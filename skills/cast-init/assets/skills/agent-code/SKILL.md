---
name: agent-code
description: >-
  Run the CAST Engineering Stage for a CEO-approved milestone: Coder (implement, test,
  commit) → Reviewer (review, classify, criteria check) → validation, with Defects routed
  through Product triage and Issues back to Coder. Use when the user asks to implement an
  approved milestone or invokes /agent-code. Requires an existing CEO verdict in the
  milestone directory's reviews/ceo.md.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /agent-code pipeline skill. It runs the Engineering Stage for
an approved milestone by executing the canonical loop in docs/PIPELINE_LOOP.md. This file
carries only the deltas specific to milestone work.

READ docs/PIPELINE_LOOP.md — you (the orchestrator) are its audience. Agents do not read it;
they read docs/STAGE_CONTRACT.md. Do not pass the loop doc into a stage invocation.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.
2. Replace [TEST_CMD] with your project's test command.
3. Replace [MAX_LOOP_COUNT] with the Coder-Reviewer cycles allowed before escalation
   (default: 3).

INSTALLATION: installs to `.claude/skills/agent-code/SKILL.md` (done automatically by
/cast-init). Invoke with `/agent-code <milestone or task id>`.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /agent-code — Engineering Pipeline

Run the engineering stage for a milestone the CEO approved during `/agent-plan`. Implements code, runs tests, reviews the diff, and validates against acceptance criteria. All work artifacts land under `artifacts/`.

## Agents this skill invokes

- [coder](../../agents/coder.md) — implements, writes and runs the tests, commits; handles every loop-back
- [reviewer](../../agents/reviewer.md) — verifies the test-results gate, reviews the diff, classifies findings, files bugs, records the Acceptance Criteria Check
- [product](../../agents/product.md) — triages bugs, validates tasks Reviewer flagged, disposes of amendments, and at milestone completion re-triages Deferred items and writes the close record in one pass
- [ui](../../agents/ui.md) — milestone UX review (UI-flagged milestones only)
- [ceo](../../agents/ceo.md) — risk implementation review and measured performance check (flagged milestones only)
- [docs-writer](../../agents/docs-writer.md) — drains the `docs` queue at milestone completion, or at an overflow drain

**Spawn only these, exactly as written.** No ad-hoc subagents, no extra verification passes (the executing model self-verifies within each stage), no collapsing a stage into direct work.

## Model Compatibility

Each stage runs on the model in its agent file (default `inherit` — the session model). Effort is per agent file (Coder `medium`, Reviewer `high`, Product `high`/`low` by duty) and fixed at that pin — an invocation cannot raise it; `xhigh` is opt-in through a permanent edit to the agent file. Reviewer reports every Defect and Issue it finds — filtering happens in triage, never at review time. Per-model profiles: `docs/MODEL_OPTIMIZATION.md`.

## Input

The argument text the user provided (e.g. `/agent-code milestone-1`) — a milestone, or a task within it. If none was provided, ask before Pre-Flight.

## Instructions

### Pre-Flight Check

0. **Resolve the milestone.** Resolve the input to the unique `artifacts/milestone-{N}-*` directory. No match: stop and list what exists. Multiple matches: stop and ask. Never guess.
1. **Verify the directory contains:** `README.md` (definition, Task Index, CEO Approval Conditions), `tasks/` with one file per Task Index row, `architecture.md`, `reviews/ceo.md`. `ui.md` is required only when at least one task file's Header has **Needs UI Spec** = Yes or Done — `/agent-plan` writes the spec for UI-flagged tasks and skips it otherwise. A milestone with no UI-flagged task, or a project that installed no `ui` agent at all (check `.claude/agents/ui.md`), proceeds without it, and that absence is not a missing artifact.
2. **Read the CEO verdict** from the single `**Verdict**:` line in `reviews/ceo.md`. Proceed only on APPROVED or APPROVED WITH CONDITIONS. On REVISION REQUIRED, or a genuinely missing planning artifact, stop and tell the user to run `/agent-plan <milestone>`.
3. **On APPROVED WITH CONDITIONS**, read the Approval Conditions from the README table. Cross-check against the CEO review; if the table is missing or stale, extract the conditions from the review, backfill the table, and add a `../README.md § CEO Approval Conditions` manifest row to every task a condition names — before proceeding.
4. **Open the session** in `artifacts/STANDUP.md`: add `### YYYY-MM-DD — agent-code — milestone-{N}-{slug}` at the top of the Log before any entries. On a resumed run, reuse the existing heading for this milestone and date.
5. **Set Status to In Progress** in the README Header (skip if already set).

### Task Selection

1. Read the README's Task Index, then only the **Header** of each task file (Status, Dependencies) — not the bodies.
2. **Skip tasks already Complete or Deferred.** The Status writeback is what makes this skill resumable. Deferred tasks stay held until Product re-triages them.
3. If the input names a single task, work only that one.
4. Otherwise work in dependency order per each task's **Dependencies** field.

### Per-Task Loop

Execute the loop in `docs/PIPELINE_LOOP.md` — Coder → Reviewer → validation, with the Defect and Issue routing, commit discipline, test gate, amendment rule, loop counters, and Environment Issue rule. That doc is the canonical statement; do not improvise routing.

**Task release.** When you select a task, append its first Handoff Log entry yourself — `orchestrator -> coder — task released` (Outcome: released for implementation; Read next: Manifest only). You write this one entry and no others; every later entry comes from a stage.

Deltas for this skill:

- **Every stage receives the task file path** and reads only that file, its Context Manifest, and the latest entry's "Read next" (`docs/STAGE_CONTRACT.md`). Never pass whole design documents into a stage — the manifest cites the sections each task needs. A stage that finds the manifest insufficient adds the missing reference and notes it.
- **Never pass `docs/PIPELINE_LOOP.md` into a stage.** It is yours; stages read `docs/STAGE_CONTRACT.md`.
- **Stage replies are one routing line**: `Handoff entry #<n> appended — <outcome>; next: <stage>`. Route on it. Never relay, summarize, or re-read a stage's work into your context — the Handoff Log on disk is the record.
- **Coder (Step 1)** additionally honors any Approval Conditions the task's manifest points at.
- The test-gate pre-check, the criterion-violating-Defect auto-route, and the batch-triage rule are part of the loop doc (Step 2 and 2a/2b) — apply them as written there. In particular, the pre-check's uncounted return is a **once-per-task** free retry for a *missing* Test Results block; a second missing block, or a block showing failures, increments the loop counter like any other cycle.

### Parallel Task Execution

Independent tasks may run their loops **concurrently**. Sequential is the default whenever a guardrail cannot be met.

**Eligibility.** For every pair: (a) neither depends on the other (transitively), and (b) their **Files** sections are disjoint. Run at most **3** concurrently.

**Rules.**

1. **Event-driven, not round-barriered.** Launch a stage for every eligible in-flight task (different tasks may be at different stages). When any stage's routing line arrives, route that task's next stage immediately — do not hold a fast task's next launch waiting for a slower task's stage to return. The rules below serialize *state*, never scheduling.
2. **Shared-root writes are orchestrator-serialized.** During parallel execution stages do NOT write `artifacts/STANDUP.md`, `artifacts/BUGS.md`, or `artifacts/AGENT_STATE.md`. A stage records what it would have written in its handoff entry's Open items as `standup: - <agent> | <type> | <note>`; you flush queued lines in order, one write at a time, at each serialization point. The task file's `Loop count` remains the live counter.
   - **Exception — bug files.** Reviewer writes the per-bug *file* itself (that file is private to its finding), but not the `artifacts/BUGS.md` index row. Reviewer records the intended row in its handoff entry; you assign the next free ID and write the index row. Two concurrent filings would otherwise race the ID.
3. **Triage is serialized across tasks.** Run one Product triage chain at a time; other tasks' defect routing queues behind it. The rest of their loops continue.
4. **Checkpoints are serialized** — they touch shared root files by design.
5. **Emergent overlap pauses the newer task.** If a stage must modify a file outside its task's declared Files list and that file belongs to another in-flight task, pause the younger task until the older completes, and note the pause in its Handoff Log.

**When in doubt, don't parallelize.** A wrongly-serialized milestone is merely slower; a wrongly-parallelized one corrupts shared state.

### Milestone Circuit Breaker

The per-task cap (`[MAX_LOOP_COUNT]`) guards one runaway task; these guard a runaway milestone. Before each round, check the task files' `Loop count` Headers:

- **Breadth**: more than half the started tasks have looped at least once, or
- **Depth**: total Loop counts have reached 2× the Task Index row count.

When either trips, pause and escalate with: which tasks are looping and on what, the total loop-back count, and a cost note (stages launched so far versus a clean run — **a clean v3 task is two stages**). A milestone where everything loops is telling you its plan is wrong; the user decides whether to continue, re-plan, or stop. Amendments do not count toward either trigger, but they carry a cap of their own: at most **2 per task**, with a third proposal pausing that task and escalating to the user exactly as this breaker does (`docs/PIPELINE_LOOP.md` → Task-amendment rule).

### Completion

#### Task-completion checkpoint (after every task)

**Launches no agents.**

1. **Status writeback.** Mark the task's **Status** Complete in its own file's Header — the single place task status lives, and what makes this skill resumable.
2. **Progress entry.** Append the task's `progress` entry to `artifacts/STANDUP.md` under this run's heading, per Step 3a or 3b.
3. **Overflow drain (conditional).** Count pending `docs` entries (the `- <agent> | docs | <note>` lines without ✅). At **10 or more**, invoke **docs-writer** now; below that, the queue waits for the milestone drain.

#### Milestone-completion checkpoint

Fires when every task file is Complete or Deferred.

1. Run `[TEST_CMD]` once more to confirm everything still passes.
2. **UX review.** If any task has **Needs UI Spec** = Yes or Done, launch **ui** once to review the implemented screens against `ui.md` and write `reviews/ux.md`. Skip otherwise. If the project installed no `ui` agent (check `.claude/agents/ui.md`), skip the review even on a UI-flagged milestone and note the skip in the checkpoint entry (`- agent-code | progress | UX review skipped: no ui agent installed`).
3. **Risk implementation review.** Read the two flag lines in `reviews/risk.md`. If **either** is Yes, launch **ceo** once to write `reviews/risk-impl.md` (`agents/ceo.md` → The implementation review) — reviewing the milestone's implementation diff against the planned controls for the security lens, and measuring against the budgets for the performance lens (recording Current vs. Target in `risk-impl.md`; you transcribe the budget rows into `artifacts/AGENT_STATE.md` at step 6 — agents never touch that file). One invocation covers both lenses. Skip when both flags say No or `reviews/risk.md` does not exist (the planning risk lenses were skipped).
   - Findings from steps 2–3 are filed as bug files, triaged by Product inside the close pass below. A **Fix Now** finding sends the affected task back into the loop; the close pass runs (or is revised) once it resolves. Deferred findings join Known Issues.
4. **Milestone close (one product launch).** Launch **product** once to close the milestone end-to-end — the steps are strictly sequential and each consumes what the previous produced, so they share one context:
   - **Re-triage** every Deferred bug in `artifacts/BUGS.md` and every Deferred task file — schedule, re-defer with an updated rationale, or close as Won't Fix with a rationale — plus any bugs steps 2–3 just filed.
   - **Write `reviews/close.md`** (`templates/MILESTONE_CLOSE.md`): the Per-Task Validation table covers **every** task including Step 3a closures, citing Reviewer's Acceptance Criteria Check as evidence; the retrospective sections fill every metric from its recorded source.
   - **Verify each CEO Approval Condition** — flip Status to Verified with verifier and date, or leave it open under Known Issues.
   - **Set Status** — **Complete with Deferrals** when anything remains Deferred, otherwise **Complete** — and mirror it into the README Header.
5. **Docs Writer.** If any pending `docs` entries remain (`- <agent> | docs | <note>` lines without ✅), launch **docs-writer** to drain them. This is the milestone's primary drain; skip only when the queue is empty.
6. **Record and archive (orchestrator, no agent).** Append the milestone's rows to `artifacts/AGENT_STATE.md` — Milestone Progress, any Decisions Log entries stages surfaced in their handoff entries, and the Performance Budget Current/Status values from `reviews/risk-impl.md` when step 3 ran (a transcription of measurements already on record). Then bound the root files: move `artifacts/one-off/task-*.md` with Status Complete to `artifacts/one-off/archive/`; move STANDUP session sections older than this milestone's first session to `artifacts/archive/STANDUP.md`; move closed AGENT_STATE rows dated before it to `artifacts/archive/AGENT_STATE.md`. Never move unresolved Open Questions, the Milestone Progress table, or the Performance Budget table. Rows relocate verbatim — the history stays greppable.
7. Append a final `progress` entry summarizing the run.
8. **Summarize** for the user: what was implemented, test results, bugs filed (including any still Deferred), the outcome of each completion review that ran, and the status of every Approval Condition.
9. **Suggest next steps** — more tasks, `/cast-release`, or a new `/agent-plan` run.

### Error Handling

- A task blocked by an unfinished dependency: skip it, record a `blocker` entry.
- An ambiguous architecture document or UI spec: flag it, pause the task, tell the user to re-run the relevant `/agent-plan` stage. Do not guess.
- Loop-cap escalation and Environment Issue handling follow `docs/PIPELINE_LOOP.md`. On an Environment Issue, pause the task and escalate the infrastructure problem to the user directly — v3 has no Validator agent for this; other tasks are not blocked.

Do NOT write any work artifact to `docs/`; that directory is reference-only.
