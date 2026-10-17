# Workflow: consolidate task summaries

Run when a project's `tasks/` folder has grown large enough that reviewing
individual task files is slower than reading one consolidated summary.
Applies to any repository following the `task-<number>.md` pattern
(e.g. `projects/<name>/tasks/` inside hub, or `tasks/` at a repo root).

Suggested trigger: 5+ task files in a project's `tasks/` folder, or when
returning to a project after a long break and the task log feels noisy.

## Checklist

- [ ] Identify the project's `tasks/` folder (e.g. `projects/<name>/tasks/`
      inside hub, or `tasks/` at a repo root).
- [ ] Run `scripts/consolidate-tasks.sh [max-files]` to merge old task
      files into one consolidated summary and archive the originals.
- [ ] Review the consolidated summary for accuracy.
- [ ] Commit the consolidated summary and archived originals together.

## Definition of done

Task history is preserved (archived originals + consolidated summary) but the
active `tasks/` folder is small enough to skim quickly.
