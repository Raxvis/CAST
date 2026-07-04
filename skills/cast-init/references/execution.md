# Phase 5 — Execution: install mechanics and customization-preservation rules

Read this file before writing any file in Phase 5. Execute the approved plan's actions in the order of the sections below, reporting progress along the way.

## Global rule — strip template scaffolding at install

Every file written into the target project (agents, pipeline skills, docs, artifacts scaffold, root CLAUDE.md) must have its template scaffolding removed before writing:

1. The leading `<!-- TEMPLATE INSTRUCTIONS ... -->` comment block.
2. Any `<!-- Placeholders — see README.md → Placeholder Reference -->` pointer comment (it references the CAST repo's README, which does not exist in the target project).

These blocks are documentation for people browsing the CAST repo; installed files must not carry them. **Exception: the eight `templates/*` files install verbatim, blocks included** — they are reusable skeletons, and their comment blocks instruct the agents that instantiate them (the instantiated copies in `artifacts/` must not carry the blocks, which is what the Phase 6 docs/artifacts-split check enforces).

When updating an existing installed file that still carries one of these blocks from a pre-1.0 install, remove it as part of the update — it is CAST-owned scaffolding, not a user customization.

## Global rule — permission-blocked writes fall back to staging

If the session's permission system blocks writes to a target path (most commonly `.claude/agents/` and `.claude/skills/` in non-interactive sessions), do not retry indefinitely, skip the files, or abort the adoption. Instead:

1. Build every blocked file completely — placeholder substitution, scaffolding strip, customization merges — exactly as if writing to the real destination.
2. Write the finished files to a `.cast-stage/` directory at the project root, mirroring the final layout (e.g. `.cast-stage/agents/coder.md` for `.claude/agents/coder.md`, `.cast-stage/skills/agent-plan/SKILL.md` for `.claude/skills/agent-plan/SKILL.md`).
3. Run all Phase 6 validation checks against the staged copies so the user moves verified files, not unverified ones.
4. State prominently in the Phase 7 report — and in the closing summary — that the adoption is staged, list exactly which paths are staged, and give the precise `mv` command(s) that complete the install, ending with the removal of the empty `.cast-stage/` directory.

Files that were written directly (typically `docs/`, `templates/`, `artifacts/`, root `CLAUDE.md`) are unaffected — stage only what was blocked. Never leave a partially-staged adoption unreported: if `.cast-stage/` exists when the report is written, the report must say so.

## 5.1 — Preflight

Verify:

1. Git working tree is clean (`git status` returns nothing modified or staged). Two exceptions, both requiring user confirmation before proceeding:
   - **Resuming an interrupted adoption**: if the only dirty files are ones the prior CAST run wrote (cross-check against the existing `artifacts/adoption-plan.md`), offer to resume — re-verify each already-written file against its planned action instead of demanding a stash. Anything dirty that the plan does not account for still blocks.
   - **Completing a staged adoption**: if `.cast-stage/` exists from a prior permission-blocked run, offer to complete the move per the staging rule below instead of starting over.
   Otherwise, stop and ask the user to commit or stash.
2. `CAST_SOURCE` (resolved in SKILL.md as `<CAST_SKILL_DIR>/assets`) exists and contains `agents/`, `skills/`, `docs/`, `templates/`, `artifacts/`, and `root/`. If missing, stop — the cast-init install is incomplete; ask the user to re-install with `npx skills add Raxvis/CAST` or `/plugin install cast@cast`.

## 5.1a — Fast path for pure-Create actions

Most greenfield adoptions are dominated by **Create** actions with no merge work. Do not read-and-retype those files one at a time. Instead:

1. Copy the payload subtrees mechanically with shell (`cp -R "<CAST_SOURCE>/docs/." docs/` etc., or per-file `cp` driven by the plan's Create list). This is permitted: the safety rule forbids executing the *target project's* code, not using the shell to copy CAST's own payload files.
2. Run **one substitution pass** over the copied files, replacing every token listed in 5.4.2 with its inventory value (e.g. a scripted find-and-replace per token).
3. Run **one scaffolding-strip pass** over the copied files per the global strip rule (skip the eight `templates/*` skeletons).
4. Spot-check one file per class (an agent, a pipeline skill, a doc) to confirm substitution and strip landed, then rely on Phase 6 validation for full coverage.

The per-file read-merge-write procedure in 5.4–5.8 remains **required** for every Rename+Update and Update-in-place action — customization preservation cannot be done mechanically. Never bulk-copy over an existing file.

## 5.2 — Create directories

Create any missing directories: `.claude/agents/`, `.claude/skills/`, `docs/`, `templates/`, `artifacts/`, `artifacts/milestones/`, `artifacts/architecture/`, `artifacts/ui-specs/`, `artifacts/reviews/`.

## 5.3 — Handle directory renames

If the plan includes a rename of `features/` (or similar) → `artifacts/`, execute it with `git mv` so history is preserved. Then update every string reference to the old directory across `.claude/`, `docs/`, and the project README. Use Grep to find references before renaming.

## 5.4 — Install agent files

Walk the canonical 15-agent list in the order given by the roster table in `roster.md` (rows 1 through 15, top to bottom — that is the install order) and execute the planned action for each. **Do not skip any name on this list.** If the plan has no action for one of these names, that is a bug in the Phase 3 plan — stop and re-enter Phase 3 to add the missing action.

For each agent:

1. Read the CAST agent file from `<CAST_SOURCE>/agents/<name>.md`. **Never install `<CAST_SOURCE>/agents/README.md`** — it is payload documentation, and a `.claude/agents/README.md` would be registered as a bogus subagent.
2. Substitute every placeholder that has a collected inventory value — identity (`[PROJECT_NAME]`, `[PROJECT_TYPE]`, `[ONE_SENTENCE_PITCH]`), tech (`[LANGUAGE]`, `[FRAMEWORK]`, `[FRAMEWORK_VERSION]`, `[EXT]`, `[STATE_LIBRARY]`, `[NAVIGATION_LIBRARY]`, `[PERSISTENCE_LAYER]`, `[TEST_RUNNER]`), commands (`[TEST_CMD]`, `[DEV_SERVER_CMD]`, `[BUILD_CMD]`, `[TYPE_CHECK_CMD]`), packaging (`[PKG_MANAGER]`, `[PKG_MANIFEST]`, `[PKG_ADD_CMD]`, `[TYPE_CONFIG]`, `[FRAMEWORK_CONFIG]`, `[BUNDLER_CONFIG]`), platforms (`[TARGET_PLATFORMS]`), structure (`[SCREEN_DIR]`, `[LOGIC_DIR]`, `[STORE_DIR]`, `[COMPONENTS_DIR]`, `[HOOKS_DIR]`, `[CONSTANTS_DIR]`, `[ASSETS_DIR]`), and conventions (`[LOWER_CASE_CONVENTION]`, `[PASCAL_CASE_CONVENTION]`, `[UPPER_SNAKE_CONVENTION]`). Domain tokens the user answered in Phase 3 substitute too; unanswered ones stay and go in the report.
3. If the action is **Create**: write to `.claude/agents/<name>.md` directly.
4. If the action is **Rename + Update**: read the existing file first, identify custom sections (anything not in CAST's standard section list), write the CAST template as the base, insert custom sections as an appendix after the standard sections, then move the old file to the new canonical name.
5. If the action is **Update in place**: read the existing file, identify custom sections, replace CAST-owned sections with CAST's current versions, leave custom sections untouched.
6. Verify YAML frontmatter is valid (`name`, `description`, `model` keys present, properly quoted description).

After completing the loop, **re-enumerate the 15 names and confirm each `.claude/agents/<name>.md` exists**. If any file is missing, that means the action was skipped. Create it from the canonical template before moving on to 5.5.

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
- Current Work (empty table for new installs, preserve existing rows for updates)
- Decisions Log (preserve all existing entries)
- Future Work

**Custom sections** (preserve verbatim): anything the user added outside the standard set. Common examples:

- "Playtesting Feedback Log"
- "Review Heuristics"
- "Code Smell Catalog"
- "Team-Specific Conventions"
- "Project Glossary"
- Agent-specific workflow appendices

Place preserved custom sections after the Future Work section, under a new H2 heading `## Custom Extensions (preserved from pre-CAST version)`.

## 5.5 — Install pipeline skills

For each of `agent-plan`, `agent-code`, `agent-task`:

1. Read from `<CAST_SOURCE>/skills/<name>/SKILL.md`. **Never install `<CAST_SOURCE>/skills/README.md`** — it is payload documentation, not a skill.
2. Substitute project-specific values including `[PROJECT_NAME]`, `[TEST_CMD]`, and `[MAX_LOOP_COUNT]` (default 3 if not specified).
3. Write to `.claude/skills/<name>/SKILL.md` (create the directory). Keep the frontmatter `name` field equal to the directory name — Claude Code requires the match.
4. If updating an existing similar-named pipeline: preserve any project-specific pre-flight or post-completion steps by moving them to an appendix section labelled `## Project-Specific Extensions (preserved from pre-CAST version)`.
5. **Pre-1.0 migration**: if `.claude/commands/<name>.md` exists (the pipelines were slash commands before CAST v1.0.0), treat it as the existing counterpart — merge its preserved custom sections into the new SKILL.md per rule 4, then propose Delete of the old command file. The delete requires explicit user approval (per the safety rules), but leaving both files registers a duplicate `/<name>`, so flag it clearly rather than silently keeping both.

## 5.6 — Install reference docs and templates

For each CAST reference doc and document template in the plan:

1. If the action is **Create** or **Rename + Update**: read from the source path shown in the mapping table in `dispositions.md` — `<CAST_SOURCE>/docs/<file>.md` for reference docs, `<CAST_SOURCE>/templates/<file>.md` for the `templates/*` rows — substitute placeholders, and write to the same relative path in the target project (`docs/<file>.md` or `templates/<file>.md` respectively).
2. For **Rename + Update**: read the existing file first, preserve all non-template content (e.g., an existing PRD with real requirements) as the body, update only the header and any CAST-specific framing.
3. For **Update in place**: same as Rename + Update but without moving the file.
4. Always install `docs/FILE_CONVENTIONS.md` — it's load-bearing for the docs/templates/artifacts split enforcement.
5. The eight `templates/*` files (architecture, UI spec, and milestone templates) install verbatim into the project's top-level `templates/` directory. Create the directory if it does not exist. `templates/README.md` also installs, but as documentation — with placeholder substitution and the scaffolding strip applied, per its disposition row.
6. In installed README files (`docs/README.md`, `templates/README.md`, `artifacts/README.md`), replace any `[YYYY-MM-DD]` "Last updated" token with the install date.

## 5.7 — Install artifacts scaffold

1. Read `BUGS.md`, `STANDUP.md`, `README.md` from `<CAST_SOURCE>/artifacts/`.
2. Substitute placeholders.
3. Write to `artifacts/`. If a file already exists with user content, preserve it — merge only if the user explicitly approved.
4. Ensure all four subdirectories (`milestones/`, `architecture/`, `ui-specs/`, `reviews/`) exist. Do not populate them — they fill up during `/agent-plan` and `/agent-code` runs.

## 5.8 — Install CLAUDE.md

Special handling because `CLAUDE.md` is where user project identity lives.

1. If no `CLAUDE.md` exists: read `<CAST_SOURCE>/root/CLAUDE.md`, substitute detected values, write to project root.
2. If `CLAUDE.md` exists: read it. Identify user content vs CAST content.
   - **User content** (preserve verbatim): Project Overview, Tech Stack, Common Pitfalls (preserve user additions), Project Structure, Style Conventions, Domain-Specific Patterns, Persistence, Git Workflow, Dependencies, File Naming.
   - **CAST content** (install or update): Directory Conventions section (docs/ vs artifacts/), Memory Imports block.
3. Append the CAST sections if missing; update them if out-of-date.
4. Update Memory Imports to reference every installed doc, including the detected topic doc(s) (`docs/FRONTEND.md`, `docs/BACKEND.md`, `docs/CLI.md`, `docs/MOBILE.md`). Mobile projects should import both `docs/FRONTEND.md` and `docs/MOBILE.md`.

## 5.9 — Placeholder substitution pass

After every file is written:

1. Scan all installed files for remaining `[UPPER_SNAKE_CASE]` tokens using grep: `grep -rEn '\[[A-Z][A-Z0-9_]+\]' --include='*.md'`
2. For each remaining token, check whether it corresponds to something in the Phase 1 inventory. If yes, substitute. If no, leave it for the user and note it in the Phase 7 report.
3. Do not guess values. If the inventory didn't find a project name, don't make one up.

---

# Preserving customizations — detailed rules

## Agent files

When merging an existing agent file with a CAST template:

1. **Frontmatter**: use CAST's YAML (name, description, model tier). If the existing file has a custom model pin that the user explicitly chose, keep it and note the divergence from CAST defaults in the adoption report.
2. **Standard sections** (Purpose, Goals, Authority, Inputs, Outputs, Interaction Rules, Templates, Current Work, Decisions Log, Future Work): use CAST's content as the base structure. If the existing file has additional bullets or custom rules inside these sections, merge them as additional bullets at the end of the relevant section.
3. **Custom appendix sections**: preserve verbatim, placed after the standard sections under `## Custom Extensions (preserved from pre-CAST version)`.
4. **Tables in Inputs/Outputs**: if the user has added rows, keep them. If CAST has rows the user's file lacks, add them. Never remove a row the user added.
5. **Decisions Log**: always preserve every existing entry. Add a new row noting the CAST adoption: `<date> | Adopted CAST template | N/A | Structure now matches canonical CAST <version> |`. For `<version>`, use the version from this skill's frontmatter (`metadata.version` at the top of SKILL.md). Never hard-code a version number in this row.

## CLAUDE.md

When merging an existing `CLAUDE.md`:

1. **Project identity section**: keep the user's version verbatim. Do not touch `# <Project Name>`, description, or tech stack.
2. **Build and test commands**: keep the user's version verbatim.
3. **Style conventions**: keep the user's version verbatim.
4. **Common Pitfalls**: preserve user pitfalls; add CAST's universal pitfalls (hidden mutable state, silent error swallowing, etc.) if the user's list is empty or very short.
5. **Directory Conventions section**: install CAST's version. This is the docs/artifacts split explanation and must appear verbatim.
6. **Memory Imports block**: install CAST's version, adjusting the import list to match the actual docs installed in this project.
7. **Domain-specific patterns**: preserve the user's section verbatim if present.

## Pipeline skills

When merging an existing pipeline (skill, command, or loose instruction file) with CAST's template:

1. **Frontmatter, header, and Input section**: use CAST's version.
2. **Main Instructions / Pipeline stages**: use CAST's version as the canonical flow.
3. **Custom pre-flight checks** that the user added: preserve as an appendix section `## Project-Specific Pre-Flight (preserved)`.
4. **Custom completion steps**: preserve as an appendix section `## Project-Specific Completion Steps (preserved)`.
5. **Custom error handling**: merge into CAST's Error Handling section as additional bullets.

## Docs

When merging an existing doc file with a CAST reference template:

1. **Header** (title, metadata): use CAST's format.
2. **Body content**: preserve the user's content entirely. CAST reference docs are templates — they become real content when filled in. If the user has already filled in the content, do not overwrite it.
3. **Structure**: if the user's doc has the same sections as CAST's template but in a different order, preserve their order.
4. **Template instructions comment block**: never present in installed files (the global strip rule covers new installs; remove it from pre-existing files during merge).
