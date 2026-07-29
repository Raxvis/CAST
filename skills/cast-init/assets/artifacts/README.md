<!-- TEMPLATE INSTRUCTIONS
FILE: artifacts/README.md
PURPOSE: This file is the index for the `artifacts/` directory — where all work artifacts
live, grouped by milestone. `artifacts/` is the counterpart to `docs/`: anything produced
by work (plans, specs, reviews, tasks, bugs, progress logs) goes here. Anything that
describes how the project works (design, conventions, templates) stays in `docs/`.

HOW TO CUSTOMIZE:
- Replace [PROJECT_NAME] with your project name.
- Update the layout table if you introduce new per-milestone work types.
- Do NOT add design documentation or coding conventions (those belong in `docs/`) or
  document templates (those belong in `templates/`) to this directory.
- This comment block is stripped automatically by /cast-init at install.
-->

# [PROJECT_NAME] — Work Artifacts (`artifacts/`)

This directory holds every artifact produced by work on [PROJECT_NAME], **grouped by milestone**: each milestone owns one directory containing its definition, design specs, reviews, per-task files, and per-bug files. Cross-milestone state (session log, agent state, bug index) lives at the root.

> **Provenance:** Every file under this directory is produced by an agent running inside the `/agent-plan`, `/agent-code`, or `/agent-task` pipeline. Review accordingly — these are agent outputs, not hand-authored reference material. Humans may edit these files (to revise plans, triage bugs, or close milestones), but the canonical producer of each artifact is named at the top of the file.

**Rule:** `artifacts/` is for **instances** of work. `docs/` is for **reference material**; `templates/` is for **reusable document skeletons**. If you are unsure where a file belongs, ask: "Is this content about a specific piece of work (feature, milestone, task, bug, session)?" If yes → `artifacts/`. "Is this a reusable skeleton agents copy?" If yes → `templates/`. "Is this reusable guidance?" If yes → `docs/`.

---

## Structure

```
artifacts/
  README.md                        # This file
  BUGS.md                          # Global bug INDEX: one line per bug → the per-bug file
  STANDUP.md                       # Rolling session progress log (cross-milestone)
  AGENT_STATE.md                   # Live working state for every agent (cross-milestone)

  milestone-{N}-{slug}/            # One directory per milestone — ALL of that milestone's work
    README.md                      # Milestone definition — the highest-order document: goal,
                                   #   scope, acceptance criteria, Status, Task Index,
                                   #   CEO Approval Conditions
    architecture.md                # Milestone architecture document
    ui.md                          # Milestone UI spec (only when the milestone has UI work)
    arch-{slug}.md                 # Supplemental module/system/schema docs (as needed)
    ui-{slug}.md                   # Supplemental screen/component specs (as needed)
    reviews/
      security.md                  # Security review (/agent-plan Stage 3)
      performance.md               # Performance review (/agent-plan Stage 3)
      ceo.md                       # CEO planning verdict (/agent-plan Stage 4)
      ux.md                        # UX review (milestone completion; UI-flagged milestones only)
      validation.md                # Milestone validation record (Product, milestone completion)
      completion.md                # Milestone completion report (Product, milestone completion)
      retrospective.md             # Milestone retrospective (Validator, milestone completion)
    tasks/
      task-{T}-{slug}.md           # ONE FILE PER TASK — self-contained: description,
                                   #   acceptance criteria, Context Manifest, Handoff Log
    bugs/
      bug-{XXX}-{slug}.md          # ONE FILE PER BUG found during this milestone's work

  one-off/                         # /agent-task work (no milestone)
    task-{slug}.md                 # One-off task file (same shape as milestone task files)
    bugs/
      bug-{XXX}-{slug}.md          # Bugs filed from one-off work
```

Milestone directories are created by `/agent-plan` Stage 1 (nothing is pre-created for them). `/cast-init` scaffolds only the root files and the `one-off/` directory.

**Why per-task and per-bug files?** Each task file is a complete, isolated unit of work: an agent can execute it by reading that one file plus the exact references its Context Manifest lists — nothing else. Handoffs between agents are compact entries appended to the task file's Handoff Log, not conversation context or whole-directory re-reads. This is the pipeline's minimal-context contract; the full protocol lives in `docs/PIPELINE_LOOP.md` → "Handoff Protocol".

---

## What Goes Where

| Artifact | Location | Produced By |
|---|---|---|
| Milestone definition (goal, scope, criteria, Status, Task Index, CEO conditions) | `milestone-{N}-{slug}/README.md` | Product (`/agent-plan` Stage 1; Status and conditions updated at later stages) |
| Per-task file | `milestone-{N}-{slug}/tasks/task-{T}-{slug}.md` | Product (`/agent-plan` Stage 1); manifest refs added by Architect/UI; Handoff Log appended by every engineering stage |
| Architecture document | `milestone-{N}-{slug}/architecture.md` | Architect (`/agent-plan` Stage 2) |
| UI specification | `milestone-{N}-{slug}/ui.md` | UI (`/agent-plan` Stage 2) |
| Supplemental arch docs (module/system/schema) | `milestone-{N}-{slug}/arch-{slug}.md` | Architect (during planning or engineering) |
| Supplemental UI specs (screen/component) | `milestone-{N}-{slug}/ui-{slug}.md` | UI (during planning or engineering) |
| Security review findings | `milestone-{N}-{slug}/reviews/security.md` | Security (`/agent-plan` Stage 3) |
| Performance review findings | `milestone-{N}-{slug}/reviews/performance.md` | Performance (`/agent-plan` Stage 3) |
| CEO planning verdict | `milestone-{N}-{slug}/reviews/ceo.md` | CEO (`/agent-plan` Stage 4) |
| UX review of implemented screens | `milestone-{N}-{slug}/reviews/ux.md` | UI (milestone completion; UI-flagged milestones only) |
| Milestone validation record | `milestone-{N}-{slug}/reviews/validation.md` | Product (milestone completion) |
| Milestone completion report | `milestone-{N}-{slug}/reviews/completion.md` | Product (milestone completion) |
| Milestone retrospective | `milestone-{N}-{slug}/reviews/retrospective.md` | Validator (milestone completion) |
| Per-bug report | `milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md` (or `one-off/bugs/` for `/agent-task` work) | Bug Gatherer files; Product, Debugger, Coder, Tester advance it |
| Bug index (ID assignment, one-line status per bug, regression checklist) | `artifacts/BUGS.md` | Bug Gatherer adds rows; owners update status column |
| One-off task file | `one-off/task-{slug}.md` | `/agent-task` |
| Session progress log | Entries in `artifacts/STANDUP.md` | Any agent / user |
| Agent working state (Current Work, Decisions Logs, dashboards) | The agent's own section in `artifacts/AGENT_STATE.md` | Each agent |

Templates for every artifact type live in `templates/` — see `templates/README.md`.

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
- Document templates (`templates/ARCH_MODULE.md`, `templates/UI_SPEC.md`, `templates/TASK.md`, etc.)
- Release changelog (`docs/CHANGELOG.md`)
- Asset registry (`docs/ASSETS.md`)

If you find yourself adding any of the above to `artifacts/`, stop and move it to `docs/`.

---

_Last updated: [YYYY-MM-DD]_
