<!-- TEMPLATE INSTRUCTIONS
  FILE: MILESTONE_RETROSPECTIVE.md
  PURPOSE: Milestone retrospective template. The Validator Agent copies this skeleton at the
           end of each milestone to record what went well, what didn't, process issues, and
           metrics, and to generate improvement actions for the next milestone.

  HOW TO CUSTOMIZE:
  - Replace [MILESTONE_NAME] with the specific milestone being retrospected.
  - Fill in every section. Do not skip sections even if they are "nothing to note".
  - Copy this template to `artifacts/reviews/retrospective-milestone-{N}.md` for each
    milestone. Never fill this template in place.
  - Every section in this template is required and must be non-empty in every instance.
    Validator checks all sections.
  - Every metric maps to a recorded source — see validator.md → Metric Sources. Fill from
    the sources; do not estimate.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# Milestone Retrospective: [MILESTONE_NAME]

## Revision History (required)

| # | Date | Agent | Reason |
|---|---|---|---|
| v1 | [DATE] | validator | Initial retrospective |

---

## Header (required)

**Date**: [DATE]
**Facilitator**: Validator Agent
**Participants**: [LIST_AGENTS_ACTIVE_THIS_MILESTONE]

---

## Estimated vs Actual Effort (required)

- **Estimated**: [ESTIMATED_EFFORT] — from the "Estimated Effort" field in the milestone definition (`artifacts/milestones/milestone-{N}-{slug}.md`)
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

_Fill each metric from its recorded source (validator.md → Metric Sources) — do not estimate._

| Metric | Value | Source |
|---|---|---|
| Tasks planned | [N] | Summary table in `artifacts/milestones/milestone-{N}-{slug}-tasks.md` |
| Tasks completed | [N] | Summary table in `artifacts/milestones/milestone-{N}-{slug}-tasks.md` |
| Tasks rejected by Product | [N] | Summary table in `artifacts/milestones/milestone-{N}-{slug}-tasks.md` — note average rejections per task |
| Process violations | [N] | Process Violations table in `artifacts/AGENT_STATE.md` → `## validator` |
| Conflicts escalated to Validator | [N] | Conflicts table in `artifacts/AGENT_STATE.md` → `## validator` |
| Architecture doc revisions | [N] | `## Revision History` table in `artifacts/architecture/arch-milestone-{N}.md` |
| UI spec revisions | [N] | `## Revision History` table in `artifacts/ui-specs/ui-milestone-{N}.md` |

---

## Actions for Next Milestone (required)

| # | Action | Owner | Due |
|---|---|---|---|
| 1 | [ACTION_1] | [AGENT] | [MILESTONE_OR_DATE] |
| 2 | [ACTION_2] | [AGENT] | [MILESTONE_OR_DATE] |
