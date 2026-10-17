#!/usr/bin/env bash
# load-session-context.sh
#
# Scan a repository's project subfolders and task files to emit a
# consolidated context summary for the start of a session.
#
# Works for:
#   - hub layout:    projects/<name>/tasks/task-*.md
#   - standalone:    tasks/task-*.md at repo root
#
# Usage:
#   ./scripts/load-session-context.sh

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

OUTPUT=""

# --- Detect hub layout -----------------------------------------------------
if [ -f "projects/PROJECTS.md" ] && [ -d "projects" ]; then
  LAYOUT="hub"
else
  LAYOUT="standalone"
fi

# --- Gather project notes --------------------------------------------------
if [ "$LAYOUT" = "hub" ]; then
  PROJECT_NOTES=$(find projects -maxdepth 2 -name '*.md' ! -name 'PROJECTS.md' ! -path '*/tasks/*' 2>/dev/null | sort)
else
  PROJECT_NOTES=$(find . -maxdepth 1 -name 'README.md' 2>/dev/null | sort)
fi

# --- Gather task files -----------------------------------------------------
if [ "$LAYOUT" = "hub" ]; then
  TASK_FILES=$(find projects -path '*/tasks/task-*.md' 2>/dev/null | sort -r)
else
  TASK_FILES=$(find tasks -name 'task-*.md' 2>/dev/null | sort -r)
fi

# --- Ollama / local model reachability (WSL) --------------------------------
OLLAMA_STATUS=""
WSL_HOST_IP=""
LAST_MODEL_FILE="$HOME/.config/opencode/last-working-model"
if [ -f /etc/resolv.conf ]; then
  WSL_HOST_IP=$(grep nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}' | head -n1)
fi
if [ -n "${WSL_HOST_IP:-}" ]; then
  if curl -s --max-time 2 "http://${WSL_HOST_IP}:11434/api/tags" >/dev/null 2>&1; then
    OLLAMA_STATUS="reachable at http://${WSL_HOST_IP}:11434 (local Ollama)"
  else
    OLLAMA_STATUS="NOT reachable at http://${WSL_HOST_IP}:11434"
    if [ -f "$LAST_MODEL_FILE" ]; then
      LAST_MODEL=$(cat "$LAST_MODEL_FILE" 2>/dev/null)
      OLLAMA_STATUS="${OLLAMA_STATUS} — offline fallback: last working local model = ${LAST_MODEL}"
    else
      OLLAMA_STATUS="${OLLAMA_STATUS} — start Ollama on Windows with projects/local-model/start-ollama.ps1"
    fi
  fi
else
  OLLAMA_STATUS="could not detect Windows host IP from /etc/resolv.conf"
fi
unset LAST_MODEL_FILE LAST_MODEL

# --- Model suggestions -----------------------------------------------------
MODEL_SUGGESTIONS=""
if [ -f "models/suggestions.md" ]; then
  MODEL_SUGGESTIONS="models/suggestions.md"
fi

{
  echo "# Session context"
  echo ""
  echo "Repository: $REPO_ROOT"
  echo "Layout: $LAYOUT"
  echo "Date: $(date +%Y-%m-%d)"
  echo ""

  echo "## Local model (Ollama) status"
  echo "- ${OLLAMA_STATUS}"
  echo ""
  echo ""
  echo "Repository: $REPO_ROOT"
  echo "Layout: $LAYOUT"
  echo "Date: $(date +%Y-%m-%d)"
  echo ""

  echo "## Project notes"
  if [ -n "$PROJECT_NOTES" ]; then
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      echo "- [$f]($f)"
      head -n 8 "$f" | sed 's/^/  > /'
    done <<< "$PROJECT_NOTES"
  else
    echo "(none found)"
  fi
  echo ""

  echo "## Recent task files"
  if [ -n "$TASK_FILES" ]; then
    COUNT=0
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      COUNT=$((COUNT+1))
      if [ "$COUNT" -le 10 ]; then
        echo "- [$f]($f)"
        head -n 6 "$f" | sed 's/^/  > /'
      fi
    done <<< "$TASK_FILES"
    REMAINING=$((COUNT - 10))
    if [ "$REMAINING" -gt 0 ]; then
      echo ""
      echo "... and $REMAINING older task file(s)."
    fi
  else
    echo "(none found)"
  fi
  echo ""

  if [ -n "$MODEL_SUGGESTIONS" ]; then
    echo "## Model suggestions"
    echo "- [$MODEL_SUGGESTIONS]($MODEL_SUGGESTIONS)"
    echo ""
  fi

  echo "## Next steps"
  echo "- Run workflows/session-start.md checklist."
  echo "- For active project work, run workflows/multi-model-review.md first."
  echo "- Log this session in task-<next-number>.md."
} | tee /tmp/session-context.md

echo ""
echo "Context summary written to /tmp/session-context.md"
