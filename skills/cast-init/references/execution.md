# Phase 5 — Execution: install mechanics and customization-preservation rules

Read this file before writing any file in Phase 5. Execute the approved plan's actions in the order of the sections below, reporting progress along the way.

## Global rule — strip template scaffolding at install

Every file written into the target project (agents, pipeline skills, docs, artifacts scaffold, root CLAUDE.md) must have its template scaffolding removed before writing:

1. The leading `<!-- TEMPLATE INSTRUCTIONS ... -->` comment block.
2. Any `<!-- Placeholders — see README.md → Placeholder Reference -->` pointer comment (it references the CAST repo's README, which does not exist in the target project).

These blocks are documentation for people browsing the CAST repo; installed files must not carry them. **Exception: the `.claude/cast/templates/` skeletons (every file there except `README.md`) install verbatim, blocks included** — they are reusable skeletons, and their comment blocks instruct the agents that instantiate them (the instantiated copies in `artifacts/` must not carry the blocks, which is what Phase 6 check 6 enforces).

When updating an existing installed file that still carries one of these blocks from a pre-1.0 install, remove it as part of the update — it is CAST-owned scaffolding, not a user customization.

## Global rule — permission-blocked writes fall back to staging

If the session's permission system blocks writes to a target path (most commonly `.claude/agents/` and `.claude/skills/` in non-interactive sessions), do not retry indefinitely, skip the files, or abort the adoption. Instead:

1. Build every blocked file completely — placeholder substitution, scaffolding strip, customization merges — exactly as if writing to the real destination.
2. Write the finished files to a `.cast-stage/` directory at the project root, mirroring the final layout (e.g. `.cast-stage/agents/coder.md` for `.claude/agents/coder.md`, `.cast-stage/skills/agent-plan/SKILL.md` for `.claude/skills/agent-plan/SKILL.md`).
3. Run all Phase 6 validation checks against the staged copies so the user moves verified files, not unverified ones.
4. State prominently in the Phase 7 report — and in the closing summary — that the adoption is staged, list exactly which paths are staged, and give the precise `mv` command(s) that complete the install, ending with the removal of the empty `.cast-stage/` directory.

Files that were written directly (typically `artifacts/` and the root `CLAUDE.md` section) are unaffected — note that `.claude/cast/` is commonly blocked along with agents and skills, so it stages to `.cast-stage/cast/` — stage only what was blocked. Never leave a partially-staged adoption unreported: if `.cast-stage/` exists when the report is written, the report must say so.

## Global rule — progress ledger and rollback

As each planned action is executed (in 5.2 through 5.9), check it off in `artifacts/adoption-plan.md` — mark the action's entry (e.g. prefix with `[x]` or append `— DONE`) immediately after the write lands, not in a batch at the end. The ledger is what makes an interrupted adoption resumable: the 5.1 resume path re-verifies checked actions instead of re-planning from scratch.

**Abort and recovery.** Because the 5.1 preflight guarantees a clean tree, aborting mid-Phase-5 is always recoverable — but note that `git mv`/`git rm` stage their changes to the index, and `git checkout -- <paths>` restores *from* the index, so it cannot undo them. Use instead: `git restore --source=HEAD --staged --worktree <touched paths>` for every tracked path the run touched (including the sources and destinations of any `git mv` and the targets of any `git rm` — this resets both index and worktree to HEAD), then `git clean -fd <touched paths>` to remove files the run created. Keep the three adoption files (`artifacts/adoption-inventory.md`, `adoption-plan.md`, `adoption-report.md`) out of the cleanup — they are exempt from the preflight and hold the ledger a later resume needs. In a non-git project there is no such safety net, which is why the preflight requires explicit confirmation there.

## 5.1 — Preflight

Verify:

1. Git working tree is clean (`git status` returns nothing modified or staged). The adoption's own files — `artifacts/adoption-inventory.md`, `artifacts/adoption-plan.md`, `artifacts/adoption-report.md` (and the `artifacts/` directory Phase 1 created to hold them) — are **always exempt**: Phases 1 and 3 write them before Phase 5 by design, so they never count as dirty. Two further exceptions, both requiring user confirmation before proceeding:
   - **Resuming an interrupted adoption**: if the only dirty files are ones the prior CAST run wrote (cross-check against the ledger checkmarks in the existing `artifacts/adoption-plan.md`), offer to resume — re-verify each already-written file against its planned action instead of demanding a stash. Anything dirty that the plan does not account for still blocks.
   - **Completing a staged adoption**: if `.cast-stage/` exists from a prior permission-blocked run, offer to complete the move per the staging rule below instead of starting over.
   Otherwise, stop and ask the user to commit or stash.
2. **Not a git repository?** If `git rev-parse --is-inside-work-tree` fails, there is no rollback safety net: warn the user explicitly, then either get their explicit confirmation to proceed without one or offer to run `git init` (plus an initial commit) so the recovery path exists. Do not proceed silently. In a non-git project, every `git mv`/`git rm` below becomes plain `mv`/`rm`.
3. `CAST_SOURCE` (resolved in SKILL.md as `<CAST_SKILL_DIR>/assets`) exists and contains `agents/`, `skills/`, `cast/`, `artifacts/`, and `root/`. If missing, stop — the cast-init install is incomplete; ask the user to re-install with `npx skills add Raxvis/CAST` or `/plugin install cast@cast`.

## 5.1a — Fast path for pure-Create actions

Most greenfield adoptions are dominated by **Create** actions with no merge work. Do not read-and-retype those files one at a time. Instead:

1. Copy the payload subtrees mechanically with shell (`cp -R "<CAST_SOURCE>/cast/." .claude/cast/` etc., or per-file `cp` driven by the plan's Create list). This is permitted: the safety rule forbids executing the *target project's* code, not using the shell to copy CAST's own payload files.
2. Run **one substitution pass** over the copied files, replacing every token listed in 5.4.2 with its inventory value (e.g. a scripted find-and-replace per token). The pass must also cover the tokens introduced outside 5.4.2: `[MAX_LOOP_COUNT]` (default 3 — see 5.5.2 and the 5.6 note on `.claude/cast/PIPELINE_LOOP.md`) and the `[YYYY-MM-DD]` "Last updated" tokens in the installed READMEs and `SOURCES.md`, replaced with the install date per 5.6.
3. Run **one scaffolding-strip pass** over the copied files per the global strip rule (skip the `.claude/cast/templates/` skeletons).
4. Spot-check one file per class (an agent, a pipeline skill, a doc) to confirm substitution and strip landed, then rely on Phase 6 validation for full coverage.

The per-file read-merge-write procedure in 5.4–5.8 remains **required** for every Rename+Update and Update-in-place action — customization preservation cannot be done mechanically. Never bulk-copy over an existing file.

## 5.2 — Create directories

Create any missing directories: `.claude/agents/`, `.claude/skills/`, `.claude/cast/`, `.claude/cast/templates/`, `artifacts/`, `artifacts/one-off/`. (Milestone directories are created by `/agent-plan`, never by the installer.)

## 5.3 — Handle directory renames

If the plan includes a rename of `features/` (or similar) → `artifacts/`, execute it with `git mv` so history is preserved. **The destination directory will already exist** — Phase 1 creates `artifacts/` for the inventory — so a directory-level `git mv features/ artifacts/` would fail or nest `features/` inside it. Move the source directory's *contents* instead: per-file `git mv features/<path> artifacts/<path>`, creating subdirectories as needed, then remove the emptied `features/` directory. In a non-git project (per the 5.1 preflight), use plain `mv` instead of `git mv`. Then update every string reference to the old directory across `.claude/` and the project README. Use Grep to find references before renaming.

## 5.4 — Install agent files

Walk the canonical 7-agent list in the order given by the roster table in `roster.md` (rows 1 through 7, top to bottom — that is the install order) and execute the planned action for each. **Do not skip any name on this list.** If the plan has no action for one of these names, that is a bug in the Phase 3 plan — stop and re-enter Phase 3 to add the missing action.

For each agent:

1. Read the CAST agent file from `<CAST_SOURCE>/agents/<name>.md`. **Never install `<CAST_SOURCE>/agents/README.md`** — it is payload documentation, and a `.claude/agents/README.md` would be registered as a bogus subagent.
2. Substitute every placeholder that has a collected inventory value — v4 agents carry only `[PROJECT_NAME]` plus, where a role runs project commands, `[TEST_CMD]`; project context beyond that reaches agents through the source map at planning time, not through baked-in tokens. `[CAST_VERSION]` (the adoption version stamp) substitutes wherever it appears — always with this skill's own `metadata.version` frontmatter value from SKILL.md, never from the inventory and never asked. Domain tokens the user answered in Phase 3 substitute too; unanswered ones stay and go in the report. If the plan's model right-sizing resolution assigned this agent a model, set the frontmatter `model:` line to it (otherwise it stays `inherit`).
3. If the action is **Create**: write to `.claude/agents/<name>.md` directly.
4. If the action is **Rename + Update**: read the existing file first, identify custom sections (anything not in CAST's standard section list), write the CAST template as the base, insert custom sections as an appendix after the standard sections, then move the old file to the new canonical name.
5. If the action is **Update in place**: read the existing file, identify custom sections, replace CAST-owned sections with CAST's current versions, leave custom sections untouched. **Role-mismatch guard**: before merging, compare the existing file's frontmatter `description` (and its evident role) against the roster's Role column for that name. If they diverge — e.g. `.claude/agents/coder.md` exists but is not a coder-role agent — the file is occupying a canonical CAST path without fulfilling the CAST role: never silently update in place. Treat it as an Ask (rename the user's file aside and Create fresh, or merge deliberately), stopping to get the user's answer if the Phase 3 plan did not already resolve it.
6. Verify YAML frontmatter is valid (`name`, `description`, `model`, `tools` keys present, properly quoted description; `tools` omits `Task`).

After completing the loop, **re-enumerate the 7 names and confirm each `.claude/agents/<name>.md` exists**. If any file is missing, that means the action was skipped. Create it from the canonical template before moving on to 5.5.

**Standard CAST agent sections** (these are CAST-owned; replace during update):

- Template instructions comment block and placeholder pointer comment (stripped at install per the global rule — remove, never carry over)
- Agent Activation blockquote
- Title heading (`# [PROJECT_NAME] — <Role> Agent`)
- `**Model**:` line
- Purpose
- Goals
- Authority
- Inputs
- Outputs
- Templates (where applicable)
- Interaction Rules (CAST's core bullets; merge user additions)
- State (pointer to `artifacts/AGENT_STATE.md`; agent files no longer carry live tables — see the migration rule in 5.7)
- Decisions Log / Current Work / Future Work tables, if present in a pre-1.2 file (they migrate to `artifacts/AGENT_STATE.md` per 5.7, not into the new agent file)

**Custom sections** (preserve verbatim): anything the user added outside the standard set. Common examples:

- "Playtesting Feedback Log"
- "Review Heuristics"
- "Code Smell Catalog"
- "Team-Specific Conventions"
- "Project Glossary"
- Agent-specific workflow appendices

Place preserved custom sections in a `## Project Customizations (preserved)` section appended at the **end of the agent file**, after all standard sections. (Do not look for a "Future Work" section to anchor on — post-1.2 agent files no longer carry one; the state tables migrated to `artifacts/AGENT_STATE.md`.)

## 5.5 — Install pipeline skills

For each of `agent-plan`, `agent-code`, `agent-task`, `file-bug`, `add-task`, `cast-doctor`, `cast-release`:

1. Read from `<CAST_SOURCE>/skills/<name>/SKILL.md`. **Never install `<CAST_SOURCE>/skills/README.md`** — it is payload documentation, not a skill.
2. Substitute project-specific values including `[PROJECT_NAME]`, `[TEST_CMD]`, and `[MAX_LOOP_COUNT]` (default 3 if not specified). `file-bug`, `add-task`, and `cast-doctor` carry only `[PROJECT_NAME]` — none of them runs project code, so they take no test command or loop cap.
3. Write to `.claude/skills/<name>/SKILL.md` (create the directory). Keep the frontmatter `name` field equal to the directory name — Claude Code requires the match.
4. If updating an existing similar-named pipeline: preserve any project-specific pre-flight or post-completion steps by moving them to an appendix section labelled `## Project-Specific Extensions (preserved from pre-CAST version)`.
5. **Pre-1.0 migration**: if `.claude/commands/<name>.md` exists (the pipelines were slash commands before CAST v1.0.0), treat it as the existing counterpart — merge its preserved custom sections into the new SKILL.md per rule 4, then propose Delete of the old command file. The delete requires explicit user approval (per the safety rules), but leaving both files registers a duplicate `/<name>`, so flag it clearly rather than silently keeping both.

## 5.5a — Execute approved Deletes

Execute every Delete action the user explicitly approved in Phase 4 — most commonly the superseded pre-1.0 command files at `.claude/commands/<name>.md` left behind by the 5.5.5 migration. Use `git rm` (plain `rm` in a non-git project) and check each executed Delete off in the plan ledger. Never execute a Delete that lacks explicit approval; in unattended mode Deletes were downgraded to flagged TODOs, so this step is a no-op there. Run this step before validation — Phase 6 check 3 (pipeline skills / superseded command files) fails if superseded command files remain without a recorded decision (in unattended mode the downgraded-Delete TODO in the report is that record, and check 3 passes).

## 5.6 — Install `.claude/cast/` (contracts, templates, source map)

Everything reads from `<CAST_SOURCE>/cast/` and writes under `.claude/cast/`, per the disposition table in `dispositions.md`:

1. **Process contracts.** Install `PIPELINE_LOOP.md` (substituting `[TEST_CMD]` and `[MAX_LOOP_COUNT]`, default 3 — the same values used for the pipeline skills) and `STAGE_CONTRACT.md`, both with the scaffolding strip applied. Preserve user loop customizations from a prior install as notes per the merge rules below.
2. **Template skeletons.** The ten skeletons (three architecture templates — system, module, data schema —, UI spec, milestone definition, task, bug-report, milestone-close, CEO review, and UX review; every `<CAST_SOURCE>/cast/templates/` file except `README.md`) install **verbatim** to `.claude/cast/templates/`, comment blocks included. The UI pair (`UI_SPEC.md`, `UX_REVIEW.md`) skips together with a recorded `ui` opt-out. `templates/README.md` also installs, but as documentation — with placeholder substitution and the scaffolding strip applied, per its disposition row.
3. **The source map.** Write `.claude/cast/SOURCES.md` from `<CAST_SOURCE>/cast/SOURCES.md`: substitute `[PROJECT_NAME]`, strip the scaffolding, then fill each category's table with the entries the user confirmed in the Phase 3 interview — verbatim paths, the user's own descriptions where they gave them — leaving `_None declared._` rows exactly where the user declared nothing. **Sequencing rule:** any approved documentation moves or deletes from the v3→v4 migration execute before this write, so every entry points at a post-migration path. Set the Last updated line to the install date.
4. On a v3→v4 upgrade, also execute the approved `templates/` → `.claude/cast/templates/` moves (`git mv` per file) and the approved `docs/` dispositions from `dispositions.md`'s migration table — before step 3, per its sequencing rule.
5. In the installed READMEs (`.claude/cast/templates/README.md`, `artifacts/README.md`), replace any `[YYYY-MM-DD]` "Last updated" token with the install date.

## 5.7 — Install artifacts scaffold

1. Read `BUGS.md`, `TASKS.md`, `STANDUP.md`, `AGENT_STATE.md`, `README.md` from `<CAST_SOURCE>/artifacts/`.
2. Substitute placeholders.
3. Write to `artifacts/`. If a file already exists with user content, preserve it — merge only if the user explicitly approved.
4. Ensure `artifacts/one-off/` exists. Do not pre-create milestone directories — `/agent-plan` Stage 1 creates each `artifacts/milestone-{N}-{slug}/`. If the plan approved a pre-2.0 by-type layout migration (see `dispositions.md` → Artifacts directory), execute it here: per-file `git mv` into the milestone directories, the `-tasks.md` → per-task-file split, and the `BUGS.md` → index + per-bug-file conversion, exactly as planned.
5. **State migration rule**: if an existing pre-1.2 agent file carries populated state tables (Current Work, Decisions Log, Directives Queue, dashboards, etc.), move the populated rows into the matching `artifacts/AGENT_STATE.md` section during the update, then install the slimmed agent definition. Empty `_(empty)_` tables are simply dropped from the agent file — the empty schemas already exist in `AGENT_STATE.md`.

## 5.8 — Install the CLAUDE.md CAST section

`CLAUDE.md` is the user's file; v4 claims exactly one section of it.

1. If no `CLAUDE.md` exists: read `<CAST_SOURCE>/root/CLAUDE.md`, substitute `[PROJECT_NAME]`, strip the scaffolding, and write a minimal `CLAUDE.md` containing only that section. Tell the user in the report that the file is theirs to grow.
2. If `CLAUDE.md` exists: **append** the CAST section (`## CAST Agent Workflow` through the version stamp) at the end. Touch nothing else — every existing section is user content, preserved verbatim.
3. On a v3 upgrade: first remove the v3 CAST-owned content per the migration table in `dispositions.md` — the Directory Conventions section, CAST-added `@docs/...` Memory Import lines (user-authored imports stay), and the old stamp line — then append the v4 section. Never remove a section the user wrote.
4. **Version stamp**: the CAST section carries the line `Adopted with CAST v[CAST_VERSION]` — substitute `[CAST_VERSION]` with this skill's `metadata.version` frontmatter value. This is the canonical stamp Phase 1 reads on later runs to detect the installed version; on an upgrade or forced re-run, replace the old version in that line. Never leave the token unfilled and never drop the line during a merge.

## 5.9 — Placeholder substitution pass

After every file is written:

1. Scan all installed files for remaining `[UPPER_SNAKE_CASE]` tokens using grep: `grep -rEn '\[[A-Z][A-Z0-9_]+\]' --include='*.md' --exclude-dir=cast-init` (the exclusion keeps a project-local cast-init install's own payload out of the scan — same rule as Phase 6 check 1)
2. For each remaining token, check whether it corresponds to something in the Phase 1 inventory. If yes, substitute. If no, leave it for the user and note it in the Phase 7 report.
3. Do not guess values. If the inventory didn't find a project name, don't make one up.

---

# Preserving customizations — detailed rules

## Agent files

When merging an existing agent file with a CAST template:

1. **Frontmatter**: use CAST's YAML (name, description, model tier). If the existing file has a custom model pin that the user explicitly chose, keep it and note the divergence from CAST defaults in the adoption report.
2. **Standard sections** (Purpose, Goals, Authority, Inputs, Outputs, Interaction Rules, Templates, State): use CAST's content as the base structure. If the existing file has additional bullets or custom rules inside these sections, merge them as additional bullets at the end of the relevant section.
3. **Custom appendix sections**: preserve verbatim, placed in the `## Project Customizations (preserved)` section appended at the end of the agent file (see 5.4).
4. **Tables in Inputs/Outputs**: if the user has added rows, keep them. If CAST has rows the user's file lacks, add them. Never remove a row the user added.
5. **Decisions Log**: always preserve every existing entry — populated rows move to the agent's section in `artifacts/AGENT_STATE.md` (see 5.7). Then add a new row to that agent's **Decision Log section in `artifacts/AGENT_STATE.md`** (not to the agent file — post-1.2 agent files carry no log tables) noting the CAST adoption: `<date> | Adopted CAST template | N/A | Structure now matches canonical CAST <version> |`. For `<version>`, use the version from this skill's frontmatter (`metadata.version` at the top of SKILL.md). Never hard-code a version number in this row.

## CLAUDE.md

When touching an existing `CLAUDE.md`:

1. **Everything the user wrote is preserved verbatim** — identity, stack, commands, conventions, pitfalls, domain patterns, imports they added themselves. v4 never merges into user sections.
2. **The CAST section** (`## CAST Agent Workflow` + stamp) is the only CAST-owned content: append it when missing, replace it wholesale when updating.
3. **v3 leftovers** (Directory Conventions, CAST-added `@docs/...` imports, the old stamp) are CAST-owned — remove them during a v4 upgrade per `dispositions.md`; when unsure whether an import line was CAST-added or user-added, ask.

## Pipeline skills

When merging an existing pipeline (skill, command, or loose instruction file) with CAST's template:

1. **Frontmatter, header, and Input section**: use CAST's version.
2. **Main Instructions / Pipeline stages**: use CAST's version as the canonical flow.
3. **Custom pre-flight checks** that the user added: preserve as an appendix section `## Project-Specific Pre-Flight (preserved)`.
4. **Custom completion steps**: preserve as an appendix section `## Project-Specific Completion Steps (preserved)`.
5. **Custom error handling**: merge into CAST's Error Handling section as additional bullets.

## Templates (migrating a v3 `templates/` directory)

When moving a prior install's template skeletons to `.claude/cast/templates/`:

1. **CAST-owned skeletons**: `git mv`, then update to the current payload version. User-added sections inside a skeleton are preserved in place (they instruct every future instance — that is a deliberate customization).
2. **User-authored templates** found alongside CAST's: move verbatim, add a row to the templates README, change nothing inside them.
3. **The project's own documentation is never part of this move.** Docs follow `dispositions.md`'s migration table — preserved in place and mapped, or deleted with approval — not relocated under `.claude/`.
