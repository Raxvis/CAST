<!-- TEMPLATE INSTRUCTIONS
  FILE: README.md
  PURPOSE: This file serves as the master navigation index for all project documentation.
  It provides a single entry point so that any contributor (human or AI agent) can quickly
  locate the relevant document for a given concern.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with the name of your project throughout.
  - Add, remove, or re-categorize documents to match the actual files present in your project.
  - Update the brief descriptions so they reflect the real content of each document.
  - Remove any categories or entries that are not applicable to your project.
  - If you add new documentation files, register them here immediately.
-->

# [PROJECT_NAME] — Documentation Index

This file is the entry point for all project documentation. If you are looking for a
specific piece of information, start here to find the correct document.

> **Scope of this directory:** `docs/` holds **reference material only** — requirements,
> conventions, and design rationale. Reusable document templates live in `templates/`; work
> artifacts (milestone plans, per-milestone architecture and UI specs, bug reports, CEO
> reviews, session logs) live in `artifacts/`. See `artifacts/README.md` for the full layout
> and the root `README.md` for the split rationale.

---

## Design Documents

These documents describe what the project is, why it exists, and how it is designed.

| File | Description |
|------|-------------|
| `CONCEPT.md` | High-level project vision, core loop, and design pillars. Start here for a first-principles understanding of the project. |
| `PRD.md` | Product Requirements Document. Defines features, user stories, acceptance criteria, success metrics, and constraints. |
| `ADDITIONAL.md` | Extended design details that expand on the PRD. Covers systems, rules, and specifications too detailed for the PRD itself. |
| `GLOSSARY.md` | Canonical definitions for all domain-specific terms used across documents. Resolve any naming ambiguities here. |
| `DESIGN_RATIONALE.md` | Decision log recording significant design choices, the reasoning behind them, and the trade-offs accepted. |

---

## Technical Documents

These documents describe how the project is built and the conventions that govern the codebase.

| File | Description |
|------|-------------|
| `CODE_PATTERNS.md` | Coding conventions, naming rules, module structure, component lifecycle, and state management patterns. |
| `FILE_CONVENTIONS.md` | Rules governing where each type of file and document belongs in the repository. Read before creating any new file. |
| `ERROR_HANDLING.md` | Guidelines for handling errors across all error categories. Defines principles, patterns, and user-facing message standards. |
| `TEST_FRAMEWORK.md` | Testing strategy, test runner setup, file conventions, coverage requirements, and best practices. |

---

## Topic-Specific Technical Documents

These four files are scoped to a project type rather than being universal. **Keep the
one(s) that match your project and delete the rest.** The shipped `CLAUDE.md` has
commented `@import` lines for all four — uncomment the relevant line(s) to load the
matching patterns into session context.

| File | Description |
|------|-------------|
| `FRONTEND.md` | User-facing visual interfaces (web, mobile, desktop GUI, game UI). Covers navigation, state management, component patterns, performance budgets, input handling, platform differences. |
| `BACKEND.md` | API servers, message workers, scheduled jobs, and data pipelines. Covers request/response boundaries, persistence, HTTP status semantics, authentication, middleware ordering, observability, and background work. |
| `CLI.md` | Command-line tools and terminal utilities. Covers argv parsing, stdin/stdout/stderr discipline, exit codes, terminal formatting, cross-platform concerns, signal handling, and interactive prompts. |
| `MOBILE.md` | Native and cross-platform mobile apps (iOS, Android, React Native, Expo, Flutter, SwiftUI, Jetpack Compose). Covers the mobile-specific delta on top of `FRONTEND.md`: app lifecycle, OS permissions, native bridges, offline-first sync, local storage tiers, deep links, push notifications, device variety, and release engineering. |

Projects that span multiple categories (e.g., a full-stack app with a backend API and a
web frontend) can keep more than one. Mobile apps should keep **both** `FRONTEND.md` and
`MOBILE.md` — the first covers the shared UI patterns, the second covers mobile-only
concerns on top. Projects that don't fit any category can delete all four and write their
own.

---

## Setup and Configuration

These files help with first-time setup and Claude Code configuration. They are reference
material — every project uses them the same way; no per-project customization needed.

| File | Description |
|------|-------------|
| `FIRST_RUN.md` | Interactive checklist to run in Claude Code after a fresh install. Verifies that subagents load, slash commands register, and the pipeline runs end-to-end. |
| `CLAUDE_CODE_SETTINGS.md` | Reference for `.claude/settings.json` — explains permission rules, environment variables, and hooks, with a recommended starting configuration. |

---

## Project Registers and Reference Logs

These documents live in `docs/` because they are reference material maintained over the
life of the project rather than per-work-item artifacts.

| File | Description |
|------|-------------|
| `CHANGELOG.md` | Chronological log of notable changes across releases and milestones. Maintained by the release agent. |
| `ASSETS.md` | Registry of all project assets (images, fonts, etc.) with status and source information. |
| `MVP_LAUNCH.md` | Checklist and criteria for the initial public release. |

Live work tracking — the active bug tracker and the rolling session log — lives in
`artifacts/`, not here:

- `artifacts/BUGS.md` — active bug tracker (Bug Gatherer files, Debugger investigates)
- `artifacts/STANDUP.md` — rolling session progress log

---

## Templates

Reusable document templates live in the top-level **`templates/`** directory, not here — see
[`templates/README.md`](../templates/README.md) for the full index. Agents read them and
produce **instances** under `artifacts/`. Never fill in a template in place — copy it to the
appropriate `artifacts/` subdirectory first.

| File | Description | Instance Location |
|------|-------------|-------------------|
| `templates/ARCH_MODULE.md` | Template for documenting a single code module | `artifacts/architecture/` |
| `templates/ARCH_SYSTEM.md` | Template for documenting a high-level system | `artifacts/architecture/` |
| `templates/ARCH_DATA_SCHEMA.md` | Template for documenting a data schema or save format | `artifacts/architecture/` |
| `templates/UI_SPEC.md` | Template for specifying a UI screen or component | `artifacts/ui-specs/` |
| `templates/MILESTONE_DEFINITION.md` | Template for the milestone definition file (what and why) | `artifacts/milestones/milestone-{N}-{slug}.md` |
| `templates/MILESTONE_TASKS.md` | Template for the task breakdown file (how; one row per task) | `artifacts/milestones/milestone-{N}-{slug}-tasks.md` |
| `templates/MILESTONE_COMPLETION.md` | Template for milestone completion reports | `artifacts/milestones/milestone-{N}-{slug}-completion.md` |
| `templates/MILESTONE_VALIDATION.md` | Template for milestone acceptance records | `artifacts/milestones/milestone-{N}-{slug}-validation.md` |

---

## How to Use This Documentation

1. **Starting a new feature?** Run `/agent-plan`. Read `PRD.md` for requirements and `CODE_PATTERNS.md` for conventions.
2. **Confused by a term?** Check `GLOSSARY.md` first.
3. **Creating a new file?** Read `FILE_CONVENTIONS.md` before deciding where to put it.
4. **Documenting a design decision?** Add an entry to `DESIGN_RATIONALE.md`.
5. **Found a bug?** Log it in `artifacts/BUGS.md` (not here — `docs/` is reference-only).
6. **Completing a milestone?** Copy `templates/MILESTONE_VALIDATION.md` into `artifacts/milestones/` and fill it in there.

---

_Last updated: [YYYY-MM-DD]_
