<!-- TEMPLATE INSTRUCTIONS
  FILE: STANDUP.md
  PURPOSE: Rolling session/progress log. Every pipeline skill (/agent-plan, /agent-code,
           /agent-task) appends entries here using the single Entry Grammar defined below.
           The grammar covers session sections, progress notes, loop counters, the Docs
           Writer queue, decisions, and blockers — there is exactly one format, cited by
           the pipeline skills and docs/PIPELINE_LOOP.md.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - [MAX_LOOP_COUNT] is substituted by /cast-init at install (default: 3).
  - Add a new session section at the TOP of the Log section (newest first).
  - Use this log to maintain continuity between sessions and as a lightweight audit trail.
-->

# [PROJECT_NAME] — Session Log

---

## Purpose

This file serves as a lightweight continuity log. Before starting each session, read the most recent session section. During and after each session, append entries using the Entry Grammar below.

---

## Entry Grammar

This is the **single canonical format** for everything written to this file. All producers — `/agent-plan` stage checkpoints, `/agent-code` and `/agent-task` completion entries, the loop counters from `docs/PIPELINE_LOOP.md`, and the Docs Writer queue — use it.

**Session sections** are added newest-first at the top of the Log, headed:

```
### YYYY-MM-DD — <skill> — <milestone/task>
```

where `<skill>` is the pipeline skill running (`agent-plan`, `agent-code`, or `agent-task`) and `<milestone/task>` identifies the work (e.g., `milestone-2-search-ui` or a one-off task summary).

**Entries** under a session heading are typed one-liners:

```
- <agent> | <type> | <note>
```

`<agent>` is the agent (or orchestrating skill) writing the entry. `<type>` is one of:

| Type | Meaning | Note format |
|---|---|---|
| `progress` | Work completed — a stage finished, a task validated, an artifact written | Free text; name the artifact path where applicable |
| `loop` | Engineering-loop cycle counter (see `docs/PIPELINE_LOOP.md`) | `Task <id>: loop <k>/[MAX_LOOP_COUNT]` |
| `docs` | Documentation work queued for Docs Writer | Free text naming the doc and the needed change |
| `decision` | A decision worth surfacing beyond the agent's own Decisions Log | Free text |
| `blocker` | A blocker encountered (or resolved) | Free text; name the blocking dependency or agent |

**The Docs Writer queue** is the set of `docs` entries not yet marked as drained. Docs Writer drains the queue at task- and milestone-completion checkpoints and marks each drained entry by appending ✅ to its line. An entry without ✅ is still pending.

Example session section:

```
### 2026-04-09 — agent-code — milestone-2-search-ui

- product | progress | M2-T01 validated against acceptance criteria; Status set to Complete
- docs-writer | progress | Drained 2 docs entries
- coder | docs | docs/CODE_PATTERNS.md needs the new debounce pattern documented ✅
- reviewer | loop | Task M2-T01: loop 2/[MAX_LOOP_COUNT]
- tester | blocker | Task M2-T02 blocked: fixture server port collision in CI
```

---

## Log

_No sessions recorded yet. Add the first session section using the Entry Grammar above._

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `BUGS.md` | Active bug tracker — reference when reporting blockers |
| `../templates/MILESTONE_TASKS.md` | Milestone task breakdown template — reference for planned work |
| `milestones/milestone-{N}-{slug}-validation.md` | Milestone acceptance record — reference when validating completed work |

---

_Last updated: [YYYY-MM-DD]_
