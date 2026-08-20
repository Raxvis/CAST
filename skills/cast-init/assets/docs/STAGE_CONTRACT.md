<!-- TEMPLATE INSTRUCTIONS
  FILE: STAGE_CONTRACT.md
  PURPOSE: The whole contract a pipeline stage needs, and nothing more. Every agent's
           Model Configuration block cites this file; it is the only process document
           an agent ever reads.

           This file exists because of a measured problem: in CAST v2 every agent
           cited docs/PIPELINE_LOOP.md, which had grown to ~5,000 tokens of routing
           rules, loop counters, and circuit breakers — none of which a stage acts on.
           The document that existed to keep context minimal had become the largest
           single item in every stage's context. v3 splits it: routing lives in
           PIPELINE_LOOP.md and is read by the orchestrating SKILL only; the read set
           and handoff format live here and are read by agents.

           KEEP THIS FILE SHORT. Every line is paid on every stage invocation of every
           task. If you are about to add routing logic, a checklist, or an explanation
           of why a rule exists, it belongs in PIPELINE_LOOP.md or the agent file.

  HOW TO CUSTOMIZE: none needed. This file is process, not project.
-->

# The Stage Contract

You are running as one stage of a pipeline. This is everything you need to know about that.

---

## 1. Your read set is closed

Read exactly these, and nothing else:

1. **The task file** whose path you were given.
2. **Every entry in its Context Manifest.**
3. **Whatever the latest Handoff Log entry lists under "Read next".**

Not the milestone directory. Not sibling task files. Not whole design documents when the manifest cites sections. Not `artifacts/AGENT_STATE.md`. Not this pipeline's other documents.

**If the manifest is insufficient**, that is a planning defect, not a reason to browse: add the missing reference to the Context Manifest so the next stage benefits, note the addition in your handoff entry, and continue.

**Milestone-grain stages** (CEO, and the milestone-completion stages) read what their agent file defines instead — still only within the milestone directory plus the cross-milestone root files.

## 2. Your report is the handoff entry, not your reply

Append **one** entry to the task file's Handoff Log:

```
### N. <from> -> <to> — YYYY-MM-DD

- **Outcome**: [one line — what was done or decided]
- **Files touched**: [paths, or "None"]
- **Commit**: [hash — only if this stage committed; omit the line otherwise]
- **Read next**: [what the next stage needs BEYOND the manifest, or "Manifest only"]
- **Open items**: [blockers, questions, or "None"]
```

**Max 10 lines. No narrative recap.** Anything longer belongs in the artifact the entry points to — a bug file, a review file, the code itself — with only the pointer in the entry.

Two stages exceed the cap, because for them the log *is* the canonical record and dropping content to fit is never acceptable:

- **Reviewer** adds one line per finding, plus the Acceptance Criteria Check block on approval.
- **Coder** adds its test-result block, and one line per failure when tests fail.

## 3. Your reply is one line

Reply to the orchestrator with exactly:

```
Handoff entry #<n> appended — <outcome>; next: <stage>
```

Nothing else. The orchestrator routes on that line and never re-reads your work into its own context. Capped reads going in, one line coming out — this is what keeps the orchestrating context flat across a whole milestone.

## 4. Findings live in their artifact; pointers travel

Test failures and review findings go in the Handoff Log. Bug details go in a per-bug file. Design content goes in the design document. The handoff entry carries the pointer, never a copy.

## 5. Do not spawn subagents

Complete your role's work directly. Your `tools:` list omits the Task tool, so this is enforced, not requested.

## 6. Silence is not a clean report

If your role produces findings — review findings, test results, risk findings — emit the full result block even when it is empty. "No output" and "nothing found" must be distinguishable to the stage that reads your entry.
