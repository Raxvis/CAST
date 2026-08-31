---
name: file-bug
description: >-
  File a user-found bug as its own tracked report: instantiate templates/BUG_REPORT.md at
  artifacts/one-off/bugs/bug-{XXX}-{slug}.md and add its row to the artifacts/BUGS.md
  index, without running any pipeline. Use when the user reports a bug they hit, wants a
  defect recorded for later, or invokes /file-bug. Runs in-session and launches no
  agents; the fix happens later via /agent-task, /add-task, or adoption into a milestone
  at /agent-plan Stage 1.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /file-bug intake skill. Reviewer files the bugs found
inside pipeline runs; /file-bug is the route for bugs found by USERS — while using the
product, reading code, or reviewing agent output — so each one gets an individually
tracked report the moment it is noticed, instead of living in chat history.

/file-bug writes the per-bug file and the index row, nothing else. Fixing the bug is a
separate, later step: /agent-task "Fix BUG-XXX" (now), /add-task (queued), or adoption
into a milestone at /agent-plan Stage 1 (which also reviews open user-filed bugs).

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.

INSTALLATION: This skill installs to `.claude/skills/file-bug/SKILL.md` in your target
project (done automatically by /cast-init). Claude Code registers it as the /file-bug
skill. Invoke it with `/file-bug <bug description>`.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /file-bug — File a User-Found Bug

Record a bug the user found in [PROJECT_NAME] as a standalone, individually tracked report: one per-bug file plus one index row. This is the user-report counterpart to Reviewer's in-pipeline filing — same template, same index, same lifecycle — for defects noticed outside a pipeline run.

This skill runs entirely in-session and **launches no agents**. It writes exactly two things: the per-bug file and its `artifacts/BUGS.md` index row. It never fixes anything.

## Input

The argument text the user provided — a free-form description of the bug: what they did, what they expected, what happened instead. May include file paths, error output, or reproduction steps. If no description was provided, ask for one.

## Instructions

### 1. Read the index and check for duplicates

Read the `artifacts/BUGS.md` index (the file also carries the canonical lifecycle, severity scale, and field-ownership rules — follow them, do not improvise). If an existing non-terminal bug describes the same defect, do not file a second one: point the user at the existing ID and offer to append their new evidence to that bug file's Notes instead. If they confirm it is genuinely distinct, file it with the existing ID cited under Related Issues.

### 2. File the bug

1. Assign the next free `BUG-XXX` ID per the ID convention in `artifacts/BUGS.md`.
2. Create `artifacts/one-off/bugs/bug-{XXX}-{slug}.md` from `templates/BUG_REPORT.md` — user-filed bugs live under `one-off/bugs/` because no milestone's work surfaced them. Instances never carry the template's instruction comment block.
3. Fill the **Report** section from the user's description:
   - **Status**: `New`. **Found during**: `user report — /file-bug`.
   - **Severity (initial)**: your judgment from the described impact, per the severity scale in `artifacts/BUGS.md`. Leave **Severity (final)** for Product's triage.
   - **Description / Expected / Actual / Steps to Reproduce**: from what the user said. If Expected, Actual, or the reproduction steps cannot be inferred from the description, ask the user before writing the file — a report nobody can reproduce is a `Cannot Reproduce` waiting to happen.
   - Everything else (**Platform**, **Frequency**, **Evidence**, **Likely Files**, **Regression**, **Related Issues**): fill what the user gave; write the template's honest defaults (`Unknown`, `None available.`, `None.`) for what they did not. **Never guess** — do not invent reproduction steps, likely files, or frequency claims. Naming likely files is fine when the user pointed at them or the description names the failing surface directly; do not go code-spelunking to populate the field.
   - Skip the Investigation and Resolution sections entirely — they belong to Coder, later.
4. Add the index row in `artifacts/BUGS.md` (ID, title, initial severity, Status `New`, file link) and update that file's `Last updated` line.

### 3. Report

Confirm the filing: the ID, title, initial severity, and file path. Then lay out the standing options — the bug is now in the triage stream, and any of these picks it up:

- `/agent-task "Fix BUG-XXX"` — fix it now through the mini pipeline.
- `/add-task Fix BUG-XXX` — queue the fix in the `artifacts/TASKS.md` backlog.
- Nothing — `/agent-plan` Stage 1 reviews open user-filed bugs at the next milestone and pulls in the relevant ones; Product triages it there.

For a `Critical` severity, recommend the first option explicitly rather than leaving it to the queue.

## Scope Boundaries

`/file-bug` writes only the per-bug file and its index row. It does not investigate root causes, modify code, launch agents, queue tasks (that is `/add-task`), or write anything to `docs/`, `templates/`, or a milestone directory. Product remains the triage authority: `/file-bug` sets only the initial severity and the `New` status.
