# Acme Todo — Project State

Written by the orchestrating skill (`/agent-plan`, `/agent-code`, `/agent-task`) at checkpoints. **Agents do not read this file** — a stage's read set is its task file, that file's Context Manifest, and the latest handoff entry's "Read next" (`docs/STAGE_CONTRACT.md`).

---

## Decisions Log

Decisions worth carrying past the milestone that produced them.

| Date | Agent | Decision | Alternatives considered | Rationale |
|---|---|---|---|---|
| 2026-04-08 | architect | Hand-written argv parser in `src/cli.ts` — no CLI framework | `commander`, `yargs` | Four subcommands, `--help`, and one flag. A framework is ~40 lines saved against a permanent dependency, and `docs/PRD.md` sets minimal dependency surface as a constraint. |
| 2026-04-08 | architect | `better-sqlite3` (synchronous) over `node:sqlite` or an async driver | `node:sqlite` (Node 22+ only), `sqlite3` (async) | Node 20 is the stated floor, and a CLI process that exits after one command gains nothing from async I/O — synchronous code is simpler to test and to reason about. |
| 2026-04-08 | architect | Schema versioned via a one-row `schema_version` table, migrations idempotent per invocation | `PRAGMA user_version`, one-time setup command | A setup command is a first-run failure mode. The pragma holds a bare integer with nowhere to record the per-migration metadata later milestones will want, while a one-row table read is just as cheap on the no-op path — which the Risk review's P2 finding then made a requirement. |
| 2026-04-09 | coder | BUG-001 fixed by extracting `ensureMigrations(db)` called at every command entry path | (a) run migrations in `list` too, (b) central `ensureMigrations` at every entry, (c) a first-run setup command | (a) leaves the next new command with the same bug; (c) reintroduces the first-run failure mode the design already rejected. (b) makes the class of bug impossible rather than fixing one instance. |
| 2026-04-10 | product | BUG-002 (`done` on a missing id exits 0 silently) triaged Low, Deferred to M2 | Fix Now | Filed by the UI agent at the milestone-completion UX review. It does not violate any M1 acceptance criterion, and the fix belongs with M2's error-signalling work rather than as a one-off. Re-triaged at M2 `/agent-plan` Stage 1. |

---

## Milestone Progress

| Milestone | Status | Tasks (done/total) | Bugs open | Closed |
|---|---|---|---|---|
| M1: Task CRUD + SQLite Persistence | Complete with Deferrals | 5/5 | 1 (BUG-002, Deferred) | 2026-04-10 |
| M2: Tags, priorities, search | Planned | 0/0 | — | — |

---

## Performance Budget Tracking

One row per metric in `milestone-1-task-crud/architecture.md` § Performance Budget, with the same target. Current values measured at the M1 risk implementation review (`reviews/risk-impl.md`, CEO agent) and transcribed by the orchestrator.

| Metric | Target | Current | Status | Measured |
|---|---|---|---|---|
| Warm `list` latency @ 100 tasks | < 100 ms | 31ms (p50), 38ms (p95) | Pass | 2026-04-10 |
| Warm `add` latency (migration no-op path) | < 100 ms | 27ms (p50) | Pass | 2026-04-10 |
| Cold first run (creates DB + schema) | not budgeted | 94ms | Recorded | 2026-04-10 |
| Test suite runtime | < 10 s | 4.2s | Pass | 2026-04-10 |
| DB file size at 1,000 rows | < 1 MB | — | Not measured | — |

---

## Open Questions

| Date | Raised by | Question | Blocking |
|---|---|---|---|
| _(none open)_ | | | |
