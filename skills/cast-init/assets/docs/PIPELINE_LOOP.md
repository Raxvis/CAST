<!-- TEMPLATE INSTRUCTIONS
  FILE: PIPELINE_LOOP.md
  PURPOSE: The canonical engineering-loop contract. Both pipeline skills that run
           engineering work — /agent-code (per milestone task) and /agent-task (one-off
           task) — execute the loop defined here. The skills state only their deltas;
           this file is the single place the loop, the Handoff Protocol, the Defect/Issue
           routing, and the loop-counter rules are spelled out. If you change the loop,
           change it here — not in the skills.

  HOW TO CUSTOMIZE:
  - [TEST_CMD] and [MAX_LOOP_COUNT] are substituted by /cast-init at install time
    ([MAX_LOOP_COUNT] defaults to 3). If you are editing an installed copy, they are
    already concrete values.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# The Engineering Loop

The per-task engineering sequence executed by `/agent-code` and `/agent-task`. The unit of work is a **task file** (an instance of `templates/TASK.md` — `artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md`, or `artifacts/one-off/task-{slug}.md`). The orchestrating skill selects the task file and then runs this loop until the task passes Product validation or the loop cap escalates. The loop is defined per task; `/agent-code` may run loops for independent tasks concurrently under its **Parallel Task Execution** rules — parallelism is an orchestration concern and lives there, not here.

---

## Handoff Protocol

This is the pipeline's minimal-context contract. Every stage — in this loop and in `/agent-plan` — ships the next agent the least context it needs, through the task file, not through conversation.

1. **The task file is the handoff medium.** All stage-to-stage communication travels through the task file's **Handoff Log** — an append-only sequence of fixed-format entries (see `templates/TASK.md`). Conversation context is never carried between stages; a stage invocation contains the task file path and nothing else that isn't in the file.
2. **The read set is closed.** An agent working a task reads exactly: (a) its own agent definition, (b) the task file, (c) the entries in the task file's **Context Manifest**, and (d) whatever the latest Handoff Log entry lists under "Read next". Nothing else — not the milestone directory, not sibling tasks, not full design documents when the manifest cites sections. If an agent finds the manifest insufficient, that is a planning defect: it adds the missing reference to the manifest (so the next stage benefits), notes it in its handoff entry, and continues.
3. **Handoff entries are capped.** One entry per stage transition, fixed fields (Outcome / Files touched / Read next / Open items), max 10 lines, no narrative recap. Anything longer belongs in the artifact the entry points to — a bug file, a review file, the code itself — with only the pointer in the entry. **One exception:** Reviewer entries and Tester failure entries add one line per finding/failure beyond the fixed fields — for those stages the Handoff Log *is* the canonical record, and dropping findings to fit a cap is never acceptable. They still carry no narrative.
4. **Findings live in their canonical artifact, pointers travel.** Test failures, review findings, and bug details are written where they canonically live (the task file's Handoff Log for stage findings; a per-bug file for defects); the handoff entry carries the pointer, never a copy.
5. **Milestone-grain agents have milestone-grain read sets.** The closed read set above governs per-task stages. Stages that are milestone-scoped by role read what their role defines: CEO reads the milestone README, design docs, and Stage 3 reviews; milestone-completion stages read the task files' Headers and the artifacts their templates cite. Even these read only within the milestone's directory plus the cross-milestone root files.
6. **The reply channel carries routing metadata only.** A stage's final report back to the orchestrator is a single line — `Handoff entry #<n> appended — <outcome>; next: <stage>` — because the Handoff Log entry, not the chat reply, is the report. The orchestrator routes on that line and never re-narrates, summarizes, or re-reads a stage's output into its own context. This is the other half of the minimal-context contract: capped reads going in, one-line replies coming out, so the orchestrator's context stays flat across a whole milestone.

## Loop counter rules

The loop may cycle. One full cycle is any return to Step 1 (Coder) or any Refactor→Tester→Reviewer round.

- Track the count in the task file's Header (`Loop count` field) and **escalate to the user after `[MAX_LOOP_COUNT]` cycles** on a single task, stating the specific blocker.
- Mirror the count in `artifacts/STANDUP.md` after each cycle as a `loop` entry per that file's Entry Grammar — `- <agent> | loop | Task <id>: loop <k>/[MAX_LOOP_COUNT]`, where `<agent>` is the agent whose findings sent the loop back — so an interrupted run resumes with the real count.
- **Refactor → Tester → Reviewer rounds increment the same counter** — the Issue subloop has no private limit of its own.
- If Refactor reports that an Issue cannot be resolved without an architecture change (structural disagreement), the escalation to the user must carry that flag and name Architecture as the needed re-entry point (`/agent-plan`).

## Test gate rule

Tester must pass before Reviewer runs. No exceptions. This gate also applies inside the Issue subloop: after Refactor hands off, Tester re-runs before Reviewer re-reviews.

**Targeted re-runs inside the loop.** Within Defect/Issue cycles, Tester runs the targeted test set for the affected modules (Refactor's handoff entry names the tests to re-run; for Defect fixes, the tests covering the changed code). The **full `[TEST_CMD]` suite** still gates Step 4 (Product validation) and the orchestrating skill's completion step — k loop iterations must not cost k full-suite runs.

## Environment Issue rule

If tests fail due to environment rather than code, Tester flags the failure as "Environment Issue" in its handoff entry instead of failing the gate on the code. In `/agent-code`, the orchestrating skill invokes the **validator** agent mid-loop; Validator pauses the test gate and escalates the infrastructure problem to the user, and Coder is not blocked from continuing other work. In `/agent-task`, no Validator is invoked — the user decides whether to continue.

---

## Step 1 — Coder

Launch the **coder** agent with the task file path to:

- Read the task file and its Context Manifest (per the Handoff Protocol — nothing else). On a loop re-entry, start from the latest Handoff Log entry.
- Implement the task in production code, following the conventions the manifest cites (at minimum `CLAUDE.md` and `docs/CODE_PATTERNS.md`).
- If the change alters something documentation-worthy (APIs, commands, config, conventions, user-facing behavior), append a `- coder | docs | <note>` entry to the current session in `artifacts/STANDUP.md` per its Entry Grammar — this queue is what Docs Writer drains at the task- and milestone-completion checkpoints.
- Complete the Pre-Handoff Checklist, then append its Handoff Log entry (coder → tester): what was implemented, files touched, which tests cover the change.

## Step 2 — Tester

After Coder hands off, launch the **tester** agent with the task file path to:

- Write or update unit tests covering the changed code (the files named in Coder's handoff entry).
- Run `[TEST_CMD]` to verify all tests pass (first cycle); on subsequent cycles within the loop, run the targeted set per the test gate rule.
- If tests fail, append the failure summary to the Handoff Log (tester → coder, pointing at the failing tests) and loop back to Step 1.
- On pass, append its Handoff Log entry (tester → reviewer): tests added/updated, suite result.

## Step 3 — Reviewer

After Tester passes, launch the **reviewer** agent with the task file path to:

- Review the changed code against the task file (description, acceptance criteria) and the manifest's convention and design references.
- Classify every finding as a **Defect** (incorrect behaviour, broken functionality, violated contract) or an **Issue** (structural problem, convention violation, maintainability concern), and append its Handoff Log entry listing every finding with its classification.
- If there are no findings, proceed to Step 4.

Within Step 3 (including the routing below), when a finding or its resolution changes something documentation-worthy (APIs, commands, config, conventions, user-facing behavior), the resolving agent appends a `- <agent> | docs | <note>` entry to the current session in `artifacts/STANDUP.md` — Docs Writer drains these at the completion checkpoints.

### Step 3a — Defects → Bug Gatherer → Product → Debugger

For every Reviewer finding classified as a **Defect**:

1. Launch the **bug-gatherer** agent to file the finding as a standalone bug file — `bugs/bug-{XXX}-{slug}.md` beside the task (created from `templates/BUG_REPORT.md`, status New) — and add its row to the index in `artifacts/BUGS.md`. The bug file, not the handoff entry, carries the full report.
2. Hand the filed report to the **product** agent for triage. Product sets the final severity and issues one of three triage outcomes:
   - **Fix Now** — launch the **debugger** agent to investigate the root cause and append the Investigation section to the bug file (status In Progress). The defect then returns to Coder (loop back to Step 1); Coder's read set gains the bug file via "Read next" in the handoff entry.
   - **Defer** — the bug file stays **open** with status Deferred. Deferred is a held-open state, not terminal: Product re-triages every Deferred bug at the `/agent-code` milestone-completion checkpoint and at `/agent-plan` Stage 1 (sweeping the index in `artifacts/BUGS.md`). Deferral is allowed only if the defect does not violate the task's acceptance criteria; the task proceeds without looping.
   - **Not a Bug** — Product sets the status to Won't Fix (terminal) with a rationale recorded in the bug file's Notes; the task proceeds without looping.

Only **Fix Now** defects send the task back through the loop. Deferred and Won't Fix reports never block the task.

### Step 3b — Issues → Refactor → Tester → Reviewer

For every Reviewer finding classified as an **Issue**:

1. Launch the **refactor** agent to restructure the code without changing behaviour, citing the architectural principle or quality standard that justifies the change. Refactor's handoff entry names the tests to re-run for the affected modules.
2. After Refactor hands off, **Tester re-runs first** (targeted set, per the test gate rule), then return to **Reviewer** (loop back to Step 3) to confirm the issue is resolved.

Step 3a and Step 3b may run in parallel when the findings are independent. A task does not advance to Step 4 until the Reviewer has approved a clean version — **clean means no open Fix Now defects and no unresolved Issues**. Open Deferred and Won't Fix reports do not count against a clean version.

(Tester failures are not Defects in this sense — they route back to Coder directly at Step 2, without Bug Gatherer or triage.)

## Step 4 — Product Validation

After Reviewer approves, launch the **product** agent with the task file path to validate the task against its acceptance criteria. In `/agent-code`, Product validates against the task file's criteria, applying the Task Validation Checklist in `templates/MILESTONE_VALIDATION.md` as the *criteria*; the outcome is recorded as the task file's Status (Header) plus a `progress` entry in `artifacts/STANDUP.md` — no per-task validation document is produced (the validation *document* is milestone-grain only, written at the milestone-completion checkpoint). In `/agent-task`, the task description itself serves as the acceptance criteria. If any criterion is not met, append the handoff entry citing the failed criterion and return to Coder (loop back to Step 1).

---

Do NOT write any work artifact to `docs/`; that directory is reference-only. All live work — task files, bug files, progress entries, completion records — goes under `artifacts/`.
