#!/usr/bin/env bash
#
# smoke-test.sh
#
# Static verification for a populated multi-agent workflow template install.
# Runs a series of checks on a target project directory and reports pass/fail
# for each. Exit code 0 if all checks pass, 1 if any fail.
#
# Usage:
#   ./scripts/smoke-test.sh <target-project-dir>
#
# This script is NOT a substitute for opening Claude Code and running the
# commands interactively. It checks the filesystem shape, YAML frontmatter,
# and metadata files. For the interactive verification (does /agents list
# the subagents, does /agent-plan actually run), see docs/FIRST_RUN.md.

set -u

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

pass() { printf '  [PASS] %s\n' "$1"; PASS_COUNT=$((PASS_COUNT + 1)); }
fail() { printf '  [FAIL] %s\n' "$1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
warn() { printf '  [WARN] %s\n' "$1"; WARN_COUNT=$((WARN_COUNT + 1)); }

# ---------- CLI ----------

usage() {
  cat >&2 <<'EOF'
Usage: smoke-test.sh <target-project-dir>

Runs static verification on a populated template install. Exit code 0 if
all checks pass, 1 if any fail.
EOF
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

case "$1" in
  -h|--help)
    usage
    exit 0
    ;;
esac

TARGET="$1"

if [ ! -d "$TARGET" ]; then
  echo "Error: $TARGET is not a directory" >&2
  exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"

echo "Smoke testing: $TARGET"
echo

# ---------- Section 1: top-level layout ----------

echo "Layout:"
if [ -f "$TARGET/CLAUDE.md" ]; then pass "CLAUDE.md at project root"; else fail "CLAUDE.md missing at project root"; fi
if [ -d "$TARGET/docs" ]; then pass "docs/ directory present"; else fail "docs/ directory missing"; fi
if [ -d "$TARGET/artifacts" ]; then pass "artifacts/ directory present"; else fail "artifacts/ directory missing"; fi
if [ -d "$TARGET/.claude" ]; then pass ".claude/ directory present"; else fail ".claude/ directory missing"; fi
if [ -d "$TARGET/.claude/agents" ]; then pass ".claude/agents/ directory present"; else fail ".claude/agents/ directory missing"; fi
if [ -d "$TARGET/.claude/commands" ]; then pass ".claude/commands/ directory present"; else fail ".claude/commands/ directory missing"; fi

echo

# ---------- Section 2: agents ----------

echo "Agents:"
if [ -d "$TARGET/.claude/agents" ]; then
  AGENT_COUNT=0
  BAD_NAME=0
  BAD_DESC=0
  BAD_MODEL=0

  for f in "$TARGET/.claude/agents"/*.md; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    if [ "$base" = "README.md" ]; then
      continue
    fi
    AGENT_COUNT=$((AGENT_COUNT + 1))
    if ! head -10 "$f" | grep -q '^name:'; then
      BAD_NAME=$((BAD_NAME + 1))
    fi
    if ! head -10 "$f" | grep -q '^description:'; then
      BAD_DESC=$((BAD_DESC + 1))
    fi
    if ! head -10 "$f" | grep -q '^model:'; then
      BAD_MODEL=$((BAD_MODEL + 1))
    fi
  done

  if [ "$AGENT_COUNT" -ge 4 ]; then
    pass "at least 4 agent files present (Tier 1 minimum) — found $AGENT_COUNT"
  else
    fail "not enough agent files — found $AGENT_COUNT, need at least 4 for Tier 1"
  fi

  if [ "$BAD_NAME" -eq 0 ]; then
    pass "every agent file has a 'name:' frontmatter key"
  else
    fail "$BAD_NAME agent files missing 'name:' frontmatter key"
  fi

  if [ "$BAD_DESC" -eq 0 ]; then
    pass "every agent file has a 'description:' frontmatter key"
  else
    fail "$BAD_DESC agent files missing 'description:' frontmatter key"
  fi

  if [ "$BAD_MODEL" -eq 0 ]; then
    pass "every agent file has a 'model:' frontmatter key"
  else
    fail "$BAD_MODEL agent files missing 'model:' frontmatter key"
  fi
else
  fail "cannot inspect agents — directory missing"
fi

echo

# ---------- Section 3: commands ----------

echo "Commands:"
if [ -d "$TARGET/.claude/commands" ]; then
  CMD_ANY=0
  if [ -f "$TARGET/.claude/commands/agent-plan.md" ]; then
    pass "/agent-plan command present"
    CMD_ANY=1
  else
    fail "/agent-plan command missing"
  fi
  if [ -f "$TARGET/.claude/commands/agent-code.md" ]; then
    pass "/agent-code command present"
    CMD_ANY=1
  else
    fail "/agent-code command missing"
  fi
  if [ -f "$TARGET/.claude/commands/agent-task.md" ]; then
    pass "/agent-task command present"
    CMD_ANY=1
  else
    fail "/agent-task command missing"
  fi
  if [ "$CMD_ANY" -eq 0 ]; then
    fail "no slash commands present — at least one of agent-plan/agent-code/agent-task is required"
  fi
else
  fail "cannot inspect commands — directory missing"
fi

echo

# ---------- Section 4: artifacts scaffold ----------

echo "Artifacts scaffold:"
if [ -d "$TARGET/artifacts" ]; then
  if [ -d "$TARGET/artifacts/milestones" ]; then pass "artifacts/milestones/"; else fail "artifacts/milestones/ missing"; fi
  if [ -d "$TARGET/artifacts/architecture" ]; then pass "artifacts/architecture/"; else fail "artifacts/architecture/ missing"; fi
  if [ -d "$TARGET/artifacts/ui-specs" ]; then pass "artifacts/ui-specs/"; else fail "artifacts/ui-specs/ missing"; fi
  if [ -d "$TARGET/artifacts/reviews" ]; then pass "artifacts/reviews/"; else fail "artifacts/reviews/ missing"; fi
  if [ -f "$TARGET/artifacts/BUGS.md" ]; then pass "artifacts/BUGS.md"; else fail "artifacts/BUGS.md missing"; fi
  if [ -f "$TARGET/artifacts/STANDUP.md" ]; then pass "artifacts/STANDUP.md"; else fail "artifacts/STANDUP.md missing"; fi
else
  fail "cannot inspect artifacts scaffold — directory missing"
fi

echo

# ---------- Section 5: template metadata ----------

echo "Template metadata:"
if [ -f "$TARGET/template.values" ]; then
  pass "template.values exists"
  VERSION_LINE="$(grep '^TEMPLATE_VERSION=' "$TARGET/template.values" 2>/dev/null | head -1)"
  if [ -n "$VERSION_LINE" ]; then
    VERSION="${VERSION_LINE#TEMPLATE_VERSION=}"
    pass "TEMPLATE_VERSION stamped: $VERSION"
  else
    fail "TEMPLATE_VERSION missing from template.values"
  fi
else
  fail "template.values missing (was the install script used?)"
fi

echo

# ---------- Section 6: stale path references ----------

echo "Path hygiene:"
SEARCH_ROOTS=""
for d in "$TARGET/.claude" "$TARGET/docs" "$TARGET/artifacts"; do
  if [ -d "$d" ]; then
    SEARCH_ROOTS="$SEARCH_ROOTS $d"
  fi
done
if [ -f "$TARGET/CLAUDE.md" ]; then
  SEARCH_ROOTS="$SEARCH_ROOTS $TARGET/CLAUDE.md"
fi

if [ -n "$SEARCH_ROOTS" ]; then
  STALE="$(grep -rln 'features/' $SEARCH_ROOTS 2>/dev/null | grep -v '/\.git/' | head -5)"
  if [ -z "$STALE" ]; then
    pass "no stale 'features/' path references"
  else
    fail "stale 'features/' references found in:"
    printf '%s\n' "$STALE" | sed 's/^/      /'
  fi
else
  fail "nothing to grep — project layout is broken"
fi

echo

# ---------- Section 7: placeholder scan ----------

echo "Placeholders:"
CHECK_SCRIPT="$TARGET/scripts/check-placeholders.sh"
if [ -x "$CHECK_SCRIPT" ]; then
  TMP_OUT="$(mktemp)"
  # Run check-placeholders.sh from the target directory (it scans cwd).
  (cd "$TARGET" && ./scripts/check-placeholders.sh > "$TMP_OUT" 2>&1) || true
  if grep -q '^PASS:' "$TMP_OUT"; then
    pass "check-placeholders.sh reports clean"
  else
    # Unresolved placeholders are a warning, not a fail: an Essentials-only
    # install legitimately leaves the Full-tier placeholders in place, and
    # nested sub-template placeholders (like [DATE] in bug-report forms) are
    # never substituted at install time.
    REMAINING_LINE="$(grep -E '^Total: [0-9]+ lines' "$TMP_OUT" | head -1)"
    if [ -n "$REMAINING_LINE" ]; then
      warn "check-placeholders.sh reports unresolved placeholders — $REMAINING_LINE"
    else
      warn "check-placeholders.sh reports unresolved placeholders (detail above)"
    fi
    echo "      Run './scripts/check-placeholders.sh' in the target and review each match."
    echo "      This is normal if you used Essentials mode or if sub-template placeholders"
    echo "      like [DATE] remain in BUGS.md / STANDUP.md forms."
  fi
  rm -f "$TMP_OUT"
else
  fail "scripts/check-placeholders.sh missing or not executable"
fi

echo

# ---------- Summary ----------

TOTAL=$((PASS_COUNT + FAIL_COUNT + WARN_COUNT))
echo "Summary: $PASS_COUNT passed, $FAIL_COUNT failed, $WARN_COUNT warnings ($TOTAL checks total)"
if [ "$FAIL_COUNT" -eq 0 ]; then
  if [ "$WARN_COUNT" -eq 0 ]; then
    echo "PASS: install looks good."
  else
    echo "PASS with warnings: install is functional but has $WARN_COUNT soft issue(s) to review."
  fi
  echo
  echo "Next: run the interactive checks in docs/FIRST_RUN.md to verify that Claude Code"
  echo "can actually load the agents and execute /agent-plan. Static checks can't cover"
  echo "what only a real session can verify."
  exit 0
else
  echo "FAIL: $FAIL_COUNT check(s) failed. Fix the issues above and re-run."
  echo
  echo "Common causes:"
  echo "  - You forgot to run the install script (try: ./scripts/install.sh <target>)"
  echo "  - You copied files manually and missed one of agents/, commands/, or artifacts/"
  echo "  - You upgraded from a pre-0.3.0 template and did not rename features/ to artifacts/"
  echo "  - See TROUBLESHOOTING.md for symptom-based diagnostics."
  exit 1
fi
