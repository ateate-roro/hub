# collectors-hub

## Identity

- **Repo:** `cbailey03/collectors-hub` (private, collaborator)
- **URL:** https://github.com/cbailey03/collectors-hub
- **Stack:** Rust backend (Actix Web or Axum, PostgreSQL/MongoDB, Diesel/SQLx, JWT auth)
  + Django + Vanilla JS + Bootstrap 5 frontend.
- **Deployment:** Google Cloud Run (planned), Docker (planned), GitHub Actions CI/CD (planned).
- **Status:** In progress / early skeleton (backend/frontend folders + README).
- **Tracked in Hub:** yes

## What it does

Full-stack web app for collectors (coins, comics, action figures, cards, etc.) to manage,
showcase, and share collections.

### Core features (from README)

- Secure user auth (Rust API).
- Add/edit/delete collections and items.
- Upload photos for items.
- Public & private sharing.
- User dashboard with stats + recent activity.
- Search & filter across collections.
- Responsive desktop/mobile UI.

### Structure

```
collectorhub/
├── backend/   # Rust API (src, Cargo.toml)
└── frontend/  # Django + JS + Bootstrap (manage.py, requirements.txt)
```

## Open questions / risks to track

- Backend ORMs are undecided (Diesel vs SQLx); DB engine undecided (Postgres vs Mongo).
- Many features listed as goals, not implemented; verify actual code before assuming.
- Deployment pipeline (Docker + Actions) marked "planned", not done.

## Suggested next steps

- Audit `backend/src` and `frontend/` to record what is actually implemented.
- Pick DB + ORM; document migration strategy.
- Stand up minimal auth + one collection CRUD end-to-end before expanding features.

## Workflow gate checklist (last run)

- [ ] `workflows/modify-project.md`
- [ ] `workflows/multi-model-review.md` (for feature work)

_Last updated: 2026-10-14 (hub bootstrap)._