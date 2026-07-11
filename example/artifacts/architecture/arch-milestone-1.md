# Acme Todo — Architecture Spec: Milestone 1 (Task CRUD + SQLite persistence)

## Revision History

| Rev | Date | Agent | Change |
|-----|------|-------|--------|
| v1 | 2026-04-08 | architect | Initial architecture spec |

---

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Date** | 2026-04-08 |
| **Author** | Architect agent (claude-opus-4-8) |
| **Status** | Approved |
| **Milestone** | M1 — `task-crud` |

---

## Overview

### Purpose

Milestone 1 introduces the foundational layers of Acme Todo: a typed task model, a SQLite-backed persistence layer, four CRUD commands (`add`, `list`, `done`, `delete`), and the CLI argument router that dispatches to them. This is a system-level architecture because the milestone spans five modules that must cooperate end-to-end to satisfy a single user action.

### Scope

**In scope (Milestone 1 only):**
- Task type definition and shared TypeScript types
- SQLite schema, migration runner, and connection management
- `add`, `list`, `done`, `delete` command handlers
- CLI argv routing and binary entry point
- Database file resolution (default `~/.acme-todo/tasks.db`, overridable via `ACME_TODO_DB`)

**Out of scope (deferred to later milestones):**
- Tagging, priorities, due dates
- Editing a task's title after creation
- Multi-user or sync features
- ANSI colors in output
- Interactive prompts

### Key Components

| Component | Role |
|-----------|------|
| `src/types/` | Shared TypeScript types (`Task`, `TaskRow`, `ExitCode`) |
| `src/db/` | SQLite schema, idempotent migration runner, connection factory |
| `src/commands/` | One handler per subcommand (`add`, `list`, `done`, `delete`) |
| `src/cli.ts` + `src/index.ts` | argv routing and the process entry point |
| SQLite (`better-sqlite3`) | Persistence layer — single file at `~/.acme-todo/tasks.db` |

---

## System Architecture

### Component Diagram

```
  ┌────────────────────────────────────────────────────────┐
  │                     acme-todo CLI                      │
  │                                                        │
  │  ┌───────────────┐      ┌────────────────────────┐    │
  │  │  src/index.ts │─────▶│        src/cli.ts      │    │
  │  │  (entrypoint) │      │     (argv dispatch)    │    │
  │  └───────────────┘      └───────────┬────────────┘    │
  │                                     │                  │
  │              ┌──────────────────────┼─────────────┐    │
  │              ▼            ▼         ▼         ▼        │
  │        ┌────────┐  ┌────────┐ ┌────────┐ ┌────────┐   │
  │        │ add.ts │  │list.ts │ │done.ts │ │delete  │   │
  │        └────┬───┘  └────┬───┘ └───┬────┘ └───┬────┘   │
  │             └───────────┴─────┬───┴───────────┘        │
  │                               ▼                        │
  │                  ┌─────────────────────────┐           │
  │                  │   src/db/connection.ts  │           │
  │                  │ (openDatabase + migrate)│           │
  │                  └────────────┬────────────┘           │
  └───────────────────────────────┼────────────────────────┘
                                  ▼
                     SQLite file (WAL mode)
                   ~/.acme-todo/tasks.db
```

All command modules share the `src/types/` definitions; `db/connection.ts` composes `db/schema.ts` and `db/migrations.ts`.

### Data Flow

End-to-end flow for a single user command:

```
  argv (process.argv.slice(2))
       │
       ▼
  src/index.ts        ── imports runCli, awaits, calls process.exit(code)
       │
       ▼
  src/cli.ts          ── parses first positional as subcommand
       │                 routes to commands/<name>.run(rest)
       ▼
  src/commands/*.ts   ── validates args, resolves DB path
       │
       ▼
  src/db/connection   ── openDatabase() returns a migrated handle
       │
       ▼
  SQLite (WAL)        ── parameterized statement executes
       │                 [CEO Condition 1 — Security]
       ▼
  result rows         ── command formats stdout and returns exit code
       │
       ▼
  stdout / stderr + exit code
```

A command handler never touches `process.exit` directly; it returns a number and lets `index.ts` own the process lifecycle. This keeps commands unit-testable.

---

## Module Specifications

The module pipeline for M1 is `types → db → commands → cli → index`. Each layer depends only on layers to its left.

| Module | Purpose | Public Interface | Depends On |
|--------|---------|------------------|------------|
| `src/types/task.ts` | Task type + shared TS types | `Task`, `TaskRow`, `ExitCode` | — |
| `src/db/schema.ts` | SQL DDL strings and pragmas | `SCHEMA_STATEMENTS: string[]`, `SCHEMA_VERSION` | `types` |
| `src/db/migrations.ts` | Idempotent migration runner | `runMigrations(db: Database): void` | `types`, `db/schema` |
| `src/db/connection.ts` | Opens the DB handle, runs migrations | `openDatabase(path?: string): Database` | `db/migrations`, `db/schema` |
| `src/commands/add.ts` | Insert a task | `run(args: string[]): number` | `types`, `db/connection` |
| `src/commands/list.ts` | Query and render tasks | `run(args: string[]): number` | `types`, `db/connection` |
| `src/commands/done.ts` | Mark a task complete | `run(args: string[]): number` | `types`, `db/connection` |
| `src/commands/delete.ts` | Delete a task by id | `run(args: string[]): number` | `types`, `db/connection` |
| `src/cli.ts` | Route argv to a command handler | `runCli(argv: string[]): Promise<number>` | all `commands/*` |
| `src/index.ts` | Binary entry point (hashbang) | — (executable) | `cli` |

Each command module exports a single `run(args: string[]): number` function returning a POSIX-style exit code. This uniform signature is what lets `cli.ts` route generically.

---

## Data Schema

### `tasks` table — DDL

Column names below match the domain model exactly: `id`, `title`, `completed`, `createdAt`, `completedAt`.

```sql
-- Enable WAL mode for read-while-write concurrency.
-- [CEO Condition 2 — Performance]
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS tasks (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT    NOT NULL,
  completed   INTEGER NOT NULL DEFAULT 0 CHECK (completed IN (0, 1)),
  createdAt   TEXT    NOT NULL,     -- ISO 8601 timestamp
  completedAt TEXT             -- ISO 8601 timestamp, nullable
);

-- Partial filter index to keep `list` (pending only) fast.
-- [CEO Condition 2 — Performance]
CREATE INDEX IF NOT EXISTS idx_tasks_completed
  ON tasks (completed);

-- Schema version row, used by the idempotent migration runner.
CREATE TABLE IF NOT EXISTS schema_version (
  version INTEGER PRIMARY KEY
);
```

### Field definitions

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | INTEGER | Yes | autoincrement | Primary key |
| `title` | TEXT | Yes | — | Task title; no length cap at the DB layer |
| `completed` | INTEGER (0/1) | Yes | 0 | Boolean flag |
| `createdAt` | TEXT (ISO 8601) | Yes | now() at insert | When the task was added |
| `completedAt` | TEXT (ISO 8601) | No | NULL | Set when `completed` transitions 0 → 1 |

Timestamps are stored as ISO 8601 TEXT (see Decisions Log for rationale).

---

## Message Flow

Primary use case — `acme-todo add "buy milk"`:

```
Actor / Source          Action                              Result
─────────────────────────────────────────────────────────────────────────────
USER               →   acme-todo add "buy milk"        →   process starts
src/index.ts       →   awaits runCli(argv)             →   owns process.exit
src/cli.ts         →   routes "add" to commands/add    →   handler invoked
commands/add.ts    →   validates title, opens DB       →   migrated handle
db/migrations.ts   →   runMigrations() (idempotent)    →   schema current
SQLite (WAL)       →   INSERT via bound parameters     →   new row, id returned
commands/add.ts    →   formats success string          →   "Added task #7: ..."
src/index.ts       →   process.exit(0)                 →   shell prompt back
```

`list`, `done`, and `delete` follow the identical shape; only the SQL statement and the stdout formatting differ.

---

## State Management

There is no in-process state layer (no store library, no caches): every invocation is a fresh process, and the SQLite file is the single source of truth. "State management" for M1 is therefore the persistence contract below plus the exit-code contract in Error Handling.

### State Storage

| State Field | Type | Persisted | Owner Module |
|-------------|------|-----------|-------------|
| `tasks` rows (`id`, `title`, `completed`, `createdAt`, `completedAt`) | SQLite table | Yes | `src/db/` |
| `schema_version` | SQLite table (single row) | Yes | `src/db/migrations.ts` |
| Parsed command + flags | `ParsedCommand` (in-memory) | No | `src/cli.ts` |
| Resolved DB path | `string` (in-memory, from `ACME_TODO_DB` or homedir) | No | `src/db/connection.ts` |

---

## Migration Strategy

`src/db/migrations.ts` exposes a single function:

```ts
export function runMigrations(db: Database): void
```

The runner:

1. Creates `schema_version` if it does not exist.
2. Reads the current `version` (defaults to 0 for a fresh DB).
3. Iterates a static `SCHEMA_STATEMENTS` array indexed by version.
4. For each statement with index > current, executes it inside a single `BEGIN IMMEDIATE` / `COMMIT` transaction and updates `schema_version` in the same transaction.
5. On exception, rolls back and rethrows.

Migrations are therefore:
- **Idempotent** — running twice is a no-op because `schema_version` gates the loop.
- **Atomic** — partial migrations cannot be observed by a subsequent connection.
- **Append-only** — M1 ships version 1 (the `tasks` table, WAL pragma, index, and `schema_version` table). Later milestones append to the array and bump the constant `SCHEMA_VERSION`.

The WAL pragma is set on every connection open (it is session-level in SQLite but persists once applied to the file). The `idx_tasks_completed` index is part of the version-1 migration statement set, satisfying CEO Approval Condition 2.

---

## Error Handling

Command handlers return a numeric exit code. Conventions:

| Exit code | Meaning | Example |
|-----------|---------|---------|
| `0` | Success | `add` inserted a row |
| `1` | User error | Missing argument, malformed id, unknown command |
| `2` | Unknown / internal error | I/O error, corrupt DB, unhandled exception |
| `3` | Task not found | `done 99` or `delete 99` when id does not exist |

Every command wraps its body in a `try`/`catch`. Caught `UserError` maps to exit 1; caught `NotFoundError` maps to exit 3; any other thrown value falls through to exit 2, with the message written to `stderr` as `acme-todo: <message>`.

**First-run resilience (CEO Condition 3).** `src/commands/list.ts` must not throw when the database file does not yet exist. Because every command calls `openDatabase()` and `openDatabase` unconditionally calls `runMigrations` after opening the handle, an invocation like `acme-todo list` on a machine with no prior state will transparently create `~/.acme-todo/tasks.db`, run migrations, and print the empty header — never a stack trace. This behavior is called out explicitly in the `list` command's test plan.

---

## Concurrency

Acme Todo is a single-user CLI; there is no server process and no long-lived handle. Each invocation opens the DB, runs one statement, and closes. Still, WAL mode (enabled by migrations) provides two benefits:

1. **Read-while-write.** If the user pipes `acme-todo list` while another shell runs `acme-todo add ...`, the reader sees a consistent snapshot without blocking the writer.
2. **Crash safety.** WAL's checkpointing behavior is more robust against partial writes than the default rollback journal.

No cross-process locking is implemented. SQLite's file-level locking is sufficient for the expected usage pattern (one interactive user, occasional concurrent shells). If we later ship a daemon mode, this section must be revisited.

---

## Integration Points

| External System | Relationship | Data Exchanged | Direction |
|----------------|-------------|---------------|----------|
| Terminal (stdout/stderr) | Consumes command output per the UI spec's formats | Formatted text rows, error strings, exit codes | System → shell |
| SQLite file (`~/.acme-todo/tasks.db`) | Reads/writes all task state | `tasks` and `schema_version` rows | Bidirectional |
| Filesystem | Creates the parent directory on first run | `~/.acme-todo/` directory | System → FS |
| Environment (`ACME_TODO_DB`) | Overrides the DB file location | Absolute path string | Env → System |

There are no network integrations, background services, or other processes in M1.

---

## Performance Budget

| Metric | Target | Notes |
|--------|--------|-------|
| Command latency (cold start) | < 100 ms | Includes Node startup + migration idempotency check |
| Command latency (warm) | < 50 ms | Second invocation in the same shell session |
| `list` latency at 1,000 rows | < 100 ms | Must use `idx_tasks_completed`, not a table scan (CEO Condition 2) |
| DB file size at 1,000 rows | < 1 MB | ISO-8601 TEXT timestamps accepted within this budget |

The Performance Agent owns the live Current/Status tracking for these targets in `artifacts/AGENT_STATE.md` → performance section.

---

## Testing Strategy

### Integration test scenarios (Vitest + a tmpdir DB)

| # | Scenario | Modules | Expected outcome |
|---|----------|---------|------------------|
| 1 | `add "buy milk"` then `list` | commands/add, commands/list, db | One row printed, pending |
| 2 | `list` on a brand-new machine | commands/list, db | Migrations run on first call, no throw, empty header printed |
| 3 | `done <id>` then `list --all` | commands/done, commands/list, db | Task shows `done` with `completedAt` set |
| 4 | `delete <id>` twice | commands/delete, db | First call exit 0, second call exit 3 |
| 5 | `done 999` on empty DB | commands/done, db | Exit 3, stderr: "Task 999 not found" |
| 6 | Parameterized binding against `'; DROP TABLE tasks; --` | commands/add, db | Row inserted verbatim, table intact |

### Manual test checklist

- [ ] First invocation on a clean `$HOME` creates `~/.acme-todo/tasks.db` and succeeds
- [ ] `ACME_TODO_DB=/tmp/other.db acme-todo add test` uses the override path
- [ ] `acme-todo list` piped to `head` produces plain text
- [ ] Two concurrent shells (`add` + `list`) do not deadlock

---

## Decisions Log

| Date | Decision | Alternatives Considered | Rationale | Impact |
|------|----------|--------------------------|-----------|--------|
| 2026-04-08 | Use `better-sqlite3` as the SQLite driver | `node:sqlite` (Node 22 experimental), `sql.js` (WASM), `sqlite3` (async) | Synchronous API fits the CLI model (no event-loop gymnastics), zero runtime deps after install, battle-tested, fastest in benchmarks | Commands stay linear and easy to reason about; prebuilt binaries need to cover macOS/Linux/Windows — verified for Node 20+ |
| 2026-04-08 | Custom argv parser in `cli.ts` instead of a library | `commander`, `yargs`, `meow`, `sade` | Five commands and a `--help` do not justify a dependency; parser is ~30 LOC; zero surface for supply-chain risk | CLI stays dependency-light; if we add > 10 commands we will revisit |
| 2026-04-08 | Store timestamps as ISO 8601 TEXT, not INTEGER unix seconds | INTEGER epoch, REAL Julian day | Human-debuggable when inspecting the DB by hand; sortable lexically; round-trips through `Date.toISOString()` without precision loss | Slightly larger rows (~20 bytes vs 8); negligible at expected scale |
| 2026-04-08 | Enable WAL mode in migrations and add `idx_tasks_completed` | Default rollback journal; no index (table-scan acceptable at small N) | Required by CEO Approval Condition 2; WAL also gives us read-while-write for free; index keeps `list` (filter by `completed = 0`) fast as history grows | Migration runner must set the pragma; adds one B-tree to maintain on writes |
| 2026-04-08 | Commands return exit codes; `index.ts` owns `process.exit` | Commands call `process.exit` directly | Keeps command functions pure and unit-testable; lets integration tests assert on return values without spawning subprocesses | One extra indirection in `index.ts`; worth it for test ergonomics |

---

## CEO Approval Conditions Traceability

| # | Condition | Where addressed |
|---|-----------|-----------------|
| 1 | All SQL queries use parameterized bindings | Every command uses `db.prepare(...).run(...)` with positional parameters; no string concatenation. Enforced by integration test #6. |
| 2 | WAL mode enabled + index on `completed` | Data Schema section DDL; `SCHEMA_STATEMENTS[1]` in `db/schema.ts` |
| 3 | `list` handles missing DB via first-run migration | Error Handling section; `openDatabase` always calls `runMigrations`; integration test #2 |

---

## Acceptance Checklist

- [ ] All modules implemented per their file list in the Modules table
- [ ] `tasks` table DDL matches the schema section exactly (column names, types, defaults)
- [ ] WAL pragma and `idx_tasks_completed` appear in the M1 migration statement set
- [ ] All SQL executes via parameterized bindings (no template-string SQL)
- [ ] `list` on a fresh machine runs migrations and prints the empty header
- [ ] Exit codes conform to the table in Error Handling
- [ ] All six integration test scenarios pass under Vitest
- [ ] No TypeScript strict-mode errors
- [ ] No ESLint errors

---

## CEO Verdict

Gated by the CEO planning review — see `artifacts/reviews/ceo-review-milestone-1.md`: **APPROVED WITH CONDITIONS** (2026-04-08). Conditions 1–3 (traceability table above) were verified by Reviewer and Product before M1 sign-off on 2026-04-10.

---

_Last updated: 2026-04-08_
