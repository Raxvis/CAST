<!-- TEMPLATE INSTRUCTIONS
  FILE: CEO_REVIEW.md
  PURPOSE: CEO planning-review template. The CEO Agent copies this skeleton during
           /agent-plan Stage 4, works through every checklist section against the full
           set of planning artifacts, and issues the go/no-go verdict that gates the
           engineering stage.

  HOW TO CUSTOMIZE:
  - Replace [MILESTONE_NAME] with the milestone under review.
  - Fill in every Inputs Reviewed path — all five inputs are mandatory; write "None"
    only when a review stage produced no findings file. Exceptions: the UI Spec row
    reads "N/A — no ui agent installed" when the project has no ui agent, and a
    conditionally skipped stage's row (light mode, or a full-mode skip) reads
    "N/A — <stage> skipped: <reason>".
  - Work through all five checklist sections. Do not skip any. Section 3 accepts
    "N/A — no ui agent installed" as its content in no-ui projects; Sections 3
    and 4 accept "N/A — <stage> skipped: <reason>" for a conditionally skipped
    stage (a flagged-in stage gets a real section).
  - Record Revision Requests when returning REVISION REQUIRED, and Approval Conditions
    (with a Verified By owner) when returning APPROVED WITH CONDITIONS.
  - Record the verdict as the single `**Verdict**:` line in the Verdict section, with
    exactly one of the three strings verbatim: APPROVED / APPROVED WITH CONDITIONS /
    REVISION REQUIRED — the /agent-plan and /agent-code skills parse that line.
  - Instance destination: artifacts/milestone-{N}-{slug}/reviews/ceo.md. Never fill
    this template in place.
  - Sections marked (required) must be present and non-empty in every instance;
    (optional) sections may be omitted. The CEO gate checks required sections.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# CEO Review: [MILESTONE_NAME]


## Header (required)

**Date**: [DATE]
**Reviewer**: CEO Agent
**Inputs Reviewed**:
- Milestone: [PATH_TO_MILESTONE_DOC]
- Task Breakdown: [PATH_TO_TASKS_DOC — list every tasks/task-{T}-{slug}.md file reviewed]
- Architecture: [PATH_TO_ARCH_DOC]
- UI Spec: [PATH_TO_UI_SPEC — or "N/A — no ui agent installed" for no-ui projects]
- Risk Review: [PATH_OR_NONE]

**Review Cycle**: [v1 for first review; v2, v3, etc. for re-reviews of revised plans]

On any re-review, run `git log`/`git diff` on the changed input files FIRST to see what actually moved, then verify the body reflects the claimed change. A revision claimed is not a revision made.

---

## 1. Scope & Business Intent (required)

- [ ] Milestone goals are clear and measurable.
- [ ] Acceptance criteria are testable.
- [ ] Scope is appropriate for a single milestone (not overloaded, not trivial).
- [ ] The milestone advances a stated product objective.

**Notes**:

---

## 2. Architectural Soundness (required)

- [ ] Architecture document covers every module touched by the milestone.
- [ ] Data schemas are versioned and migration-safe.
- [ ] Module boundaries align with the feature scope.
- [ ] No hidden dependencies on unplanned work.

**Notes**:

---

## 3. UI & User Experience (required)

_If the project installed no `ui` agent, write "N/A — no ui agent installed" as this section's Notes and leave the checklist unchecked — the section must still be present._

- [ ] UI spec covers every screen or component the milestone introduces.
- [ ] Interaction states (default, pressed, disabled, loading, error, empty) are specified.
- [ ] UI spec is consistent with the architecture (state shape, events, data flow).
- [ ] Accessibility considerations are recorded.

**Notes**:

---

## 4. Risk Posture (required)

_Both lenses of the Risk review. If a lens found nothing, say so — an empty lens is a result._

- [ ] Every Critical and High security finding has a remediation plan inside this milestone.
- [ ] No Critical finding is deferred to "future work" without explicit Product acceptance.
- [ ] New dependencies introduced by the architecture have been reviewed.
- [ ] The milestone respects the project's performance budgets; hot paths have a measurement plan.
- [ ] No budget violation is deferred without explicit Product acceptance.
- [ ] Both flag lines in `reviews/risk.md` are set, and their values match what the plan actually touches.

**Notes**:

---

## 5. Cross-Cutting Risks (required)

- [ ] No UI requirement contradicts the architecture.
- [ ] No architecture decision contradicts a Product acceptance criterion.
- [ ] No security/performance finding invalidates a task in the milestone.
- [ ] The milestone's tasks collectively satisfy every acceptance criterion.
- [ ] Every task file's Context Manifest is complete and minimal — the task is executable from the task file plus its manifest alone, and no entry forces an unnecessary read. (A manifest an engineering agent must patch mid-loop is a planning defect this gate exists to catch.)

**Notes**:

---

## Revision Requests (optional)

| # | Addressed To | Section | Required Change |
|---|---|---|---|
| | | | |

---

## Approval Conditions (for APPROVED WITH CONDITIONS) (optional)

| # | Condition | Verified By | Verified At |
|---|---|---|---|
| | | | |

---

## Verdict (required)

**Verdict**: <APPROVED | APPROVED WITH CONDITIONS | REVISION REQUIRED>

Write exactly one of the three values on the line above — `/agent-plan` and `/agent-code` parse the `**Verdict**:` line. Meaning of each value:

- **APPROVED** — Milestone may proceed to the engineering stage. No outstanding revisions.
- **APPROVED WITH CONDITIONS** — Milestone may proceed. Coder must satisfy the Approval Conditions above; Reviewer and Product verify on completion.
- **REVISION REQUIRED** — Milestone returned to the named agents. See Revision Requests. Re-review after revisions.

**Verdict Notes**:
