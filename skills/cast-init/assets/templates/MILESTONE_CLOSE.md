<!-- TEMPLATE INSTRUCTIONS
  FILE: MILESTONE_CLOSE.md
  PURPOSE: The single milestone-close record. Product fills this document once, at the
           /agent-code milestone-completion checkpoint, in one pass: per-task validation,
           milestone-level validation, the completion summary, and the retrospective.

           The "Per-Task Validation" section also serves a second, lighter use: during
           /agent-code Step 3b Product applies its checks to a task as *criteria* only —
           the per-task outcome is recorded as the task's Status in the task file's Header
           plus a `progress` entry in artifacts/STANDUP.md, and NO per-task document is
           created. Step 3b runs only when Reviewer's Acceptance Criteria Check flags a
           criterion or a CEO Approval Condition line, or a criterion was amended mid-task;
           tasks whose criteria and condition lines Reviewer marked all Met close without a
           Product spawn (Step 3a) and are reviewed here instead. (/agent-task validates against
           the task description instead and does not use this template.)

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace [MILESTONE_NAME] with the specific milestone being closed (e.g., "M2: Core Loop").
  - Per-Task Validation: one row per task in the milestone — every task, however it
    closed. Do not re-derive what Reviewer already recorded: the row cites Reviewer's
    Acceptance Criteria Check (handoff entry number) as evidence, and Product's
    disposition is a judgment on that evidence. Anything the evidence does not settle
    goes to the Notes column or a filed bug.
  - Fill the Milestone Validation Checklist with the milestone's own acceptance criteria.
  - Rename the "User Validation Feedback Log" section to match your review process
    (e.g., "User Testing", "QA Session", "Demo Review", "Playtesting").
  - Header Status: use "Complete with Deferrals" when any task or bug is still Deferred
    after Product's re-triage at this checkpoint, and list every such item under Known
    Issues. Deferred is a held-open state — re-triaged again at the next /agent-plan
    Stage 1, not forgotten.
  - Every metric maps to a recorded source — see product.md → Duty 5. Fill from the
    sources; do not estimate.
  - Instance destination: artifacts/milestone-{N}-{slug}/reviews/close.md.
    Never fill this template in place.
  - Sections marked (required) must be present and non-empty in every instance;
    (optional) sections may be omitted. Product fills them; the orchestrator pre-checks
    that every required section is present before accepting the close record.

  SECTION SCALING:
  Required sections must be PRESENT in every instance, but their depth scales with
  the milestone. A section marked (required, scales) collapses to a single line —
  `N/A — <one-clause reason>` — whenever the milestone does not exercise it (for
  example, Regression Testing on the project's first milestone). The remaining
  required sections are always filled properly. Optional sections are omitted entirely.

  This is a record, not a form to fill out: a checklist marked complete against
  work that was never done is worse than an honest `N/A`, because it reads as
  evidence at the next milestone's planning and in the retrospective.

  Coverage is NOT scalable. The Per-Task Validation table carries one row per task
  in the milestone — including tasks that closed via Step 3a of docs/PIPELINE_LOOP.md
  without a Product spawn during the loop. Those tasks were validated by Reviewer's
  Acceptance Criteria Check; this document is where Product reviews them, so omitting
  one defeats the batching Step 3a enables. Scale the depth of the Notes, never the
  number of rows.
-->

<!-- Placeholders: bracketed UPPER_SNAKE_CASE tokens are project values filled at
     adoption; bracketed lowercase names are per-use fill-ins. -->

# [PROJECT_NAME] — [MILESTONE_NAME] Close Record


## Header (required)

| Field | Value |
|-------|-------|
| **Milestone** | [MILESTONE_NAME] |
| **Close Date** | [YYYY-MM-DD] |
| **Author** | Product Agent |
| **Status** | Complete / Complete with Deferrals — use "Complete with Deferrals" when any task or bug remains Deferred after re-triage; list each under Known Issues |

---

## Summary (required)

[2–4 sentences: what this milestone achieved, what was validated, what failed or was
deferred, and whether the milestone closes clean. State the goal and whether it was met.]

---

## Delivered (required)

Features and changes completed in this milestone.

| # | Item | Description | Task Reference |
|---|------|-------------|----------------|
| 1 | [Item name] | [Brief description of what was built or changed] | [Task ID] |
| 2 | [Item name] | [Brief description] | [Task ID] |

---

## Deferred (required)

Items originally planned for this milestone that were moved to a future milestone.

| # | Item | Reason for Deferral | Moved To |
|---|------|--------------------|---------|
| 1 | [Item name] | [Why it was deferred] | [Target milestone] |

_If nothing was deferred, replace this table with "Nothing deferred."_

---

## Per-Task Validation (required)

One row per task in the milestone — **every** task, however it closed. The evidence
column cites Reviewer's Acceptance Criteria Check (the handoff entry number in that
task's file); Product's disposition is a judgment on that evidence, not a re-derivation
of it. Spot-check criteria marked `Met`; dispose explicitly of anything marked
`Not met` or `Product judgment` that was not already settled at Step 3b. A task whose
disposition is REJECTED re-enters the engineering loop like any Fix Now finding, and
this record is revised when it resolves.

| Task | Closed Via | Reviewer Evidence | Disposition | Notes |
|------|-----------|-------------------|-------------|-------|
| [TASK_NAME] | Step 3a / Step 3b | Handoff entry #[N] | APPROVED / APPROVED WITH NOTES / REJECTED | [Edge cases spot-checked, criteria disposed, or issues filed as bugs] |

---

## Milestone Validation Checklist (required)

### Functionality (required)

| # | Requirement | Acceptance Criteria | Status | Notes |
|---|-------------|--------------------|----|-------|
| F1 | [Requirement] | [Specific, testable criteria] | Pass / Fail / N/A | |
| F2 | [Requirement] | [Specific, testable criteria] | Pass / Fail / N/A | |

### Quality (required)

| # | Criterion | Acceptance Criteria | Status | Notes |
|---|-----------|--------------------|----|-------|
| Q1 | Code quality | [e.g., No linter errors, follows conventions] | Pass / Fail / N/A | |
| Q2 | Performance | [e.g., Meets performance budget targets] | Pass / Fail / N/A | |
| Q3 | Accessibility | [e.g., All interactive elements are reachable] | Pass / Fail / N/A | |

### Critical Path Testing (required)

| # | Scenario | Steps | Expected | Actual | Status |
|---|----------|-------|----------|--------|--------|
| T1 | [Scenario name] | [Brief steps] | [Expected result] | [Actual result] | Pass / Fail |

---

## Regression Testing (required, scales)

_Duplicate a checklist block for each major feature area._

### [FEATURE_AREA_1] — Regression Checklist

- [ ] [CHECK_1]
- [ ] [CHECK_2]

---

## User Validation Feedback Log (optional)

_Rename this section to match your review process (e.g., "User Testing", "QA Session",
"Demo Review"). Duplicate the session block per session._

### [SESSION_TYPE] Session — [DATE]

**Participants**: [PARTICIPANT_ROLES]
**Build / Version**: [VERSION_OR_MILESTONE]
**Duration**: [DURATION]

#### What Was Tested

- [FEATURE_OR_AREA_1]
- [FEATURE_OR_AREA_2]

#### Observations

| # | Observation | Area | Severity | Backlog Item? |
|---|---|---|---|---|
| | | | | |

---

## Known Issues (required)

Issues that remain open at close — including every task or bug still **Deferred** after
Product's re-triage (these make the Header Status "Complete with Deferrals"), and any
CEO Approval Condition left unverified.

| ID | Description | Severity | Owner | Tracked In |
|----|-------------|----------|-------|------------|
| | | | | `BUGS.md` / [Task ID] |

_If no known issues, replace this table with "No known issues." Deferred items kept
Deferred at re-triage belong here — they do not block closing the milestone and are
re-triaged again at the next `/agent-plan` Stage 1._

---

## Retrospective (required)

### Estimated vs Actual Effort (required)

- **Estimated**: [ESTIMATED_EFFORT] — from the "Estimated Effort" field in the milestone definition (`artifacts/milestone-{N}-{slug}/README.md`)
- **Actual**: [ACTUAL_DURATION] — from the session dates for this milestone in `artifacts/STANDUP.md` (first to last session)
- **Delta**: [DIFFERENCE_AND_REASON_IF_SIGNIFICANT]

### What Went Well (required)

_Be specific. Reference tasks, agents, or decisions that were particularly effective._

- [ITEM_1]
- [ITEM_2]

### What Didn't Go Well (required)

_Be specific and honest. This is not a blame log — it is a process improvement record._

- [ITEM_1]
- [ITEM_2]

### Process Issues (required)

| Issue | Agent(s) Involved | Root Cause | Action |
|---|---|---|---|
| [ISSUE_1] | [AGENT] | [ROOT_CAUSE] | [ACTION_OR_RULE_CHANGE] |

_If no process issues occurred, replace this table with "No process issues."_

### Metrics (required)

_Fill each metric from its recorded source (product.md → Duty 5) — do not estimate._

| Metric | Value | Source |
|---|---|---|
| Tasks planned | [N] | Task Index in `artifacts/milestone-{N}-{slug}/README.md` (count of task files) |
| Tasks completed | [N] | Status fields across `artifacts/milestone-{N}-{slug}/tasks/task-*.md` |
| Tasks rejected by Product | [N] | Handoff Logs across `artifacts/milestone-{N}-{slug}/tasks/task-*.md` (Product → Coder return entries) — note average rejections per task |
| Loop-backs, and what caused them | [N] | `Loop count` Headers across `tasks/task-*.md`; causes from the Handoff Log entries that sent each task back |
| Escalations to the user | [N] | `blocker` entries in `artifacts/STANDUP.md` for this milestone |
| Architecture doc revisions | [N] | `git log --follow artifacts/milestone-{N}-{slug}/architecture.md` |
| UI spec revisions | [N] | `git log --follow artifacts/milestone-{N}-{slug}/ui.md` |
| Manifest patches during engineering | [N] | Handoff Log entries across `artifacts/milestone-{N}-{slug}/tasks/task-*.md` noting a Context Manifest addition (the insufficient-manifest fallback in `docs/STAGE_CONTRACT.md`). Each one is a planning defect the CEO gate missed — a high count is itself an improvement action |

---

## Actions for Next Milestone (required)

_The Disposition column stays empty at close time. Product fills it during the next
`/agent-plan` Stage 1 (retrospective intake): every row gets either `Adopted → M{N}`
(folded into that milestone's Cross-Cutting Concerns or a task) or
`Declined — <reason>`. No row may be left undisposed at the next planning run._

| # | Action | Owner | Due | Disposition |
|---|---|---|---|---|
| 1 | [ACTION_1] | [AGENT] | [MILESTONE_OR_DATE] | |
| 2 | [ACTION_2] | [AGENT] | [MILESTONE_OR_DATE] | |

---

_Last updated: [YYYY-MM-DD]_
