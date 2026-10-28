# task-002 — Make model suggestions use local Ollama models

## Summary

Aligned `models/suggestions.md` with the local-model-inference setup so the
multi-model-review P/R roles use local Ollama models instead of remote OpenCode
free models ("this should be a local model").

## What changed

1. **`models/suggestions.md`**
   - Added a "Local (Ollama)" column to the role-mapping table:
     - P (Plan) = `ollama/devstral:24b` (llama family)
     - R (Review) = `ollama/qwen3-coder:30b` (qwen family)
     - B (Build) = `ollama/qwen3-coder:30b`
   - Added a "Local-only (Ollama, free)" practical pick: P=devstral:24b,
     R=qwen3-coder:30b, B=qwen3-coder:30b. Uses local Ollama inference
     (`baseURL http://localhost:11434/v1`), no remote calls. P and R are
     cross-family (llama vs qwen).

2. **`projects/local-model/local-model-inference.md`**
   - Updated workflow gate checklist (added modify-project pass).
   - Added a pre-flight record entry.
   - Updated `_Last updated` timestamp.

## Cross-references

- `local-model-inference.md` line ~151 already claims multi-model review uses
  `devstral:24b`/`qwen3-coder:30b` "per `models/suggestions.md`" — this is now
  accurate.
- Resolves the mismatch where `models/suggestions.md` listed remote OpenCode
  free models while the project note claimed local models were used.

## Branch

`feat/ollama-ws-l-autofix` (current branch, working tree was clean before this change).

- **Date:** 2026-10-16
- **Owner:** ateate-roro
