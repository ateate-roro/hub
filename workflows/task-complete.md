# Workflow: complete task

Trigger: when you write `"task completed"` (with double quotes) at the end
of a session.

## Checklist

- [ ] Confirm the current `task-NNN.md` has all context, decisions, and
      changes recorded for this session.
- [ ] Append a completion line to `task-NNN.md`:
      `- **Completed:** $(date +%Y-%m-%d)`
- [ ] Commit all pending changes with a descriptive message.
- [ ] Push the branch to `origin`.
- [ ] Open a PR from the branch against its base branch.
- [ ] If project context changed (new files, stack changes, decisions),
      update the relevant project note and `projects/PROJECTS.md` (hub) or
      `README.md` (standalone repo) in the same PR.
- [ ] Link the PR in `task-NNN.md`:
      `- **PR:** <url>`

## Definition of done

Task is marked completed, all changes are committed + pushed, a PR is open,
and the task file links to the PR. The `tasks/` folder is ready for the
next `task-NNN.md`.
