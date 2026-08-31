---
name: cast-init
description: >-
  Install or migrate the CAST multi-agent workflow (Claude Agent Staged Team) into the
  current project: 7 specialist subagents, three pipeline skills (/agent-plan,
  /agent-code, /agent-task) plus the /file-bug and /add-task intake skills and the
  /cast-doctor and /cast-release maintenance skills, the .claude/cast/ machinery
  (process contracts, document templates, and the SOURCES.md source map pointing at
  YOUR documentation and standards — CAST ships none of its own), and an artifacts/
  scaffold — with project detection, a user-approved migration plan, and a source-map
  interview. Use when the user says "install CAST", "adopt CAST", "set up CAST",
  "cast init", "migrate to CAST", asks for a staged multi-agent planning/engineering
  workflow, or wants to upgrade an existing CAST install. Supports a dry-run mode that
  produces the migration plan without changing files.
license: MIT
metadata:
  version: "4.0.0"
  source: "https://github.com/Raxvis/CAST"
---

# CAST Adoption — /cast-init

Adopt CAST into the current project through a seven-phase migration: crawl the project, propose a plan, wait for approval, then execute the adoption while preserving anything the user has already customized.

## Locating the CAST payload

All template files are bundled with this skill. Resolve them before Phase 1:

1. The skill's base directory is the directory containing this SKILL.md (provided when the skill is invoked). Call it `CAST_SKILL_DIR`.
2. Set `CAST_SOURCE = <CAST_SKILL_DIR>/assets`. Confirm it exists and contains `agents/`, `skills/`, `cast/`, `artifacts/`, and `root/` (e.g. `ls <CAST_SKILL_DIR>/assets`). The deterministic installer lives beside it at `<CAST_SKILL_DIR>/scripts/install.sh` — Phase 5 runs it for every Create action (`references/execution.md` 5.1a); placement is fixed by rule, never decided per file.
3. With `npx skills` installs, `.claude/skills/cast-init` may be a symlink into `.agents/skills/`. Read files through the path provided — do not dereference symlinks manually, and do not go looking for the payload anywhere else (no network access, no other clones).
4. If `assets/` is missing, stop and tell the user their cast-init install is incomplete (likely a partial copy); re-install with `npx skills add Raxvis/CAST` or `/plugin install cast@cast`.

All template files are read from `CAST_SOURCE` with the Read tool. No files are fetched from GitHub.

## Modes

- **Full adoption** (default) — run Phases 1 through 7. The user reviews and approves the plan before execution.
- **Dry run** — run Phases 1 through 3 only. Produce the inventory and migration plan, then stop. Useful for scoping a migration without committing to changes. The user must explicitly request this mode.
- **Unattended** — for non-interactive sessions (CI, headless runs). Valid only when the invocation explicitly pre-approves the plan AND pre-supplies the answers the gates would ask for (project type, pitch, test command, agent opt-outs). When both are present, treat the Phase 1 and Phase 4 gates as satisfied, record every auto-approved decision verbatim in the Phase 7 report, and never exercise a Delete action — downgrade Deletes to flagged TODOs, since destructive actions require a live approval. Any Ask item the pre-supplied answers do not resolve (including novel Asks that arise mid-run) downgrades to **Preserve** plus a TODO in the Phase 7 report — never guess an answer. If a Phase 6 validation check fails, do not prompt: halt and write a failed-adoption report per `references/validation.md`. A non-interactive invocation *without* explicit pre-approval runs as a dry run; in any non-interactive dry run the Phase 1 confirmation gate is waived — proceed automatically through Phases 1–3 and stop after writing the plan (no one can answer the gate, and Phases 1–3 write only the adoption files).

If the user has not specified a mode, assume full adoption.

**Upgrades — the script-first clause.** From v4 on, upgrading an install is the deterministic installer's job, not a re-adoption. The installer writes `.claude/cast/install-manifest.txt` (per-file hashes of what CAST installed, plus the substitution values), and `scripts/install.sh --upgrade` uses it to replace only byte-unmodified CAST files, add new ones, remove obsolete unmodified ones, and refresh the CLAUDE.md CAST section and stamp — while everything the user customized is kept and reported, never touched. When Phase 1 finds a **manifest-bearing install** (v4.0.0+), the upgrade path is therefore:

1. Run `scripts/install.sh --upgrade` (Phase 5 mechanics apply — never `--force`).
2. Do judgment work only on what the run *reported*: merge CAST's changes into each `kept (customized)` file per the preservation rules in `references/execution.md`, and conduct the source-map interview only for categories a new payload version added.
3. Run Phase 6 validation and write a short Phase 7 report. No seven-phase plan is needed unless the reported set is large or the user asks for one.

A **pre-manifest install** (v3 or older — the stamp is the `Adopted with CAST v<X.Y.Z>` line in the target's `CLAUDE.md` CAST section, see `references/discovery.md` 1.1) takes the full seven-phase migration exactly once: dispositions in `references/dispositions.md`, source-map interview, and 5.1a's installer run — which writes the manifest, making that migration **the last LLM-driven upgrade the project ever needs**. Version comparison rules: equal versions with a completed prior run report "already at <version>" and stop (offer `--upgrade` anyway if the user suspects drift — it is a cheap no-op when nothing changed); equal versions with a missing completion signal mean an interrupted run — enter the resume path in `references/execution.md` 5.1; a *newer* installed version means the local cast-init copy is stale — suggest `npx skills update` (or `/plugin marketplace update`) before proceeding.

## Role and canonical structure

Act as an expert migration assistant for the CAST template: adopt CAST into an existing project — either building the workflow from scratch if none exists, or mapping an existing agentic workflow onto CAST's structure without losing customizations.

CAST v4 ships **no documentation** — the project brings its own, and CAST plugs into it. The canonical structure in a target project is:

- `CLAUDE.md` at project root — the user's own file; CAST appends exactly one section (workflow summary, source-map pointer, version stamp) and never owns the rest
- `.claude/agents/` — 7 subagent definitions with YAML frontmatter and per-agent model settings (all `model: inherit` by default — agents run on the session model)
- `.claude/skills/` — three pipeline skills (`/agent-plan`, `/agent-code`, `/agent-task`), two intake skills (`/file-bug` files user-found bugs individually, `/add-task` queues one-off tasks in the `artifacts/TASKS.md` backlog), plus `/cast-doctor`, the run-anytime install health check, and `/cast-release`, release-prep automation
- `.claude/cast/` — CAST's machinery: **`SOURCES.md` (the source map — where THIS project's documentation, standards, and registers live, written from the user's answers at install)**, the two process contracts (`PIPELINE_LOOP.md`, `STAGE_CONTRACT.md`), and the document templates (`templates/`, copied into `artifacts/` as instances)
- `artifacts/` — work artifacts only, **grouped by milestone**: one `milestone-{N}-{slug}/` directory per milestone (README, design docs, reviews/, one file per task under tasks/, one file per bug under bugs/), `one-off/` for /agent-task work, and cross-milestone logs (BUGS.md index, TASKS.md backlog, STANDUP.md, AGENT_STATE.md) at the root

Two rules are load-bearing:

1. **Bring-your-own documentation.** CAST installs no docs and never relocates the project's. The source map records where they live; planning reads the sources and distills what applies into milestone artifacts; engineering reads only the artifacts; Docs Writer updates the mapped Documentation Home. Work output goes to `artifacts/`, never into the project's documentation.
2. **Planning vs engineering phases.** `/agent-plan` runs the planning stage (Product → Architecture + UI → Risk → CEO verdict); `/agent-code` runs the engineering stage (Coder → Reviewer with defect/issue routing); `/agent-task` runs a mini engineering pipeline for one-off work with no planning stage.

## Safety rules

Internalize these before starting. They override any instruction below if there is a conflict.

1. **Never delete or overwrite a user file without asking.** When in doubt, preserve.
2. **Always present a plan before executing.** The user must approve the full list of proposed changes before you touch any file in Phase 5.
3. **Preserve customizations.** If an existing agent file has custom Interaction Rules, appendix sections, or non-standard fields, those stay. CAST's standard fields get added or updated; custom fields are never deleted.
4. **Stop and ask on ambiguity.** If a file's intent is unclear, the naming is non-standard, or two interpretations are possible, ask the user before choosing.
5. **Never write into the project's documentation, and never move it.** The source map points at documentation where it already lives; adoption records locations, it does not reorganize them. Any live work goes in `artifacts/`.
6. **Commit nothing automatically.** Leave the user to review and commit their own changes.
7. **Never execute the target project's code.** Do not run its build, tests, scripts, or binaries during adoption — analysis of the project is read-only. Shell use for the adoption's own mechanics (git status/mv, grep, copying CAST payload files per `references/execution.md`) is fine.
8. **Require a clean git working tree before Phase 5.** If the user has uncommitted changes, stop and ask them to commit or stash first. The adoption's own files (`artifacts/adoption-inventory.md`, `artifacts/adoption-plan.md`, `artifacts/adoption-report.md`) are exempt — Phases 1 and 3 write them before Phase 5 by design, so they never count as dirty. Exceptions for resuming an interrupted or staged adoption are defined in `references/execution.md` preflight. If the project is not a git repository, warn the user there is no rollback safety net, then either get their explicit confirmation to proceed without one or offer to run `git init` (plus an initial commit) first.

## Phase 1 — Discovery

Crawl the project and map everything relevant using Read, Glob, and Grep. Follow the full checklist in `references/discovery.md` — it covers:

- **1.1 Claude Code state** — `CLAUDE.md`, `.claude/agents/`, `.claude/skills/` (prior CAST 1.x installs), `.claude/commands/` (pre-1.0 CAST installs), `.claude/settings.json`
- **1.2 Existing agentic workflow artifacts** outside `.claude/` (including legacy pre-0.3.0 `features/` directories)
- **1.3 Documentation state** — find where the project's documentation actually lives (doc directories, CONTRIBUTING/ARCHITECTURE/TESTING files, ADRs, wikis exported into the repo, a changelog) and classify each find by source-map category; these are the **candidate source-map entries** the Phase 3 interview proposes. Docs are never mapped onto CAST docs — v4 ships none
- **1.4 Project metadata** — tech stack, commands, project type (frontend / backend / CLI / library / data / mobile / mixed), and workspace/monorepo layout detected from manifests
- **1.5 Source code structure** — source layout, naming conventions, test patterns, CI config
- **1.6 The inventory** — archive any *completed* prior run's `adoption-*.md` files (date suffix, or confirmed overwrite in interactive mode). A pre-existing `adoption-plan.md` with unchecked ledger entries is a resume candidate, not an archive candidate — preserve it for the resume path in `references/execution.md` 5.1. Then write findings to `artifacts/adoption-inventory.md` using the template in the reference file

**Stop after writing the inventory** and present it to the user:

> I've finished Phase 1 (Discovery). The inventory is written to `artifacts/adoption-inventory.md`. Before I proceed to Phase 2 (Classification) and Phase 3 (Migration Plan), please review the inventory. Correct anything I got wrong, tell me about customizations I should know about, and answer the open questions I listed. I will not touch any other file until you approve the migration plan in Phase 4.

Wait for explicit confirmation before proceeding to Phase 2. (Exception: in a non-interactive dry run this gate is waived — see Modes; continue straight through Phases 2–3 and stop after writing the plan.)

## Phase 2 — Classification

Based on the confirmed inventory, classify the project into one of three states:

- **A. Greenfield** — No existing Claude Code agents or pipelines. No existing agentic workflow artifacts. Doc directory may or may not exist.
- **B. Partial** — Some agentic workflow elements exist (perhaps `CLAUDE.md` and a few agent files, or a planning doc but no pipelines). Most CAST components are missing.
- **C. Full existing workflow** — The project already has a mature agentic workflow (multiple agents, pipelines, some planning/engineering separation) but in a different structure from CAST.

State the classification explicitly and the reasoning. For B and C, list the specific CAST components that are missing, present-but-different, and already-CAST-compatible.

Additionally, classify the **phase separation**:

- **No phase split** — all workflow agents run together without a planning/engineering gate.
- **Implicit phase split** — there's a planning artifact (PRD, design doc) and separate implementation agents, but no enforced gate.
- **Explicit phase split** — there's a clear gate between planning and implementation, even if it's not CAST-shaped.

The migration plan in Phase 3 depends on this second classification. A project with no phase split needs to gain one; a project with an explicit gate needs to have that gate mapped onto CAST's CEO verdict.

## Phase 3 — Migration plan

Produce a detailed migration plan tailored to the classification. Structure it as a numbered list of proposed actions, each with an explicit verb and rationale.

**Verbs:**

- **Create** — new file, no existing counterpart
- **Rename + Update** — existing file renamed to the CAST canonical name, content merged
- **Update in place** — file keeps its name, content updated
- **Preserve** — existing file stays unchanged, referenced from elsewhere
- **Delete** — existing file removed (requires explicit user approval)
- **Skip** — CAST ships this, but it doesn't apply to this project
- **Ask** — requires user input to resolve before executing

Build the plan from these reference files:

- **`references/roster.md`** — the canonical 7-agent roster with tiers, models, and effort levels; a table mapping the eight v2 agents that were merged away to their v3 homes; alias tables for matching existing files by role; and the pipeline-skills mapping. **All 7 agents are non-negotiable by default**: every one must appear in the plan as Create / Rename+Update / Update-in-place / Preserve unless the user explicitly opts out of `ui` for a clearly backend/CLI-only project (see the opt-out rules in `references/roster.md`). Before closing the plan, enumerate all 7 names and verify each has an action. When the inventory finds v2 CAST agents (`tester`, `refactor`, `debugger`, `bug-gatherer`, `validator`, `security`, `performance`, `release`) or a pre-release v3 `risk`, propose Delete for each **and name where its duties went** — the user must be able to see nothing was dropped.
- **`references/dispositions.md`** — the `.claude/cast/` install rules (contracts, templates, source map), artifacts scaffold rules, root-file rules (the CLAUDE.md CAST section), the v3→v4 migration dispositions (installed `docs/` and `templates/` directories from a prior CAST version), and the plan-file format.

**The source-map interview.** Every plan carries an Ask block that builds `.claude/cast/SOURCES.md` — the centerpiece of the install. For each category (Standards & Conventions, Product & Requirements, Architecture & Design, Testing & Quality, Documentation Home, Project Registers), propose the candidate locations Phase 1.3 found — with one line on why each was classified there — and let the user confirm, correct, add locations you missed, or declare the category empty. Do not guess a location the discovery did not surface, and do not press the user to invent documentation they don't have: `_None declared._` is a valid, honest answer that the pipelines handle. Record the confirmed entries in the plan; 5.6 writes the file verbatim from them.

**Model right-sizing.** Agents install with `model: inherit` (the session model) by default. Every plan must include an Ask item inviting the user to right-size per-agent models for cost: the judgment-heavy gates (CEO, Architect, Reviewer, Risk) stay on the most capable model available (e.g. `opus`, or a Fable/Mythos-class model), the planning-and-implementation loop runs well on `sonnet`, and the utility roles on `haiku`. The suggested assignment table is in `references/roster.md` → "Right-sizing models"; record accepted pins into the corresponding agent actions so 5.4 applies them at install.

Write the full plan to `artifacts/adoption-plan.md` using the format in `references/dispositions.md`. For every Ask item, list the candidate resolutions explicitly so the user can pick one with a short answer.

## Phase 4 — User approval gate

Present the migration plan to the user. Quote the counts of each action category. Ask explicitly:

> I've drafted a migration plan with <N> total proposed actions:
>
> - **Create**: <N>
> - **Rename + Update**: <N>
> - **Update in place**: <N>
> - **Preserve**: <N>
> - **Skip**: <N>
> - **Delete**: <N> (requires your explicit approval)
> - **Questions**: <N> (need your answer before I can proceed)
>
> The full plan is in `artifacts/adoption-plan.md`. Please review it carefully. Tell me:
>
> 1. Which questions to resolve (answer each by number)
> 2. Which actions to modify or skip
> 3. Whether to proceed with the rest of the plan as written
>
> I will not touch any file in Phase 5 until you give explicit approval. If you want me to stop after Phase 3 (dry run mode), say so now.

Wait for explicit approval. **Do not proceed on ambiguous responses** like "looks good, maybe tweak that one thing" — ask for specific resolutions on every action the user wants to modify.

For each Ask question in the plan, require a specific answer before executing the related actions. If the user says "do whatever you think is best" for an Ask item, restate the recommendation, then proceed only after they confirm the recommendation itself.

Once approval is given, **record every Phase 4 resolution into `artifacts/adoption-plan.md` before entering Phase 5** — Ask answers, user modifications to actions, and skipped actions — so the plan file matches exactly what will execute. The Phase 5 resume path and the Phase 7 report both cross-reference the plan file; a stale plan breaks both.

## Phase 5 — Execution

Once the plan is approved, execute the actions in a safe order, reporting progress as you go. **Read `references/execution.md` before writing any file** — it contains the full install mechanics and the customization-preservation rules, including the global rule that `<!-- TEMPLATE INSTRUCTIONS -->` blocks and placeholder-pointer comments are stripped from every installed file (the ten `.claude/cast/templates/` skeletons excepted). Execute its sections in order:

1. **5.1 Preflight**
2. **5.1a The deterministic installer handles pure-Create actions** — run `scripts/install.sh` (bundled beside this skill) for every Create; it places files by fixed rule, never overwrites, and leaves merge work to 5.4–5.8
3. **5.2 Create directories**
4. **5.3 Handle directory renames**
5. **5.4 Install agent files**
6. **5.5 Install pipeline skills**
7. **5.5a Execute approved Deletes**
8. **5.6 Install `.claude/cast/` (contracts, templates, source map)**
9. **5.7 Install artifacts scaffold**
10. **5.8 Install CLAUDE.md**
11. **5.9 Placeholder substitution pass**

As each executed action completes, check it off in `artifacts/adoption-plan.md` — that ledger is the resume and rollback record (see the progress-ledger rule in `references/execution.md`).

## Phase 6 — Validation

Run every check in `references/validation.md` — the numbers below match its check numbers:

1. **Placeholder scan** — scoped to the files the plan touched, excluding cast-init's own payload directory; expected sub-template tokens like `[DATE]` are fine, real unfilled placeholders are not.
2. **All 7 agents exist** with frontmatter matching the canonical roles (a `ui` absence on a backend/CLI-only project requires a recorded opt-out; every other absence is a hard failure). No v2 agent file survives in `.claude/agents/`.
3. **Pipeline skills** — the skills the user chose to keep exist at `.claude/skills/<name>/SKILL.md` with valid frontmatter, and no superseded pre-1.0 command files remain (in unattended mode, a leftover whose Delete was downgraded to a recorded TODO passes).
3a. **`.claude/cast/` and artifacts scaffold** — `.claude/cast/SOURCES.md`, `PIPELINE_LOOP.md`, `STAGE_CONTRACT.md`, and the `templates/` skeletons exist; `artifacts/BUGS.md`, `TASKS.md`, `STANDUP.md`, `AGENT_STATE.md` exist.
4. **Source map integrity** — every location entry in `SOURCES.md` resolves (path exists, glob matches, directory non-empty of markdown), every required category carries entries or an explicit `_None declared._`, and the file matches what the user approved in the interview.
5. **Agent frontmatter** — every agent file has valid `name`/`description`/`model` frontmatter (description ≤ 300 characters).
6. **Template scaffolding stripped** — no installed file outside `.claude/cast/templates/` carries a `<!-- TEMPLATE INSTRUCTIONS -->` block, and no `artifacts/` instance does.
7. **CLAUDE.md CAST section and version stamp** — the CAST section exists, points at `.claude/cast/SOURCES.md`, and carries exactly one `Adopted with CAST v<X.Y.Z>` line matching this skill's `metadata.version`; no stale CAST-owned Memory Import lines (`@docs/...` from a v3 install) survive.
8. **UI opt-out consistency** — the `ui` agent and the UI templates (`.claude/cast/templates/UI_SPEC.md`, `.claude/cast/templates/UX_REVIEW.md`) are installed together or skipped together.

If any validation check fails, report it and ask the user how to proceed before writing the Phase 7 report — in unattended mode, do not prompt: halt and write a failed-adoption report per `references/validation.md`. Do not silently mask failures.

## Phase 7 — Report

Write the final report to `artifacts/adoption-report.md` using the template in `references/validation.md`, then present it with the closing summary, filling every slot to match the actual outcome:

> CAST adoption <complete / complete with warnings / staged / failed at Phase <N>>. <N> files created, <N> renamed, <N> updated, <N> preserved, <N> deleted. <M> validation warnings or errors listed in the report. <If any paths were staged: "Staged paths: <list>. Complete the install with: <exact `mv` command(s)>, then remove the empty `.cast-stage/` directory."> Recommended next step: <restart Claude Code (skills are discovered at session start), confirm the seven skills tab-complete, and start with `/agent-task` on something trivial or `/agent-plan` on a real feature / for a partial or failed adoption: the first recovery step from the report>. The full report is in `artifacts/adoption-report.md`.

## Decision rubric (when to act vs when to ask)

**Act without asking:**

- Creating a CAST agent, pipeline skill, or `.claude/cast/` file that has no existing counterpart
- Creating `artifacts/` scaffold directories
- Substituting detected placeholders (`[PROJECT_NAME]`, `[TEST_CMD]`, etc.) with values from the inventory
- Installing the process contracts and document templates under `.claude/cast/` (load-bearing for CAST)
- Creating the Templates section inside an agent file (CAST convention)

**Ask before acting:**

- Renaming any existing file
- Overwriting any existing file
- Merging any existing agent, pipeline, or CLAUDE.md (show the user what sections will change)
- Deleting any existing file (including superseded pre-1.0 command files)
- Classifying an ambiguous documentation location into a source-map category (when Phase 1.3's classification is a genuine coin flip, the interview asks rather than assumes)
- Creating an agent that requires judgment about role (e.g., is this project's `designer.md` closer to CAST's UI agent or its Product agent?)
- Running `git mv` on directories
- Any action the Phase 3 plan marked as Ask

**Stop and escalate:**

- Any file path conflict where two existing files claim the same CAST slot
- Any CAST required agent missing after Phase 5 completion
- Any user response that conflicts with the approved plan
- Any placeholder scan failure
- Any write that would overwrite user content without explicit approval
- Any attempt to write into, move, or reorganize the project's own documentation

## Reference files

- **`references/discovery.md`** — Phase 1 checklists and the inventory template
- **`references/roster.md`** — 7-agent roster, tiers, alias tables, pipeline-skills mapping
- **`references/dispositions.md`** — `.claude/cast/`, artifacts, and root-file install rules, the v3→v4 migration dispositions, and the plan-file format
- **`references/execution.md`** — Phase 5 install mechanics and customization-preservation rules
- **`references/validation.md`** — Phase 6 checklist and the Phase 7 report template

## Begin

Start with Phase 1 (Discovery). Do not skip to later phases. Report the inventory in `artifacts/adoption-inventory.md` and wait for user confirmation before proceeding to Phase 2.

If this is the user's first run, explicitly confirm: "I'm about to run the CAST adoption. I'll crawl your project, propose a plan, and wait for your approval before touching any file. The whole process has 7 phases. Are you ready to begin?"
