<!-- TEMPLATE INSTRUCTIONS
  FILE: ADDITIONAL.md
  PURPOSE: This document contains extended design detail that is true to the project's
  vision but too granular or voluminous to live comfortably in PRD.md. It covers advanced
  systems, detailed specifications, integration details, and post-launch plans. The PRD
  says "what must be true"; this document says "here is exactly how it works in detail".

  HOW TO CUSTOMIZE:
  - Use the Additional Item Template below to add new entries.
  - Delete the template example once you have real entries.
  - If a section grows very large, consider splitting it into its own file and linking to
    it from here.
  - This document should be kept in sync with PRD.md. If a design decision changes,
    update both files.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Extended Design Details

---

## Additional Item Template

_Copy this block for each new extended design detail. Replace all bracketed placeholders._

```
## [ITEM_TITLE]

> **NOTE TO AUTHOR:** [Optional note about when to include or delete this section.]

**Summary:** [One-sentence description of what this item covers and why it exists as an
extended detail rather than in the PRD.]

**Related PRD Section:** [Reference to the PRD section this expands on, or "N/A" if standalone.]

---

### Overview

[One to three paragraphs explaining the design in detail. Include the "why" behind decisions,
not just the "what".]

### Specification

[Detailed specification: formulas, tables, rules, constraints, sequences, or any structured
information that defines how this system works. Use tables, code blocks, or lists as appropriate.]

### Balance / Pacing Targets (if applicable)

| Metric | Target | Notes |
|--------|--------|-------|
| [METRIC_1] | [TARGET] | [NOTES] |
| [METRIC_2] | [TARGET] | [NOTES] |

### Open Questions

| # | Question | Owner | Resolution |
|---|----------|-------|------------|
| 1 | [QUESTION] | [AGENT] | [Pending / Answer] |
```

---

## Common Entry Types

Typical entries in this document include:

- **Advanced design patterns** — Detailed rules or algorithms too granular for the PRD.
- **Coding rules** — Project-specific coding constraints beyond what CODE_PATTERNS.md covers.
- **Integration specifications** — Details on third-party service integrations or API contracts.
- **Post-launch plans** — Detailed plans for features deferred beyond MVP.
- **Domain-specific formulas** — Calculations, scaling curves, or business rules.

If an entry does not expand on something in the PRD or CONCEPT.md, consider whether it
belongs in a different document (e.g., CODE_PATTERNS.md, ERROR_HANDLING.md).

---

## Items

_Add new extended design details below using the template above. Remove this placeholder line when the first item is added._

_(empty)_

---

_Last updated: [YYYY-MM-DD]_
