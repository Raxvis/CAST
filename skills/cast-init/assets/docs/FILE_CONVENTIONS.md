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
| `artifacts/` | **Work artifacts only.** Instances of *actual work*, grouped by milestone. | One directory per milestone (definition, design specs, reviews, per-task files, per-bug files), plus cross-milestone logs (bug index, session log, agent state). |

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
  STAGE_CONTRACT.md              # The only process doc an agent reads
  PIPELINE_LOOP.md               # Engineering-loop contract (orchestrator only)
  MODEL_OPTIMIZATION.md          # Model and effort policy
  TEST_FRAMEWORK.md              # Testing strategy
  CHANGELOG.md                   # Release history (/cast-release owns)
  ASSETS.md                      # Asset registry
  MVP_LAUNCH.md                  # Launch checklist
  FIRST_RUN.md                   # Onboarding walkthrough
  CLAUDE_CODE_SETTINGS.md        # Claude Code settings notes
  FRONTEND.md / BACKEND.md / CLI.md / MOBILE.md   # Topic docs (only those applicable)
```

### `templates/` — document templates

```
templates/
  ARCH_MODULE.md                 # Module architecture template
  ARCH_SYSTEM.md                 # System architecture template
  ARCH_DATA_SCHEMA.md            # Data schema template
  UI_SPEC.md                     # UI specification template
  MILESTONE_DEFINITION.md        # Milestone README template (the milestone's highest-order doc)
  TASK.md                        # Single-task file template (one instance per task)
  BUG_REPORT.md                  # Single-bug file template (one instance per bug)
  MILESTONE_CLOSE.md             # Milestone close record template (per-task validation,
                                 #   milestone validation, completion summary, retrospective)
  CEO_REVIEW.md                  # CEO planning-review template
  UX_REVIEW.md                   # UX review template
```

Templates are copied — never filled in place — to produce instances under `artifacts/`.

### `artifacts/` — work artifacts

```
artifacts/
  README.md                                # Work directory index
  BUGS.md                                  # Global bug INDEX (one line per bug → its file)
  STANDUP.md                               # Rolling session progress log
  AGENT_STATE.md                           # Project state (orchestrator-written)
  DOCTOR.md                                # /cast-doctor health report (created on first
                                           #   run; overwritten each run — git keeps history)

  milestone-{N}-{slug}/                    # One directory per milestone
    README.md                              # Milestone definition (highest-order doc: goal,
                                           #   Status, Task Index, CEO Approval Conditions)
    architecture.md                        # Milestone architecture document
    ui.md                                  # Milestone UI spec (UI milestones only)
    arch-{slug}.md                         # Supplemental module/system/schema docs
    ui-{slug}.md                           # Supplemental screen/component specs
    reviews/
      risk.md                              # Risk review: security + performance lenses,
                                           #   plus the two implementation-review flags
      ceo.md                               # CEO planning verdict
      ux.md                                # UX review (/agent-code milestone completion)
      risk-impl.md                         # Risk implementation review (milestone
                                           #   completion; flagged milestones only)
      close.md                             # Milestone close record (Product, one pass)
    tasks/
      task-{T}-{slug}.md                   # ONE FILE PER TASK (Context Manifest + Handoff Log)
    bugs/
      bug-{XXX}-{slug}.md                  # ONE FILE PER BUG found during this milestone

  one-off/                                 # /agent-task work
    task-{slug}.md
    archive/                               # Complete one-off task files (orchestrator moves
                                           #   them here at milestone checkpoints)
    bugs/
      bug-{XXX}-{slug}.md                  # Never archived — the BUGS.md index points here

  releases/                                # Release records written by /cast-release
    release-{VERSION}.md

  archive/                                 # Overflow for the bounded root files: stale
    STANDUP.md                             #   STANDUP sessions and AGENT_STATE rows,
    AGENT_STATE.md                         #   relocated verbatim by the orchestrator
```

Milestone directories are created by `/agent-plan` Stage 1 (with `reviews/`, `tasks/`, and `bugs/` created as their first files are written); `/cast-init` pre-creates only the root files and `one-off/`. Do not create additional subdirectories beyond these without updating this file and `artifacts/README.md`.

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
| `STAGE_CONTRACT.md` | The stage contract — the only process doc an agent reads |
| `PIPELINE_LOOP.md` | Engineering-loop contract (orchestrating skills only) |
| `MODEL_OPTIMIZATION.md` | Model and effort policy, per-model profiles |
| `TEST_FRAMEWORK.md` | Testing strategy |
| `CHANGELOG.md` | Chronological release log |
| `ASSETS.md` | Asset registry |
| `MVP_LAUNCH.md` | Launch readiness checklist |
| `FIRST_RUN.md`, `CLAUDE_CODE_SETTINGS.md` | Onboarding and settings notes |
| `FRONTEND.md`, `BACKEND.md`, `CLI.md`, `MOBILE.md` | Topic-specific reference (only those applicable to the project) |

### Document Templates (`templates/`)

Templates live in `templates/` and are copied — never filled in place — to produce instances under `artifacts/`.

| Template | Instance Destination |
|---|---|
| `templates/MILESTONE_DEFINITION.md` | `artifacts/milestone-{N}-{slug}/README.md` |
| `templates/TASK.md` | `artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md` (one per task), or `artifacts/one-off/task-{slug}.md` |
| `templates/BUG_REPORT.md` | `artifacts/milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md` (one per bug), or `artifacts/one-off/bugs/bug-{XXX}-{slug}.md` |
| `templates/ARCH_MODULE.md` | `artifacts/milestone-{N}-{slug}/arch-{slug}.md` |
| `templates/ARCH_SYSTEM.md` | `artifacts/milestone-{N}-{slug}/architecture.md` (the milestone architecture document) or `arch-{slug}.md` |
| `templates/ARCH_DATA_SCHEMA.md` | `artifacts/milestone-{N}-{slug}/arch-{slug}.md` |
| `templates/UI_SPEC.md` | `artifacts/milestone-{N}-{slug}/ui.md` (the milestone UI spec) or `ui-{slug}.md` |
| `templates/MILESTONE_CLOSE.md` | `artifacts/milestone-{N}-{slug}/reviews/close.md` |
| `templates/CEO_REVIEW.md` | `artifacts/milestone-{N}-{slug}/reviews/ceo.md` |
| `templates/UX_REVIEW.md` | `artifacts/milestone-{N}-{slug}/reviews/ux.md` |

### Milestone Directories (`artifacts/milestone-{N}-{slug}/`)

**Naming pattern:** `milestone-{N}-{slug}/`

- `{N}` is the milestone number (e.g., `1`, `2`, `7`).
- `{slug}` is a kebab-case short name (e.g., `user-auth`, `search-ui`).

Inside the directory, filenames are fixed: `README.md` (definition), `architecture.md`, `ui.md`, `reviews/{risk,ceo,ux,risk-impl,close}.md` (`risk-impl.md` exists only for milestones whose `risk.md` flag lines say Yes; `ux.md` only for UI-flagged milestones). Supplemental design docs use `arch-{slug}.md` (instances of `templates/ARCH_MODULE.md` / `ARCH_DATA_SCHEMA.md` when a milestone needs module- or schema-level depth beyond `architecture.md`) and `ui-{slug}.md` (screen- or component-scoped specs). `architecture.md` is an **instance of `templates/ARCH_SYSTEM.md`** — that template defines its required headings.

### Task Files (`artifacts/milestone-{N}-{slug}/tasks/`)

**Naming pattern:** `task-{T}-{slug}.md` — `{T}` is the task's zero-padded ordinal within the milestone (e.g., `task-01-add-command.md`), `{slug}` a kebab-case short name. One-off tasks (`/agent-task`) use `artifacts/one-off/task-{slug}.md` with no ordinal.

Each task file is an instance of `templates/TASK.md`: a self-contained unit of work carrying its own description, acceptance criteria, **Context Manifest** (the complete read set for the task), and **Handoff Log** (the append-only record every stage transition writes). Task status lives ONLY in the task file's Header — nowhere else.

### Bug Files (`artifacts/milestone-{N}-{slug}/bugs/` and `artifacts/one-off/bugs/`)

**Naming pattern:** `bug-{XXX}-{slug}.md` — `{XXX}` is the project-wide sequential ID assigned via the index in `artifacts/BUGS.md`; `{slug}` a kebab-case short name. The filename is lowercase; the *identifier* stays uppercase in prose, headings, and the index (`BUG-001`) — same split as tasks (`T-1` in text, `task-01-{slug}.md` on disk). Each file is an instance of `templates/BUG_REPORT.md`, filed in the milestone (or `one-off/`) where the bug surfaced, and never moved.

---

## Agent Responsibilities Summary

| Situation | Action |
|---|---|
| Planning a milestone | Product creates `artifacts/milestone-{N}-{slug}/` and writes `README.md` + one `tasks/task-{T}-{slug}.md` per task |
| Documenting architecture for a milestone | Architect writes `artifacts/milestone-{N}-{slug}/architecture.md` |
| Specifying UI for a milestone | UI writes `artifacts/milestone-{N}-{slug}/ui.md` |
| Filing risk findings | CEO writes `artifacts/milestone-{N}-{slug}/reviews/risk.md` (both lenses, its risk pass) |
| Recording a CEO verdict | CEO writes `artifacts/milestone-{N}-{slug}/reviews/ceo.md` |
| Logging a bug | Reviewer creates `bugs/bug-{XXX}-{slug}.md` in the current milestone (or `artifacts/one-off/bugs/`) and adds its index row to `artifacts/BUGS.md` |
| Closing a milestone | Product writes `artifacts/milestone-{N}-{slug}/reviews/close.md` in one pass (per-task validation, milestone validation, completion summary, retrospective) |
| Reviewing implemented UI at milestone completion | UI writes `artifacts/milestone-{N}-{slug}/reviews/ux.md` (UI-flagged milestones only) |
| Reviewing the implementation for risk at milestone completion | CEO writes `artifacts/milestone-{N}-{slug}/reviews/risk-impl.md` — security controls verified and budgets measured (only when a `risk.md` flag line says Yes) |
| Recording session progress | Any agent appends to `artifacts/STANDUP.md` using its Entry Grammar (both `/agent-code` completion and `/agent-task` completion write entries here) |
| Updating cross-milestone state tables | The orchestrator appends rows to `artifacts/AGENT_STATE.md` from stages' handoff entries — no agent reads or writes that file |
| Updating reference documentation | Docs Writer edits the relevant file in `docs/` |
| Adding a release changelog entry | The `/cast-release` skill appends to `docs/CHANGELOG.md` |
| Creating any new reference doc | Docs Writer registers it in `docs/README.md` |

**`/agent-task` scope note.** `/agent-task` is bounded to `artifacts/one-off/` (its task file and any bug files), plus `artifacts/STANDUP.md` and `artifacts/BUGS.md` updates. It does **not** write inside any `artifacts/milestone-{N}-{slug}/` directory — those are owned by `/agent-plan` and `/agent-code` outputs. If a one-off task turns out to need milestone-grade planning artifacts, `/agent-task` halts and instructs the user to run `/agent-plan` first. See the CAST repo's [`TROUBLESHOOTING.md`](https://github.com/Raxvis/CAST/blob/main/TROUBLESHOOTING.md) for the full decision table on which command to use.

---

## Revisions: git is the audit log

Planning artifacts are revised **in place**. The existing file is overwritten; prior content is not preserved inline and no filename churn occurs.

CAST v2 additionally required a `## Revision History` table at the top of every planning artifact — a hand-maintained changelog on ten document types, restating what `git log` already recorded, and read in full by the CEO on every re-review. It is gone in v3. **`git log --follow <path>` and `git diff` are the audit log**, and they cannot drift from the file the way a hand-maintained table can.

What replaces it, where it actually mattered:

- **CEO re-review** — read `git diff` for the changed artifacts to see what moved, then verify the body reflects the claimed change. This is strictly better than the table: a table entry could claim a fix the body never received.
- **Retrospective metrics** — "architecture doc revisions" comes from the git log for that path.
- **Task files** keep their Handoff Log; bug files keep their Status lifecycle; `BUGS.md`, `STANDUP.md`, and `AGENT_STATE.md` are append-only running logs; `DOCTOR.md` is overwritten per run. None of these needed the table either.

**Revised design docs invalidate manifests.** This is the one thing a revision must still do explicitly: rewriting `architecture.md` or `ui.md` can move or remove the section anchors that task Context Manifests cite, and a stale anchor silently defeats the minimal-context contract. On every revision the revising agent re-checks its previously returned manifest rows against the new document and returns corrected rows; the orchestrator re-applies them before any downstream stage reads them.

---

## Anti-Patterns

The following behaviors violate these conventions. Do not do them:

- **Writing work artifacts to `docs/`.** Bug reports, milestone plans, CEO reviews, and session logs do not belong in `docs/`. They go in `artifacts/`.
- **Writing reference material to `artifacts/`.** Coding conventions, glossaries, and design rationale do not belong in `artifacts/` — they go in `docs/`. Document templates do not belong there either — they go in `templates/`.
- **Filling in templates in place.** `templates/TASK.md` is the template — copy it to `artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md` before filling it in.
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
| Document templates | `templates/` | `UPPER_SNAKE_CASE.md` |
| _Case rule_ | — | UPPER_SNAKE is reserved for **system singletons** (reference docs, templates, the artifacts-root state files — fixed files named at design time). **Instance files that multiply as work happens** (milestone dirs, task files, bug files, reviews, supplemental specs) are lowercase kebab-case. `README.md` / `CLAUDE.md` / `SKILL.md` follow their external conventions. |
| Release changelog | `docs/CHANGELOG.md` | fixed |
| Global bug index | `artifacts/BUGS.md` | fixed |
| Rolling session log | `artifacts/STANDUP.md` | fixed |
| Cross-milestone state tables (orchestrator-written) | `artifacts/AGENT_STATE.md` | fixed |
| Doctor health report | `artifacts/DOCTOR.md` | fixed — overwritten by each `/cast-doctor` run |
| Milestone definition | `artifacts/milestone-{N}-{slug}/` | `README.md` |
| Task file (one per task) | `artifacts/milestone-{N}-{slug}/tasks/` | `task-{T}-{slug}.md` |
| One-off task file | `artifacts/one-off/` | `task-{slug}.md` |
| Milestone architecture | `artifacts/milestone-{N}-{slug}/` | `architecture.md` |
| Supplemental arch doc (module/system/schema) | `artifacts/milestone-{N}-{slug}/` | `arch-{slug}.md` |
| Milestone UI spec | `artifacts/milestone-{N}-{slug}/` | `ui.md` |
| Supplemental UI spec (screen/component) | `artifacts/milestone-{N}-{slug}/` | `ui-{slug}.md` |
| Bug file (one per bug) | `artifacts/milestone-{N}-{slug}/bugs/` or `artifacts/one-off/bugs/` | `bug-{XXX}-{slug}.md` |
| Risk review (security + performance lenses) | `artifacts/milestone-{N}-{slug}/reviews/` | `risk.md` |
| CEO review | `artifacts/milestone-{N}-{slug}/reviews/` | `ceo.md` |
| UX review | `artifacts/milestone-{N}-{slug}/reviews/` | `ux.md` |
| Risk implementation review (controls + measured budgets) | `artifacts/milestone-{N}-{slug}/reviews/` | `risk-impl.md` |
| Milestone close record | `artifacts/milestone-{N}-{slug}/reviews/` | `close.md` |
| Release record | `artifacts/releases/` | `release-{VERSION}.md` |

---

## Rationale

The `docs/` vs `artifacts/` split exists for three reasons:

1. **Predictability for agents.** An agent asked to file a bug report always knows the file goes in the current milestone's `bugs/` directory with an index row in `artifacts/BUGS.md`; an agent asked to look up coding conventions always knows to read `docs/CODE_PATTERNS.md`. Ambiguity causes agents to guess, and guessing produces scattered outputs. Grouping by milestone also bounds what any agent needs to look at: everything about a milestone is inside its one directory.

2. **Clean diffs and reviews.** Reference material changes slowly and deliberately; work artifacts churn constantly. Separating them means diffs on `docs/` signal intentional policy changes, while diffs on `artifacts/` signal ordinary work progress. Reviewers can skim `docs/` changes carefully and `artifacts/` changes quickly.

3. **Safe bulk operations.** "Wipe all in-flight work and start over" becomes `rm -rf artifacts/` — a contained, reversible operation. If work and reference were mixed, you could not do this without also destroying project knowledge.

---

_Last updated: [YYYY-MM-DD]_
