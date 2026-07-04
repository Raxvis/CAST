<!-- TEMPLATE INSTRUCTIONS
  FILE: AGENT_STATE.md
  PURPOSE: Live working state for every agent in the roster. Each agent's definition in
           .claude/agents/ stays immutable; the mutable tables it used to carry (Current
           Work, Decisions Log, dashboards, queues) live here instead, one section per
           agent.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Keep one `## <agent>` section per installed agent, in roster order. If you pruned
    an agent from the roster, delete its section.
  - Replace [MILESTONE_*] rows in the validator Milestone Progress table with your
    actual milestone names.
  - Agents append rows to their own section as they work — tables start `_(empty)_`.
  - Do not rewrite or delete historical rows; this file is an append-only record.
-->

# [PROJECT_NAME] — Agent State

Live working state for every agent. Agents read their own section on activation and append — never rewrite history. This file exists so agent definitions in `.claude/agents/` stay immutable and cheap to load.

**Decisions Log format** — every agent logs decisions in its own section using `Date / Decision / Rationale / Impact`. Log when: accepting a non-standard approach, deviating from convention, choosing between alternatives, or establishing a precedent future work should follow. The architect section uses the extended five-column variant (`Date / Decision / Alternatives Considered / Rationale / Impact`) to capture architectural decision records.

---

## product

### Current Work

| Task | Milestone | Status | Notes |
|---|---|---|---|
| _(empty)_ | | | |

### Review Queue

| Task | Submitted By | Date | Status |
|---|---|---|---|
| _(empty)_ | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## architect

### Current Work

| Task | Milestone | Status | Notes |
|---|---|---|---|
| _(empty)_ | | | |

### Architecture Documents

_Index of every architecture document produced, with its status._

| Document | Module / System | Status | Milestone |
|---|---|---|---|
| _(empty)_ | | | |

### Decisions Log

| Date | Decision | Alternatives Considered | Rationale | Impact |
|---|---|---|---|---|
| _(empty)_ | | | | |

### Technical Validation Feedback

_Performance and correctness observations from user validation sessions, for Architecture review._

| Session Date | Observation | Module Affected | Action |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## ui

### Current Work

| Task | Milestone | Status | Notes |
|---|---|---|---|
| _(empty)_ | | | |

### Screen Specifications

_Index of every completed screen spec._

| Screen | Milestone | Status | Notes |
|---|---|---|---|
| _(empty)_ | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

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
| _(empty)_ | | | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## performance

### Performance Budget Tracking

_This is the canonical live tracking table. Targets are defined by Architecture (in the milestone's architecture document → Performance Budget). The Performance Agent owns Current values and Status updates._

| Metric | Target | Current | Status | Notes |
|---|---|---|---|---|
| Startup time | < 2s | — | — | Default — tune per platform |
| Update/tick duration | < 16ms | — | — | Default — only for projects with a hot loop |
| Frame render time | < 16ms | — | — | Default — only for projects that render UI |
| Memory footprint | < 200MB | — | — | Default — tune per platform |
| Local storage use | < 50MB | — | — | Default — tune per platform |

### Current Work

| Finding | Metric Affected | Impact | Status | Date | Notes |
|---|---|---|---|---|---|
| _(empty)_ | | | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## ceo

### Current Work

| Milestone | Status | Verdict | Notes |
|---|---|---|---|
| _(empty)_ | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

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
| _(empty)_ | | | | |

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

#### [MILESTONE_NAME]

| Task | Status | Notes |
|---|---|---|
| _(empty)_ | | |

### Files Created

_All new files created by Coder. Supports Architecture review and documentation._

| File | Milestone | Module | Notes |
|---|---|---|---|
| _(empty)_ | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## tester

### Current Work

| Change | Source Agent | Tests Run | Pass / Fail | Coverage Delta | Date | Notes |
|---|---|---|---|---|---|---|
| _(empty)_ | | | | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## reviewer

### Current Work

| Submission | Source Agent | Date Received | Verdict | Date Completed | Notes |
|---|---|---|---|---|---|
| _(empty)_ | | | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## debugger

### Current Work

| Bug ID | Source | Status | Assigned To | Date Started | Notes |
|---|---|---|---|---|---|
| _(empty)_ | | | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| _(empty)_ | | |

---

## refactor

### Current Work

| Task | Triggered By | Modules Affected | Status | Tester Approved | Reviewer Approved | Notes |
|---|---|---|---|---|---|---|
| _(empty)_ | | | | | | |

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
| _(empty)_ | | | | | |

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
| _(empty)_ | | | | | |

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
| _(empty)_ | | | | | | |

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
| _(empty)_ | | |

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
| Product | _(empty)_ | | | |
| Architecture | _(empty)_ | | | |
| UI | _(empty)_ | | | |
| Security | _(empty)_ | | | |
| Performance | _(empty)_ | | | |
| CEO | _(empty)_ | | | |
| Coder | _(empty)_ | | | |
| Tester | _(empty)_ | | | |
| Reviewer | _(empty)_ | | | |
| Debugger | _(empty)_ | | | |
| Refactor | _(empty)_ | | | |
| Bug Gatherer | _(empty)_ | | | |
| Docs Writer | _(empty)_ | | | |
| Release | _(empty)_ | | | |

### Milestone Progress

| Milestone | Tasks Total | Complete | In Progress | Blocked | Not Started | % Done |
|---|---|---|---|---|---|---|
| [MILESTONE_1] | | | | | | |
| [MILESTONE_2] | | | | | | |
| [MILESTONE_3] | | | | | | |

### Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| _(empty)_ | | | |

### Future Work

| Item | Priority | Notes |
|---|---|---|
| Automate Pre-Handoff Checklist verification | Low | Would reduce Validator manual load |

---

_Last updated: [YYYY-MM-DD]_
