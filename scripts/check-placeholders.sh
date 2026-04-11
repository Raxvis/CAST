#!/usr/bin/env bash
#
# check-placeholders.sh
#
# Scans all markdown files in the current project for unreplaced
# [UPPER_SNAKE_CASE] placeholder tokens and reports them grouped by file.
#
# Usage:
#   ./scripts/check-placeholders.sh [additional-file-to-skip ...]
#
# Exit code:
#   0 — no unreplaced placeholders found
#   1 — at least one placeholder remains
#
# Files that legitimately contain placeholder tokens as *documentation*
# (e.g. this template's own README listing every available placeholder)
# are skipped by default. Add more filenames on the command line to
# extend the skip list.
#
# Note: this check is best-effort. Template files that contain
# sub-templates — for example, a bug-report template with `[DATE]` and
# `[REPRODUCTION_STEPS]` fields inside a fenced code block — will
# produce matches even after the surrounding file has been customized.
# Review the output and decide whether each match is a real unreplaced
# placeholder or a deliberately-kept fill-in-per-use marker.

set -euo pipefail

# Metadata files that intentionally list placeholders as documentation,
# or that describe template state rather than target project content.
SKIP_FILES=(
  "README.md"
  "CHANGELOG.md"
  "TROUBLESHOOTING.md"
)

# Allow callers to extend the skip list.
if [ "$#" -gt 0 ]; then
  SKIP_FILES+=("$@")
fi

# Build grep --exclude flags from the skip list.
EXCLUDE_ARGS=()
for f in "${SKIP_FILES[@]}"; do
  EXCLUDE_ARGS+=(--exclude="$f")
done

# Placeholder pattern: [UPPER_SNAKE_CASE] with at least two characters.
# Matches [PROJECT_NAME], [FRAMEWORK], [MILESTONE_1] etc.
# Does NOT match markdown link syntax [text](url) or mixed-case
# example identifiers like [MyComponent] or [DomainType].
PATTERN='\[[A-Z][A-Z0-9_]+\]'

# Run the scan. Suppress "No such file" errors on empty directories.
set +e
RESULTS=$(grep -rEn "$PATTERN" \
  --include='*.md' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=build \
  --exclude-dir=dist \
  --exclude-dir=.next \
  --exclude-dir=vendor \
  "${EXCLUDE_ARGS[@]}" \
  . 2>/dev/null)
GREP_EXIT=$?
set -e

# grep exit 1 = no matches; treat as success.
if [ "$GREP_EXIT" -eq 1 ] || [ -z "$RESULTS" ]; then
  echo "PASS: no unreplaced placeholders found."
  exit 0
fi

# grep exit >1 = real error.
if [ "$GREP_EXIT" -gt 1 ]; then
  echo "ERROR: grep failed with exit code $GREP_EXIT" >&2
  exit 2
fi

echo "FAIL: unreplaced placeholders found."
echo
echo "Skipped files: ${SKIP_FILES[*]}"
echo

LAST_FILE=""
LINE_COUNT=0
FILE_COUNT=0

while IFS= read -r line; do
  FILE=$(printf '%s' "$line" | cut -d: -f1)
  LINE_NUM=$(printf '%s' "$line" | cut -d: -f2)
  CONTENT=$(printf '%s' "$line" | cut -d: -f3-)

  if [ "$FILE" != "$LAST_FILE" ]; then
    [ -n "$LAST_FILE" ] && echo
    echo "$FILE"
    LAST_FILE="$FILE"
    FILE_COUNT=$((FILE_COUNT + 1))
  fi

  # Extract unique placeholder tokens from the line.
  TOKENS=$(printf '%s' "$CONTENT" | grep -oE "$PATTERN" | sort -u | tr '\n' ' ')
  echo "  line $LINE_NUM: $TOKENS"
  LINE_COUNT=$((LINE_COUNT + 1))
done <<< "$RESULTS"

echo
echo "Total: $LINE_COUNT lines across $FILE_COUNT files."
exit 1
