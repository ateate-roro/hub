# Hub

Central, versioned source of truth for two things:

1. **Project context summaries** - one short, living note per project under `projects/`,
   plus a `tasks/` folder (with `task-<number>.md` notes) inside each project repo to
   log context per session for efficient resume.
2. **Reusable workflows & quality gates** - checked before/while **any** project is started or modified (`workflows/`).

## Operating rule (read this first)

Whenever a new project is started **or** an existing project is modified:

1. Read `workflows/README.md`.
2. Run every workflow marked **required**, plus any **conditional** workflow that applies.
3. Record the result (pass/fail + evidence) in the project note or the PR/commit notes.
4. If context changed, update that project's note in `projects/` in the same change.

No project work should be considered "done" until its applicable workflows have been run and recorded.

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
