#!/usr/bin/env bash
#
# bootstrap.sh
#
# One-line installer for the multi-agent workflow template. Designed to be
# executed via curl-pipe-bash from the canonical repo so new users can adopt
# the template without cloning anything manually first.
#
# Usage — install into the current directory:
#   curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash
#
# Usage — install into a specific directory:
#   curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash -s -- /path/to/project
#
# Usage — non-interactive with a values file already on disk:
#   curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash -s -- /path/to/project --values /path/to/template.values
#
# Override the source repo via environment variable (for forks):
#   TEMPLATE_REPO_URL=https://github.com/myorg/my-fork.git \
#     curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash
#
# What this script does:
#   1. Clones the canonical template repo (or an override) into a temp dir.
#   2. Re-execs the main install.sh against the target project.
#   3. Cleans up the temp clone on exit.
#
# After bootstrap completes, the target project has:
#   - CLAUDE.md populated with your answers
#   - .claude/agents/  (15 subagent definitions)
#   - .claude/commands/ (agent-plan, agent-code, agent-task)
#   - .claude/settings.json.example
#   - docs/ (reference material, templates, topic-specific guides)
#   - artifacts/ (work-artifact scaffold; BUGS.md, STANDUP.md, subdirs)
#   - scripts/check-placeholders.sh, scripts/smoke-test.sh
#   - template.values (your install answers, version-stamped)
#
# This script is bash-only (macOS, Linux, WSL). Windows users without WSL
# should clone the repo and run scripts/install.ps1 directly — the curl-pipe
# pattern does not work from PowerShell.

set -euo pipefail

# ---------- Config ----------

REPO_URL="${TEMPLATE_REPO_URL:-https://github.com/Raxvis/CAST.git}"
REPO_BRANCH="${TEMPLATE_REPO_BRANCH:-main}"

# ---------- Argument parsing ----------
#
# First positional arg is the target directory (default: current directory).
# Everything after is forwarded verbatim to install.sh (e.g. --values, --full,
# --force).

if [ "$#" -ge 1 ]; then
  TARGET="$1"
  shift
else
  TARGET="."
fi

# Resolve target to absolute path; fail fast if it does not exist.
if [ ! -d "$TARGET" ]; then
  echo "Error: target directory does not exist: $TARGET" >&2
  echo "Create the directory first, then re-run bootstrap." >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

# ---------- Prerequisites ----------

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required but not found in PATH." >&2
  echo "Install git (https://git-scm.com/downloads) and re-run." >&2
  exit 1
fi

if ! command -v bash >/dev/null 2>&1; then
  echo "Error: bash is required but not found in PATH." >&2
  exit 1
fi

# ---------- Header ----------

echo
echo "==> Multi-agent workflow template bootstrap"
echo "    target:   $TARGET"
echo "    source:   $REPO_URL"
echo "    branch:   $REPO_BRANCH"
echo

# ---------- Clone template to temp ----------

TEMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'agent-tpl')"
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

echo "==> Downloading template..."
if ! git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR/template" >/dev/null 2>&1; then
  echo "Error: failed to clone $REPO_URL (branch: $REPO_BRANCH)" >&2
  echo "Check that the repo is public, the branch exists, and you have network access." >&2
  exit 1
fi

# ---------- Verify install.sh is present ----------

if [ ! -x "$TEMP_DIR/template/scripts/install.sh" ]; then
  echo "Error: install.sh not found or not executable in the cloned repo." >&2
  echo "Expected at: $TEMP_DIR/template/scripts/install.sh" >&2
  exit 1
fi

# ---------- Run the main installer ----------
#
# Redirect stdin from /dev/tty so the installer can still prompt interactively
# even though we were invoked via a curl pipe (which would otherwise leave
# stdin attached to the download). If there is no controlling terminal
# (scripting environment), /dev/tty will not exist and the installer should
# be invoked with --values FILE to run non-interactively.

echo "==> Running installer..."
echo

# Detect whether /dev/tty is actually openable (not just present on the
# filesystem). Headless environments such as CI, ssh without -t, or non-login
# shells have /dev/tty as a character device but opening it fails with
# "Device not configured" or similar. The subshell-redirect test below is
# the only reliable probe across BSD, GNU, and busybox userlands.
if (: </dev/tty) >/dev/null 2>&1; then
  "$TEMP_DIR/template/scripts/install.sh" "$TARGET" "$@" </dev/tty
else
  # Check whether the user already passed --values, which makes prompts
  # unnecessary. If they did, pass through without /dev/tty and let the
  # installer run non-interactively.
  NEEDS_PROMPT=1
  for arg in "$@"; do
    if [ "$arg" = "--values" ]; then
      NEEDS_PROMPT=0
      break
    fi
  done

  if [ "$NEEDS_PROMPT" -eq 1 ]; then
    echo "Error: no controlling terminal available and --values was not passed." >&2
    echo "       In a headless environment, the bootstrap installer needs a values" >&2
    echo "       file. Either run this script from an interactive shell, or pass" >&2
    echo "       --values FILE on the command line:" >&2
    echo "" >&2
    echo "         curl -fsSL <url> | bash -s -- /path/to/project --values values.txt" >&2
    exit 1
  fi

  "$TEMP_DIR/template/scripts/install.sh" "$TARGET" "$@"
fi

# ---------- Done ----------

echo
echo "==> Bootstrap complete. See output above for next steps."
