# .claude/cast/, artifacts, and root-file dispositions + plan file format

Reference material for Phase 3 (Migration plan). Agent and pipeline-skill dispositions live in `roster.md`.

## The `.claude/cast/` install

v4 installs CAST's machinery under `.claude/cast/` — no documentation is installed anywhere, ever. For each file:

| CAST file | Disposition |
|---|---|
| `.claude/cast/SOURCES.md` | **Always Create** — written from the source-map interview answers recorded in the plan (see SKILL.md Phase 3), with `[PROJECT_NAME]` substituted and today's date on the Last updated line. Every confirmed entry lands verbatim; unconfirmed candidates are left out (never guess). On an upgrade where a `SOURCES.md` already exists, this is **Update in place**: preserve the user's entries, add interview-confirmed additions, never silently remove a row |
| `.claude/cast/PIPELINE_LOOP.md` | **Always install** — the engineering-loop contract consumed by /agent-code and /agent-task. Substitute `[TEST_CMD]` and `[MAX_LOOP_COUNT]`; preserve user loop customizations from a prior install as notes |
| `.claude/cast/STAGE_CONTRACT.md` | **Always install** — the one process document agents read |
| `.claude/cast/templates/MILESTONE_DEFINITION.md` | **Always install** — consumed by /agent-plan Stage 1 (instantiated as each milestone's `README.md`; carries the Standards Digest section) |
| `.claude/cast/templates/TASK.md` | **Always install** — consumed by /agent-plan Stage 1 (one instance per task) and /agent-task |
| `.claude/cast/templates/BUG_REPORT.md` | **Always install** — consumed by Reviewer and /file-bug (one instance per bug) |
| `.claude/cast/templates/MILESTONE_CLOSE.md` | **Always install** — consumed by Product at the milestone-completion checkpoint. A pre-v3 (v2) install's `MILESTONE_VALIDATION.md` / `MILESTONE_COMPLETION.md` / `MILESTONE_RETROSPECTIVE.md` map to **Delete** with their duties named as merged here; existing `reviews/validation.md` / `completion.md` / `retrospective.md` *instances* are records — preserve them where they are |
| `.claude/cast/templates/ARCH_MODULE.md`, `ARCH_SYSTEM.md`, `ARCH_DATA_SCHEMA.md` | **Always install** — consumed by /agent-plan Stage 2a |
| `.claude/cast/templates/CEO_REVIEW.md` | **Always install** — consumed by /agent-plan Stage 3 |
| `.claude/cast/templates/UI_SPEC.md`, `UX_REVIEW.md` | Install if and only if the `ui` agent is installed — skipped together with it under the backend/CLI-only opt-out in `roster.md` |
| `.claude/cast/templates/README.md` | **Always install** — the in-directory index mapping each template to its producing agent and artifact destination. Unlike the template skeletons, it installs with placeholder substitution and scaffolding strip (it is documentation about the directory, not a template) |

The template skeletons install **verbatim** (comment blocks included — they instruct the agents that instantiate them); everything else under `.claude/cast/` gets the substitution and scaffolding-strip passes.

## Migrating a v3 (or earlier) CAST install — the docs/ and templates/ dispositions

A prior CAST version installed `docs/` and `templates/` directories into the project. v4 removes CAST's claim on them without touching the user's content. **The governing rule: content the user wrote is theirs and stays exactly where it is — the source map points at it; content CAST shipped and nobody filled in is clutter — propose Delete.** Per file found:

| Found in the project | Disposition |
|---|---|
| A **filled** CAST doc — a PRD with real requirements, populated CODE_PATTERNS/ERROR_HANDLING/TEST_FRAMEWORK, a real GLOSSARY or CONCEPT, a maintained `docs/CHANGELOG.md`, a populated DESIGN_RATIONALE | **Preserve in place** + propose the matching source-map entry in the interview (PRD/CONCEPT/GLOSSARY → Product & Requirements; CODE_PATTERNS/FILE_CONVENTIONS/ERROR_HANDLING → Standards & Conventions; TEST_FRAMEWORK → Testing & Quality; CHANGELOG → Project Registers; the `docs/` directory itself is the natural Documentation Home candidate). Judge "filled" by content, not filename: real project decisions and requirements, not `[PLACEHOLDER]` skeleton |
| An **unfilled** CAST doc skeleton (placeholder-dense, never populated) | **Delete** (requires approval, itemized). Name what it was in the rationale so the user can keep any they meant to fill |
| CAST **process docs** — `docs/PIPELINE_LOOP.md`, `docs/STAGE_CONTRACT.md`, `docs/MODEL_OPTIMIZATION.md`, `docs/FIRST_RUN.md`, `docs/CLAUDE_CODE_SETTINGS.md`, `docs/README.md` (when it is CAST's index, not user content) | **Delete** (approval) — the two contracts are reinstalled at `.claude/cast/`; the rest are retired in v4. User annotations found inside them are rescued into the plan as notes before the delete executes |
| Topic docs (`docs/FRONTEND.md` / `BACKEND.md` / `CLI.md` / `MOBILE.md`) | Filled → Preserve + Standards & Conventions entry; skeleton → Delete (approval) |
| The `templates/` directory (CAST's ten skeletons) | **Rename + Update**: `git mv` each skeleton to `.claude/cast/templates/` and update it to the current payload version, preserving user-added sections per the merge rules in `execution.md`. User-authored templates found alongside them move too, preserved verbatim, and get a row in the templates README |
| v3 `CLAUDE.md` CAST content — the Directory Conventions section, the Memory Imports block's `@docs/...` lines, the version stamp | **Update in place**: remove the CAST-owned sections and any CAST-added import lines, keep every user section verbatim, append the v4 CAST section (with the new stamp). User-authored imports are never touched |

Never execute a documentation Delete or move in the same action that writes the source map — map entries must point at post-migration paths, so sequence the plan: moves/deletes first, `SOURCES.md` written after, validation resolving it last.

## Artifacts directory

If `artifacts/` does not exist, Create it with:

- `BUGS.md` from CAST template (the global bug index)
- `TASKS.md` from CAST template (the one-off task backlog `/add-task` fills and `/agent-task` drains)
- `STANDUP.md` from CAST template
- `AGENT_STATE.md` from CAST template
- `README.md` from CAST template
- Empty subdirectory: `one-off/`

Milestone directories (`artifacts/milestone-{N}-{slug}/`) are **not** pre-created — `/agent-plan` Stage 1 creates each one.

If `artifacts/` already exists and contains CAST-shaped files, preserve as-is and integrate.

**Pre-2.0 by-type layout migration.** If `artifacts/` contains the v1 by-type subdirectories (`milestones/`, `architecture/`, `ui-specs/`, `reviews/`), propose a **Rename + Update migration** to the milestone-grouped layout — one plan action per milestone `{N}` found:

| v1 file | v2 destination |
|---|---|
| `milestones/milestone-{N}-{slug}.md` | `milestone-{N}-{slug}/README.md` |
| `milestones/milestone-{N}-{slug}-tasks.md` | split into `milestone-{N}-{slug}/tasks/task-{T}-{slug}.md`, one file per task (see note) |
| `milestones/milestone-{N}-{slug}-completion.md` | `milestone-{N}-{slug}/reviews/completion.md` |
| `milestones/milestone-{N}-{slug}-validation.md` | `milestone-{N}-{slug}/reviews/validation.md` |
| `architecture/arch-milestone-{N}.md` | `milestone-{N}-{slug}/architecture.md` |
| `architecture/module-{slug}.md`, `system-{slug}.md`, `schema-{slug}.md` | `milestone-{N}-{slug}/arch-{slug}.md` (the milestone that produced them; Ask if unclear) |
| `ui-specs/ui-milestone-{N}.md` | `milestone-{N}-{slug}/ui.md` |
| `ui-specs/screen-{slug}.md`, `component-{slug}.md` | `milestone-{N}-{slug}/ui-{slug}.md` (same attribution rule) |
| `reviews/{security,performance}-review-milestone-{N}.md` | `milestone-{N}-{slug}/reviews/risk.md` (merge the two into the one risk review, each as its lens section) |
| `reviews/{ceo,ux}-review-milestone-{N}.md` | `milestone-{N}-{slug}/reviews/{ceo,ux}.md` |
| `reviews/retrospective-milestone-{N}.md` | `milestone-{N}-{slug}/reviews/retrospective.md` (legacy record — preserved as-is; new milestones write `reviews/close.md`) |
| `BUGS.md` bug entries | one `milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md` per entry (attributed by the entry's task/milestone reference; `one-off/bugs/` when unattributable), with `BUGS.md` rewritten as the v2 index |

Use `git mv` per file (preserve history); the `-tasks.md` split and `BUGS.md` conversion are content transformations — flag them as their own plan actions so the user approves them explicitly. Then update every stale path reference across `.claude/` and the project README. **Ask the user before executing the migration.**

If a directory named `features/`, `work/`, or `planning/` exists and contains CAST-shaped files (detected by filename patterns `milestone-*.md`, `arch-milestone-*.md`, `ceo-review-*.md`), propose Rename + Update: rename the directory to `artifacts/` and update every reference across agents and pipeline skills, then apply the pre-2.0 migration above to its contents. This is the pre-0.3.0 CAST migration path. **Ask the user before renaming a directory.**

## Root files

- `CLAUDE.md` — if present, **append** CAST's section (from `root/CLAUDE.md`) and touch nothing else; the file is the user's. If absent, Create a minimal `CLAUDE.md` containing only the CAST section (with `[PROJECT_NAME]` substituted) and tell the user it is theirs to grow. On a v3 upgrade, apply the CLAUDE.md row of the migration table above first.
- `README.md` — preserve the user's existing README. Do not touch it. Optionally offer to add a CAST adoption note at the bottom if the user wants.
- `TROUBLESHOOTING.md` / `CHANGELOG.md` — preserve if present; do **not** create them. CAST ships no root-level template for either. Point the user at the CAST repo's troubleshooting guide (`https://github.com/Raxvis/CAST/blob/main/TROUBLESHOOTING.md`) instead; the project's changelog, wherever it lives, is a Project Registers candidate for the source map.

`root/CLAUDE.md` (the CAST section) is the only content /cast-init installs at the target project root.

## Write the migration plan

Write the full plan to `artifacts/adoption-plan.md`. Structure:

```markdown
# CAST Adoption Plan
Generated: <ISO date>
Classification: <A. Greenfield / B. Partial / C. Full existing>
Phase separation: <None / Implicit / Explicit>

## Summary
<3-5 sentences describing the scope of changes, total file counts by action, and anything the user should read carefully>

## Source map (proposed)
<one block per category: the candidate locations Phase 1.3 found, each with a one-line
classification rationale, or "None found — propose _None declared._">

## Proposed actions

### Create (N actions)
1. **Create** `.claude/agents/ceo.md`
   - Source: `<CAST_SOURCE>/agents/ceo.md`
   - Substitutions: `[PROJECT_NAME]` → `<detected>`
   - Rationale: CAST requires CEO for /agent-plan Stage 3; no existing equivalent found.

### Rename + Update (N actions)
1. **Rename + Update** `planner.md` → `.claude/agents/product.md`
   - Source: `<CAST_SOURCE>/agents/product.md`
   - Preserve: custom "Planning heuristics" section from original file as an appendix
   - Rationale: existing planner agent fills the Product role; renaming to match CAST canonical name.

### Update in place (N actions)
1. **Update** `CLAUDE.md`
   - Source: append the CAST section from `<CAST_SOURCE>/root/CLAUDE.md`
   - Preserve: every existing section verbatim
   - Rationale: CAST claims one section of CLAUDE.md; the rest is the user's.

### Preserve as-is (N actions)
1. **Preserve** `docs/architecture/` (12 files)
   - Rationale: the project's own architecture documentation — mapped in the source map (Architecture & Design), never moved.

### Skip (not applicable) (N actions)
1. **Skip** `.claude/cast/templates/UI_SPEC.md`
   - Rationale: project is a CLI tool with the recorded `ui` opt-out; the UI templates skip with the agent.

### Delete (requires explicit approval) (N actions)
1. **Delete** `.claude/commands/agent-plan.md`
   - Rationale: superseded by `.claude/skills/agent-plan/SKILL.md` after the pre-1.0 migration. Keeping both would register a duplicate /agent-plan. Requires user approval.
2. **Delete** `docs/MODEL_OPTIMIZATION.md`
   - Rationale: CAST-owned process doc from the v3 install, retired in v4; unfilled by the user. Requires user approval.

### Ask — decisions requiring user input (N questions)
1. Source map — Standards & Conventions: I found `CONTRIBUTING.md` (code style section) and `docs/conventions.md`. Map both, one, or others I missed?
2. Source map — Documentation Home: `docs/` looks like where documentation updates should land. Confirm, name another location, or declare none (Docs Writer will then never run; pending doc notes surface to you instead)?
3. You have an existing `designer.md` agent. It looks closer to CAST's UI agent than the Product agent. Should I rename it to `.claude/agents/ui.md`, map it to Product, or create both fresh and leave designer.md alone?
4. You have a `features/` directory with 12 files matching CAST's pre-0.3.0 naming. Confirm renaming to `artifacts/` and updating all cross-references?
5. CAST installs 7 agents by default. This project is backend/CLI-only with no user interface — should I skip the `ui` agent and its two templates (`UI_SPEC.md`, `UX_REVIEW.md`)? (Recommended: skip. `/agent-plan` detects the absence and skips its UI stage automatically, so the pipeline stays runnable. Everything else installs.)
```

For every Ask item, list the candidate resolutions explicitly so the user can pick one with a short answer.
