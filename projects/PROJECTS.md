# Project index

One row per tracked project. Keep this file in sync with `*.md`.

| Project | Status | Owner / org | Stack | Notes file |
|---|---|---|---|---|
| super_stonk | Active (early) | ateate-roro | Python (yfinance, pandas) | [super_stonk.md](super_stonk/context.md) |
| scheduler | Prototype / notes only | ateate-roro | TBD (messaging, payments, calendar) | [scheduler.md](scheduler.md) |
| collectors-hub | In progress | cbailey03 (collab) | Rust (backend) + Django/JS (frontend) | [collectors-hub.md](collectors-hub.md) |
| hub | Active | ateate-roro | Docs / Markdown | this repo |
| local-model-inference | Active | ateate-roro | Python / JSON / shell (Ollama + OpenCode) | [local-model/local-model-inference.md](local-model/local-model-inference.md) |

## Naming rules

- Project note filename = repo name (kebab-case), e.g. `projects/super_stonk.md`.
- Add a row here and a note in this folder for every new project, before any coding.
- Update the status row when a project moves stages (idea -> active -> maintenance -> archived).

## Status legend

- `idea` - scoped but not started.
- `active` - being built or changed now.
- `maintenance` - stable, only fixes.
- `archived` - frozen, kept for reference.
- `prototype / notes only` - early notes, no implementation.
