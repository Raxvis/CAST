<!-- TEMPLATE INSTRUCTIONS
  FILE: FILE_CONVENTIONS.md
  PURPOSE: This document defines the exact location and naming rules for every category
  of file in the project. It exists to ensure that any contributor — human or AI agent —
  places new files in predictable, discoverable locations and names them consistently.
  Without this document, documentation and generated files accumulate in random locations
  and become impossible to navigate.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - If your project uses different milestone or module identifiers, update the naming
    patterns below to match.
  - Do NOT relax the `docs/` / `templates/` / `artifacts/` split. It is load-bearing — agents
    rely on it to decide where to read templates and write every output.
  - This comment block is stripped automatically by /cast-init at install.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — File and Directory Placement Rules

This document governs where every project file belongs. Read it before creating any new file. When in doubt, place files into one of the two top-level directories described below rather than at the repository root.

---

## The Core Rule: `docs/` vs `templates/` vs `artifacts/`

The project has **three top-level directories** for non-code content. The split is strict and there are no exceptions.

| Directory | Purpose | What lives here |
|---|---|---|
| `docs/` | **Reference material only.** Describes *how the project works*. | Requirements, conventions, design rationale, glossaries, quality standards. |
| `templates/` | **Document templates only.** Skeletons copied to produce work. | Architecture, UI spec, and milestone templates. Read and copied, never filled in place. |
| `artifacts/` | **Work artifacts only.** Instances of *actual work*. | Milestone plans, per-milestone architecture and UI specs, security/performance/CEO reviews, bug reports, session logs, completion records. |

When deciding where a file belongs, ask:

1. **Is this a reusable document skeleton that gets copied and filled in?** → `templates/`
2. **Is this other reusable guidance that applies across many pieces of work?** → `docs/`
3. **Is this content about a specific milestone, feature, bug, review, or work session?** → `artifacts/`

Agents write work outputs to `artifacts/`, read reference material from `docs/`, and read document templates from `templates/`. `/agent-plan`, `/agent-code`, and `/agent-task` all write exclusively under `artifacts/`; none of them should ever write to `docs/` or `templates/`.

---

## Directory Structure

### `docs/` — reference material

```
docs/
  README.md                      # Documentation index
  CONCEPT.md                     # Project vision
  PRD.md                         # Product requirements
  ADDITIONAL.md                  # Extended design detail
  GLOSSARY.md                    # Term definitions
  DESIGN_RATIONALE.md            # Decision log
  CODE_PATTERNS.md               # Coding conventions
  FILE_CONVENTIONS.md            # This document
  ERROR_HANDLING.md              # Error handling guidelines
  PIPELINE_LOOP.md               # Canonical engineering-loop contract
  TEST_FRAMEWORK.md              # Testing strategy
  CHANGELOG.md                   # Release history (release agent owns)
  ASSETS.md                      # Asset registry
  MVP_LAUNCH.md                  # Launch checklist
```

### `templates/` — document templates

```
templates/
  ARCH_MODULE.md                 # Module architecture template
  ARCH_SYSTEM.md                 # System architecture template
  ARCH_DATA_SCHEMA.md            # Data schema template
  UI_SPEC.md                     # UI specification template
  MILESTONE_DEFINITION.md        # Milestone definition template
  MILESTONE_TASKS.md             # Milestone task breakdown template
  MILESTONE_COMPLETION.md        # Milestone completion report template
  MILESTONE_VALIDATION.md        # Task validation / milestone acceptance template
  CEO_REVIEW.md                  # CEO planning-review template
  UX_REVIEW.md                   # UX review template
```

Templates are copied — never filled in place — to produce instances under `artifacts/`.

### `artifacts/` — work artifacts

```
artifacts/
  README.md                                # Work directory index
  BUGS.md                                  # Active bug tracker (instance, not template)
  STANDUP.md                               # Rolling session progress log
  AGENT_STATE.md                           # Live working state for every agent

  milestones/
    milestone-{N}-{slug}.md                # Milestone definition
    milestone-{N}-{slug}-tasks.md          # Task breakdown for that milestone
    milestone-{N}-{slug}-completion.md     # Completion report (written after /agent-code)
    milestone-{N}-{slug}-validation.md     # Acceptance record

  architecture/
    arch-milestone-{N}.md                  # Milestone-specific architecture document
    [MODULE]_MODULE.md                     # Module-level architecture specs

  ui-specs/
    ui-milestone-{N}.md                    # Milestone-specific UI spec
    [SCREEN]_SCREEN.md                     # Screen-level UI specs

  reviews/
    security-review-milestone-{N}.md
    performance-review-milestone-{N}.md
    ceo-review-milestone-{N}.md
```

Subdirectories are created the first time an artifact of that type is produced. Do not create empty subdirectories.

---

## File Naming and Placement Rules

### Core Design and Technical Documents (`docs/`)

These files live directly in `docs/` and must not be moved, renamed, or copied elsewhere.

| File | Contents |
|------|----------|
| `README.md` | Documentation index — lists all reference docs and templates |
| `CONCEPT.md` | Project vision, core loop, design pillars |
| `PRD.md` | Product requirements, user stories, acceptance criteria |
| `ADDITIONAL.md` | Extended design details |
| `GLOSSARY.md` | Canonical term definitions |
| `DESIGN_RATIONALE.md` | Decision log |
| `CODE_PATTERNS.md` | Coding conventions |
| `FILE_CONVENTIONS.md` | File placement rules (this document) |
| `ERROR_HANDLING.md` | Error handling guidelines |
| `TEST_FRAMEWORK.md` | Testing strategy |
| `CHANGELOG.md` | Chronological release log |
| `ASSETS.md` | Asset registry |
| `MVP_LAUNCH.md` | Launch readiness checklist |

### Document Templates (`templates/`)

Templates live in `templates/` and are copied — never filled in place — to produce instances under `artifacts/`.

| Template | Instance Destination |
|---|---|
| `templates/ARCH_MODULE.md` | `artifacts/architecture/[MODULE]_MODULE.md` |
| `templates/ARCH_SYSTEM.md` | `artifacts/architecture/[SYSTEM]_SYSTEM.md` |
| `templates/ARCH_DATA_SCHEMA.md` | `artifacts/architecture/[SCHEMA]_SCHEMA.md` |
| `templates/UI_SPEC.md` | `artifacts/ui-specs/[SCREEN]_SCREEN.md` or `ui-milestone-{N}.md` |
| `templates/MILESTONE_DEFINITION.md` | `artifacts/milestones/milestone-{N}-{slug}.md` |
| `templates/MILESTONE_TASKS.md` | `artifacts/milestones/milestone-{N}-{slug}-tasks.md` |
| `templates/MILESTONE_COMPLETION.md` | `artifacts/milestones/milestone-{N}-{slug}-completion.md` |
| `templates/MILESTONE_VALIDATION.md` | `artifacts/milestones/milestone-{N}-{slug}-validation.md` |
| `templates/CEO_REVIEW.md` | `artifacts/reviews/ceo-review-milestone-{N}.md` |
| `templates/UX_REVIEW.md` | `artifacts/reviews/ux-review-milestone-{N}.md` |

### Milestone Artifacts (`artifacts/milestones/`)

**Naming pattern:** `milestone-{N}-{slug}[-suffix].md`

- `{N}` is the milestone number (e.g., `1`, `2`, `7`).
- `{slug}` is a kebab-case short name (e.g., `user-auth`, `search-ui`).
- `-suffix` is one of: `-tasks`, `-completion`, `-validation` (the base file with no suffix is the milestone definition).

**Examples:**
- `artifacts/milestones/milestone-1-user-auth.md`
- `artifacts/milestones/milestone-1-user-auth-tasks.md`
- `artifacts/milestones/milestone-1-user-auth-completion.md`
- `artifacts/milestones/milestone-1-user-auth-validation.md`

### Architecture Artifacts (`artifacts/architecture/`)

Two naming patterns are valid:

- `arch-milestone-{N}.md` — architecture document covering an entire milestone (written by `/agent-plan`).
- `[MODULE]_MODULE.md`, `[SYSTEM]_SYSTEM.md`, `[SCHEMA]_SCHEMA.md` — module-, system-, or schema-scoped specs.

### UI Artifacts (`artifacts/ui-specs/`)

Two naming patterns are valid:

- `ui-milestone-{N}.md` — UI spec covering an entire milestone (written by `/agent-plan`).
- `[SCREEN]_SCREEN.md`, `[COMPONENT]_COMPONENT.md` — screen- or component-scoped specs.

### Review Artifacts (`artifacts/reviews/`)

**Naming patterns:**

| Review Type | Pattern |
|---|---|
| Security | `security-review-milestone-{N}.md` |
| Performance | `performance-review-milestone-{N}.md` |
| CEO planning verdict | `ceo-review-milestone-{N}.md` |

---

## Agent Responsibilities Summary

| Situation | Action |
|---|---|
| Planning a milestone | Product writes `artifacts/milestones/milestone-{N}-{slug}.md` + `-tasks.md` |
| Documenting architecture for a milestone | Architect writes `artifacts/architecture/arch-milestone-{N}.md` |
| Specifying UI for a milestone | UI writes `artifacts/ui-specs/ui-milestone-{N}.md` |
| Filing security findings | Security writes `artifacts/reviews/security-review-milestone-{N}.md` |
| Filing performance findings | Performance writes `artifacts/reviews/performance-review-milestone-{N}.md` |
| Recording a CEO verdict | CEO writes `artifacts/reviews/ceo-review-milestone-{N}.md` |
| Logging a bug | Bug Gatherer adds an entry to `artifacts/BUGS.md` |
| Completing a milestone | Product writes `artifacts/milestones/milestone-{N}-{slug}-completion.md` |
| Recording session progress | Any agent appends to `artifacts/STANDUP.md` (both `/agent-code` completion and `/agent-task` completion write entries here) |
| Updating agent working state | Each agent appends to its own section in `artifacts/AGENT_STATE.md` |
| Appending a `/agent-task` completion entry | Any agent appends to `artifacts/STANDUP.md` |
| Updating reference documentation | Docs Writer edits the relevant file in `docs/` |
| Adding a release changelog entry | Release appends to `docs/CHANGELOG.md` |
| Creating any new reference doc | Docs Writer registers it in `docs/README.md` |

**`/agent-task` scope note.** `/agent-task` is bounded to `artifacts/STANDUP.md`, `artifacts/BUGS.md`, and `artifacts/AGENT_STATE.md` updates. It does **not** write to `artifacts/milestones/`, `artifacts/architecture/`, `artifacts/ui-specs/`, or `artifacts/reviews/` — those directories are owned by `/agent-plan` outputs. If a one-off task turns out to need any of those, `/agent-task` halts and instructs the user to run `/agent-plan` first. See `TROUBLESHOOTING.md` for the full decision table on which command to use.

---

## Revision History on Planning Artifacts

Every planning-stage artifact under `artifacts/milestones/`, `artifacts/architecture/`, `artifacts/ui-specs/`, and `artifacts/reviews/` begins with a `## Revision History` table directly under the title:

```
## Revision History

| # | Date | Agent | Reason |
|---|---|---|---|
| v2 | 2026-04-09 | architect | Addressed CEO Revision Request: SQL injection risk |
| v1 | 2026-04-08 | architect | Initial version |

---
```

Rules:

- First write of an artifact includes a `v1` row.
- Any revision prepends a new row at the top of the table with the next version number and a one-line reason citing the finding or request that triggered the rewrite.
- The body of the file is rewritten as needed; prior content is not preserved inline. Git history is the audit log.
- The CEO reads this table first when re-reviewing a revised plan to identify which of its prior Revision Requests have been addressed.

This block is mandatory for planning-stage artifacts produced by `/agent-plan`. It is **not** required for `artifacts/BUGS.md`, `artifacts/STANDUP.md`, or `artifacts/AGENT_STATE.md`, which are append-only running logs.

---

## Anti-Patterns

The following behaviors violate these conventions. Do not do them:

- **Writing work artifacts to `docs/`.** Bug reports, milestone plans, CEO reviews, and session logs do not belong in `docs/`. They go in `artifacts/`.
- **Writing reference material to `artifacts/`.** Coding conventions, glossaries, templates, and design rationale do not belong in `artifacts/`. They go in `docs/`.
- **Filling in templates in place.** `templates/MILESTONE_TASKS.md` is the template — copy it to `artifacts/milestones/milestone-{N}-{slug}-tasks.md` before filling it in.
- **Creating files at the repository root.** Exception: `README.md`, `CLAUDE.md`, `CHANGELOG.md` at project root, and tool configuration files that require root placement by convention.
- **Creating new subdirectories without updating this file.** Any new subdirectory under `docs/` or `artifacts/` must be added to the tree diagrams above.
- **Using free-form naming.** All artifact names must follow the patterns in this document.
- **Duplicating documents.** Never create a second file for a concern that already has a canonical home. Update the existing file instead.
- **Leaving reference docs unregistered.** Every new file in `docs/` must have an entry in `docs/README.md`. Every new subdirectory in `artifacts/` must be reflected in `artifacts/README.md`.
- **Using `/agent-task` for work that needs planning.** `/agent-task` is for self-contained changes only. If the work introduces a new module, schema, endpoint, or cross-cutting change, run `/agent-plan` → `/agent-code` instead. The Pre-Flight and Reviewer steps in `/agent-task` will catch obvious cases, but the user is the first line of defense. Sneaking a design change through `/agent-task` bypasses the CEO gate and produces drift.

---

## Quick Reference

| Content type | Location | Naming |
|---|---|---|
| Reference docs | `docs/` | `UPPER_SNAKE_CASE.md` |
| Document templates | `docs/` | `UPPER_SNAKE_CASE.md` |
| Release changelog | `docs/CHANGELOG.md` | fixed |
| Active bug tracker | `artifacts/BUGS.md` | fixed |
| Rolling session log | `artifacts/STANDUP.md` | fixed |
| Agent working state | `artifacts/AGENT_STATE.md` | fixed |
| Milestone definition | `artifacts/milestones/` | `milestone-{N}-{slug}.md` |
| Milestone tasks | `artifacts/milestones/` | `milestone-{N}-{slug}-tasks.md` |
| Milestone completion | `artifacts/milestones/` | `milestone-{N}-{slug}-completion.md` |
| Milestone validation | `artifacts/milestones/` | `milestone-{N}-{slug}-validation.md` |
| Milestone architecture | `artifacts/architecture/` | `arch-milestone-{N}.md` |
| Module architecture | `artifacts/architecture/` | `[MODULE]_MODULE.md` |
| System architecture | `artifacts/architecture/` | `[SYSTEM]_SYSTEM.md` |
| Data schema | `artifacts/architecture/` | `[SCHEMA]_SCHEMA.md` |
| Milestone UI spec | `artifacts/ui-specs/` | `ui-milestone-{N}.md` |
| Screen spec | `artifacts/ui-specs/` | `[SCREEN]_SCREEN.md` |
| Component spec | `artifacts/ui-specs/` | `[COMPONENT]_COMPONENT.md` |
| Security review | `artifacts/reviews/` | `security-review-milestone-{N}.md` |
| Performance review | `artifacts/reviews/` | `performance-review-milestone-{N}.md` |
| CEO review | `artifacts/reviews/` | `ceo-review-milestone-{N}.md` |

---

## Rationale

The `docs/` vs `artifacts/` split exists for three reasons:

1. **Predictability for agents.** An agent asked to file a bug report always knows the file goes in `artifacts/BUGS.md`; an agent asked to look up coding conventions always knows to read `docs/CODE_PATTERNS.md`. Ambiguity causes agents to guess, and guessing produces scattered outputs.

2. **Clean diffs and reviews.** Reference material changes slowly and deliberately; work artifacts churn constantly. Separating them means diffs on `docs/` signal intentional policy changes, while diffs on `artifacts/` signal ordinary work progress. Reviewers can skim `docs/` changes carefully and `artifacts/` changes quickly.

3. **Safe bulk operations.** "Wipe all in-flight work and start over" becomes `rm -rf artifacts/` — a contained, reversible operation. If work and reference were mixed, you could not do this without also destroying project knowledge.

---

_Last updated: [YYYY-MM-DD]_
