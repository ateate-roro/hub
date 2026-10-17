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
