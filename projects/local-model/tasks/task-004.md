# task-004 — Fix OpenCode V2 provider config shape; retire ollama-forwarder

## Summary

Fixed the root cause of local-model failures after the V2 upgrade: sessions
died with `Model unavailable: ollama/<model>` or `ECONNRESET` on the prompt
after the first one ("connection times out after one prompt"). OpenCode V2
reads the Ollama endpoint from `providers.ollama.settings.baseURL`; the config
(and every doc/script that wrote it) used the V1 root-level
`providers.ollama.baseURL`, which the V2 runtime **ignores**. OpenCode then
fell back to probing the default `127.0.0.1:11434` inside WSL, where the
`ollama-forwarder` proxy sat — and that proxy reset the client socket when a
response completed.

## Root cause (verified live)

1. `GET /api/provider/ollama` showed `settings: {}` and `package: ""` while
   `~/.config/opencode/opencode.json` had root-level `baseURL` → V2 ignores it.
   With the endpoint moved to `settings.baseURL`, `opencode models`
   immediately listed `ollama/devstral:24b` and `ollama/qwen3-coder:30b`.
2. `projects/local-model/ollama-forwarder`'s `pipe()` did
   `shutdown(SHUT_RDWR)` + close on **both** sockets when either direction
   ended, so every completed response reset the client connection → the next
   prompt on the reused connection got `ECONNRESET`.
3. Two writers clobbered the config with the V1 shape on every WSL boot /
   new shell: `wsl-ollama-bootfix.sh` `sync_base_url` and the `~/.bashrc`
   python snippet — so manual fixes did not stick.

## What changed (this branch)

1. **`wsl-ollama-bootfix.sh`** — `sync_base_url` now writes
   `providers.ollama.settings.baseURL` and pops any stale root-level
   `baseURL`; forwarder start replaced with `kill_forwarder` (retired — the
   script now guarantees no stale copy listens on `127.0.0.1:11434`);
   header comments updated.
2. **`projects/local-model/ollama-forwarder`** — docstring replaced with a
   RETIRED notice explaining both failure modes; kept for history.
3. **`local-model-inference.md`** — config snippet corrected to the V2 shape
   (`$schema` + `settings.baseURL`) with a "V2 shape matters" note; `.bashrc`
   behavior steps updated (3×5 s retry probe, single-model warmup gated on
   `/api/ps`); bootfix section updated; forwarder section rewritten as
   RETIRED and its duplicate `.bashrc` subsection removed; identity line fixed.
4. **`models/suggestions.md`** — stale `baseURL http://localhost:11434/v1`
   note now points at `settings.baseURL` / windows-host IP.
5. `~/.bashrc` and `~/.config/opencode/opencode.json` (outside this repo) were
   fixed live first and verified before these in-repo changes.

## Verification

- `opencode models` lists both local models; `GET /api/provider/ollama`
  shows `package: @opencode/ai/providers/openai-compatible` +
  `settings.baseURL`.
- Two consecutive prompts in one session on `ollama/devstral:24b` both
  answered (PONG1, PONG2) — the original symptom no longer reproduces.
- `bash -n` bootfix, `ast.parse` embedded python, `py_compile` forwarder.
- Functional sync test: stale root `baseURL` dropped, `settings.baseURL`
  written, second run idempotent (`already current`).
- Repo grep: no stale root-level `"baseURL"` config references remain.

## Multi-model review record (2026-10-18)

| Step | Role | Model | Outcome |
|---|---|---|---|
| 2 Review plan | R | qwen3-coder:30b | APPROVE |
| 5 Review build | P | devstral:24b | APPROVE |
| 7 Final review | R | qwen3-coder:30b | SHIP |

- **Loop counts:** 0 revision cycles (plan approved first pass; build
  approved first pass; final review SHIP first pass).
- **Exemptions:** none.

## Follow-up

- PR: https://github.com/ateate-roro/hub/pull/13
- The **installed** copy `/usr/local/bin/wsl-ollama-bootfix.sh` (root-owned,
  run by `/etc/wsl.conf [boot]`) must be re-synced from this branch, or the
  next WSL reboot re-adds the stale V1 `baseURL` and restarts the forwarder.
