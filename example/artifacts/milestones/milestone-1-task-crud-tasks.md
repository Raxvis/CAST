# Acme Todo — M1: Task CRUD + SQLite Persistence Task Breakdown

## Revision History

| Rev | Date | Agent | Change |
|-----|------|-------|--------|
| v1 | 2026-04-08 | product | Initial task breakdown |
| v2 | 2026-04-10 | product | All tasks marked complete |

---

## Header

| Field | Value |
|-------|-------|
| **Goal** | Deliver a working CLI that can add, list, complete, and delete tasks backed by SQLite. |
| **Status** | Complete |
| **Requirements Reference** | `docs/PRD.md` §3 (Core CRUD), §5 (Persistence) |
| **Milestone Definition** | `artifacts/milestones/milestone-1-task-crud.md` |
| **CEO Review** | `artifacts/reviews/ceo-review-milestone-1.md` |

---

## Summary

| Task ID | Task Name | Status | Dependencies | Needs Arch Doc | Needs UI Spec |
|---------|-----------|--------|--------------|----------------|---------------|
| T-1 | Task type, schema, migration runner | Complete | None | Done | No |
| T-2 | `add` command | Complete | T-1 | Done | Done |
| T-3 | `list` command | Complete | T-1 | Done | Done |
| T-4 | `done` + `delete` commands | Complete | T-1 | Done | Done |
| T-5 | CLI argument parser wiring | Complete | T-2, T-3, T-4 | Done | Done |

Dependency graph: T-1 blocks T-2/T-3/T-4 (parallel), which all block T-5.

---

## CEO Approval Conditions

_Filled after the CEO verdict (APPROVED WITH CONDITIONS, 2026-04-08). Coder tracked each condition during engineering; Reviewer and Product verified at completion._

| Condition | Source | Status |
|-----------|--------|--------|
| 1. All SQL queries use parameterized bindings — no string concatenation into SQL (Security) | `artifacts/reviews/ceo-review-milestone-1.md` | Verified (Reviewer, 2026-04-10) |
| 2. WAL mode enabled in the migration + index on the `completed` column (Performance) | `artifacts/reviews/ceo-review-milestone-1.md` | Verified (Reviewer, 2026-04-10) |
| 3. `list` handles a missing database file by running migrations on first invocation (Error handling) | `artifacts/reviews/ceo-review-milestone-1.md` | Verified (Product, 2026-04-10) |

---

## Tasks

---

### T-1: Task type, SQLite schema, migration runner

| Field | Value |
|-------|-------|
| **Status** | Complete |
| **Dependencies** | None |
| **Needs Arch Doc** | Done -> `artifacts/architecture/arch-milestone-1.md` (data layer) |
| **Needs UI Spec** | No |
| **CEO Conditions** | Condition 1 (parameterized SQL), Condition 2 (WAL + index) |

**Description**:
Define the `Task` domain type and build the SQLite data layer: schema creation,
idempotent migration runner, and a shared `better-sqlite3` connection helper. This
is the foundation every command builds on, so it ships first. The migration runner
must be safe to call on every CLI invocation (used by T-3 to satisfy CEO Condition 3)
and must enable WAL mode plus an index on `completed` to satisfy CEO Condition 2.

**Files**:
- `src/types/task.ts` — `Task` interface: `id: number`, `title: string`,
  `completed: boolean`, `createdAt: string`, `completedAt: string | null`.
- `src/db/schema.ts` — `CREATE TABLE IF NOT EXISTS tasks` statement and index DDL.
- `src/db/migrations.ts` — `runMigrations(db)` function; opens the DB, enables WAL,
  creates the table, creates the index on `completed`. Idempotent.

**Acceptance Criteria**:
- [x] `Task` type exported from `src/types/task.ts` with all 5 fields.
- [x] `runMigrations` is safe to invoke repeatedly — second call is a no-op.
- [x] `PRAGMA journal_mode = WAL` is set on the connection.
- [x] Index `idx_tasks_completed` exists on the `completed` column after migration.
- [x] Parent directory for `~/.acme-todo/tasks.db` is created if missing.
- [x] Honors `ACME_TODO_DB` environment variable for the DB path.
- [x] No linter or type-check errors introduced.
- [x] Vitest unit tests cover the idempotency of `runMigrations`.

**Architecture Docs**: `artifacts/architecture/arch-milestone-1.md` §4 (Data Layer)

---

### T-2: `add` command

| Field | Value |
|-------|-------|
| **Status** | Complete |
| **Dependencies** | T-1 |
| **Needs Arch Doc** | Done -> `artifacts/architecture/arch-milestone-1.md` §5 (Commands) |
| **Needs UI Spec** | Done -> `artifacts/ui-specs/ui-milestone-1.md` §2 |
| **CEO Conditions** | Condition 1 (parameterized SQL) |

**Description**:
Implement the `add` command. Takes a single positional argument (the task title),
inserts a new row into `tasks` with `completed = 0`, `createdAt = new Date().toISOString()`,
`completedAt = null`, and prints the new integer id on stdout.

**Files**:
- `src/commands/add.ts` — `runAdd(title: string, db: Database): number` plus a
  thin CLI wrapper that prints the id.

**Acceptance Criteria**:
- [x] `acme-todo add "buy milk"` prints the new task id to stdout and exits 0.
- [x] Insert uses a prepared statement with bound parameters (no string interpolation).
- [x] Missing title argument prints an error and exits non-zero.
- [x] Inserted row has `completed = false` and a valid ISO `createdAt`.
- [x] Vitest suite covers happy path and missing-title error path.
- [x] No linter or type-check errors introduced.

**Architecture Docs**: `artifacts/architecture/arch-milestone-1.md` §5.1

---

### T-3: `list` command

| Field | Value |
|-------|-------|
| **Status** | Complete |
| **Dependencies** | T-1 |
| **Needs Arch Doc** | Done -> `artifacts/architecture/arch-milestone-1.md` §5.2 |
| **Needs UI Spec** | Done -> `artifacts/ui-specs/ui-milestone-1.md` §3 |
| **CEO Conditions** | Condition 1 (parameterized SQL), Condition 3 (first-run migration) |

**Description**:
Implement the `list` command. By default prints only open tasks (where
`completed = 0`); with `--all` it also prints completed tasks. Output columns:
`ID  TITLE  STATUS  CREATED` separated by two spaces, one row per task. **Per CEO
Condition 3**, this command must detect a missing database file and run migrations
on first invocation rather than throwing — this is the path BUG-001 surfaced.

**Files**:
- `src/commands/list.ts` — `runList({ all: boolean }, db: Database): Task[]` plus
  CLI formatter.

**Acceptance Criteria**:
- [x] `acme-todo list` on an empty DB prints a header row and no tasks.
- [x] `acme-todo list` on a fresh machine (no DB file) creates the DB, runs
  migrations, and prints the empty list — does not crash (fixes BUG-001).
- [x] `--all` flag includes completed tasks; without it, only open tasks print.
- [x] Output format is exactly `ID  TITLE  STATUS  CREATED`.
- [x] Query uses parameterized binding for the `completed` filter.
- [x] Vitest suite covers: empty DB, mixed open/completed, `--all` flag, first-run migration.
- [x] No linter or type-check errors introduced.

**Architecture Docs**: `artifacts/architecture/arch-milestone-1.md` §5.2

---

### T-4: `done` and `delete` commands

| Field | Value |
|-------|-------|
| **Status** | Complete |
| **Dependencies** | T-1 |
| **Needs Arch Doc** | Done -> `artifacts/architecture/arch-milestone-1.md` §5.3 |
| **Needs UI Spec** | Done -> `artifacts/ui-specs/ui-milestone-1.md` §4 |
| **CEO Conditions** | Condition 1 (parameterized SQL) |

**Description**:
Implement the two mutation-by-id commands. `done <id>` sets `completed = 1` and
`completedAt = new Date().toISOString()` on the row with the given id. `delete <id>`
removes the row. Both must error cleanly (non-zero exit, human-readable message)
when the id does not exist. Note: BUG-002 (silent success on missing id for `done`)
was filed during validation and is deferred to M2.

**Files**:
- `src/commands/done.ts` — `runDone(id: number, db: Database): void`.
- `src/commands/delete.ts` — `runDelete(id: number, db: Database): void`.

**Acceptance Criteria**:
- [x] `acme-todo done 1` on an existing task sets `completed` and `completedAt`.
- [x] `acme-todo delete 1` on an existing task removes the row.
- [x] Both commands use parameterized statements bound to the id argument.
- [x] `delete` with a non-existent id exits non-zero with a clear error.
- [x] Non-integer id argument prints a usage error.
- [x] Vitest suite covers happy path and missing-id path for `delete` (and for `done` once BUG-002 is fixed in M2).
- [x] No linter or type-check errors introduced.

**Architecture Docs**: `artifacts/architecture/arch-milestone-1.md` §5.3

---

### T-5: CLI argument parser wiring

| Field | Value |
|-------|-------|
| **Status** | Complete |
| **Dependencies** | T-2, T-3, T-4 |
| **Needs Arch Doc** | Done -> `artifacts/architecture/arch-milestone-1.md` §6 |
| **Needs UI Spec** | Done -> `artifacts/ui-specs/ui-milestone-1.md` §5 (help output) |
| **CEO Conditions** | None direct; exercises Condition 3 via `list` |

**Description**:
Wire all four commands behind a single `acme-todo` entrypoint. Implement a minimal
custom argv parser in `src/cli.ts` — no `commander`, no `yargs`. Supported routes:
`add <title>`, `list [--all]`, `done <id>`, `delete <id>`, `--help` / `-h`.
Unknown commands print usage and exit non-zero. `src/index.ts` is the Node entrypoint
that opens the DB, runs migrations, dispatches, and closes the DB.

**Files**:
- `src/cli.ts` — `parseArgv(argv: string[]): ParsedCommand` and `dispatch` helper.
- `src/index.ts` — entrypoint: open DB, `runMigrations`, dispatch, handle errors.

**Acceptance Criteria**:
- [x] `acme-todo --help` prints usage listing all four commands.
- [x] `acme-todo` with no args prints usage and exits non-zero.
- [x] Unknown command (e.g. `acme-todo frobnicate`) prints usage and exits non-zero.
- [x] `list --all` is parsed correctly (flag routed to `runList`).
- [x] `src/index.ts` always calls `runMigrations` before dispatching — this is what
      makes Condition 3 / BUG-001 impossible to regress.
- [x] Vitest suite covers parser happy paths, `--help`, and unknown-command error.
- [x] No linter or type-check errors introduced.

**Architecture Docs**: `artifacts/architecture/arch-milestone-1.md` §6 (Entrypoint)

---

_Last updated: 2026-04-10_
