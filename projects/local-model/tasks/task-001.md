# task-001 — Reorganize local-model project

## Summary

Reorganized the `local-model-inference` project documentation into a subfolder
structure under `projects/` so context is easier to track going forward.

## What changed

1. **Moved project note into subfolder**
   - `projects/local-model-inference.md` → `projects/local-model/local-model-inference.md`

2. **Created `tasks/` subfolder**
   - `projects/local-model/tasks/README.md` — explains purpose and naming convention
   - `projects/local-model/tasks/task-001.md` — this file

3. **Moved project index into `projects/`**
   - `PROJECTS.md` → `projects/PROJECTS.md`
   - Updated internal note links to be relative (e.g. `super_stonk.md`,
     `local-model/local-model-inference.md`)

4. **Updated cross-references**
   - `README.md` — layout tree + "Project index" link now point to `projects/PROJECTS.md`
   - `workflows/new-project.md` — checklist step now references `projects/PROJECTS.md`

## Commits

- `31d4fc0` — Reorganize local-model project into subfolder with tasks dir
- `8e1b1e7` — Move PROJECTS.md into projects/ folder

## Branch

`feat/local-model-inference` — clean working tree, both commits pushed.

- **Completed:** 2026-10-16
- **PR:** https://github.com/ateate-roro/hub/compare/feat/local-model-inference?expand=1
