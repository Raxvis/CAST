<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file is the in-directory index for the pipeline skills payload. It is
reference material for readers browsing the template repo — it must NOT be copied to
target projects during adoption. /cast-init installs only the five skill directories
below.

HOW TO CUSTOMIZE: no customization needed. This file is metadata about the directory.
-->

# `skills/` — Pipeline Skill Definitions

Each subdirectory here (except this README) contains one Claude Code skill. The directory name becomes the skill name: `agent-plan/SKILL.md` is the `/agent-plan` skill, `agent-code/SKILL.md` is `/agent-code`, and so on.

## Install destination

When `/cast-init` installs the template into a target project, each skill directory is copied to `.claude/skills/` at the target's project root, with placeholders substituted:

```
skills/agent-plan/SKILL.md    →  <target>/.claude/skills/agent-plan/SKILL.md
skills/agent-code/SKILL.md    →  <target>/.claude/skills/agent-code/SKILL.md
skills/agent-task/SKILL.md    →  <target>/.claude/skills/agent-task/SKILL.md
skills/cast-doctor/SKILL.md   →  <target>/.claude/skills/cast-doctor/SKILL.md
skills/cast-release/SKILL.md  →  <target>/.claude/skills/cast-release/SKILL.md
```

Claude Code auto-discovers any `<name>/SKILL.md` under `.claude/skills/` at session start and registers it as a skill invocable as `/<name>`. The SKILL.md frontmatter `name` field must match its directory name.

**This README file is NOT copied to the target project.** It documents the payload directory, not the installed workflow.

## The skills in this directory

| Directory | Skill | Purpose |
|---|---|---|
| `agent-plan/` | `/agent-plan <feature description>` | Runs the full Planning Stage: Product → Architecture + UI → Risk → CEO. Produces a complete milestone directory (`artifacts/milestone-{N}-{slug}/`): the milestone README, one task file per task (each with a Context Manifest), architecture document, UI spec, reviews, and a CEO verdict. No code is written. **Light mode** (`/agent-plan light: <feature>`, or `single:` for the one-task case) plans a small feature with Product + Architecture + CEO only — same milestone layout, minimal ceremony. It also engages automatically when Stage 1 scoping finds 3 tasks or fewer with no new screen set, no security-sensitive scope, no applicable performance budget, and nothing cross-cutting. |
| `agent-code/` | `/agent-code <milestone or task>` | Runs the Engineering Stage for a CEO-approved milestone: **Coder → Reviewer → validation — a clean task is two spawns.** Coder implements, writes and runs the tests, and commits; Reviewer verifies the verbatim test-results block (the test gate), reviews the diff, classifies findings as Defects (filing each as a bug file, then Product triage) or Issues (back to Coder), and records the per-criterion Acceptance Criteria Check. That check decides validation: all criteria Met closes the task with no agent launch; a flagged criterion, a mid-task amendment, a CEO Approval Condition, or a resolved bug launches Product. Independent tasks (disjoint dependencies and file lists) run their loops in parallel, up to 3 at a time, with shared-state writes serialized by the orchestrator. The task-completion checkpoint launches no agents (Status writeback plus a `docs`-queue overflow drain past 10 pending entries); at milestone completion Product writes the completion, validation, and retrospective records covering every task, Docs Writer runs the primary drain, the UX review runs for UI-flagged milestones, Risk runs the implementation review when flagged, and the orchestrator records outcomes and archives. |
| `cast-release/` | `/cast-release` | Release preparation: verify the gates (milestone closed, tests pass, build succeeds, no blocking bugs, risk flags cleared), derive the semantic version from what actually shipped, update `docs/CHANGELOG.md`, and write a release record with a GO / NO-GO. Runs in-session and launches no agents. This was the `release` agent in v2. Does not tag, push, or publish — that stays the user's command. |
| `agent-task/` | `/agent-task <task description>` | Runs a mini engineering pipeline for a single one-off task without requiring a milestone, planning artifacts, or CEO verdict. Same Defect/Issue routing as `/agent-code` but no planning stage. Bails out if the task turns out to need design work — recommending `/agent-plan` light mode for a small feature with a few design decisions, the full run for cross-cutting scope. |
| `cast-doctor/` | `/cast-doctor` (or `/cast-doctor checkup` for report-only) | The maintenance skill, not a pipeline: a run-anytime health check of the CAST install. Verifies structural and state invariants (bug index, task indexes, STANDUP grammar, bounded logs, resolving references), prescribes model-aware documentation pruning in two tiers gated on the Context Inference Bar in `docs/MODEL_OPTIMIZATION.md`, and finds documentation coverage gaps. Writes `artifacts/DOCTOR.md`; treats only user-approved prescriptions. Run it after model changes or every few milestones. |

## When to use each skill

Short version:

- **New feature or milestone?** → `/agent-plan` then `/agent-code`
- **A small feature with a few design decisions?** → `/agent-plan light: <feature>` then `/agent-code`
- **Bug fix, typo, small refactor, dependency bump?** → `/agent-task`
- **Unsure?** → `/agent-plan` first (light mode keeps the tax small). It is strictly safer to plan and not need it than to skip planning and discover you needed it mid-implementation.
- **Milestone closed and ready to ship?** → `/cast-release`
- **Docs feel heavier than the project needs, models were upgraded, or the install hasn't been checked in a while?** → `/cast-doctor`

Longer version with a decision table: see the repo's `TROUBLESHOOTING.md` → "Which pipeline should I use?"

## Model compatibility

All five skills are optimized for the Claude Opus family (agents default to `model: inherit`, running on the session model; `claude-opus-5` is the preferred executing model, with `claude-opus-4-8`, `claude-opus-4-7`, and `claude-opus-4-6` supported). Each SKILL.md carries a **Model Compatibility** section with orchestration notes for the model executing it — chiefly that Opus 5 delegates readily and expands scope (spawn only the agents each stage names; hold tasks to their Files lists), Opus 4.8/4.7 delegate conservatively (the explicit stage invocations are load-bearing), and Opus 4.6 over-delegates like Opus 5. Behavior profiles and the upgrade checklists through Opus 4.8 → Opus 5 live in `docs/MODEL_OPTIMIZATION.md`.

## How pipeline skills work

A SKILL.md is Markdown with YAML frontmatter (`name`, `description`) that Claude Code discovers at session start. When the user invokes the skill (e.g. `/agent-plan add dark mode`), Claude loads the file body and follows it, treating the text the user typed after the skill name as the invocation input. The rest of the file is instructions to Claude for how to orchestrate the work.

Open any of the SKILL.md files to see the full orchestration: which agents get launched, in what order, with what inputs, and how findings are routed (`cast-doctor` and `cast-release` are the exceptions — both run self-contained in the session, cooperating with the roster through files rather than launching agents). The files are self-documenting and deliberately verbose — they are the contract between the user's intent and the agent pipeline.

## Customization

You can edit any installed SKILL.md freely. Common edits:

- Tighten the pre-flight check to read additional project-specific files.
- Add steps for project-specific gates (e.g., run a linter before Reviewer).
- Remove agents from the pipeline if you have deleted them from `.claude/agents/`.
- Change the `[MAX_LOOP_COUNT]` placeholder in `agent-code/SKILL.md` and `agent-task/SKILL.md` to match your project's tolerance for Coder/Reviewer retry cycles.

If you delete `agent-plan/` or `agent-code/`, you must also delete `agents/ceo.md` — the CEO agent exists to serve those pipelines. See the CAST repo's [`README.md` → Minimum Viable Agent Set](https://github.com/Raxvis/CAST#minimum-viable-agent-set) for the full coupling rules.

---

_See also: `../agents/README.md` for the agent roster and how each pipeline skill invokes its agents. `../docs/FILE_CONVENTIONS.md` for where each pipeline writes its outputs (`artifacts/`, never `docs/`)._
