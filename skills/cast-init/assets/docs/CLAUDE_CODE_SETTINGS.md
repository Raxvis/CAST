<!-- TEMPLATE INSTRUCTIONS
FILE: docs/CLAUDE_CODE_SETTINGS.md
PURPOSE: Reference doc explaining how .claude/settings.json works in a project
that uses this template. Covers the most common configuration patterns and
points at the authoritative Claude Code docs for anything beyond the basics.

HOW TO CUSTOMIZE: no per-project customization needed. This file is pure reference.
Delete only if your project has a policy against per-project Claude Code settings.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# `.claude/settings.json` — Claude Code Project Settings

This file is reference material for configuring Claude Code at the project level. Create a `.claude/settings.json` file in your project root and edit as needed. It is picked up automatically whenever Claude Code starts a session in the project root.

For the authoritative reference, see the Claude Code documentation on project settings. This doc only covers the patterns a project using this template is most likely to want.

---

## What project settings are for

`.claude/settings.json` is a per-project configuration file that Claude Code reads at session start. It is separate from user-level settings (`~/.claude/settings.json`) and takes precedence over user settings for the fields it defines. The scope is one project — everything in this file affects only sessions launched from within the project root.

The most useful things you can put here:

1. **Permission rules** — auto-approve safe shell commands so the session stops prompting on every routine tool call.
2. **Environment variables** — project-local values that Claude Code passes to every Bash tool call.
3. **Hooks** — shell commands that fire on specific events (tool calls, session start, etc.).

Hooks and status lines are genuinely useful but have steeper learning curves and are left as opt-in extensions.

---

## Recommended starting point

A minimal safe starting configuration for `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(ls:*)",
      "Bash(pwd:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(cat:*)"
    ]
  },
  "env": {}
}
```

This auto-approves a short list of read-only shell commands so Claude Code runs them without prompting. These are the commands Claude Code fires most frequently while exploring a codebase, and they have no destructive side effects on any project. Adding them to the allow list dramatically reduces interruption without sacrificing safety.

---

## Common extensions

### Auto-approve test and build commands

If your project has a stable test or build command, auto-approving it is a big productivity win:

```json
{
  "permissions": {
    "allow": [
      "Bash(ls:*)",
      "Bash(git status:*)",
      "Bash(npm test:*)",
      "Bash(npm run build:*)"
    ]
  }
}
```

**Do not auto-approve** destructive or network-touching commands (`git push`, `rm`, `curl`, `npm publish`, `docker build`, anything that writes to a database). The friction of confirming those once in a while is the friction you want — it catches mistakes.

### Deny list

You can block commands instead of allowing them. Useful if you want everything to prompt but specific things to hard-fail:

```json
{
  "permissions": {
    "deny": [
      "Bash(git push:*)",
      "Bash(rm -rf:*)"
    ]
  }
}
```

The `allow` and `deny` lists can be combined: deny rules win if both match.

### Environment variables

Project-local environment variables that Claude Code makes available to every Bash tool call:

```json
{
  "env": {
    "NODE_ENV": "development",
    "ACME_TODO_DB": "/tmp/acme-todo-test.db"
  }
}
```

**Do NOT store secrets in this file.** It is checked into git by default. Secrets belong in `.env.local` (outside git) and are loaded by your application, not by Claude Code.

### Hooks (advanced)

Claude Code supports event hooks — shell commands that run on tool calls, session start, etc. The most commonly useful pattern for projects using this template is a post-tool hook that appends to `artifacts/STANDUP.md` whenever a significant action completes. Hook configuration varies by Claude Code version; consult the official docs before adding hooks, and test on a scratch branch first.

Hooks are NOT in the shipped example. They are a genuine power tool but also a genuine footgun — a malformed hook can break every subsequent tool call until you remove it.

---

## What NOT to configure here

- **Secrets**: API keys, database passwords, auth tokens. Use `.env.local` (gitignored) or your secret manager.
- **User preferences**: theme, keybindings, font size. Those go in user-level `~/.claude/settings.json`.
- **Agent definitions**: those live in `.claude/agents/`, not here.
- **Pipeline skills**: those live in `.claude/skills/`, not here.
- **Template placeholders**: don't put `[PROJECT_NAME]` in settings.json — Claude Code parses it as JSON and will fail on any placeholder that isn't a valid JSON value.

---

## Verifying your settings

After editing `.claude/settings.json`, restart your Claude Code session. The new settings take effect on session start, not mid-session. Confirm by:

1. Running one of the commands in your `allow` list — it should execute without prompting.
2. Running a command NOT in your `allow` list — it should prompt for confirmation.

If a command in the `allow` list still prompts, your pattern probably doesn't match. `Bash(ls:*)` means "any invocation of `ls`"; `Bash(ls)` without the `:*` would only match a literal `ls` with no arguments.

---

_See also: the CAST repo's [`TROUBLESHOOTING.md`](https://github.com/Raxvis/CAST/blob/main/TROUBLESHOOTING.md) for common settings-related failure modes, and the official Claude Code settings documentation for the full field reference._
