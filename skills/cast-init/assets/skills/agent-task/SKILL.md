---
name: agent-task
description: >-
  Run the CAST mini engineering pipeline (Coder → Reviewer → validation, with Product
  spawned only when Reviewer's acceptance-criteria check calls for it, and a micro path
  where the orchestrator itself reviews diffs containing no executable statement) for a
  single self-contained task — bug fixes, typos, single-function refactors, dependency
  bumps — with no milestone, planning artifacts, or CEO verdict. Use when the user asks
  for a small one-off change or invokes /agent-task. Bails out for design work: to
  /agent-plan light mode when a few design decisions are implied, full /agent-plan
  for cross-cutting work.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /agent-task pipeline skill. It runs a mini engineering
pipeline for a single one-off task without requiring a milestone, planning artifacts,
or CEO verdict.

/agent-task is for small, self-contained work: bug fixes, typos, adding a log line,
refactoring one function, updating dependencies. It is NOT for new features, new
modules, new data schemas, or cross-cutting changes — those belong in /agent-plan
followed by /agent-code.

All work artifacts (the one-off task file, bug files, progress log entries) are written
to `artifacts/` — one-off work lives under `artifacts/one-off/`.
Templates are read from `templates/`; guidelines are read from `docs/`. Never mix
them: `docs/` and `templates/` are reference-only, `artifacts/` is where live work
lives.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.
2. Replace [TEST_CMD] with your project's test command.
3. Replace [MAX_LOOP_COUNT] with the number of Coder-Reviewer cycles allowed
   before escalation (default: 3).

INSTALLATION: This skill installs to `.claude/skills/agent-task/SKILL.md` in your target
project (done automatically by /cast-init). Claude Code registers it as the /agent-task
skill. Invoke it with `/agent-task <task description>`.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /agent-task — One-Off Task Pipeline

Run a mini engineering pipeline for a single, self-contained task. Unlike `/agent-code`, this skill does not require a milestone, planning artifacts, or a CEO verdict. It is designed for small, focused work that does not justify a full planning stage.

## Related agent files

This skill invokes the following agents. Open any of them for the full role definition and interaction rules:

- [coder](../../agents/coder.md) — implements the task, writes and runs its tests, commits; handles every loop-back
- [reviewer](../../agents/reviewer.md) — verifies the test-results gate, reviews the diff, classifies findings as Defects (filing each as a bug file) or Issues, and on approval records the per-criterion Acceptance Criteria Check that decides whether Step 3 needs Product
- [product](../../agents/product.md) — triages filed defects, and validates the finished task against the original task description when Reviewer's criteria check or scope creep calls for it (Step 3b)
- [docs-writer](../../agents/docs-writer.md) — drains the `docs` queue from `artifacts/STANDUP.md` at the completion checkpoint

This skill explicitly does NOT invoke [architect](../../agents/architect.md), [ui](../../agents/ui.md), or [ceo](../../agents/ceo.md). If the task turns out to need any of those, Pre-Flight or Reviewer will halt and tell you to run `/agent-plan` instead.

## When to use this skill

**Good fits:**
- Fixing a bug already filed in the `artifacts/BUGS.md` index
- Fixing a typo or small correctness issue
- Adding a log line, metric, or debug output
- Refactoring a single function without changing its contract
- Updating a dependency and its usages
- Adding a flag or option that follows an existing pattern
- Adding or updating tests for existing code
- Small documentation corrections in `docs/` or `CLAUDE.md`

**Not a fit — use `/agent-plan` followed by `/agent-code` instead:**
- Introducing a new module or file set
- Adding a new data schema or changing an existing one
- Adding a new screen, endpoint, or CLI subcommand
- Any change that crosses more than two modules
- Any change that introduces new architectural decisions
- Any change that introduces a new dependency
- Any change that needs cross-cutting UI/UX review

If in doubt, run `/agent-plan` first — for a small feature that needs a few design decisions, its **light mode** (`/agent-plan light: <feature>`; Product + Architecture + CEO) keeps the planning tax proportional — and it engages automatically when Stage 1 scopes the work to 3 tasks or fewer with no new screens, no security surface, no applicable performance budget, and nothing cross-cutting. The planning gate exists because ad-hoc changes that turn out to need design work produce drift that is expensive to untangle later.

## Model Compatibility

Each stage runs on the model set in that agent's file (default: `inherit` — the session model). Invoke only the agents this pipeline names, exactly as written: keep the task to its stated description (out-of-scope discoveries go in the Handoff Log), honor the bail-out rule above instead of spawning planning agents ad hoc, and never fold a stage into direct work. Effort is per agent file (Coder `medium`, Reviewer `high`) and fixed at that pin — an invocation cannot raise it. When a fix's mechanism is not obvious, say so in the Coder invocation instead of reaching for more effort; a project whose one-off work is routinely subtle can permanently re-pin `agents/coder.md`, though `xhigh` is rarely warranted here. Per-model profiles: `docs/MODEL_OPTIMIZATION.md`.

## Input

The argument text the user provided when invoking this skill — a free-form description of the task. May reference a specific file path, a bug ID (e.g., "Fix BUG-002: `done` silently succeeds on missing ID"), or a plain description ("Add a `--json` flag to the `list` command following the pattern in `add.ts`"). If none was provided, ask for one before the Pre-Flight Check.

## Instructions

This skill orchestrates a mini engineering pipeline by executing the canonical engineering loop defined in `docs/PIPELINE_LOOP.md` — the same loop `/agent-code` runs — but skips the planning stage entirely. This file carries only the deltas specific to one-off tasks.

### Pre-Flight Check

Before any work begins:

1. Read only what Pre-Flight needs beyond what the session already has in context (root `CLAUDE.md` and its Memory Imports — do not re-read those): `docs/FILE_CONVENTIONS.md`, plus any applicable topic doc (`docs/FRONTEND.md` / `BACKEND.md` / `CLI.md` / `MOBILE.md`) not already imported. Stages run cold and see only what the task file's Context Manifest cites — so seed the manifest below with every convention doc the task needs; it is a stage's only route to one (rationale: `docs/DESIGN_RATIONALE.md` → "Memory Imports ship empty").
2. If the task description references a bug ID, look it up in the `artifacts/BUGS.md` index and read its per-bug file.
3. Read any files named in the task description.
4. **Scope check.** If the task description implies an architectural change, a new module, a new screen, a new endpoint, or a cross-cutting change, **stop and route the user to the right planning tier**. Do not attempt to inline architect or UI work into a one-off task. For a small feature needing a few design decisions, point at light mode: "This task introduces <specific scope>, which needs a planning pass. Run `/agent-plan light: \"<feature description>\"` — a light run (Product + Architecture + CEO) — then `/agent-code` to implement." For multi-task or cross-cutting scope, point at the full run: "Run `/agent-plan \"<feature description>\"` first, then `/agent-code`."

### Task File

After Pre-Flight passes, create the one-off task file at `artifacts/one-off/task-{slug}.md` from `templates/TASK.md`: the task description becomes the Description and acceptance criteria; the Context Manifest lists exactly what Pre-Flight identified (the referenced bug file, the files named in the description, the applicable convention docs). Set the Header's Milestone field to "One-off — /agent-task". This file is the handoff medium for the loop below, exactly as in `/agent-code`.

### The Loop

Execute the engineering loop defined in `docs/PIPELINE_LOOP.md` — Coder → Reviewer (with the Defect and Issue routing) → validation — including its commit discipline, loop-counter rules, test-gate rule, and Environment Issue rule. That doc is yours, not a stage's; stages read `docs/STAGE_CONTRACT.md`. The loop doc is the single canonical statement of that sequence; do not improvise routing.

Deltas specific to this skill:

- **Every stage** receives the one-off task file path; the Context Manifest and Handoff Log carry everything else — there is no milestone, architecture document, or UI spec.
- **Micro path — no-logic diffs skip the Reviewer spawn.** After Coder's handoff passes the test-gate pre-check, if the diff touches **no executable statement** — documentation, comments, string typos, whitespace or formatting only; anything compiled or interpreted disqualifies — you (the orchestrator) review the diff yourself instead of launching Reviewer: verify it does exactly what the description says and follows the conventions the manifest cites, then append the handoff entry with the Acceptance Criteria Check and close via Step 3a. Independence holds — Coder, a spawn, wrote the diff; you did not. **Any doubt about whether the diff has logic means the normal Reviewer spawn.** Code never bypasses Reviewer; this path exists only for diffs with no code in them.
- **Reviewer files defect findings** as per-bug files under `artifacts/one-off/bugs/bug-{XXX}-{slug}.md`, indexed in `artifacts/BUGS.md`.
- **Reviewer (Step 2)** reviews against project conventions, existing patterns in adjacent code, and any topic-specific doc that applies. If the Reviewer's findings reveal missing design context (e.g., "this change should not exist without a new architecture document" or "this introduces a pattern not used elsewhere"), **stop and instruct the user to run `/agent-plan` to introduce the missing context** — light mode (`/agent-plan light: ...`) when the missing context is a few design decisions, the full run when it is cross-cutting. Do not attempt to retrofit design work into a one-off task.
- **Reviewer (Step 2)** appends the **Acceptance Criteria Check** to its approval entry, one line per criterion in the one-off task file. Because `/agent-task` derives its criteria from a free-form task description, Reviewer marks a criterion `Product judgment` whenever the description's intent is open to reading — a one-off task's criteria are less precise than a planned task's, so lean toward Product judgment here rather than assuming.
- **Validation (Step 3)**: since `/agent-task` does not produce a milestone, the task description itself serves as the acceptance criteria. A task whose criteria Reviewer marked all `Met` closes via Step 3a — the orchestrator writes the Status and the `progress` entry directly. Otherwise launch **product** (Step 3b) to verify:
  1. The change does what the task description said it would.
  2. No regressions in adjacent features.
  3. The change did not sneak in scope beyond what was asked. If new scope appeared, flag it and either trim or escalate to `/agent-plan`.

  **Scope creep always needs Product.** Point 3 is not something Reviewer's criteria check covers — if Reviewer's entry reports files touched beyond the task file's Files list, or any finding it classified as out-of-scope, route to Step 3b regardless of how the criteria were marked. (A resolved filed bug no longer forces a Product spawn: the orchestrator flips its status `Verified` → `Closed` at Completion step 5, per the field-ownership table in `artifacts/BUGS.md`.)

### Completion

After the task passes validation (Step 3a or 3b):

1. If any commit landed after Coder's last full-suite run, run `[TEST_CMD]` once more to confirm everything still passes; otherwise skip it — the test-gate rule already required Coder's final pass to run the full suite, no stage after Coder modifies code, and the verbatim block in the Handoff Log is the record.
2. Set the task file's Status to Complete in its Header.
3. Append an entry to `artifacts/STANDUP.md` using that file's Entry Grammar: a session heading `### YYYY-MM-DD — agent-task — <task summary>` (if this run has not added one yet) and a `- <product|reviewer> | progress | <task summary, any bug ID resolved>` line — attributed to whichever stage closed the task.
4. **Docs Writer (conditional).** Count the pending `docs` entries in `artifacts/STANDUP.md` (lines of the form `- <agent> | docs | <note>` without ✅ — see that file's Entry Grammar). If **one or more** are pending, invoke the **docs-writer** agent to drain them all (it marks each with ✅) — a one-off run has exactly one task, so this checkpoint is its only drain opportunity. If the queue is empty — the common case for a one-off task — launch nothing.
5. If the task resolved a filed bug, advance the per-bug file's status per the field-ownership table in `artifacts/BUGS.md` (which is canonical): Coder already set the status to **Fixed** at fix time, filling in the resolution fields (Commit, Files Changed, Regression Notes) — verify this happened and have Coder backfill it if not. Now that the suite is green and the task passed validation, **you (the orchestrator)** flip the status **Verified** → **Closed**, mirroring each change into the index row — a transcription of recorded facts, no agent launch.
6. Summarize what changed, what tests were affected, and any follow-up items or deferred scope.

### Error Handling

- If the task description is ambiguous enough that Coder cannot proceed without a design decision, stop and ask the user to clarify before continuing. Do not guess.
- If the change turns out to touch more modules than initially expected, stop and re-apply the Pre-Flight scope check (step 4) — route to the right planning tier rather than finishing a large change inside a one-off task.
- Loop-cap escalation (`[MAX_LOOP_COUNT]`) follows `docs/PIPELINE_LOOP.md`. On an Environment Issue, this skill escalates to the user directly and the user decides whether to continue.

### Scope Boundaries

`/agent-task` produces no planning artifacts (milestone definitions, architecture documents, UI specs, risk reviews, CEO verdicts — those are `/agent-plan`'s), writes nothing inside any `artifacts/milestone-{N}-{slug}/` directory (one-off work stays under `artifacts/one-off/`), and writes no work artifact to `docs/`. If the work needs any of those, the Pre-Flight scope check routes to `/agent-plan`.
