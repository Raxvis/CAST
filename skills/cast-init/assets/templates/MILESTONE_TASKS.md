<!-- TEMPLATE INSTRUCTIONS
  FILE: MILESTONE_TASKS.md
  PURPOSE: Task breakdown for a single milestone. Use this document to list all tasks
           required to complete a milestone, track their status, define acceptance criteria,
           and reference supporting architecture and UI specification documents.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace [MILESTONE_NAME] with the milestone title (e.g., "M2: Core Loop").
  - Replace [REQUIREMENTS_REFERENCE] with a link or section reference to the relevant
    requirements document (e.g., PRD section, feature spec).
  - Add a row to the Summary table for each task in this milestone.
  - Copy the Task Template block for each task and fill in all fields.
  - Task IDs should follow a consistent format (e.g., M2-T01, M2-T02).
  - Status values: Not Started / In Progress / Blocked / Complete / Deferred.
  - Needs Arch Doc / Needs UI Spec live ONLY in each task's per-task field table
    (Yes / No / Done → link) — they are deliberately not repeated in the Summary table.
  - Dependencies: List task IDs that must be complete before this task can start, or "None".
  - The milestone Goal lives in the milestone definition file (MILESTONE_DEFINITION.md
    instance) — do not restate it here.
  - The CEO Approval Conditions section is filled after the CEO verdict; keep it.
  - Sections marked (required) must be present and non-empty in every instance;
    (optional) sections may be omitted. The CEO gate checks required sections.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — [MILESTONE_NAME] Task Breakdown

## Revision History (required)

| # | Date | Agent | Reason |
|---|---|---|---|
| v1 | [YYYY-MM-DD] | product | Initial version |

---

## Header (required)

| Field | Value |
|-------|-------|
| **Definition** | see `milestone-[M#]-[slug].md` |
| **Status** | Not Started / In Progress / Blocked / Complete |
| **Requirements Reference** | [REQUIREMENTS_REFERENCE] |

---

## Summary (required)

| Task ID | Task Name | Status | Dependencies |
|---------|-----------|--------|-------------|
| [M#-T01] | [Task name] | Not Started | None |
| [M#-T02] | [Task name] | Not Started | [M#-T01] |
| [M#-T03] | [Task name] | Not Started | [M#-T01] |
| [M#-T04] | [Task name] | Not Started | [M#-T02], [M#-T03] |

---

## CEO Approval Conditions (required)

_Filled after the CEO verdict. Coder tracks each condition during engineering; Reviewer and Product verify at completion._

| Condition | Source | Status |
|-----------|--------|--------|
| [Condition text, or "None — verdict was APPROVED"] | `artifacts/reviews/ceo-review-milestone-[M#].md` | Open / Addressed / Verified |

---

## Tasks (required)

---

### [M#-T01]: [Task Name]

| Field | Value |
|-------|-------|
| **Status** | Not Started / In Progress / Blocked / Complete |
| **Dependencies** | None / [Task IDs] |
| **Needs Arch Doc** | Yes / No / Done → `[link or filename]` |
| **Needs UI Spec** | Yes / No / Done → `[link or filename]` |

**Description**:
[Detailed description of what needs to be built or changed. Include enough context for an engineer to begin work without additional clarification.]

**Files** (expected to create or modify):
- `[path/to/file]` — [what changes in this file]
- `[path/to/file]` — [what changes in this file]

**Acceptance Criteria**:
- [ ] [Specific, testable criterion — e.g., "Function X returns Y when given input Z"]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] No linter or type-check errors introduced
- [ ] Manually tested on [PLATFORM(s)]

---

### [M#-T02]: [Task Name]

| Field | Value |
|-------|-------|
| **Status** | Not Started / In Progress / Blocked / Complete |
| **Dependencies** | [M#-T01] |
| **Needs Arch Doc** | Yes / No / Done → `[link or filename]` |
| **Needs UI Spec** | Yes / No / Done → `[link or filename]` |

**Description**:
[Detailed description of what needs to be built or changed.]

**Files** (expected to create or modify):
- `[path/to/file]` — [what changes in this file]
- `[path/to/file]` — [what changes in this file]

**Acceptance Criteria**:
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] No linter or type-check errors introduced
- [ ] Manually tested on [PLATFORM(s)]

---

### [M#-T03]: [Task Name]

| Field | Value |
|-------|-------|
| **Status** | Not Started / In Progress / Blocked / Complete |
| **Dependencies** | [M#-T01] |
| **Needs Arch Doc** | Yes / No / Done → `[link or filename]` |
| **Needs UI Spec** | Yes / No / Done → `[link or filename]` |

**Description**:
[Detailed description of what needs to be built or changed.]

**Files** (expected to create or modify):
- `[path/to/file]` — [what changes in this file]
- `[path/to/file]` — [what changes in this file]

**Acceptance Criteria**:
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] No linter or type-check errors introduced
- [ ] Manually tested on [PLATFORM(s)]

---

### [M#-T04]: [Task Name]

| Field | Value |
|-------|-------|
| **Status** | Not Started / In Progress / Blocked / Complete |
| **Dependencies** | [M#-T02], [M#-T03] |
| **Needs Arch Doc** | Yes / No / Done → `[link or filename]` |
| **Needs UI Spec** | Yes / No / Done → `[link or filename]` |

**Description**:
[Detailed description of what needs to be built or changed.]

**Files** (expected to create or modify):
- `[path/to/file]` — [what changes in this file]
- `[path/to/file]` — [what changes in this file]

**Acceptance Criteria**:
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] No linter or type-check errors introduced
- [ ] Manually tested on [PLATFORM(s)]

---

## Task Template

_Copy this block to add a new task._

```
### [M#-TXX]: [Task Name]

| Field | Value |
|-------|-------|
| **Status** | Not Started |
| **Dependencies** | None / [Task IDs] |
| **Needs Arch Doc** | Yes / No |
| **Needs UI Spec** | Yes / No |

**Description**:
[Description]

**Files** (expected to create or modify):
- `[path/to/file]` — [what changes]

**Acceptance Criteria**:
- [ ] [Criterion]
- [ ] [Criterion]
- [ ] No linter or type-check errors introduced
- [ ] Manually tested on [PLATFORM(s)]
```

---

_Last updated: [YYYY-MM-DD]_
