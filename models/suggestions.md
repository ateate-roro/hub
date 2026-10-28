# Model suggestions (by role)

Pick models from **different families** for P and R so they don't share blind spots.

## Role mapping for `workflows/multi-model-review.md`

| Step | Role | Suggested (general) | Budget/free (OpenCode) | Local (Ollama) |
|---|---|---|---|---|
| 1 Plan | P - Planner | Claude Opus 4.5, GPT-5 (high), Gemini 2.5 Pro, DeepSeek R1 | Cat Jam Free (max), LongCat 2.5 Preview Free | ollama/devstral:24b |
| 2/7 Review | R - Reviewer | Gemini 2.5 Pro, GPT-5 (medium), Claude Sonnet 4.5 | Space Bunny Free (high), Muse Spark 1.3 Free (high) | ollama/qwen3-coder:30b |
| 4 Build | B - Builder | Claude Sonnet 4.5, GPT-5 Codex, Qwen3-Coder, DeepSeek V3.x | Step 5 Preview Free, Nemotron 3.5 Lightning Free | ollama/qwen3-coder:30b |
| 5 Review build | P again | same as Planner | same as Planner | same as Plan |
| 6 Apply fixes | P (original) | same as Planner | same as Planner | same as Plan |
| 7 Final review | R again | same as Reviewer | same as Reviewer | same as Review |

## Practical picks (if you want concrete combos)

- **High quality (paid):** P=GPT-5 high, R=Gemini 2.5 Pro, B=Claude Sonnet 4.5.
- **Cost-effective (paid):** P=DeepSeek R1, R=GPT-5 mini, B=DeepSeek V3.x (or Qwen3-Coder).
- **Free-only (OpenCode):** P=Cat Jam Free (max), R=Space Bunny Free (high), B=Step 5 Preview Free (high).
  - Note: free models vary in reliability; keep changes small and re-run reviews.
- **Local-only (Ollama, free):** P=ollama/devstral:24b, R=ollama/qwen3-coder:30b, B=ollama/qwen3-coder:30b.
  - Uses the hub's local Ollama inference (`providers.ollama.settings.baseURL` → `http://<windows-host-ip>:11434/v1`), no remote calls. Cross-family: devstral (llama family) for Plan, qwen3-coder (qwen family) for Review/Build.

## Selection principles

1. **Cross-family:** P and R must not be the same family.
2. **Match strength to stage:** planning/review favor reasoning; building favors code.
3. **Independence over price:** a cheaper *different* reviewer beats an expensive same-family one.
4. **Record what you used** in `templates/pre-flight.md`.

## Available in this OpenCode install

`opencode/cat-jam-free`, `opencode/longcat-2.5-preview-free`, `opencode/space-bunny-free`,
`opencode/mimo-v2.6-flash-free`, `opencode/step-5-preview-free`,
`opencode/muse-spark-1.3-contributor-free`, `opencode/nemotron-3.5-lightning-free`,
`opencode/big-pickle`.
(Discover current list with `opencode models` from the OpenCode tool.)