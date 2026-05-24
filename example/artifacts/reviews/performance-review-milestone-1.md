# Acme Todo — Performance Review: Milestone 1 (Task CRUD + SQLite Persistence)

## Revision History

| Rev | Date | Agent | Change |
|-----|------|-------|--------|
| v1 | 2026-04-08 | performance | Initial performance review |

---

**Reviewer**: Performance Agent
**Model**: claude-sonnet-4-6
**Date**: 2026-04-08
**Stage**: `/agent-plan` Stage 3b
**Inputs Reviewed**:
- Milestone: `artifacts/milestones/milestone-1-task-crud.md`
- Architecture: `artifacts/architecture/arch-milestone-1.md`

---

## Summary

Two findings filed against the Milestone 1 architecture. One Medium (WAL mode not specified, reads block writes) and one Low (missing index on `completed` column forces a full table scan for the default `list` path). Both remediations are single-line PRAGMA or DDL additions to the initial migration. Both are escalated to the CEO and rolled into a single Approval Condition covering WAL mode and the index.

---

## Performance Budget Tracking

_Targets defined by Architecture in `artifacts/architecture/arch-milestone-1.md` → Performance Budgets. Performance Agent owns Current and Status._

| Metric | Target | Current | Status | Notes |
|---|---|---|---|---|
| Command latency (cold start) | < 100 ms | — | Pending | Measured after T-5 wiring |
| Command latency (warm) | < 50 ms | — | Pending | Measured after T-5 wiring |
| `list` latency (1k rows) | < 100 ms | — | Pending | Benchmark written in Tester phase |
| DB file size (1k rows) | < 1 MB | — | Pending | Verified in Tester phase |

---

## Findings

| Finding | Metric Affected | Impact | Status | Date | Notes |
|---|---|---|---|---|---|
| 1. SQLite WAL mode not enabled | Command latency | Medium | Remediation required | 2026-04-08 | CEO Approval Condition 2 |
| 2. No index on `completed` column | `list` latency (large histories) | Low | Remediation required | 2026-04-08 | CEO Approval Condition 2 |

---

### Finding 1 — SQLite WAL Mode Not Enabled (Budget Violation)

- **Severity**: Medium (budget violation risk)
- **Metric Affected**: Command latency
- **Description**: The proposed schema in `src/db/schema.ts` does not specify a journal mode, so SQLite will fall back to the default rollback journal. In rollback journal mode, readers are blocked during a write and writers are blocked during a read. For a single-user CLI the blast radius is small — the user is unlikely to issue two commands concurrently — but `better-sqlite3` serializes on the file handle even within a single process, and the expected command latency budget of sub-100ms from `docs/CONCEPT.md` could be violated on databases with large histories where the rollback journal fsync is non-trivial.
- **Expected Impact**: WAL mode typically yields 2–10x throughput on mixed read/write workloads and eliminates the reader-blocks-writer condition. For Acme Todo's workload this primarily means shorter tail latencies on `add` and `done` commands when the DB has grown past a few hundred rows.
- **Remediation**: Add `PRAGMA journal_mode = WAL;` to the initial migration in `src/db/migrations.ts`. This is a one-time setting; SQLite persists it in the database header.
- **Verification**: Reviewer inspects the migration during T-1 code review. Tester verifies via a runtime query (`PRAGMA journal_mode;` returns `wal`).
- **Status**: Remediation enforced via CEO Approval Condition 2. Verified by Reviewer during code review.

---

### Finding 2 — Missing Index on `completed` Column

- **Severity**: Low
- **Metric Affected**: `list` command latency on large histories
- **Description**: The default `list` command (without `--all`) filters on `completed = 0`. Without an index on the `completed` column, SQLite performs a full table scan every invocation. For a small hobby todo list this is fine (<1k rows completes in well under 1ms), but as a best practice and to keep the hot path indexed before the DB grows, an index should be added up front. Adding it later requires a migration and costs the same either way — the lift now is trivial.
- **Expected Impact**: On a database with 10k rows and mostly-completed tasks, an indexed filter reduces `list` latency from ~5ms to <1ms. The larger benefit is preventing future surprise if a user pipes a large task import into the CLI.
- **Remediation**: Add `CREATE INDEX idx_tasks_completed ON tasks(completed);` to the initial migration in `src/db/migrations.ts`, immediately after the `CREATE TABLE tasks` statement.
- **Verification**: Reviewer inspects the migration during T-1 code review. Tester adds a benchmark over 10k rows to confirm the index is used (via `EXPLAIN QUERY PLAN`).
- **Status**: Remediation enforced via CEO Approval Condition 2. Verified by Reviewer.

---

## Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-08 | Bundle WAL mode + index into a single CEO Approval Condition | Both remediations live in the same migration file and are inspected together | One checkbox for Reviewer |
| 2026-04-08 | Defer benchmark suite to Tester phase (not T-1) | Benchmarks require T-5 CLI wiring to be exercised end-to-end | Budget tracking populated after M1 close |

---

## Notes

- No hot paths beyond the four command handlers exist in Milestone 1. No rendering, no tick loop, no network I/O.
- `better-sqlite3` is synchronous and already the correct choice for a short-lived CLI process; no async overhead to optimize.
- Startup cost is dominated by `require('better-sqlite3')` and the one-time migration check. Both are out of scope for M1 optimization.
