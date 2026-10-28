# task-003 — Make Ollama boot-proof for WSL local models

## Summary

Fixed the root cause of local-model timeouts after reboot: OpenCode running
in WSL could not reach the Windows Ollama server (loopback-only binding), so
sessions failed with `ModelUnavailableError` and fell back to cloud models.
Ollama autostart is now wired at Windows logon **and** WSL boot, so binding,
`opencode.json` baseURL, forwarder, and model warm-up are correct before any
user process starts — boot-proof without opening a terminal.

## Root cause (verified live)

1. Stock Startup `Ollama.lnk` ran `ollama app.exe` → bound `127.0.0.1:11434`
   only → `curl http://<wsl-host-ip>:11434` from WSL timed out.
2. No autostart set `OLLAMA_HOST=0.0.0.0:11434`.
3. The only auto-fix (`start-ollama.ps1` via `.bashrc`) never ran at boot and
   had a `$m:` PowerShell parse error — it had never executed a single line.
   Orca-spawned processes never source `.bashrc` anyway.
4. `opencode.json` baseURL holds the WSL host IP, which changes across
   reboots (`172.28.192.1` this cycle).

## What changed

1. **`projects/local-model/start-ollama.ps1`** — 3 bug fixes:
   - `$m:` → `${m}:` parse error (PowerShell never ran a single line);
   - `$jobs` assigned (warm-up actually waits for models to load);
   - binding check now accepts dual-stack `::` (Ollama 0.40), kill covers
     `ollama*` and waits for port 11434 to free before restart.
2. **`projects/local-model/wsl-ollama-bootfix.sh`** (new file, versioned
   copy) — installed root-owned as `/usr/local/bin/wsl-ollama-bootfix.sh`,
   invoked by `/etc/wsl.conf` `[boot] command=` on every WSL VM start:
   host-IP detect → sync `~/.config/opencode/opencode.json` baseURL → poll
   Ollama **from WSL** (a 127.0.0.1-only server fails this check) → early
   ps1 launch if down → `ollama-forwarder` (`127.0.0.1:11434` fallback) →
   detached warm-up (devstral first, `qwen3-coder:30b` last so the default
   stays VRAM-resident). All children `setsid`-detached to survive session
   teardown. Log: `/var/log/wsl-ollama-bootfix.log`.
3. **Windows (outside the repo)** — `Startup\Ollama.lnk` swapped to run
   `start-ollama.ps1` (stock tray kept as
   `Ollama (stock tray, disabled).lnk.disabled`); user env
   `OLLAMA_HOST=0.0.0.0:11434` set via `setx`.
4. **`projects/local-model/local-model-inference.md`** — "Boot-proof
   autostart (2026-10-17)" section, pre-flight record entry, workflows list
   entry, updated `_Last updated`.

## Decisions

- Startup **shortcut** (not scheduled task) for the logon trigger.
- Warm-up runs WSL-side, `setsid`-detached: the ps1's warm phase dies when
  the WSL interop session tears down; qwen3-coder warmed **last** so its
  ~21.7 GB VRAM stays resident (24 GB card can't hold both models hot).
- Dual-stack `::` binding accepted as valid (Ollama 0.40+; proven
  IPv4-reachable from WSL; no firewall rule needed).
- `.bashrc` auto-fix kept untouched as an interactive safety net.

## Verification (simulated cold start)

Stale baseURL `192.0.2.99` planted, Windows Ollama + forwarder killed, hook
run exactly as VM boot invokes it: config synced → `172.28.192.1`, hook 14 s
cold / 2 s fast path, direct + forwarder curl OK, `qwen3-coder:30b` resident
(`size_vram` ≈ 21.7 GB), `opencode run -m ollama/qwen3-coder:30b` → OK in
2 s, fresh agent session on the local model → `LOCAL-OK`.
True-reboot validation still pending (needs a real reboot; check
`/var/log/wsl-ollama-bootfix.log`).

## Cross-references

- Continues task-001 (project reorganization) and task-002 (local model
  suggestions); same feature line as PR #7 (`feat/ollama-forwarder-autostart`).
- `workflows/modify-project.md` run (pre-flight record in PR #11 body);
  `multi-model-review` recorded as pending before merge in the project
  note's workflows list.

## Branch

`feat/ollama-ws-l-autofix`

- **Date:** 2026-10-17
- **Owner:** ateate-roro
- **PR:** https://github.com/ateate-roro/hub/pull/11 (work),
  https://github.com/ateate-roro/hub/pull/12 (task record)
