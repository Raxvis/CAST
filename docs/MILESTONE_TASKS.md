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
  - Needs Arch Doc / Needs UI Spec: Yes / No / Done.
  - Dependencies: List task IDs that must be complete before this task can start, or "None".
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — [MILESTONE_NAME] Task Breakdown

---

## Header

| Field | Value |
|-------|-------|
| **Goal** | [One sentence describing what completing this milestone achieves.] |
| **Status** | Not Started / In Progress / Blocked / Complete |
| **Requirements Reference** | [REQUIREMENTS_REFERENCE] |

---

## Summary

| Task ID | Task Name | Status | Dependencies | Needs Arch Doc | Needs UI Spec |
|---------|-----------|--------|-------------|----------------|--------------|
| [M#-T01] | [Task name] | Not Started | None | No | No |
| [M#-T02] | [Task name] | Not Started | [M#-T01] | Yes | No |
| [M#-T03] | [Task name] | Not Started | [M#-T01] | No | Yes |
| [M#-T04] | [Task name] | Not Started | [M#-T02], [M#-T03] | No | No |

---

## Tasks

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

**Architecture Docs**: [Link to ARCH_MODULE.md, ARCH_SYSTEM.md, or "None required"]

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

**Architecture Docs**: [Link or "None required"]

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

**Architecture Docs**: [Link or "None required"]

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

**Architecture Docs**: [Link or "None required"]

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

**Architecture Docs**: [Link or "None required"]
```

---

_Last updated: [YYYY-MM-DD]_
