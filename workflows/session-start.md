# Workflow: start session / load context

Run at the start of every session in any repository to load established
context before making modifications or debugging.

## Checklist

- [ ] Identify the repository type: hub (`projects/<name>/tasks/`) or
      standalone (`tasks/` at repo root).
- [ ] Run `scripts/load-session-context.sh` to scan project subfolders and
      task files for full context (includes Ollama/local-model status).
- [ ] **Verify local model is available:** Ollama is auto-started on every new
      WSL terminal via `~/.bashrc` (detects Windows host IP, exports
      `OLLAMA_HOST`, starts `projects/local-model/start-ollama.ps1` if
      unreachable). Confirm Ollama answers at
      `http://<windows-host-ip>:11434/api/tags`.
- [ ] **Offline / no-pull fallback:** if Ollama cannot be reached or models
      cannot be pulled (no internet), the session falls back to the last
      working local model recorded in
      `~/.config/opencode/last-working-model`. No hosted/remote models are
      ever used as a substitute.
- [ ] **Confirm local-only models:** ensure the session's default model is an
      Ollama model (e.g. `ollama/qwen3-coder:30b` or `ollama/devstral:24b`)
      per `opencode.json` — no hosted/remote models.
- [ ] Review the emitted context summary (recent tasks, project notes,
      model suggestions).
- [ ] If this session will do active project work, run
      `workflows/multi-model-review.md` (the established models workflow)
      before modifying anything.
- [ ] Create `task-<next-number>.md` in the relevant `tasks/` folder to log
      this session's context as you go.

## Definition of done

Session begins with full project context loaded; local Ollama model verified
available (or last-working-model fallback recorded); model workflow is
invoked for active work; a new task file is opened for this session. No
hosted/remote models are used.
