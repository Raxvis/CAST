<!-- TEMPLATE INSTRUCTIONS
  FILE: MILESTONE_DEFINITION.md
  PURPOSE: Template for the milestone definition artifact produced by the Product
  agent during /agent-plan Stage 1. A milestone definition describes WHAT the
  milestone is and WHY it matters. The task-level breakdown ("how") lives in a
  separate sibling file using templates/MILESTONE_TASKS.md as its template.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace [MILESTONE_NAME] with the milestone title (e.g., "M2: Core Loop").
  - Replace [REQUIREMENTS_REFERENCE] with a link or section reference to the
    relevant requirements document (PRD section, feature spec, etc.).
  - Fill in every field in the Header and Body — empty fields are a signal to
    the CEO that planning is incomplete.
  - Keep this template-instruction block when copying the file; fill in the body,
    then delete this block from the instance file.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — [MILESTONE_NAME]

## Revision History

| # | Date | Agent | Reason |
|---|---|---|---|
| v1 | [YYYY-MM-DD] | product | Initial version |

---

## Header

| Field | Value |
|-------|-------|
| **Milestone ID** | [M#] |
| **Slug** | [kebab-case short name, e.g. `user-auth`] |
| **Owner** | Product agent |
| **Status** | Planning / CEO-Approved / In Progress / Complete / Deferred |
| **Requirements Reference** | [REQUIREMENTS_REFERENCE] |
| **Estimated Effort** | [e.g., 2–3 days / 1 week / one sprint] |
| **Depends On** | [List of prior milestone IDs that must be complete, or "None"] |
| **Related Task Breakdown** | `artifacts/milestones/milestone-[M#]-[slug]-tasks.md` |

---

## Goal

_One clear sentence describing what completing this milestone achieves for the user or the product. Not a list of tasks — a single outcome statement. Example: "Users can create, complete, and delete tasks from the command line with their data persisted across runs."_

[Fill in]

---

## Why This Matters

_2-4 sentences explaining why this milestone is on the roadmap at all. What user pain does it relieve? What future work does it unblock? What will the product not be able to do without it? This is the paragraph the CEO reads first during planning review._

[Fill in]

---

## Success Metrics

_Concrete, measurable outcomes that indicate the milestone is successful. Prefer observable behaviors and thresholds over feelings. At least 2, at most 6._

- [ ] [Metric 1 — e.g., "All four CRUD commands execute in under 100ms on a database with 1000 tasks"]
- [ ] [Metric 2 — e.g., "Test coverage on `src/commands/` is ≥ 90%"]
- [ ] [Metric 3 — e.g., "Users can recover from a corrupt database without losing more than the current session's writes"]

---

## In Scope

_Bulleted list of features, modules, or behaviors that belong in this milestone. Be specific. The tasks file will break each of these down into implementable work items._

- [In-scope item 1]
- [In-scope item 2]
- [In-scope item 3]

---

## Out of Scope

_Explicit list of closely-related things that are NOT in this milestone. Every item here is a future-work candidate or an explicit rejection. Use this section to prevent scope creep — if something shows up in the task breakdown that is not also listed in In Scope, it should either be moved here or added above._

- [Out-of-scope item 1]
- [Out-of-scope item 2]
- [Out-of-scope item 3]

---

## Top-Level Acceptance Criteria

_The criteria the CEO uses to decide whether the completed milestone is done. These are broader than per-task acceptance criteria (which live in the task breakdown file) — they are milestone-level outcomes that cut across tasks._

- [ ] [Criterion 1 — e.g., "All four commands (add, list, done, delete) pass their per-task acceptance criteria"]
- [ ] [Criterion 2 — e.g., "Full test suite passes on fresh and existing databases"]
- [ ] [Criterion 3 — e.g., "No Critical security findings remain open"]
- [ ] [Criterion 4 — e.g., "Performance budget respected for all commands"]

---

## Dependencies and Risks

_List any external dependencies (libraries, services, prior milestones, team decisions) and any risks that could delay or invalidate the milestone. Each risk should have a proposed mitigation or a note saying "accepted"._

| Type | Item | Mitigation / Status |
|---|---|---|
| Dependency | [e.g., "better-sqlite3 package"] | [e.g., "pinned in package.json"] |
| Risk | [e.g., "SQLite file locking on Windows"] | [e.g., "WAL mode enables concurrent reads; accepted"] |

---

## Cross-Cutting Concerns

_Anything that touches multiple tasks in this milestone and needs to be specified once at the milestone level rather than repeated per-task. Examples: error-handling conventions, logging requirements, shared naming rules, the set of platforms that must be tested._

- [Concern 1]
- [Concern 2]

---

## References

- **PRD section(s):** [PRD link or section anchor]
- **Architecture document:** `artifacts/architecture/arch-milestone-[M#].md`
- **UI specification:** `artifacts/ui-specs/ui-milestone-[M#].md`
- **Task breakdown:** `artifacts/milestones/milestone-[M#]-[slug]-tasks.md`
- **CEO review:** `artifacts/reviews/ceo-review-milestone-[M#].md`

---

_Last updated: [YYYY-MM-DD]_
