# v2.0.0 Process Gap Review

A stress-test of the v2 process as a development methodology — walking through it as the
orchestrator would execute it on a real project. The structural/protocol layer (paths,
handoff mechanics, CI, fixture) holds up; the gaps below are process holes. Recorded here
so they can be worked through item by item; every fix folds into the unreleased 2.0.0.

Priority order: **1–4** change outcomes, **5–9** tighten the loop's honesty, **10** is a
strategic call about the on-ramp, **11–12** are wording fixes.

---

## Tier 1 — The big four

### 1. Git is completely absent from the engineering loop

- [ ] Status: open

The loop never says when to commit. That breaks the system's own contracts:

- `templates/BUG_REPORT.md`'s Resolution section demands a `Commit` hash, but no step ever
  produces a commit.
- Reviewer is supposed to review "the changed code," but without per-task commits there is
  no diff surface — it re-reads whole files (a minimal-context violation).
- A bad task cannot be rolled back independently.

**Proposed fix:** Coder commits when Product validates the task (message keyed to the task
ID, e.g. `M1-T03: <summary>`); loop-back fixes amend or stack on that task's commits;
Reviewer reviews `git diff` since the last validated task. Also makes the example
fixture's `a8f3d12` hash honest.

### 2. Security and Performance never see the implementation

- [ ] Status: open

Both review the *plan* (Stage 3) and then exit the process forever. Vulnerabilities are
overwhelmingly implementation artifacts — the plan said "parameterized queries" but nobody
with a security lens ever reads the code that got written; Reviewer anchors Issues to
CODE_PATTERNS, not a security checklist. Same for performance: budgets are set at planning
and never measured after implementation.

**Proposed fix:** mirror the UX-review pattern (which runs only for UI-flagged milestones):
a security review of the milestone diff for security-flagged milestones (auth, input
handling, new dependencies — flaggable at planning), and a measured performance check
where the plan set budgets. Both at the milestone-completion checkpoint.

### 3. Retrospectives are write-only

- [ ] Status: open

Validator produces a retrospective with metrics and improvement actions, and no process
step ever reads it again. `/agent-plan` Stage 1 re-triages Deferred bugs but does not read
the previous milestone's retrospective — the one mechanism the system has for getting
*better at planning* is disconnected.

**Proposed fix:** Stage 1's read set includes the prior milestone's
`reviews/retrospective.md`, and Product must dispose of each open improvement action —
adopt into this milestone's Cross-Cutting Concerns, or explicitly decline with a reason.

### 4. There is no task-amendment path

- [ ] Status: open

When Coder discovers mid-task that the scope is wrong — the Files list is incomplete, a
criterion is unachievable as written, the task is really two tasks — the process offers
exactly two options: silently expand (scope creep; in parallel mode a file-overlap hazard)
or the nuclear escalation to `/agent-plan`. Real work constantly lands in between.

**Proposed fix:** a defined amendment step. Coder pauses and notes the proposed amendment
in its handoff entry; Product approves/rejects (updating Files/criteria in the task file,
or splitting a new task file plus Task Index row); loop resumes. Product owns scope; this
keeps it that way without a full re-plan.

---

## Tier 2 — Feedback loops that don't close

### 5. Manifest quality has no gate and no metric

- [ ] Status: open

The engineering stage runs on Context Manifests, but the CEO — the gate that exists to
catch planning defects — never reviews them; its six checklist sections predate the
concept. And when an engineering agent patches an insufficient manifest (the defined
fallback), that event is noted in one handoff entry and never aggregated. If four of five
tasks needed patches, planning failed — and nobody finds out.

**Proposed fix:** a manifest line in the CEO checklist (every task's manifest complete and
minimal), plus a retrospective metric row ("manifest patches during engineering: N, from
Handoff Logs").

### 6. No regression-test discipline for bug fixes

- [ ] Status: open

When a Fix Now defect routes back through Coder, Tester "confirms the fix" — but nothing
requires demonstrating the new test *fails without the fix*. A test written after the fix
that passes proves little.

**Proposed fix:** one sentence in the loop's Step 2 for defect cycles: the covering test
must fail against the pre-fix code (trivial once per-task commits exist — checkout, run,
confirm red, re-apply).

### 7. Two writes have no named owner

- [ ] Status: open

1. The example fixture opens every task's Handoff Log with a
   `product -> coder — task released` entry, but no process step produces it — in
   `/agent-code` the *orchestrator* selects tasks. Either the skill says the orchestrator
   appends the release entry (entry #1), or the fixture models a step that doesn't exist.
2. CEO Approval Conditions rows go Open → Addressed → Verified, but no step names who
   flips them to Verified at completion. It is implied to be Product while writing the
   completion record — should be stated.

---

## Tier 3 — Guardrails and friction

### 8. STANDUP and AGENT_STATE grow without bound

- [ ] Status: open

The system solved unbounded context for milestones, then left its two most-read shared
files append-only forever. Twenty milestones in, session-start reads of AGENT_STATE become
exactly the context bomb v2 exists to prevent.

**Proposed fix:** the same fix the system already believes in — at milestone completion,
Validator archives closed STANDUP sessions and stale AGENT_STATE rows to an archive file,
keeping the live files bounded to the current milestone plus a tail.

### 9. No run-level circuit breaker

- [ ] Status: open

The only abort mechanism is the *per-task* loop cap. A pathological milestone — every task
looping, defects spawning defects — burns through unlimited stages with no aggregate
signal.

**Proposed fix:** escalate to the user when more than half the milestone's tasks have
looped, or at a total loop-back count across the milestone (e.g. 2× task count). This is
also the natural place for a cost sanity check.

### 10. The ceremony cliff between /agent-task and /agent-plan

- [ ] Status: open — strategic decision needed

Between `/agent-task` (typo tier) and `/agent-plan` (6 agents, 7+ documents) there is
nothing — a single well-understood feature that needs one architecture decision pays for
full milestone ceremony. That gulf is where users will start bypassing the system, which
is the failure mode for any opinionated process.

**Option to consider:** a sanctioned middle tier — a single-task milestone mode for
`/agent-plan` (Product + Architect + CEO only, one task file; UI/Security/Performance
skipped unless flagged). The opinion stays ("design work gets planned"); the tax drops.

---

## Tier 4 — Mechanics notes

### 11. Parallel execution is written as event-driven, but Claude Code is batch-barriered

- [ ] Status: open

Parallel subagent calls launched in one orchestrator message return together — the
orchestrator cannot literally "launch the next stage as each routing line returns."

**Proposed fix:** phrase the rules as *rounds*: launch a batch of eligible stages (mixed
stages of different tasks is fine), collect all routing lines, launch the next batch. Same
throughput; as written, the orchestrator may get confused trying to be more asynchronous
than the harness allows.

### 12. /agent-task Pre-Flight import note is addressed to the wrong reader

- [ ] Status: open

Pre-Flight still says memory imports are "already in context — do not re-read." True for
the main session, but the loop's stages now run as subagents, and the wording predates
that. Low stakes (subagents get project memory), but the sentence should be reworded for
the orchestrator/subagent split.

---

## Verified clean

Checked for and *not* found in this review: dangling v1 paths, protocol contradictions
beyond item 7, docs/templates/artifacts split violations, CI/fixture drift.
