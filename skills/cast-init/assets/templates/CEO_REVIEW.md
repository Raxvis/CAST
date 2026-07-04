<!-- TEMPLATE INSTRUCTIONS
  FILE: CEO_REVIEW.md
  PURPOSE: CEO planning-review template. The CEO Agent copies this skeleton during
           /agent-plan Stage 4, works through every checklist section against the full
           set of planning artifacts, and issues the go/no-go verdict that gates the
           engineering stage.

  HOW TO CUSTOMIZE:
  - Replace [MILESTONE_NAME] with the milestone under review.
  - Fill in every Inputs Reviewed path — all six inputs are mandatory; write "None"
    only when a review stage produced no findings file.
  - Work through all six checklist sections. Do not skip any.
  - Record Revision Requests when returning REVISION REQUIRED, and Approval Conditions
    (with a Verified By owner) when returning APPROVED WITH CONDITIONS.
  - Issue exactly one of the three verdicts verbatim: APPROVED / APPROVED WITH
    CONDITIONS / REVISION REQUIRED — the /agent-plan and /agent-code skills key on
    these strings.
  - Instance destination: artifacts/reviews/ceo-review-milestone-{N}.md. Never fill
    this template in place.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# CEO Review: [MILESTONE_NAME]

## Revision History

| # | Date | Agent | Reason |
|---|---|---|---|
| v1 | [DATE] | ceo | Initial review |

---

## Header

**Date**: [DATE]
**Reviewer**: CEO Agent
**Inputs Reviewed**:
- Milestone: [PATH_TO_MILESTONE_DOC]
- Task Breakdown: [PATH_TO_TASKS_DOC]
- Architecture: [PATH_TO_ARCH_DOC]
- UI Spec: [PATH_TO_UI_SPEC]
- Security Findings: [PATH_OR_NONE]
- Performance Findings: [PATH_OR_NONE]

**Review Cycle**: [v1 for first review; v2, v3, etc. for re-reviews of revised plans]

On any re-review, read the `## Revision History` table at the top of every input file FIRST. Identify which of your prior Revision Requests have been addressed and which have not. An entry in the revision history is not the same as a fix — verify the body of each file reflects the claimed change.

---

## 1. Scope & Business Intent

- [ ] Milestone goals are clear and measurable.
- [ ] Acceptance criteria are testable.
- [ ] Scope is appropriate for a single milestone (not overloaded, not trivial).
- [ ] The milestone advances a stated product objective.

**Notes**:

---

## 2. Architectural Soundness

- [ ] Architecture document covers every module touched by the milestone.
- [ ] Data schemas are versioned and migration-safe.
- [ ] Module boundaries align with the feature scope.
- [ ] No hidden dependencies on unplanned work.

**Notes**:

---

## 3. UI & User Experience

- [ ] UI spec covers every screen or component the milestone introduces.
- [ ] Interaction states (default, pressed, disabled, loading, error, empty) are specified.
- [ ] UI spec is consistent with the architecture (state shape, events, data flow).
- [ ] Accessibility considerations are recorded.

**Notes**:

---

## 4. Security Posture

- [ ] All Critical and High findings have a remediation plan inside this milestone.
- [ ] No Critical finding is deferred to "future work" without explicit Product acceptance.
- [ ] New dependencies introduced by the architecture have been reviewed.

**Notes**:

---

## 5. Performance Budget

- [ ] The milestone respects the project's performance budgets.
- [ ] Hot paths are identified and have a measurement plan.
- [ ] No budget violation is deferred without explicit Product acceptance.

**Notes**:

---

## 6. Cross-Cutting Risks

- [ ] No UI requirement contradicts the architecture.
- [ ] No architecture decision contradicts a Product acceptance criterion.
- [ ] No security/performance finding invalidates a task in the milestone.
- [ ] The milestone's tasks collectively satisfy every acceptance criterion.

**Notes**:

---

## Revision Requests

| # | Addressed To | Section | Required Change |
|---|---|---|---|
| | | | |

---

## Approval Conditions (for APPROVED WITH CONDITIONS)

| # | Condition | Verified By | Verified At |
|---|---|---|---|
| | | | |

---

## Verdict

- [ ] **APPROVED** — Milestone may proceed to the engineering stage. No outstanding revisions.
- [ ] **APPROVED WITH CONDITIONS** — Milestone may proceed. Coder must satisfy the Approval Conditions above; Reviewer and Product verify on completion.
- [ ] **REVISION REQUIRED** — Milestone returned to the named agents. See Revision Requests. Re-review after revisions.

**Verdict Notes**:
