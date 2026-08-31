---
name: add-task
description: >-
  Queue a small, self-contained one-off task in the artifacts/TASKS.md backlog without
  running anything — /agent-task later drains the queue (per entry or all open entries in
  backlog mode), and /agent-plan Stage 1 adopts queued entries relevant to the milestone
  it plans. Use when the user wants to record a bug fix, typo, small refactor, or
  dependency bump for later, or invokes /add-task. Runs in-session and launches no
  agents; routes planning-tier work to /agent-plan instead of queueing it.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /add-task intake skill. It queues one-off work in the
artifacts/TASKS.md backlog so small tasks can be captured the moment they come up and
executed later — individually (/agent-task TASK-XXX), in bulk (/agent-task backlog), or
by adoption into a milestone (/agent-plan Stage 1 reviews open entries).

/add-task writes only to artifacts/TASKS.md. It creates no task files — /agent-task
instantiates templates/TASK.md when work on an entry actually starts — and it never
writes to docs/ or templates/.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.

INSTALLATION: This skill installs to `.claude/skills/add-task/SKILL.md` in your target
project (done automatically by /cast-init). Claude Code registers it as the /add-task
skill. Invoke it with `/add-task <task description>`.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /add-task — Queue a One-Off Task

Record a small, self-contained task in the [PROJECT_NAME] one-off backlog (`artifacts/TASKS.md`) without running anything. This is the intake half of the one-off flow: `/add-task` captures the work, `/agent-task` executes it — one entry at a time (`/agent-task TASK-XXX`) or the whole queue (`/agent-task backlog`) — and `/agent-plan` Stage 1 adopts open entries relevant to a milestone it is planning.

This skill runs entirely in-session and **launches no agents**. Its only write is to `artifacts/TASKS.md`.

## Input

The argument text the user provided — a free-form description of the task to queue. May name specific files, an existing pattern to follow, or a bug ID from the `artifacts/BUGS.md` index (e.g., "Fix BUG-003"). Multiple distinct tasks in one invocation are fine — queue each as its own entry. If no description was provided, ask for one.

## Instructions

### 1. Scope screen

`artifacts/TASKS.md` queues only work that fits `/agent-task`'s scope: bug fixes, typos, single-function refactors, dependency bumps, flags following an existing pattern — self-contained changes with no design decisions (the full fit list is in `.claude/skills/agent-task/SKILL.md` → "When to use this skill"). Apply the same boundary here, from the description alone — do not read the codebase to settle it:

- **Clear fit** → queue it (continue below).
- **Clearly planning-tier** (a new module, screen, endpoint, or schema; cross-cutting scope; new architectural decisions) → do **not** queue it. Tell the user: "This implies <specific scope>, which needs a planning pass — run `/agent-plan light: \"<feature>\"` (or the full `/agent-plan` for cross-cutting scope) instead of queueing it here."
- **Borderline** → queue it, but add `Scope is borderline — /agent-task Pre-Flight may route this to /agent-plan` to the entry's Notes. Queueing is cheap; `/agent-task` Pre-Flight re-checks with the codebase in front of it.

### 2. Duplicate check

Read the `artifacts/TASKS.md` index. If an Open entry already describes the same change, do not queue a second one — point the user at the existing entry (and update its Description or Notes if the new invocation adds detail). If the description references a bug ID, confirm the ID exists in the `artifacts/BUGS.md` index and that no Open backlog entry already covers that fix.

### 3. Queue the entry

Per the Backlog Lifecycle and field-ownership table in `artifacts/TASKS.md` (canonical — do not improvise):

1. Assign the next free `TASK-XXX` ID (one greater than the highest in the index, zero-padded, never reused).
2. Add the index row: ID, short title, today's date, Status `Open`, empty Resolution.
3. Append the entry block under **Entries** using the format documented there: Filed date, Description (enough for `/agent-task` Pre-Flight to begin without clarification — carry over every file path, bug ID, and pattern reference the user named), Related, and Notes (including any borderline-scope flag from step 1).
4. Update the file's `Last updated` line.

Keep the Description a compact paragraph. If it will not fit in one — headings, open design questions, multi-module scope — that is the scope screen failing late: go back to step 1's planning-tier outcome.

### 4. Report

Confirm what was queued: the ID(s) and title(s), plus the standing options — `/agent-task TASK-XXX` to run one now, `/agent-task backlog` to drain every open entry, or leave it queued for `/agent-plan` Stage 1 to consider at the next milestone.

## Scope Boundaries

`/add-task` writes only `artifacts/TASKS.md`. It does not create task files, modify code, launch agents, file bugs (that is `/file-bug`), or write anything to `docs/`, `templates/`, or a milestone directory. It records work; it never performs it.
