# Acme Todo — CAST Source Map

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
| `CLAUDE.md` | Project conventions live inline: TypeScript Style Conventions, File Naming, Common Pitfalls, Dependencies policy | The single standards source for this small project |

## Product & Requirements (required)

_PRD, product vision, roadmap, domain glossary, user research — what the product is and why. Product reads these at `/agent-plan` Stage 1 when defining milestone scope._

| Location | What it is | Notes |
|---|---|---|
| `docs/PRD.md` | Product requirements — goals, user stories, acceptance criteria for M1/M2 | v0.1.0, Approved |
| `docs/CONCEPT.md` | Product vision, core loop, design pillars | |
| `docs/GLOSSARY.md` | Domain terms (task, done, database, migration) | |

## Architecture & Design (required)

_Existing system documentation, ADRs, schemas, API contracts, design systems. Architect reads these at `/agent-plan` Stage 2a for consistency with the system as it stands; UI reads any design-system material at Stage 2b._

| Location | What it is | Notes |
|---|---|---|
| _None declared._ | | Greenfield at M1 — prior milestones' `artifacts/milestone-*/architecture.md` files are the system record |

## Testing & Quality (required)

_Testing strategy, coverage expectations, QA checklists, performance budgets. Feeds acceptance criteria at planning and the CEO's risk lenses._

| Location | What it is | Notes |
|---|---|---|
| `CLAUDE.md` | Build & Test section — Vitest via `npm test`, coverage expectations | Performance budgets originate in `docs/PRD.md` §7 |

## Documentation Home (required)

_Where documentation updates should be WRITTEN. When pipeline work changes something documentation-worthy, the entry lands in the `docs` queue (`artifacts/STANDUP.md`) and Docs Writer drains it by updating the location(s) below, matching their existing structure and style. With none declared, Docs Writer is never launched — pending `docs` entries are surfaced to you at each checkpoint instead._

| Location | What it is | Notes |
|---|---|---|
| `docs/` | The project's documentation directory (PRD, concept, glossary) | Glossary picked up the M1 persistence terms this way |

## Project Registers (optional)

_Long-lived logs with fixed homes: the release changelog, ADR index, deprecation log. `/cast-release` updates the changelog entry here; with none declared it skips changelog work and says so._

| Location | What it is | Notes |
|---|---|---|
| _None declared._ | | No changelog yet — first release will create one |

---

_Last updated: 2026-04-08_
