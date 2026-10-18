# task-005 — Session error-logging helpers for local-model triage

## Summary

Added three shell helpers to the WSL `~/.bashrc` (second block,
`# --- OpenCode session error logging ... ---`) to capture and triage errors
that come up while running local Ollama models, and documented them in the
project note (the helpers themselves live outside the repo).

| Helper | Purpose |
|---|---|
| `oc-errors [n]` | Print the last `n` error records (default 3) from `~/.local/share/opencode/log/opencode.log` with full cause/stack, one record per entry |
| `oc-logs` | Live-follow new `ERROR`/`WARN` records while a test session runs |
| `oc-repro -m ollama/<model> "<prompt>"` | Rerun a failing prompt with client + private-server DEBUG logging teed to a timestamped `/tmp/oc-repro-*.log` |

## Design notes

- **No service verbosity change.** The background service already records
  every session/provider failure at `level=ERROR` with `sessionID=`/`run=`
  and the full stack. The log has no rotation (4.3 MB after ~1.5 days at
  default level), so DEBUG stays a one-shot reproduction tool
  (`oc-repro` = `OPENCODE_LOG_LEVEL=DEBUG opencode run --standalone
  --log-level debug --print-logs`, the documented reproduction pattern).
- **Record-header anchoring.** Both grep-style helpers anchor on
  `^timestamp=... level=...`. An earlier unanchored version false-matched:
  every shell command the agent runs is logged verbatim, so the helper
  matched its own logged invocation (a `level=INFO` "spawning process" line
  containing the literal string `level=ERROR`).
- **Windows-side source.** Ollama's own rotating log
  (`C:\Users\19198\AppData\Local\Ollama\app.log`, from WSL
  `/mnt/c/Users/19198/AppData/Local/Ollama/app.log`) catches server-side
  model-load failures / runner crashes that look like client timeouts.

## Verification

- `bash -n ~/.bashrc` passes.
- `oc-errors 2` printed the real pre-fix `ModelUnavailable` record for
  `ses_timerepro01` with its 12-frame stack, cleanly separated from INFO noise.
- `oc-repro -m ollama/devstral:24b "Reply with exactly: LOGOK"` produced a
  15 KB timestamped file containing DEBUG lines and the model response;
  exit 0.
- `oc-logs` runs without errors (tail -f + anchored grep).

## Multi-model review record (2026-10-18b)

| Step | Role | Model | Outcome |
|---|---|---|---|
| 7 Final review | R | qwen3-coder:30b | SHIP |

- **Loop counts:** 0 revision cycles.
- **Exemptions:** docs-only change documenting already-tested live helpers;
  ran the final R pass instead of the full loop.

## Follow-up

- PR: https://github.com/ateate-roro/hub/pull/14
- Still pending from task-004: sync the installed
  `/usr/local/bin/wsl-ollama-bootfix.sh` via sudo (verified this session
  still not done — installed copy has 0 `settings` references).
