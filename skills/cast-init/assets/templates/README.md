<!-- TEMPLATE INSTRUCTIONS
  FILE: templates/README.md
  PURPOSE: Index for the document-template directory. Lists every reusable template,
  the agent that consumes it, and where its filled-in instances are written.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with the name of your project.
  - Add or remove rows if you add or delete templates.
  - Do NOT fill these templates in place — copy each one into artifacts/ first.
  - Delete this comment block before committing if you prefer a clean index.
-->

# [PROJECT_NAME] — Document Templates

This directory holds **reusable document templates only**. Each file is a skeleton that an
agent copies into `artifacts/` and fills in to produce a work instance. Templates are never
filled in place — copy first, then edit the copy.

> **Scope of this directory:** `templates/` holds reusable document skeletons. Reference
> material (requirements, conventions, design rationale) lives in `docs/`; filled-in work
> instances live in `artifacts/`. See `docs/FILE_CONVENTIONS.md` for the full split and the
> root `README.md` for the rationale.

---

## Templates

| Template | Produced by | Used in | Instance destination |
|---|---|---|---|
| `ARCH_MODULE.md` | Architect | `/agent-plan` Stage 2a | `artifacts/architecture/` |
| `ARCH_SYSTEM.md` | Architect | `/agent-plan` Stage 2a | `artifacts/architecture/` |
| `ARCH_DATA_SCHEMA.md` | Architect | `/agent-plan` Stage 2a | `artifacts/architecture/` |
| `UI_SPEC.md` | UI | `/agent-plan` Stage 2b | `artifacts/ui-specs/` |
| `MILESTONE_DEFINITION.md` | Product | `/agent-plan` Stage 1 | `artifacts/milestones/milestone-{N}-{slug}.md` |
| `MILESTONE_TASKS.md` | Product | `/agent-plan` Stage 1 | `artifacts/milestones/milestone-{N}-{slug}-tasks.md` |
| `MILESTONE_COMPLETION.md` | Product | `/agent-code` (after engineering) | `artifacts/milestones/milestone-{N}-{slug}-completion.md` |
| `MILESTONE_VALIDATION.md` | Product | `/agent-code` milestone-completion checkpoint only (milestone acceptance record; its Task Validation Checklist doubles as the *criteria* Product applies per task at Step 4 — per-task outcomes go to the tasks file's Status plus a STANDUP `progress` entry, with no per-task document) | `artifacts/milestones/milestone-{N}-{slug}-validation.md` |
| `CEO_REVIEW.md` | CEO | `/agent-plan` Stage 4 | `artifacts/reviews/ceo-review-milestone-{N}.md` |
| `UX_REVIEW.md` | UI | `/agent-code` milestone-completion checkpoint (once per milestone; only milestones with UI-flagged tasks) | `artifacts/reviews/ux-review-milestone-{N}.md` |
| `MILESTONE_RETROSPECTIVE.md` | Validator | `/agent-code` milestone-completion checkpoint | `artifacts/reviews/retrospective-milestone-{N}.md` |

---

## How to use a template

1. Pick the template that matches what you are documenting (see the table above, or
   `docs/CODE_PATTERNS.md` → "Architecture Document Templates").
2. **Copy** it to the correct `artifacts/` subdirectory under the naming pattern in
   `docs/FILE_CONVENTIONS.md`.
3. Fill in the copy. Never edit the template in `templates/` directly.

---

_Last updated: [YYYY-MM-DD]_
