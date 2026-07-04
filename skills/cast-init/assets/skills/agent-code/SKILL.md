---
name: agent-code
description: >-
  Run the CAST Engineering Stage for a CEO-approved milestone: Coder → Tester →
  Reviewer, with Defects routed through Debugger → Bug Gatherer → Product and Issues
  through Refactor → Reviewer, then Product validation. Use when the user asks to
  implement an approved milestone or invokes /agent-code. Requires an existing CEO
  verdict in artifacts/reviews/.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /agent-code pipeline skill. It runs the Engineering Stage of
the multi-agent workflow for an approved milestone: Coder → Tester → Reviewer, with defects
routed to Debugger → Bug Gatherer → Product, and quality issues routed to Refactor → Reviewer.

All work artifacts (bug reports, progress log entries, milestone completion records) are
written to `artifacts/`. Templates are read from `templates/`; guidelines are read from
`docs/`. Never mix them: `docs/` and `templates/` are reference-only, `artifacts/` is
where live work lives.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.
2. Replace [TEST_CMD] with your project's test command.
3. Replace [MAX_LOOP_COUNT] with the number of Coder-Tester-Reviewer cycles allowed before
   escalation (default: 3).
4. Delete this comment block once the skill is customized for your project.

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
- [debugger](../../agents/debugger.md) — investigates Defect findings and produces root-cause analysis
- [bug-gatherer](../../agents/bug-gatherer.md) — files investigated defects as structured bug reports
- [refactor](../../agents/refactor.md) — addresses Issue findings without changing behaviour and loops back to Reviewer
- [product](../../agents/product.md) — triages bug reports and validates completed tasks against acceptance criteria

The planning-stage outputs this skill reads were produced earlier by [architect](../../agents/architect.md), [ui](../../agents/ui.md), [security](../../agents/security.md), [performance](../../agents/performance.md), and signed off by [ceo](../../agents/ceo.md). This skill does not re-invoke them.

## Input

The argument text the user provided when invoking this skill (e.g. `/agent-code milestone-1`) — the milestone to implement, or a specific task identifier within that milestone. If none was provided, ask for one before the Pre-Flight Check.

## Model Compatibility

Each stage runs on the model pinned in that agent's file (default: `claude-opus-4-8`; `claude-opus-4-7` and `claude-opus-4-6` are supported — full profiles and upgrade paths in `docs/MODEL_OPTIMIZATION.md`). Orchestration notes by executing model:

- **Opus 4.8 / 4.7** — these models delegate conservatively; the explicit stage invocations below are load-bearing. Execute every stage exactly as written, including the Defect/Issue routing loops.
- **Opus 4.6** — this model over-delegates; invoke only the agents named in the stages below and spawn no ad-hoc subagents beyond them.
- **Effort** — run the Coder and Reviewer stages at `xhigh` on Opus 4.7+ (`high` on Opus 4.6); Tester, routing, and Product validation at `high`.
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
3. If APPROVED WITH CONDITIONS, extract the Approval Conditions. They must be addressed as part of implementation and verified during Reviewer / Product validation.

### Task Selection

1. Read the task breakdown in `artifacts/milestones/milestone-{N}-{slug}-tasks.md`.
2. If the invocation input specifies a single task, work on only that task.
3. Otherwise, work through tasks in dependency order, respecting any `blockedBy` relationships.

### Per-Task Loop

For each task, run this sequence. The loop may cycle — track the count and escalate to the user after `[MAX_LOOP_COUNT]` full cycles on a single task.

**Step 1 — Coder**

Launch the **coder** agent to:

- Read the task definition, architecture document, UI specification, and any Approval Conditions.
- Implement the task in production code, following the conventions in `CLAUDE.md`, `docs/CODE_PATTERNS.md`, and `docs/FILE_CONVENTIONS.md`.
- Complete the Pre-Handoff Checklist before handing off.

**Step 2 — Tester**

After Coder hands off, launch the **tester** agent to:

- Write or update unit tests covering the changed code.
- Run `[TEST_CMD]` to verify all tests pass.
- If tests fail, return findings to Coder (loop back to Step 1).

Tester must pass before Reviewer runs. No exceptions.

**Step 3 — Reviewer**

After Tester passes, launch the **reviewer** agent to:

- Review the code against the architecture document, UI specification, project conventions, and any Approval Conditions from the CEO.
- Classify every finding as a **Defect** (incorrect behaviour, broken functionality, violated contract) or an **Issue** (structural problem, convention violation, maintainability concern).
- If there are no findings, proceed to Step 4.

**Step 3a — Defects → Debugger → Bug Gatherer → Product**

For every Reviewer finding classified as a **Defect**:

1. Launch the **debugger** agent to investigate the root cause and propose solutions. Debugger logs the investigation.
2. Launch the **bug-gatherer** agent to file the finding as a structured bug report in `artifacts/BUGS.md` using the Bug Report Template.
3. Hand the filed report to the **product** agent for triage. Product decides whether the defect blocks the current task, is fixed later, or is closed as not-a-bug.
4. If Product triages the defect as "fix now", the defect returns to Coder (loop back to Step 1) with Debugger's root-cause analysis attached.

**Step 3b — Issues → Refactor → Reviewer**

For every Reviewer finding classified as an **Issue**:

1. Launch the **refactor** agent to restructure the code without changing behaviour, citing the architectural principle or quality standard that justifies the change.
2. After Refactor hands off, return to **Reviewer** (loop back to Step 3) to confirm the issue is resolved. Tester re-runs before Reviewer re-reviews, per the test gate rule.

Step 3a and Step 3b may run in parallel when the findings are independent. A task does not advance to Step 4 until the Reviewer has approved a clean version.

**Step 4 — Product Validation**

After Reviewer approves, the **product** agent validates the task against its acceptance criteria using the Task Validation Checklist. If any criterion is not met, return to Coder (loop back to Step 1) with the cited criterion.

### Completion

After all tasks for the milestone are complete (or the specified task is done):

1. Run `[TEST_CMD]` one final time to confirm everything still passes.
2. Write a milestone completion record at `artifacts/milestones/milestone-{N}-{slug}-completion.md` using the template in `templates/MILESTONE_COMPLETION.md`.
3. Append a final entry to `artifacts/STANDUP.md` summarizing the run.
4. Summarize what was implemented, test results, any defects filed in `artifacts/BUGS.md`, and the status of every Approval Condition from the CEO.
5. Suggest next steps — additional tasks, a release via the **release** agent, or a new planning run via `/agent-plan`.

### Error Handling

- If a task is blocked by an unfinished dependency, skip it and record the blocker in `artifacts/STANDUP.md`.
- If the Coder–Tester–Reviewer loop runs more than `[MAX_LOOP_COUNT]` times on the same task, stop and escalate to the user with the specific blocker.
- If the architecture document or UI specification is ambiguous, flag it rather than guessing. Pause the task and notify the user to re-run the relevant stage of `/agent-plan`.
- If tests fail due to environment rather than code, Tester flags the failure as "Environment Issue" and the Validator process rule applies — Coder is not blocked from continuing other work.

Do NOT write any work artifact to `docs/`; that directory is reference-only. All live work — bug reports, completion records, progress entries — goes under `artifacts/`.
