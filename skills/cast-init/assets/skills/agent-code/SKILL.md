---
name: agent-code
description: >-
  Run the CAST Engineering Stage for a CEO-approved milestone: Coder → Tester →
  Reviewer, with Defects routed through Bug Gatherer → Product triage → Debugger and
  Issues through Refactor → Tester → Reviewer, then Product validation. Use when the user asks
  to implement an approved milestone or invokes /agent-code. Requires an existing CEO
  verdict in artifacts/reviews/.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /agent-code pipeline skill. It runs the Engineering Stage of
the multi-agent workflow for an approved milestone by executing the canonical engineering
loop defined in docs/PIPELINE_LOOP.md (Coder → Tester → Reviewer → Product validation, with
Defect and Issue routing). This file carries only the deltas specific to milestone work.

All work artifacts (bug reports, progress log entries, milestone completion records) are
written to `artifacts/`. Templates are read from `templates/`; guidelines are read from
`docs/`. Never mix them: `docs/` and `templates/` are reference-only, `artifacts/` is
where live work lives.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.
2. Replace [TEST_CMD] with your project's test command.
3. Replace [MAX_LOOP_COUNT] with the number of Coder-Tester-Reviewer cycles allowed before
   escalation (default: 3).

INSTALLATION: This skill installs to `.claude/skills/agent-code/SKILL.md` in your target
project (done automatically by /cast-init). Claude Code registers it as the /agent-code
skill. Invoke it with `/agent-code <milestone or task id>`.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /agent-code — Engineering Pipeline

Run the engineering stage for a milestone that has already been approved by the CEO during `/agent-plan`. Implements code, runs tests, reviews for defects and quality issues, and validates against the task's acceptance criteria. Work artifacts produced by this skill (bug reports, completion records, progress log) are written to `artifacts/`.

## Related agent files

This skill invokes the following agents. Open any of them for the full role definition and interaction rules:

- [coder](../../agents/coder.md) — implements each task and completes the Pre-Handoff Checklist
- [tester](../../agents/tester.md) — writes and runs tests; gates Reviewer behind a green test suite
- [reviewer](../../agents/reviewer.md) — reviews the code and classifies findings as Defects or Issues
- [bug-gatherer](../../agents/bug-gatherer.md) — files Defect findings as structured bug reports
- [debugger](../../agents/debugger.md) — investigates triaged defects and produces root-cause analysis
- [refactor](../../agents/refactor.md) — addresses Issue findings without changing behaviour and loops back to Reviewer
- [product](../../agents/product.md) — triages bug reports, validates completed tasks against acceptance criteria, and writes the milestone completion and validation records
- [ui](../../agents/ui.md) — performs the milestone UX review at the milestone-completion checkpoint (milestones with UI-flagged tasks only)
- [docs-writer](../../agents/docs-writer.md) — drains the `docs` queue from `artifacts/STANDUP.md` at task- and milestone-completion checkpoints
- [validator](../../agents/validator.md) — records task and milestone outcomes in `artifacts/AGENT_STATE.md` and writes the milestone retrospective

The planning-stage outputs this skill reads were produced earlier by [architect](../../agents/architect.md), [ui](../../agents/ui.md), [security](../../agents/security.md), [performance](../../agents/performance.md), and signed off by [ceo](../../agents/ceo.md). This skill does not re-invoke them during the per-task loop; the only planning-stage agent it re-invokes is **ui**, once, for the milestone-completion UX review.

## Input

The argument text the user provided when invoking this skill (e.g. `/agent-code milestone-1`) — the milestone to implement, or a specific task identifier within that milestone. If none was provided, ask for one before the Pre-Flight Check.

## Model Compatibility

Each stage runs on the model pinned in that agent's file (default: `claude-opus-4-8`; `claude-opus-4-7` and `claude-opus-4-6` are supported — full profiles and upgrade paths in `docs/MODEL_OPTIMIZATION.md`). Orchestration notes by executing model:

- **Opus 4.8 / 4.7** — these models delegate conservatively; the explicit stage invocations below are load-bearing. Execute every stage exactly as written, including the Defect/Issue routing loops.
- **Opus 4.6** — this model over-delegates; invoke only the agents named in the stages below and spawn no ad-hoc subagents beyond them.
- **Effort** — run the Coder, Reviewer, and Debugger stages at `xhigh` on Opus 4.7+ (`high` on Opus 4.6); Tester, Refactor, routing, and Product validation at `high`.
- **Review recall (Opus 4.8 / 4.7)** — these models follow severity filters literally: the Reviewer stage must report every Defect and Issue found; filtering happens in the routing stages, never at review time.

## Instructions

This skill orchestrates the **Engineering Stage** of the agent workflow. It requires that `/agent-plan` has already been completed and the CEO has issued APPROVED or APPROVED WITH CONDITIONS.

### Pre-Flight Check

Before any task begins:

1. Verify the planning artifacts exist under `artifacts/`:
   - `artifacts/milestones/milestone-{N}-{slug}.md`
   - `artifacts/milestones/milestone-{N}-{slug}-tasks.md`
   - `artifacts/architecture/arch-milestone-{N}.md`
   - `artifacts/ui-specs/ui-milestone-{N}.md`
   - `artifacts/reviews/ceo-review-milestone-{N}.md`
2. Read the CEO review and confirm the verdict is APPROVED or APPROVED WITH CONDITIONS. If REVISION REQUIRED or artifacts are missing, stop and instruct the user to run `/agent-plan <milestone>` first.
3. If APPROVED WITH CONDITIONS, read the Approval Conditions from the **CEO Approval Conditions** table in `artifacts/milestones/milestone-{N}-{slug}-tasks.md` (backfilled by Product at the end of `/agent-plan`). Cross-check the table against the CEO review itself; if the table is missing or stale, extract the conditions from the CEO review and backfill the table before proceeding. The conditions must be addressed as part of implementation and verified during Reviewer / Product validation.

### Task Selection

1. Read the task breakdown in `artifacts/milestones/milestone-{N}-{slug}-tasks.md`.
2. **Skip any task whose Status is already Complete.** The task-completion checkpoint below writes Status back to the task breakdown, so a re-invocation after an interruption resumes from the first non-Complete task instead of redoing finished work.
3. If the invocation input specifies a single task, work on only that task.
4. Otherwise, work through tasks in dependency order, respecting each task's **Dependencies** field (defined in `templates/MILESTONE_TASKS.md`).

### Per-Task Loop

For each task, execute the engineering loop defined in `docs/PIPELINE_LOOP.md` — Coder → Tester → Reviewer (with the Defect and Issue routing) → Product validation — including its loop-counter rules, test-gate rule, and Environment Issue rule. The loop doc is the single canonical statement of that sequence; do not improvise routing.

Inputs specific to this skill, passed into the loop per the loop doc's pass-forward rule (read once in Pre-Flight/Task Selection, supply the content to each stage — don't have each agent re-open the same files):

- **Coder (Step 1)** receives the task definition from the task breakdown, the architecture document (`artifacts/architecture/arch-milestone-{N}.md`), the UI specification (`artifacts/ui-specs/ui-milestone-{N}.md`), and any Approval Conditions read in Pre-Flight (from the tasks file's CEO Approval Conditions table), and follows the conventions in `CLAUDE.md`, `docs/CODE_PATTERNS.md`, and `docs/FILE_CONVENTIONS.md`.
- **Reviewer (Step 3)** receives the same architecture document, UI specification, and Approval Conditions, and reviews against them plus project conventions.
- **Product validation (Step 4)** validates against the task's acceptance criteria using the Task Validation Checklist in `templates/MILESTONE_VALIDATION.md`.

### Completion

#### Task-completion checkpoint (after every task)

Run this checkpoint each time a task passes Product validation — including single-task invocations:

1. **Status writeback.** Mark the task's **Status** as Complete in `artifacts/milestones/milestone-{N}-{slug}-tasks.md` — both the Summary table row and the task's own field table. When every task in the breakdown is Complete, set the Header **Status** field to Complete as well. This writeback is what makes the skill resumable (see Task Selection).
2. **Docs Writer.** Invoke the **docs-writer** agent to drain the `docs` entries from `artifacts/STANDUP.md` (entries of the form `- <agent> | docs | <note>` — see that file's Entry Grammar). Docs Writer marks each drained entry with ✅.
3. **Validator.** Invoke the **validator** agent to record the task outcome in `artifacts/AGENT_STATE.md` (Agent Status Dashboard and Milestone Progress tables in its section).

#### Milestone-completion checkpoint

After all tasks for the milestone are complete:

1. Run `[TEST_CMD]` one final time to confirm everything still passes.
2. Launch the **product** agent to write the milestone completion record at `artifacts/milestones/milestone-{N}-{slug}-completion.md` using `templates/MILESTONE_COMPLETION.md`, and the milestone validation record at `artifacts/milestones/milestone-{N}-{slug}-validation.md` using `templates/MILESTONE_VALIDATION.md`. Product — not the orchestrator — writes both records (they are Product's artifacts; see `artifacts/README.md`).
3. **UX review.** If the milestone contains UI-flagged tasks (any task with **Needs UI Spec** = Yes or Done), launch the **ui** agent once to review the implemented screens against `artifacts/ui-specs/ui-milestone-{N}.md` and write `artifacts/reviews/ux-review-milestone-{N}.md` using `templates/UX_REVIEW.md`. Skip this step for milestones with no UI-flagged tasks.
4. **Docs Writer.** Invoke the **docs-writer** agent to drain any remaining `docs` entries from `artifacts/STANDUP.md` (per its Entry Grammar; drained entries are marked ✅).
5. **Validator.** Invoke the **validator** agent to record the milestone outcome in `artifacts/AGENT_STATE.md` and write the milestone retrospective at `artifacts/reviews/retrospective-milestone-{N}.md` using `templates/MILESTONE_RETROSPECTIVE.md`.
6. Append a final entry to `artifacts/STANDUP.md` summarizing the run, using that file's Entry Grammar.
7. Summarize what was implemented, test results, any defects filed in `artifacts/BUGS.md` (including any still open as Deferred), and the status of every Approval Condition from the CEO.
8. Suggest next steps — additional tasks, a release (the **release** agent is user-invoked after milestone completion; this skill does not launch it), or a new planning run via `/agent-plan`.

### Error Handling

- If a task is blocked by an unfinished dependency, skip it and record the blocker in `artifacts/STANDUP.md` (a `blocker` entry per its Entry Grammar).
- If the architecture document or UI specification is ambiguous, flag it rather than guessing. Pause the task and notify the user to re-run the relevant stage of `/agent-plan`.
- Loop-cap escalation (`[MAX_LOOP_COUNT]`) and Environment Issue handling follow the rules in `docs/PIPELINE_LOOP.md`.

Do NOT write any work artifact to `docs/`; that directory is reference-only. All live work — bug reports, completion records, progress entries — goes under `artifacts/`.
