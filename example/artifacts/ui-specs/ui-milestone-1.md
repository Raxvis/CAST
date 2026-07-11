# Acme Todo — UI Spec: Milestone 1 CLI Surface

## Revision History

| Rev | Date | Agent | Change |
|-----|------|-------|--------|
| v1 | 2026-04-08 | ui | Initial UI spec |

---

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Author** | UI agent (claude-opus-4-8) |
| **Date** | 2026-04-08 |
| **Status** | Approved |
| **Implements** | M1 — `task-crud` (tasks T-2, T-3, T-4, T-5) |

---

## Overview

Acme Todo is a CLI tool with no visual UI. This spec defines the user-facing text surface: argv shapes, stdout formats, error messages, exit codes, and cross-platform behavior. Everything in this document is observable via a terminal or a pipe.

**Related documents:** All commands read/write data through `src/db/connection.ts` (see `arch-milestone-1.md`). The underlying `Task` shape is defined in `src/types/task.ts`.

---

## Command Surface

Binary name: `acme-todo`.

| Command | argv pattern | Description |
|---------|-------------|-------------|
| `add` | `acme-todo add <title...>` | Create a pending task. All positional args after `add` are joined with a single space to form the title. |
| `list` | `acme-todo list [--all]` | List pending tasks. `--all` includes completed tasks. |
| `done` | `acme-todo done <id>` | Mark task `<id>` as done and stamp `completedAt`. |
| `delete` | `acme-todo delete <id>` | Permanently delete task `<id>`. |
| `--help` | `acme-todo --help` (also `-h`, or bare `acme-todo`) | Print the help screen and exit 0. |

Arguments are case-sensitive. The command name is always the first positional arg. Unknown commands exit 1 with a "unknown command" error.

---

## Layout Diagram

For a CLI, the "layout" is the anatomy of a rendered `list` screen. Every labeled element below is specified precisely in Output Formats.

```
┌────────────────────────────────────────────────────────────┐
│ $ acme-todo list --all                    ← invocation     │
│ ID  TITLE                    STATUS   CREATED               │
│ ▲   ▲                        ▲        ▲                     │
│ │   │                        │        └ CREATED col (10)    │
│ │   │                        └ STATUS col (8)               │
│ │   └ TITLE col (40, ellipsis truncation)                   │
│ └ ID col (4)                                                │
│ 7   buy milk                 done     2026-04-08            │
│ 8   renew passport           pending  2026-04-08            │
│      ↑ columns separated by exactly two spaces              │
└────────────────────────────────────────────────────────────┘
```

Single-line outputs (`add`, `done`, `delete`) have no columnar layout; their exact strings are in Output Formats. Errors never appear in this stdout layout — they go to stderr (see Error Messages and Exit Codes).

---

## Output Formats

### `add` success

```
$ acme-todo add buy milk
Added task #7: buy milk
```

The id shown is the SQLite autoincrement value of the new row. Trailing whitespace in the title is trimmed; interior whitespace is preserved.

### `list` (pending only — default)

```
$ acme-todo list
ID  TITLE                                     STATUS   CREATED
7   buy milk                                  pending  2026-04-08
8   renew passport                            pending  2026-04-08
```

Column layout:

| Column | Width | Alignment | Notes |
|--------|-------|-----------|-------|
| `ID` | 4 | left | Padded with spaces; overflow pushes the row right (no truncation) |
| `TITLE` | 40 | left | Truncated to 40 chars with a trailing ellipsis (`...`) if longer |
| `STATUS` | 8 | left | Literal strings `pending` or `done` |
| `CREATED` | 10 | left | `YYYY-MM-DD` portion of `createdAt` |

Columns are separated by exactly two spaces. No vertical bars or box-drawing characters. When no rows match, only the header is printed — no "No tasks" message, so the output stays pipe-friendly.

### `list --all` (includes completed)

```
$ acme-todo list --all
ID  TITLE                                     STATUS   CREATED
7   buy milk                                  done     2026-04-08
8   renew passport                            pending  2026-04-08
9   a very long title that will be truncat... pending  2026-04-08
```

Row 7 shows the `done` status literal. Row 9 demonstrates the 40-char truncation with ellipsis.

### `done` success

```
$ acme-todo done 7
Marked task #7 as done.
```

Idempotent on already-done tasks: re-running prints the same message and exits 0. (`completedAt` is not overwritten if already set.)

### `delete` success

```
$ acme-todo delete 7
Deleted task #7.
```

### `--help`

```
$ acme-todo --help
acme-todo — a minimal command-line todo tracker

USAGE
  acme-todo <command> [args]

COMMANDS
  add <title...>    Create a new pending task
  list [--all]      List pending tasks (use --all to include completed)
  done <id>         Mark task <id> as done
  delete <id>       Delete task <id>

OPTIONS
  -h, --help        Show this help and exit

STORAGE
  Default database: ~/.acme-todo/tasks.db
  Override:         set ACME_TODO_DB to an absolute file path
```

`acme-todo` with no args prints the same screen and exits 0.

---

## States

The GUI state vocabulary maps onto per-invocation outcomes for a CLI. Every command resolves to exactly one of these states per run:

| State | Description | Visible Result |
|-------|-------------|----------------|
| Default (success) | Command completed its effect | Success string on stdout (see Output Formats), exit 0 |
| Empty | `list` matched zero rows | Header line only, no rows, exit 0 — deliberately no "No tasks" string, so output stays pipe-friendly |
| Loading / First-run | DB file absent on invocation | Migrations run transparently, then the command proceeds as Default or Empty (CEO Condition 3); no user-visible "loading" output |
| Error (user) | Bad arguments or unknown command | `acme-todo: `-prefixed message on stderr, exit 1 |
| Error (not found) | `done`/`delete` on a missing id | `acme-todo: task <id> not found` on stderr, exit 3 |
| Error (internal) | I/O or database failure | `acme-todo: database error: ...` on stderr, exit 2 |
| Idempotent repeat | `done` on an already-done task | Same success string, exit 0, `completedAt` untouched |

There are no Pressed/Disabled states — a CLI has no persistent interactive surface in v1 (no prompts, no TTY-dependent behavior).

---

## Error Messages and Exit Codes

All error output is written to **stderr**, prefixed with `acme-todo: `. stdout is never used for errors, so `command 2>/dev/null` silences them cleanly.

| Exit code | Meaning | Example stderr |
|-----------|---------|----------------|
| `0` | Success | — |
| `1` | User error | see rows below |
| `2` | Unknown / internal error | `acme-todo: database error: disk I/O error` |
| `3` | Task not found | `acme-todo: task 42 not found` |

Concrete user-error messages (exit 1):

| Condition | stderr |
|-----------|--------|
| `add` with no title | `acme-todo: add: missing required argument <title>` |
| `done` / `delete` with no id | `acme-todo: done: missing required argument <id>` |
| Non-numeric id | `acme-todo: done: expected numeric id, got "abc"` |
| Unknown command | `acme-todo: unknown command: foo (try --help)` |
| Unknown flag on `list` | `acme-todo: list: unknown option --verbose` |

Internal errors (exit 2) include a short prefix and the underlying message:

```
acme-todo: database error: unable to open database file
```

Task-not-found (exit 3) distinguishes "you asked for a specific row that does not exist" from other user errors, so scripts can react programmatically:

```
acme-todo: task 42 not found
```

---

## Visual Style

**v1 ships plain text — no ANSI escape codes, anywhere.**

Rationale: keeps output universally pipe-safe, avoids Windows legacy-console edge cases, and punts a color-scheme decision to a later milestone. Deferring color is explicit, not an oversight.

| Property | Value | Theme Key |
|----------|-------|-----------|
| Color | None — plain text only | — (no theme file in v1) |
| Typeface | Whatever monospace font the user's terminal renders | — |
| Table borders | None (ASCII columns, two-space separator) | — |
| Emphasis / bold | None | — |

Formatting rules:

- Column separator: exactly two spaces
- Title column: hard-truncated to 40 visible characters, ellipsis (`...`) replaces the last 3 when truncated
- No trailing whitespace on any line
- Every line ends with `\n` (Node's `console.log` handles the platform newline on write)
- No Unicode box-drawing characters in tables (only ASCII)

---

## Data Requirements

### Reads

| Data | Source | Format | Notes |
|------|--------|--------|-------|
| Open tasks (`completed = 0`) | `tasks` table via `src/db/connection.ts` | `Task[]` | Default `list` query; uses `idx_tasks_completed` |
| All tasks | `tasks` table | `Task[]` | `list --all`; no filter |
| `createdAt` per row | `tasks.createdAt` | ISO 8601 string | Rendered as the `YYYY-MM-DD` prefix in the CREATED column |
| DB path override | `ACME_TODO_DB` env var | absolute path string | Falls back to `~/.acme-todo/tasks.db` |

### Writes / Actions

| Action | Trigger | Effect |
|--------|---------|--------|
| Insert task | `acme-todo add <title...>` | New row with `completed = 0`, `createdAt = now`; new id printed |
| Mark done | `acme-todo done <id>` | Sets `completed = 1`, stamps `completedAt` if null |
| Delete task | `acme-todo delete <id>` | Removes the row permanently |
| Run migrations | Any command on a missing/stale DB | Creates the DB file and schema before the command's own query (CEO Condition 3) |

---

## Accessibility

- **Piped output.** Output format does not depend on `process.stdout.isTTY`. Running `acme-todo list | grep milk` produces identical bytes to running `acme-todo list` directly.
- **No interactive prompts in v1.** Commands never call `readline` or wait for stdin. A user automating `acme-todo` from a cron job or shell script can rely on zero-input execution.
- **Screen reader friendly.** Plain text, left-to-right, one record per line, no control characters — reads naturally via any assistive terminal.
- **Stable exit codes.** Scripts can branch on `$?` without parsing stderr strings.

---

## Cross-Platform Notes

Target platforms: macOS, Linux, Windows.

- **Home directory.** `~/.acme-todo/tasks.db` is resolved via Node's `os.homedir()`, which returns the correct path on all three platforms (no hardcoded `/home/` or `$HOME` shell expansion).
- **Path separators.** The DB path is constructed with `path.join`, which emits `\` on Windows and `/` elsewhere automatically.
- **Line endings.** Output is written with `console.log`, which uses `\n`. Windows consoles and PowerShell render `\n` correctly; if a user redirects to a file that requires CRLF, Node's stream layer handles it.
- **Env override.** `ACME_TODO_DB` is read from `process.env` and must be an absolute path; relative paths are resolved against `process.cwd()`.
- **Binary shebang.** `src/index.ts` starts with `#!/usr/bin/env node`. On Windows the npm/pnpm bin shim handles dispatch; no user action required.

---

## Edge Cases

| Case | Expected behavior |
|------|-------------------|
| Title with embedded quotes | Preserved verbatim — shell quoting is the user's concern |
| Very long title (> 40 chars) | Stored full, displayed truncated with `...` |
| `list` on empty DB | Header printed, no rows, exit 0 (no "No tasks" string) |
| `list` on a brand-new machine | Migrations auto-run on first call, then empty header printed (CEO Condition 3) |
| `done` on an already-done task | Exit 0, same success message, `completedAt` untouched |
| `delete` on a non-existent id | Exit 3, `task <id> not found` |
| `add` with only whitespace as title | Exit 1, `add: missing required argument <title>` (whitespace-only is not a title) |

---

## Acceptance Checklist

- [ ] Every command in the Command Surface table is wired in `src/cli.ts`
- [ ] `add`, `list`, `done`, `delete`, `--help` produce the exact stdout formats documented above
- [ ] Column alignment uses two-space separators and 40-char title truncation with ellipsis
- [ ] No ANSI escape codes in any output
- [ ] All error messages match the strings in the Error Messages table
- [ ] Exit codes follow the 0 / 1 / 2 / 3 contract
- [ ] `acme-todo list` on a fresh machine succeeds (no missing-DB error)
- [ ] Output is identical when piped vs when attached to a TTY
- [ ] Verified on macOS, Linux, and Windows

---

## CEO Verdict

Gated by the CEO planning review — see `artifacts/reviews/ceo-review-milestone-1.md`: **APPROVED WITH CONDITIONS** (2026-04-08). None of the three conditions target this spec directly; the plain-text-only decision was confirmed for v1, with the color scheme deferred to a later milestone.

---

_Last updated: 2026-04-08_
