# Phase 1 — Discovery: full checklist and inventory template

Crawl the project and map everything relevant. Use Read, Glob, and Grep. Build an internal inventory with the categories below.

## 1.1 — Claude Code state

- Does `CLAUDE.md` exist at the project root? Read it. Note its section list and any custom content. If its CAST section carries an `Adopted with CAST v<X.Y.Z>` line, record that version — this is the **canonical version stamp** written at install time, and the value SKILL.md's Upgrades rule compares against this skill's `metadata.version`.
- Is the project a git repository (`git rev-parse --is-inside-work-tree`)? If not, flag it in the inventory — Phase 5's preflight and rollback path depend on git (see SKILL.md safety rule 8).
- Does `.claude/agents/` exist? List every file. For each, parse YAML frontmatter and note `name`, `description`, `model`.
- Does `.claude/skills/` exist? List every skill directory. Note the skill name (directory name) and summarize the first 30 lines of each `SKILL.md`. If `agent-plan/`, `agent-code/`, or `agent-task/` are present, this is a prior CAST 1.x install — treat these as existing counterparts for update-in-place. If `CLAUDE.md` carries no version stamp (older installs predate it), inventory the install as "no version found" — that is accurate: installed pipeline skills carry no version field, so there is nothing else to read.
- Does `.claude/commands/` exist? List every file. Note the command name (filename minus `.md`) and summarize the first 30 lines of each. If `agent-plan.md`, `agent-code.md`, or `agent-task.md` are present, this is a pre-1.0 CAST install — the three pipelines were commands before they became skills. Flag them for the skills migration path in `execution.md`.
- Does `.claude/settings.json` exist? Note its structure (permissions, hooks, env).

## 1.2 — Existing agentic workflow artifacts

Look outside `.claude/` too. Agentic workflows are sometimes scattered:

- **Glob patterns**: `agents/*.md`, `agent-*.md`, `planner.md`, `coder.md`, `reviewer.md`, `architect.md`, `designer.md`, `tester.md`, `qa.md`, `bug*.md`, `prd*.md`, `roadmap*.md`, `specs/**/*.md`, `workflow/**/*.md`
- **Directory patterns**: `features/`, `milestones/`, `specs/`, `artifacts/`, `workflow/`, `agents/`, `planning/`, `engineering/`
- **Legacy pre-0.3.0 CAST**: the old name for `artifacts/` was `features/`. If the project has a `features/` directory with files matching CAST's naming patterns (`milestone-*.md`, `arch-milestone-*.md`, `ceo-review-*.md`), treat it as a CAST install that needs renaming.

For each matched file, read the first 20 lines and classify:

- Is it a subagent definition (has YAML frontmatter with `name:` and `description:`)?
- Is it a pipeline definition (lives under `.claude/skills/` or `.claude/commands/`, or is a free-form Markdown instruction file)?
- Is it a planning artifact (milestone plan, architecture doc, UI spec, review)?
- Is it a work log (standup, bug tracker)?
- Is it reference material (PRD, style guide, architecture decision record)?

## 1.3 — Documentation state

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
  - Model policy / AI model selection / model upgrade guide → `docs/MODEL_OPTIMIZATION.md`
  - CHANGELOG / release notes → `docs/CHANGELOG.md`
  - Asset registry / media inventory → `docs/ASSETS.md`
  - MVP launch checklist → `docs/MVP_LAUNCH.md`
  - Frontend patterns → `docs/FRONTEND.md`
  - Backend / API patterns → `docs/BACKEND.md`
  - CLI patterns → `docs/CLI.md`
  - Mobile patterns → `docs/MOBILE.md`
- Is there a top-level `README.md`, `CHANGELOG.md`, or `TROUBLESHOOTING.md`? Note their presence.

## 1.4 — Project metadata

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
- **Framework version** — from the dependency pin, if a framework was detected
- **Test command** — from manifest scripts or convention (`npm test`, `pytest`, `cargo test`, `go test ./...`, etc.)
- **Test runner** — the tool behind the test command (Vitest, Jest, pytest, go test, etc.)
- **Dev command** — if present
- **Build command** — if present
- **Type check command** — if applicable (`tsc --noEmit`, `mypy`, etc.)
- **Package manager** — `npm`, `pnpm`, `yarn`, `pip`, `poetry`, `cargo`, `go`, `bundle`, etc.
- **Package manifest** — the manifest file itself (`package.json`, `pyproject.toml`, `Cargo.toml`, …)
- **Dependency add command** — from the package manager (`npm install`, `pnpm add`, `poetry add`, `cargo add`, …)
- **Config files** — type-checker config (`tsconfig.json`, `mypy.ini`) and framework config (`next.config.js`, `vite.config.ts`, `metro.config.js`) if present
- **Persistence layer** — best guess from dependencies (SQLite, Postgres, Mongo, Redis, localStorage, flat files) or "none detected"
- **State / navigation libraries** — if the dependency list names one (Redux, Zustand, React Router, GoRouter, …)
- **Target platforms** — from the project type and manifests: web, iOS, Android, desktop, server, CLI (e.g. a React Native app → "iOS, Android"; a CLI → "macOS / Linux / any [LANGUAGE] runtime")

These feed the substitution pass directly: each maps to a placeholder (`[PROJECT_NAME]`, `[LANGUAGE]`, `[FRAMEWORK]`, `[FRAMEWORK_VERSION]`, `[TEST_CMD]`, `[TEST_RUNNER]`, `[DEV_SERVER_CMD]`, `[BUILD_CMD]`, `[TYPE_CHECK_CMD]`, `[PKG_MANAGER]`, `[PKG_MANIFEST]`, `[PKG_ADD_CMD]`, `[TYPE_CONFIG]`, `[FRAMEWORK_CONFIG]`, `[PERSISTENCE_LAYER]`, `[STATE_LIBRARY]`, `[NAVIGATION_LIBRARY]`, `[TARGET_PLATFORMS]`). Record "unknown" rather than guessing — unknowns become Phase 3 questions or report TODOs, never invented values.

### Monorepos and workspaces

Detect workspace layouts before settling the metadata above: `pnpm-workspace.yaml`, a `workspaces` field in the root `package.json`, a `[workspace]` table in the root `Cargo.toml`, a `go.work` file, or equivalent (Nx/Turborepo/Lerna configs are corroborating signals). If the project is a workspace:

- **Default to a root-level install.** CAST installs once at the repository root — one `CLAUDE.md`, one `.claude/`, one `docs/`/`templates/`/`artifacts/` — not per package. Only deviate if the user explicitly asks for a package-scoped install.
- **Prefer workspace-wide values** for the metadata placeholders: the root manifest's `name` for `[PROJECT_NAME]`, workspace-wide commands (`pnpm -r test`, `cargo test --workspace`, `go test ./...`) for `[TEST_CMD]`/`[BUILD_CMD]`, and so on.
- **Turn manifest ambiguity into Phase 3 Ask items.** When the root manifest lacks a value and multiple packages could supply it (which package's name is `[PROJECT_NAME]`? whose framework is `[FRAMEWORK]`? which test command is canonical?), do not pick one silently — record each ambiguity in the inventory's open questions and surface it as an Ask in the Phase 3 plan, listing the candidate packages.
- **Sweep the workspace members for nested Claude Code config.** The 1.1 checks cover only the repository root; in a workspace, also glob each member package (bounded to the member directories detected above — e.g. `packages/*/.claude/**`, `apps/*/.claude/**`, and `<member>/CLAUDE.md` for every member) for per-package `.claude/` directories (agents, skills, commands, settings) and nested `CLAUDE.md` files. Inventory each hit like its root-level counterpart in 1.1. Any nested config found becomes a **Phase 3 Ask item** — consolidate it into the root install or leave it in place per package — never silently absorb or ignore it.
- Record the workspace tool and member-package list in the inventory. Multiple languages across packages usually mean project type **Mixed**.

Detect project type:

- **Frontend** — presence of React, Vue, Svelte, Angular, Next.js, Nuxt, SvelteKit, plain SPA setups. Web-only and desktop-only rendered UIs land here.
- **Backend** — presence of Express, Fastify, Django, Flask, FastAPI, Rails, Spring, Gin, Echo, Actix
- **CLI** — `bin` entry in package.json, `cmd/` directory in Go, `#!/usr/bin/env` shebang files
- **Library** — manifest has `main`/`exports`/`lib.rs` without a `bin`, no dev server command
- **Data pipeline** — Airflow, dbt, Dagster, Prefect, Spark
- **Mobile** — native or cross-platform mobile app targeting iOS / Android. Signals: React Native, Expo, Flutter, SwiftUI, Jetpack Compose, .NET MAUI, Ionic / Capacitor, native Swift (`.xcodeproj`, `Package.swift`), native Kotlin (`build.gradle` with Android plugin), `ios/` or `android/` directories at the project root, `Info.plist`, `AndroidManifest.xml`. **Mobile projects are also Frontend** — they render a UI — so classify them as `mobile` (for MOBILE.md) AND as requiring `docs/FRONTEND.md`. Both topic docs apply.
- **Mixed** — multiple of the above (common for full-stack apps, monorepos, or apps with both a mobile client and a web dashboard)

Read the top of the existing `README.md` for the project's one-sentence pitch. If none exists, note that you'll need to prompt the user for it during Phase 3.

## 1.5 — Source code structure

- Glob top-level directories and identify where source lives (`src/`, `lib/`, `app/`, `cmd/`, `pkg/`, etc.)
- Map source subdirectories to their roles where identifiable — business logic (`[LOGIC_DIR]`), state management (`[STORE_DIR]`), UI components (`[COMPONENTS_DIR]`), constants/config (`[CONSTANTS_DIR]`). Record only mappings the directory names or contents make clear; leave the rest unknown.
- Note naming conventions: camelCase vs snake_case vs PascalCase vs kebab-case for file names (`[LOWER_CASE_CONVENTION]`, `[PASCAL_CASE_CONVENTION]`, `[UPPER_SNAKE_CONVENTION]`)
- Note any existing test directory pattern (`tests/`, `test/`, `spec/`, colocated `*.test.ts`, etc.)
- If there's a dominant language, note the file extension for source files (`[EXT]`)
- Note any CI config (`.github/workflows/`, `.gitlab-ci.yml`, `circle.yml`) — helps confirm test/build commands

**Domain tokens are asked, not detected.** `[DOMAIN_ENTITY]`, `[RESOURCE_TYPE]`, `[CORE_MECHANIC]`, `[PROGRESSION_UNIT]`, `[SAVE_KEY]`, and `[ONE_SENTENCE_PITCH]` (when no README pitch exists) cannot be inferred from code. Batch them into the Phase 3 plan's Ask section when a file that carries them is being installed; if the user declines to answer, leave the token and list it in the Phase 7 report.

## 1.6 — Write the inventory

Write your findings to `artifacts/adoption-inventory.md` (create the directory if needed, but note in Phase 3 that this directory may later be renamed if you propose moving it).

**Prior adoption records**: if any `artifacts/adoption-inventory.md`, `adoption-plan.md`, or `adoption-report.md` already exists from an earlier run, do not silently overwrite it — those files are the audit trail of the earlier install. **First check for an interrupted run**: a pre-existing `adoption-plan.md` whose progress ledger has UNCHECKED entries is a **resume candidate, not an archive candidate** — do not archive or rename it. Preserve it in place (and note the interrupted run in the inventory) so the resume path in `execution.md` 5.1 can cross-check its ledger checkmarks. Only archive plan files whose ledger is fully checked (a completed prior run) or that predate the ledger format entirely. Archive each qualifying file by renaming it with a date suffix (e.g. `adoption-report-2026-07-11.md`, using the prior file's generation date); in interactive mode you may instead ask the user to confirm an overwrite.

Use this structure:

```markdown
# CAST Adoption Inventory
Generated: <ISO date>

## Claude Code state
- `CLAUDE.md`: <present/absent>, <line count>, sections: <list>
- Installed CAST version: <from the `Adopted with CAST v…` stamp | none found>
- Git repository: <yes / no — no rollback safety net>
- `.claude/agents/`: <N files> — list with detected roles
- `.claude/skills/`: <N skills> — list with detected purposes (note any prior CAST pipelines)
- `.claude/commands/`: <N files> — list with detected purposes (note any pre-1.0 CAST commands)
- `.claude/settings.json`: <present/absent>

## Existing agentic workflow (outside .claude/)
- <path>: <classification — agent / pipeline / artifact / reference>, <detected role>

## Existing documentation
- <path>: <maps to CAST: <filename> | no CAST equivalent | reference>

## Project metadata
- **Name**: <detected or "unknown — prompt user">
- **Language**: <detected>
- **Framework**: <detected or "none"> (version: <detected or "—">)
- **Project type**: <frontend / backend / CLI / library / mobile / data / mixed / unknown>
- **Test command**: <detected> (runner: <detected or "—">)
- **Dev command**: <detected>
- **Build command**: <detected>
- **Type check command**: <detected>
- **Package manager**: <detected> (manifest: <file>, add command: <cmd>)
- **Config files**: <type-checker / framework / bundler configs or "—">
- **Persistence layer**: <detected or "none detected">
- **State / navigation libraries**: <detected or "—">
- **Target platforms**: <detected>
- **Workspace / monorepo**: <none | tool + member packages, with any manifest ambiguities flagged as open questions; list any nested per-package `.claude/` dirs or `CLAUDE.md` files found by the member sweep — each is a Phase 3 Ask item>

## Source structure
- Top-level directories: <list>
- Source directory: <best guess>
- Directory role mapping: <logic / store / components / constants, where identifiable>
- Test directory: <best guess>
- File naming convention: <best guess>
- Source file extension: <best guess>

## Detected customizations to preserve
- <description of any non-standard agent, pipeline, or doc the user has built>

## Open questions for Phase 3
- <any ambiguity that needs user input to resolve>
```
