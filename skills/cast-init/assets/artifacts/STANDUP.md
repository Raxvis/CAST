<!-- TEMPLATE INSTRUCTIONS
  FILE: STANDUP.md
  PURPOSE: Rolling session/progress log. Every pipeline skill (/agent-plan, /agent-code,
           /agent-task) appends entries here using the single Entry Grammar defined below.
           The grammar covers session sections, progress notes, the Docs
           Writer queue, decisions, and blockers — there is exactly one format, cited by
           the pipeline skills and docs/PIPELINE_LOOP.md.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Add a new session section at the TOP of the Log section (newest first).
  - Use this log to maintain continuity between sessions and as a lightweight audit trail.
-->

# [PROJECT_NAME] — Session Log

---

## Purpose

This file serves as a lightweight continuity log. Before starting each session, read the most recent session section. During and after each session, append entries using the Entry Grammar below.

To stay lightweight, the log is bounded: at the milestone-completion checkpoint the orchestrating skill moves session sections older than the just-completed milestone to `artifacts/archive/STANDUP.md` (see `/agent-code` → Milestone-completion checkpoint). The live file keeps the current milestone's sessions plus a tail; archived sessions remain greppable in the archive file.

---

## Entry Grammar

This is the **single canonical format** for everything written to this file. All producers — `/agent-plan` stage checkpoints, `/agent-code` and `/agent-task` completion entries, and the Docs Writer queue — use it. (Loop counts live only in each task file's `Loop count` Header — they are not mirrored here.)

**Session sections** are added newest-first at the top of the Log, headed:

```
### YYYY-MM-DD — <skill> — <milestone/task>
```

where `<skill>` is the skill running (`agent-plan`, `agent-code`, `agent-task`, or `cast-doctor`) and `<milestone/task>` identifies the work (e.g., `milestone-2-search-ui`, a one-off task summary, or `install health` for a doctor run).

**Entries** under a session heading are typed one-liners:

```
- <agent> | <type> | <note>
```

`<agent>` is the agent (or orchestrating skill) writing the entry. `<type>` is one of:

| Type | Meaning | Note format |
|---|---|---|
| `progress` | Work completed — a stage finished, a task validated, an artifact written | Free text; name the artifact path where applicable |
| `docs` | Documentation work queued for Docs Writer | Free text naming the doc and the needed change |
| `decision` | A decision worth surfacing beyond the agent's own Decisions Log | Free text |
| `blocker` | A blocker encountered (or resolved) | Free text; name the blocking dependency or agent |

**The Docs Writer queue** is the set of `docs` entries not yet marked as drained. Docs Writer drains it at the `/agent-code` milestone-completion checkpoint (the primary drain), at an **overflow drain** when 10 or more entries are pending at a task-completion checkpoint, and at the `/agent-task` completion checkpoint — every drain runs only when at least one entry is pending, and marks each drained entry by appending ✅ to its line. An entry without ✅ is still pending. The queue is deliberately allowed to span several tasks: each entry carries its own context, so a batched drain reads the same as an immediate one, and the pending count is what `/agent-code` checks against the overflow bound.

Example session section:

```
### 2026-04-09 — agent-code — milestone-2-search-ui

- coder | docs | docs/CODE_PATTERNS.md needs the new debounce pattern documented ✅
- agent-code | progress | M2-T01 closed at Step 3a — all 5 criteria Met, no Product spawn; Status set to Complete
- coder | blocker | Task M2-T02 Environment Issue: fixture server port collision in CI
- docs-writer | progress | Milestone-completion drain: 1 docs entry drained
```

Entries under a session heading are appended in the order they happen (oldest first). In the example: the queued docs entry is written during task M2-T01; the orchestrator closes that task at Step 3a on Reviewer's criteria check, without a Product spawn; Coder hits an environment problem on M2-T02; and the queued `docs` entry drains at milestone completion (marked ✅ — the drained count matches the ✅ entries).

---

## Log

_No sessions recorded yet. Add the first session section using the Entry Grammar above._

---

_Last updated: [YYYY-MM-DD]_
