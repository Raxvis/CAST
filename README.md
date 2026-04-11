<!-- TEMPLATE INSTRUCTIONS
  This file is the master index for the reusable project template system.
  It describes the purpose, structure, placeholder conventions, and file inventory
  for every template file in this directory tree.

  When adapting this template to a new project:
    1. Read this file in full before touching anything else.
    2. Follow the Quick Start section below.
    3. Replace every [PLACEHOLDER_NAME] token with a project-specific value.
    4. Delete agent files that are not relevant to your project type.
    5. Remove this comment block from the final project's copy of the file.
-->

# CAST — Claude Agent Staged Team

**Template version:** `0.7.0` — see [`CHANGELOG.md`](CHANGELOG.md) for the version history and migration notes.

CAST is a multi-agent workflow template for Claude Code. It ships 15 specialist subagents, three slash commands, and a CEO-gated planning pipeline that keeps the planning stage and the engineering stage honest. The name is a double pun: a *cast* is a group of specialists each playing a defined role, and the pipeline runs in *stages* — planning (Product → Architecture + UI → Security + Performance → CEO sign-off) followed by engineering (Coder → Tester → Reviewer with defect and issue routing). You get a real team structure with clear handoffs, typed artifacts, and a review gate you can't accidentally skip, all as plain Markdown files that Claude Code reads at session start — no framework to install, no runtime to maintain.

## Install in one line

From inside an existing project directory, run:

```bash
curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash
```

This downloads the template, prompts for a handful of essential placeholders (project name, language, framework, test/dev/build commands), writes `CLAUDE.md`, `.claude/agents/`, `.claude/commands/`, `docs/`, `artifacts/`, and helper scripts into the current directory, and runs a placeholder check when it's done. Your next step is `./scripts/smoke-test.sh .` followed by opening Claude Code and walking through `docs/FIRST_RUN.md`.

Non-default variants:

```bash
# Install into a specific directory instead of the current one:
curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash -s -- /path/to/project

# Non-interactive install with answers pre-filled in a values file:
curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash -s -- . --values template.values

# Prompt for every supported placeholder, not just essentials:
curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash -s -- . --full

# Overwrite an already-populated target:
curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash -s -- . --force
```

Requirements: `bash`, `git`, and an interactive terminal (or a `--values` file for non-interactive environments). Works on macOS, Linux, and WSL. Windows users without WSL should clone the repo and run `scripts\install.ps1` directly — curl-pipe-bash doesn't map to PowerShell.

Before running a curl-pipe-bash command in any environment, it's reasonable to inspect the script first: `curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | less`.

---

## What Is This?

This is a **multi-agent AI-assisted development workflow template**. It provides a structured set of documents and agent configuration files that can be dropped into any new software project to establish a consistent, repeatable development process from day one.

The template is designed to be used with AI coding assistants running as autonomous or semi-autonomous agents. Each agent file defines a focused role (e.g., architect, reviewer, tester) and a set of responsibilities scoped to one part of the development lifecycle. The supporting documents provide the shared context those agents need to operate coherently across a project.

The system is:

- **Technology-agnostic** — placeholders stand in for every stack-specific detail.
- **Domain-agnostic** — placeholder names cover a wide range of application domains.
- **Incremental** — adopt only the agent roles and documents that apply to your project phase.

---

## Directory Structure

```
claude/
  README.md              # This file — master index and usage guide
  root/                  # Files intended for the project root
  agents/                # Agent role definitions (copied to .claude/agents/)
  commands/              # Slash commands (copied to .claude/commands/)
  docs/                  # Reference material: requirements, conventions, templates
  artifacts/              # Work artifacts: plans, reviews, bugs, session logs
```

### The `docs/` vs `artifacts/` split

This template enforces a strict separation between **reference material** and **work artifacts**:

- **`docs/` is documentation only.** It holds things that describe how the project works: the PRD, concept, glossary, coding conventions, file placement rules, error handling standards, testing strategy, design rationale, and **templates** for architecture docs, UI specs, milestones, and bug reports. `docs/` must never contain feature plans, milestone instances, bug reports, CEO reviews, or progress logs.
- **`artifacts/` is work artifacts only.** It holds instances of work: milestone definitions produced by the Product agent, architecture documents produced by the Architect agent for a specific milestone, UI specs produced by the UI agent, security and performance reviews, CEO planning verdicts, bug reports, and the rolling session log.

If you are unsure where a file belongs, ask: _"Is this reusable reference material or a specific piece of work?"_ Reference → `docs/`. Work → `artifacts/`. Both `/agent-plan` and `/agent-code` write exclusively to `artifacts/`; neither command should ever modify `docs/`.

### root/

Files in this directory are copied directly to the root of the target project. They configure the development environment, define coding conventions, and provide the top-level context that every agent reads first.

### agents/

Each file defines one agent role with YAML frontmatter for Claude Code auto-discovery. When copied to `.claude/agents/` in the target project, Claude Code automatically registers them as subagents that can be invoked by name or delegated to automatically based on task type. Files that do not apply to your project type can be deleted without affecting the others.

### commands/

Each file defines one slash command that orchestrates a multi-agent workflow stage end-to-end. When copied to `.claude/commands/` in the target project, Claude Code registers them as slash commands named after the file (e.g. `commands/agent-plan.md` becomes `/agent-plan`). Three commands ship with this template: `/agent-plan` runs the Planning Stage (Product → Architecture + UI → Security + Performance → CEO), `/agent-code` runs the Engineering Stage (Coder → Tester → Reviewer, with defects to Debugger → Bug Gatherer → Product and issues to Refactor → Reviewer), and `/agent-task` runs a mini engineering pipeline (Coder → Tester → Reviewer → Product) for a single one-off task without requiring a milestone, planning artifacts, or a CEO verdict — use it for bug fixes, typos, small refactors, and dependency bumps, not for new modules or cross-cutting changes.

### docs/

Reference material only. These are not agent definitions and not work artifacts — they are shared knowledge that multiple agents and human contributors reference: domain rules, quality standards, coding conventions, and reusable document templates. Agents must read from `docs/` but must not write work artifacts to `docs/`.

**Topic-specific reference docs.** Three files in `docs/` are scoped to a project type rather than being universal: `FRONTEND.md`, `BACKEND.md`, and `CLI.md`. Keep the one(s) that match your project and delete the rest. The shipped `root/CLAUDE.md` is agnostic and has commented `@import` lines for all three — uncomment the relevant line(s) after install so the right patterns get loaded into session context.

- **`docs/FRONTEND.md`** — user-facing visual interfaces (web, mobile, desktop GUI, game UI). Covers navigation, state management, UI components, performance, input handling, platform differences.
- **`docs/BACKEND.md`** — API servers, background workers, data pipelines. Covers request boundaries, persistence, error handling and HTTP status codes, auth, middleware, observability, background jobs.
- **`docs/CLI.md`** — command-line tools and terminal utilities. Covers argv parsing, stdin/stdout/stderr discipline, exit codes, terminal output formatting, cross-platform concerns, signal handling.

A project that spans two types (e.g., a full-stack web app with a backend API and a React frontend) can keep both files and import both. A project that doesn't fit any of the three categories can delete all three and write its own.

### artifacts/

Work artifacts produced by the agents during `/agent-plan` and `/agent-code`: milestone definitions, milestone-specific architecture and UI specifications, security and performance reviews, CEO planning verdicts, bug reports, milestone completion records, and the rolling session log. See `artifacts/README.md` for the full directory structure.

---

## Placeholder Convention

All project-specific content in template files is expressed using square-bracket placeholder tokens:

```
[PLACEHOLDER_NAME]
```

Placeholders appear inline within prose, code blocks, file paths, and configuration values. Every placeholder in every file must be replaced before the template is put into active use. Leaving a placeholder in place causes agents to emit that token literally, which produces incorrect output.

Placeholder names are written in `UPPER_SNAKE_CASE` and are scoped to one of the categories below.

---

## Placeholder Reference

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

Each agent file has its model hard-coded in the YAML frontmatter — there is no `[AI_MODEL]` placeholder. The template pre-selects the right model per workload tier: planning agents on `claude-opus-4-6`, engineering agents on `claude-sonnet-4-6`, and utility agents on `claude-haiku-4-5-20251001`. Edit the `model:` line in an individual agent file if you need to override, but the defaults are intentional.

| Placeholder | Description | Example value |
|---|---|---|
| _(none — all per-agent models are set in YAML frontmatter)_ | | |

---

## Prerequisites

Before running Quick Start, confirm the following:

- **Claude Code CLI installed and authenticated.** This template is built for Claude Code specifically. The slash commands (`/agent-plan`, `/agent-code`) and subagent auto-discovery rely on Claude Code's `.claude/commands/` and `.claude/agents/` conventions. Other AI coding assistants do not read these files. Install and sign in to Claude Code before continuing.
- **A target project directory.** Either a new empty git repo or an existing project where you want to introduce the agent workflow. The template does not create the project for you.
- **A shell that can run the install script.** macOS Terminal, Linux bash/zsh, or WSL run `scripts/install.sh` (bash 3.2+). Windows users without WSL run `scripts\install.ps1` (PowerShell 5.1+ or PowerShell Core 7+). The two scripts are functionally equivalent — they share CLI flags, prompt lists, and `template.values` output format. The manual copy path in Quick Start still works from any shell if you prefer not to use the installer.
- **An Anthropic account with API access** to the model tiers pinned in the agent files: Opus 4.6 for planning agents, Sonnet 4.6 for engineering agents, Haiku 4.5 for utility agents. You can override the `model:` line in an individual agent file if you need a different pin.

## Known Limitations

A common source of confusion: this repo is a **template**, not a framework. Setting expectations clearly up front:

- **Agents are role definitions, not running processes.** The files in `agents/` describe what each agent is responsible for, what it accepts as input, and what it produces as output. Claude Code reads them as subagent definitions. There is no background daemon, no queue, and no automatic dispatching beyond what Claude Code itself does.
- **The slash commands are orchestration scripts written in Markdown.** `/agent-plan` and `/agent-code` tell Claude Code to invoke a specific sequence of subagents. They are not compiled, not executable, and not testable outside Claude Code. Reading them is reading their full behavior.
- **The workflow is Claude Code-specific.** Copilot CLI, Gemini CLI, Cursor, and other AI tools do not honor `.claude/agents/` or `.claude/commands/`. Porting the template to another tool requires manual adaptation — read each agent file as a prompt and invoke it however that tool supports role prompts.
- **No code is written by copying this template.** You get a directory layout, agent role files, slash command definitions, document templates, and empty work-artifact scaffolding. Your first real output appears after you run `/agent-plan` on a feature.
- **Templates contain nested placeholders.** Some files (bug report forms, milestone validation records) include their own fill-in-per-use placeholders like `[DATE]`, `[REPRODUCTION_STEPS]`, `[TASK_NAME]`. The placeholder check script will flag these — they are not bugs in your customization, they are deliberate sub-templates filled in each time the form is used.

Common problems you may hit during adoption or first use — slash command not recognized, subagent not delegating, `features/` references after upgrade, CEO returning REVISION REQUIRED — are covered in [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md). Skim it before filing a new issue.

## What a populated project looks like

Before installing, browse [`example/`](example/) to see exactly what a real populated instance of this template looks like. The example is a fixture based on "Acme Todo" — a small TypeScript CLI todo tracker — with one milestone planned and implemented end-to-end through `/agent-plan` and `/agent-code`. It shows:

- A fully substituted `CLAUDE.md` with no `[PLACEHOLDER]` tokens ([`example/CLAUDE.md`](example/CLAUDE.md))
- A populated PRD, concept, and glossary ([`example/docs/`](example/docs/))
- A complete planning run for Milestone 1: milestone definition, task breakdown, architecture document, UI spec, security review, performance review, and CEO verdict ([`example/artifacts/`](example/artifacts/))
- A milestone completion report, an active bug tracker with one fixed bug and one open deferred bug, and a three-day session log

The example deliberately omits `.claude/` (those files are unchanged copies of the template agents/commands) and `src/` (this is a planning fixture, not a real build). The start-here file is [`example/README.md`](example/README.md).

---

## Quick Start

### Fast path: install script

The install script prompts for the essential placeholders (project name, language, framework, test/dev/build commands), copies all template files into the target, substitutes your answers across every Markdown file, writes `template.values` as a record of your answers, and runs the placeholder check so you know what is left.

**One-liner (macOS, Linux, WSL):**

```bash
curl -fsSL https://raw.githubusercontent.com/Raxvis/CAST/main/scripts/bootstrap.sh | bash
```

See the top of this README for the full set of curl-pipe-bash variants.

**Cloned repo (macOS, Linux, WSL):**

```
./scripts/install.sh /path/to/your-project
```

**Windows PowerShell (5.1+ or PowerShell Core 7+), no WSL required:**

```
.\scripts\install.ps1 C:\path\to\your-project
```

The three entry points have identical behavior: the bootstrap script downloads the template and then hands off to `install.sh`. `install.sh` and `install.ps1` share the same CLI surface. All three write a `template.values` file to the target so re-running is reproducible.

Options (bash flags on the left, PowerShell parameters on the right — they mean the same thing):

| bash | PowerShell | Effect |
|---|---|---|
| `--full` | `-Full` | Prompt for every supported placeholder, not just essentials |
| `--values FILE` | `-Values FILE` | Non-interactive, read answers from a file |
| `--force` | `-Force` | Overwrite an existing populated target |
| `--help` / `-h` | `-Help` | Print full usage |

The install script solves cross-file consistency by construction: because every substitution comes from a single values file, you cannot type `[PROJECT_NAME]` as "Acme" in one file and "Acme Dashboard" in another.

### Manual path

If you prefer to copy and substitute by hand, or you are on Windows CMD/PowerShell without WSL:

1. **Copy template files** into the target project:

   ```
   cp root/CLAUDE.md /path/to/your-project/CLAUDE.md
   mkdir -p /path/to/your-project/.claude/agents /path/to/your-project/.claude/commands
   cp agents/*.md /path/to/your-project/.claude/agents/
   cp commands/*.md /path/to/your-project/.claude/commands/
   cp -r docs/ /path/to/your-project/docs/
   cp -r artifacts/ /path/to/your-project/artifacts/
   ```

   Agent files in `.claude/agents/` are automatically discovered by Claude Code as subagents. Files in `.claude/commands/` are registered as slash commands named after the file (e.g. `agent-plan.md` → `/agent-plan`). `docs/` holds reference material and templates; `artifacts/` is where agents write live work artifacts during `/agent-plan` and `/agent-code`.

   **Windows PowerShell equivalent** (for users without WSL):

   ```
   Copy-Item root/CLAUDE.md C:\path\to\your-project\CLAUDE.md
   New-Item -ItemType Directory -Force C:\path\to\your-project\.claude\agents, C:\path\to\your-project\.claude\commands
   Copy-Item agents\*.md C:\path\to\your-project\.claude\agents\
   Copy-Item commands\*.md C:\path\to\your-project\.claude\commands\
   Copy-Item -Recurse docs C:\path\to\your-project\docs
   Copy-Item -Recurse artifacts C:\path\to\your-project\artifacts
   ```

2. **Search for every placeholder** across all files and replace each one with the appropriate project-specific value. Process the placeholder categories top-to-bottom as they appear in the Placeholder Reference table above — every category has fill-in work, not just the first few.

3. **Delete optional agent files** that do not apply to your project. Each agent file is self-contained; removing one does not break the others. Refer to the Minimum Viable Agent Set section or the file listing below to identify candidates for deletion.

4. **Review the docs/** directory. Each document contains its own placeholder tokens. Fill them in with the same values used in the agent files to keep all references consistent.

5. **Commit the populated template** as part of your project's initial commit so that all contributors and agents share the same baseline context from the start.

6. **Verify all placeholders are replaced.** Two options:

   **Option A — one-liner (macOS, Linux, WSL):**

   ```
   grep -rEn '\[[A-Z][A-Z0-9_]+\]' --include='*.md' --exclude=README.md --exclude=CHANGELOG.md --exclude=TROUBLESHOOTING.md .
   ```

   This targets only `[UPPER_SNAKE_CASE]` tokens and ignores the template's self-referential metadata files. Zero output means clean.

   **Option B — bundled script:**

   ```
   ./scripts/check-placeholders.sh
   ```

   Same regex, but groups results by file, prints a summary, and exits non-zero if anything remains (so it plugs into CI). Pass extra filenames as arguments to extend the default skip list, e.g. `./scripts/check-placeholders.sh docs/ADDITIONAL.md`.

   Both approaches are best-effort. Files that contain sub-templates — a bug report template with `[DATE]` and `[REPRODUCTION_STEPS]` fields, for example — will produce matches even after the surrounding file is fully customized. Review each match and decide whether it is a real unreplaced placeholder or a deliberate fill-in-per-use marker.

7. **Remove this README** from your project once the template has been fully populated, or repurpose it as a contributor guide scoped to your specific project.

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

### Slash Commands

| Command | Purpose |
|---|---|
| `/agent-plan <feature>` | Run the Planning Stage end-to-end. Product → Architecture + UI → Security + Performance → CEO. Produces planning documents and a CEO verdict. No code is written. |
| `/agent-code <milestone-or-task>` | Run the Engineering Stage for a CEO-approved milestone. Coder → Tester → Reviewer, with Defects routed through Debugger → Bug Gatherer → Product and Issues routed through Refactor → Reviewer. |
| `/agent-task <task description>` | Run a mini engineering pipeline for a single one-off task without requiring a milestone or CEO verdict. Coder → Tester → Reviewer, with the same Defect/Issue routing as `/agent-code`. Use for bug fixes, typos, small refactors, and dependency bumps — NOT for new modules or cross-cutting changes. |

### Inter-Agent Handoff

Agents communicate through shared documents. When one agent completes work, the next agent reads the updated files:

- **Current Work tables** in each agent file track in-progress and completed tasks.
- **`artifacts/BUGS.md`** is the shared bug tracker (Bug Gatherer files, Debugger investigates, Coder fixes).
- **Planning architecture documents** at `artifacts/architecture/arch-milestone-{N}.md` are the contract between Architect and Coder for a specific milestone. Templates live at `docs/ARCH_MODULE.md`, `docs/ARCH_SYSTEM.md`, and `docs/ARCH_DATA_SCHEMA.md`.
- **Planning UI specifications** at `artifacts/ui-specs/ui-milestone-{N}.md` are the contract between UI and Coder. Template lives at `docs/UI_SPEC.md`.
- **CEO planning verdicts** at `artifacts/reviews/ceo-review-milestone-{N}.md` gate entry into the engineering stage.

### Minimum Viable Agent Set

The required agent roster depends on which shipped slash commands you want to keep. The three commands form a gradient: `/agent-task` has the smallest minimum, then `/agent-plan` + `/agent-code` add the full planning pipeline on top. Prune from the bottom up.

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
- **Debugger** — receives Defects from Reviewer
- **Refactor** — receives Issues from Reviewer and loops back
- **Bug Gatherer** — files Defect reports and routes them to Product for triage

A project that wants `/agent-task` but not the planning stage can delete `commands/agent-plan.md`, `commands/agent-code.md`, `agents/ceo.md`, and optionally `agents/ui.md`, `agents/security.md`, `agents/performance.md`, and still have a functional engineering loop via `/agent-task`.

**Tier 4 — Required for `/agent-plan` and `/agent-code`:**

The planning commands hard-wire a pipeline that ends at a CEO sign-off. If you keep `/agent-plan` or `/agent-code`, you must keep all of these agents on top of Tiers 1–3:
- **UI** — produces UI specifications during planning
- **Security** — reviews architecture, feeds findings to CEO
- **Performance** — reviews architecture, feeds findings to CEO
- **CEO** — the final planning gate. `/agent-plan` has no meaning without it; `/agent-code` pre-flight reads the CEO verdict file before any task runs.

If you do not want a CEO planning gate, **delete both `/agent-plan` and `/agent-code` together with `ceo.md`** — the two commands and the CEO agent are a unit. `/agent-task` remains functional on its own and does not read any CEO verdict. Do not attempt to keep `/agent-plan` or `/agent-code` while deleting the CEO agent; the result is a broken pipeline.

### Optional based on project type

- **Release** — Projects with formal release processes
- **Refactor** — Projects with technical debt concerns
- **Bug Gatherer** — Projects with external bug reporters
- **Validator** — Large teams or complex multi-agent workflows

---

## File Listing

All files in the template system are listed below with a short description of each file's purpose.

### root/ (2 files)

| File | Description |
|---|---|
| `root/CLAUDE.md` | Top-level context file read first by every agent; defines project identity, structure, conventions, and run commands |
| `root/.claude/settings.json.example` | Minimal safe Claude Code project-settings example (auto-approves read-only shell commands). Copied to `<target>/.claude/settings.json.example` on install; rename to `settings.json` to activate |

### agents/ → `.claude/agents/` (16 files)

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
| `agents/reviewer.md` | Defines the code review agent; classifies findings as Defects (→ Debugger) or Issues (→ Refactor) |
| `agents/debugger.md` | Defines the debugging agent; investigates defects raised by Reviewer and hands reports to Bug Gatherer |
| `agents/refactor.md` | Defines the refactoring agent; addresses Reviewer Issues without changing behaviour, loops back to Reviewer |
| `agents/bug-gatherer.md` | Defines the bug gatherer agent; structures bug reports and routes them to Product for triage |
| `agents/docs-writer.md` | Defines the documentation agent; updates docs after any agent completes work, accepts direct user input |
| `agents/release.md` | Defines the release preparation agent; responsible for changelogs, versioning, and build verification |
| `agents/validator.md` | Defines the validator agent; enforces agent protocols, resolves conflicts, tracks milestones, runs retrospectives |
| `agents/README.md` | Master overview of the agent system: roster, interaction diagram, planning and engineering stage workflows, and placeholder reference |

### commands/ → `.claude/commands/` (3 files)

| File | Description |
|---|---|
| `commands/agent-plan.md` | Defines the `/agent-plan` slash command; orchestrates the Planning Stage end-to-end (Product → Architecture + UI → Security + Performance → CEO) |
| `commands/agent-code.md` | Defines the `/agent-code` slash command; orchestrates the Engineering Stage per task (Coder → Tester → Reviewer, with Defects through Debugger → Bug Gatherer → Product and Issues through Refactor → Reviewer) |
| `commands/agent-task.md` | Defines the `/agent-task` slash command; runs a mini engineering pipeline (Coder → Tester → Reviewer → Product) for a single one-off task without requiring a milestone or CEO verdict |

### docs/ (reference material, 20 files)

Templates and reference documentation. Never holds work artifacts.

| File | Description |
|---|---|
| `docs/README.md` | Documentation index; master navigation entry point for all project documentation |
| `docs/PRD.md` | Product Requirements Document; describes goals, user stories, and acceptance criteria for the current scope |
| `docs/CONCEPT.md` | High-level project vision, core loop, and design pillars |
| `docs/ADDITIONAL.md` | Supplementary context that does not fit the primary documents; captures edge cases and open questions |
| `docs/GLOSSARY.md` | Canonical definitions for all domain-specific terms used across documents |
| `docs/DESIGN_RATIONALE.md` | Decision log recording significant design choices and their trade-offs |
| `docs/CODE_PATTERNS.md` | Coding conventions, naming rules, module structure, and state management patterns |
| `docs/FILE_CONVENTIONS.md` | File naming rules, directory layout expectations, and `docs/` vs `artifacts/` split |
| `docs/ERROR_HANDLING.md` | Guidelines for handling errors across all categories; defines principles, patterns, and user-facing message standards |
| `docs/TEST_FRAMEWORK.md` | Testing strategy, test runner setup, file conventions, and coverage requirements |
| `docs/FIRST_RUN.md` | Interactive checklist to run in Claude Code after a fresh install; verifies that subagents load and slash commands register |
| `docs/CLAUDE_CODE_SETTINGS.md` | Reference for `.claude/settings.json` — explains permission rules, environment variables, and hooks, with common extension patterns |
| `docs/FRONTEND.md` | Topic-specific reference for frontend projects; delete if not applicable |
| `docs/BACKEND.md` | Topic-specific reference for API servers, workers, and pipelines; delete if not applicable |
| `docs/CLI.md` | Topic-specific reference for command-line tools; delete if not applicable |
| `docs/CHANGELOG.md` | Chronological log of notable changes across releases and milestones, maintained by the release agent |
| `docs/ASSETS.md` | Registry of all project assets (images, fonts, etc.) with status and source information |
| `docs/MVP_LAUNCH.md` | Checklist and criteria for the initial public release |
| `docs/MILESTONE_DEFINITION.md` | Template for the milestone definition file: goal, success metrics, in/out of scope, top-level acceptance criteria. Instance at `artifacts/milestones/milestone-{N}-{slug}.md`. |
| `docs/MILESTONE_TASKS.md` | Template for the task breakdown file: one row per task with dependencies, acceptance criteria, and files touched. Instance at `artifacts/milestones/milestone-{N}-{slug}-tasks.md`. |
| `docs/MILESTONE_VALIDATION.md` | Template for milestone validation / acceptance records. Instance at `artifacts/milestones/milestone-{N}-{slug}-validation.md`. |
| `docs/MILESTONE_COMPLETION.md` | Template for milestone completion reports. Instance at `artifacts/milestones/milestone-{N}-{slug}-completion.md`. |
| `docs/ARCH_MODULE.md` | Template for documenting a single code module (instances live in `artifacts/architecture/`) |
| `docs/ARCH_SYSTEM.md` | Template for documenting a high-level system (instances live in `artifacts/architecture/`) |
| `docs/ARCH_DATA_SCHEMA.md` | Template for documenting a data schema or save format (instances live in `artifacts/architecture/`) |
| `docs/UI_SPEC.md` | Template for specifying a UI screen or component (instances live in `artifacts/ui-specs/`) |

### artifacts/ (work artifacts)

Live work artifacts produced by the agents. Copied as a seed into the target project so the expected structure is in place from day one.

| Path | Description |
|---|---|
| `artifacts/README.md` | Explains the `docs/` vs `artifacts/` split and lists the subdirectory layout |
| `artifacts/BUGS.md` | Active bug tracker — instance (not template). Filed by Bug Gatherer, investigated by Debugger |
| `artifacts/STANDUP.md` | Rolling log of progress updates, blockers, and decisions from work sessions |
| `artifacts/milestones/` | Milestone definitions, task breakdowns, completion reports, and validation records (one per milestone) |
| `artifacts/architecture/` | Architecture documents produced per milestone during `/agent-plan` |
| `artifacts/ui-specs/` | UI specifications produced per milestone during `/agent-plan` |
| `artifacts/reviews/` | Security, performance, and CEO reviews produced during `/agent-plan` |
