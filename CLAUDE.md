# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is **CAST — Claude Agent Staged Team**, a multi-agent AI-assisted development workflow template. It contains no source code — only markdown template files with `[PLACEHOLDER]` tokens that are replaced when adapting the template to a new project. CAST establishes agent roles, documentation structure, and development conventions for Claude Code-based development.

## Directory Structure

- **`root/`** — Files copied to a target project's root (CLAUDE.md template, config templates)
- **`agents/`** — 15 agent role definitions plus a master `README.md` (product, architect, ui, security, performance, ceo, coder, tester, reviewer, debugger, refactor, bug-gatherer, docs-writer, release, validator). Each file includes YAML frontmatter for Claude Code subagent auto-discovery and defines one agent's purpose, authority, inputs, outputs, and decision log. Copied to `.claude/agents/` in the target project
- **`commands/`** — Slash command definitions (`/agent-plan`, `/agent-code`, `/agent-task`) that orchestrate the planning and engineering stages of the agent workflow plus a mini pipeline for one-off tasks. Copied to `.claude/commands/` in the target project
- **`docs/`** — **Reference material only.** Requirements, conventions, design rationale, and reusable templates (PRD, architecture templates, UI spec template, milestone templates, etc.). Never receives work artifacts.
- **`artifacts/`** — **Work artifacts only.** Milestone plans, per-milestone architecture and UI specs, security/performance/CEO reviews, bug reports, and the session log. Everything produced by `/agent-plan` and `/agent-code` lands here.

## The docs/artifacts Split

This is a hard rule enforced across the template: **`docs/` is documentation, `artifacts/` is work**. When editing templates or writing new content, every path reference in a template file must respect this split. Agents read templates and reference material from `docs/` and write instances of that work to `artifacts/`. Never introduce a path that writes work output to `docs/` or a path that looks up a template under `artifacts/`.

## Placeholder Convention

All project-specific content uses `[UPPER_SNAKE_CASE]` tokens in square brackets. Categories: Identity (`[PROJECT_NAME]`, `[PROJECT_TYPE]`), Tech (`[FRAMEWORK]`, `[LANGUAGE]`), Commands (`[DEV_SERVER_CMD]`, `[TEST_CMD]`), Domain (`[DOMAIN_ENTITY]`, `[CORE_MECHANIC]`), Platform (`[TARGET_PLATFORMS]`), Project Structure (`[SCREEN_DIR]`, `[LOGIC_DIR]`), Conventions (`[LOWER_CASE_CONVENTION]`), Persistence (`[SAVE_KEY]`), Testing (`[COVERAGE_TARGET]`), Performance (`[STARTUP_METRIC]`), Process (`[MAX_AGE_DAYS]`). Per-agent AI models are pre-configured in each agent file's YAML frontmatter and are not placeholders.

When editing templates, preserve placeholder tokens — do not replace them with concrete values unless adapting the template for a specific project.

## Agent System Architecture

15 agent roles form a two-stage pipeline.

**Planning Stage** (`/agent-plan`): **Product** (requirements) → **Architecture** + **UI** (design specs in parallel) → **Security** + **Performance** (review architecture in parallel) → **CEO** (final planning-stage review, integrates all prior outputs and issues APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED).

**Engineering Stage** (`/agent-code`): **Coder** (implementation) → **Tester** (automated gate) → **Reviewer** (classifies findings as Defects or Issues). Defects → **Debugger** → **Bug Gatherer** → **Product** (triage). Issues → **Refactor** → **Reviewer** (loop). Then **Product** validates against acceptance criteria.

**One-Off Task Pipeline** (`/agent-task`): for small self-contained work — bug fixes, typos, single-function refactors, dependency bumps — that does not justify a full milestone plan. Coder → Tester → Reviewer (with the same Defect/Issue routing as `/agent-code`) → Product validates against the task description. Bails out with a "run `/agent-plan` first" message if the task implies architectural or cross-cutting work.

**Docs Writer** updates docs after every agent. **Release** handles versioning. **Validator** enforces process. Conflict resolution priority: Product > Architecture > UI.

## Key Files

- `README.md` — Master index with full placeholder reference table and quick start guide
- `root/CLAUDE.md` — The CLAUDE.md template that gets placed in target projects (heavily parameterized)
- `agents/README.md` — Agent roster, interaction diagram, and planning/engineering stage workflows
- `commands/agent-plan.md` — Slash command that orchestrates the Planning Stage end-to-end
- `commands/agent-code.md` — Slash command that orchestrates the Engineering Stage per task
- `docs/README.md` — Documentation index listing all doc templates and their purposes

## Working With This Repo

- All files are markdown — there are no build, lint, or test commands
- Every template file begins with an HTML comment block (`<!-- TEMPLATE INSTRUCTIONS -->`) explaining how to customize it
- Agent files include YAML frontmatter (`name`, `description`) for Claude Code subagent registration; they are self-contained and removing one does not break others
- `root/CLAUDE.md` contains `@import` directives at the bottom referencing docs that should be loaded as context
