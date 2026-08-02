---
name: agent-task
description: >-
  Run the CAST mini engineering pipeline (Coder → Tester → Reviewer → Product) for a
  single self-contained task — bug fixes, typos, single-function refactors, dependency
  bumps — with no milestone, planning artifacts, or CEO verdict. Use when the user asks
  for a small one-off change or invokes /agent-task. Bails out for design work: to
  /agent-plan single-task mode when one design decision is implied, full /agent-plan
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
3. Replace [MAX_LOOP_COUNT] with the number of Coder-Tester-Reviewer cycles allowed
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

- [coder](../../agents/coder.md) — implements the task
- [tester](../../agents/tester.md) — writes and runs tests; gates Reviewer behind a green test suite
- [reviewer](../../agents/reviewer.md) — reviews the code and classifies findings as Defects or Issues
- [bug-gatherer](../../agents/bug-gatherer.md) — files Defect findings as structured bug reports
- [debugger](../../agents/debugger.md) — investigates triaged defects when Product says fix now
- [refactor](../../agents/refactor.md) — addresses Issue findings and loops back to Reviewer
- [product](../../agents/product.md) — validates the finished task against the original task description
- [docs-writer](../../agents/docs-writer.md) — drains the `docs` queue from `artifacts/STANDUP.md` at the completion checkpoint

This skill explicitly does NOT invoke [architect](../../agents/architect.md), [ui](../../agents/ui.md), [security](../../agents/security.md), [performance](../../agents/performance.md), or [ceo](../../agents/ceo.md). If the task turns out to need any of those, Pre-Flight or Reviewer will halt and tell you to run `/agent-plan` instead.

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

If in doubt, run `/agent-plan` first — for a single self-contained feature that needs only one or two design decisions, its **single-task mode** (`/agent-plan single: <feature>`; Product + Architecture + CEO, one task file) keeps the planning tax proportional. The planning gate exists because ad-hoc changes that turn out to need design work produce drift that is expensive to untangle later.

## Model Compatibility

Each stage runs on the model set in that agent's file (default: `inherit` — the session model; the Claude Opus family is the optimized target, with `claude-opus-5` preferred and `claude-opus-4-8`, `claude-opus-4-7`, and `claude-opus-4-6` supported — full profiles and upgrade paths in `docs/MODEL_OPTIMIZATION.md`). Orchestration notes by executing model:

- **Opus 5** — this model delegates readily and expands scope; invoke only the agents this pipeline names, keep the task to its stated description (out-of-scope discoveries go in the Handoff Log), and honor the bail-out rule above instead of spawning planning agents ad hoc.
- **Opus 4.8 / 4.7** — these models delegate conservatively; execute the pipeline stages exactly as written rather than folding them into direct work.
- **Opus 4.6** — this model over-delegates; invoke only the agents this pipeline names, and honor the bail-out rule above instead of spawning planning agents ad hoc.
- **Effort** — `high` reasoning effort is sufficient for one-off tasks; use `xhigh` for nontrivial fixes on Opus 4.7+ (Opus 4.6 caps at `high`).

## Input

The argument text the user provided when invoking this skill — a free-form description of the task. May reference a specific file path, a bug ID (e.g., "Fix BUG-002: `done` silently succeeds on missing ID"), or a plain description ("Add a `--json` flag to the `list` command following the pattern in `add.ts`"). If none was provided, ask for one before the Pre-Flight Check.

## Instructions

This skill orchestrates a mini engineering pipeline by executing the canonical engineering loop defined in `docs/PIPELINE_LOOP.md` — the same loop `/agent-code` runs — but skips the planning stage entirely. This file carries only the deltas specific to one-off tasks.

### Pre-Flight Check

Before any work begins:

1. Reads split by reader. The **orchestrator** (this skill's main session) already has `CLAUDE.md` and `docs/CODE_PATTERNS.md` in context via the session's memory imports (root `CLAUDE.md` → Memory Imports) — it must not re-read them; it reads only what Pre-Flight needs beyond that: `docs/FILE_CONVENTIONS.md`, and any topic-specific reference doc (`docs/FRONTEND.md`, `docs/BACKEND.md`, `docs/CLI.md`, `docs/MOBILE.md`) that applies to the project and is not already imported (mobile projects typically need both `docs/FRONTEND.md` and `docs/MOBILE.md`). The **loop's stages** run as subagents with their own context — they do not inherit this session's reads; they receive project memory plus exactly what the task file's Context Manifest cites, which is why the manifest seeded below must list the convention docs the task needs.
2. If the task description references a bug ID, look it up in the `artifacts/BUGS.md` index and read its per-bug file.
3. Read any files named in the task description.
4. **Scope check.** If the task description implies an architectural change, a new module, a new screen, a new endpoint, or a cross-cutting change, **stop and route the user to the right planning tier**. Do not attempt to inline architect or UI work into a one-off task. For a single self-contained feature needing one or two design decisions, point at single-task mode: "This task introduces <specific scope>, which needs a planning pass. Run `/agent-plan single: \"<feature description>\"` — a light run (Product + Architecture + CEO, one task file) — then `/agent-code` to implement." For multi-task or cross-cutting scope, point at the full run: "Run `/agent-plan \"<feature description>\"` first, then `/agent-code`."

### Task File

After Pre-Flight passes, create the one-off task file at `artifacts/one-off/task-{slug}.md` from `templates/TASK.md`: the task description becomes the Description and acceptance criteria; the Context Manifest lists exactly what Pre-Flight identified (the referenced bug file, the files named in the description, the applicable convention docs). Set the Header's Milestone field to "One-off — /agent-task". This file is the handoff medium for the loop below, exactly as in `/agent-code`.

### The Loop

Execute the engineering loop defined in `docs/PIPELINE_LOOP.md` — Coder → Tester → Reviewer (with the Defect and Issue routing) → Product validation — including its Handoff Protocol, loop-counter rules, test-gate rule, and Environment Issue rule. The loop doc is the single canonical statement of that sequence; do not improvise routing.

Deltas specific to this skill:

- **Every stage** receives the one-off task file path; the Context Manifest and Handoff Log carry everything else — there is no milestone, architecture document, or UI spec.
- **Bug Gatherer (Step 3a)** files defect findings as per-bug files under `artifacts/one-off/bugs/bug-{XXX}-{slug}.md`, indexed in `artifacts/BUGS.md`.
- **Reviewer (Step 3)** reviews against project conventions, existing patterns in adjacent code, and any topic-specific doc that applies. If the Reviewer's findings reveal missing design context (e.g., "this change should not exist without a new architecture document" or "this introduces a pattern not used elsewhere"), **stop and instruct the user to run `/agent-plan` to introduce the missing context** — single-task mode (`/agent-plan single: ...`) when the missing context is one design decision, the full run when it is cross-cutting. Do not attempt to retrofit design work into a one-off task.
- **Product validation (Step 4)**: since `/agent-task` does not produce a milestone, the task description itself serves as the acceptance criteria. Product verifies:
  1. The change does what the task description said it would.
  2. No regressions in adjacent features.
  3. The change did not sneak in scope beyond what was asked. If new scope appeared, flag it and either trim or escalate to `/agent-plan`.

### Completion

After the task passes Product validation:

1. Run `[TEST_CMD]` one final time to confirm everything still passes.
2. Set the task file's Status to Complete in its Header.
3. Append an entry to `artifacts/STANDUP.md` using that file's Entry Grammar: a session heading `### YYYY-MM-DD — agent-task — <task summary>` (if this run has not added one yet) and a `- product | progress | <task summary, any bug ID resolved>` line.
4. **Docs Writer.** Invoke the **docs-writer** agent to drain the `docs` entries from `artifacts/STANDUP.md` (entries of the form `- <agent> | docs | <note>` — see that file's Entry Grammar). Docs Writer marks each drained entry with ✅.
5. If the task resolved a filed bug, advance the per-bug file's status per the field-ownership table in `artifacts/BUGS.md` (which is canonical): Coder already set the status to **Fixed** at fix time, filling in the resolution fields (Commit, Files Changed, Regression Notes) — verify this happened and have Coder backfill it if not. Now that Tester has passed and Product has validated, **Product** advances the status **Verified** → **Closed** (mirroring each change into the index row).
6. Summarize what changed, what tests were affected, and any follow-up items or deferred scope.

### Error Handling

- If the task description is ambiguous enough that Coder cannot proceed without a design decision, stop and ask the user to clarify before continuing. Do not guess.
- If the change turns out to touch more modules than initially expected, stop and recommend running `/agent-plan` for a proper milestone scope (single-task mode if it is still one task with a design decision; the full run if it has grown beyond that). Do not attempt to finish a large change inside a one-off task — that defeats the purpose of the planning gate.
- Loop-cap escalation (`[MAX_LOOP_COUNT]`) and Environment Issue handling follow the rules in `docs/PIPELINE_LOOP.md`.

### Scope Boundaries (what this skill will NOT do)

`/agent-task` explicitly does not:
- Produce milestone definitions, milestone task files, architecture documents, UI specs, security reviews, performance reviews, or CEO verdicts. Those are outputs of `/agent-plan`.
- Write files inside any `artifacts/milestone-{N}-{slug}/` directory. Those are owned by `/agent-plan` and `/agent-code` outputs — one-off work stays under `artifacts/one-off/`.
- Write any work artifact to `docs/`. `docs/` is reference-only.

If the work you are doing needs any of the above, run `/agent-plan` first. The planning gate exists for a reason.
