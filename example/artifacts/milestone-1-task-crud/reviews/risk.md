# Risk Review — M1: Task CRUD + SQLite Persistence

**Date**: 2026-04-08
**Reviewer**: CEO Agent — risk lenses (claude-opus-5, `/agent-plan` Stage 3)
**Inputs**: `../README.md`, `../architecture.md`, `../ui.md`

---

## Security

| # | Finding | Category | Severity | Module / Path | Remediation |
|---|---|---|---|---|---|
| S1 | The architecture's example `add` insert builds SQL by string interpolation of the task title. A title containing `'` breaks the statement; a crafted title executes arbitrary SQL against the user's task database. | OWASP A03:2021 Injection | **High** | `architecture.md` § Module: db; `src/commands/add.ts` (planned) | Every statement goes through `better-sqlite3`'s `.prepare()` with bound parameters. No user value is ever concatenated into SQL. Applies to all four commands, not just `add`. |
| S2 | The database file is created with the process umask. On a shared machine the default may leave it group-readable. | CWE-732 Incorrect Permission Assignment | Low | `src/db/schema.ts` (planned) | Acceptable for v1 — the file lives under `~/.acme-todo/` and contains only the user's own task titles. Recorded, not blocking. |
| S3 | `ACME_TODO_DB` lets the user redirect the database path. This is intended, and the value is used as a path, never as SQL. | — | Informational | `src/db/schema.ts` (planned) | No action. Noted so a later reviewer does not re-flag it. |

**Dependencies reviewed**: `better-sqlite3` (synchronous SQLite bindings, widely used, no network surface), `tsx` and `vitest` (dev-only). No finding.

## Performance

| # | Finding | Budget / Metric | Severity | Module / Path | Remediation |
|---|---|---|---|---|---|
| P1 | `list` filters on `completed` with no index. At the PRD's 100-task target this is immaterial, but the budget is stated as "warm `list` under 100ms" and the query is the only one that scales with task count. | Warm `list` < 100ms @ 100 tasks | Medium | `architecture.md` § Data Schema | Create `idx_tasks_completed` in the migration. Cheap now, and it is the difference between a table scan and an index seek once a user accumulates a few thousand rows. |
| P2 | Migrations run on every command invocation. Idempotent, but if implemented as "run every statement and ignore errors" it adds startup cost to every command in a CLI whose entire budget is 100ms. | Warm command latency < 100ms | Medium | `architecture.md` § Module: db | Gate on the `schema_version` table; the no-op path must be a single version read, not a series of caught exceptions. |
| P3 | WAL mode is specified. Correct for durability under `kill -9` and it also removes reader/writer contention. | — | Informational | `architecture.md` § Module: db | No action. |

**Budget source**: `architecture.md` § Performance Budget, itself derived from `docs/PRD.md` § Non-Functional Requirements.

---

## Flags

**Security implementation review required**: Yes
**Performance measured check required**: Yes

S1 is a High injection finding whose remediation is a code-level contract — "every query is parameterized" is only verifiable against the diff, not the plan. Both performance budgets are numeric and the milestone exercises them, so they get measured rather than argued.
