<!-- TEMPLATE INSTRUCTIONS
  FILE: PIPELINE_LOOP.md
  PURPOSE: The canonical engineering-loop contract, read by the ORCHESTRATING SKILL only
           (/agent-code per milestone task, /agent-task for one-off work). It defines the
           stage sequence, the Defect/Issue routing, the loop counters, and the commit
           discipline. If you change the loop, change it here — not in the skills.

  WHO READS THIS: the orchestrator. Not agents.
           Agents read docs/STAGE_CONTRACT.md, which carries the read set and the handoff
           format and nothing else. That split is deliberate and load-bearing: in v2 every
           agent cited this file, and it had grown to ~5,000 tokens of routing rules that
           no stage acts on — the largest single item in every stage's context. Do not
           re-point agent files at this document.

  HOW TO CUSTOMIZE:
  - [TEST_CMD] and [MAX_LOOP_COUNT] are substituted by /cast-init at install time
    ([MAX_LOOP_COUNT] defaults to 3). If you are editing an installed copy, they are
    already concrete values.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# The Engineering Loop

The per-task engineering sequence executed by `/agent-code` and `/agent-task`. The unit of work is a **task file** (an instance of `templates/TASK.md` — `artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md`, or `artifacts/one-off/task-{slug}.md`). The orchestrating skill selects the task file and runs this loop until the task passes validation (Step 3) or the loop cap escalates.

**Two stages, not four.**

```
Coder (implement + test + commit)  →  Reviewer (review + classify + criteria check)  →  validation
        ▲                                    │
        └──────── Defect or Issue ───────────┘
```

Testing belongs to the stage that wrote the code; the gate is enforced by verbatim evidence (below). The independent check — a different agent reading the diff against the criteria — is Reviewer.

---

## Commit discipline

Git is part of the loop's contract: every task leaves a commit trail keyed to its task ID, so bug reports can cite a real hash, Reviewer has a diff surface, and a bad task can be reverted independently.

1. **Coder commits its own work** at the end of every pass — that task's production code and test files only, nothing else. The message starts with the task ID: `M{N}-T{TT}: <summary>` (one-off tasks use their slug). This is safe under parallel execution because eligible tasks have disjoint Files lists.
2. **Loop-back passes stack, never amend.** A fix or refactor pass adds a new commit on top. Never amend or rebase mid-loop — the stacked history is the audit trail the Handoff Log points into.
3. **The handoff entry names the commit** (the `Commit` field in `templates/TASK.md`). This is how Reviewer finds the code without re-reading whole files.
4. **Reviewer reviews the diff, not the tree** — the commits recorded in the Handoff Log since the last Reviewer approval (on the first review, all of the task's commits), via `git show`/`git diff`, plus surrounding context only where the diff demands it.
5. **Bug fixes cite the fix commit.** When a Fix Now defect is fixed, Coder fills the bug file's Resolution → Commit field with the hash of the stacking fix commit.
6. **Validation closes the range.** Rolling back a bad task later means reverting the commits prefixed with its ID — no other task is touched.

## Test gate rule

Tests must pass before Reviewer runs. No exceptions. Because Coder now owns testing, the gate is enforced by **evidence, not by a separate agent**:

- Coder's handoff entry carries a **Test Results** block with the **verbatim tail of the `[TEST_CMD]` run** — the actual pass/fail counts as printed, not a paraphrase. "All tests pass" without output is an incomplete entry and Reviewer rejects it back to Coder without reviewing.
- **Full suite vs. targeted.** The first pass of a task and the final pass before validation run the full `[TEST_CMD]` suite. Intermediate loop-back passes may run the targeted set for the affected modules — k loop iterations must not cost k full-suite runs.
- **Defect cycles — prove the test red.** A pass that fixes a Fix Now defect must record red→green evidence against the pre-fix commit in its handoff entry (procedure in `agents/coder.md`); Reviewer checks for it.

## Environment Issue rule

If tests fail due to environment rather than code — broken runner or toolchain, missing or misconfigured dependencies, CI outage, resource exhaustion, network or credential problems — Coder flags the failure as **Environment Issue** in its handoff entry instead of looping on the code. The orchestrator pauses the task and escalates the infrastructure problem to the user; other tasks are not blocked.

## Task-amendment rule

When a stage discovers mid-task that the task's scope is wrong — the Files list is incomplete, an acceptance criterion is unachievable as written, the task is really two tasks — it neither silently expands scope (a file-overlap hazard under parallel execution) nor escalates to a full re-plan:

1. The discovering stage pauses and appends a handoff entry (`<stage> -> product`) whose Outcome states the proposed amendment and why.
2. The orchestrator routes to **Product**, who owns scope, and who disposes of the proposal in one of three ways, appending its own handoff entry: **approve** (update the task file's Files list and/or acceptance criteria in place), **split** (create a new task file plus its Task Index row in the milestone README; the current task keeps its reduced scope), or **reject** (the task proceeds as written, with the reason in the entry).
3. The loop resumes at the paused stage from Product's entry. Amendments do not increment the loop counter.

The `/agent-plan` escalation remains for genuinely architectural discoveries — a new module, a schema change, cross-cutting design work. The amendment path is for scope corrections *within* the task's design envelope.

## Loop counter rules

One full cycle is any return to Step 1 (Coder).

- Track the count in the task file's Header (`Loop count`) — the single live counter; an interrupted run resumes from it — and **escalate to the user after `[MAX_LOOP_COUNT]` cycles** on a single task, stating the specific blocker.
- If Coder reports that a finding cannot be resolved without an architecture change (structural disagreement), the escalation must carry that flag and name Architecture as the needed re-entry point (`/agent-plan`).

---

## Step 1 — Coder

Launch the **coder** agent with the task file path. One pass implements, tests, and commits, ending in a `coder -> reviewer` handoff entry with the **Test Results block** (what a pass does is `agents/coder.md`'s content, not yours).

Routing facts: **on a loop-back**, Coder handles all three return paths — a Reviewer-classified Defect, a Reviewer-classified Issue, and a Product criteria rejection — in one pass. **If Coder cannot make tests pass** after a genuine attempt, it appends the failing entry and you loop it back to Step 1 with the loop counter incremented — the same escalation path as any other cycle.

## Step 2 — Reviewer

After Coder hands off, the orchestrator first applies the **test-gate pre-check**: read the latest Coder entry and confirm it carries a Test Results block with verbatim output showing no failures. This is a presence check, never judgment on the tests. Absent or failing: route straight back to Coder without launching Reviewer (a full Reviewer context spent rejecting a missing block is a wasted spawn); this does not increment the loop counter — no work was reviewed.

When the block is present, launch the **reviewer** agent with the task file path. Reviewer enforces the same gate as backstop, reviews the diff, files every Defect as a bug file, and hands back an entry you route on: every finding classified **Defect** (incorrect behaviour, broken functionality, violated contract) or **Issue** (structural problem, convention violation, maintainability concern), and — on approving a clean version — the **Acceptance Criteria Check**, one line per criterion (`Met` with evidence / `Not met` / `Product judgment`; details in `agents/reviewer.md`).

### Step 2a — Defect routing

**Determined dispositions skip triage.** A Defect whose bug file cites a violated acceptance criterion has no triage question — Defer is forbidden for it by the rule below — so the orchestrator routes it straight back to Coder as **Fix Now** without a Product launch, noting `auto-routed: violates criterion <n>`. Product still reviews every bug at the milestone close, so nothing escapes oversight.

For every other Defect, the orchestrator hands the filed bug to the **product** agent for triage. Product sets final severity and issues one of three outcomes:

- **Fix Now** — the task returns to Coder (Step 1). Coder's read set gains the bug file via "Read next".
- **Defer** — the bug file stays **open** with status Deferred. Deferred is a held-open state, not terminal: Product re-triages every Deferred bug at the `/agent-code` milestone-completion checkpoint and at `/agent-plan` Stage 1. Deferral is allowed only if the defect does not violate the task's acceptance criteria; the task proceeds without looping.
- **Not a Bug** — status Won't Fix (terminal) with a rationale in the bug file's Notes; the task proceeds without looping.

Only **Fix Now** sends the task back through the loop.

**Batch the triage.** When a review produces several Defects, hand Product all of them in one invocation — one triage pass over N findings, not N passes.

### Step 2b — Issue routing

Findings Reviewer classified as **Issues** return to **Coder** (Step 1) for behavior-preserving restructuring, together in one pass with any Fix Now defects from the same review. Coder cites the convention or architectural principle that justifies each change, re-runs the affected tests, and hands back to Reviewer.

A task does not advance to Step 3 until Reviewer has approved a clean version — **no open Fix Now defects and no unresolved Issues**. Open Deferred and Won't Fix reports do not count against a clean version.

## Step 3 — Validation

Every task's acceptance criteria are checked, criterion by criterion, before it closes. **Who** performs the check depends on Reviewer's Acceptance Criteria Check.

**Step 3a — Clean close (no agent launch).** When Reviewer marks **every** criterion — and, for a condition-bearing task, every CEO Approval Condition line — `Met` with an evidence pointer, the orchestrator closes the task itself: set the task file's Status to Complete and append a `progress` entry to `artifacts/STANDUP.md` citing Reviewer's entry number. Reviewer's entry is the validation record. If the task resolved a filed bug, the orchestrator also flips that bug's status `Verified` → `Closed` (mirroring the index row) per the field-ownership table in `artifacts/BUGS.md` — a transcription of recorded facts, not a judgment.

**Step 3b — Product validation (agent launch).** Launch the **product** agent whenever any of these hold:

- Reviewer's check reports any criterion — or any CEO Approval Condition line — `Not met` or `Product judgment`;
- a criterion was added or amended mid-task (Task-amendment rule).

(A CEO Approval Condition no longer forces a per-task spawn by itself: Reviewer's check carries one line per condition the task's manifest cites, an evidenced line closes at 3a, and Product remains the verifier of record for every condition at the milestone close.)

Product validates against the task file's criteria and disposes of every flagged criterion. If any criterion is unmet, it appends the handoff entry citing the failure and the task returns to Coder.

**Product retains milestone-grain oversight either way.** At the `/agent-code` milestone-completion checkpoint the close record's Per-Task Validation table (`templates/MILESTONE_CLOSE.md`) covers every task in the milestone — including 3a closures — so no task escapes Product review. A 3a-closed task whose criteria Product later judges unmet re-enters the loop like any Fix Now finding.

---

Do NOT write any work artifact to `docs/`; that directory is reference-only. All live work — task files, bug files, progress entries, close records — goes under `artifacts/`.
