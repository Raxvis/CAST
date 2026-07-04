<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file is the in-directory index for the pipeline skills payload. It is
reference material for readers browsing the template repo — it must NOT be copied to
target projects during adoption. /cast-init installs only the three skill directories
below.

HOW TO CUSTOMIZE: no customization needed. This file is metadata about the directory.
-->

# `skills/` — Pipeline Skill Definitions

Each subdirectory here (except this README) contains one Claude Code skill. The directory name becomes the skill name: `agent-plan/SKILL.md` is the `/agent-plan` skill, `agent-code/SKILL.md` is `/agent-code`, and so on.

## Install destination

When `/cast-init` installs the template into a target project, each skill directory is copied to `.claude/skills/` at the target's project root, with placeholders substituted:

```
skills/agent-plan/SKILL.md  →  <target>/.claude/skills/agent-plan/SKILL.md
skills/agent-code/SKILL.md  →  <target>/.claude/skills/agent-code/SKILL.md
skills/agent-task/SKILL.md  →  <target>/.claude/skills/agent-task/SKILL.md
```

Claude Code auto-discovers any `<name>/SKILL.md` under `.claude/skills/` at session start and registers it as a skill invocable as `/<name>`. The SKILL.md frontmatter `name` field must match its directory name.

**This README file is NOT copied to the target project.** It documents the payload directory, not the installed workflow.

## The three pipeline skills in this directory

| Directory | Skill | Purpose |
|---|---|---|
| `agent-plan/` | `/agent-plan <feature description>` | Runs the full Planning Stage: Product → Architecture + UI → Security + Performance → CEO. Produces milestone plans, architecture documents, UI specs, reviews, and a CEO verdict in `artifacts/`. No code is written. |
| `agent-code/` | `/agent-code <milestone or task>` | Runs the Engineering Stage for a CEO-approved milestone: Coder → Tester → Reviewer → Product validation. Defect findings route through Bug Gatherer → Product triage → Debugger investigation. Issue findings route through Refactor → Reviewer loop. |
| `agent-task/` | `/agent-task <task description>` | Runs a mini engineering pipeline for a single one-off task without requiring a milestone, planning artifacts, or CEO verdict. Same Defect/Issue routing as `/agent-code` but no planning stage. Bails out and recommends `/agent-plan` if the task turns out to need architectural work. |

## When to use each skill

Short version:

- **New feature or milestone?** → `/agent-plan` then `/agent-code`
- **Bug fix, typo, small refactor, dependency bump?** → `/agent-task`
- **Unsure?** → `/agent-plan` first. It is strictly safer to plan and not need it than to skip planning and discover you needed it mid-implementation.

Longer version with a decision table: see the repo's `TROUBLESHOOTING.md` → "Which pipeline should I use?"

## Model compatibility

All three skills are optimized for the Claude Opus 4.x family (`claude-opus-4-8` default; `claude-opus-4-7` and `claude-opus-4-6` supported). Each SKILL.md carries a **Model Compatibility** section with orchestration notes for the model executing it — chiefly that Opus 4.8/4.7 delegate conservatively (the explicit stage invocations are load-bearing) while Opus 4.6 over-delegates (spawn only the agents each stage names). Behavior profiles and the 4.6 → 4.7 → 4.8 upgrade checklists live in `docs/MODEL_OPTIMIZATION.md`.

## How pipeline skills work

A SKILL.md is Markdown with YAML frontmatter (`name`, `description`) that Claude Code discovers at session start. When the user invokes the skill (e.g. `/agent-plan add dark mode`), Claude loads the file body and follows it, treating the text the user typed after the skill name as the invocation input. The rest of the file is instructions to Claude for how to orchestrate the work.

Open any of the three SKILL.md files to see the full orchestration: which agents get launched, in what order, with what inputs, and how findings are routed. The files are self-documenting and deliberately verbose — they are the contract between the user's intent and the agent pipeline.

## Customization

You can edit any installed SKILL.md freely. Common edits:

- Tighten the pre-flight check to read additional project-specific files.
- Add steps for project-specific gates (e.g., run a linter before Reviewer).
- Remove agents from the pipeline if you have deleted them from `.claude/agents/`.
- Change the `[MAX_LOOP_COUNT]` placeholder in `agent-code/SKILL.md` and `agent-task/SKILL.md` to match your project's tolerance for Coder/Tester/Reviewer retry cycles.

If you delete `agent-plan/` or `agent-code/`, you must also delete `agents/ceo.md` — the CEO agent exists to serve those pipelines. See the CAST repo's [`README.md` → Minimum Viable Agent Set](https://github.com/Raxvis/CAST#minimum-viable-agent-set) for the full coupling rules.

---

_See also: `../agents/README.md` for the agent roster and how each pipeline skill invokes its agents. `../docs/FILE_CONVENTIONS.md` for where each pipeline writes its outputs (`artifacts/`, never `docs/`)._
