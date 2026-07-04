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
3. If you are trying to run engineering for a milestone that was planned manually (not via `/agent-plan`), you have two options: either run `/agent-plan` to produce the CEO review file retroactively, or hand-create `artifacts/reviews/ceo-review-milestone-{N}.md` with an APPROVED verdict. The pipeline only checks that the file exists and the verdict string is present.

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
3. Escalate conflicts per the repo's `skills/cast-init/assets/agents/README.md` → Conflict Resolution Priority: Product > Architecture > UI > Validator. The Validator agent arbitrates process conflicts; Product has final say on scope.

---

## The CEO agent keeps returning `REVISION REQUIRED`

**Cause.** The CEO applies a cross-cutting review against Security, Performance, Architecture, UI, and milestone scope. If any of those have open Critical findings, scope contradictions, or budget violations, the verdict will keep coming back as REVISION REQUIRED until resolved.

**Fix.**
1. Open `artifacts/reviews/ceo-review-milestone-{N}.md` and read the "Revision Requests" table. Every revision is addressed to a specific agent with a cited section.
2. Re-run only the affected planning stage: if Security flagged a Critical issue, re-run Stage 2a (Architecture) to revise the design, then Stage 3a (Security) to confirm remediation.
3. Only then re-run Stage 4 (CEO). The CEO does not rewrite plans; it reviews them.
4. If you disagree with a CEO revision, escalate per the conflict resolution hierarchy — the CEO does not override Product on business intent, and a Product override routes through Validator.

---

## `CLAUDE.md` context is not being loaded

**Cause.** Claude Code loads `CLAUDE.md` from the project root at session start. If the file is at the wrong path (e.g., `docs/CLAUDE.md`), or if the session started before you placed it, it will not load.

**Fix.**
1. Confirm the file is at the project root: `ls CLAUDE.md` should show it in the top-level directory.
2. Restart your Claude Code session.
3. If your project has nested subdirectories you work in, note that Claude Code loads `CLAUDE.md` from the root of the currently-open directory. Opening a subdirectory will not pick up the root `CLAUDE.md`.
4. For large projects, consider splitting `CLAUDE.md` into the root file plus `@import` directives pointing at reference material in `docs/`. This is what `root/CLAUDE.md` does by default.

---

## An agent wrote a work artifact to `docs/` instead of `artifacts/`

**Cause.** The agent was invoked ad-hoc without the pipeline skills, or its input pointed at a `docs/` path, or its prompt did not make the `docs/` vs `artifacts/` split explicit.

**Fix.**
1. Move the file: `git mv docs/<file>.md artifacts/<appropriate-subdir>/<file>.md`.
2. Grep for any references to the old path and update them.
3. Update `agents/docs-writer.md` and the responsible agent's file if the source of the error is a stale path reference there.
4. Re-read `docs/FILE_CONVENTIONS.md` → The Core Rule. If you are writing a template document or coding convention, it belongs in `docs/`. If you are writing a milestone plan, bug report, review, or session log, it belongs in `artifacts/`. The pipeline skills enforce this; direct agent invocation does not.

