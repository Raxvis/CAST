# Acme Todo — M1: Task CRUD + SQLite Persistence Completion Report

## Revision History

| Rev | Date | Agent | Change |
|-----|------|-------|--------|
| v1 | 2026-04-10 | product | Initial completion report |

---

## Header

| Field | Value |
|-------|-------|
| **Milestone** | M1: Task CRUD + SQLite Persistence |
| **Slug** | `task-crud` |
| **Planned** | 2026-04-08 |
| **Implementation** | 2026-04-09 |
| **Completion Date** | 2026-04-10 |
| **Author** | Product |
| **Status** | Complete with Deferrals |

---

## Summary

M1 shipped the first usable slice of Acme Todo. All five planned tasks (T-1 through T-5)
landed and the CLI can now add, list, complete, and delete tasks against a SQLite
database at `~/.acme-todo/tasks.db` (or the path in `ACME_TODO_DB`). All three CEO
Approval Conditions were verified. One bug (BUG-001) was caught and fixed during
implementation; one bug (BUG-002) was discovered during validation and deferred to
M2. The Vitest suite is green with 42 tests passing.

---

## Delivered

| # | Item | Description | Task Reference |
|---|------|-------------|----------------|
| 1 | Task type + data layer | `Task` interface, SQLite schema, idempotent migration runner with WAL mode and `idx_tasks_completed`. | T-1 |
| 2 | `add` command | `acme-todo add "<title>"` inserts a row with `completed=false` and prints the new id. | T-2 |
| 3 | `list` command | `acme-todo list` prints open tasks; `--all` includes completed; first-run creates DB + runs migrations automatically. | T-3 |
| 4 | `done` + `delete` commands | `done <id>` sets `completed` and `completedAt`; `delete <id>` removes the row; `delete` errors non-zero on missing id. | T-4 |
| 5 | CLI argument parser + entrypoint | Minimal custom argv parser in `src/cli.ts`, dispatcher in `src/index.ts`, `--help` output, unknown-command handling. | T-5 |

---

## Deferred

| # | Item | Reason for Deferral | Moved To |
|---|------|---------------------|----------|
| 1 | BUG-002: `done <id>` silently succeeds when the given id does not exist | Discovered during Product validation after freeze; low severity; not a blocker for M1's acceptance criteria. Fix belongs alongside a broader "id-not-found" helper in the data layer. | M2 |

---

## CEO Approval Conditions — Verification Status

| # | Condition | Verified By | Status | Evidence |
|---|-----------|-------------|--------|----------|
| 1 | All SQL queries must use parameterized bindings (no string concatenation into SQL). | Reviewer | Verified | Code review of `src/db/*`, `src/commands/*` — all statements use `db.prepare(...).run(...)` with bound parameters. See `artifacts/reviews/code-review-milestone-1.md`. |
| 2 | SQLite WAL mode enabled in the migration; index created on the `completed` column. | Reviewer | Verified | `src/db/migrations.ts` sets `PRAGMA journal_mode = WAL` and creates `idx_tasks_completed`. Runtime check in test suite confirms both. |
| 3 | `list` must handle a missing database file by running migrations on first invocation rather than throwing. | Product | Verified | Manual test on a clean machine: removed `~/.acme-todo/tasks.db`, ran `acme-todo list`, got an empty list with exit 0. Regression test added in `src/commands/list.test.ts`. |

All three conditions verified — milestone can proceed out of "Approved with Conditions".

---

## Test Suite Results

| Metric | Value |
|--------|-------|
| **Runner** | Vitest |
| **Command** | `pnpm test` |
| **Result** | Pass |
| **Tests passing** | 42 |
| **Tests failing** | 0 |
| **Typecheck** | `pnpm typecheck` clean |

Breakdown:
- `src/db/migrations.test.ts` — 6 tests (idempotency, WAL, index, env var)
- `src/commands/add.test.ts` — 5 tests
- `src/commands/list.test.ts` — 11 tests (includes first-run regression for BUG-001)
- `src/commands/done.test.ts` — 7 tests (BUG-002 case is skipped with a TODO)
- `src/commands/delete.test.ts` — 6 tests
- `src/cli.test.ts` — 7 tests

---

## Known Issues

| ID | Description | Severity | Owner | Tracked In |
|----|-------------|----------|-------|------------|
| BUG-002 | `done <id>` silently succeeds when the given id does not exist; should print an error and exit non-zero. | Low | Coder | `artifacts/bugs.md`, deferred to M2 |

BUG-001 (`list` crashed with "no such table: tasks" on first invocation) was fixed in-milestone
via CEO Condition 3 and is **closed**.

---

## Lessons Learned

### What Went Well

- CEO Condition 3 directly caught BUG-001 before shipping. The condition was written
  defensively ("handle a missing database file by running migrations on first invocation")
  and during implementation of T-3 the Coder hit exactly that crash on a clean machine.
  Because the condition was already on the checklist, the fix landed in the same task
  instead of becoming a post-release hotfix.
- T-1 shipping first as a hard dependency gate kept T-2/T-3/T-4 from stepping on each
  other — the three parallel tasks touched only their own command files.
- Writing the minimal custom argv parser in T-5 instead of pulling `commander` kept the
  dependency tree small (only `better-sqlite3` as a runtime dep).

### What Could Be Improved

- BUG-002 (`done` silent success) should have been caught in T-4's acceptance criteria.
  The criteria said "error if ID not found" for `delete` but the equivalent for `done`
  was implicit. Next milestone: make "error on missing id" an explicit criterion for
  every id-based mutation.
- The migration runner's directory-creation step for `~/.acme-todo/` was added late
  after manual testing on Linux. Arch review should explicitly cover filesystem
  prerequisites.

### Action Items for Next Milestone

| # | Action | Owner |
|---|--------|-------|
| 1 | Fix BUG-002: `done <id>` must error non-zero when the id does not exist. Add the previously-skipped Vitest case. | Coder |
| 2 | Add "error on missing id" as a standard acceptance criterion for every id-based mutation command. | Product |
| 3 | Document filesystem prerequisites (DB parent dir creation) in `artifacts/architecture.md` §4. | Docs Writer |

---

## Next Steps

1. Kick off M2 planning with BUG-002 as an inherited defect.
2. Product to draft M2 scope (task editing / renaming is the headline feature).
3. Tag `v0.1.0` once release milestone's checklist is cut — tracked separately.

---

## References

- **Milestone Definition**: `artifacts/milestones/milestone-1-task-crud.md`
- **Task Breakdown**: `artifacts/milestones/milestone-1-task-crud-tasks.md`
- **CEO Review**: `artifacts/reviews/ceo-review-milestone-1.md`
- **Code Review**: `artifacts/reviews/code-review-milestone-1.md`
- **Bug Log**: `artifacts/bugs.md`
- **Architecture**: `artifacts/architecture.md`

---

_Last updated: 2026-04-10_
