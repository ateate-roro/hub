# Hub

Central, versioned source of truth for two things:

1. **Project context summaries** - one short, living note per project under `projects/`,
   plus a `tasks/` folder (with `task-<number>.md` notes) inside each project repo to
   log context per session for efficient resume.
2. **Reusable workflows & quality gates** - checked before/while **any** project is started or modified (`workflows/`).
3. **Per-session context** - `workflows/session-start.md` + `scripts/load-session-context.sh` scan project subfolders and `tasks/` folders at the start of each session to load full context before modifications or debugging.

## Operating rule (read this first)

Whenever a new project is started **or** an existing project is modified:

1. Read `workflows/README.md`.
2. Run every workflow marked **required**, plus any **conditional** workflow that applies.
3. Record the result (pass/fail + evidence) in the project note or the PR/commit notes.
4. If context changed, update that project's note in `projects/` in the same change.

No project work should be considered "done" until its applicable workflows have been run and recorded.

## GitHub Integration Status

GitHub integrations are functional. The repository is configured with:
- SSH key authentication (verified)
- Remote URL: https://github.com/ateate-roro/hub.git  
- Working Git configuration
- Proper access to the ateate-roro organization

## Layout

```
.
├── README.md
├── projects/
│   └── PROJECTS.md
├── workflows/
├── models/
└── templates/
```

## Quick links

- Project index: `projects/PROJECTS.md`
- Workflows: `workflows/README.md`
- Model suggestions: `models/suggestions.md`