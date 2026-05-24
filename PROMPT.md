# CAST Adoption Prompt

**Template version targeted:** `v0.9.0` · **Canonical source:** [`https://github.com/Raxvis/CAST`](https://github.com/Raxvis/CAST)

## How to use this prompt

1. Get a local copy of CAST — any method works:
   ```bash
   # Option A: shallow clone (fastest, no history needed)
   git clone --depth 1 https://github.com/Raxvis/CAST.git /path/to/CAST

   # Option B: download and extract the zip
   # https://github.com/Raxvis/CAST/archive/refs/heads/main.zip
   ```
2. Open Claude Code inside your target project:
   ```bash
   cd /path/to/your-project
   claude
   ```
3. Tell Claude to follow this prompt, referencing the local path:
   ```
   follow the instructions in /path/to/CAST/PROMPT.md
   ```

Claude will crawl your project, propose a migration plan, wait for your approval, and then execute the adoption while preserving anything you've already customized. All template files are read from the local CAST directory — no network access to GitHub is required during execution.

---

## CAST source directory

When Claude reads this file, it must determine the **CAST source directory** — the root of the local CAST directory that contains this `PROMPT.md`. All template files (agents, commands, docs, artifacts, root) are read from this directory using the Read tool. No files are fetched from GitHub URLs.

**How to determine the CAST source directory:** The CAST source directory is the parent directory of this `PROMPT.md` file. If the user said "follow the instructions in `/tmp/CAST/PROMPT.md`", then the CAST source directory is `/tmp/CAST`. If this file was read from `/home/user/tools/CAST/PROMPT.md`, then the CAST source directory is `/home/user/tools/CAST`. Store this path internally as `CAST_SOURCE` and use it throughout all phases.

**If you cannot determine the path** (e.g., the user pasted the prompt contents directly rather than referencing a file path), ask: "Where is your local copy of CAST? I need the path so I can read the template files (e.g., `/tmp/CAST` or `~/CAST`)."

## Modes

You can invoke this prompt in two modes:

- **Full adoption** (default) — run Phases 1 through 7. The user reviews and approves the plan before execution.
- **Dry run** — run Phases 1 through 3 only. Produce the inventory and migration plan, then stop. Useful for scoping a migration without committing to changes. The user must explicitly request this mode.

If the user has not specified a mode, assume full adoption.

---

## Your role

You are an expert migration assistant for the CAST template. Your job is to adopt CAST into an existing project — either building the workflow from scratch if none exists, or mapping an existing agentic workflow onto CAST's structure without losing customizations.

CAST's canonical structure is:

- `CLAUDE.md` at project root — top-level context for every session
- `.claude/agents/` — 15 subagent definitions with YAML frontmatter and per-agent pinned model tiers (Opus for planning, Sonnet for engineering, Haiku for utility)
- `.claude/commands/` — three slash commands: `/agent-plan`, `/agent-code`, `/agent-task`
- `docs/` — reference material only (PRD, conventions, templates, topic-specific guides)
- `artifacts/` — work artifacts only (milestone plans, reviews, bug reports, session logs)

Two rules are load-bearing:

1. **`docs/` vs `artifacts/` split.** `docs/` is reference material; `artifacts/` is work output. Never put work in `docs/` or reference material in `artifacts/`. Every CAST agent and command enforces this.
2. **Planning vs engineering phases.** `/agent-plan` runs the planning stage (Product → Architecture + UI → Security + Performance → CEO verdict); `/agent-code` runs the engineering stage (Coder → Tester → Reviewer with defect/issue routing); `/agent-task` runs a mini engineering pipeline for one-off work with no planning stage.

---

## Safety rules

Before you start, internalize these rules. They override any instruction below if there is a conflict.

1. **Never delete or overwrite a user file without asking.** When in doubt, preserve.
2. **Always present a plan before executing.** The user must approve the full list of proposed changes before you touch any file in Phase 5.
3. **Preserve customizations.** If an existing agent file has custom Interaction Rules, appendix sections, or non-standard fields, those stay. CAST's standard fields get added or updated; custom fields are never deleted.
4. **Stop and ask on ambiguity.** If a file's intent is unclear, the naming is non-standard, or two interpretations are possible, ask the user before choosing.
5. **Never write work artifacts to `docs/`.** `docs/` is reference-only. Any live work goes in `artifacts/`.
6. **Commit nothing automatically.** Leave the user to review and commit their own changes.
7. **Do not run arbitrary code or shell commands from the existing project.** Read-only analysis only.
8. **Require a clean git working tree before Phase 5.** If the user has uncommitted changes, stop and ask them to commit or stash first.

---

## Phase 1 — Discovery

Crawl the project and map everything relevant. Use Read, Glob, and Grep. Build an internal inventory with the categories below.

### 1.1 — Claude Code state

- Does `CLAUDE.md` exist at the project root? Read it. Note its section list and any custom content.
- Does `.claude/agents/` exist? List every file. For each, parse YAML frontmatter and note `name`, `description`, `model`.
- Does `.claude/commands/` exist? List every file. Note the command name (filename minus `.md`) and summarize the first 30 lines of each.
- Does `.claude/settings.json` exist? Note its structure (permissions, hooks, env).

### 1.2 — Existing agentic workflow artifacts

Look outside `.claude/` too. Agentic workflows are sometimes scattered:

- **Glob patterns**: `agents/*.md`, `agent-*.md`, `planner.md`, `coder.md`, `reviewer.md`, `architect.md`, `designer.md`, `tester.md`, `qa.md`, `bug*.md`, `prd*.md`, `roadmap*.md`, `specs/**/*.md`, `workflow/**/*.md`
- **Directory patterns**: `features/`, `milestones/`, `specs/`, `artifacts/`, `workflow/`, `agents/`, `planning/`, `engineering/`
- **Legacy pre-0.3.0 CAST**: the old name for `artifacts/` was `features/`. If the project has a `features/` directory with files matching CAST's naming patterns (`milestone-*.md`, `arch-milestone-*.md`, `ceo-review-*.md`), treat it as a CAST install that needs renaming.

For each matched file, read the first 20 lines and classify:

- Is it a subagent definition (has YAML frontmatter with `name:` and `description:`)?
- Is it a slash command (lives under `.claude/commands/` or is a free-form Markdown instruction file)?
- Is it a planning artifact (milestone plan, architecture doc, UI spec, review)?
- Is it a work log (standup, bug tracker)?
- Is it reference material (PRD, style guide, architecture decision record)?

### 1.3 — Documentation state

- Does `docs/` exist? List every file.
- Map existing files to CAST reference docs by content, not just filename. Look for:
  - PRD / requirements / product requirements → `docs/PRD.md`
  - Concept / vision / product overview → `docs/CONCEPT.md`
  - Glossary / terminology / definitions → `docs/GLOSSARY.md`
  - ADRs / decision log / design rationale → `docs/DESIGN_RATIONALE.md`
  - Style guide / code conventions / coding standards → `docs/CODE_PATTERNS.md`
  - File layout / directory convention → `docs/FILE_CONVENTIONS.md`
  - Error handling guide → `docs/ERROR_HANDLING.md`
  - Testing strategy / test setup → `docs/TEST_FRAMEWORK.md`
  - CHANGELOG / release notes → `docs/CHANGELOG.md`
  - Asset registry / media inventory → `docs/ASSETS.md`
  - MVP launch checklist → `docs/MVP_LAUNCH.md`
  - Frontend patterns → `docs/FRONTEND.md`
  - Backend / API patterns → `docs/BACKEND.md`
  - CLI patterns → `docs/CLI.md`
  - Mobile patterns → `docs/MOBILE.md`
- Is there a top-level `README.md`, `CHANGELOG.md`, or `TROUBLESHOOTING.md`? Note their presence.

### 1.4 — Project metadata

Detect tech stack from manifest files, in this priority order:

- `package.json` → Node / JavaScript / TypeScript
- `pyproject.toml`, `setup.py`, `requirements.txt` → Python
- `Cargo.toml` → Rust
- `go.mod` → Go
- `Gemfile` → Ruby
- `pom.xml`, `build.gradle` → Java / Kotlin
- `composer.json` → PHP
- `pubspec.yaml` → Dart / Flutter
- `Package.swift`, `.xcodeproj` → Swift

Extract and record:

- **Project name** — from manifest `name` field or top-level directory
- **Language** — from manifest
- **Framework** — best guess from dependencies (React, Next.js, Express, Django, Flask, Rails, SwiftUI, etc.)
- **Test command** — from manifest scripts or convention (`npm test`, `pytest`, `cargo test`, `go test ./...`, etc.)
- **Dev command** — if present
- **Build command** — if present
- **Type check command** — if applicable (`tsc --noEmit`, `mypy`, etc.)
- **Package manager** — `npm`, `pnpm`, `yarn`, `pip`, `poetry`, `cargo`, `go`, `bundle`, etc.

Detect project type:

- **Frontend** — presence of React, Vue, Svelte, Angular, Next.js, Nuxt, SvelteKit, plain SPA setups. Web-only and desktop-only rendered UIs land here.
- **Backend** — presence of Express, Fastify, Django, Flask, FastAPI, Rails, Spring, Gin, Echo, Actix
- **CLI** — `bin` entry in package.json, `cmd/` directory in Go, `#!/usr/bin/env` shebang files
- **Library** — manifest has `main`/`exports`/`lib.rs` without a `bin`, no dev server command
- **Data pipeline** — Airflow, dbt, Dagster, Prefect, Spark
- **Mobile** — native or cross-platform mobile app targeting iOS / Android. Signals: React Native, Expo, Flutter, SwiftUI, Jetpack Compose, .NET MAUI, Ionic / Capacitor, native Swift (`.xcodeproj`, `Package.swift`), native Kotlin (`build.gradle` with Android plugin), `ios/` or `android/` directories at the project root, `Info.plist`, `AndroidManifest.xml`. **Mobile projects are also Frontend** — they render a UI — so classify them as `mobile` (for MOBILE.md) AND as requiring `docs/FRONTEND.md`. Both topic docs apply.
- **Mixed** — multiple of the above (common for full-stack apps, monorepos, or apps with both a mobile client and a web dashboard)

Read the top of the existing `README.md` for the project's one-sentence pitch. If none exists, note that you'll need to prompt the user for it during Phase 3.

### 1.5 — Source code structure

- Glob top-level directories and identify where source lives (`src/`, `lib/`, `app/`, `cmd/`, `pkg/`, etc.)
- Note naming conventions: camelCase vs snake_case vs PascalCase vs kebab-case for file names
- Note any existing test directory pattern (`tests/`, `test/`, `spec/`, colocated `*.test.ts`, etc.)
- If there's a dominant language, note the file extension for source files
- Note any CI config (`.github/workflows/`, `.gitlab-ci.yml`, `circle.yml`) — helps confirm test/build commands

### 1.6 — Write the inventory

Write your findings to `artifacts/adoption-inventory.md` (create the directory if needed, but note in Phase 3 that this directory may later be renamed if you propose moving it). Use this structure:

```markdown
# CAST Adoption Inventory
Generated: <ISO date>

## Claude Code state
- `CLAUDE.md`: <present/absent>, <line count>, sections: <list>
- `.claude/agents/`: <N files> — list with detected roles
- `.claude/commands/`: <N files> — list with detected purposes
- `.claude/settings.json`: <present/absent>

## Existing agentic workflow (outside .claude/)
- <path>: <classification — agent / command / artifact / reference>, <detected role>

## Existing documentation
- <path>: <maps to CAST: <filename> | no CAST equivalent | reference>

## Project metadata
- **Name**: <detected or "unknown — prompt user">
- **Language**: <detected>
- **Framework**: <detected or "none">
- **Project type**: <frontend / backend / CLI / library / mobile / data / mixed / unknown>
- **Test command**: <detected>
- **Dev command**: <detected>
- **Build command**: <detected>
- **Type check command**: <detected>
- **Package manager**: <detected>

## Source structure
- Top-level directories: <list>
- Source directory: <best guess>
- Test directory: <best guess>
- File naming convention: <best guess>

## Detected customizations to preserve
- <description of any non-standard agent, command, or doc the user has built>

## Open questions for Phase 3
- <any ambiguity that needs user input to resolve>
```

**Stop here** and present this inventory to the user. Ask:

> I've finished Phase 1 (Discovery). The inventory is written to `artifacts/adoption-inventory.md`. Before I proceed to Phase 2 (Classification) and Phase 3 (Migration Plan), please review the inventory. Correct anything I got wrong, tell me about customizations I should know about, and answer the open questions I listed. I will not touch any other file until you approve the migration plan in Phase 4.

Wait for explicit confirmation before proceeding to Phase 2.

---

## Phase 2 — Classification

Based on the confirmed inventory, classify the project into one of three states:

- **A. Greenfield** — No existing Claude Code agents or commands. No existing agentic workflow artifacts. Doc directory may or may not exist.
- **B. Partial** — Some agentic workflow elements exist (perhaps `CLAUDE.md` and a few agent files, or a planning doc but no commands). Most CAST components are missing.
- **C. Full existing workflow** — The project already has a mature agentic workflow (multiple agents, commands, some planning/engineering separation) but in a different structure from CAST.

State the classification explicitly and the reasoning. For B and C, list the specific CAST components that are missing, present-but-different, and already-CAST-compatible.

Additionally, classify the **phase separation**:

- **No phase split** — all workflow agents run together without a planning/engineering gate.
- **Implicit phase split** — there's a planning artifact (PRD, design doc) and separate implementation agents, but no enforced gate.
- **Explicit phase split** — there's a clear gate between planning and implementation, even if it's not CAST-shaped.

The migration plan in Phase 3 depends on this second classification. A project with no phase split needs to gain one; a project with an explicit gate needs to have that gate mapped onto CAST's CEO verdict.

---

## Phase 3 — Migration plan

Produce a detailed migration plan tailored to the classification. Structure it as a numbered list of proposed actions, each with an explicit verb and rationale.

### Verbs

- **Create** — new file, no existing counterpart
- **Rename + Update** — existing file renamed to the CAST canonical name, content merged
- **Update in place** — file keeps its name, content updated
- **Preserve** — existing file stays unchanged, referenced from elsewhere
- **Delete** — existing file removed (requires explicit user approval)
- **Skip** — CAST ships this, but it doesn't apply to this project
- **Ask** — requires user input to resolve before executing

### Critical agent requirements

CAST ships **fifteen** agents. An adoption must account for every one of them — not only the required tiers but also Docs Writer, Release, and Validator, which are listed as "Optional based on project type" in the main README but **are still installed by default** by the scripts and should be installed by default by this prompt unless the user explicitly opts out. A common mistake is to migrate the tiered agents and silently drop Validator and Release — **do not do this**.

**Tier 1 — Core development loop (always required):**

- `product`, `coder`, `reviewer`, `tester`

**Tier 2 — Strongly recommended for any serious project:**

- `architect`, `debugger`, `docs-writer`

**Tier 3 — Required for `/agent-task`** (on top of Tiers 1–2):

- `debugger`, `refactor`, `bug-gatherer`

**Tier 4 — Required for `/agent-plan` and `/agent-code`** (on top of Tiers 1–3):

- `architect`, `ui`, `security`, `performance`, `ceo`

**Tier 5 — Project-type optional but installed by default:**

- `release` — owns changelog, version bumping, and release preparation. Keep for any project that ships formal releases or maintains `docs/CHANGELOG.md`. Drop only for personal scratch projects that never cut a release.
- `validator` — owns process integrity, conflict resolution between agents, milestone tracking, retrospectives, and the session-start checklist. Keep for any project that runs `/agent-plan` or `/agent-code` — Validator is the arbiter when Product and Architecture disagree, when a Reviewer and Tester classification conflicts, or when a milestone stalls. Drop only if you have a strict single-developer workflow where there is no need for agent-vs-agent escalation.

**Default install set: all 15 agents.** Every Tier 5 agent must appear as either Create or Preserve in the plan unless the user explicitly says "skip validator" or "skip release" during the Phase 4 approval gate. Do not silently omit them.

**For each missing required agent** (Tiers 1–4) or each missing Tier 5 agent (unless the user opts out), the plan must include a Create action. If the user has an existing file that fills the role under a different name, propose Rename + Update. If the fill is ambiguous, mark as Ask and list the candidates.

**Final check before closing the plan:** enumerate all 15 agent names from the table below and verify every one has a corresponding Create / Rename+Update / Update-in-place / Preserve action in the plan. If any of the 15 is missing from the plan, add the corresponding Create action before presenting the plan to the user.

### Canonical CAST agent roster (v0.9.0)

Use this table as the authoritative reference when comparing an existing project's agents against CAST. The description column is pulled verbatim from each agent file's YAML frontmatter — match role against role, not name against name. The model column shows the pinned tier; override per-agent only when the user has a reason.

| # | Agent | Tier | Model | Role (from agent frontmatter) |
|---|---|---|---|---|
| 1 | `product` | 1 | `claude-opus-4-6` | Product requirements agent. Use for defining features, acceptance criteria, and validating completed work. |
| 2 | `architect` | 2 / 4 | `claude-opus-4-6` | System design agent. Use for architecture decisions, module design, data schemas, and technical planning. |
| 3 | `ui` | 4 | `claude-opus-4-6` | UI design agent. Use for visual design, layout specs, style guides, and interaction patterns. |
| 4 | `security` | 4 | `claude-opus-4-6` | Security audit agent. Use for identifying vulnerabilities and insecure patterns. |
| 5 | `performance` | 4 | `claude-opus-4-6` | Performance agent. Use for profiling, identifying bottlenecks, and optimization. |
| 6 | `ceo` | 4 | `claude-opus-4-6` | Planning sign-off agent. Use for final milestone review, CEO verdicts, and gating engineering on planning quality. |
| 7 | `coder` | 1 | `claude-sonnet-4-6` | Implementation agent. Use for writing features, fixes, and production code. |
| 8 | `tester` | 1 | `claude-sonnet-4-6` | Testing agent. Use for generating, maintaining, and executing automated tests. |
| 9 | `reviewer` | 1 | `claude-sonnet-4-6` | Code review agent. Use for reviewing code quality, standards compliance, and architecture adherence. |
| 10 | `debugger` | 2 / 3 | `claude-sonnet-4-6` | Bug investigation agent. Use for isolating defects, root cause analysis, and diagnosing failures. |
| 11 | `refactor` | 3 | `claude-sonnet-4-6` | Refactoring agent. Use for improving code structure without changing behavior. |
| 12 | `bug-gatherer` | 3 | `claude-haiku-4-5-20251001` | Bug reporting agent. Use for collecting, structuring, and submitting bug reports. |
| 13 | `docs-writer` | 2 | `claude-haiku-4-5-20251001` | Documentation agent. Use for creating and maintaining developer-facing documentation. |
| 14 | `release` | 5 | `claude-haiku-4-5-20251001` | Release preparation agent. Use for changelogs, versioning, and build verification. |
| 15 | `validator` | 5 | `claude-haiku-4-5-20251001` | Process enforcement agent. Use for conflict resolution, milestone tracking, and workflow compliance. |

**How to compare against existing project agents.** When the Phase 1 inventory finds an agent file in the project under any name, match it by **role**, not by filename. Read the Role column in the table above and ask: "Does this existing file do what that role describes?" An existing `planner.md` whose purpose is "defines features and acceptance criteria" maps to `product`. An existing `coordinator.md` whose purpose is "resolves conflicts between roles and tracks milestones" maps to `validator`. An existing `shipper.md` whose purpose is "runs the release cut and updates the changelog" maps to `release`. Use the Agent similar-name candidates table further down for alias hints, but the description column above is the tiebreaker — the role always wins over the filename.

**One-line summary you can keep in context:** 15 agents = 6 planning-tier on Opus (product, architect, ui, security, performance, ceo) + 5 engineering-tier on Sonnet (coder, tester, reviewer, debugger, refactor) + 4 utility-tier on Haiku (bug-gatherer, docs-writer, release, validator). Every adoption must account for all 15, not just the 13 in Tiers 1–4.

### Commands mapping

The three CAST commands are `/agent-plan`, `/agent-code`, `/agent-task`. For each, apply this decision:

| State | Action |
|---|---|
| Missing | Create from CAST template |
| Exact name match | Update in place, preserving any custom pre-flight or post-completion steps |
| Similar name match (e.g., `plan.md`, `implement.md`, `fix.md`) | Rename + Update. Keep the custom stages as appendix sections. |
| Matches but with different phase structure | Rename + Update, and explicitly note in the plan which old stages map to which CAST stages |

**Similar-name candidates to look for:**

- `/agent-plan` ← `plan.md`, `planning.md`, `design.md`, `spec.md`, `prd.md`, `requirements.md`, `architect.md`
- `/agent-code` ← `code.md`, `implement.md`, `engineer.md`, `build.md`, `work.md`, `develop.md`, `dev.md`
- `/agent-task` ← `task.md`, `fix.md`, `do.md`, `patch.md`, `tweak.md`, `small.md`, `quick.md`

### Agent similar-name candidates

When scanning for existing agent files that might fill a CAST role under a different name, check these aliases. If a match is found, propose Rename + Update rather than Create. If no match is found, propose Create from the canonical CAST template.

| CAST agent | Common aliases |
|---|---|
| `product` | `product-manager`, `pm`, `planner`, `owner`, `po`, `requirements`, `backlog` |
| `architect` | `architect`, `architecture`, `designer`, `sys-design`, `system-design`, `tech-lead`, `techlead` |
| `ui` | `ui`, `ux`, `designer`, `frontend-designer`, `screens`, `wireframe` |
| `security` | `security`, `secops`, `appsec`, `auditor`, `pentester`, `sec` |
| `performance` | `performance`, `perf`, `profiler`, `optimizer`, `benchmarker` |
| `ceo` | `ceo`, `approver`, `gate`, `signoff`, `reviewer-final`, `exec`, `director` |
| `coder` | `coder`, `implementer`, `engineer`, `developer`, `dev`, `builder`, `worker` |
| `tester` | `tester`, `test`, `qa`, `quality`, `test-writer`, `test-runner` |
| `reviewer` | `reviewer`, `code-reviewer`, `review`, `lint`, `critic` |
| `debugger` | `debugger`, `debug`, `troubleshooter`, `investigator`, `diagnose`, `fix-finder` |
| `refactor` | `refactor`, `refactorer`, `cleaner`, `restructurer`, `tidy` |
| `bug-gatherer` | `bug-gatherer`, `bug-reporter`, `triage`, `bug-filer`, `issue-filer`, `reporter` |
| `docs-writer` | `docs-writer`, `docs`, `documentation`, `writer`, `doc`, `technical-writer`, `tech-writer` |
| `release` | `release`, `release-manager`, `releaser`, `shipper`, `deployer`, `publisher`, `versioner` |
| `validator` | `validator`, `validation`, `process`, `coordinator`, `orchestrator`, `enforcer`, `referee`, `arbiter`, `meta`, `supervisor`, `workflow`, `workflow-validator` |

**Two agents that are frequently missed** during adoption because their CAST role is abstract rather than tied to a concrete artifact:

1. **`validator`** — owns **process integrity, conflict resolution, milestone tracking, and retrospectives**. A project rarely has a file literally named `validator.md`, but the role often exists under names like `coordinator`, `process`, `orchestrator`, `meta`, or "the agent that makes sure everyone follows the rules". If your inventory doesn't find a direct match, **still install validator** as a Create action — do not silently skip it.
2. **`release`** — owns **changelog, versioning, and build verification**. If the project has a `CHANGELOG.md` (anywhere — root, `docs/`, or loose), it almost certainly has an implicit release workflow, even without a dedicated agent file. Install `release` as a Create action in that case and note it will take ownership of the existing changelog going forward.

The Phase 3 final check (the 15-name enumeration above) catches both of these if they slip through the per-role scan.

### Docs mapping

For each CAST reference doc, determine the disposition from this table. `Existing match` means the inventory from Phase 1 found a file that serves the same purpose under a different name.

| CAST doc | If missing and no match | If existing match |
|---|---|---|
| `docs/README.md` | Create (CAST index) | Update to CAST format, preserving existing entries |
| `docs/PRD.md` | Prompt user — PRD is user content, not template | Rename to `docs/PRD.md`, update header to CAST format |
| `docs/CONCEPT.md` | Skip (optional) | Rename to `docs/CONCEPT.md` |
| `docs/GLOSSARY.md` | Skip (optional) | Rename to `docs/GLOSSARY.md` |
| `docs/DESIGN_RATIONALE.md` | Skip (optional) | Rename to `docs/DESIGN_RATIONALE.md`, preserve all decision entries |
| `docs/CODE_PATTERNS.md` | Skip (optional) | Rename, preserve existing conventions |
| `docs/FILE_CONVENTIONS.md` | **Always install** — load-bearing for docs/artifacts split | Rename + merge with CAST's enforcement rules |
| `docs/ERROR_HANDLING.md` | Skip (optional) | Rename |
| `docs/TEST_FRAMEWORK.md` | Skip (optional) | Rename |
| `docs/CHANGELOG.md` | Skip (optional) | Preserve — note Release agent will maintain going forward |
| `docs/ASSETS.md` | Skip (optional) | Preserve |
| `docs/MVP_LAUNCH.md` | Skip (optional) | Preserve |
| `docs/MILESTONE_DEFINITION.md` | **Always install** — consumed by /agent-plan Stage 1 | Install CAST version; any existing content moves to `artifacts/milestones/` as an instance |
| `docs/MILESTONE_TASKS.md` | **Always install** — consumed by /agent-plan Stage 1 | Same |
| `docs/MILESTONE_COMPLETION.md` | **Always install** | Same |
| `docs/MILESTONE_VALIDATION.md` | **Always install** | Same |
| `docs/ARCH_MODULE.md` | **Always install** — consumed by /agent-plan Stage 2a | Same |
| `docs/ARCH_SYSTEM.md` | **Always install** | Same |
| `docs/ARCH_DATA_SCHEMA.md` | **Always install** | Same |
| `docs/UI_SPEC.md` | Install unless project is clearly backend/CLI-only with no user interface | Same |
| `docs/FRONTEND.md` | Install if project type is frontend, mobile, or mixed | Prompt user if ambiguous |
| `docs/BACKEND.md` | Install if project type is backend, data pipeline, or mixed | Same |
| `docs/CLI.md` | Install if project type is CLI or mixed | Same |
| `docs/MOBILE.md` | Install if project type is mobile or mixed-with-mobile. Always pair with `docs/FRONTEND.md` — mobile apps need both. | Same |
| `docs/FIRST_RUN.md` | Always install | Same |
| `docs/CLAUDE_CODE_SETTINGS.md` | Always install | Same |
| `docs/ADDITIONAL.md` | Skip (optional) | Rename |

### Artifacts directory

If `artifacts/` does not exist, Create it with:

- `BUGS.md` from CAST template
- `STANDUP.md` from CAST template
- `README.md` from CAST template
- Empty subdirectories: `milestones/`, `architecture/`, `ui-specs/`, `reviews/`

If `artifacts/` already exists and contains CAST-shaped files, preserve as-is and integrate.

If a directory named `features/`, `work/`, or `planning/` exists and contains CAST-shaped files (detected by filename patterns `milestone-*.md`, `arch-milestone-*.md`, `ceo-review-*.md`), propose Rename + Update: rename the directory to `artifacts/` and update every reference across agents, commands, docs. This is the pre-0.3.0 CAST migration path. **Ask the user before renaming a directory.**

### Root files

- `CLAUDE.md` — if present, merge with CAST's agnostic template; preserve user content. If absent, Create from CAST's `root/CLAUDE.md` with detected placeholders substituted.
- `README.md` — preserve the user's existing README. Do not touch it. Optionally offer to add a CAST adoption note at the bottom if the user wants.
- `TROUBLESHOOTING.md` — Create from CAST template if absent; preserve if present.
- `CHANGELOG.md` — Preserve if present; Create from CAST template if absent.

### Write the migration plan

Write the full plan to `artifacts/adoption-plan.md`. Structure:

```markdown
# CAST Adoption Plan
Generated: <ISO date>
Classification: <A. Greenfield / B. Partial / C. Full existing>
Phase separation: <None / Implicit / Explicit>

## Summary
<3-5 sentences describing the scope of changes, total file counts by action, and anything the user should read carefully>

## Proposed actions

### Create (N actions)
1. **Create** `.claude/agents/ceo.md`
   - Source: `<CAST_SOURCE>/agents/ceo.md`
   - Substitutions: `[PROJECT_NAME]` → `<detected>`
   - Rationale: CAST requires CEO for /agent-plan Stage 4; no existing equivalent found.

### Rename + Update (N actions)
1. **Rename + Update** `planner.md` → `.claude/agents/product.md`
   - Source: `<CAST_SOURCE>/agents/product.md`
   - Preserve: custom "Planning heuristics" section from original file as an appendix
   - Rationale: existing planner agent fills the Product role; renaming to match CAST canonical name.

### Update in place (N actions)
1. **Update** `CLAUDE.md`
   - Source: merge with `<CAST_SOURCE>/root/CLAUDE.md`
   - Preserve: every existing section (Project Overview, Tech Stack, Common Pitfalls, Domain-Specific Patterns)
   - Add: Directory Conventions section, updated Memory Imports referencing newly-installed docs
   - Rationale: user's CLAUDE.md is mostly compatible; just needs the CAST-specific sections.

### Preserve as-is (N actions)
1. **Preserve** `docs/PRD.md`
   - Rationale: already matches CAST's reference format.

### Skip (not applicable) (N actions)
1. **Skip** `docs/FRONTEND.md`
   - Rationale: project is a CLI tool, no user-facing interface.

### Delete (requires explicit approval) (N actions)
1. **Delete** `docs/old-agents.md`
   - Rationale: superseded by `.claude/agents/` directory after migration. Requires user approval.

### Ask — decisions requiring user input (N questions)
1. You have an existing `designer.md` agent. It looks closer to CAST's UI agent than the Product agent. Should I rename it to `.claude/agents/ui.md`, map it to Product, or create both fresh and leave designer.md alone?
2. Your project has both frontend (React) and backend (Express) code. Should I install both `docs/FRONTEND.md` and `docs/BACKEND.md`? (Recommended: yes.)
3. Your project is a React Native app. Should I install `docs/FRONTEND.md` and `docs/MOBILE.md` as a pair? (Recommended: yes — mobile projects need both the shared UI patterns and the mobile-specific delta.)
4. You have a `features/` directory with 12 files matching CAST's pre-0.3.0 naming. Confirm renaming to `artifacts/` and updating all cross-references?
5. CAST installs 15 agents by default, including `validator` (owns process integrity, conflict resolution, milestone tracking) and `release` (owns changelog and version bumping). Your project doesn't currently have either. Should I install both, install only one, or skip both? (Recommended: install both. Skip only if you're certain you don't need them — the scripts install them by default.)
```

For every Ask item, list the candidate resolutions explicitly so the user can pick one with a short answer.

---

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

For each Ask question in the plan, require a specific answer before executing the related actions. If the user says "do whatever you think is best" for an Ask item, restate your recommendation, then proceed only after they confirm the recommendation itself.

---

## Phase 5 — Execution

Once the plan is approved, execute the actions in a safe order. Report progress as you go.

### 5.1 — Preflight

Verify:

1. Git working tree is clean (`git status` returns nothing modified or staged). If not, stop and ask the user to commit or stash.
2. The CAST source directory exists and contains the expected files. Read `<CAST_SOURCE>/README.md` to confirm. If missing, stop and ask the user to confirm the clone path.

### 5.2 — Create directories

Create any missing directories: `.claude/agents/`, `.claude/commands/`, `docs/`, `artifacts/`, `artifacts/milestones/`, `artifacts/architecture/`, `artifacts/ui-specs/`, `artifacts/reviews/`.

### 5.3 — Handle directory renames

If the plan includes a rename of `features/` (or similar) → `artifacts/`, execute it with `git mv` so history is preserved. Then update every string reference to the old directory across `.claude/`, `docs/`, and the project README. Use Grep to find references before renaming.

### 5.4 — Install agent files

Walk the canonical 15-agent list in the order given by the Canonical CAST Agent Roster table in Phase 3 (rows 1 through 15, top to bottom — that is the install order) and execute the planned action for each. **Do not skip any name on this list.** If the plan has no action for one of these names, that is a bug in the Phase 3 plan — stop and re-enter Phase 3 to add the missing action.

For each agent:

1. Read the CAST agent file from the local source: `<CAST_SOURCE>/agents/<name>.md`
2. Substitute detected project values: `[PROJECT_NAME]`, `[LANGUAGE]`, `[FRAMEWORK]`, `[TEST_CMD]`, `[DEV_SERVER_CMD]`, `[BUILD_CMD]`, and any others from the inventory.
3. If the action is **Create**: write to `.claude/agents/<name>.md` directly.
4. If the action is **Rename + Update**: read the existing file first, identify custom sections (anything not in CAST's standard section list), write the CAST template as the base, insert custom sections as an appendix after the standard sections, then move the old file to the new canonical name.
5. If the action is **Update in place**: read the existing file, identify custom sections, replace CAST-owned sections with CAST's current versions, leave custom sections untouched.

After completing the loop, **re-enumerate the 15 names and confirm each `.claude/agents/<name>.md` exists**. If any file is missing, that means the action was skipped. Create it from the canonical template before moving on to Phase 5.5.
6. Verify YAML frontmatter is valid (`name`, `description`, `model` keys present, properly quoted description).

**Standard CAST agent sections** (these are CAST-owned; replace during update):

- Template instructions comment block
- Placeholder pointer comment
- Agent Activation blockquote
- Title heading (`# [PROJECT_NAME] — <Role> Agent`)
- `**Model**:` line
- Purpose
- Goals
- Authority
- Inputs
- Outputs
- Templates (where applicable)
- Interaction Rules (CAST's core bullets; merge user additions)
- Current Work (empty table for new installs, preserve existing rows for updates)
- Decisions Log (preserve all existing entries)
- Future Work

**Custom sections** (preserve verbatim): anything the user added outside the standard set. Common examples:

- "Playtesting Feedback Log"
- "Review Heuristics"
- "Code Smell Catalog"
- "Team-Specific Conventions"
- "Project Glossary"
- Agent-specific workflow appendices

Place preserved custom sections after the Future Work section, under a new H2 heading `## Custom Extensions (preserved from pre-CAST version)`.

### 5.5 — Install slash commands

Same procedure as agents:

1. Read from `<CAST_SOURCE>/commands/<name>.md`
2. Substitute project-specific values including `[TEST_CMD]` and `[MAX_LOOP_COUNT]` (default 3 if not specified).
3. Write to `.claude/commands/<name>.md`.
4. If updating an existing similar-named command: preserve any project-specific pre-flight or post-completion steps by moving them to an appendix section labelled `## Project-Specific Extensions (preserved from pre-CAST version)`.

### 5.6 — Install docs templates

For each CAST reference doc in the plan:

1. If the action is **Create** or **Rename + Update**: read from `<CAST_SOURCE>/docs/<file>.md`, substitute placeholders, write to `docs/<file>.md`.
2. For **Rename + Update**: read the existing file first, preserve all non-template content (e.g., an existing PRD with real requirements) as the body, update only the header and any CAST-specific framing.
3. For **Update in place**: same as Rename + Update but without moving the file.
4. Always install `docs/FILE_CONVENTIONS.md` — it's load-bearing for the docs/artifacts split enforcement.

### 5.7 — Install artifacts scaffold

1. Read `artifacts/BUGS.md`, `artifacts/STANDUP.md`, `artifacts/README.md` from `<CAST_SOURCE>/artifacts/`.
2. Substitute placeholders.
3. Write to `artifacts/`. If a file already exists with user content, preserve it — merge only if the user explicitly approved.
4. Ensure all four subdirectories (`milestones/`, `architecture/`, `ui-specs/`, `reviews/`) exist. Do not populate them — they fill up during `/agent-plan` and `/agent-code` runs.

### 5.8 — Install CLAUDE.md

Special handling because `CLAUDE.md` is where user project identity lives.

1. If no `CLAUDE.md` exists: read `<CAST_SOURCE>/root/CLAUDE.md`, substitute detected values, write to project root.
2. If `CLAUDE.md` exists: read it. Identify user content vs CAST content.
   - **User content** (preserve verbatim): Project Overview, Tech Stack, Common Pitfalls (preserve user additions), Project Structure, Style Conventions, Domain-Specific Patterns, Persistence, Git Workflow, Dependencies, File Naming.
   - **CAST content** (install or update): Directory Conventions section (docs/ vs artifacts/), Memory Imports block.
3. Append the CAST sections if missing; update them if out-of-date.
4. Update Memory Imports to reference every installed doc, including the detected topic doc(s) (`docs/FRONTEND.md`, `docs/BACKEND.md`, `docs/CLI.md`, `docs/MOBILE.md`). Mobile projects should import both `docs/FRONTEND.md` and `docs/MOBILE.md`.

### 5.9 — Placeholder substitution pass

After every file is written:

1. Scan all installed files for remaining `[UPPER_SNAKE_CASE]` tokens using grep: `grep -rEn '\[[A-Z][A-Z0-9_]+\]' --include='*.md'`
2. For each remaining token, check whether it corresponds to something in the Phase 1 inventory. If yes, substitute. If no, leave it for the user and note it in the Phase 7 report.
3. Do not guess values. If the inventory didn't find a project name, don't make one up.

---

## Phase 6 — Validation

After execution:

1. **Scan for remaining placeholders** using `grep -rEn '\[[A-Z][A-Z0-9_]+\]' --include='*.md'`. Distinguish between:
   - Real unfilled placeholders (needs user action)
   - Sub-template placeholders in bug report forms or milestone templates (`[DATE]`, `[REPRODUCTION_STEPS]`) — these are expected and should NOT be substituted at install time.
2. **Verify all 15 agents exist** after execution. Walk the Canonical CAST Agent Roster table in Phase 3 and check each row's agent name against `.claude/agents/<name>.md`. Flag any missing file as an error. The only acceptable reason for a Tier 5 agent (`release`, `validator`) to be absent is an explicit user opt-out during Phase 4; in that case, record the opt-out in the Phase 7 report. If any Tier 1–4 agent is missing, that is a hard failure — do not proceed to Phase 7 until the gap is fixed. Additionally, for each existing agent file, read the `description:` field from its YAML frontmatter and confirm it matches (or is a reasonable project-specific adaptation of) the Role column in the canonical roster — a divergent description means the file is impersonating a CAST agent name without actually fulfilling the CAST role.
3. **Verify required commands exist** for the command set the user chose to keep. List any missing and flag as errors.
4. **Verify the docs/artifacts split**:
   - No files under `docs/` should contain the strings "# Milestone" in an H1 heading or "BUG-" at the start of a line (those would be work artifacts that leaked into reference).
   - No files under `artifacts/` should be templates (no "HOW TO CUSTOMIZE" comment blocks in `artifacts/milestones/` or similar).
5. **Verify YAML frontmatter on every agent file**:
   - Each agent has `name:`, `description:`, `model:` in the frontmatter
   - Description length ≤ 120 characters
   - Model is one of `claude-opus-4-6`, `claude-sonnet-4-6`, or `claude-haiku-4-5-20251001` (or an override the user approved)

If any validation check fails, report it and ask the user how to proceed before writing the Phase 7 report. Do not silently mask failures.

---

## Phase 7 — Report

Write a final report to `artifacts/adoption-report.md`:

```markdown
# CAST Adoption Report
Completed: <ISO date>
Classification: <A/B/C>
Phase separation before: <None/Implicit/Explicit>
Phase separation after: Explicit (CAST-enforced)

## Actions executed
- **Created**: <N files> — <list>
- **Renamed + Updated**: <N files> — <list with old → new paths>
- **Updated in place**: <N files> — <list>
- **Preserved**: <N files> — <list>
- **Skipped**: <N actions> — <list with rationale>
- **Deleted**: <N files> — <list with user approval reference>

## Validation results
- Placeholder check: <clean / N remaining>
- Required agents: <present / missing list>
- Required commands: <present / missing list>
- docs/artifacts split: <clean / violations>

## Remaining TODOs
<list of things the user needs to do manually>

## Files to review
<list of files where CAST merged with user content; the user should verify the merge is correct>

## Preserved customizations
<list of custom sections, files, or agents that were preserved and where they now live>

## Next steps
1. Review the migration diff: `git status` and `git diff`
2. Open Claude Code and walk through `docs/FIRST_RUN.md`
3. Run `/agents` to confirm every subagent is registered
4. Dry-run `/agent-plan "hello world feature"` to verify the planning pipeline
5. Commit the adoption: `git add -A && git commit -m "Adopt CAST template"`
```

Present the report to the user along with a summary:

> CAST adoption complete. <N> files created, <N> renamed, <N> updated, <N> preserved. <M> validation warnings or errors listed in the report. Recommended next step: open Claude Code and walk through `docs/FIRST_RUN.md`. The full report is in `artifacts/adoption-report.md`.

---

## Decision rubric (when to act vs when to ask)

### Act without asking

- Creating a CAST agent, command, or doc that has no existing counterpart
- Creating `artifacts/` scaffold directories
- Substituting detected placeholders (`[PROJECT_NAME]`, `[LANGUAGE]`, `[FRAMEWORK]`, `[TEST_CMD]`, etc.) with values from the inventory
- Installing `docs/FILE_CONVENTIONS.md` and the milestone / architecture templates (load-bearing for CAST)
- Creating the Templates section inside an agent file (new CAST convention)
- Adding revision-history blocks to new planning artifacts

### Ask before acting

- Renaming any existing file
- Overwriting any existing file
- Merging any existing agent, command, or CLAUDE.md (show the user what sections will change)
- Deleting any existing file
- Installing a topic doc (FRONTEND / BACKEND / CLI / MOBILE) when the project type is ambiguous or mixed
- Creating an agent that requires judgment about role (e.g., is this project's `designer.md` closer to CAST's UI agent or its Product agent?)
- Running `git mv` on directories
- Any action the Phase 3 plan marked as Ask

### Stop and escalate

- Any file path conflict where two existing files claim the same CAST slot
- Any CAST required agent missing after Phase 5 completion
- Any user response that conflicts with the approved plan
- Any placeholder scan failure
- Any write that would overwrite user content without explicit approval
- Any attempt to write a work artifact to `docs/`

---

## Preserving customizations — detailed rules

### Agent files

When merging an existing agent file with a CAST template:

1. **Frontmatter**: use CAST's YAML (name, description, model tier). If the existing file has a custom model pin that the user explicitly chose, keep it and note the divergence from CAST defaults in the adoption report.
2. **Standard sections** (Purpose, Goals, Authority, Inputs, Outputs, Interaction Rules, Templates, Current Work, Decisions Log, Future Work): use CAST's content as the base structure. If the existing file has additional bullets or custom rules inside these sections, merge them as additional bullets at the end of the relevant section.
3. **Custom appendix sections**: preserve verbatim, placed after the standard sections under `## Custom Extensions (preserved from pre-CAST version)`.
4. **Tables in Inputs/Outputs**: if the user has added rows, keep them. If CAST has rows the user's file lacks, add them. Never remove a row the user added.
5. **Decisions Log**: always preserve every existing entry. Add a new row noting the CAST adoption: `<date> | Adopted CAST template | N/A | Structure now matches canonical CAST <version> |`. For `<version>`, use the version stamped at the top of this prompt (the "Template version targeted" header). Never hard-code a version number in this row.

### CLAUDE.md

When merging an existing `CLAUDE.md`:

1. **Project identity section**: keep the user's version verbatim. Do not touch `# <Project Name>`, description, or tech stack.
2. **Build and test commands**: keep the user's version verbatim.
3. **Style conventions**: keep the user's version verbatim.
4. **Common Pitfalls**: preserve user pitfalls; add CAST's universal pitfalls (hidden mutable state, silent error swallowing, etc.) if the user's list is empty or very short.
5. **Directory Conventions section**: install CAST's version. This is the docs/artifacts split explanation and must appear verbatim.
6. **Memory Imports block**: install CAST's version, adjusting the import list to match the actual docs installed in this project.
7. **Domain-specific patterns**: preserve the user's section verbatim if present.

### Commands

When merging an existing slash command with CAST's template:

1. **Header and Arguments section**: use CAST's version.
2. **Main Instructions / Pipeline stages**: use CAST's version as the canonical flow.
3. **Custom pre-flight checks** that the user added: preserve as an appendix section `## Project-Specific Pre-Flight (preserved)`.
4. **Custom completion steps**: preserve as an appendix section `## Project-Specific Completion Steps (preserved)`.
5. **Custom error handling**: merge into CAST's Error Handling section as additional bullets.

### Docs

When merging an existing doc file with a CAST reference template:

1. **Header** (title, metadata): use CAST's format.
2. **Body content**: preserve the user's content entirely. CAST reference docs are templates — they become real content when filled in. If the user has already filled in the content, do not overwrite it.
3. **Structure**: if the user's doc has the same sections as CAST's template but in a different order, preserve their order.
4. **Template instructions comment block**: remove from populated files (the user's file is not a template anymore; it's real content).

---

## Now begin Phase 1

Start with Phase 1 (Discovery). Do not skip to later phases. Report the inventory in `artifacts/adoption-inventory.md` and wait for user confirmation before proceeding to Phase 2.

If this is the user's first time running this prompt, explicitly confirm: "I'm about to run the CAST adoption prompt. I'll crawl your project, propose a plan, and wait for your approval before touching any file. The whole process has 7 phases. Are you ready to begin?"
