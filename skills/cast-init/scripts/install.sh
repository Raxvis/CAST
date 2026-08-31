#!/usr/bin/env bash
# CAST deterministic installer.
#
# Copies the CAST payload into a target project with fixed, scriptable placement:
#
#   assets/agents/*.md        -> .claude/agents/            (except README.md)
#   assets/skills/*/SKILL.md  -> .claude/skills/<name>/     (except skills/README.md)
#   assets/cast/**            -> .claude/cast/              (templates verbatim)
#   assets/artifacts/*.md     -> artifacts/                 (+ artifacts/one-off/)
#   assets/root/CLAUDE.md     -> appended to CLAUDE.md      (created if absent)
#
# No LLM decides placement — every file has exactly one destination. The parts that
# genuinely need judgment (the source-map interview, migrating a pre-v4 install,
# merging customized files) stay with /cast-init; this script performs the
# deterministic copy /cast-init itself invokes, and works standalone for a fresh
# install: fill in .claude/cast/SOURCES.md by hand afterwards (or run /cast-init,
# which detects the install and only conducts the interview).
#
# Existing files are never overwritten unless --force is given: each is skipped and
# reported, so re-running is safe and an upgrade of customized files stays a
# /cast-init job.
#
# Usage:
#   install.sh [--target DIR] [--project-name NAME] [--test-cmd CMD] [--build-cmd CMD]
#              [--max-loop-count N] [--versioning-scheme S] [--no-ui] [--force]
#              [--dry-run]
#
# Unsupplied values keep their [PLACEHOLDER] tokens; the summary lists every file
# still carrying one so you can fill them by hand.
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ASSETS="$SCRIPT_DIR/../assets"
SKILL_MD="$SCRIPT_DIR/../SKILL.md"

TARGET="."
NO_UI=0
FORCE=0
DRY=0
export SUB_PROJECT_NAME="" SUB_TEST_CMD="" SUB_BUILD_CMD="" SUB_MAX_LOOP_COUNT="" SUB_VERSIONING_SCHEME=""

while [ $# -gt 0 ]; do
  case "$1" in
    --target)            TARGET=$2; shift 2 ;;
    --project-name)      SUB_PROJECT_NAME=$2; shift 2 ;;
    --test-cmd)          SUB_TEST_CMD=$2; shift 2 ;;
    --build-cmd)         SUB_BUILD_CMD=$2; shift 2 ;;
    --max-loop-count)    SUB_MAX_LOOP_COUNT=$2; shift 2 ;;
    --versioning-scheme) SUB_VERSIONING_SCHEME=$2; shift 2 ;;
    --no-ui)             NO_UI=1; shift ;;
    --force)             FORCE=1; shift ;;
    --dry-run)           DRY=1; shift ;;
    -h|--help)           sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "install.sh: unknown option: $1" >&2; exit 2 ;;
  esac
done

[ -d "$ASSETS" ] || { echo "install.sh: payload not found at $ASSETS — incomplete cast-init install" >&2; exit 1; }
[ -f "$SKILL_MD" ] || { echo "install.sh: SKILL.md not found beside assets/ — incomplete cast-init install" >&2; exit 1; }

# Defaults for tokens that have safe ones; the rest stay as tokens when unset.
: "${SUB_MAX_LOOP_COUNT:=3}"
: "${SUB_VERSIONING_SCHEME:=semantic versioning}"
export SUB_CAST_VERSION SUB_DATE
SUB_CAST_VERSION=$(sed -n 's/^  version: "\([0-9][0-9.]*\)"$/\1/p' "$SKILL_MD" | head -1)
[ -n "$SUB_CAST_VERSION" ] || { echo "install.sh: could not read metadata.version from SKILL.md" >&2; exit 1; }
SUB_DATE=$(date +%Y-%m-%d)

installed=0 skipped=0
declare -a SKIPPED_FILES=()

# process < src > dst — strips the leading TEMPLATE INSTRUCTIONS block and the
# placeholder-pointer comment, then substitutes every provided token literally.
process() {
  awk '
    function lit(s, tok, val,   out, i) {
      out = ""
      while ((i = index(s, tok)) > 0) { out = out substr(s, 1, i-1) val; s = substr(s, i + length(tok)) }
      return out s
    }
    BEGIN { in_block = 0 }
    {
      line = $0
      if (!in_block && line ~ /^<!-- TEMPLATE INSTRUCTIONS/) { in_block = 1; next }
      if (in_block) { if (line ~ /-->[[:space:]]*$/) { in_block = 0; strip_blank = 1 }; next }
      if (line ~ /^<!-- Placeholders — see README\.md → Placeholder Reference -->$/) { strip_blank = 1; next }
      if (strip_blank && line == "") { strip_blank = 0; next }
      strip_blank = 0
      if (ENVIRON["SUB_PROJECT_NAME"]      != "") line = lit(line, "[PROJECT_NAME]",      ENVIRON["SUB_PROJECT_NAME"])
      if (ENVIRON["SUB_TEST_CMD"]          != "") line = lit(line, "[TEST_CMD]",          ENVIRON["SUB_TEST_CMD"])
      if (ENVIRON["SUB_BUILD_CMD"]         != "") line = lit(line, "[BUILD_CMD]",         ENVIRON["SUB_BUILD_CMD"])
      if (ENVIRON["SUB_MAX_LOOP_COUNT"]    != "") line = lit(line, "[MAX_LOOP_COUNT]",    ENVIRON["SUB_MAX_LOOP_COUNT"])
      if (ENVIRON["SUB_VERSIONING_SCHEME"] != "") line = lit(line, "[VERSIONING_SCHEME]", ENVIRON["SUB_VERSIONING_SCHEME"])
      line = lit(line, "[CAST_VERSION]", ENVIRON["SUB_CAST_VERSION"])
      line = lit(line, "[YYYY-MM-DD]",   ENVIRON["SUB_DATE"])
      print line
    }
  '
}

# put <mode> <src> <dst>  — mode: sub (strip+substitute) | verbatim
put() {
  local mode=$1 src=$2 dst=$3
  if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then
    skipped=$((skipped + 1)); SKIPPED_FILES+=("$dst"); return 0
  fi
  [ "$DRY" -eq 1 ] && { echo "would install: $dst"; installed=$((installed + 1)); return 0; }
  mkdir -p "$(dirname "$dst")"
  if [ "$mode" = verbatim ]; then
    cp "$src" "$dst"
  else
    process < "$src" > "$dst"
  fi
  installed=$((installed + 1))
}

cd "$TARGET"

# 1) Agents (never the payload README — it would register as a bogus subagent)
for f in "$ASSETS"/agents/*.md; do
  b=$(basename "$f")
  [ "$b" = "README.md" ] && continue
  [ "$NO_UI" -eq 1 ] && [ "$b" = "ui.md" ] && continue
  put sub "$f" ".claude/agents/$b"
done

# 2) Skills (never the payload README — it is not a skill)
for d in "$ASSETS"/skills/*/; do
  n=$(basename "$d")
  put sub "$d/SKILL.md" ".claude/skills/$n/SKILL.md"
done

# 3) The .claude/cast/ machinery: contracts + source map (substituted),
#    template skeletons verbatim (their comment blocks instruct the agents),
#    templates/README.md as documentation (substituted).
put sub "$ASSETS/cast/SOURCES.md"       ".claude/cast/SOURCES.md"
put sub "$ASSETS/cast/PIPELINE_LOOP.md" ".claude/cast/PIPELINE_LOOP.md"
put sub "$ASSETS/cast/STAGE_CONTRACT.md" ".claude/cast/STAGE_CONTRACT.md"
for f in "$ASSETS"/cast/templates/*.md; do
  b=$(basename "$f")
  if [ "$NO_UI" -eq 1 ]; then
    case "$b" in UI_SPEC.md|UX_REVIEW.md) continue ;; esac
  fi
  if [ "$b" = "README.md" ]; then
    put sub "$f" ".claude/cast/templates/$b"
  else
    put verbatim "$f" ".claude/cast/templates/$b"
  fi
done

# 4) Artifacts scaffold
for f in "$ASSETS"/artifacts/*.md; do
  put sub "$f" "artifacts/$(basename "$f")"
done
[ "$DRY" -eq 1 ] || mkdir -p artifacts/one-off

# 5) CLAUDE.md — append the CAST section, never touch user content.
if [ "$DRY" -ne 1 ]; then
  if [ -f CLAUDE.md ]; then
    if grep -q "Adopted with CAST v" CLAUDE.md; then
      echo "CLAUDE.md already carries a CAST section — left untouched (upgrades are /cast-init's job)."
    else
      { printf '\n'; process < "$ASSETS/root/CLAUDE.md"; } >> CLAUDE.md
      echo "CLAUDE.md: CAST section appended."
    fi
  else
    if [ -n "$SUB_PROJECT_NAME" ]; then printf '# %s\n\n' "$SUB_PROJECT_NAME" > CLAUDE.md; else printf '# [PROJECT_NAME]\n\n' > CLAUDE.md; fi
    process < "$ASSETS/root/CLAUDE.md" >> CLAUDE.md
    echo "CLAUDE.md: created with the CAST section (the file is yours to grow)."
  fi
fi

# 6) Summary
echo
echo "CAST v$SUB_CAST_VERSION install: $installed file(s) installed, $skipped skipped (already exist)."
if [ "$skipped" -gt 0 ]; then
  printf '  skipped: %s\n' "${SKIPPED_FILES[@]}"
  echo "  Existing files are never overwritten (re-run with --force to replace, or run /cast-init to merge)."
fi
if [ "$DRY" -ne 1 ]; then
  remaining=$(grep -rlE '\[(PROJECT_NAME|TEST_CMD|BUILD_CMD|MAX_LOOP_COUNT|VERSIONING_SCHEME)\]' \
    .claude/agents .claude/skills .claude/cast/SOURCES.md .claude/cast/PIPELINE_LOOP.md .claude/cast/STAGE_CONTRACT.md artifacts CLAUDE.md 2>/dev/null \
    | grep -v '^.claude/skills/cast-init' || true)
  if [ -n "$remaining" ]; then
    echo "  Unfilled install-time tokens remain in:"
    echo "$remaining" | sed 's/^/    /'
    echo "  Fill them by hand or re-run with the matching --flags."
  fi
  echo
  echo "Next: fill in .claude/cast/SOURCES.md — the source map pointing at YOUR docs and"
  echo "standards (or run /cast-init, which interviews you and writes it). Then restart"
  echo "Claude Code so the agents and skills register."
fi
