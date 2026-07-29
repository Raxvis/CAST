# T-1: Task type, SQLite schema, migration runner

## Header

| Field | Value |
|-------|-------|
| **Milestone** | `../README.md` (M1: Task CRUD + SQLite Persistence) |
| **Status** | Complete |
| **Dependencies** | None |
| **Needs Arch Doc** | Done -> `../architecture.md` §4 (Data Layer) |
| **Needs UI Spec** | No |
| **Loop count** | 0 / 3 |

---

## Description

Define the `Task` domain type and build the SQLite data layer: schema creation,
idempotent migration runner, and a shared `better-sqlite3` connection helper. This
is the foundation every command builds on, so it ships first. The migration runner
must be safe to call on every CLI invocation (used by T-3 to satisfy CEO Condition 3)
and must enable WAL mode plus an index on `completed` to satisfy CEO Condition 2.

---

## Files

- `src/types/task.ts` — `Task` interface: `id: number`, `title: string`,
  `completed: boolean`, `createdAt: string`, `completedAt: string | null`.
- `src/db/schema.ts` — `CREATE TABLE IF NOT EXISTS tasks` statement and index DDL.
- `src/db/migrations.ts` — `runMigrations(db)` function; opens the DB, enables WAL,
  creates the table, creates the index on `completed`. Idempotent.

---

## Acceptance Criteria

- [x] `Task` type exported from `src/types/task.ts` with all 5 fields.
- [x] `runMigrations` is safe to invoke repeatedly — second call is a no-op.
- [x] `PRAGMA journal_mode = WAL` is set on the connection.
- [x] Index `idx_tasks_completed` exists on the `completed` column after migration.
- [x] Parent directory for `~/.acme-todo/tasks.db` is created if missing.
- [x] Honors `ACME_TODO_DB` environment variable for the DB path.
- [x] No linter or type-check errors introduced.
- [x] Vitest unit tests cover the idempotency of `runMigrations`.

---

## Context Manifest

| Reference | Sections | Why |
|---|---|---|
| `../architecture.md` | §4 (Data Layer) | Schema shape, WAL + index contract, connection helper design |
| `../README.md` | § CEO Approval Conditions | Conditions 1 (parameterized SQL) and 2 (WAL + index) name this task |
| `docs/CODE_PATTERNS.md` | TypeScript Style Conventions | Naming, strict-mode, and module-layout rules |

---

## Handoff Log

### 1. product -> coder — 2026-04-09

- **Outcome**: Task released for implementation; no dependencies.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 2. coder -> tester — 2026-04-09

- **Outcome**: Data layer implemented — `Task` type, schema DDL, idempotent `runMigrations` with WAL and `idx_tasks_completed`.
- **Files touched**: `src/types/task.ts`, `src/db/schema.ts`, `src/db/migrations.ts`
- **Read next**: Manifest only — cover `runMigrations` idempotency and the `ACME_TODO_DB` override
- **Open items**: None

### 3. tester -> reviewer — 2026-04-09

- **Outcome**: 6 unit tests added; `pnpm test` green (idempotency, WAL pragma, index presence, env override).
- **Files touched**: `src/db/migrations.test.ts`
- **Read next**: Manifest only
- **Open items**: None

### 4. reviewer -> product — 2026-04-09

- **Outcome**: Clean review — no Defects, no Issues. CEO Conditions 1 and 2 verified in the migration.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 5. product — task complete — 2026-04-09

- **Outcome**: All acceptance criteria met; Status set to Complete.
- **Files touched**: This file (Header Status)
- **Read next**: —
- **Open items**: None

---

_Last updated: 2026-04-09_
