<!-- TEMPLATE INSTRUCTIONS
  FILE: docs/CLI.md
  PURPOSE: Topic-specific reference for projects whose primary surface is a command-line
  tool or terminal utility — single-binary tools, multi-subcommand utilities, interactive
  REPLs, and piped filters. Loaded into an AI coding assistant's context at session start
  so patterns, pitfalls, and conventions are available before the first edit.

  WHEN TO KEEP: your project's primary interface is a terminal binary invoked from a
  shell, a script, or a pipe.

  WHEN TO DELETE: if the project is a GUI or web frontend, keep docs/FRONTEND.md instead.
  If it is a long-running service with no terminal surface, keep docs/BACKEND.md instead.

  HOW TO CUSTOMIZE:
  - Replace [PLACEHOLDER] tokens with project-specific values. See README.md for the
    full placeholder reference table.
  - Keep code blocks as illustrative patterns — the bracket-style identifiers
    (e.g., `[dispatchCommand]`, `[ExitCode]`) are intentional.
  - Add project-specific pitfalls to "Common Pitfalls" as they surface in review.
  - Delete this comment block before committing.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — CLI Patterns

Reference material for the command-line surface of [PROJECT_NAME]. This document
covers argument parsing, stream discipline, exit codes, terminal formatting, and
cross-platform behavior. Patterns here apply to any terminal binary regardless of
[LANGUAGE] or [FRAMEWORK]; project-specific commands and flags live in
`artifacts/ui-specs/`.

---

## Scope

"CLI" for [PROJECT_NAME] means any surface invoked from a shell, a script, or a
pipe — single-binary tools, multi-subcommand utilities, interactive REPLs, or
filters that read stdin and write stdout. Everything the user observes is text
on three streams (stdin, stdout, stderr) plus an exit code.

- Projects with a graphical or web UI keep `docs/FRONTEND.md` instead.
- Services that never attach to a terminal keep `docs/BACKEND.md` instead.
- Hybrid projects (a service with an admin CLI) may keep multiple docs.

---

## Argument Parsing and Command Structure

A CLI's argv is its public API. Design it once, document it in
`artifacts/ui-specs/`, and do not change it without a version bump.

**Subcommand pattern.** For anything beyond a handful of flags, dispatch on the
first positional arg:

```
[binaryName] <command> [args...] [flags...]
```

- First positional is the subcommand (`[add]`, `[list]`, `[run]`).
- Positional args that follow are command-specific.
- Flags may appear in any position but the convention is after positionals.
- Unknown subcommand exits non-zero with a pointer to `--help`.

**Flags vs positional args.**

- Positional args for required, order-significant inputs (`<file>`, `<id>`).
- Flags for optional modifiers (`--all`, `--format=json`) and boolean toggles.
- Long flags that are typed often deserve a short form (`-v`). Rare flags get
  long form only.
- `--` terminates flag parsing; everything after is positional. Matters for
  filenames beginning with `-`.

**`--help` and `--version`.** Both exist, both exit 0, both write to stdout
(they are requested output). Bare invocation with no args prints help and
exits 0 — unless the tool is a filter expected to read stdin, in which case
document that explicitly.

**Library vs custom parser.** A custom parser is fine for under ~5 subcommands
and ~10 flags. Beyond that, the edge cases (flag bundling, `--flag=value` vs
`--flag value`, repeated flags, negation) are worth a library's weight. Record
the decision in the Architect's Decisions Log.

```
// Dispatch pattern — illustrative
function [dispatchCommand]([argv]: [StringList]): [ExitCode] {
  const [[sub], ...[rest]] = [argv]
  switch ([sub]) {
    case '[addCmd]':    return [runAdd]([rest])
    case '[listCmd]':   return [runList]([rest])
    case '--help':
    case undefined:     [printUsage](); return 0
    case '--version':   [printVersion](); return 0
    default:
      [writeStderr](`[binaryName]: unknown command: ${[sub]} (try --help)`)
      return 1
  }
}
```

---

## Stdin, Stdout, Stderr

The three streams have distinct jobs. Never mix them.

- **stdout** is for the output the user asked for — data, results, the thing
  a downstream `| grep` or `| jq` will consume. Prefer one record per line.
- **stderr** is for progress, warnings, errors, and usage-on-failure. Anything
  a script using `2>/dev/null` should be able to silence without losing data.
- **stdin** is for piped input. If the command accepts stdin and an explicit
  file arg, document precedence (usually the explicit arg wins, `-` means
  stdin).

**TTY-aware behavior.** When stdout is not a TTY (i.e. it is piped or
redirected), the tool should:

- Disable ANSI color codes.
- Disable spinners and progress bars.
- Never prompt for input.
- Emit the same bytes it would emit in plain mode to a TTY — pipe-determinism
  is the contract.

Check once at startup via the language's `[isatty]` equivalent on file
descriptor 1 and cache the result.

---

## Exit Codes

Exit codes are the machine-readable part of the CLI. Scripts branch on them,
so they are a contract.

| Code | Meaning | When |
|------|---------|------|
| `0` | Success | Operation completed as requested |
| `1` | User error | Bad args, missing input, invalid flag, unknown command |
| `2` | Internal / unknown error | Bug, unexpected I/O failure, unhandled exception |
| `3` | [DOMAIN_NOT_FOUND] | A specific, requested resource does not exist |
| `[N]` | [DOMAIN_SPECIFIC] | Add further codes only when scripts will branch on them |

Rules:

- Every path that returns non-zero must also write a human-readable message to
  stderr prefixed with `[binaryName]: `.
- Document every exit code the tool can return in `artifacts/ui-specs/`.
- Do not introduce new codes casually — each one is a compatibility commitment.
- An uncaught exception must map to exit 2, not a crash with no code. Install a
  top-level handler.

---

## Terminal Output Formatting

Output must be readable in a terminal and parseable in a pipe.

**Columns and alignment.** Fixed-width columns separated by exactly two
spaces. No box-drawing characters. Truncate long cells with a trailing
ellipsis (`...`); store the full value, truncate at display only. Detect
terminal width via `[terminalSize]` only when stdout is a TTY; when piped,
use a deterministic fixed width.

**Color.** Use ANSI color only when all of these hold: stdout is a TTY,
`NO_COLOR` is unset (respect <https://no-color.org>), and the user did not
pass `--no-color` / `--plain`. Centralize the decision in one boolean
computed at startup.

**Progress indicators.** Spinners and bars go to stderr, never stdout, and
only when stderr is a TTY. A tool piped into `less` must not leak spinner
frames.

**Structured output.** A `--json` (or `--format=json`) flag serves machine
consumers. When set: disable color, progress, and prompts; emit a single JSON
document or NDJSON (document which in the spec); errors still go to stderr as
plain text.

---

## Cross-Platform Concerns

Assume the CLI runs on macOS, Linux, and Windows unless the spec says otherwise.

- **Paths.** Build with the language's `[pathJoin]` helper. Never concatenate
  with `/`. Never hardcode `/tmp`, `/var`, `C:\\`, or `\\`.
- **Home directory.** Resolve via the `[homeDir]` helper (`os.homedir()`,
  `dirs::home_dir()`, `pathlib.Path.home()`). Do not read `$HOME` directly —
  it is unset on Windows and spoofable elsewhere.
- **Temp files.** Use the `[tempDir]` helper and clean up on exit.
- **Line endings.** Write `\n`; let the runtime handle CRLF. Never emit
  `\r\n` manually.
- **File permissions.** `chmod` bits are a no-op on Windows. Code that relies
  on `0o600` for secrecy needs a documented fallback (ACLs, parent-directory
  permissions, or a warning).
- **Environment.** `%USERPROFILE%` vs `$HOME`, `%APPDATA%` vs
  `$XDG_CONFIG_HOME` — always go through the language helper.
- **Shell quoting.** Document how spaces and quotes should be passed in
  PowerShell, cmd.exe, and POSIX shells.

---

## Signal Handling and Cancellation

- **SIGINT (Ctrl-C).** Default behavior is fine for most tools: exit promptly.
  Only trap when there is cleanup to do (temp files, open connections, partial
  writes). A trapped handler sets a cancellation flag and returns quickly.
- **SIGTERM.** Treat like SIGINT for cleanup. Long-running commands check the
  flag between units of work.
- **SIGPIPE.** When a pipe's downstream closes (`[binaryName] list | head`),
  the next write raises SIGPIPE. Do not swallow it — exit cleanly. Languages
  that convert it to an exception (Python, some Node cases) need an explicit
  handler that exits 0 or 141.
- **Long operations must be cancellable.** Loops that run longer than a
  second check the cancellation flag each iteration.
- **Never block on stdin** unless the command explicitly reads it. A tool
  that hangs waiting for input is unusable in scripts.

---

## Interactive Prompts

Prompts are convenient for humans and hostile to automation. Every
interactive tool must be scriptable.

- Only prompt when both stdin and stdout are TTYs. Otherwise fail with a
  "non-interactive; use --[flagName]" message on stderr.
- Every prompt has a flag equivalent (`--yes`, `--no-input`,
  `--[answerFlag]=[value]`). Scripts must answer every question in advance.
- Destructive actions (delete, overwrite, force-push) require explicit
  confirmation — a prompt or a `--force` flag. Never default to destructive.
- Never echo secrets. Use `[readPassword]` which disables terminal echo.
- Document the non-interactive equivalent in `--help`.

---

## Common Pitfalls

CLI-specific traps. Universal pitfalls (error swallowing, stringly-typed
boundaries) are in the root `CLAUDE.md`.

- **Colors leaking into pipes.** Hard-coding ANSI escapes without checking
  `isatty(stdout)` breaks every downstream `grep`, `awk`, and `jq`. Centralize
  the color decision.
- **Hardcoded `/tmp` or `~`.** Breaks on Windows and leaks across users on
  shared hosts. Use `[tempDir]` and `[homeDir]`.
- **Not flushing stdout on exit.** Buffered writes are lost when the process
  terminates before flush. Languages with line-buffered stdout on a TTY switch
  to block-buffered when piped — a tool that looks correct interactively
  truncates under `| head`. Flush explicitly before exit.
- **Swallowing SIGPIPE.** A CLI that catches the broken-pipe error and keeps
  running becomes a zombie when its consumer dies. Re-raise or exit.
- **Trusting `$HOME` to be set.** It is not guaranteed, especially in CI,
  cron, systemd units, and Windows. Use `[homeDir]`.
- **Forgetting to return a non-zero exit code on failure.** A `try/catch` that
  prints an error and then falls through returns 0. Scripts think everything
  is fine. Always return or `process.exit` after an error path.
- **Partial writes on crash.** Writing directly to the target file means a
  crash mid-write corrupts it. Write to a sibling temp file and rename
  atomically.
- **Assuming terminal width is 80.** Users with wide terminals get wasted
  space; users with narrow terminals get broken layouts. Detect width at
  runtime when stdout is a TTY; fall back to a fixed width when piped.

---

## Cross-References

- `docs/CODE_PATTERNS.md` — universal [LANGUAGE] conventions, module
  structure, and naming rules. Read first.
- `docs/ERROR_HANDLING.md` — error categories, boundary conventions, and the
  mapping from error classes to user-facing messages and exit codes.
- `docs/FILE_CONVENTIONS.md` — where CLI source lives in the project
  structure.
- `artifacts/ui-specs/` — active, per-milestone CLI UX specifications (command
  surface, exact stdout/stderr strings, exit-code table, edge cases).

---

_Last updated: [YYYY-MM-DD]_
