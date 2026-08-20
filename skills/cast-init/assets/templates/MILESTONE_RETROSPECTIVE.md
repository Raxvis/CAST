<!-- TEMPLATE INSTRUCTIONS
  FILE: MILESTONE_RETROSPECTIVE.md
  PURPOSE: Milestone retrospective template. The Product Agent copies this skeleton at the
           end of each milestone to record what went well, what didn't, process issues, and
           metrics, and to generate improvement actions for the next milestone.

  HOW TO CUSTOMIZE:
  - Replace [MILESTONE_NAME] with the specific milestone being retrospected.
  - Fill in every section. Do not skip sections even if they are "nothing to note".
  - Copy this template to `artifacts/milestone-{N}-{slug}/reviews/retrospective.md` for each
    milestone. Never fill this template in place.
  - Every section in this template is required and must be non-empty in every instance.
    Product checks all sections.
  - Every metric maps to a recorded source — see product.md → Duty 5. Fill from
    the sources; do not estimate.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# Milestone Retrospective: [MILESTONE_NAME]


## Header (required)

**Date**: [DATE]
**Facilitator**: Product Agent
**Participants**: [LIST_AGENTS_ACTIVE_THIS_MILESTONE]

---

## Estimated vs Actual Effort (required)

- **Estimated**: [ESTIMATED_EFFORT] — from the "Estimated Effort" field in the milestone definition (`artifacts/milestone-{N}-{slug}/README.md`)
- **Actual**: [ACTUAL_DURATION] — from the session dates for this milestone in `artifacts/STANDUP.md` (first to last session)
- **Delta**: [DIFFERENCE_AND_REASON_IF_SIGNIFICANT]

---

## What Went Well (required)

_Be specific. Reference tasks, agents, or decisions that were particularly effective._

- [ITEM_1]
- [ITEM_2]
- [ITEM_3]

---

## What Didn't Go Well (required)

_Be specific and honest. This is not a blame log — it is a process improvement record._

- [ITEM_1]
- [ITEM_2]
- [ITEM_3]

---

## Process Issues (required)

| Issue | Agent(s) Involved | Root Cause | Action |
|---|---|---|---|
| [ISSUE_1] | [AGENT] | [ROOT_CAUSE] | [ACTION_OR_RULE_CHANGE] |
| [ISSUE_2] | [AGENT] | [ROOT_CAUSE] | [ACTION_OR_RULE_CHANGE] |

_If no process issues occurred, replace this table with "No process issues."_

---

## Metrics (required)

_Fill each metric from its recorded source (product.md → Duty 5) — do not estimate._

| Metric | Value | Source |
|---|---|---|
| Tasks planned | [N] | Task Index in `artifacts/milestone-{N}-{slug}/README.md` (count of task files) |
| Tasks completed | [N] | Status fields across `artifacts/milestone-{N}-{slug}/tasks/task-*.md` |
| Tasks rejected by Product | [N] | Handoff Logs across `artifacts/milestone-{N}-{slug}/tasks/task-*.md` (Product → Coder return entries) — note average rejections per task |
| Loop-backs, and what caused them | [N] | `Loop count` Headers across `tasks/task-*.md` plus the `loop` entries in `artifacts/STANDUP.md` |
| Escalations to the user | [N] | `blocker` entries in `artifacts/STANDUP.md` for this milestone |
| Architecture doc revisions | [N] | `git log --follow artifacts/milestone-{N}-{slug}/architecture.md` |
| UI spec revisions | [N] | `git log --follow artifacts/milestone-{N}-{slug}/ui.md` |
| Manifest patches during engineering | [N] | Handoff Log entries across `artifacts/milestone-{N}-{slug}/tasks/task-*.md` noting a Context Manifest addition (the insufficient-manifest fallback in `docs/STAGE_CONTRACT.md`). Each one is a planning defect the CEO gate missed — a high count is itself an improvement action |

---

## Actions for Next Milestone (required)

_The Disposition column stays empty at retrospective time. Product fills it during the next `/agent-plan` Stage 1 (retrospective intake): every row gets either `Adopted → M{N}` (folded into that milestone's Cross-Cutting Concerns or a task) or `Declined — <reason>`. No row may be left undisposed at the next planning run._

| # | Action | Owner | Due | Disposition |
|---|---|---|---|---|
| 1 | [ACTION_1] | [AGENT] | [MILESTONE_OR_DATE] | |
| 2 | [ACTION_2] | [AGENT] | [MILESTONE_OR_DATE] | |
