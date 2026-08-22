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

### 1. orchestrator -> coder — 2026-04-09

- **Outcome**: Task released for implementation; no dependencies.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 2. coder -> reviewer — 2026-04-09

- **Outcome**: Data layer implemented — `Task` type, schema DDL, idempotent `runMigrations` with WAL and `idx_tasks_completed`. 6 unit tests added covering idempotency, the WAL pragma, index presence, and the `ACME_TODO_DB` override.
- **Files touched**: `src/types/task.ts`, `src/db/schema.ts`, `src/db/migrations.ts`, `src/db/migrations.test.ts`
- **Commit**: `b7d41e0`
- **Test Results**: `pnpm test` — `Test Files  1 passed (1)` / `Tests  6 passed (6)` / `Duration  0.61s`
- **Read next**: Manifest only
- **Open items**: None

### 3. reviewer -> orchestrator — 2026-04-09

- **Outcome**: Clean review — no Defects, no Issues. All 8 criteria and both CEO Approval Condition lines Met with evidence — closes at Step 3a.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None
- **Acceptance Criteria Check**:
  - [1] `Task` type exported from `src/types/task.ts` with all 5 fields. — Met — `src/types/task.ts:3-9` (`b7d41e0`)
  - [2] `runMigrations` is safe to invoke repeatedly — second call is a no-op. — Met — `migrations.test.ts` › "second call is a no-op" (`b7d41e0`)
  - [3] `PRAGMA journal_mode = WAL` is set on the connection. — Met — `src/db/migrations.ts:18`; `migrations.test.ts` › "WAL pragma set"
  - [4] Index `idx_tasks_completed` exists on the `completed` column after migration. — Met — `src/db/schema.ts:24`; `migrations.test.ts` › "index present"
  - [5] Parent directory for `~/.acme-todo/tasks.db` is created if missing. — Met — `src/db/schema.ts:11` (`mkdirSync` recursive)
  - [6] Honors `ACME_TODO_DB` environment variable for the DB path. — Met — `migrations.test.ts` › "env override"
  - [7] No linter or type-check errors introduced. — Met — `pnpm typecheck` clean at `b7d41e0`
  - [8] Vitest unit tests cover the idempotency of `runMigrations`. — Met — 6 tests in `b7d41e0`
  - [C-1] CEO Approval Condition 1 — all SQL parameterized. — Met — `src/db/migrations.ts` uses prepared statements throughout; no string-built SQL in the diff
  - [C-2] CEO Approval Condition 2 — WAL mode + `idx_tasks_completed`. — Met — `src/db/migrations.ts:18`; `src/db/schema.ts:24`

### 4. orchestrator — task complete — 2026-04-09

- **Outcome**: Step 3a clean close — every criterion and condition line Met with evidence (entry #3); Status set to Complete. Conditions verified of record by Product at the milestone close.
- **Files touched**: This file (Header Status)
- **Read next**: —
- **Open items**: None

---

_Last updated: 2026-04-09_
