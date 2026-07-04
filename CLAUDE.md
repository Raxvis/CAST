# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is **CAST — Claude Agent Staged Team**, a multi-agent AI-assisted development workflow template. It contains no source code — only markdown template files with `[PLACEHOLDER]` tokens that are replaced when adapting the template to a new project. CAST establishes agent roles, documentation structure, and development conventions for Claude Code-based development.

## Directory Structure

- **`root/`** — Files copied to a target project's root (CLAUDE.md template)
- **`agents/`** — 15 agent role definitions plus a master `README.md` (product, architect, ui, security, performance, ceo, coder, tester, reviewer, debugger, refactor, bug-gatherer, docs-writer, release, validator). Each file includes YAML frontmatter for Claude Code subagent auto-discovery and defines one agent's purpose, authority, inputs, outputs, and decision log. Copied to `.claude/agents/` in the target project
- **`commands/`** — Slash command definitions (`/agent-plan`, `/agent-code`, `/agent-task`) that orchestrate the planning and engineering stages of the agent workflow plus a mini pipeline for one-off tasks. Copied to `.claude/commands/` in the target project
- **`docs/`** — **Reference material only.** Requirements, conventions, and design rationale (PRD, code patterns, file conventions, glossary, etc.). Never receives work artifacts.
- **`templates/`** — **Document templates only.** Reusable skeletons (architecture templates, UI spec template, milestone templates) that agents copy into `artifacts/` as instances. Never filled in place.
- **`artifacts/`** — **Work artifacts only.** Milestone plans, per-milestone architecture and UI specs, security/performance/CEO reviews, bug reports, and the session log. Everything produced by `/agent-plan` and `/agent-code` lands here.

## The docs/templates/artifacts Split

This is a hard rule enforced across the template: **`docs/` is documentation, `templates/` is reusable document skeletons, `artifacts/` is work**. When editing templates or writing new content, every path reference in a template file must respect this split. Agents read reference material from `docs/`, read document templates from `templates/`, and write instances of that work to `artifacts/`. Never introduce a path that writes work output to `docs/` or `templates/`, or a path that looks up a template under `docs/` or `artifacts/`.

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

## Release and Tagging Policy

Whenever the template version is bumped, the new version must be tagged and released on GitHub at the same time the commit is pushed. This is a hard rule, not a preference — `PROMPT.md` references the template version, and downstream users rely on GitHub tags to pin a known-good revision. A push without a corresponding tag leaves the canonical version floating and breaks reproducible installs.

**A version bump is any change to one of the following synchronized locations:**

- `README.md` — the version badge and the `Current template version` hero line
- `PROMPT.md` — the `Template version targeted` header
- `CHANGELOG.md` — a new version entry

All three of these must land in the same commit. A commit that bumps one without the others is incomplete and should not be pushed.

**Release checklist (run every time the version changes):**

1. Update all three locations above in a single commit.
2. Add a `CHANGELOG.md` entry for the new version, following the existing format (Added / Changed / Removed / Migration subsections as applicable). The entry must describe every substantive change since the prior version, not just the new feature.
3. Commit the version bump with a message that starts with the new version number (e.g. `"Release v<NEW>: ..."`) so the tag-creation step can use the commit as the tag target.
4. Push the commit to `origin main`.
5. **Immediately after pushing**, create an annotated git tag at the same commit matching the new version:
   ```bash
   git tag -a v<NEW> -m "CAST v<NEW>" <commit-sha>
   git push origin v<NEW>
   ```
   The tag name is `v` followed by the semver string. Use an annotated tag (`-a`), never a lightweight tag — annotated tags carry the tagger, date, and message and are what GitHub Releases consume.
6. **Immediately after pushing the tag**, create a GitHub Release at that tag with the release notes pulled from the corresponding `CHANGELOG.md` entry. The new entry is always the topmost version section, so extract everything from the first `## [` heading up to (but not including) the second, drop the heading line itself, and pass the result to `gh release create`:
   ```bash
   awk '/^## \[/{n++} n==1' CHANGELOG.md | sed '1d' > /tmp/notes.md
   cat /tmp/notes.md   # MUST be non-empty and match the <NEW> entry — do not publish blank notes
   gh release create v<NEW> \
     --title "CAST v<NEW>" \
     --notes-file /tmp/notes.md \
     --latest
   rm /tmp/notes.md
   ```
   Do not use a single awk range pattern like `awk '/^## \[<NEW>\]/,/^## \[/'` — the heading line matches both the start and end expressions, so awk emits only that one line and the pipeline produces an empty notes file.
   The `--latest` flag marks this as the repo's latest release (what `https://github.com/Raxvis/CAST/releases/latest` redirects to). Omit `--latest` only for patch releases of a non-current minor version. Do NOT pass `--target <sha>` — `gh` expects a branch name there, and the tag already points at the right commit.
7. Verify: `gh release view v<NEW>` should show the release notes, and `git tag -l` should list the new tag. If either is missing, finish the release before moving on.

Throughout these steps, replace `<NEW>` with the actual new semver string (e.g. `0.8.2`) and `<commit-sha>` with the full or short SHA of the version-bump commit.

**Do not do any of the following:**

- Push a version-bump commit without creating the matching tag and release in the same session.
- Bump the version in some locations but not others. All three synchronized locations must match.
- Use a lightweight tag (`git tag v<NEW> <sha>` without `-a`). Always use an annotated tag.
- Skip the GitHub Release step because "the tag exists". The tag and the Release are separate artifacts; downstream tooling depends on both.
- Bump the version without a `CHANGELOG.md` entry. Every tag must have a corresponding CHANGELOG section the release notes can cite.

**When not to bump:** content changes that do not affect the template's externally visible behavior (README prose tweaks, typo fixes, internal refactors of agent decision logs) do not require a version bump. Bump only when one of these is true:

- A new file is added that users would import or reference
- An existing file's public contract changes (agent outputs, command stages, template slot names)
- A file is renamed, moved, or removed
- A bug in the adoption prompt is fixed in a way users should re-run with
- The workflow gains or loses an agent, command, or stage

If in doubt, bump — the cost of an unnecessary patch release is much lower than the cost of a silent behavior change reaching users at `main`.
