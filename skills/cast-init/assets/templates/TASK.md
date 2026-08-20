<!-- TEMPLATE INSTRUCTIONS
  FILE: TASK.md
  PURPOSE: Template for a SINGLE task file — the isolated, self-contained unit of work the
           engineering pipeline executes and the medium every agent-to-agent handoff travels
           through. One instance per task: milestone tasks live at
           artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md; one-off (/agent-task)
           tasks live at artifacts/one-off/task-{slug}.md.

           A task file must be executable in isolation: an agent picking it up reads THIS
           file plus exactly the references in its Context Manifest — nothing else. Handoffs
           are compact entries appended to the Handoff Log, not conversation context. The
           full contract lives in docs/STAGE_CONTRACT.md — the only process document an
           agent reads. Routing lives in docs/PIPELINE_LOOP.md, read by the
           orchestrating skill only.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Task IDs follow [M#]-T[##] for milestone tasks (e.g., M2-T01) or a short slug for
    one-off tasks.
  - Status values: Not Started / In Progress / Blocked / Complete / Deferred. Deferred is
    a held-open state, not terminal: /agent-code Task Selection skips Deferred tasks (as it
    does Complete ones), the milestone-completion checkpoint fires when every task file is
    Complete or Deferred, and Product re-triages Deferred tasks at that checkpoint and at
    the next /agent-plan Stage 1.
  - The Status field in the Header below is the ONLY place task status lives — the
    milestone README's Task Index deliberately carries no status column.
  - Acceptance Criteria: write only criteria Reviewer can settle from the diff and a test
    run — each needs an evidence pointer for the no-spawn Step 3a close. Never seed blanket
    criteria ("no linter errors", "manually tested on X"): the linter gate is Reviewer's
    checklist and manual testing is the close record's Critical Path Testing, and a
    criterion that cannot carry diff evidence forces a Product validation spawn on
    every task.
  - Context Manifest: Product seeds it at planning; Architect and UI append their document
    sections (with anchors) when they write the milestone design docs. Keep it minimal —
    every entry is a file another agent is forced to read.
  - Handoff Log: append-only, newest last; one fixed-format entry per stage transition.
    The entry format, 10-line cap, and its exceptions are defined once in
    docs/STAGE_CONTRACT.md §2 — deliberately not restated per instance (every stage
    of every task re-reads this file).
  - Sections marked (required) must be present and non-empty in every instance;
    (optional) sections may be omitted.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [M#-T##]: [Task Name]

## Header (required)

| Field | Value |
|-------|-------|
| **Milestone** | `../README.md` (or "One-off — /agent-task") |
| **Status** | Not Started / In Progress / Blocked / Complete / Deferred |
| **Dependencies** | None / [Task IDs] |
| **Needs Arch Doc** | Yes / No / Done → `[link]` |
| **Needs UI Spec** | Yes / No / Done → `[link]` |
| **Loop count** | 0 / [MAX_LOOP_COUNT] |

---

## Description (required)

[Detailed description of what needs to be built or changed. Include enough context for an engineer to begin work without additional clarification — this file plus the Context Manifest is everything they get.]

---

## Files (required)

_Expected to create or modify:_

- `[path/to/file]` — [what changes in this file]
- `[path/to/file]` — [what changes in this file]

---

## Acceptance Criteria (required)

- [ ] [Specific, testable criterion — e.g., "Function X returns Y when given input Z"]
- [ ] [Specific, testable criterion]

---

## Context Manifest (required)

_The complete read set for this task (`docs/STAGE_CONTRACT.md` §1). Cite sections, not whole files._

| Reference | Sections | Why |
|---|---|---|
| `../architecture.md` | [§ anchor(s), e.g. "§ Data Schema"] | [what this task takes from it] |
| `../ui.md` | [§ anchor(s), or remove row if no UI work] | [what this task takes from it] |
| `../README.md` | § CEO Approval Conditions | [only if a condition names this task; otherwise remove row] |
| `docs/CODE_PATTERNS.md` | [§ anchor(s)] | [conventions this task must follow] |

---

## Handoff Log (required)

_Append-only; newest last; one entry per stage transition. Entry format, the 10-line cap, and its exceptions (Coder's Test Results block, Reviewer's per-finding lines and Acceptance Criteria Check): `docs/STAGE_CONTRACT.md` §2._

### 1. [from-agent] → [to-agent] — [YYYY-MM-DD]

---

_Last updated: [YYYY-MM-DD]_
