---
name: agent-code
description: >-
  Run the CAST Engineering Stage for a CEO-approved milestone: Coder → Tester →
  Reviewer, with Defects routed through Bug Gatherer → Product triage → Debugger and
  Issues through Refactor → Tester → Reviewer, then Product validation. Use when the user asks
  to implement an approved milestone or invokes /agent-code. Requires an existing CEO
  verdict in the milestone directory's reviews/ceo.md.
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
- [product](../../agents/product.md) — triages bug reports, validates completed tasks against acceptance criteria, disposes of task-amendment proposals, re-triages Deferred bugs and tasks at milestone completion, and writes the milestone completion and validation records (verifying the CEO Approval Conditions as part of them)
- [ui](../../agents/ui.md) — performs the milestone UX review at the milestone-completion checkpoint (milestones with UI-flagged tasks only)
- [security](../../agents/security.md) — performs the milestone security implementation review at the milestone-completion checkpoint (security-flagged milestones only)
- [performance](../../agents/performance.md) — performs the measured performance check at the milestone-completion checkpoint (milestones whose plan set budgets only)
- [docs-writer](../../agents/docs-writer.md) — drains the `docs` queue from `artifacts/STANDUP.md` at task- and milestone-completion checkpoints
- [validator](../../agents/validator.md) — records task and milestone outcomes in `artifacts/AGENT_STATE.md`, writes the milestone retrospective, and (invoked mid-loop) pauses the test gate when Tester flags an Environment Issue

The planning-stage outputs this skill reads were produced earlier by [architect](../../agents/architect.md), [ui](../../agents/ui.md), [security](../../agents/security.md), [performance](../../agents/performance.md), and signed off by [ceo](../../agents/ceo.md). This skill does not re-invoke them during the per-task loop; the planning-stage agents it re-invokes are **ui**, **security**, and **performance** — each at most once, at the milestone-completion checkpoint, and each only when its flag condition is met (steps 4–6 there).

## Input

The argument text the user provided when invoking this skill (e.g. `/agent-code milestone-1`) — the milestone to implement, or a specific task identifier within that milestone. If none was provided, ask for one before the Pre-Flight Check.

## Model Compatibility

Each stage runs on the model set in that agent's file (default: `inherit` — the session model; the Claude Opus family is the optimized target, with `claude-opus-5` preferred and `claude-opus-4-8`, `claude-opus-4-7`, and `claude-opus-4-6` supported — full profiles and upgrade paths in `docs/MODEL_OPTIMIZATION.md`). Orchestration notes by executing model:

- **Opus 5** — this model delegates readily and expands scope; invoke only the agents named in the stages below, spawn no ad-hoc subagents beyond them, and hold each task to its Files list. Do not add extra verification passes — the model self-verifies within each stage.
- **Opus 4.8 / 4.7** — these models delegate conservatively; the explicit stage invocations below are load-bearing. Execute every stage exactly as written, including the Defect/Issue routing loops.
- **Opus 4.6** — this model over-delegates; invoke only the agents named in the stages below and spawn no ad-hoc subagents beyond them.
- **Effort** — run the Coder, Reviewer, and Debugger stages at `xhigh` on Opus 4.7+ (`high` on Opus 4.6); Tester, Refactor, routing, and Product validation at `high`.
- **Review recall (all supported models)** — Opus 5, 4.8, and 4.7 follow severity filters literally: the Reviewer stage must report every Defect and Issue found; filtering happens in the routing stages, never at review time.

## Instructions

This skill orchestrates the **Engineering Stage** of the agent workflow. It requires that `/agent-plan` has already been completed and the CEO has issued APPROVED or APPROVED WITH CONDITIONS.

### Pre-Flight Check

Before any task begins:

0. **Resolve the milestone.** Resolve the invocation input to the unique `artifacts/milestone-{N}-*` directory (e.g. `milestone-1` → `artifacts/milestone-1-task-crud/`). If it matches no directory, stop and list the milestone directories that exist; if it matches more than one, stop and ask the user to disambiguate. Never guess.
1. Verify the milestone directory `artifacts/milestone-{N}-{slug}/` exists and contains:
   - `README.md` — the milestone definition, Task Index, and CEO Approval Conditions
   - `tasks/` with one `task-{T}-{slug}.md` file per Task Index row
   - `architecture.md`
   - `ui.md` — required only when the `ui` agent is installed (check for `.claude/agents/ui.md`); no-ui projects proceed without it
   - `reviews/ceo.md`
2. Read the CEO review and read the verdict from its single `**Verdict**:` line (defined by `templates/CEO_REVIEW.md`); confirm it is APPROVED or APPROVED WITH CONDITIONS. If the verdict is REVISION REQUIRED, or a genuinely required planning artifact from step 1 is missing, stop and instruct the user to run `/agent-plan <milestone>` first. A UI spec absent because no `ui` agent is installed is not a missing artifact — do not stop for it; downstream stages then run without a UI specification.
3. If APPROVED WITH CONDITIONS, read the Approval Conditions from the **CEO Approval Conditions** table in the milestone README (backfilled by Product at the end of `/agent-plan`). Cross-check the table against the CEO review itself; if the table is missing or stale, extract the conditions from the CEO review, backfill the README table, and add the `../README.md § CEO Approval Conditions` manifest row to every task file a condition names, before proceeding. The conditions must be addressed as part of implementation and verified during Reviewer / Product validation.
4. Open the run's session in `artifacts/STANDUP.md`: add a session heading `### YYYY-MM-DD — agent-code — milestone-{N}-{slug}` at the top of the Log, per that file's Entry Grammar, **before any entries are written**. (On a resumed run, reuse the existing heading for this milestone and date instead of adding a duplicate.) Every `loop`, `docs`, `blocker`, and `progress` entry this run writes goes under this heading.
5. **Set the milestone Status to In Progress.** Update the Header Status field in the milestone README from CEO-Approved to In Progress (skip if already In Progress on a resumed run). The README's Status must reflect reality for the whole engineering phase — Product later mirrors the completion Status into the same field.

### Task Selection

1. Read the Task Index in the milestone README, then read only the **Header** of each task file under `tasks/` (Status and Dependencies) — not the task bodies.
2. **Skip any task whose Status is already Complete or Deferred.** The task-completion checkpoint below writes Status into the task file's Header, so a re-invocation after an interruption resumes from the first remaining task instead of redoing finished work. Deferred tasks are not worked — they stay held until Product re-triages them at the milestone-completion checkpoint or at the next `/agent-plan` Stage 1.
3. If the invocation input specifies a single task, work on only that task.
4. Otherwise, work through tasks in dependency order, respecting each task's **Dependencies** field (defined in `templates/TASK.md`).

### Per-Task Loop

For each task, execute the engineering loop defined in `docs/PIPELINE_LOOP.md` — Coder → Tester → Reviewer (with the Defect and Issue routing) → Product validation — including its Commit discipline, task-amendment rule, loop-counter rules, test-gate rule, and Environment Issue rule. The loop doc is the single canonical statement of that sequence; do not improvise routing.

**Task release.** When the orchestrator selects a task and starts its loop, it appends the task's first Handoff Log entry itself — `orchestrator → coder — task released` (Outcome: released for implementation; Read next: Manifest only) — so the log opens with a dated release record and every stage has a prior entry to start from. The orchestrator writes this one entry and no others; all subsequent entries come from stages.

Inputs specific to this skill, governed by the loop doc's **Handoff Protocol** — each stage invocation carries the task file path; the task file's Context Manifest and Handoff Log carry everything else:

- **Every stage** receives the task file path (`artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md`) and reads only that file, its Context Manifest entries, and the latest handoff entry's "Read next". Do not pass whole design documents into stages — the manifest cites the sections each task needs; a stage that finds the manifest insufficient adds the missing reference and notes it in its handoff entry.
- **Stage replies are one routing line** (Handoff Protocol rule 6): `Handoff entry #<n> appended — <outcome>; next: <stage>`. Route on that line; never relay, summarize, or re-read a stage's work into this skill's context — the Handoff Log on disk is the record. This keeps the orchestrating context flat across an entire milestone.
- **Coder (Step 1)** additionally honors any Approval Conditions the task's manifest points at (`../README.md § CEO Approval Conditions`).
- **Product validation (Step 4)** validates against the task file's acceptance criteria, applying the Task Validation Checklist in `templates/MILESTONE_VALIDATION.md` as the *criteria*. The outcome is recorded as the task file's Status (Header) plus a `progress` entry in `artifacts/STANDUP.md` — no per-task validation document is produced; the validation *document* is written once, at the milestone-completion checkpoint.

### Parallel Task Execution

Independent tasks may run their engineering loops **concurrently** — task isolation makes this safe, with the guardrails below. Sequential execution remains the default whenever any guardrail cannot be met.

**Eligibility.** Tasks may run in parallel only when, for every pair: (a) neither depends on the other (Dependencies fields, transitively), and (b) their **Files** sections are disjoint — two Coders editing the same source file is a merge conflict, not parallelism. Run at most **3** tasks concurrently.

**Rules.**

1. **Execution proceeds in rounds; stages within a task stay sequential.** Subagent stages launched together return together — the harness is batch-barriered, so there is no launching task A's next stage while task B's current stage is still running. Each round: launch one eligible stage per in-flight task (different tasks may be at different stages — one round can contain task A's Reviewer and task B's Coder), collect all routing lines, then launch the next round. Same throughput as event-driven phrasing, honest mechanics. Each stage writes only its own task file and the code files its task declares.
2. **All shared-root writes are orchestrator-serialized.** During parallel execution, stage agents do NOT write to `artifacts/STANDUP.md`, `artifacts/BUGS.md`, or `artifacts/AGENT_STATE.md`. A stage that would write a STANDUP entry (`loop`, `docs`, `blocker`) records it in its handoff entry's Open items as `standup: - <agent> | <type> | <note>`; the orchestrator flushes queued lines to STANDUP — in order, one file-write at a time — at each serialization point (a task entering a checkpoint, a defect being filed, an escalation). The task file's Header `Loop count` remains the live counter, so deferred STANDUP mirroring loses nothing.
3. **Defect filing is serialized across tasks.** Step 3a assigns the next bug ID by reading the `artifacts/BUGS.md` index — two concurrent filings would race the ID and the index row. Run only one Step 3a chain (Bug Gatherer → Product triage → Debugger) at a time across all parallel tasks; other tasks' defect routing queues behind it. The rest of their loops may continue.
4. **Checkpoints are serialized.** Task-completion checkpoints (and the milestone-completion checkpoint) run one at a time — they touch the shared root files by design.
5. **Emergent overlap pauses the newer task.** If a stage discovers it must modify a file outside its task's declared Files list and that file belongs to another in-flight task, the orchestrator pauses the younger task until the older one's loop completes, and notes the pause in the paused task's Handoff Log.

**When in doubt, don't parallelize.** A wrongly-serialized milestone is merely slower; a wrongly-parallelized one corrupts shared state.

### Milestone Circuit Breaker

The per-task loop cap (`[MAX_LOOP_COUNT]`) guards a single runaway task; these aggregate triggers guard a runaway milestone. Before launching each round of stages, check two counters across the milestone's task files (the Header `Loop count` fields — no new bookkeeping):

- **Breadth**: more than half of the milestone's started tasks have looped at least once, or
- **Depth**: the sum of Loop counts across all tasks has reached 2× the Task Index row count.

When either trips, pause the run and escalate to the user with: which tasks are looping and on what, the total loop-back count, and a cost sanity note (stages launched so far versus a clean run — a clean task is four stages). A milestone where everything loops is telling you its plan is wrong; the user decides whether to continue, re-plan via `/agent-plan`, or stop. Task amendments (`docs/PIPELINE_LOOP.md` → Task-amendment rule) do not count toward either trigger.

### Completion

#### Task-completion checkpoint (after every task)

Run this checkpoint each time a task passes Product validation — including single-task invocations:

1. **Status writeback.** Mark the task's **Status** as Complete in its own file's Header — the single place task status lives (the README's Task Index deliberately has no status column). This writeback is what makes the skill resumable (see Task Selection).
2. **Docs Writer.** Invoke the **docs-writer** agent to drain the `docs` entries from `artifacts/STANDUP.md` (entries of the form `- <agent> | docs | <note>` — see that file's Entry Grammar). Docs Writer marks each drained entry with ✅.
3. **Validator.** Invoke the **validator** agent to record the task outcome in `artifacts/AGENT_STATE.md` (Agent Status Dashboard and Milestone Progress tables in its section).

#### Milestone-completion checkpoint

This checkpoint fires when every task file under `tasks/` has Status Complete or Deferred:

1. Run `[TEST_CMD]` one final time to confirm everything still passes.
2. **Deferred re-triage.** Launch the **product** agent to re-triage every Deferred bug in the `artifacts/BUGS.md` index and every Deferred task file. Deferred is a held-open state, not terminal (see `artifacts/BUGS.md` → Bug Lifecycle): each item is either scheduled (pulled into follow-up work or the next milestone plan), re-deferred with an updated rationale, or closed as Won't Fix with a rationale.
3. Launch the **product** agent to write the milestone completion record at `artifacts/milestone-{N}-{slug}/reviews/completion.md` using `templates/MILESTONE_COMPLETION.md`, and the milestone validation record at `artifacts/milestone-{N}-{slug}/reviews/validation.md` using `templates/MILESTONE_VALIDATION.md`. Product — not the orchestrator — writes both records (they are Product's artifacts; see `artifacts/README.md`). **While writing the completion record, Product also verifies the CEO Approval Conditions**: for each row in the milestone README's table, confirm the recorded evidence and flip the Status to Verified (with verifier and date), or leave it Open/Addressed and list it under Known Issues — Product owns this flip; no other step performs it. The completion record's Status is **Complete with Deferrals** when any task or bug remains Deferred after re-triage, with every such item listed under its Known Issues section; otherwise **Complete**. Product mirrors that Status into the milestone README's Header.
4. **UX review.** If the milestone contains UI-flagged tasks (any task with **Needs UI Spec** = Yes or Done), launch the **ui** agent once to review the implemented screens against `artifacts/milestone-{N}-{slug}/ui.md` and write `artifacts/milestone-{N}-{slug}/reviews/ux.md` using `templates/UX_REVIEW.md`. Skip this step for milestones with no UI-flagged tasks.
5. **Security implementation review.** Read the single `**Implementation review required**:` line in `artifacts/milestone-{N}-{slug}/reviews/security.md` (written at planning — see `security.md`). If Yes, launch the **security** agent once to review the milestone's implementation diff — the commits made under this milestone's task IDs (Commit discipline, `docs/PIPELINE_LOOP.md`) — against the planned controls and its planning findings, writing `artifacts/milestone-{N}-{slug}/reviews/security-impl.md`. Findings are filed through Bug Gatherer for Product triage like any defect. Skip when the line says No or the file has no such line.
6. **Performance measured check.** Read the single `**Measured check required**:` line in `artifacts/milestone-{N}-{slug}/reviews/performance.md`. If Yes, launch the **performance** agent once to measure the implementation against the budgets the plan set (architecture document → Performance Budget; live table in `artifacts/AGENT_STATE.md` → `## performance`), writing `artifacts/milestone-{N}-{slug}/reviews/performance-impl.md` and updating the live budget table's Current/Status columns. Budget violations are filed through Bug Gatherer for Product triage. Skip when the line says No or the file has no such line.
   - If any step 4–6 finding is triaged **Fix Now**, the affected task re-enters the per-task loop; Product revises the completion record (new Revision History row) once it resolves. Deferred findings join the Known Issues list.
7. **Docs Writer.** Invoke the **docs-writer** agent to drain any remaining `docs` entries from `artifacts/STANDUP.md` (per its Entry Grammar; drained entries are marked ✅).
8. **Validator.** Invoke the **validator** agent to record the milestone outcome in `artifacts/AGENT_STATE.md` and write the milestone retrospective at `artifacts/milestone-{N}-{slug}/reviews/retrospective.md` using `templates/MILESTONE_RETROSPECTIVE.md`. As part of the same invocation, Validator performs archive hygiene (its Archival Duty section defines the mechanics): every `artifacts/one-off/task-{slug}.md` with Status Complete moves to `artifacts/one-off/archive/` (bug files stay put — the index rows point at them), closed session sections in `artifacts/STANDUP.md` and stale rows in `artifacts/AGENT_STATE.md` move to `artifacts/archive/`, keeping both live files bounded to the current milestone plus a tail.
9. Append a final entry to `artifacts/STANDUP.md` summarizing the run, using that file's Entry Grammar.
10. Summarize what was implemented, test results, any defects filed (per-bug files under `bugs/`, indexed in `artifacts/BUGS.md`, including any still Deferred after re-triage), the outcome of each completion review that ran (UX, security implementation, performance check), and the status of every Approval Condition from the CEO.
11. Suggest next steps — additional tasks, a release (the **release** agent is user-invoked after milestone completion; this skill does not launch it), or a new planning run via `/agent-plan`.

### Error Handling

- If a task is blocked by an unfinished dependency, skip it and record the blocker in `artifacts/STANDUP.md` (a `blocker` entry per its Entry Grammar).
- If the architecture document or UI specification is ambiguous, flag it rather than guessing. Pause the task and notify the user to re-run the relevant stage of `/agent-plan`.
- Loop-cap escalation (`[MAX_LOOP_COUNT]`) and Environment Issue handling follow the rules in `docs/PIPELINE_LOOP.md`. When Tester flags a failure as an Environment Issue, this skill invokes the **validator** agent mid-loop; Validator pauses the test gate and escalates the infrastructure problem to the user.

Do NOT write any work artifact to `docs/`; that directory is reference-only. All live work — bug reports, completion records, progress entries — goes under `artifacts/`.
