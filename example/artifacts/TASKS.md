# Acme Todo — One-Off Task Backlog

Small, self-contained work — bug fixes, typos, single-function refactors, dependency bumps — queued by `/add-task` for later execution. Each entry is a queue entry, not a task file: when work starts, `/agent-task` creates the real task file at `artifacts/one-off/task-{slug}.md` from `.claude/cast/templates/TASK.md` and this index tracks where the entry went. Drain the queue with `/agent-task backlog` (all open entries) or `/agent-task TASK-XXX` (one entry); `/agent-plan` Stage 1 reviews open entries and adopts the ones relevant to the milestone it is planning.

---

## Backlog Lifecycle

**ID convention**: `TASK-XXX` — sequential across the whole project, zero-padded, never reused (e.g., `TASK-001`, `TASK-042`). The next free ID is one greater than the highest ID in the index below.

**Status flow**: `Open → In Progress → Done`

**Terminal states**: `Done` / `Adopted → M{N}` / `Dropped` — once set, the entry never advances again. `Adopted → M{N}` means `/agent-plan` Stage 1 pulled the entry into milestone {N}'s scope (the milestone task file supersedes the entry); `Dropped` always carries a rationale in the entry's Notes.

**Scope rule**: entries must fit `/agent-task`'s scope — self-contained changes with no design decisions. `/add-task` screens for this at filing and `/agent-task` Pre-Flight re-checks at run time; an entry that turns out to need planning is marked `Open — needs planning` in its Notes and routed to `/agent-plan` rather than forced through the mini pipeline.

**Field ownership** — who writes what, and when. This table is **canonical**: the skills cite it rather than restating status ownership.

| Owner | Writes | Status set |
|---|---|---|
| **`/add-task`** | Creates the index row and entry block: ID, Title, Filed date, Description, any file paths or bug IDs the user named | `Open` |
| **`/agent-task` (orchestrator)** | Flips the entry when its run starts, and again when the task passes validation — filling the Resolution column with the task file path (`one-off/task-{slug}.md`) | `In Progress` → `Done` |
| **Product (`/agent-plan` Stage 1)** | Reviews every Open entry while defining a milestone: adopts the relevant ones into milestone scope (Resolution column names the milestone task, e.g. `M2-T03`), leaves the rest Open | `Adopted → M{N}` |
| **User / Product** | Drops an entry that is no longer wanted, with a rationale in its Notes | `Dropped` |

---

## Index

| ID | Title | Filed | Status | Resolution |
|---|---|---|---|---|
| _No tasks queued yet._ | | | | |

---

## Entries

_One block per queued task, newest last. `/agent-task` reads the entry block as the task description._

<!-- Entry format:

### TASK-XXX — <short title>

- **Filed**: YYYY-MM-DD
- **Description**: <what to change and where — enough for /agent-task Pre-Flight to
  begin without clarification; name specific files, bug IDs, or existing patterns>
- **Related**: <bug IDs, file paths, or "None">
- **Notes**: <optional — scope flags, drop rationale, anything triage should know>
-->

---

_Last updated: 2026-04-08_
