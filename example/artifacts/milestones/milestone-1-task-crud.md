# Acme Todo — M1: Task CRUD + SQLite Persistence

**Status**: Planning approved (CEO: APPROVED WITH CONDITIONS)

## Revision History

| Rev | Date | Agent | Change |
|-----|------|-------|--------|
| v1 | 2026-04-08 | product | Initial milestone definition |

---

## Header

| Field | Value |
|-------|-------|
| **Milestone** | M1: Task CRUD + SQLite Persistence |
| **Slug** | `task-crud` |
| **Planned** | 2026-04-08 |
| **Target Completion** | 2026-04-10 |
| **Owner** | Product |
| **Requirements Reference** | `artifacts/prd.md` §3 (Core CRUD), §5 (Persistence) |

---

## Goal

Ship the first usable slice of Acme Todo: a CLI that can add, list, complete, and
delete tasks, with state persisted in a local SQLite database. After this milestone,
a user can run `acme-todo add "buy milk"`, `acme-todo list`, `acme-todo done 1`,
and `acme-todo delete 1` from any Node 20+ shell and have their tasks survive
across invocations.

---

## Success Metrics

- User can create, list, complete, and delete tasks from the CLI without editing
  files by hand.
- Task state persists across CLI invocations via SQLite at `~/.acme-todo/tasks.db`
  (overridable via `ACME_TODO_DB`).
- All 5 planned tasks (T-1 through T-5) land with passing Vitest suites.
- First-run experience works: running `acme-todo list` on a fresh machine creates
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

## Dependencies

- **External**: `better-sqlite3` (native module, pnpm-installed), Node.js 20+, pnpm.
- **Internal**: None — this is the first implementation milestone.
- **Docs**: `artifacts/architecture.md` (data layer section), `artifacts/ui-spec.md`
  (CLI output formats).

---

## Top-Level Acceptance Criteria

- [ ] `pnpm build` produces a runnable CLI entrypoint.
- [ ] `pnpm test` passes with coverage for all four commands and the migration runner.
- [ ] `acme-todo add "write tests"` prints the new task ID and exits 0.
- [ ] `acme-todo list` shows open tasks in the format `ID  TITLE  STATUS  CREATED`.
- [ ] `acme-todo list --all` includes completed tasks.
- [ ] `acme-todo done <id>` marks a task complete and sets `completedAt`.
- [ ] `acme-todo delete <id>` removes the row.
- [ ] `done` and `delete` both exit non-zero with a clear error if the id does not exist.
- [ ] First invocation against a missing database file succeeds (migrations run automatically).
- [ ] All three CEO Approval Conditions verified (see below).

---

## CEO Approval Conditions

The CEO approved this milestone with three conditions. All three must be verified
before the milestone can be marked Complete.

1. **Security** — All SQL queries must use parameterized bindings (no string
   concatenation into SQL). Verified by Reviewer during code review.
2. **Performance** — SQLite WAL mode must be enabled in the migration, and an
   index must be created on the `completed` column. Verified by Reviewer inspecting
   the migration.
3. **Error handling** — `list` must handle a missing database file by running
   migrations on first invocation rather than throwing an error. Verified by
   Product during validation.

See `artifacts/reviews/ceo-review-milestone-1.md` for the full verdict.

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

- **Task Breakdown**: `artifacts/milestones/milestone-1-task-crud-tasks.md`
- **CEO Review**: `artifacts/reviews/ceo-review-milestone-1.md`
- **Architecture**: `artifacts/architecture.md`
- **UI Spec**: `artifacts/ui-spec.md`
- **PRD**: `artifacts/prd.md`

---

_Last updated: 2026-04-08_
