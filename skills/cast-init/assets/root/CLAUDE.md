<!-- TEMPLATE INSTRUCTIONS
  FILE: CLAUDE.md (placed at project root)
  PURPOSE: Provides an AI coding assistant with persistent context about the project.
  This file is intentionally agnostic — it does not assume frontend, backend, CLI,
  mobile, library, or data-pipeline. Topic-specific patterns live in
  docs/FRONTEND.md, docs/BACKEND.md, docs/CLI.md, and docs/MOBILE.md; keep the
  one(s) that match your project and delete the rest. Mobile projects should
  import both docs/FRONTEND.md and docs/MOBILE.md.

  HOW TO CUSTOMIZE:
  - Replace every [PLACEHOLDER] token with project-specific values.
  - Exception: [CAST_VERSION] is stamped automatically by /cast-init at install time
    (the "Adopted with CAST v[CAST_VERSION]" line in Directory Conventions) — leave it as-is.
  - See README.md for the full placeholder reference table.
  - Delete sections not relevant to your project (e.g., Persistence for a stateless service).
  - Update Memory Imports to match your actual docs and to include the topic-specific
    doc(s) your project needs (FRONTEND, BACKEND, CLI, MOBILE).
  - Add project-specific patterns under "Domain-Specific Patterns" as they emerge.
  - This comment block is stripped automatically by /cast-init at install.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] - CLAUDE.md

## Project Overview

[PROJECT_NAME] is a [PROJECT_TYPE] built with **[FRAMEWORK] ([FRAMEWORK_VERSION])**. Targets **[TARGET_PLATFORMS]**.

[ONE_SENTENCE_PITCH]

## Tech Stack

- **Framework**: [FRAMEWORK] ([FRAMEWORK_VERSION])
- **Language**: [LANGUAGE] (strict mode)
- **Persistence**: [PERSISTENCE_LAYER]
- **Package Manager**: [PKG_MANAGER]
- **Test Runner**: [TEST_RUNNER]
- **Platforms**: [TARGET_PLATFORMS]
- **Build**: `[DEV_SERVER_CMD]` (dev) / `[BUILD_CMD]` (production)

## Build & Test

- **Dev**: `[DEV_SERVER_CMD]`
- **Type check**: `[TYPE_CHECK_CMD]`
- **Tests**: `[TEST_CMD]`
- **Production build**: `[BUILD_CMD]`
- **Debug**: Use the framework's dev tooling or runtime logging. Prefer structured logs over `print`-style output so output stays greppable.

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

> **Note:** Bracketed names in code examples below (e.g., `[MyType]`, `[doAction]`) are
> illustrative example identifiers, not project placeholders. They show naming patterns
> you should follow using your own project-specific names.

- **[LOWER_CASE_CONVENTION]** for variables, functions, and file names
- **[PASCAL_CASE_CONVENTION]** for types, interfaces, and exported constructs
- **[UPPER_SNAKE_CONVENTION]** for module-level constants
- Prefer structured type declarations over anonymous shapes for object types
- Prefer union/alias constructs for non-object types
- Explicit return types on all exported functions
- No unchecked/unsafe types — use proper types or a safe unknown equivalent
- All business logic lives in pure [LANGUAGE] modules with no framework coupling, testable independently

```
// Pure logic module pattern
export interface [DomainType] {
  [field_one]: [FieldType]
  [field_two]: [FieldType]
}

const [CONSTANT_NAME]: [Type] = [value]

function [internalHelper]([param]: [DomainType]): [DomainType] {
  // internal helper — not exported
}

export function [publicOperation](a: [DomainType], b: [DomainType]): [DomainType] {
  // ...
}
```

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

## Git Workflow

- **Branching**: feature branches off `main`, merged via pull request.
- **Branch naming**: `feature/description`, `fix/description`, `refactor/description`.
- **Commits**: short imperative messages ("Add X", "Fix Y", "Refactor Z").
- **Ignore**: build outputs, dependency directories, local environment files (already in `.gitignore`).

## Dependencies

Manage with `[PKG_MANAGER]`. Add new dependencies:

```
[PKG_ADD_CMD] <package>
```

Every new dependency must be justified in the Architect's Decisions Log in
`artifacts/milestone-{N}-{slug}/architecture.md`. Dependencies are irreversible in practice
and compound over time — resist adding them.

Current dependencies (see `[PKG_MANIFEST]`):
- **[FRAMEWORK]** — core framework
- **[PERSISTENCE_LAYER]** — persistence layer
- **[TEST_RUNNER]** — test runner

## File Naming

- [LOWER_CASE_CONVENTION] for source files: `[example-module].[EXT]`, `[example-helper].[EXT]`
- [PASCAL_CASE_CONVENTION] for exported constructs: `[ExampleType]`, `[ExampleService]`
- Group by feature or domain, not by layer, once the codebase outgrows ~15 files per directory.

## Directory Conventions

The project uses a strict split between reference material, document templates, and work artifacts:

- **`docs/`** — reference only: requirements, conventions, design rationale. Never receives work artifacts. One deliberate exception: `docs/CHANGELOG.md` is a long-lived project register maintained by the release agent (see `docs/README.md` → Project Registers and Reference Logs).
- **`templates/`** — reusable document templates (architecture, UI spec, milestone files). Agents copy them into `artifacts/` as instances; never filled in place.
- **`artifacts/`** — all live work, **grouped by milestone**: each `milestone-{N}-{slug}/` directory holds that milestone's README (definition), `architecture.md`, `ui.md`, `reviews/`, per-task files (`tasks/task-{T}-{slug}.md` — one isolated file per task, with its Context Manifest and Handoff Log), and per-bug files (`bugs/`). Cross-milestone state lives at the root: the bug index (`artifacts/BUGS.md`), the rolling session log (`artifacts/STANDUP.md`), every agent's live working state (`artifacts/AGENT_STATE.md`), and the `/cast-doctor` health report (`artifacts/DOCTOR.md`, created on first run and overwritten per run). One-off `/agent-task` work goes under `artifacts/one-off/`. Everything produced by the pipelines lands here.

When in doubt, read `docs/FILE_CONVENTIONS.md` and `artifacts/README.md`.

This structure and the agent workflow were installed by [CAST](https://github.com/Raxvis/CAST).
Adopted with CAST v[CAST_VERSION]

## Memory Imports

Bare `@path` lines below are loaded into context at every session start **and into every
subagent the pipeline spawns**. That second part is what makes this list expensive: an
import is paid once per session plus once per stage, so a 250-line document costs more
across one milestone than most agent definitions do.

**This list ships empty on purpose.** CAST v2 imported `docs/CODE_PATTERNS.md`
unconditionally, which contradicted its own Context Inference Bar
(`docs/MODEL_OPTIMIZATION.md`): on Opus 4.8+ and Sonnet 5+, conventions that merely restate
what the codebase already shows — naming, file layout, function ordering — are inferred from
the code, and writing them down again buys nothing but weight. Agents that need conventions
get them through each task's Context Manifest, which cites *sections* rather than files.

**Add an import only when a document is needed unprompted in most sessions and cannot be
inferred from the code.** Good candidates: a genuinely non-obvious domain convention, a
project glossary whose terms appear nowhere in the source, a compliance constraint. Then
delete it again if `/cast-doctor` flags it as inferable.

<!-- Add bare import lines here, e.g.:
     @docs/CODE_PATTERNS.md      — conventions a reader could NOT infer from the code
     @docs/GLOSSARY.md           — domain terms that appear nowhere in the source
     @docs/FRONTEND.md | BACKEND.md | CLI.md | MOBILE.md  — your project type's patterns

     Paths in comments are inert; an import only fires as a bare `@path` line at the
     left margin. Everything else is read on demand by path: FILE_CONVENTIONS,
     ERROR_HANDLING, TEST_FRAMEWORK, PRD, CONCEPT, docs/README.md, artifacts/README.md. -->
