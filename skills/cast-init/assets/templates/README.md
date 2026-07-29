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
| `MILESTONE_DEFINITION.md` | Product | `/agent-plan` Stage 1 | `artifacts/milestone-{N}-{slug}/README.md` — the milestone's highest-order document |
| `TASK.md` | Product | `/agent-plan` Stage 1 (one instance **per task**); `/agent-task` (one-off tasks) | `artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md`, or `artifacts/one-off/task-{slug}.md` |
| `ARCH_MODULE.md` | Architect | `/agent-plan` Stage 2a | `artifacts/milestone-{N}-{slug}/architecture.md` (or `arch-{slug}.md` for supplemental docs) |
| `ARCH_SYSTEM.md` | Architect | `/agent-plan` Stage 2a | `artifacts/milestone-{N}-{slug}/architecture.md` (or `arch-{slug}.md` for supplemental docs) |
| `ARCH_DATA_SCHEMA.md` | Architect | `/agent-plan` Stage 2a | `artifacts/milestone-{N}-{slug}/architecture.md` (or `arch-{slug}.md` for supplemental docs) |
| `UI_SPEC.md` | UI | `/agent-plan` Stage 2b | `artifacts/milestone-{N}-{slug}/ui.md` (or `ui-{slug}.md` for supplemental screen/component specs) |
| `BUG_REPORT.md` | Bug Gatherer | Any pipeline, when a defect is filed (one instance **per bug**) | `artifacts/milestone-{N}-{slug}/bugs/BUG-{XXX}-{slug}.md`, or `artifacts/one-off/bugs/BUG-{XXX}-{slug}.md`; indexed in `artifacts/BUGS.md` |
| `MILESTONE_COMPLETION.md` | Product | `/agent-code` milestone-completion checkpoint | `artifacts/milestone-{N}-{slug}/reviews/completion.md` |
| `MILESTONE_VALIDATION.md` | Product | `/agent-code` milestone-completion checkpoint only (milestone acceptance record; its Task Validation Checklist doubles as the *criteria* Product applies per task at Step 4 — per-task outcomes go to the task file's Status plus a STANDUP `progress` entry, with no per-task document) | `artifacts/milestone-{N}-{slug}/reviews/validation.md` |
| `CEO_REVIEW.md` | CEO | `/agent-plan` Stage 4 | `artifacts/milestone-{N}-{slug}/reviews/ceo.md` |
| `UX_REVIEW.md` | UI | `/agent-code` milestone-completion checkpoint (once per milestone; only milestones with UI-flagged tasks) | `artifacts/milestone-{N}-{slug}/reviews/ux.md` |
| `MILESTONE_RETROSPECTIVE.md` | Validator | `/agent-code` milestone-completion checkpoint | `artifacts/milestone-{N}-{slug}/reviews/retrospective.md` |

---

## How to use a template

1. Pick the template that matches what you are documenting (see the table above, or
   `docs/CODE_PATTERNS.md` → "Architecture Document Templates").
2. **Copy** it to the correct location inside the milestone's directory
   (`artifacts/milestone-{N}-{slug}/`) under the naming pattern in
   `docs/FILE_CONVENTIONS.md` — or under `artifacts/one-off/` for `/agent-task` work.
3. Fill in the copy. Never edit the template in `templates/` directly.

---

_Last updated: [YYYY-MM-DD]_
