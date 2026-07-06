<!-- TEMPLATE INSTRUCTIONS
  This file is the master index for the CAST repo. It describes the purpose,
  structure, placeholder conventions, and file inventory for every template file
  in this repository. It is never installed into target projects — adoption is
  performed by the /cast-init skill, which substitutes [PLACEHOLDER_NAME] tokens
  and strips TEMPLATE INSTRUCTIONS blocks from the files it installs.
-->

# CAST — Claude Agent Staged Team

> **A multi-agent workflow template for Claude Code.** Fifteen specialist subagents, three pipeline skills, and a CEO-gated planning pipeline — shipped as plain Markdown via a single `/cast-init` skill, no framework to install, no runtime to maintain.

![Template version](https://img.shields.io/badge/template-v1.2.2-blue)
![Claude Code](https://img.shields.io/badge/Claude_Code-required-9cf)
![Agents](https://img.shields.io/badge/agents-15-orange)

CAST gives you a real team structure with clear handoffs, typed artifacts, and a review gate you can't accidentally skip. The name is a double pun: a *cast* is a group of specialists each playing a defined role, and the pipeline runs in *stages* — planning (Product → Architecture + UI → Security + Performance → CEO sign-off) followed by engineering (Coder → Tester → Reviewer, with defect and issue routing).

```text
Planning stage — /agent-plan

    feature request
          │
          ▼
    Product  →  Architecture + UI  →  Security + Performance  →  CEO verdict
                                                                      │
                                                                      ▼
                                                         APPROVED (with conditions)


Engineering stage — /agent-code

    Coder  →  Tester  →  Reviewer  ──┬──  Defect  →  Bug Gatherer  →  Product  →  Debugger  →  Coder
                                     │
                                     └──  Issue   →  Refactor  →  Tester  →  Reviewer (loop)
                                                                      │
                                                                      ▼
                                                                    Product
                                                                   validates
                                                                      │
                                                                      ▼
                                                                     done


One-off task — /agent-task  (no planning stage, for small self-contained changes)

    Coder  →  Tester  →  Reviewer  →  Product   (same Defect / Issue routing)
```

**What you get out of the box:**

- **15 specialist subagents** pinned to `claude-opus-4-8`, with per-agent recommended reasoning effort matched to the workload (planning and engineering at high/xhigh, utility at low).
- **Three pipeline skills** — `/agent-plan`, `/agent-code`, `/agent-task` — as plain Markdown orchestration scripts Claude Code discovers at session start.
- **A hard `docs/` / `templates/` / `artifacts/` split** — `docs/` holds reference material (requirements, conventions), `templates/` holds reusable document skeletons, and `artifacts/` holds live work (plans, reviews, bugs, session logs). The CEO gate, placeholder check, and smoke test all enforce the split.
- **A fully populated `example/` fixture** so you can see exactly what a real planning run produces.
- **An agnostic `CLAUDE.md`** with opt-in topic docs (`docs/FRONTEND.md`, `docs/BACKEND.md`, `docs/CLI.md`, `docs/MOBILE.md`) for project-type-specific patterns.

Current template version: `v1.2.2` — see [`CHANGELOG.md`](CHANGELOG.md) for the version history and migration notes.

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

1. Walk through [`docs/FIRST_RUN.md`](skills/cast-init/assets/docs/FIRST_RUN.md) (installed to your project's `docs/`) for the interactive checklist (`/agents`, `/agent-plan` dry run, optional per-agent smoke probes).
2. Commit the populated template as your first commit.

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
        artifacts/       #   Work artifact scaffold: agent state, bug tracker, session log
  example/               # Populated fixture: a full "Acme Todo" project walkthrough
```

### The `docs/` / `templates/` / `artifacts/` split

This template enforces a strict separation between **reference material**, **document templates**, and **work artifacts**:

- **`docs/` is documentation only.** It holds things that describe how the project works: the PRD, concept, glossary, coding conventions, file placement rules, error handling standards, testing strategy, and design rationale. `docs/` must never contain feature plans, milestone instances, bug reports, CEO reviews, or progress logs.
- **`templates/` is document templates only.** It holds the reusable skeletons for architecture docs, UI specs, and milestone files. Agents copy them — never fill them in place — to produce instances under `artifacts/`.
- **`artifacts/` is work artifacts only.** It holds instances of work: milestone definitions produced by the Product agent, architecture documents produced by the Architect agent for a specific milestone, UI specs produced by the UI agent, security and performance reviews, CEO planning verdicts, bug reports, and the rolling session log.

If you are unsure where a file belongs, ask: _"Is this a reusable template, other reference material, or a specific piece of work?"_ Template → `templates/`. Other reference → `docs/`. Work → `artifacts/`. Both `/agent-plan` and `/agent-code` write exclusively to `artifacts/`; neither pipeline should ever modify `docs/` or `templates/`.

All the payload directories described below live under `skills/cast-init/assets/` in this repo; the headings use their short names because that is where they land in a target project.

### skills/cast-init/

The `/cast-init` skill itself: `SKILL.md` carries the seven-phase adoption workflow (discovery → classification → migration plan → approval gate → execution → validation → report), `references/` holds the detailed phase documentation it loads on demand, and `assets/` holds the entire installable payload described below.

### root/

Contains the `CLAUDE.md` template that is copied to the root of the target project. This file defines project identity, structure, conventions, and run commands — the top-level context that every agent reads first.

### agents/

Each file defines one agent role with YAML frontmatter for Claude Code auto-discovery. When installed to `.claude/agents/` in the target project, Claude Code automatically registers them as subagents that can be invoked by name or delegated to automatically based on task type. Files that do not apply to your project type can be deleted without affecting the others.

### skills/ (pipeline skills)

Each subdirectory defines one pipeline skill that orchestrates a multi-agent workflow stage end-to-end. When installed to `.claude/skills/` in the target project, Claude Code registers them as skills named after the directory (e.g. `agent-plan/SKILL.md` becomes `/agent-plan`). Three pipelines ship with this template: `/agent-plan` runs the Planning Stage (Product → Architecture + UI → Security + Performance → CEO), `/agent-code` runs the Engineering Stage (Coder → Tester → Reviewer, with defects to Bug Gatherer → Product → Debugger and issues to Refactor → Tester → Reviewer), and `/agent-task` runs a mini engineering pipeline (Coder → Tester → Reviewer → Product) for a single one-off task without requiring a milestone, planning artifacts, or a CEO verdict — use it for bug fixes, typos, small refactors, and dependency bumps, not for new modules or cross-cutting changes.

### docs/

Reference material only. These are not agent definitions and not work artifacts — they are shared knowledge that multiple agents and human contributors reference: domain rules, quality standards, coding conventions, and reusable document templates. Agents must read from `docs/` but must not write work artifacts to `docs/`.

**Topic-specific reference docs.** Four files in `docs/` are scoped to a project type rather than being universal: `FRONTEND.md`, `BACKEND.md`, `CLI.md`, and `MOBILE.md`. Keep the one(s) that match your project and delete the rest. The shipped `root/CLAUDE.md` is agnostic and has commented `@import` lines for all four — uncomment the relevant line(s) after install so the right patterns get loaded into session context.

- **`docs/FRONTEND.md`** — user-facing visual interfaces (web, mobile, desktop GUI, game UI). Covers navigation, state management, UI components, performance, input handling, platform differences.
- **`docs/BACKEND.md`** — API servers, background workers, data pipelines. Covers request boundaries, persistence, error handling and HTTP status codes, auth, middleware, observability, background jobs.
- **`docs/CLI.md`** — command-line tools and terminal utilities. Covers argv parsing, stdin/stdout/stderr discipline, exit codes, terminal output formatting, cross-platform concerns, signal handling.
- **`docs/MOBILE.md`** — native and cross-platform mobile apps (iOS, Android, React Native, Expo, Flutter, SwiftUI, Jetpack Compose). Covers the mobile-specific delta on top of `FRONTEND.md`: app lifecycle, permissions, native bridges, offline-first sync, local storage tiers, deep links, push notifications, device variety, release engineering. Import both `FRONTEND.md` and `MOBILE.md` for a mobile project.

A project that spans two types (e.g., a full-stack web app with a backend API and a React frontend) can keep both files and import both. A project that doesn't fit any of the four categories can delete all four and write its own.

### artifacts/

Work artifacts produced by the agents during `/agent-plan` and `/agent-code`: milestone definitions, milestone-specific architecture and UI specifications, security and performance reviews, CEO planning verdicts, bug reports, milestone completion records, and the rolling session log. See `artifacts/README.md` for the full directory structure.

---

## Placeholders

Project-specific content in every template file is marked with `[UPPER_SNAKE_CASE]` tokens — things like `[PROJECT_NAME]`, `[LANGUAGE]`, `[FRAMEWORK]`, `[TEST_CMD]`. The `/cast-init` skill detects project values and substitutes them during install; any remaining unfilled tokens are reported in the adoption report for you to fill in by hand. The skill also strips the `<!-- TEMPLATE INSTRUCTIONS -->` comment blocks (repo documentation) from every file it installs — only the `templates/` skeletons keep theirs, since those blocks instruct the agents that instantiate them.

<details>
<summary><strong>Full placeholder reference</strong> (12 categories, ~60 tokens) — expand if you're populating files manually or writing a values file</summary>

### Identity

| Placeholder | Description | Example value |
|---|---|---|
| `[PROJECT_NAME]` | Human-readable name of the project | Acme Dashboard |
| `[PROJECT_TYPE]` | Category of software being built | mobile app, CLI tool, web service |
| `[ONE_SENTENCE_PITCH]` | Single sentence describing what the product does and for whom | A budgeting tool that helps freelancers track project income in real time |

### Tech

| Placeholder | Description | Example value |
|---|---|---|
| `[FRAMEWORK]` | Primary application framework | any client or server framework |
| `[FRAMEWORK_VERSION]` | Framework version | v14, SDK 52 |
| `[LANGUAGE]` | Primary programming language | any typed or untyped language |
| `[STATE_LIBRARY]` | Client-side or application-level state management library | any state management solution |
| `[STATE_LIBRARY_VERSION]` | Version of the state management library | 4.x, 2.0 |
| `[PERSISTENCE_LAYER]` | Storage mechanism for application data | any database, file store, or cache |
| `[NAVIGATION_LIBRARY]` | Routing or navigation solution | React Router, GoRouter |
| `[TEST_RUNNER]` | Tool used to execute automated tests | any test runner or framework |
| `[PKG_MANAGER]` | Package or dependency manager | npm, pub, bundler |
| `[PKG_ADD_CMD]` | Command to add a new dependency | npm install, flutter pub add |
| `[PKG_MANIFEST]` | Package or dependency manifest file | package.json, pubspec.yaml |
| `[FRAMEWORK_CONFIG]` | Framework configuration file | app.json, next.config.js |
| `[TYPE_CONFIG]` | Type checker configuration file | tsconfig.json |
| `[BUNDLER_CONFIG]` | Bundler or build configuration file | metro.config.js, webpack.config.js |
| `[EXT]` | File extension for source files | tsx, dart, rb |

### Commands

| Placeholder | Description | Example value |
|---|---|---|
| `[DEV_SERVER_CMD]` | Command to start the local development server | the project's start/watch command |
| `[TYPE_CHECK_CMD]` | Command to run the static type checker without emitting output | the project's type-check command |
| `[TEST_CMD]` | Command to execute the full test suite | the project's test command |
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
| `[SCREEN_DIR]` | Directory where screen or page files live | app/, pages/ |
| `[LOGIC_DIR]` | Directory for pure business logic | src/game/, lib/domain/ |
| `[STORE_DIR]` | Directory for state management files | src/store/ |
| `[COMPONENTS_DIR]` | Directory for UI components | src/components/ |
| `[HOOKS_DIR]` | Directory for reusable hooks or providers | src/hooks/ |
| `[CONSTANTS_DIR]` | Directory for constants and configuration | src/constants/ |
| `[ASSETS_DIR]` | Directory for static assets | assets/ |
| `[MAIN_SCREEN]` | Core feature screen file name | game, dashboard |

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
| `[SAVE_VERSION]` | Current save format version number | 1 |

### Platform

| Placeholder | Description | Example value |
|---|---|---|
| `[TARGET_PLATFORMS]` | Comma-separated list of deployment targets | web, iOS, Android, desktop |
| `[PLATFORM_1]` | Primary target platform name | iOS |
| `[PLATFORM_2]` | Secondary target platform name | Android |
| `[TARGET_PLATFORM_1]` | First platform for Build & Test instructions | iOS simulator |
| `[TARGET_PLATFORM_2]` | Second platform for Build & Test instructions | Android emulator |
| `[TARGET_PLATFORM_3]` | Third platform for Build & Test instructions | web browser |
| `[INPUT_METHOD]` | Primary input method | touch, mouse, keyboard |
| `[MIN_TOUCH_TARGET]` | Minimum interactive element size for touch interfaces | any size specification in platform units |
| `[THEME_FILE_PATH]` | Relative path from the project root to the theme or design-token file | path to the project's theme constants |
| `[OTHER_DEP_1]` | Additional project dependency | any package name |
| `[OTHER_DEP_2]` | Additional project dependency | any package name |

### Testing

| Placeholder | Description | Example value |
|---|---|---|
| `[COVERAGE_TARGET]` | Minimum code coverage percentage threshold | 80% |
| `[BRANCH_TARGET]` | Minimum branch coverage percentage threshold | 80% |

### Performance

| Placeholder | Description | Example value |
|---|---|---|
| `[STARTUP_METRIC]` | Maximum acceptable app startup time | 2s |
| `[TICK_METRIC]` | Maximum acceptable update loop duration | 16ms |
| `[RENDER_METRIC]` | Maximum acceptable frame render time | 16ms |
| `[MEMORY_METRIC]` | Maximum acceptable memory usage | 200MB |
| `[STORAGE_METRIC]` | Maximum acceptable local storage usage | 50MB |

### Process

| Placeholder | Description | Example value |
|---|---|---|
| `[SESSION_TYPE]` | Type of user validation session | playtest, usability test, A/B test |
| `[MAX_AGE_DAYS]` | Maximum age in days before a task is flagged stale | 14 |
| `[MAX_BLOCKED_DAYS]` | Maximum days a task can remain blocked before escalation | 7 |
| `[CRITICAL_BLOCKED_DAYS]` | Maximum days a critical task can remain blocked | 3 |

### Agents

Each agent file has its model hard-coded in the YAML frontmatter — there is no `[AI_MODEL]` placeholder. Every agent is pinned to `claude-opus-4-8` and optimized for the Claude Opus 4.x family (`claude-opus-4-7` and `claude-opus-4-6` are supported executing models); workload differentiation comes from the recommended reasoning effort stated in each agent's **Model Configuration** section rather than model tier. Edit the `model:` line in an individual agent file if you need to override, and see `docs/MODEL_OPTIMIZATION.md` for per-model behavior profiles and the 4.6 → 4.7 → 4.8 upgrade checklists.

| Placeholder | Description | Example value |
|---|---|---|
| _(none — all per-agent models are set in YAML frontmatter)_ | | |

</details>

---

## Prerequisites

Before installing, confirm the following:

- **Claude Code CLI installed and authenticated.** This template is built for Claude Code specifically. The pipeline skills (`/agent-plan`, `/agent-code`) and subagent auto-discovery rely on Claude Code's `.claude/skills/` and `.claude/agents/` conventions. Other AI coding assistants do not read these files. Install and sign in to Claude Code before continuing.
- **A target project directory.** Either a new empty git repo or an existing project where you want to introduce the agent workflow. The template does not create the project for you.
- **An Anthropic account with access to the Claude Opus 4.x family.** All agents are pinned to `claude-opus-4-8` by default; `claude-opus-4-7` and `claude-opus-4-6` are supported alternatives (all three are priced identically). You can override the `model:` line in an individual agent file if you need a different pin — `docs/MODEL_OPTIMIZATION.md` covers the per-model behavior differences and upgrade paths.

## Known Limitations

A common source of confusion: this repo is a **template**, not a framework. Setting expectations clearly up front:

- **Agents are role definitions, not running processes.** The files in `agents/` describe what each agent is responsible for, what it accepts as input, and what it produces as output. Claude Code reads them as subagent definitions. There is no background daemon, no queue, and no automatic dispatching beyond what Claude Code itself does.
- **The pipeline skills are orchestration scripts written in Markdown.** `/agent-plan` and `/agent-code` tell Claude Code to invoke a specific sequence of subagents. They are not compiled, not executable, and not testable outside Claude Code. Reading them is reading their full behavior.
- **The workflow is Claude Code-specific.** Copilot CLI, Gemini CLI, Cursor, and other AI tools do not honor `.claude/agents/`. Porting the template to another tool requires manual adaptation — read each agent file as a prompt and invoke it however that tool supports role prompts. (The `SKILL.md` format itself is portable across a growing set of agents, but the subagent roster and orchestration are Claude Code conventions.)
- **No code is written by installing this template.** You get a directory layout, agent role files, pipeline skill definitions, document templates, and empty work-artifact scaffolding. Your first real output appears after you run `/agent-plan` on a feature.
- **Templates contain nested placeholders.** Some files (bug report forms, milestone validation records) include their own fill-in-per-use placeholders like `[DATE]`, `[REPRODUCTION_STEPS]`, `[TASK_NAME]`. These are not bugs in your customization — they are deliberate sub-templates filled in each time the form is used.

Common problems you may hit during adoption or first use — a pipeline skill not recognized, subagent not delegating, `features/` references after upgrade, CEO returning REVISION REQUIRED — are covered in [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md). Skim it before filing a new issue.

## What a populated project looks like

Before installing, browse [`example/`](example/) to see exactly what a real populated instance of this template looks like. The example is a fixture based on "Acme Todo" — a small TypeScript CLI todo tracker — with one milestone planned and implemented end-to-end through `/agent-plan` and `/agent-code`. It shows:

- A fully substituted `CLAUDE.md` with no `[PLACEHOLDER]` tokens ([`example/CLAUDE.md`](example/CLAUDE.md))
- A populated PRD, concept, and glossary ([`example/docs/`](example/docs/))
- A complete planning run for Milestone 1: milestone definition, task breakdown, architecture document, UI spec, security review, performance review, and CEO verdict ([`example/artifacts/`](example/artifacts/))
- A milestone completion report, an active bug tracker with one fixed bug and one open deferred bug, and a three-day session log

The example deliberately omits `.claude/` (those files are unchanged copies of the template agents and pipeline skills) and `src/` (this is a planning fixture, not a real build). The start-here file is [`example/README.md`](example/README.md).

---

## Quick Start

1. In your target project: `npx skills add Raxvis/CAST` (or `/plugin marketplace add Raxvis/CAST` + `/plugin install cast@cast`).
2. Open (or restart) Claude Code inside the project directory.
3. Run: `/cast-init`
4. Claude crawls your project, proposes a migration plan, and waits for your approval.
5. After approval, Claude installs agents, pipeline skills, docs, artifacts, and `CLAUDE.md` — substituting detected project values.
6. Restart the session, then walk through your project's `docs/FIRST_RUN.md` to verify everything loaded correctly.
7. Commit the populated template as your first commit.

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
| Audit for security issues | `security` |
| Profile performance | `performance` |
| Final planning-stage review and sign-off | `ceo` |
| Implement features or fixes | `coder` |
| Write or run tests | `tester` |
| Review code quality | `reviewer` |
| Investigate a bug | `debugger` |
| Refactor code structure | `refactor` |
| File a bug report | `bug-gatherer` |
| Update documentation | `docs-writer` |
| Prepare a release | `release` |
| Enforce process and resolve conflicts | `validator` |

### Pipeline Skills

| Skill | Purpose |
|---|---|
| `/agent-plan <feature>` | Run the Planning Stage end-to-end. Product → Architecture + UI → Security + Performance → CEO. Produces planning documents and a CEO verdict. No code is written. |
| `/agent-code <milestone-or-task>` | Run the Engineering Stage for a CEO-approved milestone. Coder → Tester → Reviewer, with Defects routed through Bug Gatherer → Product (triage) → Debugger and Issues routed through Refactor → Tester → Reviewer. |
| `/agent-task <task description>` | Run a mini engineering pipeline for a single one-off task without requiring a milestone or CEO verdict. Coder → Tester → Reviewer, with the same Defect/Issue routing as `/agent-code`. Use for bug fixes, typos, small refactors, and dependency bumps — NOT for new modules or cross-cutting changes. |

### Inter-Agent Handoff

Agents communicate through shared documents. When one agent completes work, the next agent reads the updated files:

- **`artifacts/AGENT_STATE.md`** holds every agent's live working state (Current Work tables, decision logs) in one file, one section per agent — agent definition files are immutable and carry only a pointer to their section.
- **`docs/PIPELINE_LOOP.md`** is the canonical engineering-loop contract (per-task sequence, Defect/Issue routing, loop-counter and test-gate rules) that both `/agent-code` and `/agent-task` execute.
- **`artifacts/BUGS.md`** is the shared bug tracker (Bug Gatherer files, Product triages, Debugger investigates, Coder fixes).
- **Planning architecture documents** at `artifacts/architecture/arch-milestone-{N}.md` are the contract between Architect and Coder for a specific milestone. Templates live at `templates/ARCH_MODULE.md`, `templates/ARCH_SYSTEM.md`, and `templates/ARCH_DATA_SCHEMA.md`.
- **Planning UI specifications** at `artifacts/ui-specs/ui-milestone-{N}.md` are the contract between UI and Coder. Template lives at `templates/UI_SPEC.md`.
- **CEO planning verdicts** at `artifacts/reviews/ceo-review-milestone-{N}.md` gate entry into the engineering stage. Template lives at `templates/CEO_REVIEW.md`.

### Minimum Viable Agent Set

The required agent roster depends on which shipped pipeline skills you want to keep. The three pipelines form a gradient: `/agent-task` has the smallest minimum, then `/agent-plan` + `/agent-code` add the full planning pipeline on top. Prune from the bottom up.

**Tier 1 — Always required (core development loop):**
- **Product** — Requirements, acceptance criteria, and task validation
- **Coder** — Implementation
- **Reviewer** — Code quality and Defect/Issue classification
- **Tester** — Test coverage and the automated gate

**Tier 2 — Strongly recommended for any serious project:**
- **Architect** — For projects with multiple modules or complex structure
- **Debugger** — For projects with non-trivial bug investigation needs
- **Docs Writer** — For projects requiring documentation maintenance

**Tier 3 — Required for `/agent-task`:**

`/agent-task` runs a mini engineering pipeline (Coder → Tester → Reviewer → Product) without any planning stage. On top of Tier 1, it needs the Defect/Issue routing targets to exist, otherwise Reviewer's hand-offs dead-end:
- **Bug Gatherer** — files Reviewer's Defects as structured bug reports and routes them to Product for triage
- **Debugger** — investigates Defects that Product triages as "fix now"
- **Refactor** — receives Issues from Reviewer and loops back through Tester

A project that wants `/agent-task` but not the planning stage can delete `.claude/skills/agent-plan/`, `.claude/skills/agent-code/`, `.claude/agents/ceo.md`, and optionally `.claude/agents/ui.md`, `.claude/agents/security.md`, `.claude/agents/performance.md`, and still have a functional engineering loop via `/agent-task`.

**Tier 4 — Required for `/agent-plan` and `/agent-code`:**

The planning pipelines hard-wire a flow that ends at a CEO sign-off. If you keep `/agent-plan` or `/agent-code`, you must keep all of these agents on top of Tiers 1–3:
- **UI** — produces UI specifications during planning
- **Security** — reviews architecture, feeds findings to CEO
- **Performance** — reviews architecture, feeds findings to CEO
- **CEO** — the final planning gate. `/agent-plan` has no meaning without it; `/agent-code` pre-flight reads the CEO verdict file before any task runs.

If you do not want a CEO planning gate, **delete both `/agent-plan` and `/agent-code` together with `ceo.md`** — the two pipelines and the CEO agent are a unit. `/agent-task` remains functional on its own and does not read any CEO verdict. Do not attempt to keep `/agent-plan` or `/agent-code` while deleting the CEO agent; the result is a broken pipeline.

### Optional based on project type

- **Release** — Projects with formal release processes
- **Refactor** — Projects with technical debt concerns
- **Bug Gatherer** — Projects with external bug reporters
- **Validator** — Large teams or complex multi-agent workflows

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
| `agents/product.md` | Defines the product agent; owns requirements, acceptance criteria, milestone definitions, and final sign-off |
| `agents/architect.md` | Defines the system design agent; responsible for proposing and documenting structural decisions |
| `agents/ui.md` | Defines the UI agent; owns visual design, layout specifications, style guide, and interaction patterns |
| `agents/security.md` | Defines the security audit agent; runs after Architecture produces a document, feeds findings to CEO |
| `agents/performance.md` | Defines the performance agent; runs after Architecture produces a document, feeds findings to CEO |
| `agents/ceo.md` | Defines the CEO agent; final reviewer of the planning stage, integrates Product/Architecture/UI/Security/Performance into a go/no-go verdict |
| `agents/coder.md` | Defines the implementation agent; responsible for writing feature code within established conventions |
| `agents/tester.md` | Defines the testing agent; runs after every Coder change to generate and maintain automated test coverage |
| `agents/reviewer.md` | Defines the code review agent; classifies findings as Defects (→ Bug Gatherer) or Issues (→ Refactor) |
| `agents/debugger.md` | Defines the debugging agent; investigates defects Product triages as "fix now" and hands root-cause analysis back to Coder |
| `agents/refactor.md` | Defines the refactoring agent; addresses Reviewer Issues without changing behaviour, loops back through Tester to Reviewer |
| `agents/bug-gatherer.md` | Defines the bug gatherer agent; structures bug reports and routes them to Product for triage |
| `agents/docs-writer.md` | Defines the documentation agent; drains the `docs:` queue at task- and milestone-completion checkpoints, accepts direct user input |
| `agents/release.md` | Defines the release preparation agent; responsible for changelogs, versioning, and build verification |
| `agents/validator.md` | Defines the validator agent; enforces agent protocols, resolves conflicts, tracks milestones, runs retrospectives |
| `agents/README.md` | Master overview of the agent system: roster, interaction diagram, planning and engineering stage workflows, and placeholder reference |

### skills/ → `.claude/skills/` (3 pipeline skills + README)

> **Note:** `skills/README.md` is metadata about the directory. It is NOT installed to the target project.

| File | Description |
|---|---|
| `skills/agent-plan/SKILL.md` | Defines the `/agent-plan` pipeline skill; orchestrates the Planning Stage end-to-end (Product → Architecture + UI → Security + Performance → CEO) |
| `skills/agent-code/SKILL.md` | Defines the `/agent-code` pipeline skill; orchestrates the Engineering Stage per task (Coder → Tester → Reviewer, with Defects through Bug Gatherer → Product → Debugger and Issues through Refactor → Tester → Reviewer) |
| `skills/agent-task/SKILL.md` | Defines the `/agent-task` pipeline skill; runs a mini engineering pipeline (Coder → Tester → Reviewer → Product) for a single one-off task without requiring a milestone or CEO verdict |

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
| `docs/MODEL_OPTIMIZATION.md` | Model policy for the agent roster: the Claude Opus 4.x ladder, per-model behavior profiles, and the 4.6 → 4.7 → 4.8 upgrade checklists |
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

### templates/ (document templates, 10 files)

Reusable document skeletons. Agents copy them — never fill in place — to produce instances under `artifacts/`. See [`templates/README.md`](skills/cast-init/assets/templates/README.md).

| File | Description |
|---|---|
| `templates/MILESTONE_DEFINITION.md` | Template for the milestone definition file: goal, success metrics, in/out of scope, top-level acceptance criteria. Instance at `artifacts/milestones/milestone-{N}-{slug}.md`. |
| `templates/MILESTONE_TASKS.md` | Template for the task breakdown file: one row per task with dependencies, acceptance criteria, and files touched. Instance at `artifacts/milestones/milestone-{N}-{slug}-tasks.md`. |
| `templates/MILESTONE_VALIDATION.md` | Template for milestone validation / acceptance records. Instance at `artifacts/milestones/milestone-{N}-{slug}-validation.md`. |
| `templates/MILESTONE_COMPLETION.md` | Template for milestone completion reports. Instance at `artifacts/milestones/milestone-{N}-{slug}-completion.md`. |
| `templates/ARCH_MODULE.md` | Template for documenting a single code module (instances live in `artifacts/architecture/`) |
| `templates/ARCH_SYSTEM.md` | Template for documenting a high-level system (instances live in `artifacts/architecture/`) |
| `templates/ARCH_DATA_SCHEMA.md` | Template for documenting a data schema or save format (instances live in `artifacts/architecture/`) |
| `templates/UI_SPEC.md` | Template for specifying a UI screen or component (instances live in `artifacts/ui-specs/`) |
| `templates/CEO_REVIEW.md` | Template for the CEO planning verdict: the six mandated inputs, the review checklist, and the APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED verdict block. Instance at `artifacts/reviews/ceo-review-milestone-{N}.md`. |
| `templates/UX_REVIEW.md` | Template for UI's UX review of an implemented milestone (instances live in `artifacts/reviews/`) |

### artifacts/ (work artifacts)

Live work artifacts produced by the agents. Copied as a seed into the target project so the expected structure is in place from day one.

| Path | Description |
|---|---|
| `artifacts/README.md` | Explains the `docs/` vs `artifacts/` split and lists the subdirectory layout |
| `artifacts/AGENT_STATE.md` | Live working state for all 15 agents (Current Work tables, decision logs, validator dashboards), one section per agent — the mutable counterpart to the immutable agent definition files |
| `artifacts/BUGS.md` | Active bug tracker — instance (not template). Filed by Bug Gatherer, triaged by Product, investigated by Debugger |
| `artifacts/STANDUP.md` | Rolling log of progress updates, blockers, and decisions from work sessions |
| `artifacts/milestones/` | Milestone definitions, task breakdowns, completion reports, and validation records (one per milestone) |
| `artifacts/architecture/` | Architecture documents produced per milestone during `/agent-plan` |
| `artifacts/ui-specs/` | UI specifications produced per milestone during `/agent-plan` |
| `artifacts/reviews/` | Security, performance, and CEO reviews produced during `/agent-plan` |

</details>

---

## License and contributing

CAST is [MIT-licensed](LICENSE) Markdown — every agent definition, pipeline skill, and document template is plain text you can fork, edit, and republish. If you find a rough edge, open an issue or a pull request on [`Raxvis/CAST`](https://github.com/Raxvis/CAST).

Significant changes must bump the template version in **four synchronized locations** and ship an annotated git tag plus a GitHub Release at the same push. The full policy is in [`CLAUDE.md`](CLAUDE.md) → Release and Tagging Policy. Short version:

1. `README.md` — the version badge and the `Current template version` hero line
2. `CHANGELOG.md` — a new version entry following the existing format
3. `.claude-plugin/plugin.json` — the `version` field
4. `skills/cast-init/SKILL.md` — the `metadata.version` frontmatter field

All four land in the same commit. Immediately after pushing: annotated tag (`git tag -a v<new>`) + GitHub Release (`gh release create v<new> --notes-file ... --latest`).
