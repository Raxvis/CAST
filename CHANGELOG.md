# Template Changelog

This file tracks changes to the multi-agent workflow **template itself**. It is separate from `docs/CHANGELOG.md`, which is a release changelog for the target project that adopts the template.

Format is loosely based on [Keep a Changelog](https://keepachangelog.com/). Versions follow semantic versioning: major = breaking structural changes that require migration, minor = additive or reorganizing changes, patch = doc fixes and small corrections.

The current template version is recorded in the root `README.md` and stamped into each installed project's `template.values` file by `scripts/install.sh`.

---

## [0.7.0] — 2026-04-11

One-line curl-pipe-bash install.

### Added

- **`scripts/bootstrap.sh`** — a minimal self-contained installer designed to be executed via `curl -fsSL <url> | bash`. Clones the template repo into a temp directory, hands off to `scripts/install.sh` with any forwarded arguments (`--values`, `--full`, `--force`), and cleans up the clone on exit. Supports installing into the current directory (default) or a specified path. Honors `TEMPLATE_REPO_URL` and `TEMPLATE_REPO_BRANCH` environment variables for forks. Detects headless environments (no `/dev/tty`) and fails fast with a clear message if `--values` was not passed.
- **"Install in one line" section at the very top of `README.md`** showing the canonical curl-pipe-bash command and four variants (specific directory, non-interactive values file, `--full` prompts, `--force` overwrite). Positioned above "What Is This?" so new users can copy-paste and get started before reading anything else. Also notes Windows users should clone and run `install.ps1` directly, and recommends inspecting the script with `curl ... | less` before piping to bash.

### Changed

- **`README.md` Quick Start → "Fast path: install script"** now references the bootstrap curl-pipe-bash one-liner as the primary entry point, with `scripts/install.sh` and `scripts/install.ps1` as the cloned-repo variants. All three entry points share the same `template.values` output format and CLI surface.
- **Canonical repo URL** set to `https://github.com/Raxvis/CAST.git` on the `main` branch.

### Migration from 0.6.0

Purely additive. The bootstrap script is an alternative entry point; existing `install.sh` and `install.ps1` usage is unchanged.

---

## [0.6.0] — 2026-04-11

Clears the remaining open improvements from the setup audit. Adds verification tooling, settings documentation, per-file placeholder pointers, inline links from commands to agents, a per-agent smoke-probe rubric, a revision-history policy for planning artifacts, and a milestone-definition template split. The `IMPROVEMENTS.md` tracking file was removed at the end of this release since every item was resolved. No breaking changes.

### Added

- **`scripts/smoke-test.sh`** — static verification script. Runs 22+ checks on a target project covering layout, agent YAML frontmatter (`name`/`description`/`model`), slash commands, artifacts scaffold, template metadata, path hygiene, and placeholder status. PASS/FAIL/WARN output; exit 0 if clean or only warnings, exit 1 on failure. Copied into target projects by the installers.
- **`docs/FIRST_RUN.md`** — interactive checklist covering everything the static smoke test cannot: open Claude Code, run `/agents`, tab-complete the slash commands, dry-run `/agent-plan`, optional dry-run `/agent-task`, clean up. Includes an Appendix with 15 per-agent smoke probes (one per agent) so users can verify individual role definitions are loading correctly, grouped by tier.
- **`docs/CLAUDE_CODE_SETTINGS.md`** (~170 lines) — reference for `.claude/settings.json`. Explains permission rules, environment variables, hooks (at a pointer level), common extensions (auto-approving test/build commands, deny lists), and what NOT to configure here (secrets, user preferences, agent definitions).
- **`root/.claude/settings.json.example`** — minimal safe starting point that auto-approves 7 read-only shell commands (`ls`, `pwd`, `git status`, `git diff`, `git log`, `git show`, `cat`). Users rename the `.example` suffix off to activate. Install script copies into `<target>/.claude/settings.json.example`.
- **`commands/README.md`** — in-directory index for `commands/`. Explains how slash commands work in Claude Code, how filenames map to command names, the install destination, and a table of all three commands with one-line purposes. Not copied to target projects (Claude Code would register it as a `/README` slash command).
- **`docs/MILESTONE_DEFINITION.md`** — new template for the milestone definition file. Captures what the milestone is and why it matters (Goal, Why This Matters, Success Metrics, In Scope, Out of Scope, Top-Level Acceptance Criteria, Dependencies and Risks, Cross-Cutting Concerns, References). Split from `MILESTONE_TASKS.md` so each file has a single focused audience.
- **Per-agent smoke probes appendix** in `docs/FIRST_RUN.md` — 15 concrete one-line probes (one per agent) with expected outputs, organized by tier. Designed to fail if the agent file is not being loaded correctly so a passing probe is meaningful signal.
- **Revision History policy** for planning-stage artifacts. Every file under `artifacts/milestones/`, `artifacts/architecture/`, `artifacts/ui-specs/`, and `artifacts/reviews/` now carries a `## Revision History` table at the top. First write includes a `v1` row; revisions prepend new rows with date, agent, and reason. Documented in `commands/agent-plan.md`, `agents/ceo.md`, and `docs/FILE_CONVENTIONS.md`.
- **"Related agent files" sections** at the top of all three command files (`commands/agent-plan.md`, `agent-code.md`, `agent-task.md`). Each section lists the agents the command invokes with relative Markdown links to their files and a one-liner describing their role in that specific pipeline.
- **Placeholder pointer comments** — a one-line HTML comment (`<!-- Placeholders — see README.md → Placeholder Reference -->`) at the top of every template file that contains `[UPPER_SNAKE_CASE]` tokens. 41 files across `agents/`, `commands/`, `docs/`, and `root/CLAUDE.md`. Invisible in rendered Markdown; signposts the placeholder reference when editing the file in a source view.
- **Tier column in the Agent Roster table** (`agents/README.md`) showing which Minimum Viable Agent Set tier each agent belongs to (T1/T2/T3/T4/Opt), with a short leader paragraph explaining the tiers.

### Changed

- **`root/CLAUDE.md` is now fully agnostic** (from 0.5.0's partial split). All frontend-only content (UI component patterns, navigation, state management, performance budgets, input handling, safe areas) was moved into the new `docs/FRONTEND.md`, `docs/BACKEND.md`, and `docs/CLI.md` topic docs. The shipped `root/CLAUDE.md` has commented `@import` lines for all three; users uncomment the one(s) matching their project type. Common Pitfalls section rewritten to cover only universal traps.
- **Agent description field consistency.** All 15 agent descriptions now fit in 75–114 characters (a 39-char spread, down from 105) and follow the same `<Role> agent. Use for X, Y, and Z.` format. `ceo` (174→114 chars) and `product` (128→106 chars) were the only two that needed rewriting; the rest already fit.
- **Minimum Viable Agent Set reorganized into four tiers** in `README.md` so users can prune the roster based on which slash commands they keep: Tier 1 always, Tier 2 strongly recommended, Tier 3 required for `/agent-task`, Tier 4 required for `/agent-plan` + `/agent-code`.
- **Install scripts exclude `README.md`** when copying `agents/*.md` and `commands/*.md` into target projects. Previously, `agents/README.md` and `commands/README.md` were copied into `.claude/agents/` and `.claude/commands/` respectively; Claude Code would potentially register `commands/README.md` as a `/README` slash command. Both installers now skip any `README.md` in those directories.
- **`commands/agent-plan.md` Stage 1** now references both `docs/MILESTONE_DEFINITION.md` and `docs/MILESTONE_TASKS.md` explicitly and explains why the two files are separate.
- **Install script completion output** now points at `scripts/smoke-test.sh` and `docs/FIRST_RUN.md` as the next steps after install, replacing the old "open Claude Code and run /agents" one-liner.

### Migration from 0.5.0

Purely additive. A 0.5.0 project can pull any of the new files individually without breaking anything.

---

## [0.5.0] — 2026-04-11

Pins each agent to a specific Claude model tier based on its workload. Removes the `[AI_MODEL]` placeholder entirely.

### Changed

- **Per-agent models are now hard-coded in YAML frontmatter.** Each of the 15 agent files has a `model:` key chosen to match the agent's workload:
  - **Planning tier → `claude-opus-4-6`** (Product, Architect, UI, Security, Performance, CEO)
  - **Engineering tier → `claude-sonnet-4-6`** (Coder, Tester, Reviewer, Debugger, Refactor)
  - **Utility tier → `claude-haiku-4-5-20251001`** (Bug Gatherer, Docs Writer, Release, Validator)

  Planning agents do cross-document reasoning and judgment calls that justify Opus. Engineering agents do bounded code-centric work where Sonnet's speed and cost win. Utility agents do structured writing against templates where Haiku is sufficient. Users who want to override can edit the `model:` line in an individual agent file.

- **`[AI_MODEL]` placeholder removed.** `scripts/install.sh` and `scripts/install.ps1` dropped it from their Essentials prompt lists. The installer no longer asks for a model. Consistent with "the toolkit makes best-case judgments" rather than deferring model selection to users.

- **Documentation updated** across `README.md` → Placeholder Reference → Agents (replaced with tier explanation), `CLAUDE.md` → Placeholder Categories, `agents/README.md` → HOW TO CUSTOMIZE and "All agents run on" line, and `scripts/check-placeholders.sh` example comment.

### Migration from 0.4.0

1. In your existing project, find every `[AI_MODEL]` reference and replace it with the appropriate model for that file:
   ```
   grep -rn '\[AI_MODEL\]' .claude/agents/
   ```
   Or copy the updated agent files from this template over your existing ones if you have not customized them.
2. If your existing installer answers had an `AI_MODEL` entry in `template.values`, delete the line. It is ignored by 0.5.0.
3. Optional: review each agent's `model:` pin. Override if your account does not have access to Opus 4.6 — you can use Sonnet 4.6 for all planning agents without breaking anything, though the quality of cross-document reviews will be lower.

---

## [0.4.0] — 2026-04-11

Adds the `/agent-task` slash command for one-off work that does not justify a full planning stage. Reorganizes the Minimum Viable Agent Set into four tiers so users can prune the agent roster to match the commands they keep. Splits frontend-only content out of `root/CLAUDE.md` into three opt-in topic docs.

### Added

- **`commands/agent-task.md`** — a third slash command that runs a mini engineering pipeline (Coder → Tester → Reviewer → Product) for a single one-off task without requiring a milestone, planning artifacts, or a CEO verdict. Same Defect → Debugger → Bug Gatherer → Product and Issue → Refactor → Reviewer routing as `/agent-code`. Explicitly bounded to self-contained changes; bails out with a "run `/agent-plan` first" message if the Pre-Flight or Reviewer step detects that the task crosses the scope boundary (new module, schema change, endpoint, cross-cutting refactor).
- **`docs/FRONTEND.md`** (241 lines) — topic-specific reference for user-facing visual interfaces. Covers navigation, state management, UI components, performance budgets, input handling, and platform differences.
- **`docs/BACKEND.md`** (285 lines) — topic-specific reference for API servers, message workers, scheduled jobs, and data pipelines. Covers request/response boundaries, persistence, HTTP status semantics, authentication, middleware ordering, observability, and background work.
- **`docs/CLI.md`** (276 lines) — topic-specific reference for command-line tools. Covers argv parsing, stdin/stdout/stderr discipline, exit codes, terminal output formatting, cross-platform concerns, and signal handling.
- **`example/`** — a 15-file fixture based on "Acme Todo" showing what a populated instance of the template looks like after `/agent-plan` and `/agent-code` have run for Milestone 1. Includes a populated `CLAUDE.md`, PRD/CONCEPT/GLOSSARY, a full planning run (milestone definition, task breakdown, architecture, UI spec, security/performance/CEO reviews), a completion report, a bug tracker with one fixed and one deferred bug, and a three-day session log.
- **`scripts/install.ps1`** — PowerShell twin of `install.sh` for Windows users without WSL. Same CLI surface, same prompt lists, same `template.values` output format. Requires PowerShell 5.1 or PowerShell Core 7. Documented alongside the bash installer in `README.md`.
- **Prerequisites and Known Limitations sections** in `README.md`. Makes the Claude Code dependency explicit and sets expectations that this is a template, not a framework.
- **`TROUBLESHOOTING.md`** entry: "Which command should I use — `/agent-plan`, `/agent-code`, or `/agent-task`?" — a decision table covering 9 common task shapes. Plus a second new entry: "`/agent-task` halted and told me to run `/agent-plan`."

### Changed

- **`root/CLAUDE.md` is now fully agnostic.** All frontend-specific content (UI component pattern, navigation, state management, performance budgets, input handling, safe areas, touch targets) was moved into the three new topic docs. The shipped `CLAUDE.md` has commented `@import` lines for `docs/FRONTEND.md`, `docs/BACKEND.md`, and `docs/CLI.md` — users uncomment the one(s) that match their project type after install. Backend and CLI projects no longer need to delete sections by hand.
- **`root/CLAUDE.md` Common Pitfalls section** rewritten to cover only universal traps (hidden mutable state, silent error swallowing, stringly-typed boundaries, stale configuration, untested error paths). Topic-specific pitfalls moved into the three topic docs.
- **Minimum Viable Agent Set in `README.md` reorganized into four tiers.** Tier 1 (Product/Coder/Reviewer/Tester) is always required. Tier 2 (Architect/Debugger/Docs Writer) is strongly recommended. Tier 3 (Debugger/Refactor/Bug Gatherer) is required if you keep `/agent-task`. Tier 4 (UI/Security/Performance/CEO) is required if you keep `/agent-plan` or `/agent-code`. This makes it explicit that a project can run `/agent-task` without the planning stage agents.
- **`agents/architect.md` Interaction Rules** split the "publish before Coder begins" rule into two sibling bullets covering the two paths: `/agent-plan` → `/agent-code` (Architecture publishes first, enforced by pre-flight) and `/agent-task` (Architecture is skipped for self-contained work; Reviewer catches anything that needs architectural decisions and routes back to `/agent-plan`).
- **`agents/README.md` Workflow** gained a third subsection: "One-Off Task Workflow (`/agent-task`)". The interaction diagram set gained a third ASCII diagram showing the mini pipeline with its scope check at the top.
- **`docs/FILE_CONVENTIONS.md` Core Rule** now says "`/agent-plan`, `/agent-code`, and `/agent-task` all write exclusively under `artifacts/`." The Anti-Patterns list gained a new entry: "Using `/agent-task` for work that needs planning."
- **`TEMPLATE_VERSION` bumped to 0.4.0** in `README.md`, `scripts/install.sh`, and `scripts/install.ps1`. Installs stamped with 0.4.0 in `template.values`.

### Migration from 0.3.0

Purely additive with one exception. The exception:

1. **`root/CLAUDE.md` lost its frontend sections.** If you populated a project from 0.3.0 and kept those sections, you have two options:
   - Treat your existing `CLAUDE.md` as authoritative — keep it as-is, your frontend content still lives there.
   - Adopt the new split — move the frontend sections into `docs/FRONTEND.md` in your project (the template ships a fresh copy you can use as a reference), and add `@import docs/FRONTEND.md` to your `CLAUDE.md` Memory Imports block.

Everything else in 0.4.0 is opt-in. `/agent-task` is a new command, `example/` is new reference material, the PowerShell installer is new, and the Minimum Viable Agent Set reorg is a documentation-only change. A 0.3.0 project that does nothing still works on 0.4.0.

---

## [0.3.0] — 2026-04-11

Major refactor pass. Introduces the two-stage planning/engineering workflow, adds the CEO agent and the slash commands that orchestrate the full pipeline, renames work artifacts out of `docs/`, and ships an install script.

### Added

- **`scripts/install.sh`** — interactive + values-file hybrid installer. Copies all template files into a target project, substitutes placeholders from answers or a `template.values` file, and runs the placeholder check. Bash 3.2 compatible (works on default macOS bash). See `README.md` → Fast path for usage.
- **`scripts/install.ps1`** — functionally equivalent PowerShell twin of `install.sh`. Same CLI surface (positional target, `-Full`, `-Values`, `-Force`, `-Help`), same prompt lists, same `template.values` output with version stamp. Includes an inlined placeholder check so Windows users without WSL get a final report. Requires PowerShell 5.1 or PowerShell Core 7.
- **`scripts/check-placeholders.sh`** — standalone placeholder validation script. Targets `[UPPER_SNAKE_CASE]` tokens only, groups matches by file, exits non-zero so it plugs into CI. Skip list is extensible via command-line arguments.
- **`commands/agent-plan.md`** — slash command that orchestrates the planning stage: Product → Architecture + UI (parallel) → Security + Performance (parallel) → CEO (final sign-off).
- **`commands/agent-code.md`** — slash command that orchestrates the engineering stage: Coder → Tester → Reviewer. Reviewer findings are classified as **Defects** (→ Debugger → Bug Gatherer → Product) or **Issues** (→ Refactor → Reviewer loop).
- **`agents/ceo.md`** — CEO agent. Final reviewer of the planning stage. Integrates Product/Architecture/UI/Security/Performance outputs and issues APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED.
- **`artifacts/` directory and `artifacts/README.md`** — top-level directory for all work artifacts produced by the agent pipeline. Explains the `docs/` vs `artifacts/` split and lists the subdirectory layout (`milestones/`, `architecture/`, `ui-specs/`, `reviews/`, `BUGS.md`, `STANDUP.md`).
- **Prerequisites and Known Limitations sections** in `README.md`. Prerequisites covers Claude Code install, target directory, shell requirements, and Anthropic account. Known Limitations explicitly states: agents are role definitions not running processes, the slash commands are Markdown orchestration scripts, the workflow is Claude Code specific, and no code is written by copying the template.
- **Windows PowerShell equivalents** for Quick Start step 1 copy commands.
- **YAML frontmatter** on every agent file for Claude Code subagent auto-discovery.
- **`TEMPLATE_VERSION` constant** displayed in `README.md` and written into `template.values` by the install script so installed projects can report which template revision they came from.

### Changed

- **`features/` renamed to `artifacts/`.** Every path reference in every template file was updated. The name `artifacts/` was chosen over `features/`, `work/`, `planning/`, or `ai-work/` because it describes what the files *are* (produced outputs with a defined schema and owner) rather than who or when they were produced, pairs cleanly with `docs/` as reference vs produced, and stays accurate when humans edit the files.
- **`docs/` vs `artifacts/` split is now hard-enforced.** `docs/` holds reference material only — requirements, conventions, design rationale, and reusable templates. `artifacts/` holds instances of work. Neither `/agent-plan` nor `/agent-code` ever writes to `docs/`. `docs/FILE_CONVENTIONS.md` was rewritten to enforce this rule with a new "Core Rule" section, updated directory trees, and an extended anti-pattern list.
- **Agent roster split into two stages** in `agents/README.md`. The interaction diagram now shows Planning Stage and Engineering Stage as separate subgraphs. The per-task workflow rules were rewritten to match the Reviewer → Defect/Issue routing introduced by `/agent-code`.
- **CEO moved from "optional" to "required by the shipped slash commands"** in `README.md` → Minimum Viable Agent Set. Deleting `ceo.md` without also deleting both slash commands is now explicitly warned against.
- **Placeholder validation tightened.** Quick Start step 6's fragile `grep -r '\['` replaced with a precise `[UPPER_SNAKE_CASE]` regex that excludes the template's self-referential metadata files (`README.md`, `CHANGELOG.md`, `TROUBLESHOOTING.md`).
- **Quick Start placeholder ordering** reframed. Previously listed 6 of 12 categories in the processing order; now says "top-to-bottom as they appear in the Placeholder Reference table above."
- **`root/CLAUDE.md` Memory Imports** gained `@import artifacts/README.md` so installed projects always load the work-artifact index into session context.
- **Docs Writer scope narrowed.** Docs Writer now explicitly owns `docs/` only and must never move, rename, or rewrite files under `artifacts/`.
- **Bug Gatherer, Debugger, CEO** updated to reference `artifacts/BUGS.md` and `artifacts/reviews/` respectively.

### Removed

- **`agents/asset-gen.md`** — Asset Gen agent removed. The planning stage no longer includes asset generation as a core step. Visual asset production, if needed, is now handled ad-hoc or via a custom subagent outside the standard pipeline.
- **`agents/ux-critic.md`** — UX Critic agent removed. UX review is now folded into the UI agent's screen specification work and the CEO's final planning review.
- **`docs/BUGS.md` and `docs/STANDUP.md`** — these were work artifacts, not reference material. Moved to `artifacts/BUGS.md` and `artifacts/STANDUP.md`.
- **Placeholder tokens no longer in use:** `[PLANNING_DOCS_DIR]`, `[MILESTONE_DEF_PATH]`, `[ARCH_DOC_PATH]`, `[UI_SPEC_PATH]`, `[SECURITY_REVIEW_PATH]`, `[PERF_REVIEW_PATH]`, `[CEO_REVIEW_PATH]`, `[CEO_REVIEW_DIR]`. These were introduced briefly during the refactor and then replaced by fixed `artifacts/` paths.

### Migration from 0.2.x or earlier

If you have an existing project using an earlier revision of this template, the following migrations are needed:

1. **Rename `features/` to `artifacts/`** in your project. Run `grep -rn 'features/' .` after the rename to find any stale references and update them.
2. **Move `docs/BUGS.md` and `docs/STANDUP.md`** to `artifacts/BUGS.md` and `artifacts/STANDUP.md`. Update any agent files, commands, or docs that reference the old paths.
3. **If you deleted `agents/ceo.md`** thinking it was optional, re-add it from this template. Otherwise you must also delete `commands/agent-plan.md` and `commands/agent-code.md` — those commands hard-depend on the CEO stage.
4. **If you kept `agents/asset-gen.md` or `agents/ux-critic.md`**, they are no longer referenced by the main workflow. Keep them as custom subagents if you use them, or delete them.
5. **Add `scripts/check-placeholders.sh` and `scripts/install.sh`** from this template into your project if you want the tighter placeholder validation and reproducible re-installs.
6. **Update `CLAUDE.md`** to reference the `docs/` vs `artifacts/` split so future agent sessions respect the rule.

---

## [0.2.0] — (development snapshot)

Agent roster refactor that introduced the two-stage pipeline: Planning (Product → Architecture + UI → Security + Performance) and Engineering (Coder → Tester → Reviewer). CEO agent was added in this pass. Slash commands `/agent-plan` and `/agent-code` were introduced but still used `[PLANNING_DOCS_DIR]` placeholder paths and wrote to `features/`.

This version existed only briefly during development and is not recommended for new adoption. Upgrade directly to 0.3.0.

---

## [0.1.0]

Original template. 17 agents including Asset Gen and UX Critic, no slash commands, no planning/engineering stage split. Work artifacts (bug tracker, session log, milestone records) lived in `docs/` alongside reference material. No formal changelog from this era exists — entries reconstructed from the refactor that produced 0.3.0.

---

_This file is the historical log for the template itself. File an issue on the template repo for anything that should land in a future release._
