<!-- TEMPLATE INSTRUCTIONS
  This file is the master index for the CAST repo. It describes the purpose,
  structure, placeholder conventions, and file inventory for every template file
  in this repository. It is never installed into target projects — adoption is
  performed by the /cast-init skill, which substitutes [PLACEHOLDER_NAME] tokens
  and strips TEMPLATE INSTRUCTIONS blocks from the files it installs.
-->

# CAST — Claude Agent Staged Team

> **A multi-agent workflow template for Claude Code.** Eight specialist subagents, three pipeline skills plus two maintenance skills, and a CEO-gated planning pipeline — shipped as plain Markdown via a single `/cast-init` skill, no framework to install, no runtime to maintain.

![Template version](https://img.shields.io/badge/template-v3.0.0-blue)
![Claude Code](https://img.shields.io/badge/Claude_Code-required-9cf)
![Agents](https://img.shields.io/badge/agents-8-orange)

CAST gives you a real team structure with clear handoffs, typed artifacts, and a review gate you can't accidentally skip. The name is a double pun: a *cast* is a group of specialists each playing a defined role, and the pipeline runs in *stages* — planning (Product → Architecture + UI → Risk → CEO sign-off) followed by engineering (Coder → Reviewer, with defect and issue routing).

```text
Planning stage — /agent-plan

    feature request
          │
          ▼
    Product  →  Architecture + UI  →  Risk  →  CEO verdict
                                                                      │
                                                                      ▼
                                                         APPROVED (with conditions)


Engineering stage — /agent-code

    Coder  →  Reviewer  ──┬──  Defect  →  Reviewer files the bug  →  Product triage  →  Coder
    (implement,           │
     test, commit)        └──  Issue   →  Coder (loop)
                                                                      │
                                                                      ▼
                                          Reviewer's criteria check: all Met?
                                            yes → orchestrator closes the task
                                            no  → Product validates
                                                                      │
                                                                      ▼
                                          task checkpoint: no agents — Status writeback
                                          (+ docs drain only past 10 pending entries)
                                                                      │
                                             ... every task Complete or Deferred? ...
                                                                      ▼
                                          milestone checkpoint: Deferred re-triage (Product)
                                          →  completion + validation records (Product)
                                          →  docs drain (Docs Writer)
                                          →  UX review (UI, UI-flagged milestones only)
                                          →  retrospective (Product) + orchestrator records


One-off task — /agent-task  (no planning stage, for small self-contained changes)

    Coder  →  Reviewer  →  validation   (same Defect / Issue routing;
                                         Product only when the criteria check flags one)
```

**What you get out of the box:**

- **8 specialist subagents** defaulting to `model: inherit` — each runs on the session model — with effort matched to the workload (`high` on the planning stages and the review gate, `medium` on implementation, `low` on utility). Every role that earned its own cold context has one; the seven v2 roles that did not were merged into the stages that already held their context, with every gate they enforced preserved.
- **Three pipeline skills** — `/agent-plan`, `/agent-code`, `/agent-task` — as plain Markdown orchestration scripts Claude Code discovers at session start, plus two maintenance skills: **`/cast-doctor`** (health check, model-aware documentation pruning, coverage gaps) and **`/cast-release`** (gate verification, versioning, changelog, GO/NO-GO).
- **A hard `docs/` / `templates/` / `artifacts/` split** — `docs/` holds reference material (requirements, conventions), `templates/` holds reusable document skeletons, and `artifacts/` holds live work **grouped by milestone**: one directory per milestone containing its README, design docs, reviews, one file per task, and one file per bug. The CEO gate, placeholder check, and smoke test all enforce the split.
- **Minimal-context handoffs** — every task is an isolated file carrying its own Context Manifest (the complete read set an agent needs) and Handoff Log (the capped, fixed-format record each stage appends). Agents ship the next agent the least context required, through the task file — never through conversation or whole-directory re-reads — and reply to the orchestrator with a single routing line, so the orchestrating context stays flat across a whole milestone.
- **Parallel task execution** — `/agent-code` runs engineering loops for independent tasks concurrently (disjoint dependencies and file lists, up to 3 at a time), with all shared-state writes serialized by the orchestrator. Task isolation is what makes this safe.
- **Toolset-enforced discipline** — every agent's frontmatter declares an explicit `tools:` list that omits the Task tool, so "agents don't spawn subagents" is a hard guarantee, not a request.
- **A fully populated `example/` fixture** so you can see exactly what a real planning run produces.
- **An agnostic `CLAUDE.md`** with opt-in topic docs (`docs/FRONTEND.md`, `docs/BACKEND.md`, `docs/CLI.md`, `docs/MOBILE.md`) for project-type-specific patterns.

Current template version: `v3.0.0` — see [`CHANGELOG.md`](CHANGELOG.md) for the version history and migration notes.

---

## Install

CAST is distributed as a single skill, `cast-init`, installable two ways. Both routes deliver the same `/cast-init` skill; pick whichever fits your tooling.

**Route A — the `skills` CLI:**

```bash
cd /path/to/your-project
npx skills add Raxvis/CAST        # installs the cast-init skill into .claude/skills/
```

(Add `-g` to install globally for all projects instead.)

**Route B — the Claude Code plugin marketplace:**

```
/plugin marketplace add Raxvis/CAST
/plugin install cast@cast
```

> **Note on plugin-route footprint:** the plugin manifest points at the repo root, so a plugin install copies the entire repository — including `example/`, `CHANGELOG.md`, and `.github/` — into your local plugin cache. This is harmless (none of it is installed into your project; `/cast-init` only ever writes the payload under `skills/cast-init/assets/`), just a few hundred kilobytes of extra cache. The `npx skills` route fetches only the `cast-init` skill directory.

**Then run the adoption.** Open Claude Code inside your project (restart the session if it was already open so the skill is discovered) and invoke:

```
/cast-init
```

The skill reads all template files from its bundled payload — no network access to GitHub is required during execution. It will:

1. **Crawl your project** — detect tech stack, existing agents, docs, and customizations.
2. **Propose a migration plan** — numbered list of every file it will create, rename, update, or skip.
3. **Wait for your approval** — nothing is touched until you explicitly approve.
4. **Execute the plan** — install agents, pipeline skills, docs, and artifacts, substituting detected project values.
5. **Validate** — verify all 15 agents exist, the docs/artifacts split is clean, and YAML frontmatter is valid.

This works for greenfield projects, existing projects with no agentic workflow, and existing projects with a mature agentic workflow you want to migrate to CAST.

**Next steps after adoption:**

1. Restart the session so the installed agents and pipeline skills register.
2. Walk through [`docs/FIRST_RUN.md`](skills/cast-init/assets/docs/FIRST_RUN.md) (installed to your project's `docs/`) for the interactive checklist (`/agents`, `/agent-plan` dry run, optional per-agent smoke probes).
3. Commit the populated template as your first commit.

### Keeping CAST up to date

Keep the cast-init skill installed after adoption — it is also the upgrade mechanism:

1. `npx skills update` refreshes the skill to the latest content of this repo (updates are content-hash based, not semver). Plugin installs use `/plugin marketplace update` instead.
2. Re-run `/cast-init`. It detects your installed CAST version, short-circuits if you're already current, and otherwise proposes a migration plan that preserves your customizations.

Two operational notes about the `npx skills` route:

- It writes a **`skills-lock.json`** at your project root recording the skill's source and content hash. Commit it — it is designed for deterministic team installs (a teammate runs `npx skills add` and gets the same revision).
- By default the skill is installed as a **symlink**: the real copy lives in `.agents/skills/cast-init` and `.claude/skills/cast-init` points at it. Pass `--copy` to `npx skills add` if you prefer a real copy (e.g. your tooling doesn't follow symlinks).

---

## Directory Structure

```
CAST/
  README.md              # This file — master index and usage guide
  .claude-plugin/        # Plugin + marketplace manifests (the /plugin install route)
  skills/
    cast-init/
      SKILL.md           # The /cast-init adoption workflow — replaces the old PROMPT.md
      references/        # Detailed phase docs (discovery, roster, dispositions, execution, validation)
      assets/            # The installable payload:
        root/            #   Files intended for the project root (CLAUDE.md template)
        agents/          #   Agent role definitions (installed to .claude/agents/)
        skills/          #   Pipeline skills (installed to .claude/skills/)
        docs/            #   Reference material: requirements, conventions, rationale
        templates/       #   Document templates instantiated into artifacts/
        artifacts/       #   Work artifact scaffold: agent state, bug index, session log
  example/               # Populated fixture: a full "Acme Todo" project walkthrough
```

### The `docs/` / `templates/` / `artifacts/` split

This template enforces a strict separation between **reference material**, **document templates**, and **work artifacts**:

- **`docs/` is documentation only.** It holds things that describe how the project works: the PRD, concept, glossary, coding conventions, file placement rules, error handling standards, testing strategy, and design rationale. `docs/` must never contain feature plans, milestone instances, bug reports, CEO reviews, or progress logs.
- **`templates/` is document templates only.** It holds the reusable skeletons for architecture docs, UI specs, and milestone files. Agents copy them — never fill them in place — to produce instances under `artifacts/`.
- **`artifacts/` is work artifacts only, grouped by milestone.** Each `milestone-{N}-{slug}/` directory holds everything one milestone produces: its README (definition), architecture and UI specs, reviews, per-task files, and per-bug files. Cross-milestone state (bug index, session log, agent state) lives at the root; `/agent-task` work lives under `one-off/`.

If you are unsure where a file belongs, ask: _"Is this a reusable template, other reference material, or a specific piece of work?"_ Template → `templates/`. Other reference → `docs/`. Work → `artifacts/`. Both `/agent-plan` and `/agent-code` write exclusively to `artifacts/`; neither pipeline should ever modify `docs/` or `templates/`.

All the payload directories described below live under `skills/cast-init/assets/` in this repo; the headings use their short names because that is where they land in a target project.

### skills/cast-init/

The `/cast-init` skill itself: `SKILL.md` carries the seven-phase adoption workflow (discovery → classification → migration plan → approval gate → execution → validation → report), `references/` holds the detailed phase documentation it loads on demand, and `assets/` holds the entire installable payload described below.

### root/

Contains the `CLAUDE.md` template that is copied to the root of the target project. This file defines project identity, structure, conventions, and run commands — the top-level context that every agent reads first.

### agents/

Each file defines one agent role with YAML frontmatter for Claude Code auto-discovery. When installed to `.claude/agents/` in the target project, Claude Code automatically registers them as subagents that can be invoked by name or delegated to automatically based on task type. Files that do not apply to your project type can be deleted without affecting the others.

### skills/ (pipeline skills)

Each subdirectory defines one pipeline skill that orchestrates a multi-agent workflow stage end-to-end. When installed to `.claude/skills/` in the target project, Claude Code registers them as skills named after the directory (e.g. `agent-plan/SKILL.md` becomes `/agent-plan`). Three pipelines ship with this template, plus two maintenance skills — `/cast-doctor` (install health check and model-aware documentation audit) and `/cast-release` (release gates, versioning, changelog): `/agent-plan` runs the Planning Stage (Product → Architecture + UI → Risk → CEO), `/agent-code` runs the Engineering Stage (Coder → Reviewer, with Defects routed through Product triage and Issues back to Coder — a clean task is two spawns), and `/agent-task` runs a mini engineering pipeline (Coder → Reviewer → validation) for a single one-off task without requiring a milestone, planning artifacts, or a CEO verdict — use it for bug fixes, typos, small refactors, and dependency bumps, not for new modules or cross-cutting changes. Between the two, `/agent-plan light: <feature>` runs a light planning mode (Product + Architecture + CEO) for a small feature that needs a few design decisions without full milestone ceremony — it also engages automatically when Stage 1 scoping finds 3 tasks or fewer with no new screen set, no security-sensitive scope, no applicable performance budget, and nothing cross-cutting.

### docs/

Reference material only. These are not agent definitions and not work artifacts — they are shared knowledge that multiple agents and human contributors reference: domain rules, quality standards, coding conventions, and reusable document templates. Agents must read from `docs/` but must not write work artifacts to `docs/`.

**Topic-specific reference docs.** Four files in `docs/` are scoped to a project type rather than being universal: `FRONTEND.md`, `BACKEND.md`, `CLI.md`, and `MOBILE.md`. Keep the one(s) that match your project and delete the rest. The shipped `root/CLAUDE.md` is agnostic and names all four as inert backticked paths in its import block — a Claude Code import only fires as a bare `@path` line, so after install copy the relevant one(s) out as bare lines (e.g. `@docs/BACKEND.md`) to load those patterns into session context.

- **`docs/FRONTEND.md`** — user-facing visual interfaces (web, mobile, desktop GUI, game UI). Covers navigation, state management, UI components, performance, input handling, platform differences.
- **`docs/BACKEND.md`** — API servers, background workers, data pipelines. Covers request boundaries, persistence, error handling and HTTP status codes, auth, middleware, observability, background jobs.
- **`docs/CLI.md`** — command-line tools and terminal utilities. Covers argv parsing, stdin/stdout/stderr discipline, exit codes, terminal output formatting, cross-platform concerns, signal handling.
- **`docs/MOBILE.md`** — native and cross-platform mobile apps (iOS, Android, React Native, Expo, Flutter, SwiftUI, Jetpack Compose). Covers the mobile-specific delta on top of `FRONTEND.md`: app lifecycle, permissions, native bridges, offline-first sync, local storage tiers, deep links, push notifications, device variety, release engineering. Import both `FRONTEND.md` and `MOBILE.md` for a mobile project.

A project that spans two types (e.g., a full-stack web app with a backend API and a React frontend) can keep both files and import both. A project that doesn't fit any of the four categories can delete all four and write its own.

### artifacts/

Work artifacts produced by the agents during `/agent-plan` and `/agent-code`, grouped by milestone: each milestone directory holds its definition README, architecture and UI specifications, reviews (security, performance, CEO, UX, validation, completion, retrospective), per-task files, and per-bug files. Cross-milestone state lives at the artifacts root. See `artifacts/README.md` for the full directory structure.

---

## Placeholders

Project-specific content in every template file is marked with `[UPPER_SNAKE_CASE]` tokens — things like `[PROJECT_NAME]`, `[LANGUAGE]`, `[FRAMEWORK]`, `[TEST_CMD]`. The `/cast-init` skill detects project values and substitutes them during install; any remaining unfilled tokens are reported in the adoption report for you to fill in by hand. The skill also strips the `<!-- TEMPLATE INSTRUCTIONS -->` comment blocks (repo documentation) from every file it installs — only the `templates/` skeletons keep theirs, since those blocks instruct the agents that instantiate them.

<details>
<summary><strong>Full placeholder reference</strong> (10 categories, 40+ tokens) — expand if you're populating files manually or writing a values file</summary>

### Identity

| Placeholder | Description | Example value |
|---|---|---|
| `[PROJECT_NAME]` | Human-readable name of the project | Acme Dashboard |
| `[PROJECT_TYPE]` | Category of software being built | mobile app, CLI tool, web service |
| `[ONE_SENTENCE_PITCH]` | Single sentence describing what the product does and for whom | A budgeting tool that helps freelancers track project income in real time |
| `[CAST_VERSION]` | CAST template version stamped into the installed `CLAUDE.md` (`Adopted with CAST v[CAST_VERSION]`). Auto-filled by `/cast-init` from its own version — never fill by hand | 1.3.0 |

### Tech

| Placeholder | Description | Example value |
|---|---|---|
| `[FRAMEWORK]` | Primary application framework | any client or server framework |
| `[FRAMEWORK_VERSION]` | Framework version | v14, SDK 52 |
| `[LANGUAGE]` | Primary programming language | any typed or untyped language |
| `[STATE_LIBRARY]` | Client-side or application-level state management library | any state management solution |
| `[PERSISTENCE_LAYER]` | Storage mechanism for application data | any database, file store, or cache |
| `[NAVIGATION_LIBRARY]` | Routing or navigation solution | React Router, GoRouter |
| `[TEST_RUNNER]` | Tool used to execute automated tests | any test runner or framework |
| `[PKG_MANAGER]` | Package or dependency manager | npm, pub, bundler |
| `[PKG_ADD_CMD]` | Command to add a new dependency | npm install, flutter pub add |
| `[PKG_MANIFEST]` | Package or dependency manifest file | package.json, pubspec.yaml |
| `[FRAMEWORK_CONFIG]` | Framework configuration file | app.json, next.config.js |
| `[TYPE_CONFIG]` | Type checker configuration file | tsconfig.json |
| `[EXT]` | File extension for source files | tsx, dart, rb |

### Commands

| Placeholder | Description | Example value |
|---|---|---|
| `[DEV_SERVER_CMD]` | Command to start the local development server | the project's start/watch command |
| `[TYPE_CHECK_CMD]` | Command to run the static type checker without emitting output | the project's type-check command |
| `[TEST_CMD]` | Command to execute the full test suite | the project's test command |
| `[TEST_COVERAGE_CMD]` | Command to run the test suite with coverage reporting — the coverage targets in `docs/TEST_FRAMEWORK.md` are measured against its output | the project's coverage command |
| `[BUILD_CMD]` | Command to produce a production build artifact | the project's build command |

### Domain

| Placeholder | Description | Example value |
|---|---|---|
| `[DOMAIN_ENTITY]` | The primary data object the application manages | order, patient record, task, asset |
| `[RESOURCE_TYPE]` | A secondary resource that belongs to or relates to the domain entity | line item, appointment, subtask, attachment |
| `[CORE_MECHANIC]` | The central user-facing action or loop in the application | placing a bid, scheduling a shift, publishing a report |
| `[PROGRESSION_UNIT]` | The measure of progress or achievement that users accumulate | points, completed milestones, unlocked tiers |

### Project Structure

| Placeholder | Description | Example value |
|---|---|---|
| `[LOGIC_DIR]` | Directory for pure business logic | src/game/, lib/domain/ |
| `[STORE_DIR]` | Directory for state management files | src/store/ |
| `[COMPONENTS_DIR]` | Directory for UI components | src/components/ |
| `[CONSTANTS_DIR]` | Directory for constants and configuration | src/constants/ |

### Conventions

| Placeholder | Description | Example value |
|---|---|---|
| `[LOWER_CASE_CONVENTION]` | Naming convention for variables, functions, and file names | camelCase, snake_case |
| `[PASCAL_CASE_CONVENTION]` | Naming convention for types, interfaces, and components | PascalCase |
| `[UPPER_SNAKE_CONVENTION]` | Naming convention for module-level constants | UPPER_SNAKE_CASE |

### Persistence

| Placeholder | Description | Example value |
|---|---|---|
| `[SAVE_KEY]` | Storage key for persisted data | my_app_data_v1 |

### Platform

| Placeholder | Description | Example value |
|---|---|---|
| `[TARGET_PLATFORMS]` | Comma-separated list of deployment targets | web, iOS, Android, desktop |
| `[PLATFORM_LIST]` | Comma-separated list of platforms the project supports — used by the bug report form's Platform field in `templates/BUG_REPORT.md` and the PRD's compatibility requirements | iOS, Android, Web |
| `[MIN_TOUCH_TARGET]` | Minimum interactive element size for touch interfaces | any size specification in platform units |

### Performance

| Placeholder | Description | Example value |
|---|---|---|
| `[STARTUP_METRIC]` | Maximum acceptable app startup time | 2s |
| `[TICK_INTERVAL_MS]` | Update loop tick interval in milliseconds — the cadence the core loop runs at in `docs/CODE_PATTERNS.md`; `[TICK_METRIC]` budgets each tick's duration | 100 |
| `[TICK_METRIC]` | Maximum acceptable update loop duration | 16ms |
| `[RENDER_METRIC]` | Maximum acceptable frame render time | 16ms |
| `[MEMORY_METRIC]` | Maximum acceptable memory usage | 200MB |

### Process

| Placeholder | Description | Example value |
|---|---|---|
| `[SESSION_TYPE]` | Type of user validation session | playtest, usability test, A/B test |
| `[MAX_LOOP_COUNT]` | Maximum Defect/Issue loop iterations in the engineering pipeline before escalating to the user (used in `refactor.md`; loop semantics in `docs/PIPELINE_LOOP.md`) | 3 |

### Agents

Each agent file has its model set in the YAML frontmatter — there is no `[AI_MODEL]` placeholder. Every agent defaults to `model: inherit`, running on whatever model the invoking session uses, and is optimized for the Claude Opus family (`claude-opus-5` is the preferred executing model; `claude-opus-4-8`, `claude-opus-4-7`, and `claude-opus-4-6` are supported); workload differentiation comes from the recommended reasoning effort stated in each agent's **Model Configuration** section rather than model tier. Edit the `model:` line in an individual agent file if you need an explicit pin, and see `docs/MODEL_OPTIMIZATION.md` for per-model behavior profiles and the upgrade checklists through Opus 4.8 → Opus 5.

**Right-size models at install time.** `inherit` is the safe default, but per-agent pins are the roster's main cost lever, and `/cast-init` proposes an assignment during adoption. A sensible split: keep the judgment-heavy gates (CEO, Architect, Reviewer, Risk) on the most capable model you have — e.g. `opus`, or a Fable/Mythos-class model if your account serves one; run Product, UI, and Coder on `sonnet`; and drop Docs Writer to `haiku`. Note the ordering, though: **spawn count dominates both model tier and effort**, and v3's roster is already right-sized in that dimension. Claude Code accepts the `opus` / `sonnet` / `haiku` aliases or full model IDs in agent frontmatter.

| Placeholder | Description | Example value |
|---|---|---|
| _(none — all per-agent models are set in YAML frontmatter)_ | | |

</details>

---

## Prerequisites

Before installing, confirm the following:

- **Claude Code CLI installed and authenticated.** This template is built for Claude Code specifically. The pipeline skills (`/agent-plan`, `/agent-code`) and subagent auto-discovery rely on Claude Code's `.claude/skills/` and `.claude/agents/` conventions. Other AI coding assistants do not read these files. Install and sign in to Claude Code before continuing.
- **A target project directory.** Either a new empty git repo or an existing project where you want to introduce the agent workflow. The template does not create the project for you.
- **An Anthropic account with access to the Claude Opus family.** All agents default to `model: inherit` and run on the session model; the Opus family is the optimized target (`claude-opus-5` preferred; `claude-opus-4-8`, `claude-opus-4-7`, and `claude-opus-4-6` are supported — all four share the same standard API pricing, though Opus 5's optional fast mode is priced separately and Opus 5 has its own rate-limit bucket). You can set the `model:` line in an individual agent file if you need an explicit pin — `docs/MODEL_OPTIMIZATION.md` covers the per-model behavior differences and upgrade paths.

## Known Limitations

A common source of confusion: this repo is a **template**, not a framework. Setting expectations clearly up front:

- **Agents are role definitions, not running processes.** The files in `agents/` describe what each agent is responsible for, what it accepts as input, and what it produces as output. Claude Code reads them as subagent definitions. There is no background daemon, no queue, and no automatic dispatching beyond what Claude Code itself does.
- **The pipeline skills are orchestration scripts written in Markdown.** `/agent-plan` and `/agent-code` tell Claude Code to invoke a specific sequence of subagents. They are not compiled, not executable, and not testable outside Claude Code. Reading them is reading their full behavior.
- **The workflow is Claude Code-specific.** Copilot CLI, Gemini CLI, Cursor, and other AI tools do not honor `.claude/agents/`. Porting the template to another tool requires manual adaptation — read each agent file as a prompt and invoke it however that tool supports role prompts. (The `SKILL.md` format itself is portable across a growing set of agents, but the subagent roster and orchestration are Claude Code conventions.)
- **No code is written by installing this template.** You get a directory layout, agent role files, pipeline skill definitions, document templates, and empty work-artifact scaffolding. Your first real output appears after you run `/agent-plan` on a feature.
- **Templates contain nested placeholders.** Some files (bug report forms, milestone validation records) include their own fill-in-per-use placeholders like `[DATE]`, `[MILESTONE_NAME]`, `[TASK_NAME]`. These are not bugs in your customization — they are deliberate sub-templates filled in each time the form is used.

Common problems you may hit during adoption or first use — a pipeline skill not recognized, subagent not delegating, `features/` references after upgrade, CEO returning REVISION REQUIRED — are covered in [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md). Skim it before filing a new issue.

## What a populated project looks like

Before installing, browse [`example/`](example/) to see exactly what a real populated instance of this template looks like. The example is a fixture based on "Acme Todo" — a small TypeScript CLI todo tracker — with one milestone planned and implemented end-to-end through `/agent-plan` and `/agent-code`. It shows:

- A fully substituted `CLAUDE.md` with no `[PLACEHOLDER]` tokens ([`example/CLAUDE.md`](example/CLAUDE.md))
- A populated PRD, concept, and glossary ([`example/docs/`](example/docs/))
- A complete planning run for Milestone 1, grouped in one milestone directory: milestone README, five per-task files with Context Manifests and Handoff Logs, architecture document, UI spec, security review, performance review, and CEO verdict ([`example/artifacts/`](example/artifacts/))
- The full engineering wrap-up for that milestone: completion and validation records, the UX review, the risk implementation review, and the retrospective
- An active bug tracker with one fixed bug and one Deferred (held-open) bug, and a session log following the canonical `STANDUP.md` entry grammar

The example deliberately omits `.claude/` (those files are unchanged copies of the template agents and pipeline skills) and `src/` (this is a planning fixture, not a real build). The start-here file is [`example/README.md`](example/README.md).

---

## Using with Claude Code

### Session Initialization

`CLAUDE.md` is automatically loaded from the project root at every session start. It provides the baseline context (project identity, build commands, conventions) that all agents need. Agent files in `.claude/agents/` are auto-discovered as subagents — no manual loading required.

### Agent Invocation

With agent files in `.claude/agents/`, Claude Code can invoke them in three ways:

1. **Automatic delegation** — Claude routes tasks to the matching subagent based on the `description` field in each agent's YAML frontmatter (e.g., asking "review this code" automatically delegates to the reviewer agent).
2. **Explicit request** — Ask Claude directly: "Use the coder agent to implement this feature" or "Have the security agent audit this module."
3. **Management** — Use the `/agents` command to view, create, and manage all available subagents.

### Agent Reference by Task Type

| Task | Agent |
|---|---|
| Define or update requirements | `product` |
| Design system architecture | `architect` |
| Design UI screens or components | `ui` |
| Audit for security or performance risk | `risk` |
| Final planning-stage review and sign-off | `ceo` |
| Implement features or fixes | `coder` |
| Write or run tests | `coder` (Coder writes and runs the tests for what it implements) |
| Review code quality | `reviewer` |
| Investigate a bug | `debugger` |
| Refactor code structure | `coder` (behavior-preserving restructuring is a Coder loop-back) |
| File a bug report | `bug-gatherer` |
| Update documentation | `docs-writer` |
| Prepare a release | `/cast-release` skill (not an agent) |


### Pipeline Skills

| Skill | Purpose |
|---|---|
| `/agent-plan <feature>` | Run the Planning Stage end-to-end. Product → Architecture + UI → Security + Performance → CEO. Produces planning documents and a CEO verdict. No code is written. **Light mode** (`/agent-plan light: <feature>`, or `single:` for the one-task case) plans a small feature with Product + Architecture + CEO only — same milestone layout, minimal ceremony. It also engages automatically when Stage 1 scoping finds 3 tasks or fewer, no new screen set, no security-sensitive scope, no applicable performance budget, and nothing cross-cutting; any one of those failing means the full run, and the per-task flags still pull a skipped stage back in. |
| `/agent-code <milestone-or-task>` | Run the Engineering Stage for a CEO-approved milestone. Coder (implement, test, commit) → Reviewer, with Defects filed by Reviewer and routed through Product triage, and Issues routed back to Coder — then validation. A clean task is two spawns. Reviewer's per-criterion Acceptance Criteria Check decides validation: all criteria Met and the orchestrator closes the task with no agent launch; a flagged criterion, a mid-task amendment, a CEO Approval Condition, or a resolved bug launches Product. The task checkpoint launches no agents — just the Status writeback, plus a `docs`-queue drain only once 10 entries are pending. When every task is Complete or Deferred, the milestone checkpoint runs Deferred re-triage, the completion and validation records (covering every task and verifying CEO Approval Conditions), the `docs` drain, the UX review (UI-flagged milestones), the risk implementation review (flagged milestones), the retrospective, and the orchestrator's outcome records and archival. |
| `/agent-task <task description>` | Run a mini engineering pipeline for a single one-off task without requiring a milestone or CEO verdict. Coder → Reviewer, with the same Defect/Issue routing as `/agent-code`. Use for bug fixes, typos, small refactors, and dependency bumps — NOT for new modules or cross-cutting changes (it bails out to `/agent-plan`, whose light mode covers the small-feature middle ground). |
| `/cast-doctor` (or `/cast-doctor checkup`) | Run a health check on the CAST install: verify structural and state invariants, prescribe model-aware documentation pruning (two tiers, gated on the Context Inference Bar in `docs/MODEL_OPTIMIZATION.md`), and find documentation coverage gaps. Writes `artifacts/DOCTOR.md`; treats only user-approved prescriptions. Run after model changes or every few milestones. |

### Inter-Agent Handoff

Agents communicate through shared documents. When one agent completes work, the next agent reads the updated files:

- **`artifacts/AGENT_STATE.md`** holds the cross-milestone record that is not a task file: the Decisions Log, milestone progress, the live performance-budget table, and open questions. **No agent reads it** — the orchestrating skill writes it at checkpoints. In v2 it was 506 lines of per-agent tables that every agent was told to read on activation, which contradicted the read-set rule the pipeline is built on.
- **`docs/PIPELINE_LOOP.md`** is the canonical engineering-loop contract (per-task sequence, Defect/Issue routing, loop-counter and test-gate rules) that both `/agent-code` and `/agent-task` execute.
- **`artifacts/STANDUP.md`** is the rolling session log with one canonical Entry Grammar: each run opens a `### YYYY-MM-DD — <skill> — <milestone/task>` session heading, and every entry under it is a `- <agent> | <type> | <note>` line. Any agent with documentation fallout appends a `- <agent> | docs | <note>` entry; Docs Writer drains those entries (marking them ✅) at the milestone-completion checkpoint, at an overflow drain once 10 are pending, and at the `/agent-task` completion checkpoint.
- **`artifacts/BUGS.md`** is the global bug index — every bug lives in its own file beside the work that surfaced it (`milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md`), with one status line in the index (Reviewer files, Product triages, Coder investigates and fixes). Deferred is a held-open state, not a terminal one — the terminal states are Closed, Won't Fix, Duplicate, and Cannot Reproduce — and Product re-triages every Deferred item at milestone completion and at the next `/agent-plan` Stage 1.
- **Planning architecture documents** at `artifacts/milestone-{N}-{slug}/architecture.md` are the contract between Architect and Coder for a specific milestone — reaching engineering agents through each task file's Context Manifest, which cites the exact sections a task needs. Templates live at `templates/ARCH_MODULE.md`, `templates/ARCH_SYSTEM.md`, and `templates/ARCH_DATA_SCHEMA.md`.
- **Planning UI specifications** at `artifacts/milestone-{N}-{slug}/ui.md` are the contract between UI and Coder. Template lives at `templates/UI_SPEC.md`. Produced only when the `ui` agent is installed — a backend/CLI project that opted out of `ui` runs both pipelines without a UI spec, and `/agent-code` does not demand one.
- **CEO planning verdicts** at `artifacts/milestone-{N}-{slug}/reviews/ceo.md` gate entry into the engineering stage via a single `**Verdict**: <APPROVED | APPROVED WITH CONDITIONS | REVISION REQUIRED>` line that `/agent-code` Pre-Flight parses; on APPROVED WITH CONDITIONS the conditions are backfilled into the milestone README's CEO Approval Conditions table and referenced from the affected task files' Context Manifests. Template lives at `templates/CEO_REVIEW.md`.
- **Milestone-completion records**: Product writes the completion record (Status `Complete`, or `Complete with Deferrals` when Deferred items survive re-triage) and the validation record, UI writes the UX review for UI-flagged milestones, and Product writes the retrospective — all under the milestone's `reviews/` directory (templates `MILESTONE_COMPLETION.md`, `MILESTONE_VALIDATION.md`, `UX_REVIEW.md`, and `MILESTONE_RETROSPECTIVE.md`).

### Minimum Viable Agent Set

The required roster depends on which pipeline skills you keep. Prune from the bottom up.

**Tier 1 — Always required (the core loop):**
- **Product** — scope: acceptance criteria, bug triage, validation
- **Coder** — implementation, its tests, and every loop-back
- **Reviewer** — the independent gate: test-results verification, diff review, Defect/Issue classification, the Acceptance Criteria Check

These three run `/agent-task` on their own. There is no separate Tier for it in v3 — the Defect/Issue routing targets that v2 needed (Bug Gatherer, Debugger, Refactor) are now duties of Reviewer and Coder, so Reviewer's hand-offs cannot dead-end.

**Tier 2 — Strongly recommended for any serious project:**
- **Architect** — for projects with multiple modules or non-trivial structure
- **Docs Writer** — for projects that maintain documentation

**Tier 3 — Required for `/agent-plan` and `/agent-code`:**

The planning pipeline hard-wires a flow ending at a CEO sign-off. Keeping either skill means keeping all three on top of Tiers 1–2:
- **UI** — produces the UI specification during planning
- **Risk** — reviews the architecture through the security and performance lenses, and sets the two implementation-review flags `/agent-code` reads at milestone completion
- **CEO** — the planning gate. `/agent-plan` has no meaning without it; `/agent-code` pre-flight reads its verdict file before any task runs.

If you do not want a CEO planning gate, **delete `/agent-plan`, `/agent-code`, and `ceo.md` together** — they are a unit. `/agent-task` remains functional on its own and reads no verdict. Keeping `/agent-plan` or `/agent-code` while deleting the CEO agent produces a broken pipeline.

### Optional based on project type

One conditional opt-out: **UI** becomes optional for backend/CLI-only projects with no user interface. The opt-out is explicit during `/cast-init` (the UI templates are skipped with the agent), `/agent-plan` then skips its UI stage, and `/agent-code` does not require a UI spec when no `ui` agent is installed.

Every other agent is installed by default. **Release is not on this list** — it is a skill (`/cast-release`), not an agent, so there is nothing to opt out of.

---

## File Listing

<details>
<summary><strong>Every file in the template with a one-line description</strong> — expand if you need a map</summary>

All payload paths below are relative to `skills/cast-init/assets/` in this repo.

### Skill and plugin machinery

| File | Description |
|---|---|
| `skills/cast-init/SKILL.md` | The `/cast-init` adoption workflow: seven phases from discovery to the final report |
| `skills/cast-init/references/discovery.md` | Phase 1 checklists and the adoption-inventory template |
| `skills/cast-init/references/roster.md` | Canonical 15-agent roster, tiers, alias tables, and the pipeline-skills mapping |
| `skills/cast-init/references/dispositions.md` | Per-file disposition tables for docs/templates/artifacts/root and the plan-file format |
| `skills/cast-init/references/execution.md` | Phase 5 install mechanics and customization-preservation rules |
| `skills/cast-init/references/validation.md` | Phase 6 validation checklist and the Phase 7 report template |
| `.claude-plugin/plugin.json` | Plugin manifest (name `cast`, version, the cast-init skill) |
| `.claude-plugin/marketplace.json` | Marketplace manifest enabling `/plugin marketplace add Raxvis/CAST` |

### root/ (1 file)

| File | Description |
|---|---|
| `root/CLAUDE.md` | Top-level context file read first by every agent; defines project identity, structure, conventions, and run commands |

### agents/ → `.claude/agents/` (15 agents + README)

> **Note:** `agents/README.md` is metadata about the directory. It should NOT be copied to `.claude/agents/` in the target project — Claude Code would try to register it as a subagent.

| File | Description |
|---|---|
| `agents/product.md` | Defines the product agent; owns scope — milestone definition, task files, bug triage, validation, and the completion/validation/retrospective records |
| `agents/architect.md` | Defines the system design agent; owns module boundaries, data schemas, contracts, and the performance budget |
| `agents/ui.md` | Defines the UI agent; owns visual design, layout, interaction states, accessibility, and the milestone UX review |
| `agents/risk.md` | Defines the risk agent; reviews an architecture through the security and performance lenses in one pass and sets the two implementation-review flags |
| `agents/ceo.md` | Defines the CEO agent; the planning gate — reads across every artifact for what falls between the specialists and issues the verdict |
| `agents/coder.md` | Defines the implementation agent; writes production code and its tests, commits, and handles every loop-back (defect fixes, Issue restructuring, criteria rejections) |
| `agents/reviewer.md` | Defines the review agent; the independent gate — verifies the test-results block, reviews the diff, classifies findings as Defects (filing each as a bug file) or Issues, and records the Acceptance Criteria Check |
| `agents/docs-writer.md` | Defines the documentation agent; drains the `docs:` queue at the milestone-completion checkpoint, at an overflow drain, and at the `/agent-task` checkpoint |
| `agents/README.md` | Master overview of the agent system: roster, interaction diagram, planning and engineering stage workflows, and placeholder reference |

### skills/ → `.claude/skills/` (4 skills + README)

> **Note:** `skills/README.md` is metadata about the directory. It is NOT installed to the target project.

| File | Description |
|---|---|
| `skills/agent-plan/SKILL.md` | Defines the `/agent-plan` pipeline skill; orchestrates the Planning Stage end-to-end (Product → Architecture + UI → Security + Performance → CEO) |
| `skills/agent-code/SKILL.md` | Defines the `/agent-code` pipeline skill; orchestrates the Engineering Stage per task (Coder → Reviewer, with Defects through Product triage and Issues back to Coder) |
| `skills/cast-release/SKILL.md` | Defines the `/cast-release` skill; verifies the release gates, derives the version, updates `docs/CHANGELOG.md`, and issues a GO/NO-GO. Runs in-session, launches no agents |
| `skills/agent-task/SKILL.md` | Defines the `/agent-task` pipeline skill; runs a mini engineering pipeline (Coder → Reviewer → validation) for a single one-off task without requiring a milestone or CEO verdict |
| `skills/cast-doctor/SKILL.md` | Defines the `/cast-doctor` maintenance skill; run-anytime install health check — state invariants, two-tier model-gated documentation diet (Context Inference Bar in `docs/MODEL_OPTIMIZATION.md`), and documentation coverage gaps. Writes `artifacts/DOCTOR.md` |

### docs/ (reference material, 21 files)

Reference documentation. Never holds work artifacts. Document templates live in `templates/` (below).

| File | Description |
|---|---|
| `docs/README.md` | Documentation index; master navigation entry point for all project documentation |
| `docs/PRD.md` | Product Requirements Document skeleton; describes goals, user stories, and acceptance criteria for the current scope. Not auto-installed — `/cast-init` prompts for it, since a PRD is user content |
| `docs/CONCEPT.md` | High-level project vision, core loop, and design pillars |
| `docs/ADDITIONAL.md` | Supplementary context that does not fit the primary documents; captures edge cases and open questions |
| `docs/GLOSSARY.md` | Canonical definitions for all domain-specific terms used across documents |
| `docs/DESIGN_RATIONALE.md` | Decision log recording significant design choices and their trade-offs |
| `docs/CODE_PATTERNS.md` | Coding conventions, naming rules, module structure, and state management patterns |
| `docs/FILE_CONVENTIONS.md` | File naming rules, directory layout expectations, and `docs/` vs `artifacts/` split |
| `docs/ERROR_HANDLING.md` | Guidelines for handling errors across all categories; defines principles, patterns, and user-facing message standards |
| `docs/TEST_FRAMEWORK.md` | Testing strategy, test runner setup, file conventions, and coverage requirements |
| `docs/MODEL_OPTIMIZATION.md` | Model policy for the agent roster: the Claude Opus ladder (Opus 5 preferred), per-model behavior profiles, and the upgrade checklists through Opus 4.8 → Opus 5 |
| `docs/PIPELINE_LOOP.md` | The canonical engineering-loop contract executed by both `/agent-code` and `/agent-task`: per-task sequence, Defect/Issue routing, loop-counter rules, test gate, targeted re-runs, pass-forward rule |
| `docs/FIRST_RUN.md` | Interactive checklist to run in Claude Code after a fresh install; verifies that subagents load and pipeline skills register |
| `docs/CLAUDE_CODE_SETTINGS.md` | Reference for `.claude/settings.json` — explains permission rules, environment variables, and hooks, with common extension patterns |
| `docs/FRONTEND.md` | Topic-specific reference for frontend projects; delete if not applicable |
| `docs/BACKEND.md` | Topic-specific reference for API servers, workers, and pipelines; delete if not applicable |
| `docs/CLI.md` | Topic-specific reference for command-line tools; delete if not applicable |
| `docs/MOBILE.md` | Topic-specific reference for native and cross-platform mobile apps (iOS, Android, React Native, Expo, Flutter, SwiftUI, Jetpack Compose). Pair with `docs/FRONTEND.md` for mobile projects; delete if not applicable |
| `docs/CHANGELOG.md` | Chronological log of notable changes across releases and milestones, maintained by the release agent |
| `docs/ASSETS.md` | Registry of all project assets (images, fonts, etc.) with status and source information |
| `docs/MVP_LAUNCH.md` | Checklist and criteria for the initial public release |

### templates/ (document templates, 12 files)

Reusable document skeletons. Agents copy them — never fill in place — to produce instances under `artifacts/`. See [`templates/README.md`](skills/cast-init/assets/templates/README.md).

| File | Description |
|---|---|
| `templates/MILESTONE_DEFINITION.md` | Template for the milestone README — the milestone's highest-order document: goal, success metrics, in/out of scope, top-level acceptance criteria, Task Index, CEO Approval Conditions. Instance at `artifacts/milestone-{N}-{slug}/README.md`. |
| `templates/TASK.md` | Template for a single task file — the isolated unit of work: description, dependencies, acceptance criteria, Context Manifest (the task's complete read set), and Handoff Log (the fixed-format record every stage appends). One instance per task at `artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md` (or `artifacts/one-off/` for `/agent-task`). |
| `templates/BUG_REPORT.md` | Template for a single bug file. One instance per bug at `artifacts/milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md` (or `artifacts/one-off/bugs/`), indexed in `artifacts/BUGS.md`. |
| `templates/MILESTONE_VALIDATION.md` | Template for milestone validation / acceptance records. Instance at `artifacts/milestone-{N}-{slug}/reviews/validation.md`. |
| `templates/MILESTONE_COMPLETION.md` | Template for milestone completion reports. Instance at `artifacts/milestone-{N}-{slug}/reviews/completion.md`. |
| `templates/ARCH_MODULE.md` | Template for documenting a single code module (instances at `artifacts/milestone-{N}-{slug}/arch-{slug}.md`) |
| `templates/ARCH_SYSTEM.md` | Template for documenting a high-level system (the milestone `architecture.md` is an instance) |
| `templates/ARCH_DATA_SCHEMA.md` | Template for documenting a data schema or save format (instances at `artifacts/milestone-{N}-{slug}/arch-{slug}.md`) |
| `templates/UI_SPEC.md` | Template for specifying a UI screen or component (the milestone `ui.md` is an instance; supplemental specs at `ui-{slug}.md`) |
| `templates/CEO_REVIEW.md` | Template for the CEO planning verdict: the six mandated inputs, the review checklist, and the APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED verdict block. Instance at `artifacts/milestone-{N}-{slug}/reviews/ceo.md`. |
| `templates/UX_REVIEW.md` | Template for UI's UX review of an implemented milestone (instance at `artifacts/milestone-{N}-{slug}/reviews/ux.md`) |
| `templates/MILESTONE_RETROSPECTIVE.md` | Template for Product's end-of-milestone retrospective: what went well, what didn't, process issues, metrics, and improvement actions. Instance at `artifacts/milestone-{N}-{slug}/reviews/retrospective.md`. |

### artifacts/ (work artifacts)

Live work artifacts produced by the agents. Copied as a seed into the target project so the expected structure is in place from day one.

| Path | Description |
|---|---|
| `artifacts/README.md` | Explains the `docs/` vs `artifacts/` split and lists the subdirectory layout |
| `artifacts/AGENT_STATE.md` | Live working state for all 15 agents (Current Work tables, decision logs, validator dashboards), one section per agent — the mutable counterpart to the immutable agent definition files |
| `artifacts/BUGS.md` | Global bug index — one line per bug pointing at its per-bug file. Carries the canonical lifecycle and field-ownership rules |
| `artifacts/STANDUP.md` | Rolling log of progress updates, blockers, and decisions from work sessions |
| `artifacts/milestone-{N}-{slug}/` | One directory per milestone: `README.md` (definition, Task Index, CEO conditions), `architecture.md`, `ui.md`, `reviews/` (security, performance, CEO, UX, validation, completion, retrospective), `tasks/` (one file per task), `bugs/` (one file per bug) |
| `artifacts/one-off/` | `/agent-task` work: one-off task files and their bug files |

</details>

---

## License and contributing

CAST is [MIT-licensed](LICENSE) Markdown — every agent definition, pipeline skill, and document template is plain text you can fork, edit, and republish. If you find a rough edge, open an issue or a pull request on [`Raxvis/CAST`](https://github.com/Raxvis/CAST).

Significant changes must bump the template version in **four synchronized locations** and ship an annotated git tag plus a GitHub Release at the same push. The full policy is in [`CLAUDE.md`](CLAUDE.md) → Release and Tagging Policy. Short version:

1. `README.md` — the version badge and the `Current template version` hero line
2. `CHANGELOG.md` — a new version entry following the existing format
3. `.claude-plugin/plugin.json` — the `version` field
4. `skills/cast-init/SKILL.md` — the `metadata.version` frontmatter field

All four land in the same commit, with the message starting `Release v<new>:`. On push to `main`, [`release.yml`](.github/workflows/release.yml) does the rest automatically: it verifies the four locations agree, creates the annotated `v<new>` tag, and publishes the GitHub Release with notes extracted from the top `CHANGELOG.md` entry. After pushing, confirm with `gh release view v<new>`. Tag and Release by hand (`git tag -a` + `gh release create`, per the CLAUDE.md checklist) only if the workflow is unavailable.
