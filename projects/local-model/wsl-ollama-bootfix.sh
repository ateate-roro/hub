#!/bin/bash
# wsl-ollama-bootfix.sh — WSL boot hook (invoked by /etc/wsl.conf [boot] command=).
# Runs as root on every WSL VM start; requires no shell, no .bashrc, no login.
#
# What it guarantees before user processes start:
#   1. Detect the current Windows-host IP (it can change across WSL reboots).
#   2. Sync ~/.config/opencode/opencode.json  providers.ollama.settings.baseURL
#      -> http://<host-ip>:11434/v1 (OpenCode V2 ignores a root-level baseURL).
#   3. Verify Ollama answers from WSL (the check doubles as the binding check:
#      a 127.0.0.1-only server is unreachable from WSL); if down, launch the
#      Windows-side fix early (start-ollama.ps1) and keep polling.
#   4. Stop the retired ollama-forwarder if a stale copy is running. OpenCode
#      connects directly via settings.baseURL; the forwarder reset client
#      connections when a response completed (ECONNRESET on the next prompt).
#
# Fast path (Ollama already up) finishes in a few seconds so it never
# meaningfully delays WSL boot; worst case (Ollama down) is ~20s of polling
# while the detached Windows fix brings it up.
# Everything is logged to /var/log/wsl-ollama-bootfix.log.

set -u
trap '' HUP   # survive interop session teardown signalling
LOG=/var/log/wsl-ollama-bootfix.log
CFG=/home/svarog/.config/opencode/opencode.json
PS1_FIX='C:\Users\19198\orca\hub\projects\local-model\start-ollama.ps1'
POWERSHELL=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
LAUNCH_FLAG=/run/wsl-ollama-fix-launched

log() { echo "$(date -Is) $*" >>"$LOG" 2>&1; }

detect_host_ip() {
    local i ip
    for i in $(seq 1 10); do
        ip=$(ip route show default 2>/dev/null | awk '/^default/ {print $3; exit}')
        if [ -z "${ip:-}" ]; then
            ip=$(awk '/^nameserver/ {print $2; exit}' /etc/resolv.conf 2>/dev/null)
        fi
        if [ -n "${ip:-}" ]; then
            echo "$ip"
            return 0
        fi
        sleep 1
    done
    return 1
}

sync_base_url() {
    local ip="$1" rc
    if [ ! -f "$CFG" ]; then
        echo "config missing ($CFG) - skipping baseURL sync"
        return 0
    fi
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$CFG" "$ip" <<'PYEOF'
import json, os, sys
path, ip = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        cfg = json.load(f)
except Exception as e:
    print("config unparseable, refusing to rewrite: %s" % e)
    sys.exit(3)
st = os.stat(path)
prov = cfg.setdefault("providers", {}).setdefault("ollama", {})
new = "http://%s:11434/v1" % ip
# OpenCode V2 reads providers.ollama.settings.baseURL; a root-level
# "baseURL" (V1 shape) is silently ignored and breaks model discovery.
stale = prov.pop("baseURL", None)
settings = prov.setdefault("settings", {})
if settings.get("baseURL") == new and stale is None:
    print("baseURL already current: %s" % new)
    sys.exit(0)
settings["baseURL"] = new
cfg.setdefault("model", "ollama/qwen3-coder:30b")
tmp = path + ".tmp"
with open(tmp, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
os.chown(tmp, st.st_uid, st.st_gid)
os.chmod(tmp, st.st_mode & 0o7777)
os.replace(tmp, path)
print("baseURL synced -> %s" % new)
PYEOF
        rc=$?
        echo "sync_base_url python rc=$rc"
        return "$rc"
    else
        sed -i -E "s#(\"baseURL\"[[:space:]]*:[[:space:]]*\")[^\"]*(\")#\1http://${ip}:11434/v1\2#" "$CFG"
        echo "sync_base_url sed-fallback rc=$?"
        return 0
    fi
}

kill_forwarder() {
    # Retired: OpenCode connects directly via providers.ollama.settings.baseURL.
    # The forwarder reset client connections when a response completed, so any
    # stale copy must be stopped, never started. awk-bracket trick: pattern
    # must not match this script's own command line.
    local pids
    pids=$(ps -eo pid=,args= | awk '/[o]llama-forwarder/ {print $1}')
    if [ -n "$pids" ]; then
        kill $pids 2>/dev/null
        sleep 1
        kill -9 $pids 2>/dev/null
        log "killed retired ollama-forwarder (pid(s): $pids)"
    fi
    return 0
}

launch_windows_fix() {
    local i
    if [ -e "$LAUNCH_FLAG" ]; then
        return 0
    fi
    for i in $(seq 1 5); do
        [ -x "$POWERSHELL" ] && break
        sleep 1
    done
    if [ ! -x "$POWERSHELL" ]; then
        log "FATAL: powershell.exe not available - cannot invoke Windows fix"
        return 1
    fi
    touch "$LAUNCH_FLAG"
    log "launching Windows fix (start-ollama.ps1, setsid-detached)"
    setsid nohup "$POWERSHELL" -NoProfile -ExecutionPolicy Bypass -File "$PS1_FIX" >>"$LOG" 2>&1 </dev/null &
    disown 2>/dev/null || true
    return 0
}

ensure_ollama() {
    local host_ip="$1" i
    if ! command -v curl >/dev/null 2>&1; then
        log "curl not available - cannot verify ollama"
        echo 0
        return 0
    fi
    # Poll up to ~24s. Launch the Windows fix EARLY (after ~4s of failures)
    # so Ollama restarts while we keep polling, instead of after a long dead
    # wait. A 127.0.0.1-only server is unreachable from WSL, so this check
    # also catches a wrongly-bound listener.
    for i in $(seq 1 12); do
        if curl -sf -m 1 "http://${host_ip}:11434/api/tags" >/dev/null 2>&1; then
            echo 1
            return 0
        fi
        if [ "$i" -eq 3 ]; then
            launch_windows_fix
        fi
        sleep 1
    done
    echo 0
    return 0
}

start_warmup() {
    local ip="$1"
    # Detached WSL-side model warm-up. Independent of interop lifetime (the
    # Windows-side ps1 warm can die with session teardown when WE launched the
    # ps1; the logon-startup path does its own warm natively). devstral first,
    # qwen3-coder LAST so the OpenCode default model stays VRAM-resident
    # (24 GB VRAM cannot hold both).
    setsid nohup env OLLAMA_WARM_HOST="http://${ip}:11434" WARM_LOG="$LOG" bash -c '
        {
            for m in devstral:24b qwen3-coder:30b; do
                echo "warm start: $m $(date -Is)"
                curl -sf -m 180 -X POST -H "Content-Type: application/json" \
                    -d "{\"model\":\"$m\",\"prompt\":\"hi\",\"stream\":false}" \
                    "$OLLAMA_WARM_HOST/api/generate" >/dev/null \
                    && echo "warm ok: $m" || echo "warm FAILED: $m"
            done
            echo "warm pass complete $(date -Is)"
        } >>"$WARM_LOG" 2>&1
    ' </dev/null &
    disown 2>/dev/null || true
    log "detached WSL-side warm-up started (devstral first, qwen last)"
}

main() {
    log "=== bootfix run (pid=$$) ==="
    local HOST_IP up
    if ! HOST_IP=$(detect_host_ip); then
        log "FATAL: could not detect Windows host IP - .bashrc safety net will retry in interactive shells"
        exit 1
    fi
    log "host ip: $HOST_IP"

    sync_base_url "$HOST_IP" >>"$LOG" 2>&1

    up=$(ensure_ollama "$HOST_IP")
    if [ "$up" -eq 1 ]; then
        log "ollama reachable at ${HOST_IP}:11434"
        start_warmup "$HOST_IP"
    else
        log "ollama still not reachable after launch attempts at ${HOST_IP}:11434"
        launch_windows_fix
    fi

    # Forwarder retired: ensure no stale copy is listening on 127.0.0.1:11434.
    kill_forwarder
    log "=== bootfix done (host_ip=$HOST_IP ollama_up=$up) ==="
}

main "$@"
