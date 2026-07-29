# BUG-001: `list` crashes with "no such table: tasks" on first invocation

## Report

- **Status**: Closed
- **Severity (initial)**: High
- **Severity (final)**: High
- **Found during**: T-3 (`tasks/task-03-list-command.md`), M1
- **Description**: On a fresh install, running `acme list` before any other command crashes with a raw `SqliteError: no such table: tasks` stack trace. The first command a fresh-install user runs is often `list` (to confirm the CLI is working), so this breaks the first-run experience outright.
- **Expected**: `acme list` on a machine with no prior state prints the empty-state message and exits 0.
- **Actual**: `better-sqlite3` raises `SqliteError: no such table: tasks` and the CLI exits with a raw stack trace.
- **Steps to Reproduce**:
  1. Remove any prior state: `rm -rf ~/.acme-todo`.
  2. Run `acme list` as the first-ever command.
  3. Observe the `SqliteError` stack trace and non-zero exit.
- **Platform**: All (macOS, Linux, Windows)
- **Frequency**: Always (on a fresh install)
- **Evidence**: Terminal transcript in the 2026-04-09 session entry of `artifacts/STANDUP.md`; reproduces deterministically.
- **Likely Files**:
  - `src/commands/list.ts`
  - `src/db/connection.ts`
- **Regression**: No — the first-run path never worked; migration execution lived only in the `add` command path.
- **Related Issues**: CEO Approval Condition 3 (`../reviews/ceo.md`).

## Investigation (written by Debugger)

- **Root Cause**: Assumption leak — the original architecture assumed the SQLite database file would already be initialized by some earlier step before any command handler touched it. Migration execution lived in the `add` command path implicitly (because `add` was the command used during development), so `list` had no migration entry point and issued `SELECT * FROM tasks` against a database that had never had its migrations run.
- **Affected Module(s)**: `src/commands/list.ts`, `src/db/connection.ts` (all command entry paths by extension).
- **Alternative Solutions**: (a) Run migrations once in the CLI dispatcher (`src/cli.ts`) before dispatching — single call site, but hides the dependency from command handlers and their tests. (b) Extract an idempotent `ensureMigrations(db)` and call it at the top of every command entry path — explicit per handler, testable in isolation, smallest diff. (c) Make migration automatic inside the connection factory — most foolproof, but a larger structural change than a bug fix warrants.
- **Recommended Fix**: Option (b). It is the smallest explicit change and keeps each command self-sufficient; revisit option (c) as a Milestone 2 refactor.
- **Assigned To**: Coder
- **Investigation Date**: 2026-04-09

## Resolution (written by Coder at fix time)

- **Commit**: `a8f3d12`
- **Files Changed**:
  - `src/commands/list.ts`
  - `src/db/connection.ts`
- **Regression Notes**: The migration runner is idempotent (checks `schema_version` first) so the cost on subsequent invocations is a single indexed query. The same `ensureMigrations()` call was wired into `add`, `done`, and `delete` in the same commit for consistency. Watch for regressions if future work adds a new command: it must also call `ensureMigrations()` before touching the database. Consider making it automatic inside the connection factory in Milestone 2.

## Notes

Discovered by Coder during T-3 and resolved within the same session. This fix is the exact remediation CEO Approval Condition 3 demanded ("`list` must handle a missing database file by running migrations on first invocation rather than throwing an error"). Tester confirmed the fix in the T-3 suite run; Product verified the condition during Milestone 1 validation on 2026-04-10 by running `rm -rf ~/.acme-todo && acme list` and confirming the empty-state message and exit 0, then closed the bug at milestone sign-off.

---

_Last updated: 2026-04-10_
