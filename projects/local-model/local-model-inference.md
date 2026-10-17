# local-model-inference

## Identity

- **Repo:** `ateate-roro/hub` (local-model inference setup tracked in hub)
- **Local clone:** `C:\Users\19198\orca\hub`
- **URL:** local
- **Owner:** ateate-roro
- **Language / stack:** Python 3 (inference client), JSON (OpenCode config), shell (winget / Ollama)
- **Status:** Active (in use - local inference wired into OpenCode build agent)
- **Tracked in Hub:** yes

## What it does

Sets up fully local, free LLM inference on the owner's Windows workstation via
Ollama, and wires OpenCode to use it as the default model provider.

- Ollama server installed via winget (`Ollama.Ollama` v0.40.5), running locally and
  GPU-accelerated via NVIDIA RTX 4090 (24 GB VRAM).
- Open-weight models pulled: `devstral:24b` (primary), `qwen3-coder:30b` (secondary).
- Reusable Python inference script via the `ollama` pip client (venv + httpx/pydantic).
- OpenCode provider configured (`ollama`, baseURL `http://localhost:11434/v1` —
  Ollama running on Windows, OpenCode runs on Windows) with
  global default model `ollama/qwen3-coder:30b`.

## Key components / files

- Ollama install/service: `C:\Users\19198\AppData\Local\Programs\Ollama\ollama.exe`
  (installed via `winget install Ollama.Ollama`).
- Model store: `C:\Users\19198\AppData\Local\ollama`.
- Inference client venv: `C:\Users\19198\AppData\Local\Temp\opencode\ollama-test`
  (python `ollama` package + scripts: `local_inference.py`, `plan_step_p.py`,
  `review_step_r.py`, `plan_step_p_revise.py`, `review_step_r_revise.py`,
  `check_openai_endpoint.py`, `list_models.py`, `delete_test_models.py`).
- OpenCode config: `C:\Users\19198\.config\opencode/opencode.json`.

## Tech / dependencies

- Ollama (Go server; GGUF models; OpenAI-compatible API on `:11434/v1`).
- Python 3.14 venv with `ollama` == 0.6.3 (+ httpx, pydantic).
- NVIDIA RTX 4090 GPU (24 GB VRAM) for acceleration.

## CLI / usage

```
winget install Ollama.Ollama
ollama pull devstral:24b
ollama pull qwen3-coder:30b

C:\Users\19198\AppData\Local\Temp\opencode\ollama-test\Scripts\python.exe \
  C:\Users\19198\AppData\Local/Temp/opencode/ollama-test/local_inference.py \
  --model devstral:24b --prompt "..."

C:\Users\19198\AppData\Roaming\ai.opencode.desktop\cli\2.0.29-x64\opencode-cli.exe \
  run -m ollama/qwen3-coder:30b "<prompt>"
```

OpenCode default model: `ollama/qwen3-coder:30b` (set via global `model` in
`C:\Users\19198/.config/opencode/opencode.json`).

## Known issues / gaps

- Inference client venv lives under the temp dir (if missing, recreate venv + reinstall
  `ollama`; the venv `python.exe` launcher had gone missing once).
- `num_ctx` defaults may limit tool calling for Ollama models; docs suggest raising to
  ~16k-32k if tool calls misbehave.
- Only the `build` agent was defaulted to a local model; plan/explore/subagents can
  override via agent config or `@` mentions.
- Ollama on Windows is bound to `127.0.0.1:11434` only (not `0.0.0.0`), so it is
  reachable from Windows (`localhost`) but not directly from WSL via `172.28.192.1`.
  To access from WSL too, restart Ollama with `OLLAMA_HOST=0.0.0.0:11434`.

## Auto-start: ensure Ollama is running before each conversation

Script: `projects/local-model/start-ollama.ps1` (PowerShell)

What it does:
1. Polls `http://localhost:11434/api/tags` to check if Ollama is running.
2. If not running, starts `ollama.exe serve` and waits up to 60 seconds for it to respond.
3. Prints status (green = running, red = failed to start).

Usage: run `.\projects\local-model\start-ollama.ps1` in PowerShell before starting a
conversation, or add it to your shell profile / OpenCode startup.

## Model license verification (free / open models only)

| Model | License | Cost | Source |
|---|---|---|---|
| `qwen3-coder:30b` | Apache 2.0 | Free | Qwen (Alibaba) |
| `devstral:24b` | NVIDIA Open Model License | Free | NVIDIA |

Both models are open-weight and free to use locally. No proprietary or paid models are
configured in `opencode.json` — the only provider is Ollama (local), and the only models
registered are `devstral:24b` and `qwen3-coder:30b`.

## Conventions / context worth remembering

- Multi-model review uses cross-family P/R: devstral:24b (llama family) for planning,
  qwen3-coder:30b (qwen family) for review, per `models/suggestions.md`.
- Workflow gates: `new-project.md` + `multi-model-review.md` required for shipped changes.

## Suggested next steps

- Set local models as defaults for plan/explore agents too.
- Persist the inference client venv outside the temp dir.
- Consider pinning `num_ctx` for tool-calling models.

## Workflow gate checklist (last run)

- [x] `workflows/new-project.md` (new project)
- [x] `workflows/modify-project.md` (2026-10-16: updated OpenCode baseURL to WSL host IP)
- [x] `workflows/multi-model-review.md` (SHIP)

## Pre-flight record

- **Change:** new project `local-model-inference` scaffolding (project note + index row + commit).
- **Summary of change:** Documented and shipped the local-model-inference setup as a new
  hub project; verified OpenCode default model points at local Ollama inference.
- **Date:** 2026-10-16
- **Owner:** ateate-roro

- **Change:** update OpenCode Ollama baseURL for WSL (`localhost` → Windows host IP `172.28.192.1`).
- **Summary of change:** OpenCode config (`opencode.json`) baseURL changed from
  `http://localhost:11434/v1` to `http://172.28.192.1:11434/v1` so Ollama running on the
  Windows host is reachable from WSL. Project note updated to match.
- **Date:** 2026-10-16
- **Owner:** ateate-roro

- **Change:** revert OpenCode Ollama baseURL to `localhost` (OpenCode runs on Windows;
  Ollama bound to Windows 127.0.0.1:11434, not 0.0.0.0, so `172.28.192.1` is unreachable
  from Windows). To access Ollama from WSL too, restart Ollama with
  `OLLAMA_HOST=0.0.0.0:11434`.
- **Date:** 2026-10-16
- **Owner:** ateate-roro

- **Change:** add Ollama auto-start script + free model license verification.
- **Summary of change:** Created `projects/local-model/start-ollama.ps1` (PowerShell)
  that checks if Ollama is running on `http://localhost:11434/api/tags` and starts it
  if not. Added model license verification: `qwen3-coder:30b` (Apache 2.0, free) and
  `devstral:24b` (NVIDIA Open Model License, free). Confirmed no proprietary/paid models
  are configured in `opencode.json`.
- **Date:** 2026-10-16
- **Owner:** ateate-roro

## Workflows run

- [x] `workflows/new-project.md` - Pass
- [x] `workflows/modify-project.md` - Pass (auto-start script + license verification)
- [x] `workflows/multi-model-review.md` - Pass (SHIP)

## Multi-model review record (if run)

| Step | Role | Model | Outcome |
|---|---|---|---|
| 1 Plan | P | devstral:24b | Plan produced |
| 2 Review plan | R | qwen3-coder:30b | CHANGES REQUESTED (6 items) |
| 4 Build | B | (agent) | Implemented per revised plan |
| 5 Review build | P | devstral:24b | - |
| 7 Final review | R | qwen3-coder:30b | - |
| Gates | - | - | Approve -> Revise -> Approve -> Build -> ... -> SHIP |

- **Loop counts:** 1 revision cycle (R requested changes; P revised; R re-reviewed → APPROVE).
- **Exemptions:** none.

## Evidence / links

- Commits / PR: (pending commit)
- Notes: Local-model setup verified end-to-end via Ollama + OpenCode.

_Last updated: 2026-10-16 (added Ollama auto-start script + free model license verification)._
