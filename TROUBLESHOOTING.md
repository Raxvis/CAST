# Troubleshooting

Common problems adopting or running this template, with the most likely cause and the fix. If your issue is not listed here, check `CHANGELOG.md` for recent changes that might explain the behavior before filing a new one.

---

## Which pipeline should I use — `/agent-plan`, `/agent-code`, or `/agent-task`?

**Cause.** This is a decision problem rather than an error. The template ships three pipeline skills with three different scopes, and users don't always know which one fits their current work. `/agent-plan` runs the full planning stage (Product → Architecture + UI → Security + Performance → CEO). `/agent-code` runs the engineering stage for a CEO-approved milestone (Coder → Tester → Reviewer, with Defect and Issue routing). `/agent-task` runs a mini engineering pipeline for a single self-contained task with no milestone, no planning artifacts, and no CEO verdict.

**Fix.** Use the table below to pick a pipeline, then read the narrative note after it.

| Task | Pipeline | Why |
|---|---|---|
| "Add a new feature / milestone" | `/agent-plan` then `/agent-code` | New features need a planning stage with CEO sign-off before engineering. |
| "Fix a typo in the README" | `/agent-task` | Self-contained text change, no design work needed. |
| "Fix a bug already in `artifacts/BUGS.md`" | `/agent-task` | Scope is bounded by the bug report. |
| "Add a new command or endpoint" | `/agent-plan` then `/agent-code` | Touches the public interface — needs UI spec, security review, CEO sign-off. |
| "Bump a dependency and update call sites" | `/agent-task` | Mechanical change across existing patterns, no new design. |
| "Refactor a single function" | `/agent-task` | Contract doesn't change, no architectural impact. |
| "Refactor across multiple modules" | `/agent-plan` then `/agent-code` | Cross-cutting — needs an architecture revision. |
| "Add a flag following an existing pattern" | `/agent-task` | The pattern already exists; no new design decisions. |
| "Add a new data field to a schema" | `/agent-plan` then `/agent-code` | Schema change requires migration planning, security review, CEO sign-off. |

**When in doubt, run `/agent-plan` first.** The planning gate exists because ad-hoc changes that turn out to need design work produce drift that is expensive to untangle later. `/agent-task` will halt and tell you to run `/agent-plan` if its Pre-Flight or Reviewer step notices you've crossed the line — but front-loading the decision is faster than backing out of a half-finished one-off task.

---

## `/cast-init` is not recognized

**Cause.** The cast-init skill is not installed, or the session started before it was installed. Claude Code discovers skills at session start.

**Fix.**
1. Confirm the skill is installed: `ls .claude/skills/cast-init/SKILL.md` (project install) or `ls ~/.claude/skills/cast-init/SKILL.md` (global install). If missing, install it: `npx skills add Raxvis/CAST`, or `/plugin marketplace add Raxvis/CAST` followed by `/plugin install cast@cast`.
2. Restart your Claude Code session (exit and re-open). Skill discovery runs at session start, not continuously.
3. If the file exists but the skill still doesn't register, verify `.claude/skills/cast-init` is not a broken symlink (`npx skills` installs symlinks into `.agents/skills/` by default): `ls -L .claude/skills/cast-init/`.

---

## `/cast-init` finished but says files are staged in `.cast-stage/`

**Cause.** The session's permission system blocked writes under `.claude/` (this mostly happens in non-interactive or restricted-permission sessions — in a normal interactive session you would simply be prompted to approve the writes). Rather than skipping or failing, `/cast-init` builds, substitutes, and validates the blocked files in a `.cast-stage/` directory mirroring the final layout, and tells you how to finish.

**Fix.**
1. Read the adoption report (`artifacts/adoption-report.md`) — it lists exactly which paths are staged and the precise move command(s).
2. Run the move command(s) from the project root. Typically:
   ```
   mv .cast-stage/agents .claude/agents
   mv .cast-stage/skills/agent-plan .cast-stage/skills/agent-code .cast-stage/skills/agent-task .claude/skills/
   rmdir .cast-stage/skills .cast-stage
   ```
3. Restart your Claude Code session so the moved agents and skills register.
4. To avoid staging entirely, run `/cast-init` in an interactive session and approve the `.claude/` write prompts when asked.

---

## My installed files still contain `[PLACEHOLDER]` tokens

**Cause.** `/cast-init` substitutes every placeholder it can detect (tech stack, commands, platforms, directory roles) or that you answered during planning, but some tokens are undetectable domain values (`[DOMAIN_ENTITY]`, `[SAVE_KEY]`, …) and some are deliberate: per-use sub-template tokens (`[DATE]`, `[TASK_NAME]`, `[MILESTONE_NAME]`) are filled by agents each time a form or template is used and are supposed to remain.

**Fix.**
1. Open `artifacts/adoption-report.md` — the "Remaining TODOs" section lists every real unfilled placeholder from your install; per-use tokens are not defects.
2. Fill the listed tokens by hand (they're stable project facts: domain entity, save key, budgets, etc.), or re-run `/cast-init` and answer the questions you skipped.
3. If a token you expected to be auto-filled wasn't (e.g. `[TEST_CMD]` in a project with a test script), that's a discovery miss — file an issue on `Raxvis/CAST` with your project's manifest shape.

---

## Re-running `/cast-init` stops because the git tree is dirty after an interrupted run

**Cause.** Adoption requires a clean git tree before Phase 5 (safety rule). A run that was interrupted mid-execution leaves its own half-written files uncommitted, which would block a naive re-run against its own output.

**Fix.** Re-run `/cast-init` and say you want to resume. Preflight recognizes two resume cases: dirty files that match the prior run's `artifacts/adoption-plan.md` actions (it re-verifies each against the plan instead of demanding a stash), and a leftover `.cast-stage/` directory from a permission-blocked run (it offers to complete the move). Only files the plan does not account for still require a commit or stash — that's your work, not the adoption's.

---

## `/cast-init` reports "already at <version>" — is that right?

**Cause.** `/cast-init` compares the `Adopted with CAST v<X.Y.Z>` stamp in your `CLAUDE.md` against its own `metadata.version`, and when they are equal it stops instead of re-running a no-op upgrade. That short-circuit is correct **only when the prior run actually finished** — `artifacts/adoption-report.md` exists and every entry in the `artifacts/adoption-plan.md` ledger is checked off.

**Fix.**
1. If both completion signals are present, the report is accurate: you are current. Nothing to do. (`npx skills update` / `/plugin marketplace update` first if you expected a newer version.)
2. If the report is missing or the ledger has unchecked entries, the previous run died *after* writing the version stamp but before finishing (the stamp lands ahead of validation and the report). `/cast-init` detects this on its own and enters the resume path instead of stopping — if you are seeing a hard stop in this state, your cast-init copy predates v1.4.0; update it.
3. If you suspect the installed files have drifted from the payload (manual edits, partial merges), ask for a **forced re-run** — it repeats all seven phases, refreshing CAST-owned content while preserving your customizations.

---

## `/agent-plan` or `/agent-code` is not recognized

**Cause.** Claude Code registers skills from `.claude/skills/` at session start. If the directory did not exist when you started the session, or if the pipeline skills are not there yet, they will not appear. (Before CAST v1.0.0 the pipelines were slash commands in `.claude/commands/` — if you upgraded, the old files should have been migrated and removed by `/cast-init`.)

**Fix.**
1. Confirm the files exist at the right path:
   ```
   ls .claude/skills/agent-plan/SKILL.md .claude/skills/agent-code/SKILL.md
   ```
2. Restart your Claude Code session (exit and re-open). Auto-discovery runs at session start, not continuously.
3. If the files are missing, re-run `/cast-init` — it installs the pipeline skills as part of the adoption.
4. Run `/agents` to confirm Claude Code sees the template's subagents. If `/agents` lists the 15 agents, the session is reading `.claude/`; if it doesn't, you are in the wrong directory.

---

## A subagent is not being auto-delegated when I ask for its work

**Cause.** Claude Code routes tasks to subagents based on the `description` field in each agent file's YAML frontmatter. A malformed frontmatter block, a vague description, or a file in the wrong directory prevents delegation.

**Fix.**
1. Open the affected agent file in `.claude/agents/<name>.md`.
2. Verify the file starts with a valid YAML frontmatter block:
   ```
   ---
   name: <agent-name>
   description: "<one-sentence description>"
   ---
   ```
   No missing quotes, no tabs, no trailing whitespace.
3. Make the `description` specific. "Reviews code" is too vague. "Reviews code against project conventions, architecture docs, and UI specs. Classifies findings as Defects or Issues." gives Claude Code enough signal to route.
4. As a workaround, invoke the agent explicitly: "Use the reviewer subagent to review this file." Explicit invocation bypasses the routing heuristic.

---

## `/agent-code` fails at pre-flight with "CEO review not found"

**Cause.** `/agent-code` reads `artifacts/reviews/ceo-review-milestone-{N}.md` before running any task. If that file does not exist, the planning stage was never completed (or was not completed for the milestone you specified).

**Fix.**
1. Run `/agent-plan <milestone>` first. The planning stage ends with a CEO verdict written to that path.
2. If the CEO issued **REVISION REQUIRED**, the planning stage is not complete. Address the Revision Requests (named by agent in the review document), re-run the affected stage, and re-run the CEO review.
3. If you are trying to run engineering for a milestone that was planned manually (not via `/agent-plan`), you have two options: either run `/agent-plan` to produce the CEO review file retroactively, or hand-create `artifacts/reviews/ceo-review-milestone-{N}.md` from `templates/CEO_REVIEW.md` with its single `**Verdict**: APPROVED` line filled in. Pre-Flight parses that one line — there is exactly one verdict string in the file (the old three-checkbox verdict block is gone), so don't leave all three options in place.
4. Note what Pre-Flight does beyond the existence check: it reads the verdict from the `**Verdict**:` line, and on **APPROVED WITH CONDITIONS** it cross-checks the CEO Approval Conditions table in the milestone's tasks file — backfilling it from the CEO review if missing or stale — so the conditions follow every task through implementation and review. A hand-created review with conditions should list them explicitly.

---

## I have no `ui` agent — will `/agent-plan` and `/agent-code` still run?

**Cause.** Backend and CLI-only projects can opt out of the `ui` agent during `/cast-init` (the UI templates are skipped together with it). Before v1.4.0, `/agent-code` Pre-Flight unconditionally required `artifacts/ui-specs/ui-milestone-{N}.md`, so opted-out projects dead-ended between the two pipelines.

**Fix.** Nothing to work around on a current install — the opt-out is wired through end to end:
1. `/agent-plan` skips its UI design stage when `.claude/agents/ui.md` is absent, so no UI spec is produced and the CEO review's UI section is marked not applicable.
2. `/agent-code` Pre-Flight requires the UI spec **only when the `ui` agent is installed**. A UI spec absent because there is no `ui` agent is not a missing artifact; Coder and Reviewer simply run without a UI specification, and the milestone-completion UX review is skipped.
3. If `/agent-code` still stops for a missing UI spec on a no-ui project, your installed pipeline skills predate v1.4.0 — update the cast-init skill and re-run `/cast-init` to refresh them.
4. The opt-out is all-or-nothing per install: never delete `.claude/agents/ui.md` while keeping UI-flagged tasks in a milestone, and never install the UI templates without the agent.

---

## I interrupted `/agent-code` mid-milestone — how do I resume?

**Cause.** A session died (or you stopped it) partway through a milestone. This is a designed-for case, not an error: the task-completion checkpoint writes each finished task's **Status** back to `artifacts/milestones/milestone-{N}-{slug}-tasks.md`, so the tasks file is the resume ledger.

**Fix.**
1. Re-run `/agent-code <milestone>`. Task Selection skips every task whose Status is already Complete or Deferred and picks up at the first remaining task — finished work is not redone.
2. Do not hand-mark tasks Complete to "help" the resume; only tasks that actually passed Product validation carry that status. If the interruption hit mid-task, that task's Status is unchanged and the whole per-task loop re-runs for it, which is correct.
3. The resumed run reuses the existing `### YYYY-MM-DD — agent-code — …` session heading in `artifacts/STANDUP.md` for the same milestone and date rather than opening a duplicate.
4. When the last task lands, the milestone-completion checkpoint (Deferred re-triage, completion and validation records, UX review, retrospective) fires normally — it keys off "every task Complete or Deferred", not off an unbroken session.

---

## `/agent-task` halted and told me to run `/agent-plan`

**Cause.** The Pre-Flight or Reviewer step in `/agent-task` detected that the change you described crosses the `/agent-task` scope boundary. `/agent-task` is explicitly bounded to self-contained changes: bug fixes, typos, single-function refactors, dependency bumps, and flags that follow existing patterns. When Pre-Flight reads the task description and notices it implies a new module, a schema change, a new endpoint, or a cross-cutting change, it halts rather than guessing. The Reviewer in Step 3 applies the same check against the actual diff and halts if the finished work has crossed the line.

**Fix.**
1. Re-read the halt message. It should name the specific scope-crossing concern (e.g., "introduces a new module", "changes a data schema", "adds a new CLI subcommand").
2. Run `/agent-plan "<feature description>"` to produce the planning artifacts for that scope. This runs Product → Architecture + UI → Security + Performance → CEO and ends with a verdict file at `artifacts/reviews/ceo-review-milestone-{N}.md`.
3. After the CEO issues **APPROVED** or **APPROVED WITH CONDITIONS**, run `/agent-code <milestone>` to execute the engineering stage against the approved plan.
4. If you disagree with the scope classification and think the change is really self-contained, you can re-run `/agent-task` with a more precise task description that narrows the scope (name the specific file, the specific bug ID, or the specific existing pattern the change follows). Do not try to sneak a design change through `/agent-task` — the gate exists to prevent drift, and the Reviewer in Step 3 will catch it anyway.

---

## I still have `features/` references in my project after upgrading

**Cause.** The template renamed `features/` to `artifacts/` in version 0.3.0. If you adopted the template before that change and then merged in newer template files, some references will still point at the old name.

**Fix.**
1. Find every remaining reference:
   ```
   grep -rn 'features/' . --include='*.md'
   ```
2. Rename the directory: `mv features artifacts` (or `git mv` if tracked).
3. Replace all path references:
   ```
   grep -rln 'features/' . --include='*.md' | xargs sed -i.bak 's|features/|artifacts/|g' && find . -name '*.bak' -delete
   ```
4. Re-read `CHANGELOG.md` → Migration from 0.2.x for the full migration steps.

---

## Two agents give contradictory outputs

**Cause.** The template's agents are designed to run in a specific sequence: `/agent-plan` orchestrates the planning stage producers and gates them at the CEO; `/agent-code` orchestrates the engineering stage producers and gates them at the Reviewer and Product validation. Invoking agents ad-hoc — asking the Coder to implement something the Architect has not yet designed, for example — bypasses the gates and produces drift.

**Fix.**
1. Use `/agent-plan` and `/agent-code` as the canonical entry points. They exist specifically to sequence the agents correctly.
2. If you must invoke an agent directly, give it the prior agent's output as input ("Here is the architecture document at `artifacts/architecture/arch-milestone-3.md`; implement task T-4.").
3. Escalate conflicts per the repo's `skills/cast-init/assets/agents/README.md` → Conflict Resolution Priority: **Product > Architecture > UI**. The Validator agent arbitrates the dispute by applying that hierarchy — it does not sit in the hierarchy and does not override anyone; Product has final say on scope.

---

## The CEO agent keeps returning `REVISION REQUIRED`

**Cause.** The CEO applies a cross-cutting review against Security, Performance, Architecture, UI, and milestone scope. If any of those have open Critical findings, scope contradictions, or budget violations, the verdict will keep coming back as REVISION REQUIRED until resolved.

**Fix.**
1. Open `artifacts/reviews/ceo-review-milestone-{N}.md` and read the "Revision Requests" table (the verdict itself is the single `**Verdict**:` line). Every revision is addressed to a specific agent with a cited section.
2. Re-run only the affected planning stage — but note a revised architecture re-passes Stage 3 (both Security and Performance) before the CEO sees it again, so the CEO never re-reviews against stale findings.
3. Only then re-run Stage 4 (CEO). The CEO does not rewrite plans; it reviews them.
4. If you disagree with a CEO revision, escalate per the conflict resolution hierarchy (Product > Architecture > UI) — Validator arbitrates but does not override, and the CEO does not override Product on business intent.

---

## `CLAUDE.md` context is not being loaded

**Cause.** Claude Code loads `CLAUDE.md` from the project root at session start. If the file is at the wrong path (e.g., `docs/CLAUDE.md`), or if the session started before you placed it, it will not load.

**Fix.**
1. Confirm the file is at the project root: `ls CLAUDE.md` should show it in the top-level directory.
2. Restart your Claude Code session.
3. If your project has nested subdirectories you work in, note that Claude Code loads `CLAUDE.md` from the root of the currently-open directory. Opening a subdirectory will not pick up the root `CLAUDE.md`.
4. For large projects, split `CLAUDE.md` into the root file plus bare `@docs/<FILE>.md` import lines pointing at reference material. An import only fires as a bare `@path` line at the start of a line — there is no `@import` keyword, and a path wrapped in backticks or inside a comment is inert. This is what the shipped `root/CLAUDE.md` does: `@docs/CODE_PATTERNS.md` is the one always-on import (plus `@docs/PRD.md` once the PRD has real content), and the topic docs (`FRONTEND`/`BACKEND`/`CLI`/`MOBILE`) are listed as inert backticked paths you copy out as bare lines to activate.
5. If a doc you "imported" is not in context, check for exactly that mistake: the line reads `` `@docs/FRONTEND.md` `` (backticks — inert) instead of `@docs/FRONTEND.md` (bare — fires).

---

## An agent wrote a work artifact to `docs/` instead of `artifacts/`

**Cause.** The agent was invoked ad-hoc without the pipeline skills, or its input pointed at a `docs/` path, or its prompt did not make the `docs/` vs `artifacts/` split explicit.

**Fix.**
1. Move the file: `git mv docs/<file>.md artifacts/<appropriate-subdir>/<file>.md`.
2. Grep for any references to the old path and update them.
3. Update `agents/docs-writer.md` and the responsible agent's file if the source of the error is a stale path reference there.
4. Re-read `docs/FILE_CONVENTIONS.md` → The Core Rule. If you are writing a template document or coding convention, it belongs in `docs/`. If you are writing a milestone plan, bug report, review, or session log, it belongs in `artifacts/`. The pipeline skills enforce this; direct agent invocation does not.

---

## The `v<version>` tag exists on GitHub but there is no Release

*(CAST repo maintainers only — this is about releasing CAST itself, not about installed projects.)*

**Cause.** `.github/workflows/release.yml` pushes the tag first, then publishes the GitHub Release. If the run died between those two steps (API hiccup, cancelled run), the tag exists without its Release. The tag and the Release are separate artifacts; downstream tooling needs both.

**Fix.**
1. Re-run the failed workflow run from the GitHub Actions tab (or just push the next commit to `main`). The workflow self-heals: when the tag already exists it checks `gh release view v<version>`, and if the Release is missing it re-verifies the four synchronized version locations and publishes the Release at the existing tag — it never re-pushes the tag.
2. It skips as a no-op only when the tag **and** the Release both exist, so a re-run on a healthy state is always safe.
3. If the workflow is unavailable, publish manually per `CLAUDE.md` → Release and Tagging Policy step 6 (`gh release create v<version> …` with notes extracted from the top `CHANGELOG.md` entry). Do not delete and re-push the tag — consumers may already have fetched it.

