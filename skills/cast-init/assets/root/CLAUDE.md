<!-- TEMPLATE INSTRUCTIONS
  FILE: CLAUDE.md (the CAST section)
  PURPOSE: v4 does not own your CLAUDE.md — your project context, stack, commands, and
  conventions are yours, living wherever you already keep them (and mapped for the
  pipelines by .claude/cast/SOURCES.md). What CAST needs in CLAUDE.md is exactly one
  section: the one below. /cast-init APPENDS it to an existing CLAUDE.md, or creates a
  minimal CLAUDE.md containing only it when none exists. The "Adopted with CAST" line
  is the canonical version stamp later /cast-init runs read to detect the install.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - [CAST_VERSION] is stamped automatically by /cast-init at install time — leave it.
  - This comment block is stripped automatically by /cast-init at install.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

## CAST Agent Workflow

[PROJECT_NAME] uses the [CAST](https://github.com/Raxvis/CAST) staged agent team: `/agent-plan` plans a milestone (Product → Architecture + UI → CEO verdict), `/agent-code` implements it (Coder → Reviewer → validation), `/agent-task` runs small one-off work, `/file-bug` and `/add-task` capture bugs and backlog entries, and `/cast-doctor` / `/cast-release` maintain the install and prepare releases.

- **CAST brings no documentation — this project's own docs drive it.** `.claude/cast/SOURCES.md` (the **source map**) records where the requirements, standards, architecture docs, testing guidance, documentation home, and registers live. Planning reads those sources and distills what applies into each milestone's own artifacts; engineering reads only the artifacts. Keep the source map current when documentation moves — `/cast-doctor` verifies it.
- **`artifacts/`** holds all live work, grouped by milestone: each `milestone-{N}-{slug}/` directory carries that milestone's README (definition, Standards Digest, CEO conditions), design docs, reviews, per-task files, and per-bug files. Cross-milestone state sits at the root — the bug index (`artifacts/BUGS.md`), the one-off task backlog (`artifacts/TASKS.md`), the session log (`artifacts/STANDUP.md`), and the orchestrator's state tables (`artifacts/AGENT_STATE.md`). One-off `/agent-task` work goes under `artifacts/one-off/`.
- **`.claude/cast/`** is CAST's machinery — the source map, the process contracts (`PIPELINE_LOOP.md`, `STAGE_CONTRACT.md`), and the document templates (`templates/`). Agents copy templates into `artifacts/` as instances; nothing under `.claude/cast/` is edited during work except the source map, by you or `/cast-doctor`.

Adopted with CAST v[CAST_VERSION]
