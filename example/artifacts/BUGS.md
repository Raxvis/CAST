# Acme Todo — Bug Tracking Log

This file is the single canonical schema for bug entries. All agents file, update, and verify bugs in exactly the format defined here.

---

## Bug Lifecycle

**ID convention**: `BUG-XXX` — sequential, zero-padded, never reused (e.g., `BUG-001`, `BUG-042`).

**Status flow**: `New → Triaged → In Progress → Fixed → Verified → Closed`

**Terminal states** (may be set instead of continuing the flow): `Cannot Reproduce` / `Duplicate` / `Won't Fix` / `Deferred`

**Severity**: `Critical` (product unusable or data at risk, no workaround) / `High` (major feature broken or wrong output; workaround cumbersome) / `Medium` (edge-case misbehavior; straightforward workaround) / `Low` (cosmetic or textual; no functional impact)

**Frequency**: `Always` / `Intermittent — N of M` / `Observed once` / `Unknown`

**Field ownership** — who writes what, and when:

| Owner | Writes | Status set |
|---|---|---|
| **Bug Gatherer** | Files the initial entry: ID, Description, Expected, Actual, Steps to Reproduce, Platform, Frequency, Evidence, Likely Files, Regression, Related Issues, initial Severity | `New` |
| **Product** | Triages: sets final Severity, accepts/rejects/defers | `Triaged` (or `Won't Fix` / `Duplicate` / `Deferred`) |
| **Debugger** | Investigation fields: Root Cause, Affected Module(s), Alternative Solutions, Recommended Fix, Assigned To, Investigation Date | `In Progress` |
| **Coder** | Resolution fields at fix time: Commit, Files Changed, Regression Notes | `Fixed` |
| **Tester / Product** | Tester confirms the fix; Product signs off | `Verified` → `Closed` |

Bugs never move between file sections — the entry stays in place and its **Status** field advances.

---

## Bug Entry Format

```
### BUG-XXX: [Short Title]
- **Status**: New / Triaged / In Progress / Fixed / Verified / Closed / Cannot Reproduce / Duplicate / Won't Fix / Deferred
- **Severity (initial)**: Critical | High | Medium | Low   _(set by Bug Gatherer)_
- **Severity (final)**: Critical | High | Medium | Low   _(set by Product at triage)_
- **Description**: [Detailed description of the bug and its impact on the user experience.]
- **Expected**: [What should happen.]
- **Actual**: [What actually happens.]
- **Steps to Reproduce**:
  1. [Step one]
  2. [Step two]
  3. [Step three]
- **Platform**: [All | macOS | Linux | Windows]
- **Frequency**: Always | Intermittent — [N] of [M] | Observed once | Unknown
- **Evidence**: [Link to screenshot, recording, or log. Or: "None available."]
- **Likely Files**:
  - `[path/to/file]`
- **Regression**: [Yes / No — if yes, what changed since it last worked. Or: "Unknown."]
- **Related Issues**: [Related bug IDs or tasks. Or: "None."]

_Investigation (written by Debugger):_
- **Root Cause**: [Why the defect occurs.]
- **Affected Module(s)**: [Files or modules involved.]
- **Alternative Solutions**: [At least two approaches with trade-offs, for non-trivial bugs.]
- **Recommended Fix**: [Debugger's preferred approach and why.]
- **Assigned To**: [Coder or Refactor]
- **Investigation Date**: [YYYY-MM-DD]

_Resolution (written by Coder at fix time):_
- **Commit**: `[commit hash or reference]`
- **Files Changed**:
  - `[path/to/file]`
- **Regression Notes**: [Areas to watch for regressions introduced by the fix.]

- **Notes**: [Any additional context, workarounds, or severity rationale.]
```

---

## Bugs

### BUG-001: `list` crashes with "no such table: tasks" on first invocation
- **Status**: Closed
- **Severity (initial)**: High
- **Severity (final)**: High
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
- **Related Issues**: CEO Approval Condition 3 (`artifacts/reviews/ceo-review-milestone-1.md`).

_Investigation (written by Debugger):_
- **Root Cause**: Assumption leak — the original architecture assumed the SQLite database file would already be initialized by some earlier step before any command handler touched it. Migration execution lived in the `add` command path implicitly (because `add` was the command used during development), so `list` had no migration entry point and issued `SELECT * FROM tasks` against a database that had never had its migrations run.
- **Affected Module(s)**: `src/commands/list.ts`, `src/db/connection.ts` (all command entry paths by extension).
- **Alternative Solutions**: (a) Run migrations once in the CLI dispatcher (`src/cli.ts`) before dispatching — single call site, but hides the dependency from command handlers and their tests. (b) Extract an idempotent `ensureMigrations(db)` and call it at the top of every command entry path — explicit per handler, testable in isolation, smallest diff. (c) Make migration automatic inside the connection factory — most foolproof, but a larger structural change than a bug fix warrants.
- **Recommended Fix**: Option (b). It is the smallest explicit change and keeps each command self-sufficient; revisit option (c) as a Milestone 2 refactor.
- **Assigned To**: Coder
- **Investigation Date**: 2026-04-09

_Resolution (written by Coder at fix time):_
- **Commit**: `a8f3d12`
- **Files Changed**:
  - `src/commands/list.ts`
  - `src/db/connection.ts`
- **Regression Notes**: The migration runner is idempotent (checks `schema_version` first) so the cost on subsequent invocations is a single indexed query. The same `ensureMigrations()` call was wired into `add`, `done`, and `delete` in the same commit for consistency. Watch for regressions if future work adds a new command: it must also call `ensureMigrations()` before touching the database. Consider making it automatic inside the connection factory in Milestone 2.

- **Notes**: Discovered by Coder during T-3 and resolved within the same session. This fix is the exact remediation CEO Approval Condition 3 demanded ("`list` must handle a missing database file by running migrations on first invocation rather than throwing an error"). Tester confirmed the fix in the T-3 suite run; Product verified the condition during Milestone 1 validation on 2026-04-10 by running `rm -rf ~/.acme-todo && acme list` and confirming the empty-state message and exit 0, then closed the bug at milestone sign-off.

### BUG-002: `done <id>` silently succeeds on non-existent task ID
- **Status**: Deferred
- **Severity (initial)**: Low
- **Severity (final)**: Low
- **Description**: Running `acme done <id>` with an ID that does not correspond to any row in the `tasks` table returns exit code 0 and produces no output. The user has no signal that their command did nothing. This does not affect correctness of normal flows — if the user supplies a real ID, the task is marked completed as expected — but it is a usability papercut that also makes shell scripting around the CLI error-prone.
- **Expected**: The CLI should print an error message to stderr (e.g., `Error: no task with id 999`) and exit with a non-zero status code.
- **Actual**: No output. Exit code 0. The underlying `UPDATE tasks SET completed = 1 WHERE id = ?` runs, affects zero rows, and returns without signalling.
- **Steps to Reproduce**:
  1. Run `acme add "test task"` (creates task with id=1).
  2. Run `acme done 999`.
  3. Observe: no output, `echo $?` prints `0`.
- **Platform**: All (macOS, Linux, Windows)
- **Frequency**: Always
- **Evidence**: None available — reproduces deterministically from the steps above.
- **Likely Files**:
  - `src/commands/done.ts`
- **Regression**: No — the zero-row case was never handled.
- **Related Issues**: None yet — `delete` should receive the same treatment for consistency; add it to the Milestone 2 task when filed.

- **Notes**: Filed by Bug Gatherer during Milestone 1 manual smoke testing. Triaged by Product on 2026-04-10 and deferred to Milestone 2 (no Debugger investigation — deferral decided at triage). Reason for deferral: does not affect correctness of normal flows; usability papercut that can wait. The fix will likely check the `changes` field returned by `better-sqlite3`'s `.run()` result and error out when `changes === 0`.

---

## Regression Checklist

**Owner: Tester.** Tester maintains this table and verifies each critical path after significant fixes or refactors.

| # | Area | Check Description | Last Verified | Verified By |
|---|------|-------------------|--------------|-------------|
| 1 | DB bootstrap | Migrations run on a fresh DB file (delete `~/.acme-todo/` and run any command) | 2026-04-10 | Product |
| 2 | `list` first-run | `acme list` on a machine with no prior state prints empty-state message and exits 0 | 2026-04-10 | Product |
| 3 | `done`/`delete` on non-existent ID | CLI signals failure (tracked via BUG-002; currently silent) | — | — |
| 4 | WAL mode persistence | `PRAGMA journal_mode;` returns `wal` after a migration run | 2026-04-09 | Reviewer |
| 5 | Index presence | `EXPLAIN QUERY PLAN SELECT * FROM tasks WHERE completed = 0` uses `idx_tasks_completed` | 2026-04-09 | Reviewer |

---

_Last updated: 2026-04-10_
