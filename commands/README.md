<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file is the in-directory index for the commands/ directory. It is
reference material for readers browsing the template repo — it does NOT get copied
to target projects during install, because Claude Code would otherwise try to
register it as a slash command named /README.

The install scripts (scripts/install.sh and scripts/install.ps1) explicitly
exclude README.md when copying commands/*.md into .claude/commands/.

HOW TO CUSTOMIZE: no customization needed. This file is metadata about the directory.
-->

# `commands/` — Slash Command Definitions

Each `.md` file in this directory (except this README) defines one Claude Code slash command. The filename becomes the command name: `commands/agent-plan.md` is the `/agent-plan` command, `commands/agent-code.md` is `/agent-code`, and so on.

## Install destination

When the template is installed into a target project, files in this directory are copied to `.claude/commands/` at the target's project root:

```
commands/agent-plan.md  →  <target>/.claude/commands/agent-plan.md
commands/agent-code.md  →  <target>/.claude/commands/agent-code.md
commands/agent-task.md  →  <target>/.claude/commands/agent-task.md
```

Claude Code auto-discovers any `.md` file in `.claude/commands/` at session start and registers it as a slash command named after the file (without the `.md` extension). No configuration is required beyond putting the files in the right place.

**This README file is NOT copied to the target project.** The install scripts exclude it explicitly, because a `.claude/commands/README.md` would be registered as a `/README` slash command.

## The three commands in this directory

| File | Slash command | Purpose |
|---|---|---|
| `agent-plan.md` | `/agent-plan <feature description>` | Runs the full Planning Stage: Product → Architecture + UI → Security + Performance → CEO. Produces milestone plans, architecture documents, UI specs, reviews, and a CEO verdict in `artifacts/`. No code is written. |
| `agent-code.md` | `/agent-code <milestone or task>` | Runs the Engineering Stage for a CEO-approved milestone: Coder → Tester → Reviewer → Product validation. Defect findings route through Debugger → Bug Gatherer → Product for triage. Issue findings route through Refactor → Reviewer loop. |
| `agent-task.md` | `/agent-task <task description>` | Runs a mini engineering pipeline for a single one-off task without requiring a milestone, planning artifacts, or CEO verdict. Same Defect/Issue routing as `/agent-code` but no planning stage. Bails out and recommends `/agent-plan` if the task turns out to need architectural work. |

## When to use each command

Short version:

- **New feature or milestone?** → `/agent-plan` then `/agent-code`
- **Bug fix, typo, small refactor, dependency bump?** → `/agent-task`
- **Unsure?** → `/agent-plan` first. It is strictly safer to plan and not need it than to skip planning and discover you needed it mid-implementation.

Longer version with a decision table: see `TROUBLESHOOTING.md` → "Which command should I use?"

## How command files work

A command file is plain Markdown read by Claude Code at session start. The `$ARGUMENTS` token in the file body is replaced with whatever the user typed after the command name. The rest of the file is instructions to Claude for how to orchestrate the work.

Open any of the three command files to see the full orchestration: which agents get launched, in what order, with what inputs, and how findings are routed. The files are self-documenting and deliberately verbose — they are the contract between the user's intent and the agent pipeline.

## Customization

You can edit any command file freely. Common edits:

- Tighten the pre-flight check to read additional project-specific files.
- Add steps for project-specific gates (e.g., run a linter before Reviewer).
- Remove agents from the pipeline if you have deleted them from `.claude/agents/`.
- Change the `[MAX_LOOP_COUNT]` placeholder in `agent-code.md` and `agent-task.md` to match your project's tolerance for Coder/Tester/Reviewer retry cycles.

If you delete `agent-plan.md` or `agent-code.md`, you must also delete `agents/ceo.md` — the CEO agent exists to serve those commands. See `README.md` → Minimum Viable Agent Set for the full coupling rules.

---

_See also: `../agents/README.md` for the agent roster and how each slash command invokes its agents. `../docs/FILE_CONVENTIONS.md` for where each command writes its outputs (`artifacts/`, never `docs/`)._
