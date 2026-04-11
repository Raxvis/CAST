# Acme Todo — Bug Tracking Log

---

## Bug Entry Format

```
### BUG-XXX: [Short Title]
- **Status**: Open / In Progress / Fixed / Won't Fix / Deferred
- **Severity**: Critical | High | Medium | Low
- **Description**: [Detailed description of the bug and its impact on the user experience.]
- **Expected**: [What should happen.]
- **Actual**: [What actually happens.]
- **Steps to Reproduce**:
  1. [Step one]
  2. [Step two]
  3. [Step three]
- **Platform**: [All | macOS | Linux | Windows]
- **Frequency**: Always | Often | Sometimes | Rare
- **Likely Files**:
  - `[path/to/file]`
- **Notes**: [Any additional context, related bugs, or workarounds.]
```

---

## Open Bugs

### BUG-002: `done <id>` silently succeeds on non-existent task ID
- **Status**: Open (Deferred to Milestone 2)
- **Severity**: Low
- **Description**: Running `acme done <id>` with an ID that does not correspond to any row in the `tasks` table returns exit code 0 and produces no output. The user has no signal that their command did nothing. This does not affect correctness of normal flows — if the user supplies a real ID, the task is marked completed as expected — but it is a usability papercut that also makes shell scripting around the CLI error-prone.
- **Expected**: The CLI should print an error message to stderr (e.g., `Error: no task with id 999`) and exit with a non-zero status code.
- **Actual**: No output. Exit code 0. The underlying `UPDATE tasks SET completed = 1 WHERE id = ?` runs, affects zero rows, and returns without signalling.
- **Steps to Reproduce**:
  1. Run `acme add "test task"` (creates task with id=1).
  2. Run `acme done 999`.
  3. Observe: no output, `echo $?` prints `0`.
- **Platform**: All (macOS, Linux, Windows)
- **Frequency**: Always
- **Likely Files**:
  - `src/commands/done.ts`
- **Notes**: Triaged by Product on 2026-04-10 and deferred to Milestone 2. Reason for deferral: does not affect correctness of normal flows; cosmetic issue that can wait. The fix will likely check the `changes` field returned by `better-sqlite3`'s `.run()` result and error out when `changes === 0`. Related: `delete` should receive the same treatment for consistency — add to the M2 task when filed.

---

## Fixed Bugs

### BUG-001: `list` crashes with "no such table: tasks" on first invocation
- **Status**: Fixed
- **Severity**: High (at discovery; downgraded to Fixed after inline remediation)
- **Fixed**: 2026-04-09
- **Commit**: `a8f3d12`
- **Files Changed**:
  - `src/commands/list.ts`
  - `src/db/connection.ts`
- **Root Cause**: The original architecture assumed the SQLite database file would already be initialized by some earlier step before any command handler touched it. In practice, the first command a fresh-install user runs is often `acme list` (to confirm the CLI is working), which issues a `SELECT * FROM tasks` against a database that has never had its migrations run. `better-sqlite3` raises `SqliteError: no such table: tasks` and the CLI exits with a raw stack trace. The fault is an assumption leak: migration execution lived in the `add` command path implicitly (because `add` was the command used during development), so nobody noticed that `list` had no migration entry point.
- **Fix**: Extracted the migration runner into `ensureMigrations(db)` in `src/db/connection.ts` and wired it into every command's entry path. `src/commands/list.ts` now calls `ensureMigrations()` before preparing its SELECT statement. The migration runner is idempotent (checks `schema_version` first) so the cost on subsequent invocations is a single indexed query. The same change was applied to `add`, `done`, and `delete` during the same commit for consistency, even though those paths were not directly broken.
- **Regression Notes**: This fix is the exact remediation CEO Approval Condition 3 demanded ("`list` must handle a missing database file by running migrations on first invocation rather than throwing an error"). Product verified the condition during Milestone 1 validation on 2026-04-10 by running `rm -rf ~/.acme-todo && acme list` and confirming the CLI printed the empty-state message and exited 0. Watch for regressions if future work adds a new command: it must also call `ensureMigrations()` before touching the database. Consider making `ensureMigrations()` automatic inside the connection factory in Milestone 2.

---

### Fixed Bug Format

```
### BUG-XXX: [Short Title]
- **Status**: Fixed
- **Severity**: [Severity at time of fix]
- **Fixed**: [YYYY-MM-DD]
- **Commit**: `[commit hash or reference]`
- **Files Changed**:
  - `[path/to/file]`
- **Root Cause**: [Explanation of why the bug occurred.]
- **Fix**: [Description of the change that resolved the bug.]
- **Regression Notes**: [Any areas to watch for regressions introduced by the fix.]
```

---

## Regression Checklist

Use this table to track critical paths that must be manually verified after significant fixes or refactors.

| # | Area | Check Description | Last Verified | Verified By |
|---|------|-------------------|--------------|-------------|
| 1 | DB bootstrap | Migrations run on a fresh DB file (delete `~/.acme-todo/` and run any command) | 2026-04-10 | Product |
| 2 | `list` first-run | `acme list` on a machine with no prior state prints empty-state message and exits 0 | 2026-04-10 | Product |
| 3 | `done`/`delete` on non-existent ID | CLI signals failure (tracked via BUG-002; currently silent) | — | — |
| 4 | WAL mode persistence | `PRAGMA journal_mode;` returns `wal` after a migration run | 2026-04-09 | Reviewer |
| 5 | Index presence | `EXPLAIN QUERY PLAN SELECT * FROM tasks WHERE completed = 0` uses `idx_tasks_completed` | 2026-04-09 | Reviewer |

---

_Last updated: 2026-04-10_
