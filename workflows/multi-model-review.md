# Workflow: multi-model review (plan -> review -> build -> review -> fix -> final review)

Purpose: reduce blind spots by forcing independent eyes at each stage.
Never let the same model both plan and ship without review.

## Roles

| Role key | Job |
|---|---|
| **P - Planner** | Produce the first plan/spec. |
| **R - Reviewer** | Critique plan/build for correctness, risks, scope. |
| **B - Builder** | Implement exactly the agreed plan. |

Use **different model families** for P and R (and ideally B) so they don't share blind spots.
See `models/suggestions.md`.

## Required inputs

- A clear task statement (feature, bugfix, or change).
- Relevant project context (the matching `projects/<name>.md` note).
- Any constraints (stack, timeline, scope out-of-bounds).

## Steps (run in order)

### Step 1 - P: First plan
- Output: a written plan with goal, scope, steps, files touched, risks, test plan.
- Must NOT start coding yet.

### Step 2 - R: Review the plan
- Checks: feasibility, missing requirements, security/perf risks, scope creep, testability.
- Output: `APPROVE` or `CHANGES REQUESTED` with numbered items.

### Step 3 - Gate: plan approval
- If `CHANGES REQUESTED`: P revises (loop Step 1-2). Max 3 loops, then escalate to human.
- If `APPROVE`: proceed.

### Step 4 - B: Build
- Implement the approved plan. No scope beyond it.
- Output: code + tests + a short "what changed" summary.

### Step 5 - P (previous planner): Review the build
- Review whether the build matches the approved plan, edge cases handled, tests adequate.
- Output: `APPROVE` or numbered issues.

### Step 6 - Fix gate
- If issues found: **P (original model)** applies fixes. (Builder may assist; P owns the fix decisions.)
- Re-run Step 5 until P approves or escalates.

### Step 7 - R (reviewer): Final review
- Last independent pass: correctness, regressions, style, docs, security.
- Output: `SHIP` or `BLOCK` with reasons.

### Step 8 - Gate: ship decision
- `SHIP`: merge/release. Update project note + record workflow run.
- `BLOCK`: return to Step 6 (fix) or Step 1 (re-plan) depending on severity.

## Evidence to record

Use `templates/pre-flight.md` and note:
- Model used at each role (P/R/B).
- Loop counts and reasons.
- Final decision + date.

## Anti-patterns (do NOT do these)

- Skipping R because "it's a small change".
- Letting B both plan and ship without review.
- Applying fixes silently without re-review.
- Reviewing with the same model/family that produced the artifact.