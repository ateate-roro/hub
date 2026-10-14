# Workflows - catalogue & gating rules

## Rule: check before start or change

Before starting a new project or modifying an existing one:

1. Read this file.
2. Run every workflow marked **required**.
3. Run any **conditional** workflow whose trigger matches.
4. Record results using `templates/pre-flight.md`.

## Workflows

| Workflow | File | When | Required? |
|---|---|---|---|
| Multi-model review | `multi-model-review.md` | Any non-trivial code/spec/feature change | **required** for shipped changes |
| New project | `new-project.md` | Starting a brand-new project/repo | **required** |
| Modify project | `modify-project.md` | Any change to an existing project | **required** |

### Conditional add-ons (future)

- Security review - when handling auth, payments, secrets, user data.
- Data migration review - when schema/CSV formats change.
- Dependency upgrade review - when bumping major versions.

## Recording

Use `templates/pre-flight.md` to record which workflows ran and their outcome.
Store the filled-in copy in the project note or the PR description.

## Adding a workflow

1. Add a `workflows/<name>.md` file following the style of `multi-model-review.md`.
2. Add a row to the table above.
3. Update `templates/pre-flight.md` checklist if needed.
4. Commit to `hub` first, then reference from projects.