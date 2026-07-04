<!-- TEMPLATE INSTRUCTIONS
  FILE: DESIGN_RATIONALE.md
  PURPOSE: This is the project's decision log. Every significant design or technical
  decision — one that narrows future options, reflects a real trade-off, or required
  non-trivial deliberation — should have an entry here. The purpose is to prevent the
  same debates from recurring, to help new contributors understand why the project is the
  way it is, and to create an audit trail for decisions that may need to be revisited.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Add new decisions by copying the "Decision Entry Template" section.
  - Fill in the category sections with real decisions as they are made during development.
  - Do not delete old entries, even when a decision is reversed. Instead, add a new entry
    that records the reversal and references the original.
  - "Decided by" can be a person's name, a team, or "team consensus". For AI-assisted
    decisions, note "author + AI review" or similar.
  - Keep entries concise. If a decision requires extensive explanation, write a separate
    document and link to it from the Rationale field.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Design Rationale

This document records significant design and technical decisions made during the
development of [PROJECT_NAME]. Entries are organized by category and listed in
reverse chronological order within each category (most recent first).

---

## Purpose

A decision is significant enough to record here if any of the following are true:

- It required choosing between two or more viable alternatives.
- Reversing it would require meaningful rework.
- A reasonable contributor could look at the result and wonder "why did they do it this way?"
- It involves a trade-off that was accepted knowingly.

If a decision was obvious, required no deliberation, and has no meaningful alternative,
it does not need an entry here.

**Scope vs. Architect's Decisions Log:** Each agent has its own Decisions Log (in `artifacts/AGENT_STATE.md`, one section per agent — the architect section especially) for milestone-scoped architectural choices made during that agent's work. This document is for project-wide decisions that span milestones or outlast any single agent's scope — e.g., "why SQLite over Postgres," "why this state management pattern," "why monorepo." If a milestone-specific architectural decision turns out to have project-wide implications, promote it here with a reference to the original.

---

## Decision Entry Template

Copy this block for each new decision:

```
### [DECISION_TITLE]

**Decision:** [One or two sentences stating the decision that was made, in the past tense.
"We decided to..." or "The team chose to..."]

**Rationale:** [Why was this decision made? What factors made this the best option?
Reference specific goals from PRD.md or CONCEPT.md where applicable.]

**Trade-offs accepted:**
- [Trade-off 1: what was given up or made harder by this choice]
- [Trade-off 2: what risk was accepted]
- [Trade-off 3: what alternative was rejected and why]

**Decided by:** [Name, team, or process]
**Date:** [YYYY-MM or "Milestone [NAME]" — avoid precise dates in this document]
```

---

## Product Design

<!-- Add entries here as product design decisions are made. -->
<!-- Use the template above. Most recent entries go at the top of this section. -->

*No entries yet. Add the first entry when a product design decision is finalized.*

---

## UI Design

<!-- Add entries here as UI design decisions are made. -->

*No entries yet.*

---

## Architecture Design

<!-- Add entries here as architecture design decisions are made. -->

*No entries yet.*

---

## Security Design

<!-- Add entries here as security design decisions are made. -->

*No entries yet.*

---

## Technical Decisions

<!-- Add entries here as significant architectural or implementation decisions are made. -->

*No entries yet.*

---

## Reversed Decisions

When a decision is reversed, move the original entry here and add a new entry above
explaining the reversal. Do not delete original entries.

*No reversed decisions yet.*

---

_Last updated: [YYYY-MM-DD]_
