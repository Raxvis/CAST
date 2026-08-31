<!-- TEMPLATE INSTRUCTIONS
  FILE: SOURCES.md (installed to .claude/cast/SOURCES.md)
  PURPOSE: The SOURCE MAP — the single file that tells the CAST pipelines where THIS
           project's documentation, standards, and registers live. CAST v4 ships no
           documentation of its own: you bring your own docs, wherever and however you
           keep them, and this file points at them. /cast-init writes it from your
           answers at install time; edit it by hand whenever your documentation moves.

           WHO READS THIS: the ORCHESTRATING skills and the PLANNING stages.
           /agent-plan reads the mapped sources at planning time and distills what
           applies into the milestone's own artifacts (the Standards Digest, the
           architecture document, task files). /agent-task's Pre-Flight does the same
           for one-off work. ENGINEERING stages (Coder, Reviewer) never open these
           locations — a plan is not done until it carries everything engineering
           needs. Docs Writer writes documentation updates to the Documentation Home
           below. /cast-release reads the Project Registers.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name (done by /cast-init).
  - Fill each category's table with your real locations. A location is a path or glob
    relative to the project root (e.g. `docs/standards/**/*.md`, `CONTRIBUTING.md`,
    `wiki-export/architecture/`). Directories mean "every markdown file under here".
  - Leave a category as "_None declared._" if you genuinely have nothing for it —
    pipelines then work from code inspection and say so in their outputs.
  - Keep entries current: a stale path is worse than no path, because planning trusts
    this file. /cast-doctor verifies every entry still resolves.
-->

# [PROJECT_NAME] — CAST Source Map

Where this project keeps its documentation, standards, and registers. CAST installs no documentation of its own — the pipelines read **your** material from the locations below, distill what applies into each milestone's own artifacts, and write documentation updates back to your Documentation Home.

**Ground rules**

1. **Locations are paths or globs relative to the project root.** A directory entry means every markdown file beneath it. Keep entries minimal and current — every entry is something planning is forced to read.
2. **Planning reads sources; engineering reads plans.** `/agent-plan` and `/agent-task` Pre-Flight open these locations and distill what applies into the milestone's Standards Digest, architecture document, and task files. Coder and Reviewer read only those distilled artifacts — never the sources. If a plan's digest is missing something, that is a planning defect to fix in the plan, not a license for engineering to browse.
3. **Empty is honest.** A category with `_None declared._` makes the pipelines plan from code inspection (existing patterns in the codebase) and note that they did.

---

## Standards & Conventions (required)

_Code style, naming, file layout, error handling, testing conventions, review checklists — anything that governs how code should be written here. Planning distills the applicable rules into each milestone's Standards Digest._

| Location | What it is | Notes |
|---|---|---|
| _None declared._ | | |

## Product & Requirements (required)

_PRD, product vision, roadmap, domain glossary, user research — what the product is and why. Product reads these at `/agent-plan` Stage 1 when defining milestone scope._

| Location | What it is | Notes |
|---|---|---|
| _None declared._ | | |

## Architecture & Design (required)

_Existing system documentation, ADRs, schemas, API contracts, design systems. Architect reads these at `/agent-plan` Stage 2a for consistency with the system as it stands; UI reads any design-system material at Stage 2b._

| Location | What it is | Notes |
|---|---|---|
| _None declared._ | | |

## Testing & Quality (required)

_Testing strategy, coverage expectations, QA checklists, performance budgets. Feeds acceptance criteria at planning and the CEO's risk lenses._

| Location | What it is | Notes |
|---|---|---|
| _None declared._ | | |

## Documentation Home (required)

_Where documentation updates should be WRITTEN. When pipeline work changes something documentation-worthy, the entry lands in the `docs` queue (`artifacts/STANDUP.md`) and Docs Writer drains it by updating the location(s) below, matching their existing structure and style. With none declared, Docs Writer is never launched — pending `docs` entries are surfaced to you at each checkpoint instead._

| Location | What it is | Notes |
|---|---|---|
| _None declared._ | | |

## Project Registers (optional)

_Long-lived logs with fixed homes: the release changelog, ADR index, deprecation log. `/cast-release` updates the changelog entry here; with none declared it skips changelog work and says so._

| Location | What it is | Notes |
|---|---|---|
| _None declared._ | | |

---

_Last updated: [YYYY-MM-DD]_
