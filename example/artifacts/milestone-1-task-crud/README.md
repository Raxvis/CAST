# Acme Todo — M1: Task CRUD + SQLite Persistence

**Status**: Complete with Deferrals (CEO: APPROVED WITH CONDITIONS 2026-04-08; completed 2026-04-10)


## Header

| Field | Value |
|-------|-------|
| **Milestone** | M1: Task CRUD + SQLite Persistence |
| **Slug** | `task-crud` |
| **Planned** | 2026-04-08 |
| **Target Completion** | 2026-04-10 |
| **Owner** | Product |
| **Requirements Reference** | `docs/PRD.md` §3 (Core CRUD), §5 (Persistence) |

---

## Goal

Ship the first usable slice of Acme Todo: a CLI that can add, list, complete, and
delete tasks, with state persisted in a local SQLite database. After this milestone,
a user can run `acme add "buy milk"`, `acme list`, `acme done 1`,
and `acme delete 1` from any Node 20+ shell and have their tasks survive
across invocations.

---

## Why This Matters

Without persistence-backed CRUD there is no product — every later milestone
(error signaling in M2, tags and due dates in M3+) edits or extends task rows
that this milestone teaches the CLI to create, read, and mutate. Shipping the
four commands against a real SQLite file also settles the two decisions with
the highest cost-of-change (the on-disk schema and the argv dispatch shape)
while the codebase is still small enough to redo them cheaply. Finally, a solo
developer needs a usable tool on day one: after M1, Acme Todo is something its
own author can adopt for daily task tracking, which is the fastest feedback
loop available.

---

## Success Metrics

- User can create, list, complete, and delete tasks from the CLI without editing
  files by hand.
- Task state persists across CLI invocations via SQLite at `~/.acme-todo/tasks.db`
  (overridable via `ACME_TODO_DB`).
- All 5 planned tasks (T-1 through T-5) land with passing Vitest suites.
- First-run experience works: running `acme list` on a fresh machine creates
  the database and prints an empty list rather than crashing.
- `pnpm typecheck` and `pnpm test` both pass clean on macOS, Linux, and Windows
  (Node 20+).

---

## In Scope

- `Task` domain type with fields `id`, `title`, `completed`, `createdAt`, `completedAt`.
- SQLite schema and idempotent migration runner (`better-sqlite3`, WAL mode, index
  on `completed`).
- Four commands: `add`, `list`, `done`, `delete`.
- Minimal custom argv parser in `src/cli.ts` (no commander / yargs dependency).
- `--help` output and friendly error on unknown commands.
- `--all` flag on `list` to include completed tasks.
- Default DB path `~/.acme-todo/tasks.db`, overridable via `ACME_TODO_DB` env var.

---

## Out of Scope

- Task editing / renaming (deferred to M2).
- Due dates, priorities, tags, or projects (deferred to M3+).
- Sync, multi-device, or network storage.
- Interactive TUI or colored output beyond plain text columns.
- Shell completions, man pages, packaging for Homebrew / winget (deferred to release milestone).
- Importing from other todo tools.

---

## Dependencies and Risks

| Type | Item | Mitigation / Status |
|---|---|---|
| Dependency | `better-sqlite3` (native module) | Pinned in `package.json`; prebuilt binaries verified for Node 20+ on macOS/Linux/Windows |
| Dependency | Node.js 20+ and pnpm on the developer machine | Documented in `CLAUDE.md` Build & Test |
| Dependency | Architecture data-layer section and UI spec output formats | Both approved 2026-04-08: `architecture.md`, `ui.md` |
| Risk | SQLite file locking with concurrent shells on Windows | WAL mode (CEO Condition 2) allows read-while-write; accepted for a single-user CLI |
| Risk | First-run crash when the DB file does not exist yet | Migrations run on every invocation (CEO Condition 3); covered by regression tests |

No internal milestone dependencies — this is the first implementation milestone.

---

## Top-Level Acceptance Criteria

- [x] `pnpm build` produces a runnable CLI entrypoint.
- [x] `pnpm test` passes with coverage for all four commands and the migration runner.
- [x] `acme add "write tests"` prints the new task ID and exits 0.
- [x] `acme list` shows open tasks in the format `ID  TITLE  STATUS  CREATED`.
- [x] `acme list --all` includes completed tasks.
- [x] `acme done <id>` marks a task complete and sets `completedAt`.
- [x] `acme delete <id>` removes the row.
- [ ] `done` and `delete` both exit non-zero with a clear error if the id does not exist. — `delete` does; `done` does not (BUG-002, Deferred to M2)
- [x] First invocation against a missing database file succeeds (migrations run automatically).
- [x] All three CEO Approval Conditions verified (see below).

---

## Task Index

_One row per task file under `tasks/`. No status column — task status lives ONLY in each task file's Header._

| Task ID | Task Name | File | Dependencies |
|---------|-----------|------|--------------|
| T-1 | Task type, schema, migration runner | `tasks/task-01-data-layer.md` | None |
| T-2 | `add` command | `tasks/task-02-add-command.md` | T-1 |
| T-3 | `list` command | `tasks/task-03-list-command.md` | T-1 |
| T-4 | `done` + `delete` commands | `tasks/task-04-done-delete-commands.md` | T-1 |
| T-5 | CLI argument parser wiring | `tasks/task-05-cli-parser.md` | T-2, T-3, T-4 |

Dependency graph: T-1 blocks T-2/T-3/T-4 (parallel), which all block T-5.

---

## CEO Approval Conditions

The CEO approved this milestone with three conditions (APPROVED WITH CONDITIONS,
2026-04-08); the rows below are transcribed from that review's Approval Conditions
table, `Verified By` included. Coder tracked each condition during engineering, and
Reviewer's Acceptance Criteria Check carried one line per condition a task's manifest
cited. Product confirmed the evidence for all three while writing `reviews/close.md`
on 2026-04-10 and flipped each row to Verified. Tasks a condition names carry a
`../README.md § CEO Approval Conditions` row in their Context Manifest.

| # | Condition | Source | Verified By | Verified At | Status |
|---|-----------|--------|-------------|-------------|--------|
| 1 | All SQL queries use parameterized bindings — no string concatenation into SQL (Security) | `reviews/ceo.md` | Reviewer | 2026-04-10 | Verified |
| 2 | WAL mode enabled in the migration + index on the `completed` column (Performance) | `reviews/ceo.md` | Reviewer | 2026-04-10 | Verified |
| 3 | `list` handles a missing database file by running migrations on first invocation (Error handling) | `reviews/ceo.md` | Product | 2026-04-10 | Verified |

See `reviews/ceo.md` for the full verdict.

---

## Estimated Effort

| Task | Rough Size |
|------|------------|
| T-1 Data layer + migrations | M (half day) |
| T-2 `add` command | S |
| T-3 `list` command | S-M (condition 3 adds first-run handling) |
| T-4 `done` + `delete` commands | S |
| T-5 CLI parser wiring | S |
| **Total** | ~1.5 engineer-days |

---

## References

- **Task files**: `tasks/`
- **CEO Review**: `reviews/ceo.md`
- **Architecture**: `architecture.md`
- **UI Spec**: `ui.md`
- **PRD**: `docs/PRD.md`

---

_Last updated: 2026-04-10_
