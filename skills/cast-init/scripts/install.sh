#!/usr/bin/env bash
# CAST deterministic installer and upgrader.
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
# deterministic copy /cast-init itself invokes, and works standalone.
#
# INSTALL (default): existing files are never overwritten unless --force is given —
# each is skipped and reported, so re-running is safe. A MANIFEST
# (.claude/cast/install-manifest.txt) records the substitution values used and the
# hash of every file as installed.
#
# UPGRADE (--upgrade): re-renders the current payload with the manifest's recorded
# values (flags override) and, per file:
#   unmodified since install (hash matches manifest)  -> overwritten with new version
#   customized by you (hash differs)                  -> kept, reported for /cast-init to merge
#   new in this release                               -> installed
#   in the manifest but gone from the payload         -> removed if unmodified, kept+reported if customized
#   CLAUDE.md CAST section                            -> replaced only if the section is unmodified
# Nothing you wrote is ever overwritten or deleted: the script only replaces or
# removes bytes it itself installed. From v4 on, upgrading is:
#   npx skills update && bash .claude/skills/cast-init/scripts/install.sh --upgrade
#
# Usage:
#   install.sh [--target DIR] [--project-name NAME] [--test-cmd CMD] [--build-cmd CMD]
#              [--max-loop-count N] [--versioning-scheme S] [--no-ui] [--force]
#              [--upgrade] [--dry-run]
#
# Unsupplied values keep their [PLACEHOLDER] tokens on install (the summary lists
# every file still carrying one); on upgrade they default to the manifest's values.
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ASSETS="$SCRIPT_DIR/../assets"
SKILL_MD="$SCRIPT_DIR/../SKILL.md"
MANIFEST_REL=".claude/cast/install-manifest.txt"

TARGET="."
NO_UI="" FORCE=0 DRY=0 UPGRADE=0
export SUB_PROJECT_NAME="" SUB_TEST_CMD="" SUB_BUILD_CMD="" SUB_MAX_LOOP_COUNT="" SUB_VERSIONING_SCHEME=""
ARG_PROJECT_NAME=unset ARG_TEST_CMD=unset ARG_BUILD_CMD=unset ARG_MAX_LOOP=unset ARG_VERS=unset

while [ $# -gt 0 ]; do
  case "$1" in
    --target)            TARGET=$2; shift 2 ;;
    --project-name)      SUB_PROJECT_NAME=$2; ARG_PROJECT_NAME=set; shift 2 ;;
    --test-cmd)          SUB_TEST_CMD=$2; ARG_TEST_CMD=set; shift 2 ;;
    --build-cmd)         SUB_BUILD_CMD=$2; ARG_BUILD_CMD=set; shift 2 ;;
    --max-loop-count)    SUB_MAX_LOOP_COUNT=$2; ARG_MAX_LOOP=set; shift 2 ;;
    --versioning-scheme) SUB_VERSIONING_SCHEME=$2; ARG_VERS=set; shift 2 ;;
    --no-ui)             NO_UI=1; shift ;;
    --force)             FORCE=1; shift ;;
    --upgrade)           UPGRADE=1; shift ;;
    --dry-run)           DRY=1; shift ;;
    -h|--help)           sed -n '2,39p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "install.sh: unknown option: $1" >&2; exit 2 ;;
  esac
done

[ -d "$ASSETS" ] || { echo "install.sh: payload not found at $ASSETS — incomplete cast-init install" >&2; exit 1; }
[ -f "$SKILL_MD" ] || { echo "install.sh: SKILL.md not found beside assets/ — incomplete cast-init install" >&2; exit 1; }

export SUB_CAST_VERSION SUB_DATE
SUB_CAST_VERSION=$(sed -n 's/^  version: "\([0-9][0-9.]*\)"$/\1/p' "$SKILL_MD" | head -1)
[ -n "$SUB_CAST_VERSION" ] || { echo "install.sh: could not read metadata.version from SKILL.md" >&2; exit 1; }
SUB_DATE=$(date +%Y-%m-%d)

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}
hash_stdin() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum | cut -d' ' -f1
  else shasum -a 256 | cut -d' ' -f1; fi
}

cd "$TARGET"
MANIFEST="$MANIFEST_REL"

# --upgrade: load recorded values (flags win); require the manifest.
manifest_value() { sed -n "s/^V $1=//p" "$MANIFEST" | head -1; }
manifest_hash_for() { awk -v p="$2" '$1=="F" && substr($0, index($0,$3)) == p { print $2 }' "$1"; }

if [ "$UPGRADE" -eq 1 ] && [ ! -f "$MANIFEST" ]; then
  echo "install.sh: no $MANIFEST_REL found." >&2
  echo "This install predates the manifest (a pre-v4 or hand-rolled install)." >&2
  echo "Run /cast-init once to upgrade it — that run writes the manifest, and every" >&2
  echo "upgrade after it is just: install.sh --upgrade" >&2
  exit 1
fi
# Any run that finds a manifest inherits its recorded values as defaults (explicit
# flags still win) — a re-run or upgrade without flags must never blank them.
if [ -f "$MANIFEST" ]; then
  [ "$ARG_PROJECT_NAME" = set ] || SUB_PROJECT_NAME=$(manifest_value project_name)
  [ "$ARG_TEST_CMD" = set ]     || SUB_TEST_CMD=$(manifest_value test_cmd)
  [ "$ARG_BUILD_CMD" = set ]    || SUB_BUILD_CMD=$(manifest_value build_cmd)
  [ "$ARG_MAX_LOOP" = set ]     || SUB_MAX_LOOP_COUNT=$(manifest_value max_loop_count)
  [ "$ARG_VERS" = set ]         || SUB_VERSIONING_SCHEME=$(manifest_value versioning_scheme)
  [ -n "$NO_UI" ] || NO_UI=$(manifest_value no_ui)
fi
: "${NO_UI:=0}"
: "${SUB_MAX_LOOP_COUNT:=3}"
: "${SUB_VERSIONING_SCHEME:=semantic versioning}"

installed=0 skipped=0 upgraded=0 kept=0 removed=0
declare -a SKIPPED_FILES=() KEPT_FILES=() NEW_MANIFEST=()

# process < src > dst — strips the TEMPLATE INSTRUCTIONS block and the
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

render_tmp=$(mktemp)
trap 'rm -f "$render_tmp"' EXIT

# put <mode> <src> <dst> — mode: sub (strip+substitute) | verbatim
# Install: write unless dst exists (--force overrides).
# Upgrade: overwrite when dst matches its manifest hash (or is absent); keep otherwise.
put() {
  local mode=$1 src=$2 dst=$3 newhash
  if [ "$mode" = verbatim ]; then cp "$src" "$render_tmp"; else process < "$src" > "$render_tmp"; fi
  newhash=$(hash_file "$render_tmp")
  if [ "$UPGRADE" -eq 1 ]; then
    local rec cur
    rec=$(manifest_hash_for "$MANIFEST" "$dst" || true)
    if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then
      cur=$(hash_file "$dst")
      if [ "$cur" != "${rec:-}" ]; then
        kept=$((kept + 1)); KEPT_FILES+=("$dst")
        # Carry forward the last CAST-written hash (or a sentinel), NEVER the
        # customized hash — recording the customized bytes as "CAST's" would make
        # the next upgrade clobber them.
        NEW_MANIFEST+=("F ${rec:-preexisting} $dst")
        return 0
      fi
      if [ "$cur" = "$newhash" ]; then
        NEW_MANIFEST+=("F $newhash $dst"); return 0   # already current
      fi
    fi
    if [ -e "$dst" ]; then
      [ "$DRY" -eq 1 ] && { echo "would upgrade: $dst"; upgraded=$((upgraded + 1)); NEW_MANIFEST+=("F $newhash $dst"); return 0; }
      mkdir -p "$(dirname "$dst")"; cp "$render_tmp" "$dst"
      upgraded=$((upgraded + 1))
    else
      [ "$DRY" -eq 1 ] && { echo "would add: $dst"; installed=$((installed + 1)); NEW_MANIFEST+=("F $newhash $dst"); return 0; }
      mkdir -p "$(dirname "$dst")"; cp "$render_tmp" "$dst"
      installed=$((installed + 1))
    fi
    NEW_MANIFEST+=("F $newhash $dst"); return 0
  fi
  if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then
    skipped=$((skipped + 1)); SKIPPED_FILES+=("$dst")
    # Carry forward the prior record (the hash CAST wrote) when the manifest has
    # one — a plain re-run must not degrade the upgrade contract. With no prior
    # record, CAST did not write these bytes: a sentinel makes --upgrade treat
    # the file as customized (kept), never as CAST's to replace.
    local prior=""
    [ -f "$MANIFEST" ] && prior=$(manifest_hash_for "$MANIFEST" "$dst" || true)
    NEW_MANIFEST+=("F ${prior:-preexisting} $dst")
    return 0
  fi
  [ "$DRY" -eq 1 ] && { echo "would install: $dst"; installed=$((installed + 1)); return 0; }
  mkdir -p "$(dirname "$dst")"; cp "$render_tmp" "$dst"
  installed=$((installed + 1)); NEW_MANIFEST+=("F $newhash $dst")
}

PAYLOAD_DESTS=""   # newline-separated dest list (bash-3.2 compatible; CAST paths have no newlines)
payload_has() { printf '%s\n' "$PAYLOAD_DESTS" | grep -qFx "$1"; }

# 1) Agents (never the payload README — it would register as a bogus subagent)
for f in "$ASSETS"/agents/*.md; do
  b=$(basename "$f")
  [ "$b" = "README.md" ] && continue
  [ "$NO_UI" = 1 ] && [ "$b" = "ui.md" ] && continue
  PAYLOAD_DESTS="$PAYLOAD_DESTS
.claude/agents/$b"
  put sub "$f" ".claude/agents/$b"
done

# 2) Skills (never the payload README — it is not a skill)
for d in "$ASSETS"/skills/*/; do
  n=$(basename "$d")
  PAYLOAD_DESTS="$PAYLOAD_DESTS
.claude/skills/$n/SKILL.md"
  put sub "$d/SKILL.md" ".claude/skills/$n/SKILL.md"
done

# 3) The .claude/cast/ machinery: contracts + source map (substituted),
#    template skeletons verbatim, templates/README.md as documentation.
for b in SOURCES.md PIPELINE_LOOP.md STAGE_CONTRACT.md; do
  PAYLOAD_DESTS="$PAYLOAD_DESTS
.claude/cast/$b"
  put sub "$ASSETS/cast/$b" ".claude/cast/$b"
done
for f in "$ASSETS"/cast/templates/*.md; do
  b=$(basename "$f")
  if [ "$NO_UI" = 1 ]; then
    case "$b" in UI_SPEC.md|UX_REVIEW.md) continue ;; esac
  fi
  PAYLOAD_DESTS="$PAYLOAD_DESTS
.claude/cast/templates/$b"
  if [ "$b" = "README.md" ]; then put sub "$f" ".claude/cast/templates/$b"
  else put verbatim "$f" ".claude/cast/templates/$b"; fi
done

# 4) Artifacts scaffold
for f in "$ASSETS"/artifacts/*.md; do
  b=$(basename "$f")
  PAYLOAD_DESTS="$PAYLOAD_DESTS
artifacts/$b"
  put sub "$f" "artifacts/$b"
done
[ "$DRY" -eq 1 ] || mkdir -p artifacts/one-off

# 5) Obsolete files (upgrade only): in the old manifest, absent from this payload.
#    Removed only when byte-identical to what CAST installed; customized ones stay.
if [ "$UPGRADE" -eq 1 ]; then
  while IFS= read -r line; do
    case "$line" in F\ *) ;; *) continue ;; esac
    h=${line#F }; h=${h%% *}
    p=${line#F "$h" }
    payload_has "$p" && continue
    [ "$p" = "$MANIFEST_REL" ] && continue
    if [ -e "$p" ]; then
      if [ "$(hash_file "$p")" = "$h" ]; then
        [ "$DRY" -eq 1 ] && echo "would remove (obsolete): $p" || rm "$p"
        removed=$((removed + 1))
      else
        kept=$((kept + 1)); KEPT_FILES+=("$p (obsolete in this release, but customized)")
        NEW_MANIFEST+=("F $h $p")
      fi
    fi
  done < "$MANIFEST"
fi

# 6) CLAUDE.md — append the CAST section on install; on upgrade, replace the section
#    only when it is byte-identical to what CAST wrote (the stamp line included).
extract_section() { awk '/^## CAST Agent Workflow$/{f=1} f{print} f && /^Adopted with CAST v/{exit}' CLAUDE.md; }
section_hash=""
process < "$ASSETS/root/CLAUDE.md" > "$render_tmp"
new_section_hash=$(hash_file "$render_tmp")
if [ "$DRY" -eq 1 ]; then
  if [ -f CLAUDE.md ] && grep -q "Adopted with CAST v" CLAUDE.md; then
    if [ "$UPGRADE" -eq 1 ]; then
      rec=$(sed -n 's/^S \([^ ]*\) CLAUDE.md#cast-section$/\1/p' "$MANIFEST" | head -1)
      cur=$(extract_section | hash_stdin)
      if [ -n "$rec" ] && [ "$cur" = "$rec" ]; then echo "would refresh: CLAUDE.md CAST section (stamp → v$SUB_CAST_VERSION)"
      else echo "would keep: CLAUDE.md CAST section (customized)"; fi
    else
      echo "would keep: CLAUDE.md (already carries a CAST section)"
    fi
  elif [ -f CLAUDE.md ]; then echo "would append: CLAUDE.md CAST section"
  else echo "would create: CLAUDE.md with the CAST section"; fi
fi
if [ "$DRY" -ne 1 ]; then
  if [ -f CLAUDE.md ] && grep -q "Adopted with CAST v" CLAUDE.md; then
    if [ "$UPGRADE" -eq 1 ]; then
      rec=$(sed -n 's/^S \([^ ]*\) CLAUDE.md#cast-section$/\1/p' "$MANIFEST" | head -1)
      cur=$(extract_section | hash_stdin)
      if [ -n "$rec" ] && [ "$cur" = "$rec" ]; then
        awk -v repl="$render_tmp" '
          /^## CAST Agent Workflow$/ { insec=1; while ((getline l < repl) > 0) print l; close(repl); next }
          insec { if (/^Adopted with CAST v/) insec=0; next }
          { print }' CLAUDE.md > CLAUDE.md.cast-new && mv CLAUDE.md.cast-new CLAUDE.md
        echo "CLAUDE.md: CAST section upgraded (stamp now v$SUB_CAST_VERSION)."
        section_hash=$new_section_hash
      else
        echo "CLAUDE.md: CAST section was customized — left untouched (run /cast-init to merge)."
        KEPT_FILES+=("CLAUDE.md (CAST section customized)"); kept=$((kept + 1))
        section_hash=$cur
      fi
    else
      echo "CLAUDE.md already carries a CAST section — left untouched (use --upgrade to refresh it)."
      # Carry the prior record forward; with none, a sentinel — never claim bytes
      # this run did not write as CAST's.
      if [ -f "$MANIFEST" ]; then
        section_hash=$(sed -n 's/^S \([^ ]*\) CLAUDE.md#cast-section$/\1/p' "$MANIFEST" | head -1)
      fi
      : "${section_hash:=preexisting}"
    fi
  elif [ -f CLAUDE.md ]; then
    { printf '\n'; cat "$render_tmp"; } >> CLAUDE.md
    echo "CLAUDE.md: CAST section appended."
    section_hash=$new_section_hash
  else
    if [ -n "$SUB_PROJECT_NAME" ]; then printf '# %s\n\n' "$SUB_PROJECT_NAME" > CLAUDE.md; else printf '# [PROJECT_NAME]\n\n' > CLAUDE.md; fi
    cat "$render_tmp" >> CLAUDE.md
    echo "CLAUDE.md: created with the CAST section (the file is yours to grow)."
    section_hash=$new_section_hash
  fi
fi

# 7) Write the manifest — what makes the NEXT upgrade a pure script run.
if [ "$DRY" -ne 1 ]; then
  {
    echo "# CAST install manifest — written by scripts/install.sh. Do not edit:"
    echo "# --upgrade uses these hashes to tell CAST's unmodified files (safe to replace)"
    echo "# from your customized ones (never touched)."
    echo "V cast_version=$SUB_CAST_VERSION"
    echo "V installed_on=$SUB_DATE"
    echo "V project_name=$SUB_PROJECT_NAME"
    echo "V test_cmd=$SUB_TEST_CMD"
    echo "V build_cmd=$SUB_BUILD_CMD"
    echo "V max_loop_count=$SUB_MAX_LOOP_COUNT"
    echo "V versioning_scheme=$SUB_VERSIONING_SCHEME"
    echo "V no_ui=$NO_UI"
    [ -n "$section_hash" ] && echo "S $section_hash CLAUDE.md#cast-section"
    printf '%s\n' ${NEW_MANIFEST[@]+"${NEW_MANIFEST[@]}"} | LC_ALL=C sort -k3
  } > "$MANIFEST"
fi

# 8) Summary
echo
if [ "$UPGRADE" -eq 1 ]; then
  echo "CAST upgrade to v$SUB_CAST_VERSION: $upgraded file(s) upgraded, $installed added, $removed obsolete removed, $kept kept (customized)."
  if [ "$kept" -gt 0 ]; then
    printf '  kept: %s\n' ${KEPT_FILES[@]+"${KEPT_FILES[@]}"}
    echo "  Customized files are yours — run /cast-init to merge CAST's changes into them."
  fi
else
  echo "CAST v$SUB_CAST_VERSION install: $installed file(s) installed, $skipped skipped (already exist)."
  if [ "$skipped" -gt 0 ]; then
    printf '  skipped: %s\n' ${SKIPPED_FILES[@]+"${SKIPPED_FILES[@]}"}
    echo "  Existing files are never overwritten (re-run with --force to replace, or run /cast-init to merge)."
  fi
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
  if [ "$UPGRADE" -ne 1 ]; then
    echo
    echo "Next: fill in .claude/cast/SOURCES.md — the source map pointing at YOUR docs and"
    echo "standards (or run /cast-init, which interviews you and writes it). Then restart"
    echo "Claude Code so the agents and skills register."
    echo "Future upgrades: npx skills update (or /plugin marketplace update), then re-run"
    echo "this script with --upgrade."
  fi
fi
