# Acme Todo — Milestone Validation Report

## Revision History

| # | Date | Agent | Reason |
|---|---|---|---|
| v1 | 2026-04-10 | product | Initial version |

---

## Header

| Field | Value |
|-------|-------|
| **Milestone** | M1: Task CRUD + SQLite Persistence |
| **Validation Date** | 2026-04-10 |
| **Validator** | Product Agent |
| **Status** | Complete |

---

## Executive Summary

All five M1 tasks (T-1 through T-5) were validated against their acceptance criteria and the milestone's top-level acceptance criteria. The full Vitest suite passes (42 tests, 100% line coverage on `src/commands/`), all three CEO Approval Conditions are Verified, and the first-run experience works on a clean machine. One criterion is not met: `done <id>` on a non-existent ID exits 0 silently (BUG-002, Low). Product re-triaged BUG-002 at the milestone-completion checkpoint and held it Deferred into M2, so the milestone is approved for completion as "Complete with Deferrals".

---

## Task Validation Checklist

_The checklist below was applied per task at `/agent-code` Step 4 as criteria (outcome recorded in the tasks file and `artifacts/STANDUP.md`); this document records the milestone-grain pass over all five tasks._

### Task Validation: T-1 — Task type, SQLite schema, migration runner

**Date**: 2026-04-09
**Reviewer**: Product Agent
**Milestone**: M1: Task CRUD + SQLite Persistence

#### Functional Validation

- [x] All acceptance criteria from the task definition are met
- [x] Feature behaves correctly under normal usage
- [x] Feature behaves correctly under edge cases (empty state, maximum values, error states)
- [x] No regressions in adjacent features

**Notes**: `runMigrations` verified idempotent — second call is a no-op; `ACME_TODO_DB` override honored.

#### Visual Validation

- [x] Matches the UI specification (layout, spacing, typography, color)
- [x] All interactive states are implemented (default, pressed, disabled, loading, error, empty)
- [x] Visual feedback is present for all user actions
- [x] Animations and transitions (if specified) are implemented

**Notes**: No user-facing surface of its own; migration output is silent by spec.

#### Data Validation

- [x] Data persists correctly across sessions (if applicable)
- [x] Data displays correctly in all formatting edge cases (zero, very large, very small, null)
- [x] No data is lost or corrupted in error scenarios

**Notes**: WAL mode confirmed via `PRAGMA journal_mode;` → `wal` (Approval Condition 2).

#### Integration Validation

- [x] Feature integrates correctly with adjacent features
- [x] No unintended side effects on other parts of the system
- [x] Events, callbacks, and state updates flow correctly end-to-end

**Notes**: All four command handlers build on this layer without further schema work.

#### Code Quality

- [x] Code follows the project's style conventions (reviewed with Architecture if complex)
- [x] No placeholder code, debug output, or commented-out blocks left in
- [x] New modules/functions are appropriately named

**Notes**: Reviewer approved at merge; parameterized statements throughout (Approval Condition 1).

#### Testing

- [x] Manually tested on each target platform (macOS, Linux, Windows)
- [x] Edge cases were tested, not just the happy path

**Notes**: 6 Vitest cases including idempotency, WAL, index, and env-var override.

#### Issues Found

| # | Description | Severity | Blocking? |
|---|---|---|---|
| — | None | — | — |

#### Sign-Off

- [x] **APPROVED** — Task is complete. No further action required.
- [ ] **APPROVED WITH NOTES** — Task is complete. Non-blocking issues noted above.
- [ ] **REJECTED** — Task is returned to Coder. See Issues Found for required changes.

**Sign-Off Notes**: Approved 2026-04-09.

---

### Task Validation: T-2 — `add` command

**Date**: 2026-04-09
**Reviewer**: Product Agent
**Milestone**: M1: Task CRUD + SQLite Persistence

#### Functional Validation

- [x] All acceptance criteria from the task definition are met
- [x] Feature behaves correctly under normal usage
- [x] Feature behaves correctly under edge cases (empty state, maximum values, error states)
- [x] No regressions in adjacent features

**Notes**: Missing-title error path exits 1 with a usage message on stderr.

#### Visual Validation

- [x] Matches the UI specification (layout, spacing, typography, color)
- [x] All interactive states are implemented (default, pressed, disabled, loading, error, empty)
- [x] Visual feedback is present for all user actions
- [x] Animations and transitions (if specified) are implemented

**Notes**: New task ID printed to stdout exactly per UI spec §2.

#### Data Validation

- [x] Data persists correctly across sessions (if applicable)
- [x] Data displays correctly in all formatting edge cases (zero, very large, very small, null)
- [x] No data is lost or corrupted in error scenarios

**Notes**: Titles with spaces and quotes preserved verbatim; ISO-8601 `createdAt` confirmed.

#### Integration Validation

- [x] Feature integrates correctly with adjacent features
- [x] No unintended side effects on other parts of the system
- [x] Events, callbacks, and state updates flow correctly end-to-end

**Notes**: Inserted rows immediately visible to `list`.

#### Code Quality

- [x] Code follows the project's style conventions (reviewed with Architecture if complex)
- [x] No placeholder code, debug output, or commented-out blocks left in
- [x] New modules/functions are appropriately named

**Notes**: `.prepare().run(params)` bindings only (Approval Condition 1).

#### Testing

- [x] Manually tested on each target platform (macOS, Linux, Windows)
- [x] Edge cases were tested, not just the happy path

**Notes**: 5 Vitest cases; Windows quoting behavior checked manually in PowerShell and cmd.exe.

#### Issues Found

| # | Description | Severity | Blocking? |
|---|---|---|---|
| — | None | — | — |

#### Sign-Off

- [x] **APPROVED** — Task is complete. No further action required.
- [ ] **APPROVED WITH NOTES** — Task is complete. Non-blocking issues noted above.
- [ ] **REJECTED** — Task is returned to Coder. See Issues Found for required changes.

**Sign-Off Notes**: Approved 2026-04-09.

---

### Task Validation: T-3 — `list` command

**Date**: 2026-04-09
**Reviewer**: Product Agent
**Milestone**: M1: Task CRUD + SQLite Persistence

#### Functional Validation

- [x] All acceptance criteria from the task definition are met
- [x] Feature behaves correctly under normal usage
- [x] Feature behaves correctly under edge cases (empty state, maximum values, error states)
- [x] No regressions in adjacent features

**Notes**: BUG-001 (first-run crash) was found during implementation, fixed in the same session (`a8f3d12`), and re-validated before sign-off.

#### Visual Validation

- [x] Matches the UI specification (layout, spacing, typography, color)
- [x] All interactive states are implemented (default, pressed, disabled, loading, error, empty)
- [x] Visual feedback is present for all user actions
- [x] Animations and transitions (if specified) are implemented

**Notes**: Empty state is header row only, keeping output pipe-friendly per spec §3.

#### Data Validation

- [x] Data persists correctly across sessions (if applicable)
- [x] Data displays correctly in all formatting edge cases (zero, very large, very small, null)
- [x] No data is lost or corrupted in error scenarios

**Notes**: Open/completed filtering verified with mixed data; `--all` includes completed rows.

#### Integration Validation

- [x] Feature integrates correctly with adjacent features
- [x] No unintended side effects on other parts of the system
- [x] Events, callbacks, and state updates flow correctly end-to-end

**Notes**: `ensureMigrations()` on the entry path makes `list` safe as the first-ever command (Approval Condition 3).

#### Code Quality

- [x] Code follows the project's style conventions (reviewed with Architecture if complex)
- [x] No placeholder code, debug output, or commented-out blocks left in
- [x] New modules/functions are appropriately named

**Notes**: Reviewer approved on loop 2 after the BUG-001 fix.

#### Testing

- [x] Manually tested on each target platform (macOS, Linux, Windows)
- [x] Edge cases were tested, not just the happy path

**Notes**: 11 Vitest cases including the fresh-install first-run regression test.

#### Issues Found

| # | Description | Severity | Blocking? |
|---|---|---|---|
| 1 | BUG-001: first-run crash `no such table: tasks` — fixed in-task, verified same session | High | Resolved before sign-off |

#### Sign-Off

- [x] **APPROVED** — Task is complete. No further action required.
- [ ] **APPROVED WITH NOTES** — Task is complete. Non-blocking issues noted above.
- [ ] **REJECTED** — Task is returned to Coder. See Issues Found for required changes.

**Sign-Off Notes**: Approved 2026-04-09 after the BUG-001 fix passed Tester and Reviewer on loop 2.

---

### Task Validation: T-4 — `done` and `delete` commands

**Date**: 2026-04-09
**Reviewer**: Product Agent
**Milestone**: M1: Task CRUD + SQLite Persistence

#### Functional Validation

- [x] All acceptance criteria from the task definition are met
- [x] Feature behaves correctly under normal usage
- [ ] Feature behaves correctly under edge cases (empty state, maximum values, error states)
- [x] No regressions in adjacent features

**Notes**: `delete` errors non-zero on a missing ID as required. The equivalent edge case for `done` was not an explicit T-4 criterion and surfaced later as BUG-002 during milestone smoke testing (2026-04-10) — see Known Issues.

#### Visual Validation

- [x] Matches the UI specification (layout, spacing, typography, color)
- [x] All interactive states are implemented (default, pressed, disabled, loading, error, empty)
- [x] Visual feedback is present for all user actions
- [x] Animations and transitions (if specified) are implemented

**Notes**: Error messages go to stderr with non-zero exit for `delete` and for non-integer IDs on both commands.

#### Data Validation

- [x] Data persists correctly across sessions (if applicable)
- [x] Data displays correctly in all formatting edge cases (zero, very large, very small, null)
- [x] No data is lost or corrupted in error scenarios

**Notes**: `completedAt` set to ISO-8601 on `done`; `delete` removes exactly one row.

#### Integration Validation

- [x] Feature integrates correctly with adjacent features
- [x] No unintended side effects on other parts of the system
- [x] Events, callbacks, and state updates flow correctly end-to-end

**Notes**: Completed tasks drop out of default `list` and appear under `--all`.

#### Code Quality

- [x] Code follows the project's style conventions (reviewed with Architecture if complex)
- [x] No placeholder code, debug output, or commented-out blocks left in
- [x] New modules/functions are appropriately named

**Notes**: Parameterized statements bound to the ID argument (Approval Condition 1).

#### Testing

- [x] Manually tested on each target platform (macOS, Linux, Windows)
- [ ] Edge cases were tested, not just the happy path

**Notes**: 13 Vitest cases across the two commands; the `done`-on-missing-ID case is reserved as a skipped test with a TODO pending the BUG-002 fix in M2.

#### Issues Found

| # | Description | Severity | Blocking? |
|---|---|---|---|
| 1 | BUG-002: `done <id>` on a non-existent ID exits 0 silently (filed 2026-04-10 during milestone smoke testing; Deferred to M2 by Product) | Low | No |

#### Sign-Off

- [ ] **APPROVED** — Task is complete. No further action required.
- [x] **APPROVED WITH NOTES** — Task is complete. Non-blocking issues noted above.
- [ ] **REJECTED** — Task is returned to Coder. See Issues Found for required changes.

**Sign-Off Notes**: Task-grain validation approved 2026-04-09; the BUG-002 note was appended at the milestone-grain pass on 2026-04-10 after the bug was filed and re-triaged Deferred.

---

### Task Validation: T-5 — CLI argument parser wiring

**Date**: 2026-04-10
**Reviewer**: Product Agent
**Milestone**: M1: Task CRUD + SQLite Persistence

#### Functional Validation

- [x] All acceptance criteria from the task definition are met
- [x] Feature behaves correctly under normal usage
- [x] Feature behaves correctly under edge cases (empty state, maximum values, error states)
- [x] No regressions in adjacent features

**Notes**: `--help`, bare invocation, and unknown-command routes all behave per spec §5.

#### Visual Validation

- [x] Matches the UI specification (layout, spacing, typography, color)
- [x] All interactive states are implemented (default, pressed, disabled, loading, error, empty)
- [x] Visual feedback is present for all user actions
- [x] Animations and transitions (if specified) are implemented

**Notes**: Usage text matches the spec's help-output block verbatim.

#### Data Validation

- [x] Data persists correctly across sessions (if applicable)
- [x] Data displays correctly in all formatting edge cases (zero, very large, very small, null)
- [x] No data is lost or corrupted in error scenarios

**Notes**: `src/index.ts` runs migrations before dispatch, so no route can reach an unmigrated database.

#### Integration Validation

- [x] Feature integrates correctly with adjacent features
- [x] No unintended side effects on other parts of the system
- [x] Events, callbacks, and state updates flow correctly end-to-end

**Notes**: End-to-end add → list → done → delete cycle verified through the real entrypoint.

#### Code Quality

- [x] Code follows the project's style conventions (reviewed with Architecture if complex)
- [x] No placeholder code, debug output, or commented-out blocks left in
- [x] New modules/functions are appropriately named

**Notes**: Hand-written parser kept `better-sqlite3` as the only runtime dependency.

#### Testing

- [x] Manually tested on each target platform (macOS, Linux, Windows)
- [x] Edge cases were tested, not just the happy path

**Notes**: 7 parser cases; full suite green (42 tests) at the milestone gate.

#### Issues Found

| # | Description | Severity | Blocking? |
|---|---|---|---|
| — | None | — | — |

#### Sign-Off

- [x] **APPROVED** — Task is complete. No further action required.
- [ ] **APPROVED WITH NOTES** — Task is complete. Non-blocking issues noted above.
- [ ] **REJECTED** — Task is returned to Coder. See Issues Found for required changes.

**Sign-Off Notes**: Approved 2026-04-10; closing this task triggered the milestone-completion checkpoint.

---

## Milestone Validation Checklist

### Functionality

| # | Requirement | Acceptance Criteria | Status | Notes |
|---|-------------|--------------------|----|-------|
| F1 | Add tasks | `acme-todo add "buy milk"` prints the new task ID and exits 0; titles preserved verbatim | Pass | |
| F2 | List tasks | `acme-todo list` prints open tasks as `ID  TITLE  STATUS  CREATED`; `--all` includes completed | Pass | |
| F3 | Complete tasks | `acme-todo done <id>` sets `completed` and `completedAt` | Pass | Happy path only — see F5 |
| F4 | Delete tasks | `acme-todo delete <id>` removes the row; errors non-zero on missing ID | Pass | |
| F5 | Missing-ID signaling | `done` and `delete` both exit non-zero with a clear error when the ID does not exist | Fail | `done` exits 0 silently — BUG-002, re-triaged and held Deferred into M2 by Product |
| F6 | First-run experience | First invocation against a missing database file runs migrations and succeeds | Pass | Approval Condition 3; BUG-001 regression test in place |
| F7 | Persistence | Task state survives across CLI invocations via SQLite at `~/.acme-todo/tasks.db` (or `ACME_TODO_DB`) | Pass | |

### Quality

| # | Criterion | Acceptance Criteria | Status | Notes |
|---|-----------|--------------------|----|-------|
| Q1 | Code quality | `pnpm typecheck` clean; no linter errors; parameterized SQL throughout (Approval Condition 1) | Pass | Verified by Reviewer at every merge |
| Q2 | Performance | Warm `list` under 100 ms on a 100-task DB; WAL + `idx_tasks_completed` present (Approval Condition 2) | Pass | Measured 18 ms warm / 62 ms cold — see AGENT_STATE performance budget table |
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

### Resolved During Validation

| ID | Description | Resolution |
|----|-------------|------------|
| BUG-001 | `list` crashed with `no such table: tasks` on first invocation | Fixed in-milestone (`a8f3d12`); Product re-verified on a clean machine during validation and closed the bug at sign-off |

### Open (Must Resolve Before Milestone Closes)

| ID | Description | Severity | Owner | Target Date |
|----|-------------|----------|-------|------------|
| — | None | — | — | — |

_Deferred items that Product re-triaged at the milestone-completion checkpoint and kept Deferred do NOT belong here and do not block closing the milestone — BUG-002 is listed under Known Issues in the completion report ("Complete with Deferrals") and is re-triaged again at the next `/agent-plan` Stage 1._

---

## Recommendations

### For Next Milestone

1. Fix BUG-002 and un-skip the reserved `done`-on-missing-ID Vitest case.
2. Make "error on missing id" a standard acceptance criterion for every id-based mutation command.
3. Have architecture review explicitly cover filesystem prerequisites (the `~/.acme-todo/` directory-creation step was added late).

---

## Completion Reports

Links or references to related task breakdown documents for this milestone:

- `artifacts/milestones/milestone-1-task-crud-tasks.md` — task breakdown with final statuses and CEO Approval Conditions tracking
- `artifacts/milestones/milestone-1-task-crud-completion.md` — completion report (Status: Complete with Deferrals)
- `artifacts/reviews/ux-review-milestone-1.md` — UX review of the implemented command surface (APPROVED WITH NOTES)

---

## Validation Status

**Status**: Approved with Notes

**Signed off by**: Product Agent
**Date**: 2026-04-10

**Notes**:
> Approved with one note: BUG-002 (`done` silent success on a missing ID, Low) fails criterion F5 / scenario T3. Product re-triaged it at the milestone-completion checkpoint and held it Deferred into M2, where it is paired with an error-signaling task. The milestone closes as "Complete with Deferrals" per the completion report.

---

_Last updated: 2026-04-10_
