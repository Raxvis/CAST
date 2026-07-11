# Template Changelog

This file tracks changes to the multi-agent workflow **template itself**. It is separate from `docs/CHANGELOG.md`, which is a release changelog for the target project that adopts the template.

Format is loosely based on [Keep a Changelog](https://keepachangelog.com/). Versions follow semantic versioning: major = breaking structural changes that require migration, minor = additive or reorganizing changes, patch = doc fixes and small corrections.

The current template version is recorded in four synchronized locations: the root `README.md` (badge + hero line), this `CHANGELOG.md`, `.claude-plugin/plugin.json` (`version`), and `skills/cast-init/SKILL.md` (`metadata.version`).

---

## [1.3.0] — 2026-07-11

Full-system hardening pass: a four-track review of the adoption skill, agent roster, pipeline skills, and packaging produced 45 improvements, all landed here. Headlines: the installed CLAUDE.md's memory imports actually load now, defect routing is stated identically everywhere, the pipelines are resumable and their documented-but-never-invoked stages (Docs Writer, Validator, UX review) are wired in, `/cast-init` handles re-runs/monorepos/non-git projects, and releases are automated.

### Added

- **`templates/MILESTONE_RETROSPECTIVE.md`** — milestone retrospectives were previously written *into* `validator.md`, violating both the artifacts split and the immutable-agent-file rule. They are now instances at `artifacts/reviews/retrospective-milestone-{N}.md`, written by Validator at the `/agent-code` milestone checkpoint.
- **`[CAST_VERSION]` version stamp.** `/cast-init` now stamps `Adopted with CAST v<X.Y.Z>` into the installed CLAUDE.md (sourced from its own `metadata.version`) and reads it back on re-runs — the documented upgrade path finally has something to compare against. Forced re-run semantics are defined.
- **Adoption-skill coverage for previously undefined situations:** monorepo/workspace detection (root-level install default, manifest ambiguity becomes a Phase 3 Ask), non-git projects (explicit confirmation, plain `mv`, no-rollback warning), same-named agent files with divergent roles (always an Ask, never silent update-in-place), archival of prior adoption records, an explicit execute-approved-Deletes step, a Phase 5 progress ledger with abort/recovery instructions, unattended-mode fallbacks for novel Asks and validation failures, and a documented `ui` opt-out for backend/CLI-only projects (UI templates skipped iff the agent is skipped; `/agent-plan` skips its UI stage when no `ui` agent is installed).
- **Pipeline wiring for stages that previously had no invoker:** both engineering skills drain the Docs Writer queue at task/milestone checkpoints; Validator is invoked at those checkpoints to record outcomes in `artifacts/AGENT_STATE.md`; the UX review runs once per UI-flagged milestone at `/agent-code` milestone completion; Release is explicitly user-invoked.
- **Resumability:** `/agent-code` writes task Status back to the milestone tasks file and skips Complete tasks on re-invocation; `/agent-plan` writes per-stage checkpoints to STANDUP, defines milestone numbering (max existing + 1), and caps the REVISION REQUIRED loop at 3 cycles before escalating.
- **`.github/workflows/release.yml`** — on push to main with an untagged `plugin.json` version: verifies the four synchronized version locations, creates the annotated tag, and publishes the GitHub Release from the top CHANGELOG section; a second job verifies integrity on `v*` tag pushes. Checklist steps 5–6 are now automated with the manual path as fallback.
- **Six new CI checks in `validate.yml`:** README placeholder-table tokens must exist in the payload; `example/` must be token-free; docs/templates/artifacts path-split lint; offline relative-link check; example instances must carry their template's required headings; agent model pins must be identical. Manifests are validated with `claude plugin validate` instead of bare `JSON.parse`.

### Changed

- **Installed CLAUDE.md memory imports fixed.** The template used `@import docs/X.md`, a syntax Claude Code does not support — every adopted project silently loaded no core context. Imports are now bare `@docs/X.md` lines; commented suggestions use inert code spans; `/cast-init` validation now checks the syntax and that imported paths exist.
- **Defect routing stated identically everywhere.** Canonical flow: Reviewer → Bug Gatherer (files report, status New) → Product triage (**Fix Now** → Debugger → Coder; **Defer** — allowed only when acceptance criteria are unaffected, task proceeds; **Not a Bug** — closed with rationale). `reviewer.md`, `debugger.md`, `tester.md`, `bug-gatherer.md`, and `docs/PIPELINE_LOOP.md` all previously contradicted this in different ways; Tester failures route to Coder only. "Clean version" = no open Fix Now defects.
- **All 15 agent frontmatter descriptions rewritten trigger-first** for Claude Code subagent auto-discovery (e.g. Tester: "Use PROACTIVELY after every Coder change"), and the roster table in `references/roster.md` synced verbatim (CI-enforced).
- **Agent Model Configuration boilerplate compressed** from ~8–10 duplicated lines per file to ~2, with every behavioral constraint kept in-file and the shared model-ladder rationale consolidated in `docs/MODEL_OPTIMIZATION.md` (~100+ lines removed across the roster).
- **Cross-agent contract fixes:** Architect/Product/UI Inputs tables now receive Security/Performance findings and CEO revision requests; Coder hands off to Tester (not Product); Release gates on "Critical or High" (the 4-level scale — "Major" existed nowhere); Security's Informational findings are review-document-only (never filed as bugs); `docs/CHANGELOG.md` has a single owner (Release; Docs Writer routes through it); CI/build infrastructure and dependency maintenance have assigned owners; Release's checklist gains the security pre-release gate.
- **One STANDUP entry grammar** (`### YYYY-MM-DD — <skill> — <milestone/task>` sections with `- <agent> | <type> | <note>` entries; types progress/loop/docs/decision/blocker) replaces the four incompatible formats previously implied by STANDUP.md, `agent-task`, PIPELINE_LOOP, and the roster README.
- **CEO Approval Conditions** are backfilled into the milestone tasks file by Product after the verdict; `/agent-code` Pre-Flight reads them from there. Product (not the orchestrator) writes completion and validation records.
- **Naming/path corrections:** artifact instance names unified to lower-hyphen (`module-{slug}.md`, `screen-{slug}.md`, new `component-{slug}.md`), STANDUP's related-documents links fixed, "Work Queue" renamed to AGENT_STATE's actual "Current Work — Ready to Start", `validator.md`'s stale "Product's file" reference fixed, path-split wording bugs in `security.md`/`docs-writer.md` corrected.
- **README placeholder table pruned of 22 dead tokens** (also from `references/execution.md`/`discovery.md` substitution lists) and gains `[CAST_VERSION]` + `[MAX_LOOP_COUNT]`; the docs/ "never receives work" wording now carries the `docs/CHANGELOG.md` carve-out; the plugin-route asymmetry (full repo in the plugin cache) is documented; `/artifacts/` is gitignored at the repo root.
- **Example fixture synced to the 1.2.0 template contracts:** milestone definition, tasks file, architecture doc, UI spec, and CEO review all restructured to their templates' required sections (CI-enforced from now on); stray `[MILESTONE_NAME]` token removed; example imports fixed to the working syntax and trimmed to files the fixture ships.
- **`/cast-init` validation hardening:** placeholder grep scoped to the installed file set with `templates/*` exempt; new ui-agent ⇔ UI-templates consistency check; import-syntax check; Phase 7 closing summary and report parameterized for staged/partial/failed outcomes.

### Migration

- Existing installs: re-run `/cast-init` (after `npx skills update`). The memory-import fix alone is worth it — installs adopted from any earlier version load no `docs/` context at session start. The re-run also delivers the corrected defect routing, the retrospective/UX-review/Docs-Writer wiring, and stamps the version for future upgrades.
- If you customized `reviewer.md`, `debugger.md`, `tester.md`, or `docs/PIPELINE_LOOP.md`, review the merge: the defect-routing and triage-outcome wording changed in all four.
- `validator.md` no longer accumulates retrospectives in place; move any existing ones to `artifacts/reviews/retrospective-milestone-{N}.md`.

---

## [1.2.2] — 2026-07-05

CI hardening: the validation workflow now enforces the 1.2.0 single-source-of-truth invariants, and writing those checks immediately caught three stale routing lines the 1.2.0 sweep missed in the payload itself.

### Changed

- **Three leftover pre-1.2 routing phrasings corrected in the payload.** The Issue loop is `Refactor → Tester → Reviewer` since 1.2.0, but three places still said `Refactor → Reviewer`: the `/agent-code` skill's frontmatter `description` (functional metadata Claude Code reads for skill discovery), the pipeline-skills table in `assets/skills/README.md`, and the loop-counter rule in `docs/PIPELINE_LOOP.md` ("Refactor→Reviewer rounds"). All three now state the full sequence.
- **`.github/workflows/validate.yml` gains five invariant checks** (repo CI only, not installed):
  - *No stale pipeline-routing orders* — greps README, CLAUDE.md, TROUBLESHOOTING.md, the payload, and the example for the pre-1.2 adjacencies (`Debugger → Bug Gatherer`, `Refactor → Reviewer` in any bold/arrow/spacing variant); `docs/PIPELINE_LOOP.md` is the canonical loop contract. CHANGELOG.md is excluded as historical.
  - *Template markers* — every level-2 heading in `templates/*.md` must carry `(required)` or `(optional)` (level-3 per-instance blocks and the `## Task Template` sub-skeleton are exempt).
  - *Canonical bug lifecycle* — payload and example `BUGS.md` must contain the `New → Triaged → In Progress → Fixed → Verified → Closed` flow and the field-ownership table; the example must not use pre-1.2 status vocabulary.
  - *1.2 state files present* — `AGENT_STATE.md` (payload + example) and `docs/PIPELINE_LOOP.md` must exist.
  - *README File Listing counts* — the `docs/` and `templates/` file counts claimed in README.md must match the payload.

### Migration

- Existing installs: re-run `/cast-init` (or `npx skills update` first) if you want the corrected skill description and loop wording; nothing behavioral changed beyond the three phrasings.

---

## [1.2.1] — 2026-07-05

The post-1.2.0 documentation sweep: the repo's own docs and the `example/` fixture caught up with the 1.2.0 payload changes they still contradicted.

### Added

- **`example/artifacts/AGENT_STATE.md`** — a fully populated instance of the 1.2.0 live-state file, showing all 15 agent sections as they stand after Acme Todo's Milestone 1 closed: current work, decision logs (including the architect's five-column ADR variant), the performance budget tracking table with measured values, and the validator's dashboards and milestone progress.

### Changed

- **`example/artifacts/BUGS.md` rewritten to the canonical 1.2.0 schema.** The fixture still used the pre-1.2 format (Open/Fixed sections, `Open / In Progress / Fixed / Won't Fix / Deferred` statuses, ad-hoc frequency values). It now demonstrates the single-list schema: full lifecycle header with the `New → Triaged → In Progress → Fixed → Verified → Closed` status flow, terminal states, split initial/final Severity, the canonical Frequency enum, and the per-stage field-ownership table. BUG-001 is `Closed` with populated Investigation (Debugger) and Resolution (Coder) blocks; BUG-002 is `Deferred`, set by Product at triage with no investigation — matching the corrected defect routing.
- **`example/CLAUDE.md` Memory Imports slimmed to the 1.2.0 always-on set** (PRD + CODE_PATTERNS + the CLI topic doc), with FILE_CONVENTIONS/ERROR_HANDLING moved to the commented on-demand group, mirroring the payload template. The Directory Conventions section now lists `artifacts/AGENT_STATE.md`.
- **`example/README.md` and `example/artifacts/STANDUP.md`** updated to include the new state file in the reading order, directory layout, and related-documents table.
- **Root `README.md` and `CLAUDE.md` synced with the 1.2.0 content changes** (landed on `main` as `75a9276`): Defect/Issue routing corrected to Bug Gatherer → Product (triage) → Debugger with Tester in the Issue loop everywhere the old order appeared; the four 1.2.0 payload files added to the File Listing with corrected counts; Inter-Agent Handoff rewritten around `AGENT_STATE.md` and `PIPELINE_LOOP.md`; Docs Writer trigger updated to batched checkpoints.

### Migration

- None. Documentation and fixture changes only — no payload behavior changed, and existing installs need no action.

---

## [1.2.0] — 2026-07-03

The agent-system optimization release, targeting Opus 4.6/4.7/4.8 effectiveness and per-invocation efficiency. Agent definitions shrink from 3,933 to ~2,500 lines (−36%) and stop growing with project age; the pipeline stops disagreeing with itself about bugs and loops. Sourced from a three-agent deep analysis of how the 15 agents, docs, and templates work together.

### Added

- **`artifacts/AGENT_STATE.md`** — live working state for every agent (Current Work, Decisions Logs, validator's dashboards), one section per agent. Agent definitions are now immutable and cheap to load; they carry a 3-line State pointer instead of mutable tables. `/cast-init` migrates populated tables from pre-1.2 agent files during updates.
- **`docs/PIPELINE_LOOP.md`** — the canonical engineering-loop contract (per-task sequence, Defect/Issue routing, loop-counter rules, test-gate rule, targeted re-runs, pass-forward rule, Environment Issue rule). Both `/agent-code` and `/agent-task` execute this loop and carry only their deltas — the ~65% duplicated loop text is gone and can no longer drift.
- **`templates/CEO_REVIEW.md`** and **`templates/UX_REVIEW.md`** — the CEO checklist (now with all six mandated inputs including the task breakdown) and UI's UX review checklist, promoted out of the agent files; `templates/MILESTONE_VALIDATION.md` absorbed Product's task-validation checklist, feedback log, and regression sections.
- **`(required)` / `(optional)` markers on every template section** (~149 headings across 10 templates) — Opus 4.7 thins unmarked sections; the gates now have an explicit contract to check.

### Changed

- **Bug lifecycle unified on a single `artifacts/BUGS.md` schema**: one entry format, canonical status flow (New → Triaged → In Progress → Fixed → Verified → Closed, plus terminal states), one severity scale (Critical/High/Medium/Low), one frequency enum, explicit field ownership per stage — Coder now owns the resolution fields (Commit, Files Changed, Regression Notes) that previously had no owner; Tester owns the Regression Checklist. bug-gatherer and debugger reference the schema instead of restating divergent copies.
- **Defect routing corrected in `/agent-code`**: Bug Gatherer files (New) → Product triages → Debugger investigates — the skill previously ran Debugger before a report existed and before triage, inverting the documented lifecycle.
- **Loop control unified**: everything counts against `[MAX_LOOP_COUNT]` (refactor's private 3-iteration counter is gone), counts persist to `artifacts/STANDUP.md` across interruptions, Refactor↔Reviewer rounds increment the same counter, and the Tester-first re-run rule is encoded in reviewer.md and refactor.md, not just the skills.
- **Planning handoff contracts fixed**: Performance's inputs now include the UI spec and milestone definition (it is told to read both but its contract omitted them); Security's inputs include the milestone definition; UI now receives the task breakdown (where the `Needs UI Spec` flags live); the `docs/` vs `templates/` template-path contradiction in product/architect/ui is fixed.
- **Orphaned inline template systems deleted** from architect.md (−433 lines) and ui.md (−268): they duplicated and contradicted the canonical `templates/` files — ui.md's copy omitted the Pressed/Disabled states the CEO gate grades, so an agent following its own file failed the pipeline's own review.
- **Model Configuration collapsed in all 15 agents** to an effort line + the three role-specific per-model bullets; the model ladder and rules live only in `docs/MODEL_OPTIMIZATION.md` (a model change no longer touches 16 files). The `xhigh`-requires-4.7+ caveat now appears wherever `xhigh` is recommended.
- **Per-model guards propagated**: the 4.6 anti-delegation guard ("do not spawn subagents") in every agent; the 4.6 structured-output guard in the four review agents; the 4.8 terse-handoff directive ("no narrative recap") everywhere.
- **docs-writer batched to checkpoints**: runs at task completion and milestone completion, draining a `docs:` queue in STANDUP.md — previously "after any other agent completes work," the roster's least cost-justified trigger.
- **Session-start imports slimmed**: always-on = PRD + CODE_PATTERNS + topic doc; the navigation indexes and FILE_CONVENTIONS/ERROR_HANDLING move to a commented on-demand group (agents read them by path). TEST_FRAMEWORK and ERROR_HANDLING are now actually cited by tester and reviewer — previously referenced by zero agents.
- **Efficiency rules in the loop**: targeted test re-runs inside Defect/Issue cycles (full suite still gates validation and completion); orchestrators pass artifact content forward instead of each stage re-reading the same files.
- **Template slots de-duplicated**: milestone arch/UI linkage stated once; the performance-budget table lives in two places instead of four; "Product Approval" signature blocks replaced by CEO-verdict pointers; CEO Approval Conditions get a tracking slot in the task breakdown; ARCH_MODULE de-Reacted (framework-neutral state/integration wording).
- **Validator staleness thresholds ship as defaults** (14/7/3 days) instead of nowhere-defined placeholders.

### Migration

- Existing installs: re-run `/cast-init`. It installs AGENT_STATE.md and PIPELINE_LOOP.md, migrates any populated state tables out of your pre-1.2 agent files, and updates the slimmed agents and skills while preserving your custom sections. Bug entries in an existing BUGS.md keep their data; map `Open → New`, `Major/Minor/Cosmetic → High/Medium/Low` when convenient.
- If you customized the deleted inline templates in architect.md/ui.md, port those customizations to the canonical `templates/ARCH_*.md` / `templates/UI_SPEC.md` files.

## [1.1.0] — 2026-07-03

The adoption-workflow batch from the post-1.0 review: fewer surviving placeholders, a much faster Phase 5, and specified behavior for unattended runs, interrupted runs, and repeat runs.

### Added

- **Expanded discovery** (`references/discovery.md`): Phase 1 now also collects framework version, test runner, package manifest, dependency-add command, type-checker/framework/bundler config files, persistence layer, state/navigation libraries, target platforms, source-directory role mapping (screens/logic/store/components/hooks/constants/assets), naming conventions, and source-file extension — each mapped to its placeholder. Domain tokens (`[DOMAIN_ENTITY]`, `[SAVE_KEY]`, …) are explicitly asked in the Phase 3 plan, never guessed. The Phase 5 substitution list covers all of it.
- **Phase 5 fast path** (`references/execution.md` §5.1a): pure-Create actions are bulk-copied with shell, then one substitution pass + one scaffolding-strip pass — the per-file read-merge-write loop is reserved for actions that preserve customizations. Safety rule 7 reworded to its actual intent: never *execute* the target project's code (shell for the adoption's own mechanics is fine).
- **Unattended mode** (SKILL.md): non-interactive runs are valid only with explicit pre-approval plus pre-supplied answers; auto-approved decisions are recorded in the report; Delete actions are never exercised unattended. Without pre-approval, non-interactive runs behave as dry runs.
- **Resume support**: preflight recognizes an interrupted adoption (dirty files matching the prior `adoption-plan.md`) and a leftover `.cast-stage/` from a permission-blocked run, and offers to resume/complete instead of demanding a stash.
- **Version-aware re-runs** (SKILL.md): if the installed CAST version equals the skill's `metadata.version`, report and stop; if the install is newer than the skill, warn that the local cast-init copy is stale.
- **Per-use placeholder whitelist** (`references/validation.md`): the Phase 6 placeholder scan now has a definitive list of deliberate sub-template tokens instead of judgment calls.
- **CI enforcement** (`.github/workflows/validate.yml`): version sync across the four locations, SKILL.md <500-line cap, skill frontmatter name==directory, agent-frontmatter-vs-roster drift, payload/example pre-1.0-reference scan, and manifest JSON validity.
- **"Keeping CAST up to date"** section in the README and a FIRST_RUN note covering `skills-lock.json` (commit it) and the default symlink install (`--copy` to avoid).
- **TROUBLESHOOTING entries**: "installed files still contain `[PLACEHOLDER]` tokens" and "re-run stops on a dirty tree after an interruption."

### Changed

- **Payload defaults instead of dead tokens**: `tester.md` ships 80% line/branch coverage defaults; `performance.md` and `architect.md` performance-budget tables ship concrete default targets (2s startup, 16ms tick/render, 200MB memory, 50MB storage) marked "tune per project"; `coder.md`/`product.md` checklists say "each target platform (`[TARGET_PLATFORMS]`)" instead of `[PLATFORM_1]`/`[PLATFORM_2]`; `bug-gatherer.md`'s platform example uses `[TARGET_PLATFORMS]`. All of these previously survived installs as bare tokens whose only explanation was in the stripped comment block.

### Migration

- Existing installs: optional. Re-running `/cast-init` picks up the improved substitutions and the defaulted checklists/tables; your customized values are preserved by the merge rules. No paths change.

## [1.0.2] — 2026-07-03

Consistency batch from the post-1.0 review sweep. No pipeline or agent behavior changes — this release corrects stale wording that predated the v0.10.0 `templates/` split and the v1.0.0 commands→skills conversion, closes two specification gaps, and adds two Phase 6 validation checks.

### Fixed

- **`artifacts/README.md`** (installed): "templates live in `docs/`" corrected to `templates/`; the milestone-definition row now cites `templates/MILESTONE_DEFINITION.md` (was `MILESTONE_TASKS.md`, same fix in `agents/README.md`); the "do not create empty subdirectories" line now acknowledges `/cast-init` pre-creates the four scaffold subdirectories; the two-way split rule updated to the three-way docs/templates/artifacts split.
- **`agents/README.md`**: tier scheme aligned with the authoritative roster — Release and Validator are now Tier 5, installed by default unless opted out (previously labeled "Opt" with keep-if language); stale `[FEATURE_AREA_*]`/`[ARTIFACT_TYPE_*]` customize bullets removed; "Minimum Viable Agent Set" cross-reference now links to the repo README explicitly.
- **Terminology stragglers**: "command" → "skill"/"pipeline" in `agent-task/SKILL.md` (installed), `agents/README.md`, `skills/README.md`, and `example/README.md`; `example/CLAUDE.md` Directory Conventions updated to the three-way split.
- **SKILL.md ↔ validation.md drift**: the Phase 6 summary now scopes the pipeline-skill check to the set the user chose to keep, matching `references/validation.md`.

### Added

- **`templates/README.md` disposition** (previously unspecified): always installs, as documentation — with placeholder substitution and scaffolding strip — unlike the eight skeletons, which continue to install verbatim.
- **Phase 6 validation checks**: mobile projects must have both `docs/FRONTEND.md` and `docs/MOBILE.md`; the installed `CLAUDE.md` Memory Imports must match the docs actually installed.
- **Install-date substitution**: `[YYYY-MM-DD]` "Last updated" tokens in installed README files are replaced with the install date.
- **`docs/PRD.md` semantics stated explicitly** in both the disposition table and the repo README: the skeleton is never auto-installed; `/cast-init` prompts, because a PRD is user content.

### Migration

- Existing installs: no action required. Re-running `/cast-init` refreshes the corrected `artifacts/README.md`, `agents/README.md`, and `agent-task` skill wording, and installs `templates/README.md` if missing.

## [1.0.1] — 2026-07-03

Codifies the fallback behavior for permission-blocked writes during adoption. Previously, if a session could not get approval to write under `.claude/` (non-interactive or restricted-permission sessions), the outcome was unspecified. Interactive adoption is unchanged — you approve the write prompts and nothing is staged.

### Added

- **Staging fallback in `references/execution.md`** — when a target path is permission-blocked, `/cast-init` builds the affected files completely (substitution, scaffolding strip, customization merges), writes them to `.cast-stage/` mirroring the final layout, runs Phase 6 validation against the staged copies, and ends the report with the exact move command(s) that complete the install. Partially-staged adoptions must always be reported.
- **`TROUBLESHOOTING.md` entry** — "`/cast-init` finished but says files are staged in `.cast-stage/`" with the finish-up steps.

### Migration

- No installed-project changes. Re-running `/cast-init` is only needed if a prior run silently skipped `.claude/` files in a restricted session — re-run it and follow the staging instructions.

## [1.0.0] — 2026-07-03

CAST is now a skill. Adoption moves from "clone the repo and follow `PROMPT.md`" to installing the `/cast-init` skill — either `npx skills add Raxvis/CAST` or the Claude Code plugin marketplace (`/plugin marketplace add Raxvis/CAST` + `/plugin install cast@cast`) — and running `/cast-init` inside the target project. Installed projects keep the same shape except that the three pipeline commands are now pipeline **skills** under `.claude/skills/`.

### Added

- **`skills/cast-init/`** — the adoption skill. `SKILL.md` carries the seven-phase workflow (discovery → classification → migration plan → approval gate → execution → validation → report) that `PROMPT.md` used to define; the detail moved to five progressive-disclosure reference files: `references/discovery.md` (Phase 1 checklists + inventory template), `references/roster.md` (canonical 15-agent roster, tiers, alias tables, pipeline-skills mapping), `references/dispositions.md` (docs/templates/artifacts/root disposition tables + plan format), `references/execution.md` (Phase 5 install mechanics + customization-preservation rules), and `references/validation.md` (Phase 6 checklist + Phase 7 report template).
- **`.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`** — the plugin install route. The plugin exposes exactly one component: the cast-init skill.
- **Pre-converted pipeline skills in the payload** — `assets/skills/{agent-plan,agent-code,agent-task}/SKILL.md` with YAML frontmatter (`name`, `description`), replacing the frontmatter-less command files.
- **`LICENSE`** — MIT, referenced from `plugin.json` and the SKILL.md frontmatter.

### Changed

- **The entire template payload moved under `skills/cast-init/assets/`** (`agents/`, `docs/`, `templates/`, `artifacts/`, `root/`, and the former `commands/` as `skills/`) via `git mv`, so the whole payload travels inside the skill directory on install. `example/` stays at the repo root and is never installed.
- **Target install path for the three pipelines changed** from `.claude/commands/<name>.md` to `.claude/skills/<name>/SKILL.md`. `/cast-init` detects pre-1.0 command files, migrates preserved customizations into the new skills, and proposes deleting the old files.
- **Fixed stale "Templates are read from `docs/`" wording** in all three pipeline definitions (stale since the 0.10.0 `templates/` split) and corrected their related-agent links for the new install depth (`../../agents/`).
- **`$ARGUMENTS` command interpolation removed** from the pipeline definitions — skills receive the invocation text as input; each pipeline now has an `## Input` section and asks when no input was provided.
- **`<!-- TEMPLATE INSTRUCTIONS -->` blocks are stripped at install.** These blocks date to the original manual-adoption era; they remain in the repo as per-file documentation, but `/cast-init` now removes them (and the dangling `<!-- Placeholders — see README.md ... -->` pointer comments) from every file it installs. Exception: the eight `templates/*` skeletons install verbatim — their blocks instruct the agents that instantiate them. Phase 6 validation checks that no installed file outside `templates/` carries a block.
- **`/cast-init` no longer creates target-root `TROUBLESHOOTING.md` / `CHANGELOG.md`.** The old `PROMPT.md` claimed to "create from CAST template" but no such root templates ever existed; installed docs now link to the repo's `TROUBLESHOOTING.md` on GitHub, and `root/CLAUDE.md` is the only file installed at the target root.
- **Release policy: the synchronized version locations are now four** — `README.md`, `CHANGELOG.md`, `.claude-plugin/plugin.json`, and `skills/cast-init/SKILL.md` (`metadata.version`) — replacing the retired `PROMPT.md` header.
- **`README.md`** — Install and Quick Start rewritten around the two install routes + `/cast-init`; directory structure, file listing, prerequisites, and limitations updated for the skill layout; version badge and hero line bumped to v1.0.0.

### Removed

- **`PROMPT.md`** — `/cast-init` is the only adoption path. Its content lives on in `skills/cast-init/SKILL.md` and `references/` (moved with history via `git mv`).
- **Top-level `agents/`, `commands/`, `docs/`, `templates/`, `artifacts/`, `root/`** — moved (not deleted) under `skills/cast-init/assets/`.

### Migration

- **New adoptions:** `npx skills add Raxvis/CAST` (or the plugin route), restart Claude Code, then run `/cast-init`.
- **Existing CAST projects:** install cast-init and re-run `/cast-init`. It detects pre-1.0 `.claude/commands/agent-*.md` files, merges any customizations into the new `.claude/skills/<name>/SKILL.md` counterparts, and proposes deleting the old command files (approval required — keeping both would register a duplicate `/agent-plan`). No agent, doc, template, or artifact paths change inside target projects.
- **Contributors:** template content now lives under `skills/cast-init/assets/`; edit files there. Version bumps must update all four synchronized locations.

## [0.11.0] — 2026-07-03

Re-targeted the entire agent roster and all three commands at the Claude Opus 4.x family (Opus 4.8 / 4.7 / 4.6), replacing the previous Opus 4.6 / Sonnet 4.6 / Haiku 4.5 model-tier split. Every agent and command now carries model-conditional execution notes, and a new reference doc defines the per-model behavior profiles and upgrade paths.

### Added

- **`docs/MODEL_OPTIMIZATION.md`** — the model policy for the roster: the Opus 4.x ladder (`claude-opus-4-8` default, `claude-opus-4-7` supported, `claude-opus-4-6` minimum), the default roster assignment with recommended reasoning effort per agent, per-model behavior profiles (4.8 narrates and asks more but under-delegates without explicit triggers; 4.7 is the most literal and terse; 4.6 overtriggers on aggressive wording and over-delegates), the 4.6 → 4.7, 4.7 → 4.8, and 4.6 → 4.8 upgrade checklists, downgrade/pinning guidance, and a verification procedure. Registered in `docs/README.md`, the root `README.md` docs table, and the `PROMPT.md` docs mapping + disposition tables (Always install).
- **`## Model Configuration` section in all 15 agent files** — a compact per-agent block stating the default model, the recommended reasoning effort (`xhigh` for architect/coder/reviewer/debugger, `high` for the other planning/engineering roles, `low` for the four utility roles), a supported-models table, and three role-specific execution notes — one each for Opus 4.8, 4.7, and 4.6 — so the same agent definition stays calibrated on whichever Opus 4.x model executes it.
- **`## Model Compatibility` section in all three commands** (`/agent-plan`, `/agent-code`, `/agent-task`) — orchestration notes per executing model: Opus 4.8/4.7 delegate conservatively (the explicit stage invocations are load-bearing), Opus 4.6 over-delegates (spawn only the agents each stage names), plus per-stage effort recommendations and, for `/agent-code`, a coverage-first review-recall rule for Opus 4.8/4.7. Summarized in `commands/README.md`.

### Changed

- **All 15 agents re-pinned to `claude-opus-4-8`.** The YAML frontmatter `model:` line changed from `inherit` to an explicit `claude-opus-4-8` pin (frontmatter previously contradicted the documented per-tier pinning), and each body `**Model**:` line now names `claude-opus-4-8`. Workload differentiation moved from model tier to recommended reasoning effort — all three Opus 4.x models are priced identically, so the old cost-tiering no longer applies. `claude-haiku-4-5` remains a documented downgrade pin for the four utility agents.
- **`PROMPT.md` roster table** now pins every agent to `claude-opus-4-8` and gains an Effort column; the Phase 6 frontmatter validation accepts `claude-opus-4-8` / `claude-opus-4-7` / `claude-opus-4-6` (or an approved override); version header bumped to v0.11.0.
- **`README.md`** — model paragraph, prerequisites, docs file table (now 20 files), badge, and hero line updated to the Opus 4.x policy and v0.11.0.
- **`agents/README.md`** — template instructions and the model overview paragraph now describe the Opus 4.x pinning and effort-based differentiation.
- **`docs/FIRST_RUN.md`** — the per-agent model-access caveat now names `claude-opus-4-8` with 4.7/4.6 as the supported fallbacks.
- **`example/artifacts/`** — the five stale `claude-sonnet-4-6` author-model references in the worked example updated to `claude-opus-4-8`.

### Migration

- Existing installs: in each `.claude/agents/*.md`, change the frontmatter `model:` line to `claude-opus-4-8` (or `claude-opus-4-7` / `claude-opus-4-6` if that is what your account serves), then copy the new `## Model Configuration` sections from the CAST agents and the `## Model Compatibility` sections from the CAST commands, and install `docs/MODEL_OPTIMIZATION.md`. Re-running `PROMPT.md` against an existing install applies all of this automatically.
- If you previously relied on the Haiku pins for the utility agents (bug-gatherer, docs-writer, release, validator) for cost or latency, re-pin them to `claude-haiku-4-5` — the roles remain compatible; only the optimized default changed.
- No directory structure, command stage, or artifact path changed in this release.

## [0.10.0] — 2026-05-24

Reorganized document templates into a dedicated top-level `templates/` directory, turning the previous two-way `docs/` vs `artifacts/` split into a three-way `docs/` / `templates/` / `artifacts/` split.

### Added

- **`templates/` directory** — the eight reusable document templates now live here instead of `docs/`: `ARCH_MODULE.md`, `ARCH_SYSTEM.md`, `ARCH_DATA_SCHEMA.md`, `UI_SPEC.md`, `MILESTONE_DEFINITION.md`, `MILESTONE_TASKS.md`, `MILESTONE_COMPLETION.md`, `MILESTONE_VALIDATION.md`.
- **`templates/README.md`** — index for the new directory listing each template, the agent that produces it, the command stage it is used in, and its `artifacts/` instance destination.

### Changed

- **Three-way split is now the canonical rule.** `docs/` holds reference material, `templates/` holds reusable document skeletons, and `artifacts/` holds work instances. Updated the split definition in `CLAUDE.md`, `root/CLAUDE.md`, `docs/FILE_CONVENTIONS.md`, `docs/README.md`, `agents/README.md`, and the root `README.md`.
- **All template path references updated** from `docs/<TEMPLATE>.md` to `templates/<TEMPLATE>.md` across `agents/architect.md`, `agents/product.md`, `agents/ui.md`, `agents/README.md`, `commands/agent-plan.md`, `commands/agent-code.md`, `docs/CODE_PATTERNS.md`, `docs/FRONTEND.md`, `docs/MOBILE.md`, `docs/FIRST_RUN.md`, `artifacts/README.md`, and `artifacts/STANDUP.md`.
- **`PROMPT.md` adoption flow** — the docs/templates mapping table now lists the `templates/*` rows with their new install location, and step 5.6 reads templates from `<CAST_SOURCE>/templates/` and writes them to the project's top-level `templates/` directory.

### Fixed

- **`templates/MILESTONE_COMPLETION.md`** pointed its instance and cross-reference paths at `docs/milestones/` — a split violation, since milestones are work artifacts. Corrected to `artifacts/milestones/milestone-{N}-{slug}-{completion,tasks,validation}.md`.

### Migration

- Projects that already adopted CAST should move the eight template files from `docs/` into a new top-level `templates/` directory; no agent or command behavior changes beyond the template lookup path. Re-running `PROMPT.md` against an existing install creates `templates/` and relocates the templates automatically.

## [0.9.0] — 2026-05-23

Template cleanup: removed install scripts and settings example, fixed documentation inconsistencies, and corrected stale cross-references.

### Removed

- **`scripts/` directory deleted** — `install.sh`, `install.ps1`, `bootstrap.sh`, `check-placeholders.sh`, and `smoke-test.sh` removed. The adoption prompt (`PROMPT.md`) is now the sole installation method.
- **`root/.claude/settings.json.example` deleted** — `docs/CLAUDE_CODE_SETTINGS.md` provides the same guidance inline without requiring users to rename a file.

### Changed

- **Template version bumped to 0.9.0** in `README.md` (badge and hero line), `PROMPT.md` (version header and roster table), and `CHANGELOG.md`.
- **`README.md` docs file count corrected** from "20 files" to "27 files" in the File Listing section.
- **`README.md` topic-doc count corrected** from "three categories" to "four categories" — stale since v0.8.0 added `docs/MOBILE.md`.
- **`README.md` `root/` description updated** to reflect that only `CLAUDE.md` remains after the settings example deletion.
- **`README.md` `agents/` File Listing section** now notes that `agents/README.md` should not be copied to target projects, matching the existing note on `commands/README.md`.
- **`CLAUDE.md` `root/` directory description updated** — removed "config templates" since only the `CLAUDE.md` template remains.
- **`docs/README.md` gained a "Setup and Configuration" section** listing `FIRST_RUN.md` and `CLAUDE_CODE_SETTINGS.md`, which were previously absent from the documentation index.
- **`docs/FIRST_RUN.md` and `docs/CLAUDE_CODE_SETTINGS.md`** — references to `TROUBLESHOOTING.md` clarified as "the CAST template's `TROUBLESHOOTING.md`" since the file lives at the template repo root and is not copied to target projects.
- **`docs/DESIGN_RATIONALE.md`** — added a scope clarification explaining the relationship between this project-wide decision log and the Architect agent's inline Decisions Log.
- **`example/README.md`** — fixed broken artifact paths (`01-task-crud/MILESTONE.md` → `milestones/milestone-1-task-crud.md`, `01-task-crud/CEO_REVIEW.md` → `reviews/ceo-review-milestone-1.md`) and replaced hardcoded absolute paths (`/Users/raxvis/work/claude/`) with generic references.
- **All 8 example planning artifacts** gained `## Revision History` sections as required by `commands/agent-plan.md` and `docs/FILE_CONVENTIONS.md`.
- **`example/CLAUDE.md`** — added `@import docs/CLI.md` to Memory Imports since the example project is a CLI tool.

### Added

- **`.gitignore`** — minimal ignore file for OS files (`.DS_Store`, `Thumbs.db`) and editor directories (`.vscode/`, `.idea/`).

### Migration from 0.8.1

If your project has copies of `scripts/install.sh`, `scripts/install.ps1`, `scripts/bootstrap.sh`, `scripts/check-placeholders.sh`, `scripts/smoke-test.sh`, or `root/.claude/settings.json.example` from a prior adoption, you can safely delete them — they are no longer part of the template. The adoption prompt (`PROMPT.md`) and `docs/CLAUDE_CODE_SETTINGS.md` cover the same ground.

---

## [0.8.1] — 2026-04-12

PROMPT.md reliability fixes. No template content changes — this release is entirely about making the adoption prompt produce complete, accurate 15-agent installs when migrating existing projects.

### Changed

- **`PROMPT.md` gained a Canonical CAST Agent Roster table** listing all 15 agents with the exact name, tier assignment, pinned model, and role description pulled verbatim from each agent file's YAML frontmatter. This is now the single source of truth the adoption prompt consults when matching existing project agents against CAST roles. Existing logic that enumerated agent names inline (Phase 3 final check, Phase 5.4 install order, Phase 6 verification) now references the table by name instead of repeating the list, so future roster changes only have to happen in one place.
- **`PROMPT.md` Phase 1–6 role-matching now compares by description, not filename.** When the Phase 1 inventory finds an agent file under a non-CAST name, Claude is instructed to read its purpose and match against the Role column of the roster table — the filename is a hint but the description is the tiebreaker. This fixes a failure mode where existing `planner.md`, `coordinator.md`, or `shipper.md` files got mapped to the wrong CAST role (or no role at all) because the prompt only walked by name.
- **`PROMPT.md` Phase 6 validation now also checks description fidelity.** After confirming each `.claude/agents/<name>.md` file exists, the validation step reads the `description:` field from its YAML frontmatter and confirms it matches (or is a reasonable project-specific adaptation of) the canonical Role column. A file with the name `ceo.md` but the description "writes marketing copy" is flagged as impersonating a CAST agent name without fulfilling the CAST role.
- **`PROMPT.md` gained a version header** at the top (`Template version targeted: v0.8.1`) and a self-version-check instruction: before executing, fetch `https://raw.githubusercontent.com/Raxvis/CAST/main/README.md` and compare the canonical template version against the version stamped at the top of the prompt. If the canonical version is newer, Claude tells the user so they can decide whether to re-run from an updated prompt.
- **`README.md` template version** bumped to 0.8.1 in the badge and hero line.
- **`scripts/install.sh` and `scripts/install.ps1`** `TEMPLATE_VERSION` bumped to 0.8.1.

### Migration from 0.8.0

Purely additive. An existing 0.8.0 install needs no changes — the template content is unchanged. The bump is for users who want the improved adoption prompt when migrating new projects. Re-download `PROMPT.md` from the canonical repo if you plan to run another adoption.

---

## [0.8.0] — 2026-04-12

Adds a fourth topic-specific reference doc for mobile projects and wires it into every place that enumerates the topic-doc set.

### Added

- **`docs/MOBILE.md`** — native and cross-platform mobile reference covering the mobile-specific delta on top of `docs/FRONTEND.md`: app lifecycle and background transitions, OS permission prompts (lazy asking, denial handling, foreground re-check), native bridges and platform APIs, offline-first writes and sync reconciliation, the three local-storage tiers (secure storage, key-value, structured DB, file system), deep links / Universal Links / App Links, push notifications and background fetch, build variants (debug/staging/release with per-variant bundle IDs and signing), device and screen variety (foldables, tablets, safe-area insets, font scaling), release engineering (phased rollouts, OTA updates, privacy manifests, crash reporting), on-device performance budgets, and 9 mobile-specific common pitfalls. Targets React Native, Expo, Flutter, SwiftUI, Jetpack Compose, .NET MAUI, and native Swift / Kotlin projects. Roughly 300 lines.

### Changed

- **Topic-doc set expanded from three to four.** Every place that enumerates the topic docs now lists FRONTEND, BACKEND, CLI, and MOBILE. Mobile projects are explicitly instructed to import **both** `docs/FRONTEND.md` and `docs/MOBILE.md` — the first covers the shared UI patterns (navigation, components, state, performance) and the second covers mobile-only concerns on top.
- **`root/CLAUDE.md` Memory Imports block** gained `@import docs/MOBILE.md` alongside the existing three topic imports.
- **`root/CLAUDE.md` Common Pitfalls section** now references MOBILE.md for mobile-specific pitfalls (app-lifecycle state loss).
- **`README.md`** top hero, topic-docs subsection, and file listing table all expanded to mention MOBILE.md and the recommendation to pair it with FRONTEND.md for mobile projects.
- **`docs/README.md`** Topic-Specific Technical Documents section now lists four files instead of three, with an explicit note that mobile apps should keep both FRONTEND and MOBILE.
- **`commands/agent-task.md`** pre-flight reading list includes MOBILE.md.
- **`PROMPT.md` (CAST adoption prompt)** updates across three sections:
  - Phase 1 documentation scanner now maps existing "mobile patterns" references to `docs/MOBILE.md`.
  - Phase 1 project-type detection classifies Mobile explicitly and notes that mobile projects also require `docs/FRONTEND.md`. Native Swift, native Kotlin, React Native, Expo, Flutter, SwiftUI, Jetpack Compose, .NET MAUI, Ionic/Capacitor, and `ios/`/`android/` directories are listed as mobile signals.
  - Phase 3 docs-mapping table includes a MOBILE.md row.
  - Example Ask question for a React Native project recommends installing both FRONTEND and MOBILE as a pair.
  - Phase 5.9 CLAUDE.md install step updated to reference the full four-doc set.
  - Decision rubric "ask before acting" bullet updated to include MOBILE.

### Migration from 0.7.0

Purely additive. An existing 0.7.0 project that does nothing still works on 0.8.0. Mobile projects that want the new reference doc should:

1. Copy `docs/MOBILE.md` from the canonical repo into their project's `docs/` directory.
2. Add `@import docs/MOBILE.md` to the Memory Imports block in `CLAUDE.md`, alongside the existing `@import docs/FRONTEND.md`.
3. Optionally populate the placeholders in `docs/MOBILE.md` for their specific framework, minimum OS versions, crash reporter, and bundle IDs.

---

## [0.7.0] — 2026-04-11

One-line curl-pipe-bash install.

### Added

- **`scripts/bootstrap.sh`** — a minimal self-contained installer designed to be executed via `curl -fsSL <url> | bash`. Clones the template repo into a temp directory, hands off to `scripts/install.sh` with any forwarded arguments (`--values`, `--full`, `--force`), and cleans up the clone on exit. Supports installing into the current directory (default) or a specified path. Honors `TEMPLATE_REPO_URL` and `TEMPLATE_REPO_BRANCH` environment variables for forks. Detects headless environments (no `/dev/tty`) and fails fast with a clear message if `--values` was not passed.
- **"Install in one line" section at the very top of `README.md`** showing the canonical curl-pipe-bash command and four variants (specific directory, non-interactive values file, `--full` prompts, `--force` overwrite). Positioned above "What Is This?" so new users can copy-paste and get started before reading anything else. Also notes Windows users should clone and run `install.ps1` directly, and recommends inspecting the script with `curl ... | less` before piping to bash.

### Changed

- **`README.md` Quick Start → "Fast path: install script"** now references the bootstrap curl-pipe-bash one-liner as the primary entry point, with `scripts/install.sh` and `scripts/install.ps1` as the cloned-repo variants. All three entry points share the same `template.values` output format and CLI surface.
- **Canonical repo URL** set to `https://github.com/Raxvis/CAST.git` on the `main` branch.

### Migration from 0.6.0

Purely additive. The bootstrap script is an alternative entry point; existing `install.sh` and `install.ps1` usage is unchanged.

---

## [0.6.0] — 2026-04-11

Clears the remaining open improvements from the setup audit. Adds verification tooling, settings documentation, per-file placeholder pointers, inline links from commands to agents, a per-agent smoke-probe rubric, a revision-history policy for planning artifacts, and a milestone-definition template split. The `IMPROVEMENTS.md` tracking file was removed at the end of this release since every item was resolved. No breaking changes.

### Added

- **`scripts/smoke-test.sh`** — static verification script. Runs 22+ checks on a target project covering layout, agent YAML frontmatter (`name`/`description`/`model`), slash commands, artifacts scaffold, template metadata, path hygiene, and placeholder status. PASS/FAIL/WARN output; exit 0 if clean or only warnings, exit 1 on failure. Copied into target projects by the installers.
- **`docs/FIRST_RUN.md`** — interactive checklist covering everything the static smoke test cannot: open Claude Code, run `/agents`, tab-complete the slash commands, dry-run `/agent-plan`, optional dry-run `/agent-task`, clean up. Includes an Appendix with 15 per-agent smoke probes (one per agent) so users can verify individual role definitions are loading correctly, grouped by tier.
- **`docs/CLAUDE_CODE_SETTINGS.md`** (~170 lines) — reference for `.claude/settings.json`. Explains permission rules, environment variables, hooks (at a pointer level), common extensions (auto-approving test/build commands, deny lists), and what NOT to configure here (secrets, user preferences, agent definitions).
- **`root/.claude/settings.json.example`** — minimal safe starting point that auto-approves 7 read-only shell commands (`ls`, `pwd`, `git status`, `git diff`, `git log`, `git show`, `cat`). Users rename the `.example` suffix off to activate. Install script copies into `<target>/.claude/settings.json.example`.
- **`commands/README.md`** — in-directory index for `commands/`. Explains how slash commands work in Claude Code, how filenames map to command names, the install destination, and a table of all three commands with one-line purposes. Not copied to target projects (Claude Code would register it as a `/README` slash command).
- **`docs/MILESTONE_DEFINITION.md`** — new template for the milestone definition file. Captures what the milestone is and why it matters (Goal, Why This Matters, Success Metrics, In Scope, Out of Scope, Top-Level Acceptance Criteria, Dependencies and Risks, Cross-Cutting Concerns, References). Split from `MILESTONE_TASKS.md` so each file has a single focused audience.
- **Per-agent smoke probes appendix** in `docs/FIRST_RUN.md` — 15 concrete one-line probes (one per agent) with expected outputs, organized by tier. Designed to fail if the agent file is not being loaded correctly so a passing probe is meaningful signal.
- **Revision History policy** for planning-stage artifacts. Every file under `artifacts/milestones/`, `artifacts/architecture/`, `artifacts/ui-specs/`, and `artifacts/reviews/` now carries a `## Revision History` table at the top. First write includes a `v1` row; revisions prepend new rows with date, agent, and reason. Documented in `commands/agent-plan.md`, `agents/ceo.md`, and `docs/FILE_CONVENTIONS.md`.
- **"Related agent files" sections** at the top of all three command files (`commands/agent-plan.md`, `agent-code.md`, `agent-task.md`). Each section lists the agents the command invokes with relative Markdown links to their files and a one-liner describing their role in that specific pipeline.
- **Placeholder pointer comments** — a one-line HTML comment (`<!-- Placeholders — see README.md → Placeholder Reference -->`) at the top of every template file that contains `[UPPER_SNAKE_CASE]` tokens. 41 files across `agents/`, `commands/`, `docs/`, and `root/CLAUDE.md`. Invisible in rendered Markdown; signposts the placeholder reference when editing the file in a source view.
- **Tier column in the Agent Roster table** (`agents/README.md`) showing which Minimum Viable Agent Set tier each agent belongs to (T1/T2/T3/T4/Opt), with a short leader paragraph explaining the tiers.

### Changed

- **`root/CLAUDE.md` is now fully agnostic** (from 0.5.0's partial split). All frontend-only content (UI component patterns, navigation, state management, performance budgets, input handling, safe areas) was moved into the new `docs/FRONTEND.md`, `docs/BACKEND.md`, and `docs/CLI.md` topic docs. The shipped `root/CLAUDE.md` has commented `@import` lines for all three; users uncomment the one(s) matching their project type. Common Pitfalls section rewritten to cover only universal traps.
- **Agent description field consistency.** All 15 agent descriptions now fit in 75–114 characters (a 39-char spread, down from 105) and follow the same `<Role> agent. Use for X, Y, and Z.` format. `ceo` (174→114 chars) and `product` (128→106 chars) were the only two that needed rewriting; the rest already fit.
- **Minimum Viable Agent Set reorganized into four tiers** in `README.md` so users can prune the roster based on which slash commands they keep: Tier 1 always, Tier 2 strongly recommended, Tier 3 required for `/agent-task`, Tier 4 required for `/agent-plan` + `/agent-code`.
- **Install scripts exclude `README.md`** when copying `agents/*.md` and `commands/*.md` into target projects. Previously, `agents/README.md` and `commands/README.md` were copied into `.claude/agents/` and `.claude/commands/` respectively; Claude Code would potentially register `commands/README.md` as a `/README` slash command. Both installers now skip any `README.md` in those directories.
- **`commands/agent-plan.md` Stage 1** now references both `docs/MILESTONE_DEFINITION.md` and `docs/MILESTONE_TASKS.md` explicitly and explains why the two files are separate.
- **Install script completion output** now points at `scripts/smoke-test.sh` and `docs/FIRST_RUN.md` as the next steps after install, replacing the old "open Claude Code and run /agents" one-liner.

### Migration from 0.5.0

Purely additive. A 0.5.0 project can pull any of the new files individually without breaking anything.

---

## [0.5.0] — 2026-04-11

Pins each agent to a specific Claude model tier based on its workload. Removes the `[AI_MODEL]` placeholder entirely.

### Changed

- **Per-agent models are now hard-coded in YAML frontmatter.** Each of the 15 agent files has a `model:` key chosen to match the agent's workload:
  - **Planning tier → `claude-opus-4-6`** (Product, Architect, UI, Security, Performance, CEO)
  - **Engineering tier → `claude-sonnet-4-6`** (Coder, Tester, Reviewer, Debugger, Refactor)
  - **Utility tier → `claude-haiku-4-5-20251001`** (Bug Gatherer, Docs Writer, Release, Validator)

  Planning agents do cross-document reasoning and judgment calls that justify Opus. Engineering agents do bounded code-centric work where Sonnet's speed and cost win. Utility agents do structured writing against templates where Haiku is sufficient. Users who want to override can edit the `model:` line in an individual agent file.

- **`[AI_MODEL]` placeholder removed.** `scripts/install.sh` and `scripts/install.ps1` dropped it from their Essentials prompt lists. The installer no longer asks for a model. Consistent with "the toolkit makes best-case judgments" rather than deferring model selection to users.

- **Documentation updated** across `README.md` → Placeholder Reference → Agents (replaced with tier explanation), `CLAUDE.md` → Placeholder Categories, `agents/README.md` → HOW TO CUSTOMIZE and "All agents run on" line, and `scripts/check-placeholders.sh` example comment.

### Migration from 0.4.0

1. In your existing project, find every `[AI_MODEL]` reference and replace it with the appropriate model for that file:
   ```
   grep -rn '\[AI_MODEL\]' .claude/agents/
   ```
   Or copy the updated agent files from this template over your existing ones if you have not customized them.
2. If your existing installer answers had an `AI_MODEL` entry in `template.values`, delete the line. It is ignored by 0.5.0.
3. Optional: review each agent's `model:` pin. Override if your account does not have access to Opus 4.6 — you can use Sonnet 4.6 for all planning agents without breaking anything, though the quality of cross-document reviews will be lower.

---

## [0.4.0] — 2026-04-11

Adds the `/agent-task` slash command for one-off work that does not justify a full planning stage. Reorganizes the Minimum Viable Agent Set into four tiers so users can prune the agent roster to match the commands they keep. Splits frontend-only content out of `root/CLAUDE.md` into three opt-in topic docs.

### Added

- **`commands/agent-task.md`** — a third slash command that runs a mini engineering pipeline (Coder → Tester → Reviewer → Product) for a single one-off task without requiring a milestone, planning artifacts, or a CEO verdict. Same Defect → Debugger → Bug Gatherer → Product and Issue → Refactor → Reviewer routing as `/agent-code`. Explicitly bounded to self-contained changes; bails out with a "run `/agent-plan` first" message if the Pre-Flight or Reviewer step detects that the task crosses the scope boundary (new module, schema change, endpoint, cross-cutting refactor).
- **`docs/FRONTEND.md`** (241 lines) — topic-specific reference for user-facing visual interfaces. Covers navigation, state management, UI components, performance budgets, input handling, and platform differences.
- **`docs/BACKEND.md`** (285 lines) — topic-specific reference for API servers, message workers, scheduled jobs, and data pipelines. Covers request/response boundaries, persistence, HTTP status semantics, authentication, middleware ordering, observability, and background work.
- **`docs/CLI.md`** (276 lines) — topic-specific reference for command-line tools. Covers argv parsing, stdin/stdout/stderr discipline, exit codes, terminal output formatting, cross-platform concerns, and signal handling.
- **`example/`** — a 15-file fixture based on "Acme Todo" showing what a populated instance of the template looks like after `/agent-plan` and `/agent-code` have run for Milestone 1. Includes a populated `CLAUDE.md`, PRD/CONCEPT/GLOSSARY, a full planning run (milestone definition, task breakdown, architecture, UI spec, security/performance/CEO reviews), a completion report, a bug tracker with one fixed and one deferred bug, and a three-day session log.
- **`scripts/install.ps1`** — PowerShell twin of `install.sh` for Windows users without WSL. Same CLI surface, same prompt lists, same `template.values` output format. Requires PowerShell 5.1 or PowerShell Core 7. Documented alongside the bash installer in `README.md`.
- **Prerequisites and Known Limitations sections** in `README.md`. Makes the Claude Code dependency explicit and sets expectations that this is a template, not a framework.
- **`TROUBLESHOOTING.md`** entry: "Which command should I use — `/agent-plan`, `/agent-code`, or `/agent-task`?" — a decision table covering 9 common task shapes. Plus a second new entry: "`/agent-task` halted and told me to run `/agent-plan`."

### Changed

- **`root/CLAUDE.md` is now fully agnostic.** All frontend-specific content (UI component pattern, navigation, state management, performance budgets, input handling, safe areas, touch targets) was moved into the three new topic docs. The shipped `CLAUDE.md` has commented `@import` lines for `docs/FRONTEND.md`, `docs/BACKEND.md`, and `docs/CLI.md` — users uncomment the one(s) that match their project type after install. Backend and CLI projects no longer need to delete sections by hand.
- **`root/CLAUDE.md` Common Pitfalls section** rewritten to cover only universal traps (hidden mutable state, silent error swallowing, stringly-typed boundaries, stale configuration, untested error paths). Topic-specific pitfalls moved into the three topic docs.
- **Minimum Viable Agent Set in `README.md` reorganized into four tiers.** Tier 1 (Product/Coder/Reviewer/Tester) is always required. Tier 2 (Architect/Debugger/Docs Writer) is strongly recommended. Tier 3 (Debugger/Refactor/Bug Gatherer) is required if you keep `/agent-task`. Tier 4 (UI/Security/Performance/CEO) is required if you keep `/agent-plan` or `/agent-code`. This makes it explicit that a project can run `/agent-task` without the planning stage agents.
- **`agents/architect.md` Interaction Rules** split the "publish before Coder begins" rule into two sibling bullets covering the two paths: `/agent-plan` → `/agent-code` (Architecture publishes first, enforced by pre-flight) and `/agent-task` (Architecture is skipped for self-contained work; Reviewer catches anything that needs architectural decisions and routes back to `/agent-plan`).
- **`agents/README.md` Workflow** gained a third subsection: "One-Off Task Workflow (`/agent-task`)". The interaction diagram set gained a third ASCII diagram showing the mini pipeline with its scope check at the top.
- **`docs/FILE_CONVENTIONS.md` Core Rule** now says "`/agent-plan`, `/agent-code`, and `/agent-task` all write exclusively under `artifacts/`." The Anti-Patterns list gained a new entry: "Using `/agent-task` for work that needs planning."
- **`TEMPLATE_VERSION` bumped to 0.4.0** in `README.md`, `scripts/install.sh`, and `scripts/install.ps1`. Installs stamped with 0.4.0 in `template.values`.

### Migration from 0.3.0

Purely additive with one exception. The exception:

1. **`root/CLAUDE.md` lost its frontend sections.** If you populated a project from 0.3.0 and kept those sections, you have two options:
   - Treat your existing `CLAUDE.md` as authoritative — keep it as-is, your frontend content still lives there.
   - Adopt the new split — move the frontend sections into `docs/FRONTEND.md` in your project (the template ships a fresh copy you can use as a reference), and add `@import docs/FRONTEND.md` to your `CLAUDE.md` Memory Imports block.

Everything else in 0.4.0 is opt-in. `/agent-task` is a new command, `example/` is new reference material, the PowerShell installer is new, and the Minimum Viable Agent Set reorg is a documentation-only change. A 0.3.0 project that does nothing still works on 0.4.0.

---

## [0.3.0] — 2026-04-11

Major refactor pass. Introduces the two-stage planning/engineering workflow, adds the CEO agent and the slash commands that orchestrate the full pipeline, renames work artifacts out of `docs/`, and ships an install script.

### Added

- **`scripts/install.sh`** — interactive + values-file hybrid installer. Copies all template files into a target project, substitutes placeholders from answers or a `template.values` file, and runs the placeholder check. Bash 3.2 compatible (works on default macOS bash). See `README.md` → Fast path for usage.
- **`scripts/install.ps1`** — functionally equivalent PowerShell twin of `install.sh`. Same CLI surface (positional target, `-Full`, `-Values`, `-Force`, `-Help`), same prompt lists, same `template.values` output with version stamp. Includes an inlined placeholder check so Windows users without WSL get a final report. Requires PowerShell 5.1 or PowerShell Core 7.
- **`scripts/check-placeholders.sh`** — standalone placeholder validation script. Targets `[UPPER_SNAKE_CASE]` tokens only, groups matches by file, exits non-zero so it plugs into CI. Skip list is extensible via command-line arguments.
- **`commands/agent-plan.md`** — slash command that orchestrates the planning stage: Product → Architecture + UI (parallel) → Security + Performance (parallel) → CEO (final sign-off).
- **`commands/agent-code.md`** — slash command that orchestrates the engineering stage: Coder → Tester → Reviewer. Reviewer findings are classified as **Defects** (→ Debugger → Bug Gatherer → Product) or **Issues** (→ Refactor → Reviewer loop).
- **`agents/ceo.md`** — CEO agent. Final reviewer of the planning stage. Integrates Product/Architecture/UI/Security/Performance outputs and issues APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED.
- **`artifacts/` directory and `artifacts/README.md`** — top-level directory for all work artifacts produced by the agent pipeline. Explains the `docs/` vs `artifacts/` split and lists the subdirectory layout (`milestones/`, `architecture/`, `ui-specs/`, `reviews/`, `BUGS.md`, `STANDUP.md`).
- **Prerequisites and Known Limitations sections** in `README.md`. Prerequisites covers Claude Code install, target directory, shell requirements, and Anthropic account. Known Limitations explicitly states: agents are role definitions not running processes, the slash commands are Markdown orchestration scripts, the workflow is Claude Code specific, and no code is written by copying the template.
- **Windows PowerShell equivalents** for Quick Start step 1 copy commands.
- **YAML frontmatter** on every agent file for Claude Code subagent auto-discovery.
- **`TEMPLATE_VERSION` constant** displayed in `README.md` and written into `template.values` by the install script so installed projects can report which template revision they came from.

### Changed

- **`features/` renamed to `artifacts/`.** Every path reference in every template file was updated. The name `artifacts/` was chosen over `features/`, `work/`, `planning/`, or `ai-work/` because it describes what the files *are* (produced outputs with a defined schema and owner) rather than who or when they were produced, pairs cleanly with `docs/` as reference vs produced, and stays accurate when humans edit the files.
- **`docs/` vs `artifacts/` split is now hard-enforced.** `docs/` holds reference material only — requirements, conventions, design rationale, and reusable templates. `artifacts/` holds instances of work. Neither `/agent-plan` nor `/agent-code` ever writes to `docs/`. `docs/FILE_CONVENTIONS.md` was rewritten to enforce this rule with a new "Core Rule" section, updated directory trees, and an extended anti-pattern list.
- **Agent roster split into two stages** in `agents/README.md`. The interaction diagram now shows Planning Stage and Engineering Stage as separate subgraphs. The per-task workflow rules were rewritten to match the Reviewer → Defect/Issue routing introduced by `/agent-code`.
- **CEO moved from "optional" to "required by the shipped slash commands"** in `README.md` → Minimum Viable Agent Set. Deleting `ceo.md` without also deleting both slash commands is now explicitly warned against.
- **Placeholder validation tightened.** Quick Start step 6's fragile `grep -r '\['` replaced with a precise `[UPPER_SNAKE_CASE]` regex that excludes the template's self-referential metadata files (`README.md`, `CHANGELOG.md`, `TROUBLESHOOTING.md`).
- **Quick Start placeholder ordering** reframed. Previously listed 6 of 12 categories in the processing order; now says "top-to-bottom as they appear in the Placeholder Reference table above."
- **`root/CLAUDE.md` Memory Imports** gained `@import artifacts/README.md` so installed projects always load the work-artifact index into session context.
- **Docs Writer scope narrowed.** Docs Writer now explicitly owns `docs/` only and must never move, rename, or rewrite files under `artifacts/`.
- **Bug Gatherer, Debugger, CEO** updated to reference `artifacts/BUGS.md` and `artifacts/reviews/` respectively.

### Removed

- **`agents/asset-gen.md`** — Asset Gen agent removed. The planning stage no longer includes asset generation as a core step. Visual asset production, if needed, is now handled ad-hoc or via a custom subagent outside the standard pipeline.
- **`agents/ux-critic.md`** — UX Critic agent removed. UX review is now folded into the UI agent's screen specification work and the CEO's final planning review.
- **`docs/BUGS.md` and `docs/STANDUP.md`** — these were work artifacts, not reference material. Moved to `artifacts/BUGS.md` and `artifacts/STANDUP.md`.
- **Placeholder tokens no longer in use:** `[PLANNING_DOCS_DIR]`, `[MILESTONE_DEF_PATH]`, `[ARCH_DOC_PATH]`, `[UI_SPEC_PATH]`, `[SECURITY_REVIEW_PATH]`, `[PERF_REVIEW_PATH]`, `[CEO_REVIEW_PATH]`, `[CEO_REVIEW_DIR]`. These were introduced briefly during the refactor and then replaced by fixed `artifacts/` paths.

### Migration from 0.2.x or earlier

If you have an existing project using an earlier revision of this template, the following migrations are needed:

1. **Rename `features/` to `artifacts/`** in your project. Run `grep -rn 'features/' .` after the rename to find any stale references and update them.
2. **Move `docs/BUGS.md` and `docs/STANDUP.md`** to `artifacts/BUGS.md` and `artifacts/STANDUP.md`. Update any agent files, commands, or docs that reference the old paths.
3. **If you deleted `agents/ceo.md`** thinking it was optional, re-add it from this template. Otherwise you must also delete `commands/agent-plan.md` and `commands/agent-code.md` — those commands hard-depend on the CEO stage.
4. **If you kept `agents/asset-gen.md` or `agents/ux-critic.md`**, they are no longer referenced by the main workflow. Keep them as custom subagents if you use them, or delete them.
5. **Add `scripts/check-placeholders.sh` and `scripts/install.sh`** from this template into your project if you want the tighter placeholder validation and reproducible re-installs.
6. **Update `CLAUDE.md`** to reference the `docs/` vs `artifacts/` split so future agent sessions respect the rule.

---

## [0.2.0] — (development snapshot)

Agent roster refactor that introduced the two-stage pipeline: Planning (Product → Architecture + UI → Security + Performance) and Engineering (Coder → Tester → Reviewer). CEO agent was added in this pass. Slash commands `/agent-plan` and `/agent-code` were introduced but still used `[PLANNING_DOCS_DIR]` placeholder paths and wrote to `features/`.

This version existed only briefly during development and is not recommended for new adoption. Upgrade directly to 0.3.0.

---

## [0.1.0]

Original template. 17 agents including Asset Gen and UX Critic, no slash commands, no planning/engineering stage split. Work artifacts (bug tracker, session log, milestone records) lived in `docs/` alongside reference material. No formal changelog from this era exists — entries reconstructed from the refactor that produced 0.3.0.

---

_This file is the historical log for the template itself. File an issue on the template repo for anything that should land in a future release._
