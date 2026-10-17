#!/usr/bin/env bash
# consolidate-tasks.sh
#
# Merge older task summaries in a project's tasks/ folder into one
# consolidated summary, then archive the originals.
#
# Usage:
#   ./scripts/consolidate-tasks.sh projects/<project-name> [max-files]
#
# Defaults: keeps the 5 most recent task files, consolidates the rest into
# a dated consolidated summary and moves the originals to tasks/archive/.

set -euo pipefail

PROJECT_DIR="${1:?usage: consolidate-tasks.sh projects/<project-name> [max-files]}"
MAX_FILES="${2:-5}"
TASKS_DIR="$PROJECT_DIR/tasks"
ARCHIVE_DIR="$TASKS_DIR/archive"

if [ ! -d "$TASKS_DIR" ]; then
  echo "No tasks/ folder at $TASKS_DIR" >&2
  exit 1
fi

# Collect task files (exclude README.md and archive/), sorted newest first.
mapfile -t TASK_FILES < <(find "$TASKS_DIR" -maxdepth 1 -type f -name '*.md' ! -name 'README.md' | sort -r)

TOTAL=${#TASK_FILES[@]}

if [ "$TOTAL" -le "$MAX_FILES" ]; then
  echo "Only $TOTAL task file(s) (threshold $MAX_FILES). Nothing to consolidate."
  exit 0
fi

FILES_TO_ARCHIVE=("${TASK_FILES[@]:$MAX_FILES}")
KEPT_FILES=("${TASK_FILES[@]:0:$MAX_FILES}")

CONSOLIDATED="$TASKS_DIR/consolidated-$(date +%Y-%m).md"

mkdir -p "$ARCHIVE_DIR"

{
  echo "# Consolidated task summary"
  echo ""
  echo "Merged $((${#FILES_TO_ARCHIVE[@]})) older task files on $(date +%Y-%m-%d)."
  echo "Most recent $MAX_FILES task files kept unmerged in this folder."
  echo ""
  echo "## Archived tasks"
  echo ""
  for f in "${FILES_TO_ARCHIVE[@]}"; do
    name="$(basename "$f")"
    echo "- [$name](archive/$name)"
    # Append a short excerpt (first 10 non-empty lines) for context.
    echo "  > $(sed -n 's/^# //p; /^$/d; 1,10p' "$f" | head -n 1 | cut -c1-120)"
  done
} > "$CONSOLIDATED"

for f in "${FILES_TO_ARCHIVE[@]}"; do
  mv "$f" "$ARCHIVE_DIR/"
done

echo "Consolidated ${#FILES_TO_ARCHIVE[@]} task file(s) into $CONSOLIDATED"
echo "Kept ${#KEPT_FILES[@]} most recent file(s) unmerged."
echo "Archived originals in $ARCHIVE_DIR/"
