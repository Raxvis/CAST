<!-- TEMPLATE INSTRUCTIONS
  FILE: PIPELINE_LOOP.md
  PURPOSE: The canonical engineering-loop contract. Both pipeline skills that run
           engineering work — /agent-code (per milestone task) and /agent-task (one-off
           task) — execute the loop defined here. The skills state only their deltas;
           this file is the single place the loop, the Defect/Issue routing, and the
           loop-counter rules are spelled out. If you change the loop, change it here —
           not in the skills.

  HOW TO CUSTOMIZE:
  - [TEST_CMD] and [MAX_LOOP_COUNT] are substituted by /cast-init at install time
    ([MAX_LOOP_COUNT] defaults to 3). If you are editing an installed copy, they are
    already concrete values.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# The Engineering Loop

The per-task engineering sequence executed by `/agent-code` and `/agent-task`. The orchestrating skill supplies the task's inputs (see each skill's own instructions) and then runs this loop until the task passes Product validation or the loop cap escalates.

---

## Loop counter rules

The loop may cycle. One full cycle is any return to Step 1 (Coder) or any Refactor→Tester→Reviewer round.

- Track the count per task and **escalate to the user after `[MAX_LOOP_COUNT]` cycles** on a single task, stating the specific blocker.
- Record the count in `artifacts/STANDUP.md` after each cycle (`Task <id>: loop <k>/[MAX_LOOP_COUNT]`) so an interrupted run resumes with the real count.
- **Refactor → Tester → Reviewer rounds increment the same counter** — the Issue subloop has no private limit of its own.
- If Refactor reports that an Issue cannot be resolved without an architecture change (structural disagreement), the escalation to the user must carry that flag and name Architecture as the needed re-entry point (`/agent-plan`).

## Test gate rule

Tester must pass before Reviewer runs. No exceptions. This gate also applies inside the Issue subloop: after Refactor hands off, Tester re-runs before Reviewer re-reviews.

**Targeted re-runs inside the loop.** Within Defect/Issue cycles, Tester runs the targeted test set for the affected modules (Refactor's handoff names the tests to re-run; for Defect fixes, the tests covering the changed code). The **full `[TEST_CMD]` suite** still gates Step 4 (Product validation) and the orchestrating skill's completion step — k loop iterations must not cost k full-suite runs.

## Pass-forward rule

The orchestrating skill reads the task's input artifacts (task definition, architecture document, UI spec, Approval Conditions, convention docs) **once**, at task start, and passes the relevant content into each stage's invocation. Do not instruct Coder, Tester, and Reviewer to each independently re-open the same files — that pays the same read three times per cycle. An agent re-reads a file itself only when it needs sections the orchestrator did not supply.

## Environment Issue rule

If tests fail due to environment rather than code, Tester flags the failure as "Environment Issue" instead of failing the gate on the code. In `/agent-code`, the Validator escalation protocol applies (Validator pauses the test gate until infrastructure is resolved) and Coder is not blocked from continuing other work. In `/agent-task`, there is no Validator in the loop — the user decides whether to continue.

---

## Step 1 — Coder

Launch the **coder** agent to:

- Read the task's inputs supplied by the orchestrating skill (task definition or description, plus any planning artifacts).
- Implement the task in production code, following the conventions in `CLAUDE.md`, `docs/CODE_PATTERNS.md`, and `docs/FILE_CONVENTIONS.md`.
- Complete the Pre-Handoff Checklist before handing off.

## Step 2 — Tester

After Coder hands off, launch the **tester** agent to:

- Write or update unit tests covering the changed code.
- Run `[TEST_CMD]` to verify all tests pass (first cycle); on subsequent cycles within the loop, run the targeted set per the test gate rule.
- If tests fail, return findings to Coder (loop back to Step 1).

## Step 3 — Reviewer

After Tester passes, launch the **reviewer** agent to:

- Review the code against the inputs the orchestrating skill supplied (planning artifacts and conventions for `/agent-code`; conventions and adjacent patterns for `/agent-task`).
- Classify every finding as a **Defect** (incorrect behaviour, broken functionality, violated contract) or an **Issue** (structural problem, convention violation, maintainability concern).
- If there are no findings, proceed to Step 4.

### Step 3a — Defects → Bug Gatherer → Product → Debugger

For every Reviewer finding classified as a **Defect**:

1. Launch the **bug-gatherer** agent to file the finding as a structured bug report in `artifacts/BUGS.md` (status New), using the canonical entry format at the top of that file.
2. Hand the filed report to the **product** agent for triage. Product decides whether the defect is fixed now, fixed later, or closed as not-a-bug, and sets the final severity (status Triaged).
3. If Product triages the defect as "fix now", launch the **debugger** agent to investigate the root cause and update the existing record with the investigation fields (status In Progress).
4. The defect returns to Coder (loop back to Step 1) with Debugger's root-cause analysis attached.

### Step 3b — Issues → Refactor → Tester → Reviewer

For every Reviewer finding classified as an **Issue**:

1. Launch the **refactor** agent to restructure the code without changing behaviour, citing the architectural principle or quality standard that justifies the change. Refactor's handoff names the tests to re-run for the affected modules.
2. After Refactor hands off, **Tester re-runs first** (targeted set, per the test gate rule), then return to **Reviewer** (loop back to Step 3) to confirm the issue is resolved.

Step 3a and Step 3b may run in parallel when the findings are independent. A task does not advance to Step 4 until the Reviewer has approved a clean version.

## Step 4 — Product Validation

After Reviewer approves, launch the **product** agent to validate the task against its acceptance criteria (in `/agent-code`, the task definition's criteria, using the Task Validation Checklist in `templates/MILESTONE_VALIDATION.md`; in `/agent-task`, the task description itself serves as the acceptance criteria). If any criterion is not met, return to Coder (loop back to Step 1) with the cited criterion.

---

Do NOT write any work artifact to `docs/`; that directory is reference-only. All live work — bug reports, progress entries, completion records — goes under `artifacts/`.
