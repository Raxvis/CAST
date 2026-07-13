<!-- TEMPLATE INSTRUCTIONS
  FILE: MILESTONE_VALIDATION.md
  PURPOSE: Milestone validation record template. The document instance is milestone-grain
           only: the Product Agent fills the whole document once, at the /agent-code
           milestone-completion checkpoint, to formally verify that the milestone's
           requirements have been met.
           The "Task Validation Checklist" section also serves a second, lighter use:
           during /agent-code Step 4 (Product validation) Product applies it to each task
           as *criteria* only — the per-task outcome is recorded as the task's Status in
           the milestone tasks file plus a `progress` entry in artifacts/STANDUP.md, and
           NO per-task document is created. (/agent-task validates against the task
           description instead and does not use this template.)

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace [MILESTONE_NAME] with the specific milestone being validated (e.g., "M2: Core Loop").
  - Replace [VALIDATOR] with the name or role of the person or agent conducting the validation.
  - In the milestone-grain instance, duplicate the Task Validation Checklist section once
    per validated task; fill in every field and do not skip sections. (Mid-milestone, the
    checklist is applied as criteria only — see PURPOSE above; no per-task instance.)
  - Fill in the Milestone Validation Checklist with the specific acceptance criteria for
    this milestone.
  - Rename the "User Validation Feedback Log" section to match your review process
    (e.g., "User Testing", "QA Session", "Demo Review", "Playtesting").
  - Duplicate a Regression Checklist block per major feature area.
  - Update Known Issues with any bugs or gaps discovered during validation.
  - Set the final Validation Status to one of: Approved / Approved with Notes / Changes Requested.
  - Reference any linked milestone task documents in the Completion Reports section.
  - Instance destination: artifacts/milestones/milestone-{N}-{slug}-validation.md.
    Never fill this template in place.
  - Sections marked (required) must be present and non-empty in every instance;
    (optional) sections may be omitted. Reviewer and Product check required sections.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Milestone Validation Report

## Revision History (required)

| # | Date | Agent | Reason |
|---|---|---|---|
| v1 | [DATE] | product | Initial version |

---

## Header (required)

| Field | Value |
|-------|-------|
| **Milestone** | [MILESTONE_NAME] |
| **Validation Date** | [YYYY-MM-DD] |
| **Validator** | [VALIDATOR] |
| **Status** | Pending / In Progress / Complete |

---

## Executive Summary (required)

[2–4 sentences summarizing the outcome of this validation. State what was tested, what passed, what failed, and whether the milestone is approved for completion.]

---

## Task Validation Checklist (required)

_Duplicate this section for each task validated by the Product Agent. Fill in every field. Do not skip sections. (This section also defines the criteria Product applies per task at Step 4 mid-milestone — there, the outcome goes into the tasks file's Status plus a STANDUP `progress` entry; no per-task document is produced.)_

### Task Validation: [TASK_NAME]

**Date**: [DATE]
**Reviewer**: Product Agent
**Milestone**: [MILESTONE_NAME]

#### Functional Validation

- [ ] All acceptance criteria from the task definition are met
- [ ] Feature behaves correctly under normal usage
- [ ] Feature behaves correctly under edge cases (empty state, maximum values, error states)
- [ ] No regressions in adjacent features

**Notes**:

#### Visual Validation

- [ ] Matches the UI specification (layout, spacing, typography, color)
- [ ] All interactive states are implemented (default, pressed, disabled, loading, error, empty)
- [ ] Visual feedback is present for all user actions
- [ ] Animations and transitions (if specified) are implemented

**Notes**:

#### Data Validation

- [ ] Data persists correctly across sessions (if applicable)
- [ ] Data displays correctly in all formatting edge cases (zero, very large, very small, null)
- [ ] No data is lost or corrupted in error scenarios

**Notes**:

#### Integration Validation

- [ ] Feature integrates correctly with adjacent features
- [ ] No unintended side effects on other parts of the system
- [ ] Events, callbacks, and state updates flow correctly end-to-end

**Notes**:

#### Code Quality

- [ ] Code follows the project's style conventions (reviewed with Architecture if complex)
- [ ] No placeholder code, debug output, or commented-out blocks left in
- [ ] New modules/functions are appropriately named

**Notes**:

#### Testing

- [ ] Manually tested on each target platform ([TARGET_PLATFORMS])
- [ ] Edge cases were tested, not just the happy path

**Notes**:

#### Issues Found

| # | Description | Severity | Blocking? |
|---|---|---|---|
| | | | |

#### Sign-Off

- [ ] **APPROVED** — Task is complete. No further action required.
- [ ] **APPROVED WITH NOTES** — Task is complete. Non-blocking issues noted above.
- [ ] **REJECTED** — Task is returned to Coder. See Issues Found for required changes.

**Sign-Off Notes**:

---

## Milestone Validation Checklist (required)

### Functionality (required)

| # | Requirement | Acceptance Criteria | Status | Notes |
|---|-------------|--------------------|----|-------|
| F1 | [Requirement] | [Specific, testable criteria] | Pass / Fail / N/A | |
| F2 | [Requirement] | [Specific, testable criteria] | Pass / Fail / N/A | |
| F3 | [Requirement] | [Specific, testable criteria] | Pass / Fail / N/A | |

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
| T2 | [Scenario name] | [Brief steps] | [Expected result] | [Actual result] | Pass / Fail |

---

## User Validation Feedback Log (optional)

_Rename this section to match your review process (e.g., "User Testing", "QA Session", "Demo Review"). Duplicate the session block per session._

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

#### Summary

[Overall impression and priority actions]

---

## Regression Testing (required)

_Duplicate a checklist block for each major feature area._

### [FEATURE_AREA_1] — Regression Checklist

- [ ] [CHECK_1]
- [ ] [CHECK_2]
- [ ] [CHECK_3]

### [FEATURE_AREA_2] — Regression Checklist

- [ ] [CHECK_1]
- [ ] [CHECK_2]
- [ ] [CHECK_3]

---

## Known Issues (required)

### Resolved During Validation (required)

| ID | Description | Resolution |
|----|-------------|------------|
| | | |

### Open (Must Resolve Before Milestone Closes) (required)

| ID | Description | Severity | Owner | Target Date |
|----|-------------|----------|-------|------------|
| | | | | |

_Deferred items that Product re-triaged at the milestone-completion checkpoint and kept Deferred do NOT belong here and do not block closing the milestone — they are listed under Known Issues in the completion report ("Complete with Deferrals") and are re-triaged again at the next `/agent-plan` Stage 1._

---

## Blockers for Remaining Tasks (optional)

_Issues that will prevent subsequent milestones from starting or proceeding._

| Blocker | Impact | Owner |
|---------|--------|-------|
| | | |

---

## Recommendations (optional)

### Immediate (Before Milestone Closes) (optional)

1. [Recommendation]

### For Next Milestone (optional)

1. [Recommendation]

---

## Completion Reports (required)

Links or references to related task breakdown documents for this milestone:

- [MILESTONE_TASKS.md or equivalent] — [brief description]

---

## Validation Status (required)

**Status**: Approved / Approved with Notes / Changes Requested

**Signed off by**: [NAME or ROLE]
**Date**: [YYYY-MM-DD]

**Notes**:
> [Any conditions attached to approval, or reasons for requesting changes.]

---

_Last updated: [YYYY-MM-DD]_
