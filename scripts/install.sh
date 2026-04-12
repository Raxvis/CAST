#!/usr/bin/env bash
#
# install.sh
#
# Copies this agent-workflow template into a target project and optionally
# fills in the most common placeholder tokens.
#
# Usage:
#   ./scripts/install.sh <target-dir>                  # interactive, essentials only
#   ./scripts/install.sh <target-dir> --full           # interactive, every supported placeholder
#   ./scripts/install.sh <target-dir> --values FILE    # non-interactive, read from FILE
#   ./scripts/install.sh <target-dir> --force          # overwrite an already-populated target
#   ./scripts/install.sh --help
#
# The values file is a simple key=value per line format:
#
#   PROJECT_NAME=Acme Dashboard
#   LANGUAGE=TypeScript
#   # comments start with #
#
# After a successful install, the chosen values are written to
# <target>/template.values so you can re-run with --values later.
#
# What gets copied:
#   root/CLAUDE.md          -> <target>/CLAUDE.md
#   agents/*.md             -> <target>/.claude/agents/
#   commands/*.md           -> <target>/.claude/commands/
#   docs/                   -> <target>/docs/
#   artifacts/              -> <target>/artifacts/
#   scripts/check-placeholders.sh -> <target>/scripts/
#
# The template's own README.md, CHANGELOG.md, TROUBLESHOOTING.md, and install
# scripts are NOT copied — they are template metadata, not project content.

set -euo pipefail

# ---------- Template version ----------
# Bumped alongside CHANGELOG.md at the template repo root.
# Stamped into the installed project's template.values for traceability.

TEMPLATE_VERSION="0.8.0"

# ---------- CLI parsing ----------

TARGET=""
VALUES_FILE=""
MODE="essentials"   # essentials | full | file
FORCE=0

usage() {
  sed -n '3,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --full)
      MODE="full"
      shift
      ;;
    --values)
      [ "$#" -lt 2 ] && { echo "Error: --values requires a filename" >&2; exit 1; }
      VALUES_FILE="$2"
      MODE="file"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -*)
      echo "Error: unknown option $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -z "$TARGET" ]; then
        TARGET="$1"
      else
        echo "Error: unexpected argument $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "Error: target directory required" >&2
  echo >&2
  usage >&2
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory $TARGET does not exist" >&2
  exit 1
fi

# Resolve target to absolute path
TARGET="$( cd "$TARGET" && pwd )"

# Find template root (parent of this script directory)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# ---------- Safety check ----------

if [ "$FORCE" -eq 0 ] && [ -d "$TARGET/.claude/agents" ]; then
  if [ -n "$(ls -A "$TARGET/.claude/agents" 2>/dev/null)" ]; then
    echo "Error: $TARGET/.claude/agents/ is already populated." >&2
    echo "Pass --force to overwrite, or choose a different target." >&2
    exit 1
  fi
fi

# ---------- Placeholder definitions ----------
# Format: KEY|description|example
#
# Essentials prompt by default. Full mode adds the rest.

ESSENTIALS=(
  "PROJECT_NAME|Human-readable project name|Acme Dashboard"
  "PROJECT_TYPE|Category of software (web service, mobile app, CLI tool, etc.)|web service"
  "ONE_SENTENCE_PITCH|Single sentence describing the product|A budgeting tool for freelancers"
  "LANGUAGE|Primary programming language|TypeScript"
  "FRAMEWORK|Primary application framework|Next.js"
  "TEST_CMD|Command to run the full test suite|npm test"
  "DEV_SERVER_CMD|Command to start the local dev server|npm run dev"
  "BUILD_CMD|Command to produce a production build|npm run build"
)

FULL_EXTRAS=(
  "FRAMEWORK_VERSION|Framework version|14.2"
  "STATE_LIBRARY|State management library|Zustand"
  "STATE_LIBRARY_VERSION|State library version|4.5"
  "PERSISTENCE_LAYER|Primary persistence mechanism|PostgreSQL"
  "NAVIGATION_LIBRARY|Routing or navigation solution|Next.js App Router"
  "TEST_RUNNER|Test runner tool|Vitest"
  "PKG_MANAGER|Package manager|pnpm"
  "PKG_ADD_CMD|Command to add a dependency|pnpm add"
  "PKG_MANIFEST|Dependency manifest filename|package.json"
  "FRAMEWORK_CONFIG|Framework config filename|next.config.js"
  "TYPE_CONFIG|Type checker config filename|tsconfig.json"
  "BUNDLER_CONFIG|Bundler config filename|next.config.js"
  "EXT|Source file extension|tsx"
  "TYPE_CHECK_CMD|Command to run static type check|tsc --noEmit"
  "DOMAIN_ENTITY|Primary domain object|order"
  "RESOURCE_TYPE|Secondary resource type|line item"
  "CORE_MECHANIC|Central user action|placing an order"
  "PROGRESSION_UNIT|Measure of user progress|completed orders"
  "SCREEN_DIR|Directory for screen/page files|app/"
  "LOGIC_DIR|Directory for business logic|src/lib/"
  "STORE_DIR|Directory for state management|src/store/"
  "COMPONENTS_DIR|Directory for UI components|src/components/"
  "HOOKS_DIR|Directory for hooks/providers|src/hooks/"
  "CONSTANTS_DIR|Directory for constants|src/constants/"
  "ASSETS_DIR|Directory for static assets|public/"
  "MAIN_SCREEN|Core feature screen name|dashboard"
  "LOWER_CASE_CONVENTION|Lower-case naming convention|camelCase"
  "PASCAL_CASE_CONVENTION|Type/component naming convention|PascalCase"
  "UPPER_SNAKE_CONVENTION|Constant naming convention|UPPER_SNAKE_CASE"
  "SAVE_KEY|Storage key for persisted data|acme_app_data_v1"
  "SAVE_VERSION|Current save format version|1"
  "TARGET_PLATFORMS|Comma-separated deployment targets|web, desktop"
  "PLATFORM_1|Primary target platform|web"
  "PLATFORM_2|Secondary target platform|desktop"
  "COVERAGE_TARGET|Minimum code coverage|80%"
  "BRANCH_TARGET|Minimum branch coverage|80%"
  "STARTUP_METRIC|Max acceptable startup time|2s"
  "TICK_METRIC|Max acceptable update-loop duration|16ms"
  "RENDER_METRIC|Max acceptable render time|16ms"
  "MEMORY_METRIC|Max acceptable memory usage|200MB"
  "MAX_AGE_DAYS|Max days before a task is stale|14"
  "MAX_BLOCKED_DAYS|Max days a task can be blocked|7"
  "CRITICAL_BLOCKED_DAYS|Max days a critical task can be blocked|3"
)

# ---------- Collect values ----------
# Uses parallel arrays for bash 3.2 compatibility (macOS default).

KEYS=()
VALS=()

add_value() {
  KEYS+=("$1")
  VALS+=("$2")
}

if [ "$MODE" = "file" ]; then
  if [ ! -f "$VALUES_FILE" ]; then
    echo "Error: values file $VALUES_FILE not found" >&2
    exit 1
  fi
  while IFS='=' read -r raw_key raw_value || [ -n "$raw_key" ]; do
    # Trim leading/trailing whitespace from key
    key="$(printf '%s' "$raw_key" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    # Skip comments and blank lines
    case "$key" in
      ''|'#'*) continue ;;
    esac
    # Strip optional surrounding quotes from value
    value="$(printf '%s' "${raw_value:-}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^"\(.*\)"$/\1/; s/^'\''\(.*\)'\''$/\1/')"
    add_value "$key" "$value"
  done < "$VALUES_FILE"
  echo "Loaded ${#KEYS[@]} values from $VALUES_FILE"
else
  # Interactive
  PROMPTS=("${ESSENTIALS[@]}")
  if [ "$MODE" = "full" ]; then
    PROMPTS=("${ESSENTIALS[@]}" "${FULL_EXTRAS[@]}")
  fi

  echo
  echo "Template install (version $TEMPLATE_VERSION) — answer each prompt or press Enter to skip."
  echo "You can always re-run with --values template.values to refine."
  echo

  for prompt in "${PROMPTS[@]}"; do
    IFS='|' read -r key desc example <<< "$prompt"
    echo "[$key]"
    echo "  $desc"
    echo "  Example: $example"
    printf "  Value: "
    read -r answer || answer=""
    if [ -n "$answer" ]; then
      add_value "$key" "$answer"
    fi
    echo
  done
fi

# ---------- Copy files ----------

echo "Copying template files to $TARGET ..."

cp "$TEMPLATE_ROOT/root/CLAUDE.md" "$TARGET/CLAUDE.md"

mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/commands"

# Ship the settings.json.example so users have a starting point for Claude Code
# project settings. We never overwrite an existing .claude/settings.json.
if [ -f "$TEMPLATE_ROOT/root/.claude/settings.json.example" ]; then
  cp "$TEMPLATE_ROOT/root/.claude/settings.json.example" "$TARGET/.claude/settings.json.example"
fi
# Copy agent files but NOT agents/README.md — it is the master overview for
# human reference, not a subagent definition.
for agent_file in "$TEMPLATE_ROOT/agents/"*.md; do
  base="$(basename "$agent_file")"
  if [ "$base" = "README.md" ]; then
    continue
  fi
  cp "$agent_file" "$TARGET/.claude/agents/"
done
# Copy command files but NOT commands/README.md — Claude Code would register
# it as a /README slash command, which we don't want.
for cmd_file in "$TEMPLATE_ROOT/commands/"*.md; do
  base="$(basename "$cmd_file")"
  if [ "$base" = "README.md" ]; then
    continue
  fi
  cp "$cmd_file" "$TARGET/.claude/commands/"
done

# Recursive copy of docs and artifacts.
# Use rsync if available for cleaner behavior; fall back to cp -R.
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete-excluded "$TEMPLATE_ROOT/docs/" "$TARGET/docs/"
  rsync -a --delete-excluded "$TEMPLATE_ROOT/artifacts/" "$TARGET/artifacts/"
else
  rm -rf "$TARGET/docs" "$TARGET/artifacts"
  cp -R "$TEMPLATE_ROOT/docs" "$TARGET/docs"
  cp -R "$TEMPLATE_ROOT/artifacts" "$TARGET/artifacts"
fi

mkdir -p "$TARGET/scripts"
cp "$TEMPLATE_ROOT/scripts/check-placeholders.sh" "$TARGET/scripts/"
cp "$TEMPLATE_ROOT/scripts/smoke-test.sh" "$TARGET/scripts/"
chmod +x "$TARGET/scripts/check-placeholders.sh" "$TARGET/scripts/smoke-test.sh"

echo "Files copied."

# ---------- Substitute placeholders ----------

if [ "${#KEYS[@]}" -gt 0 ]; then
  echo "Substituting ${#KEYS[@]} placeholders ..."

  # Collect target files: the copied CLAUDE.md, the .claude tree, docs, artifacts.
  # -print0 + xargs -0 to be safe with spaces.
  FILE_LIST="$(mktemp)"
  trap 'rm -f "$FILE_LIST"' EXIT

  {
    [ -f "$TARGET/CLAUDE.md" ] && echo "$TARGET/CLAUDE.md"
    find "$TARGET/.claude" "$TARGET/docs" "$TARGET/artifacts" -type f -name '*.md' 2>/dev/null
  } > "$FILE_LIST"

  # Detect sed in-place flavor (BSD vs GNU)
  if sed --version >/dev/null 2>&1; then
    SED_INPLACE=(-i)
  else
    SED_INPLACE=(-i '')
  fi

  # Escape a string for use as a sed replacement (right-hand side).
  sed_escape_replacement() {
    printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
  }

  i=0
  while [ "$i" -lt "${#KEYS[@]}" ]; do
    key="${KEYS[$i]}"
    value="${VALS[$i]}"
    escaped="$(sed_escape_replacement "$value")"
    # Replace [KEY] with value across all collected files.
    while IFS= read -r file; do
      [ -z "$file" ] && continue
      sed "${SED_INPLACE[@]}" "s/\[$key\]/$escaped/g" "$file"
    done < "$FILE_LIST"
    i=$((i + 1))
  done

  echo "Substitution complete."
fi

# ---------- Write template.values record ----------

VALUES_OUT="$TARGET/template.values"
{
  echo "# Generated by install.sh on $(date)"
  echo "# Template version: $TEMPLATE_VERSION"
  echo "# Re-run with: scripts/install.sh <target> --values template.values"
  echo ""
  echo "TEMPLATE_VERSION=$TEMPLATE_VERSION"
  i=0
  while [ "$i" -lt "${#KEYS[@]}" ]; do
    echo "${KEYS[$i]}=${VALS[$i]}"
    i=$((i + 1))
  done
} > "$VALUES_OUT"
echo "Saved answers and template version to $VALUES_OUT"

# ---------- Run placeholder check ----------

echo
echo "Scanning $TARGET for remaining placeholders ..."
echo
(cd "$TARGET" && ./scripts/check-placeholders.sh) || true

# ---------- Next steps ----------

echo
echo "Install complete (template version $TEMPLATE_VERSION)."
echo
echo "Next steps:"
echo "  1. Review $TARGET/template.values and adjust if needed."
echo "  2. Fill in any placeholders still flagged above by hand."
echo "  3. Run static verification:  ./scripts/smoke-test.sh $TARGET"
echo "  4. Open $TARGET in Claude Code and walk through docs/FIRST_RUN.md"
echo "     for the interactive verification steps."
echo "  5. Commit the populated template as the first commit of your project."
