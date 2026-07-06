# Acme Todo — Agent State

Live working state for every agent. Agents read their own section on activation and append — never rewrite history. This file exists so agent definitions in `.claude/agents/` stay immutable and cheap to load.

**Decisions Log format** — every agent logs decisions in its own section using `Date / Decision / Rationale / Impact`. Log when: accepting a non-standard approach, deviating from convention, choosing between alternatives, or establishing a precedent future work should follow. The architect section uses the extended five-column variant (`Date / Decision / Alternatives Considered / Rationale / Impact`) to capture architectural decision records.

---

## product

### Current Work

| Task | Milestone | Status | Notes |
|---|---|---|---|
| Milestone 1 definition + task breakdown (T-1 – T-5) | M1 | Complete | `milestone-1-task-crud.md`, `-tasks.md` |
| Milestone 1 validation against acceptance criteria | M1 | Complete | All criteria met; completion record written 2026-04-10 |

### Review Queue

| Task | Submitted By | Date | Status |
|---|---|---|---|
| T-5 (CLI wiring) final validation | Coder | 2026-04-10 | Validated |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-10 | Defer BUG-002 to Milestone 2 | Does not affect correctness of normal flows; usability papercut | M2 gains an error-signaling task (`done`/`delete` on missing ID) |
| 2026-04-10 | Close BUG-001 at milestone sign-off | Condition 3 remediation verified by fresh-install test | First-run path covered by regression checklist items 1–2 |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| M2 task: error signaling for `done`/`delete` on non-existent ID | Medium | Covers BUG-002 and the `delete` counterpart in one task |

---

## architect

### Current Work

| Task | Milestone | Status | Notes |
|---|---|---|---|
| Milestone 1 architecture document | M1 | Complete | `artifacts/architecture/arch-milestone-1.md` |

### Architecture Documents

_Index of every architecture document produced, with its status._

| Document | Module / System | Status | Milestone |
|---|---|---|---|
| `arch-milestone-1.md` | `src/db/`, `src/commands/`, `src/cli.ts` | Approved (CEO, with conditions) | M1 |

### Decisions Log

| Date | Decision | Alternatives Considered | Rationale | Impact |
|---|---|---|---|---|
| 2026-04-08 | `better-sqlite3` synchronous bindings | `node:sqlite` (experimental), `sql.js` (WASM) | Synchronous API fits a short-lived CLI process; no async ceremony in command handlers | All DB access is synchronous; tests need no async setup |
| 2026-04-08 | Idempotent migrations run on every command invocation | One-time `init` subcommand | No install step to forget; idempotency check is a single indexed query | Every command entry path must call the migration runner (see BUG-001) |

### Technical Validation Feedback

| Session Date | Observation | Module Affected | Action |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| Make `ensureMigrations()` automatic inside the connection factory | Medium | M2 refactor candidate, from BUG-001 regression notes |

---

## ui

### Current Work

| Task | Milestone | Status | Notes |
|---|---|---|---|
| Milestone 1 UI spec (command surfaces) | M1 | Complete | `artifacts/ui-specs/ui-milestone-1.md` |

### Screen Specifications

_Index of every completed screen spec._

| Screen | Milestone | Status | Notes |
|---|---|---|---|
| `ui-milestone-1.md` (all four commands) | M1 | Approved | Covers output format, exit codes, and error messages per command |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-08 | All errors and usage-on-failure go to stderr; stdout is data only | Keeps the CLI pipe- and script-friendly | Encoded in `docs/` conventions and the UI spec's error-message table |

### UX Playtesting Feedback

| Session Date | Observation | Screen Affected | Severity | Action |
|---|---|---|---|---|
| _(empty)_ | | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## security

### Current Work

| Finding | Severity | Module | Status | Date | Notes |
|---|---|---|---|---|---|
| SQL injection risk in command handlers | Critical | `src/commands/*` | Resolved | 2026-04-08 | Escalated to CEO → Approval Condition 1; Reviewer gated every merge |
| Unvalidated `ACME_TODO_DB` env var used as filesystem path | Medium | `src/db/` | Accepted risk | 2026-04-08 | Single-user CLI, no privilege boundary; revisit in M2 |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-08 | Escalate the injection finding to CEO as an Approval Condition | Critical severity; touches every write path | Coder must use `.prepare().run(params)` exclusively |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| Path resolution / validation for `ACME_TODO_DB` | Low | Accepted-risk follow-up from M1 review |

---

## performance

### Performance Budget Tracking

_This is the canonical live tracking table. Targets are defined by Architecture (in the milestone's architecture document → Performance Budget). The Performance Agent owns Current values and Status updates._

| Metric | Target | Current | Status | Notes |
|---|---|---|---|---|
| Command latency (cold start) | < 100 ms | 62 ms | Within budget | Measured after T-5 wiring, 2026-04-10 |
| Command latency (warm) | < 50 ms | 18 ms | Within budget | Measured after T-5 wiring, 2026-04-10 |
| `list` latency (1k rows) | < 100 ms | 9 ms | Within budget | Benchmark added in Tester phase; uses `idx_tasks_completed` |
| DB file size (1k rows) | < 1 MB | 92 KB | Within budget | Verified in Tester phase |

### Current Work

| Finding | Metric Affected | Impact | Status | Date | Notes |
|---|---|---|---|---|---|
| WAL mode not enabled | Command latency | fsync stalls on large histories | Resolved | 2026-04-08 | Folded into CEO Approval Condition 2 |
| Missing index on `completed` | `list` latency | Full table scan on the hot path | Resolved | 2026-04-08 | Folded into CEO Approval Condition 2 |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-08 | Defer benchmark suite to Tester phase (not T-1) | Benchmarks require T-5 CLI wiring to be exercised end-to-end | Budget tracking populated after M1 close |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## ceo

### Current Work

| Milestone | Status | Verdict | Notes |
|---|---|---|---|
| M1 — Task CRUD | Reviewed 2026-04-08 | APPROVED WITH CONDITIONS | Three conditions (parameterized SQL; WAL + index; migration on first invocation) — all verified by 2026-04-10 |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-08 | Approve with conditions instead of requiring document rework | All findings had concrete, localized remediations | Engineering started next session; conditions tracked in the task breakdown and verified at merge |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## coder

### Current Work — In Progress

| Task | Milestone | Started | Blocked? | Notes |
|---|---|---|---|---|
| _(empty)_ | | | | |

### Current Work — Ready to Start

| Task | Milestone | Priority | Spec Ready? | Notes |
|---|---|---|---|---|
| _(empty — M1 complete; M2 not yet planned)_ | | | | |

### Current Work — Blocked

| Task | Milestone | Blocked By | Since | Notes |
|---|---|---|---|---|
| _(empty)_ | | | | |

### Directives Queue

_Directives are instructions from Architecture, UI, or Product that do not yet have a full task definition. Coder does not begin work on a directive until it has been converted to a task with acceptance criteria._

| Directive | From | Date | Status | Notes |
|---|---|---|---|---|
| _(empty)_ | | | | |

### Open Questions

_Questions raised to Architecture, UI, or Product. Implementation of affected work does not begin until the question is resolved._

| # | Date | Question | Directed To | Status | Resolution |
|---|---|---|---|---|---|
| _(empty)_ | | | | | |

### Blockers

| Blocker | Affected Task | Blocking Agent | Raised | Notes |
|---|---|---|---|---|
| _(empty)_ | | | | |

### Implementation Status by Milestone

_Duplicate the table below per milestone, under a `#### [MILESTONE_NAME]` heading._

#### Milestone 1 — Task CRUD

| Task | Status | Notes |
|---|---|---|
| T-1 Schema, migration runner, WAL, index | Complete | Condition 2 verified by Reviewer at merge |
| T-2 `add` command | Complete | Parameterized bindings per Condition 1 |
| T-3 `list` command | Complete | BUG-001 discovered and fixed inline (`a8f3d12`) |
| T-4 `done` / `delete` commands | Complete | |
| T-5 CLI argv parser + entry wiring | Complete | Closed M1 on 2026-04-10 |

### Files Created

_All new files created by Coder. Supports Architecture review and documentation._

| File | Milestone | Module | Notes |
|---|---|---|---|
| `src/db/schema.ts`, `src/db/migrations.ts`, `src/db/connection.ts` | M1 | db | `connection.ts` added during BUG-001 fix |
| `src/commands/add.ts`, `list.ts`, `done.ts`, `delete.ts` | M1 | commands | One file per subcommand |
| `src/types/task.ts` | M1 | types | `Task` interface, `TaskRow` row shape |
| `src/cli.ts`, `src/index.ts` | M1 | cli | Dispatcher and shebang entry |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-09 | Wire `ensureMigrations()` into every command entry path, not just `list` | Same defect class waiting in `add`/`done`/`delete`; one commit closes all of it | New commands must follow the same pattern (see BUG-001 regression notes) |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## tester

### Current Work

| Change | Source Agent | Tests Run | Pass / Fail | Coverage Delta | Date | Notes |
|---|---|---|---|---|---|---|
| T-1 – T-4 suites | Coder | Targeted per task | Pass | +100% on new modules | 2026-04-09 | BUG-001 fix covered by first-run test |
| T-5 + full-suite gate | Coder | Full suite (42 tests) | Pass | 100% line coverage on `src/commands/` | 2026-04-10 | Gated Milestone 1 validation |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-10 | Add fresh-install first-run case to the regression checklist | BUG-001 class of failure is invisible to unit tests with a warm DB | Checklist items 1–2 in `BUGS.md` |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| Benchmark suite for the performance budget table | Low | Currently manual; automate in M2 |

---

## reviewer

### Current Work

| Submission | Source Agent | Date Received | Verdict | Date Completed | Notes |
|---|---|---|---|---|---|
| T-1 – T-4 | Coder | 2026-04-09 | Approved | 2026-04-09 | Conditions 1 and 2 verified at each merge; BUG-001 classified as Defect |
| T-5 | Coder | 2026-04-10 | Approved | 2026-04-10 | No findings |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-09 | Classify BUG-001 as a Defect (not an Issue) | Broken first-run behaviour, violated Condition 3 — incorrect behaviour, not structure | Routed to Bug Gatherer → Product → Debugger per the engineering loop |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## debugger

### Current Work

| Bug ID | Source | Status | Assigned To | Date Started | Notes |
|---|---|---|---|---|---|
| BUG-001 | `artifacts/BUGS.md` | Closed | Coder | 2026-04-09 | Root cause: assumption leak — migrations only ran on the `add` path; fixed same session |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-09 | Recommend per-command `ensureMigrations()` over dispatcher-level or factory-level init | Smallest explicit diff; factory-level change too large for a bug fix | Factory-level init logged as an M2 refactor candidate (architect Future Work) |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## refactor

### Current Work

| Task | Triggered By | Modules Affected | Status | Tester Approved | Reviewer Approved | Notes |
|---|---|---|---|---|---|---|
| _(empty — no Issues filed in M1)_ | | | | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## bug-gatherer

### Current Work

| Bug Report | Source | Date Filed | Suggested Severity | Status | Notes |
|---|---|---|---|---|---|
| BUG-001 | Reviewer Defect during T-3 | 2026-04-09 | High | Closed | Product triaged fix-now; verified and closed at M1 sign-off |
| BUG-002 | Manual smoke testing | 2026-04-10 | Low | Deferred | Product deferred to M2 at triage |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## docs-writer

### Current Work

| Document | Triggered By | Action (Created / Updated) | Status | Date | Notes |
|---|---|---|---|---|---|
| `CLAUDE.md` Common Pitfalls + Persistence sections | Task-completion checkpoint (T-3) | Updated | Done | 2026-04-09 | First-run migration behaviour documented from BUG-001 |
| `docs/` sweep for M1 close | Milestone-completion checkpoint | Updated | Done | 2026-04-10 | Drained the `docs:` queue in `STANDUP.md`; no items remained |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## release

### Current Work

| Release Version | Milestone | Quality Gates Met | Product Approved | Status | Date | Notes |
|---|---|---|---|---|---|---|
| _(empty — no release cut yet; Acme Todo ships after M2)_ | | | | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## validator

### Current Work

| Task | Status | Notes |
|---|---|---|
| M1 process check at milestone close | Complete | No violations; all handoffs followed the loop |

### Conflicts

| # | Date | Agents Involved | Description | Resolution | Status |
|---|---|---|---|---|---|
| _(empty)_ | | | | | |

### Process Violations

| # | Date | Agent | Violation | Impact | Resolution |
|---|---|---|---|---|---|
| _(empty)_ | | | | | |

### Open Questions Tracker

_System-wide view of all pending Open Questions raised by any agent. Validator reviews this at session start to identify potential blockers._

| # | Date | Raised By | Directed To | Question | Status | Resolution |
|---|---|---|---|---|---|---|
| _(empty)_ | | | | | | |

### Agent Status Dashboard

| Agent | Current Task | Status | Blocked By | Last Updated |
|---|---|---|---|---|
| Product | — | Idle (M1 closed) | — | 2026-04-10 |
| Architecture | — | Idle | — | 2026-04-10 |
| UI | — | Idle | — | 2026-04-10 |
| Security | — | Idle | — | 2026-04-10 |
| Performance | — | Idle | — | 2026-04-10 |
| CEO | — | Idle | — | 2026-04-10 |
| Coder | — | Idle | — | 2026-04-10 |
| Tester | — | Idle | — | 2026-04-10 |
| Reviewer | — | Idle | — | 2026-04-10 |
| Debugger | — | Idle | — | 2026-04-10 |
| Refactor | — | Idle | — | 2026-04-10 |
| Bug Gatherer | — | Idle | — | 2026-04-10 |
| Docs Writer | — | Idle | — | 2026-04-10 |
| Release | — | Idle | — | 2026-04-10 |

### Milestone Progress

| Milestone | Tasks Total | Complete | In Progress | Blocked | Not Started | % Done |
|---|---|---|---|---|---|---|
| M1 — Task CRUD | 5 | 5 | 0 | 0 | 0 | 100% |
| M2 — Error signaling + polish | — | — | — | — | — | Not planned yet |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| Automate Pre-Handoff Checklist verification | Low | Would reduce Validator manual load |

---

_Last updated: 2026-04-10_
