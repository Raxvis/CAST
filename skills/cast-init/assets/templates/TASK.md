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
           full protocol lives in docs/PIPELINE_LOOP.md → "Handoff Protocol".

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
  - Context Manifest: Product seeds it at planning; Architect and UI append their document
    sections (with anchors) when they write the milestone design docs. Keep it minimal —
    every entry is a file another agent is forced to read.
  - Handoff Log: append-only, newest last. Every stage transition appends exactly one
    entry in the fixed format. No narrative recaps — max 10 lines per entry; anything
    longer belongs in the artifact the entry points to (bug file, review file, code).
    Exceptions: (a) Reviewer entries and Tester failure entries add one line per
    finding/failure beyond the fixed fields — for those stages this log IS the
    canonical record; never drop findings to fit the cap; (b) a Reviewer approval
    entry also carries the Acceptance Criteria Check block — one line per
    acceptance criterion, each Met (with evidence) / Not met / Product judgment.
    That block is what decides whether the task closes directly or spawns Product
    (docs/PIPELINE_LOOP.md → Step 4).
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
- [ ] No linter or type-check errors introduced
- [ ] Manually tested on [PLATFORM(s)]

---

## Context Manifest (required)

_The complete read set for this task. An agent working this task reads: (1) this file, (2) the entries below, (3) anything the latest Handoff Log entry lists under "Read next". Nothing else — do not re-read the milestone directory, prior tasks, or full design documents. Cite sections, not whole files, wherever possible._

| Reference | Sections | Why |
|---|---|---|
| `../architecture.md` | [§ anchor(s), e.g. "§ Data Schema"] | [what this task takes from it] |
| `../ui.md` | [§ anchor(s), or remove row if no UI work] | [what this task takes from it] |
| `../README.md` | § CEO Approval Conditions | [only if a condition names this task; otherwise remove row] |
| `docs/CODE_PATTERNS.md` | [§ anchor(s)] | [conventions this task must follow] |

---

## Handoff Log (required)

_Append-only; newest last. One entry per stage transition, fixed format, max 10 lines. The next agent starts from the latest entry._

### 1. [from-agent] → [to-agent] — [YYYY-MM-DD]

- **Outcome**: [one line — what was done or decided]
- **Files touched**: [paths, or "None"]
- **Commit**: [hash — only when this stage committed code per the Commit discipline in `docs/PIPELINE_LOOP.md`; omit the line otherwise]
- **Read next**: [file/section references the next agent needs BEYOND the Context Manifest, or "Manifest only"]
- **Open items**: [blockers, questions, or "None"]

_Reviewer approval entries add the criteria block below the fixed fields (omit it in every other entry):_

- **Acceptance Criteria Check**:
  - [1] [criterion text, verbatim] — Met — [evidence: commit, test name, or file:line]
  - [2] [criterion text, verbatim] — Product judgment — [what needs deciding]
  - [3] [criterion text, verbatim] — Not met — [what is missing]

---

_Last updated: [YYYY-MM-DD]_
