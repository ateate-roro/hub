# Workflow: modify project

Run for any change to an existing project. All items required.

## Checklist

- [ ] Read the project's `projects/<name>.md` note first.
- [ ] Re-confirm scope: what is in/out for this change.
- [ ] If behavior/architecture changes, update the note.
- [ ] Run `workflows/multi-model-review.md` when the change is non-trivial.
- [ ] Run relevant tests (or add smoke tests for new behavior).
- [ ] Update README/usage if commands or outputs changed.
- [ ] Record results in `templates/pre-flight.md`.

## Trivial-change exception

Typo-only / comment-only edits may skip `multi-model-review.md`, but must still
update the project note if context changed and record the exemption.