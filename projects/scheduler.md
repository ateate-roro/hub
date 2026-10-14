# scheduler

## Identity

- **Repo:** `ateate-roro/scheduler` (private)
- **URL:** https://github.com/ateate-roro/scheduler
- **Owner:** ateate-roro
- **Status:** Prototype / notes only (single `rough_doc.txt`, last touched 2026-05-11).
- **Tracked in Hub:** yes

## What it is (inferred from rough notes)

A small business-facing scheduling/messaging system. From `rough_doc.txt`:

- Messaging between **provider** and **"customer"**.
- Basic **profiles** stored as JSON.
- **Payment processing** + **invoicing**.
- A **calendar** indicating when time is free.

## What is NOT yet known (needs fleshing out before implementation)

- Language / framework / hosting choice.
- Data model (user, provider, appointment, invoice, message).
- Auth model and tenancy.
- Payment provider (Stripe?).
- Storage (JSON files vs DB).
- API vs full app.

## Suggested next steps

- Promote rough notes into a one-page spec: actors, entities, key flows.
- Decide stack (Python/FastAPI or Node) and storage.
- Only then start a `new-project` workflow run.

## Workflow gate checklist (last run)

- [ ] `workflows/new-project.md` (run before first real commit)

_Last updated: 2026-10-14 (hub bootstrap)._