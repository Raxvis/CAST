<!-- TEMPLATE INSTRUCTIONS
  FILE: AGENT_STATE.md
  PURPOSE: The cross-milestone record that is not a task file: decisions worth carrying
           forward, milestone progress, and the live performance-budget table.

  WHAT CHANGED IN v3 — READ THIS BEFORE ADDING A TABLE.
  In v2 this file was 506 lines of per-agent tables (Current Work, Review Queue, Future
  Work, Screen Specifications, Blocked-agent dashboards) and every one of the 15 agent
  files ended with "read your section on activation" — which directly contradicted the
  read-set rule that is the whole point of the pipeline. The tables also duplicated state
  that already had an owner: Current Work is the task file's Status field, the review queue
  is the Handoff Log, Future Work is the milestone README's out-of-scope list.

  v3 fixed both ends. NO AGENT READS THIS FILE. The orchestrating skill writes it at
  checkpoints, and only the three things below survived — the ones with no other home.

  If you are about to add a table here, first ask which file already owns that state.
  Almost always one does.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace the [MILESTONE_*] rows with your actual milestones.
  - Tables start `_(empty)_`; the orchestrator appends rows as work completes.
  - Append-only. The one sanctioned exception: at milestone completion the orchestrator
    relocates closed rows verbatim to artifacts/archive/AGENT_STATE.md so this file stays
    bounded to the current milestone plus a tail.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Project State

Written by the orchestrating skill (`/agent-plan`, `/agent-code`, `/agent-task`) at checkpoints. **Agents do not read this file** — a stage's read set is its task file, that file's Context Manifest, and the latest handoff entry's "Read next" (`docs/STAGE_CONTRACT.md`).

---

## Decisions Log

Decisions worth carrying past the milestone that produced them. Log when: accepting a non-standard approach, deviating from a convention, choosing between real alternatives, or setting a precedent future work should follow. **Do not log routine choices** — a decision that would not change anyone's later work is noise.

Architecture entries use the Alternatives column; others may leave it empty.

| Date | Agent | Decision | Alternatives considered | Rationale |
|---|---|---|---|---|
| _(empty)_ | | | | |

---

## Milestone Progress

One row per milestone, updated at planning approval and at completion.

| Milestone | Status | Tasks (done/total) | Bugs open | Closed |
|---|---|---|---|---|
| [MILESTONE_1] | Planned / In Progress / Complete / Complete with Deferrals | 0/0 | 0 | — |

---

## Performance Budget Tracking

Targets are set by Architecture in the milestone's `architecture.md` → Performance Budget. Current values are measured by the Risk agent at the milestone-completion check (recorded in `reviews/risk-impl.md`) and transcribed here by the orchestrator, when the plan flagged one.

| Metric | Target | Current | Status | Measured |
|---|---|---|---|---|
| [PERFORMANCE_METRIC] | [TARGET] | — | Not measured | — |

---

## Open Questions

Questions raised by a stage that need a human answer before work can continue. The orchestrator adds them when it escalates; remove a row when it is answered.

| Date | Raised by | Question | Blocking |
|---|---|---|---|
| _(empty)_ | | | |
