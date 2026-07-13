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
`artifacts/architecture/arch-milestone-{N}.md`. Dependencies are irreversible in practice
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
- **`artifacts/`** — all live work: milestone plans, per-milestone architecture and UI specs, security/performance/CEO reviews, bug reports (`artifacts/BUGS.md`), the rolling session log (`artifacts/STANDUP.md`), and every agent's live working state (`artifacts/AGENT_STATE.md`). Everything produced by `/agent-plan` and `/agent-code` lands here.

When in doubt, read `docs/FILE_CONVENTIONS.md` and `artifacts/README.md`.

This structure and the agent workflow were installed by [CAST](https://github.com/Raxvis/CAST).
Adopted with CAST v[CAST_VERSION]

## Memory Imports

These documents are loaded into Claude Code's context at every session start. They
provide the baseline context all agents need. Keep this list lean — every import is
paid in every session. The Directory Conventions section above already covers where
files live; agents read the detailed reference docs on demand by path (the planning
stage reads `docs/PRD.md` on demand regardless of whether it is imported here).

<!-- Core context — keep this -->
@docs/CODE_PATTERNS.md

<!-- Topic-specific context — add a bare import line (like the one above) for the
     one(s) that match your project type, and ignore the rest. These files ship with
     the template and can be edited freely: `@docs/FRONTEND.md`, `@docs/BACKEND.md`,
     `@docs/CLI.md`, `@docs/MOBILE.md`. Paths in backticks here are inert — an import
     only fires as a bare `@path` line, so copy one out to activate it. -->

<!-- On-demand reference — agents read these by path when a task calls for them
     (coder/docs-writer: FILE_CONVENTIONS; coder/reviewer: ERROR_HANDLING; tester:
     TEST_FRAMEWORK; navigation: docs/README.md, artifacts/README.md). Add an import
     line only if your sessions repeatedly need one unprompted:
     `@docs/FILE_CONVENTIONS.md`, `@docs/ERROR_HANDLING.md` -->

<!-- Add once they contain real project content (at install time these are placeholder
     skeletons — importing them pays for hundreds of skeleton lines per session):
     `@docs/PRD.md`, `@docs/CONCEPT.md`, `@docs/ADDITIONAL.md`, `@docs/GLOSSARY.md` -->
