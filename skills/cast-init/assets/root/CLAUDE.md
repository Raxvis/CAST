<!-- TEMPLATE INSTRUCTIONS
  FILE: CLAUDE.md (placed at project root)
  PURPOSE: Provides an AI coding assistant with persistent context about the project.
  This file is intentionally agnostic — it does not assume frontend, backend, CLI,
  mobile, library, or data-pipeline. Topic-specific patterns live in
  docs/FRONTEND.md, docs/BACKEND.md, docs/CLI.md, and docs/MOBILE.md; keep the
  one(s) that match your project and delete the rest. Mobile projects should keep
  both docs/FRONTEND.md and docs/MOBILE.md. Kept topic docs are read on demand
  through task Context Manifests — keeping one does not mean importing it.

  HOW TO CUSTOMIZE:
  - Replace every [PLACEHOLDER] token with project-specific values.
  - Exception: [CAST_VERSION] is stamped automatically by /cast-init at install time
    (the "Adopted with CAST v[CAST_VERSION]" line in Directory Conventions) — leave it as-is.
  - See README.md for the full placeholder reference table.
  - Delete sections not relevant to your project (e.g., Persistence for a stateless service).
  - Leave Memory Imports empty unless a document is needed unprompted in most sessions
    AND cannot be inferred from the code — see the note in that section before adding one.
  - Add project-specific patterns under "Domain-Specific Patterns" as they emerge.
  - This comment block is stripped automatically by /cast-init at install.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] - CLAUDE.md

## Project Overview

[PROJECT_NAME] is a [PROJECT_TYPE] built with **[FRAMEWORK] ([FRAMEWORK_VERSION])**. Targets **[TARGET_PLATFORMS]**.

[ONE_SENTENCE_PITCH]

## Stack & Commands

- **Stack**: [LANGUAGE] (strict mode) on [FRAMEWORK] ([FRAMEWORK_VERSION]); persistence via [PERSISTENCE_LAYER]; packages via [PKG_MANAGER]; tests via [TEST_RUNNER].
- **Dev**: `[DEV_SERVER_CMD]` · **Type check**: `[TYPE_CHECK_CMD]` · **Tests**: `[TEST_CMD]` · **Build**: `[BUILD_CMD]`
- **Debug**: prefer structured logs over `print`-style output so output stays greppable.

## Common Pitfalls

These are universal traps. Topic-specific pitfalls (frontend re-renders, backend N+1 queries, CLI signal handling, mobile app-lifecycle state loss) live in the relevant `docs/FRONTEND.md` / `docs/BACKEND.md` / `docs/CLI.md` / `docs/MOBILE.md`.

- **Hidden mutable state.** Shared state that is silently mutated across module boundaries produces heisenbugs. Prefer immutability and explicit copy-on-write patterns.
- **Silent error swallowing.** Catching errors and returning a default is worse than a crash — it masks the failure mode. Catch only at explicit boundaries and always log.
- **Stringly-typed boundaries.** Anywhere you convert a typed value to a string and back, you lose type safety. Validate at the boundary with a schema or type guard.
- **Stale configuration.** Environment-dependent values (URLs, keys, feature flags) belong in one place. Hard-coding them in multiple files produces drift that is invisible until production.
- **Untested error paths.** The happy path is easy. Write tests for the empty case, the maximum case, and the "upstream dependency broken" case before shipping.

## Project Structure

```
[PROJECT_NAME]/
  src/
    [LOGIC_DIR]                   # Pure [LANGUAGE] business logic — no framework coupling
    [STORE_DIR]                   # Application state (if applicable)
    [COMPONENTS_DIR]              # UI components or service modules
    [CONSTANTS_DIR]               # Constants and configuration
  [PKG_MANIFEST]                  # Dependency manifest
  [TYPE_CONFIG]                   # [LANGUAGE] config
  [FRAMEWORK_CONFIG]              # Framework config
```

Fill in or delete directories to match your actual structure. Reference the authoritative layout in `docs/FILE_CONVENTIONS.md`.

## [LANGUAGE] Style Conventions

Only the conventions a reader could **not** infer from existing code belong here — match the codebase for everything else. Defaults worth stating once:

- Naming: **[LOWER_CASE_CONVENTION]** for variables, functions, and file names; **[PASCAL_CASE_CONVENTION]** for types and exported constructs; **[UPPER_SNAKE_CONVENTION]** for module-level constants.
- Explicit return types on exported functions; no unchecked/unsafe types.
- All business logic lives in pure [LANGUAGE] modules with no framework coupling, testable independently.
- Group files by feature or domain, not by layer, once a directory outgrows ~15 files.

## Domain-Specific Patterns

_Add domain-specific patterns here that are unique to your project. Delete this placeholder
section and replace it with patterns relevant to your domain. Examples: custom data types,
calculation engines, scheduling logic, workflow state machines, real-time update loops, or
any business logic that warrants a documented convention._

## Persistence

_Keep this section if your project has persistent state. Delete it for stateless services._

Data is persisted via [PERSISTENCE_LAYER] using the key `[SAVE_KEY]`.

- Include a `version` field in persisted data to enable forward migration.
- Always handle missing or corrupt data gracefully by falling back to defaults.
- Migrations must be idempotent — the same migration can run twice without damaging data.

## Git & Dependencies

- Feature branches off `main` (`feature/…`, `fix/…`, `refactor/…`), merged via pull request; short imperative commit messages.
- Add dependencies with `[PKG_ADD_CMD] <package>` — and justify every new one in the Architect's Decisions Log in `artifacts/milestone-{N}-{slug}/architecture.md`. Dependencies are irreversible in practice and compound over time; resist adding them.

## Directory Conventions

The project uses a strict split between reference material, document templates, and work artifacts:

- **`docs/`** — reference only: requirements, conventions, design rationale. Never receives work artifacts. One deliberate exception: `docs/CHANGELOG.md` is a long-lived project register maintained by the `/cast-release` skill (see `docs/README.md` → Project Registers and Reference Logs).
- **`templates/`** — reusable document templates (architecture, UI spec, milestone files). Agents copy them into `artifacts/` as instances; never filled in place.
- **`artifacts/`** — all live work, **grouped by milestone**: each `milestone-{N}-{slug}/` directory holds that milestone's README (definition), `architecture.md`, `ui.md`, `reviews/`, per-task files (`tasks/task-{T}-{slug}.md` — one isolated file per task, with its Context Manifest and Handoff Log), and per-bug files (`bugs/`). Cross-milestone state lives at the root: the bug index (`artifacts/BUGS.md`), the rolling session log (`artifacts/STANDUP.md`), the orchestrator-written state tables (`artifacts/AGENT_STATE.md` — no agent reads it), and the `/cast-doctor` health report (`artifacts/DOCTOR.md`, created on first run and overwritten per run). One-off `/agent-task` work goes under `artifacts/one-off/`. Everything produced by the pipelines lands here.

When in doubt, read `docs/FILE_CONVENTIONS.md` and `artifacts/README.md`.

This structure and the agent workflow were installed by [CAST](https://github.com/Raxvis/CAST).
Adopted with CAST v[CAST_VERSION]

## Memory Imports

Bare `@path` lines below load into every session **and every subagent spawn** — the most
expensive real estate in the project. The list ships empty on purpose; add an import only
for a document that is needed unprompted in most sessions **and** cannot be inferred from
the code (rationale: `docs/DESIGN_RATIONALE.md` → "Memory Imports ship empty").

<!-- Add bare import lines here (comments are inert; an import only fires as a bare
     `@path` line at the left margin), e.g.:
     @docs/GLOSSARY.md — domain terms that appear nowhere in the source -->

