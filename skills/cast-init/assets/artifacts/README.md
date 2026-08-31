<!-- TEMPLATE INSTRUCTIONS
FILE: artifacts/README.md
PURPOSE: This file is the index for the `artifacts/` directory — where all work artifacts
live, grouped by milestone. Anything produced by work (plans, specs, reviews, tasks,
bugs, progress logs) goes here. Anything that describes how the project works — its own
documentation and standards — lives wherever the project keeps it, mapped by
.claude/cast/SOURCES.md; CAST's templates live in .claude/cast/templates/.

HOW TO CUSTOMIZE:
- Replace [PROJECT_NAME] with your project name.
- Update the layout table if you introduce new per-milestone work types.
- Do NOT add design documentation or coding conventions (those belong in your own
  documentation, mapped by the source map) or document templates (those belong in
  `.claude/cast/templates/`) to this directory.
- This comment block is stripped automatically by /cast-init at install.
-->

# [PROJECT_NAME] — Work Artifacts (`artifacts/`)

This directory holds every artifact produced by work on [PROJECT_NAME], **grouped by milestone**: each milestone owns one directory containing its definition, design specs, reviews, per-task files, and per-bug files. Cross-milestone state (session log, agent state, bug index, one-off task backlog) lives at the root.

> **Provenance:** Every file under this directory is produced by an agent running inside the `/agent-plan`, `/agent-code`, or `/agent-task` pipeline (plus `artifacts/DOCTOR.md`, written by the `/cast-doctor` maintenance skill; `artifacts/releases/`, written by `/cast-release`; and the intake skills — `/file-bug` files user-reported bugs, `/add-task` queues backlog entries in `artifacts/TASKS.md`). Review accordingly — these are agent outputs, not hand-authored reference material. Humans may edit these files (to revise plans, triage bugs, or close milestones), but the canonical producer of each artifact is named at the top of the file.

**Rule:** `artifacts/` is for **instances** of work. Reusable document skeletons live in `.claude/cast/templates/`; the project's own reference material lives wherever you keep it, mapped by `.claude/cast/SOURCES.md`. If you are unsure where a file belongs, ask: "Is this content about a specific piece of work (feature, milestone, task, bug, session)?" If yes → `artifacts/`. "Is this a reusable skeleton agents copy?" If yes → `.claude/cast/templates/`. "Is this reusable guidance?" If yes → your own documentation (and make sure the source map points at it).

---

## Structure

```
artifacts/
  README.md                        # This file
  BUGS.md                          # Global bug INDEX: one line per bug → the per-bug file
  TASKS.md                         # One-off task BACKLOG: entries queued by /add-task,
                                   #   drained by /agent-task (backlog mode) and reviewed
                                   #   for adoption at /agent-plan Stage 1
  STANDUP.md                       # Rolling session progress log (cross-milestone)
  AGENT_STATE.md                   # Cross-milestone state tables, orchestrator-written
                                   #   (Decisions Log, Milestone Progress, Performance Budget,
                                   #   Open Questions) — NO agent reads this file
  DOCTOR.md                        # /cast-doctor health report (created on first run;
                                   #   overwritten each run — git history keeps priors)

  milestone-{N}-{slug}/            # One directory per milestone — ALL of that milestone's work
    README.md                      # Milestone definition — the highest-order document: goal,
                                   #   scope, acceptance criteria, Standards Digest (the
                                   #   distilled project standards engineering reads instead
                                   #   of the sources), Status, Task Index, CEO conditions
    architecture.md                # Milestone architecture document
    ui.md                          # Milestone UI spec (only when the milestone has UI work)
    arch-{slug}.md                 # Supplemental module/system/schema docs (as needed)
    ui-{slug}.md                   # Supplemental screen/component specs (as needed)
    reviews/
      risk.md                      # Risk review — security + performance lenses in one file
                                   #   (/agent-plan Stage 3; only when the plan has a security
                                   #   surface or an applicable performance budget)
      ceo.md                       # CEO planning verdict (/agent-plan Stage 3)
      ux.md                        # UX review (milestone completion; UI-flagged milestones only)
      risk-impl.md                 # Risk implementation review — security controls verified and
                                   #   budgets measured (milestone completion; only when a
                                   #   risk.md flag line says Yes)
      close.md                     # Milestone close record — per-task validation, milestone
                                   #   validation, completion summary, retrospective
                                   #   (Product, milestone completion, one pass)
    tasks/
      task-{T}-{slug}.md           # ONE FILE PER TASK — self-contained: description,
                                   #   acceptance criteria, Context Manifest, Handoff Log
    bugs/
      bug-{XXX}-{slug}.md          # ONE FILE PER BUG found during this milestone's work

  one-off/                         # /agent-task work (no milestone)
    task-{slug}.md                 # One-off task file (same shape as milestone task files)
    archive/                       # Complete one-off task files (moved by the orchestrator at
                                   #   milestone-completion checkpoints)
    bugs/
      bug-{XXX}-{slug}.md          # Bugs filed from one-off work and user reports filed
                                   #   via /file-bug (never archived — the BUGS.md index
                                   #   points at them)

  releases/                        # Release records (`release-{VERSION}.md`), written by /cast-release

  archive/                         # Bounded-file overflow (created on first use by the orchestrator
    STANDUP.md                     #   at milestone completion): session sections and stale
    AGENT_STATE.md                 #   state rows relocated verbatim — see the record-and-archive
                                   #   step in the /agent-code milestone checkpoint. History
                                   #   stays greppable here.
```

Milestone directories are created by `/agent-plan` Stage 1 (nothing is pre-created for them). `/cast-init` scaffolds only the root files and the `one-off/` directory.

**Why per-task and per-bug files?** Each task file is a complete, isolated unit of work: an agent can execute it by reading that one file plus the exact references its Context Manifest lists — nothing else. Handoffs between agents are compact entries appended to the task file's Handoff Log, not conversation context or whole-directory re-reads. This is the pipeline's minimal-context contract; the full contract lives in `.claude/cast/STAGE_CONTRACT.md` — the only process document an agent reads.

---

## What Goes Where

| Artifact | Location | Produced By |
|---|---|---|
| Milestone definition (goal, scope, criteria, Status, Task Index, CEO conditions) | `milestone-{N}-{slug}/README.md` | Product (`/agent-plan` Stage 1; Status and conditions updated at later stages) |
| Per-task file | `milestone-{N}-{slug}/tasks/task-{T}-{slug}.md` | Product (`/agent-plan` Stage 1); manifest refs added by Architect/UI; Handoff Log appended by every engineering stage |
| Architecture document | `milestone-{N}-{slug}/architecture.md` | Architect (`/agent-plan` Stage 2a) |
| UI specification | `milestone-{N}-{slug}/ui.md` | UI (`/agent-plan` Stage 2b) |
| Supplemental arch docs (module/system/schema) | `milestone-{N}-{slug}/arch-{slug}.md` | Architect (during planning or engineering) |
| Supplemental UI specs (screen/component) | `milestone-{N}-{slug}/ui-{slug}.md` | UI (during planning or engineering) |
| Risk review (security + performance lenses, one file) | `milestone-{N}-{slug}/reviews/risk.md` | CEO (`/agent-plan` Stage 3, its risk pass) |
| CEO planning verdict | `milestone-{N}-{slug}/reviews/ceo.md` | CEO (`/agent-plan` Stage 3) |
| UX review of implemented screens | `milestone-{N}-{slug}/reviews/ux.md` | UI (milestone completion; UI-flagged milestones only) |
| Risk implementation review (controls verified, budgets measured) | `milestone-{N}-{slug}/reviews/risk-impl.md` | CEO (milestone completion; only when a `reviews/risk.md` flag line says Yes) |
| Milestone close record (per-task validation, milestone validation, completion summary, retrospective) | `milestone-{N}-{slug}/reviews/close.md` | Product (milestone completion, one pass) |
| Per-bug report | `milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md` (or `one-off/bugs/` for `/agent-task` work and `/file-bug` user reports) | Reviewer or `/file-bug` files; Product triages and closes; Coder investigates, fixes, and verifies |
| Bug index (ID assignment, one-line status per bug, regression checklist) | `artifacts/BUGS.md` | Reviewer and `/file-bug` add rows; owners update status column |
| One-off task backlog (queue entries, lifecycle, field ownership) | `artifacts/TASKS.md` | `/add-task` adds entries; `/agent-task` and Product (`/agent-plan` Stage 1) advance statuses |
| One-off task file | `one-off/task-{slug}.md` | `/agent-task` |
| Session progress log | Entries in `artifacts/STANDUP.md` | Any agent / user |
| Cross-milestone state (Decisions Log, Milestone Progress, Performance Budget, Open Questions) | `artifacts/AGENT_STATE.md` — no agent reads this file | The orchestrator (from stages' handoff entries) |
| Install health report (state findings, diet prescriptions, coverage gaps) | `artifacts/DOCTOR.md` — overwritten per run | `/cast-doctor` |
| Release record (gates, version, changelog entry, GO / NO-GO) | `releases/release-{VERSION}.md` | `/cast-release` |

Templates for every artifact type live in `.claude/cast/templates/` — see the README there.

---

> **Naming note:** Do not rename this directory to `references/`. "Reference material" is what your own documentation contains, so `references/` would invert the meaning. The name `artifacts/` was chosen because every file here is a produced output of the agent pipeline with a defined schema and owner — which is what an artifact is.

## What Does NOT Go Here

The following belong in the project's own documentation (mapped by `.claude/cast/SOURCES.md`) or in `.claude/cast/`, not `artifacts/`:

- Product requirements, vision, and glossary (→ your Product & Requirements sources)
- Coding conventions, file placement rules, error handling guidelines (→ your Standards & Conventions sources)
- Testing strategy (→ your Testing & Quality sources)
- Design rationale that outlives one milestone (→ your Documentation Home)
- Release changelog and other registers (→ your Project Registers)
- Document templates (`.claude/cast/templates/ARCH_MODULE.md`, `.claude/cast/templates/UI_SPEC.md`, `.claude/cast/templates/TASK.md`, etc.)

If you find yourself adding any of the above to `artifacts/`, stop and move it to its real home — and point the source map at it.

---

_Last updated: [YYYY-MM-DD]_
