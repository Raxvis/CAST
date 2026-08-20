# Acme Todo — M1: Task CRUD + SQLite Persistence Close Record


## Header

| Field | Value |
|-------|-------|
| **Milestone** | M1: Task CRUD + SQLite Persistence |
| **Close Date** | 2026-04-10 |
| **Author** | Product Agent |
| **Status** | Complete with Deferrals |

---

## Summary

M1 shipped the first usable slice of Acme Todo. All five planned tasks (T-1 through T-5) landed and the CLI can now add, list, complete, and delete tasks against a SQLite database at `~/.acme-todo/tasks.db` (or the path in `ACME_TODO_DB`). All three CEO Approval Conditions were verified, and the full Vitest suite is green (42 tests, 100% line coverage on `src/commands/`). One bug (BUG-001, first-run crash) was caught and fixed during implementation; one bug (BUG-002, `done` silent success on a missing id) was discovered during milestone smoke testing, triaged Low, and re-triaged Deferred into M2 at this checkpoint — so the milestone closes as "Complete with Deferrals" rather than clean.

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
|---|------|----------------------|----------|
| 1 | BUG-002: `done <id>` silently succeeds when the given id does not exist | Discovered during milestone smoke testing after freeze; low severity; not a blocker for M1's acceptance criteria. Fix belongs alongside a broader "id-not-found" helper in the data layer. | M2 |

Deferred is a held-open state, not terminal. Product re-triaged BUG-002 at this milestone-completion checkpoint and held it Deferred into M2 with an updated rationale; it stays open in `artifacts/BUGS.md` and is re-triaged again at the M2 `/agent-plan` Stage 1. This deferral is why the Header Status above reads "Complete with Deferrals".

---

## Per-Task Validation

| Task | Closed Via | Reviewer Evidence | Disposition | Notes |
|------|-----------|-------------------|-------------|-------|
| T-1 — Task type, SQLite schema, migration runner | Step 3a | Handoff entry #3 | APPROVED | All 8 criteria + Condition lines 1 (parameterized SQL) and 2 (WAL + index) Met with evidence; closed without a Product spawn. |
| T-2 — `add` command | Step 3a | Handoff entry #3 | APPROVED | All 6 criteria + Condition line 1 Met with evidence on the insert path; closed without a Product spawn. |
| T-3 — `list` command | Step 3a | Handoff entry #6 | APPROVED | All 7 criteria + Condition line 3 Met with evidence after the BUG-001 fix (loop 1/3). Red→green evidence verified against `9d4b1c7` (fail) → `a8f3d12` (pass). BUG-001 advanced Fixed → Verified → Closed at this checkpoint. |
| T-4 — `done` and `delete` commands | Step 3b | Handoff entry #3 | APPROVED WITH NOTES | Criterion 6 (missing-id coverage for `done`) disposed as in-scope for M2, not this task — held as written. BUG-002 was filed during milestone smoke testing (not against a T-4 criterion) and triaged Low / Deferred. |
| T-5 — CLI argument parser wiring | Step 3a | Handoff entry #3 | APPROVED | All 7 criteria Met with evidence; migration-before-dispatch guard confirmed (Condition 3 regression-proof). Closing this task at Step 3a triggered the milestone-completion checkpoint; reviewed here per the batching Step 3a enables. |

---

## Milestone Validation Checklist

### Functionality

| # | Requirement | Acceptance Criteria | Status | Notes |
|---|-------------|--------------------|----|-------|
| F1 | Add tasks | `acme-todo add "buy milk"` prints the new task ID and exits 0; titles preserved verbatim | Pass | |
| F2 | List tasks | `acme-todo list` prints open tasks as `ID  TITLE  STATUS  CREATED`; `--all` includes completed | Pass | |
| F3 | Complete tasks | `acme-todo done <id>` sets `completed` and `completedAt` | Pass | Happy path only — see F5 |
| F4 | Delete tasks | `acme-todo delete <id>` removes the row; errors non-zero on missing ID | Pass | |
| F5 | Missing-ID signaling | `done` and `delete` both exit non-zero with a clear error when the ID does not exist | Fail | `done` exits 0 silently — BUG-002, re-triaged and held Deferred into M2 |
| F6 | First-run experience | First invocation against a missing database file runs migrations and succeeds | Pass | Approval Condition 3; BUG-001 regression test in place |
| F7 | Persistence | Task state survives across CLI invocations via SQLite at `~/.acme-todo/tasks.db` (or `ACME_TODO_DB`) | Pass | |

### Quality

| # | Criterion | Acceptance Criteria | Status | Notes |
|---|-----------|--------------------|----|-------|
| Q1 | Code quality | `pnpm typecheck` clean; no linter errors; parameterized SQL throughout (Approval Condition 1) | Pass | Verified by Reviewer at every merge |
| Q2 | Performance | Warm `list` under 100 ms on a 100-task DB; WAL + `idx_tasks_completed` present (Approval Condition 2) | Pass | Measured 31 ms (p50) / 38 ms (p95) warm, 94 ms cold first run — see `reviews/risk-impl.md` and the Performance Budget Tracking table in `artifacts/AGENT_STATE.md` |
| Q3 | Test coverage | Full Vitest suite green; logic coverage at or above the 80% target | Pass | 42 tests passing; 100% line coverage on `src/commands/` |

### Critical Path Testing

| # | Scenario | Steps | Expected | Actual | Status |
|---|----------|-------|----------|--------|--------|
| T1 | Fresh-install first run | `rm -rf ~/.acme-todo`, then `acme-todo list` | DB created, migrations run, empty list, exit 0 | As expected | Pass |
| T2 | Full CRUD cycle | `add "x"` → `list` → `done 1` → `list --all` → `delete 1` | Each step succeeds; state visible at every stage | As expected | Pass |
| T3 | Missing-ID signaling | `add "x"`, then `done 999` | stderr error, non-zero exit | No output, exit 0 | Fail |

T3's failure is BUG-002 (Low). Product accepted it as non-blocking for M1 and held it Deferred at re-triage; the scenario stays on the regression checklist until the M2 fix lands.

---

## Regression Testing

### Data Layer & First Run — Regression Checklist

- [x] Migrations run on a fresh DB file (delete `~/.acme-todo/` and run any command)
- [x] `acme-todo list` on a machine with no prior state prints the empty-state output and exits 0
- [x] `PRAGMA journal_mode;` returns `wal` after a migration run
- [x] `EXPLAIN QUERY PLAN` for the open-tasks query uses `idx_tasks_completed`

### Command Surface — Regression Checklist

- [x] `add` → `list` → `done` → `delete` cycle works end to end through the real entrypoint
- [x] `delete` on a non-existent ID exits non-zero with a clear stderr message
- [ ] `done` on a non-existent ID signals failure (blocked on BUG-002 — currently silent; verify when the M2 fix lands)

---

## Known Issues

| ID | Description | Severity | Owner | Tracked In |
|----|-------------|----------|-------|------------|
| BUG-002 | `done <id>` silently succeeds when the given id does not exist; should print an error and exit non-zero. Re-triaged by Product at this checkpoint and held Deferred into M2. | Low | Coder | `BUGS.md` / T-4 |

BUG-001 (`list` crashed with "no such table: tasks" on first invocation) was fixed in-milestone via CEO Condition 3 and closed at this checkpoint — it is not a known issue.

---

## Retrospective

### Estimated vs Actual Effort

- **Estimated**: ~1.5 engineer-days — from the "Estimated Effort" field in the milestone definition (`artifacts/milestone-1-task-crud/README.md`)
- **Actual**: 3 sessions across 3 calendar days, 2026-04-08 to 2026-04-10 — from the session dates for this milestone in `artifacts/STANDUP.md` (first to last session)
- **Delta**: The engineering work itself (2026-04-09 and 2026-04-10) matched the ~1.5-day estimate; the third calendar day is the planning session, which the estimate deliberately excluded. The only unplanned engineering cost was the BUG-001 fix in T-3, which stayed inside the same session (loop 1/3, no escalation).

### What Went Well

- CEO Approval Condition 3 was written defensively during planning and caught BUG-001 during T-3 implementation — the fix landed in the same session instead of becoming a post-release hotfix.
- The Defect routing on BUG-001 worked end to end in one session: Coder handed off the honest failure, Reviewer classified it and filed the bug, Product triaged Fix Now, and Coder investigated (alternatives considered recorded in the bug file) and shipped the fix with red→green proof (`a8f3d12`).
- T-1 shipping first as a hard dependency gate kept T-2/T-3/T-4 from colliding — the three parallel tasks touched only their own command files.
- The Docs Writer queue kept documentation current without a dedicated docs pass: all 4 queued `docs` entries drained in the single milestone-completion pass. The queue never approached the 10-entry overflow bound, so the milestone cost one Docs Writer invocation instead of one per task.

### What Didn't Go Well

- BUG-002 (`done` silently succeeds on a missing ID) should have been caught by T-4's acceptance criteria. The criteria required "error if ID not found" for `delete` but left the equivalent for `done` implicit; the gap surfaced only in manual smoke testing during the milestone-completion checkpoint.
- The migration runner's directory-creation step for `~/.acme-todo/` was added late, after manual testing on Linux — architecture review did not explicitly cover filesystem prerequisites.
- The performance budget table could not be populated until after T-5 landed, because the benchmark plan depended on end-to-end CLI wiring. Budget tracking was blind for most of the milestone.

### Process Issues

No process issues. Every handoff followed the pipeline loop; nothing was escalated to the user and no Context Manifest had to be patched mid-task.

### Metrics

| Metric | Value | Source |
|---|---|---|
| Tasks planned | 5 | Task Index in `artifacts/milestone-1-task-crud/README.md` (count of task files) |
| Tasks completed | 5 | Status fields across `artifacts/milestone-1-task-crud/tasks/task-*.md` |
| Tasks rejected by Product | 0 | Handoff Logs across `artifacts/milestone-1-task-crud/tasks/task-*.md` (Product → Coder return entries) — average rejections per task: 0 |
| Loop-backs, and what caused them | 1 | `Loop count` Headers across `tasks/task-*.md` — T-3 looped once (1/3) on BUG-001 (first-run crash, per its Handoff Log), triaged Fix Now, resolved in the same session |
| Escalations to the user | 0 | `blocker` entries in `artifacts/STANDUP.md` for this milestone — none recorded |
| Architecture doc revisions | 1 | `git log --follow artifacts/milestone-1-task-crud/architecture.md` |
| UI spec revisions | 1 | `git log --follow artifacts/milestone-1-task-crud/ui.md` |
| Manifest patches during engineering | 0 | Handoff Log entries across `artifacts/milestone-1-task-crud/tasks/task-*.md` noting a Context Manifest addition — no stage had to add a missing reference this milestone |

---

## Actions for Next Milestone

| # | Action | Owner | Due | Disposition |
|---|---|---|---|---|
| 1 | Fix BUG-002: `done <id>` must error non-zero when the ID does not exist; un-skip the reserved Vitest case | coder | M2 | |
| 2 | Make "error on missing id" a standard acceptance criterion for every id-based mutation command | product | M2 planning (Stage 1) | |
| 3 | Add filesystem prerequisites (DB parent-directory creation) to the architecture review checklist | architect | M2 planning (Stage 2a) | |
| 4 | Automate the performance benchmark suite so budget tracking is populated during engineering, not after close | coder | M2 | |

---

## Sign-Off

**Status**: Approved with Notes

**Signed off by**: Product Agent
**Date**: 2026-04-10

**Notes**:
> Approved with one note: BUG-002 (`done` silent success on a missing ID, Low) fails criterion F5 / scenario T3. Product re-triaged it at this milestone-completion checkpoint and held it Deferred into M2, where it is paired with an error-signaling task. All three CEO Approval Conditions are Verified (1 and 2 by Reviewer, 3 by Product) — none remain open. The milestone closes as "Complete with Deferrals".

---

_Last updated: 2026-04-10_
