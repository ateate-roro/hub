# Workflow: new project

Run when creating a brand-new project/repo. All items required.

## Checklist

- [ ] Define purpose and target user in one paragraph.
- [ ] Decide stack, hosting, data model (rough spec written down).
- [ ] Create repo; add README with setup + run.
- [ ] Add a `projects/<name>.md` note in `hub` and a row in `PROJECTS.md`.
- [ ] Add dependencies/lockfile; pin versions.
- [ ] Add license (decide and record).
- [ ] Add minimal CI (lint/test) OR document why not.
- [ ] Add `.gitignore` (no IDE/build artifacts if avoidable).
- [ ] Run `workflows/multi-model-review.md` on the initial scope/spec.
- [ ] Record results in `templates/pre-flight.md`.

## Definition of done

Repo is clonable, runnable per README, and listed in `hub` with an up-to-date note.