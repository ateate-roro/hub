# Workflow: start session / load context

Run at the start of every session in any repository to load established
context before making modifications or debugging.

## Checklist

- [ ] Identify the repository type: hub (`projects/<name>/tasks/`) or
      standalone (`tasks/` at repo root).
- [ ] Run `scripts/load-session-context.sh` to scan project subfolders and
      task files for full context.
- [ ] Review the emitted context summary (recent tasks, project notes,
      model suggestions).
- [ ] If this session will do active project work, run
      `workflows/multi-model-review.md` (the established models workflow)
      before modifying anything.
- [ ] Create `task-<next-number>.md` in the relevant `tasks/` folder to log
      this session's context as you go.

## Definition of done

Session begins with full project context loaded; model workflow is invoked
for active work; a new task file is opened for this session.
