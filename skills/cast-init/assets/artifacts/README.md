<!-- TEMPLATE INSTRUCTIONS
FILE: artifacts/README.md
PURPOSE: This file is the index for the `artifacts/` directory — where all work artifacts
live. `artifacts/` is the counterpart to `docs/`: anything produced by work (plans, bugs,
reviews, progress logs) goes here. Anything that describes how the project works (design,
conventions, templates) stays in `docs/`.

HOW TO CUSTOMIZE:
- Replace [PROJECT_NAME] with your project name.
- Update the subdirectory table as new work types are introduced.
- Do NOT add design documentation, coding conventions, or templates to this directory —
  those belong in `docs/`.
- This comment block is stripped automatically by /cast-init at install.
-->

# [PROJECT_NAME] — Work Artifacts (`artifacts/`)

This directory holds every artifact produced by work on [PROJECT_NAME]: milestone plans, architecture specs for specific milestones, UI specs for specific screens, security and performance reviews, CEO planning reviews, bug reports, and the rolling session log.

> **Provenance:** Every file under this directory is produced by an agent running inside the `/agent-plan` or `/agent-code` pipeline. Review accordingly — these are agent outputs, not hand-authored reference material. Humans may edit these files (to revise plans, triage bugs, or close milestones), but the canonical producer of each artifact is named at the top of the file.

**Rule:** `artifacts/` is for **instances** of work. `docs/` is for **reference and templates**. If you are unsure where a file belongs, ask: "Is this content about a specific piece of work (feature, milestone, bug, session)?" If yes → `artifacts/`. "Is this content reusable guidance or a template?" If yes → `docs/`.

---

## Structure

```
artifacts/
  README.md                        # This file
  BUGS.md                          # Active bug tracker (instance, not template)
  STANDUP.md                       # Rolling session progress log

  milestones/
    milestone-{N}-{slug}.md        # Milestone definition (from templates/MILESTONE_TASKS.md)
    milestone-{N}-{slug}-tasks.md  # Task breakdown for that milestone

  architecture/
    arch-milestone-{N}.md          # Milestone-specific architecture document
    [MODULE]_MODULE.md             # Module-level architecture docs produced during work

  ui-specs/
    ui-milestone-{N}.md            # Milestone-specific UI spec
    [SCREEN]_SCREEN.md             # Screen-level specs produced during work

  reviews/
    security-review-milestone-{N}.md
    performance-review-milestone-{N}.md
    ceo-review-milestone-{N}.md    # CEO planning-stage verdict
```

Subdirectories are created the first time an artifact of that type is produced. Do not create empty subdirectories.

---

## What Goes Where

| Artifact | Location | Produced By |
|---|---|---|
| Milestone definition | `artifacts/milestones/milestone-{N}-{slug}.md` | Product (during `/agent-plan`) |
| Milestone task breakdown | `artifacts/milestones/milestone-{N}-{slug}-tasks.md` | Product (during `/agent-plan`) |
| Architecture document for a milestone | `artifacts/architecture/arch-milestone-{N}.md` | Architect (during `/agent-plan`) |
| UI specification for a milestone | `artifacts/ui-specs/ui-milestone-{N}.md` | UI (during `/agent-plan`) |
| Security review findings | `artifacts/reviews/security-review-milestone-{N}.md` | Security (during `/agent-plan`) |
| Performance review findings | `artifacts/reviews/performance-review-milestone-{N}.md` | Performance (during `/agent-plan`) |
| CEO planning verdict | `artifacts/reviews/ceo-review-milestone-{N}.md` | CEO (during `/agent-plan`) |
| Bug reports | Entries in `artifacts/BUGS.md` | Bug Gatherer |
| Session progress log | Entries in `artifacts/STANDUP.md` | Any agent / user |
| Milestone completion report | `artifacts/milestones/milestone-{N}-{slug}-completion.md` | Product (after `/agent-code`) |
| Milestone validation record | `artifacts/milestones/milestone-{N}-{slug}-validation.md` | Product (after `/agent-code`) |

Templates for every artifact type live in `docs/` — see `docs/README.md`.

---

> **Naming note:** Do not rename this directory to `references/`. "Reference material" is what `docs/` contains, so `references/` would invert the meaning. The name `artifacts/` was chosen because every file here is a produced output of the agent pipeline with a defined schema and owner — which is what an artifact is.

## What Does NOT Go Here

The following belong in `docs/`, not `artifacts/`:

- Product requirements (`docs/PRD.md`)
- Project vision and concept (`docs/CONCEPT.md`)
- Glossary and term definitions (`docs/GLOSSARY.md`)
- Design rationale / decision log (`docs/DESIGN_RATIONALE.md`)
- Coding conventions (`docs/CODE_PATTERNS.md`)
- File placement rules (`docs/FILE_CONVENTIONS.md`)
- Error handling guidelines (`docs/ERROR_HANDLING.md`)
- Testing strategy (`docs/TEST_FRAMEWORK.md`)
- Document templates (`templates/ARCH_MODULE.md`, `templates/UI_SPEC.md`, `templates/MILESTONE_TASKS.md`, etc.)
- Release changelog (`docs/CHANGELOG.md`)
- Asset registry (`docs/ASSETS.md`)

If you find yourself adding any of the above to `artifacts/`, stop and move it to `docs/`.

---

_Last updated: [YYYY-MM-DD]_
