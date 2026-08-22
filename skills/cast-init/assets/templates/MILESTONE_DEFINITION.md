<!-- TEMPLATE INSTRUCTIONS
  FILE: MILESTONE_DEFINITION.md
  PURPOSE: Template for the milestone README — the highest-order document of a milestone
  directory, produced by the Product agent during /agent-plan Stage 1 as
  artifacts/milestone-{N}-{slug}/README.md. It describes WHAT the milestone is and WHY it
  matters, indexes the milestone's per-task files (tasks/task-{T}-{slug}.md, one instance
  of templates/TASK.md each), and carries the milestone Status and the CEO Approval
  Conditions. Task-level detail ("how") lives in the task files, one per task.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace [MILESTONE_NAME] with the milestone title (e.g., "M2: Core Loop").
  - Replace [REQUIREMENTS_REFERENCE] with a link or section reference to the
    relevant requirements document (PRD section, feature spec, etc.).
  - Fill in every field in the Header and Body — empty fields are a signal to
    the CEO that planning is incomplete.
  - Copy the file with this instruction block intact and use it while filling in the
    body, then delete the block from the instance before handing the milestone off.
  - Sections marked (required) must be present and non-empty in every instance;
    (optional) sections may be omitted. The CEO gate checks required sections.
-->

<!-- Placeholders: bracketed UPPER_SNAKE_CASE tokens are project values filled at
     adoption; bracketed lowercase names are per-use fill-ins. -->

# [PROJECT_NAME] — [MILESTONE_NAME]


## Header (required)

| Field | Value |
|-------|-------|
| **Milestone ID** | [M#] |
| **Slug** | [kebab-case short name, e.g. `user-auth`] |
| **Owner** | Product agent |
| **Status** | Planning / CEO-Approved / In Progress / Complete / Complete with Deferrals |
| **Requirements Reference** | [REQUIREMENTS_REFERENCE] |
| **Estimated Effort** | [e.g., 2–3 days / 1 week / one sprint] |
| **Depends On** | [List of prior milestone IDs that must be complete, or "None"] |

---

## Goal (required)

_One clear sentence describing what completing this milestone achieves for the user or the product. Not a list of tasks — a single outcome statement. Example: "Users can create, complete, and delete tasks from the command line with their data persisted across runs."_

[Fill in]

---

## Why This Matters (required)

_2-4 sentences explaining why this milestone is on the roadmap at all. What user pain does it relieve? What future work does it unblock? What will the product not be able to do without it? This is the paragraph the CEO reads first during planning review._

[Fill in]

---

## Success Metrics (required)

_Concrete, measurable outcomes that indicate the milestone is successful. Prefer observable behaviors and thresholds over feelings. At least 2, at most 6._

- [ ] [Metric 1 — e.g., "All four CRUD commands execute in under 100ms on a database with 1000 tasks"]
- [ ] [Metric 2 — e.g., "Test coverage on `src/commands/` is ≥ 90%"]
- [ ] [Metric 3 — e.g., "Users can recover from a corrupt database without losing more than the current session's writes"]

---

## In Scope (required)

_Bulleted list of features, modules, or behaviors that belong in this milestone. Be specific. The per-task files under `tasks/` will break each of these down into implementable work items._

- [In-scope item 1]
- [In-scope item 2]
- [In-scope item 3]

---

## Out of Scope (required)

_Explicit list of closely-related things that are NOT in this milestone. Every item here is a future-work candidate or an explicit rejection. Use this section to prevent scope creep — if something shows up in the task breakdown that is not also listed in In Scope, it should either be moved here or added above._

- [Out-of-scope item 1]
- [Out-of-scope item 2]
- [Out-of-scope item 3]

---

## Top-Level Acceptance Criteria (required)

_The criteria the CEO uses to decide whether the completed milestone is done. These are broader than per-task acceptance criteria (which live in the task breakdown file) — they are milestone-level outcomes that cut across tasks._

- [ ] [Criterion 1 — e.g., "All four commands (add, list, done, delete) pass their per-task acceptance criteria"]
- [ ] [Criterion 2 — e.g., "Full test suite passes on fresh and existing databases"]
- [ ] [Criterion 3 — e.g., "No Critical security findings remain open"]
- [ ] [Criterion 4 — e.g., "Performance budget respected for all commands"]

---

## Dependencies and Risks (required)

_List any external dependencies (libraries, services, prior milestones, team decisions) and any risks that could delay or invalidate the milestone. Each risk should have a proposed mitigation or a note saying "accepted"._

| Type | Item | Mitigation / Status |
|---|---|---|
| Dependency | [e.g., "better-sqlite3 package"] | [e.g., "pinned in package.json"] |
| Risk | [e.g., "SQLite file locking on Windows"] | [e.g., "WAL mode enables concurrent reads; accepted"] |

---

## Task Index (required)

_One row per task file under `tasks/`. Deliberately no status column — task status lives ONLY in each task file's Header, so it is never written twice. To check milestone progress, read the Status field across `tasks/task-*.md`._

| Task ID | Task Name | File | Dependencies |
|---------|-----------|------|--------------|
| [M#-T01] | [Task name] | `tasks/task-01-[slug].md` | None |
| [M#-T02] | [Task name] | `tasks/task-02-[slug].md` | [M#-T01] |

---

## CEO Approval Conditions (required)

_Filled after the CEO verdict (`reviews/ceo.md`). The orchestrator transcribes one row per row of that review's Approval Conditions table — the columns line up so nothing is lost: `#`, `Condition`, and `Verified By` come straight across, and `Verified At` holds `—` until the condition is verified. Coder tracks each condition during engineering; Reviewer's Acceptance Criteria Check carries one line per condition a task's manifest cites. **Product owns the flip to Verified**: while writing the close record (`reviews/close.md`) at the milestone-completion checkpoint, Product confirms each row's evidence, sets Status to Verified, and fills Verified At with the date — or leaves the row Open and lists it under the close record's Known Issues. Tasks a condition names carry a `../README.md § CEO Approval Conditions` row in their Context Manifest._

| # | Condition | Source | Verified By | Verified At | Status |
|---|-----------|--------|-------------|-------------|--------|
| [1] | [Condition text, or "None — verdict was APPROVED"] | `reviews/ceo.md` | [owner named in the CEO review] | [YYYY-MM-DD, or "—" while Open] | Open / Verified |

---

## Cross-Cutting Concerns (optional)

_Anything that touches multiple tasks in this milestone and needs to be specified once at the milestone level rather than repeated per-task. Examples: error-handling conventions, logging requirements, shared naming rules, the set of platforms that must be tested._

- [Concern 1]
- [Concern 2]

---

## References (required)

- **PRD section(s):** [PRD link or section anchor]

_Only the variable reference lives here — the milestone's fixed layout (`architecture.md`, `ui.md`, `tasks/`, `reviews/`) is `docs/FILE_CONVENTIONS.md`'s to define, not each README's to restate._

---

_Last updated: [YYYY-MM-DD]_
