# Phase 6 — Validation checklist and Phase 7 — Report template

## Phase 6 — Validation checks

After execution:

1. **Scan for remaining placeholders** — scoped to the installed file set only, i.e. the files the plan's Create / Rename+Update / Update-in-place actions touched: `.claude/agents/`, `.claude/skills/`, `.claude/cast/` (excluding the template skeletons), `artifacts/`, and the root `CLAUDE.md`. Never grep the whole project — the target's own documentation, `node_modules/`, and anything the plan did not touch are out of scope. The `.claude/cast/templates/` skeletons (every file there except `README.md`) are explicitly exempt: they install verbatim and legitimately keep their tokens. For example: `grep -rEn '\[[A-Z][A-Z0-9_]+\]' --include='*.md' --exclude-dir=cast-init --exclude-dir=templates .claude/ artifacts/ CLAUDE.md; grep -En '\[[A-Z][A-Z0-9_]+\]' .claude/cast/templates/README.md`. The `--exclude-dir=cast-init` is required: with a project-local `npx skills` install, `.claude/skills/cast-init/assets/` carries the full CAST payload — thousands of legitimate `[PLACEHOLDER]` tokens that are not part of the adoption. Distinguish between:
   - Real unfilled placeholders (needs user action — list each in the report)
   - Per-use sub-template placeholders, which are expected and must NOT be substituted at install time. The whitelist: form-fill tokens (`[DATE]`, `[REPRODUCTION_STEPS]`, `[EXPECTED]`, `[ACTUAL]`, `[TASK_NAME]`, `[MILESTONE_NAME]`, `[VERSION_OR_MILESTONE]`, `[PARTICIPANT_ROLES]`, `[LIST_KEY_BEHAVIORS_TESTED]`, `[EDGE_CASE_*]`, `[METRIC_*]`, `[TARGET]`, `[Notes]`-style example cells), naming-pattern examples (`[MODULE]`, `[SYSTEM]`, `[SCHEMA]`, `[SCREEN]`, `[COMPONENT]` in filename patterns like `[MODULE]_MODULE.md`), and anything inside a fenced code block illustrating a template. When in doubt: if the token is filled per-milestone/per-bug by an agent at runtime, it is per-use; if it describes a stable property of the project, it is a real unfilled placeholder.
2. **Verify all 7 agents exist** after execution. Walk the roster table in `roster.md` and check each row's agent name against `.claude/agents/<name>.md`. Flag any missing file as an error. The only acceptable absence is the `ui` agent on a clearly backend/CLI-only project under a Phase 4 opt-out recorded in the Phase 7 report; every other absence is a hard failure — do not proceed to Phase 7 until the gap is fixed. **Also verify no v2 agent survives**: `tester.md`, `refactor.md`, `debugger.md`, `bug-gatherer.md`, `validator.md`, `security.md`, `performance.md`, `release.md`, and `risk.md` (pre-release v3 draft) must not exist in `.claude/agents/` — a leftover file registers a subagent the pipelines no longer invoke and whose instructions contradict the v3 loop. Additionally, for each existing agent file, read the `description:` field from its YAML frontmatter and confirm it matches (or is a reasonable project-specific adaptation of) the Role column in the canonical roster — a divergent description means the file is impersonating a CAST agent name without actually fulfilling the CAST role.
3. **Verify required pipeline skills exist** for the pipeline set the user chose to keep, plus the always-installed intake and maintenance skills. For each of `agent-plan`, `agent-code`, `agent-task`, `file-bug`, `add-task`, `cast-doctor`, `cast-release`: check `.claude/skills/<name>/SKILL.md` exists, its YAML frontmatter has `name` and `description`, and the `name` field equals the directory name. List any missing or malformed skill and flag as an error. Also confirm no superseded pre-1.0 command file remains at `.claude/commands/<name>.md` unless the user explicitly chose to keep it — a leftover copy registers a duplicate `/<name>`. **Unattended-mode carve-out**: in unattended mode Deletes are downgraded to flagged TODOs (see SKILL.md Modes), so a superseded command file whose Delete was downgraded counts as PASS provided the downgrade is recorded as a TODO in the Phase 7 report — the recorded TODO is the record. Interactive runs still fail on leftover command files with no recorded user decision to keep them. Additionally, both `agent-code` and `agent-task` must reference `.claude/cast/PIPELINE_LOOP.md` (the shared engineering-loop contract) — a copy referencing `docs/PIPELINE_LOOP.md` is a pre-v4 file that was not updated, and one carrying its own inline step-by-step loop is pre-1.2.
3a. **Verify `.claude/cast/` and the artifacts scaffold**:
   - `.claude/cast/SOURCES.md`, `.claude/cast/PIPELINE_LOOP.md`, `.claude/cast/STAGE_CONTRACT.md`, and the `.claude/cast/templates/` skeletons must exist (the loop contract is executed by `agent-code` and `agent-task`; the UI template pair may be absent only under a recorded `ui` opt-out).
   - `artifacts/BUGS.md`, `artifacts/TASKS.md`, `artifacts/STANDUP.md`, and `artifacts/AGENT_STATE.md` must exist. A missing `AGENT_STATE.md` means the agents' State pointers dangle — install it from `<CAST_SOURCE>/artifacts/AGENT_STATE.md`; a missing `TASKS.md` leaves `/add-task` and `/agent-task backlog` with no queue — install it from `<CAST_SOURCE>/artifacts/TASKS.md`.
4. **Verify the source map**:
   - Every location entry in `.claude/cast/SOURCES.md` resolves: the path exists, a glob matches at least one file, a directory contains at least one markdown file. A dangling entry is an error — planning trusts this file.
   - Every required category carries either entries or the literal `_None declared._` row — never an empty or half-filled table.
   - The entries match what the user confirmed in the Phase 3 interview (cross-check the plan file) — nothing guessed in, nothing approved left out.
   - No files under `artifacts/` should be templates (no "HOW TO CUSTOMIZE" comment blocks in milestone directories or `artifacts/one-off/`), and no v1 by-type directories (`artifacts/milestones/`, `architecture/`, `ui-specs/`, `reviews/`) remain after an approved pre-2.0 migration.
5. **Verify YAML frontmatter on every agent file**:
   - Each agent has `name:`, `description:`, `model:`, and `tools:` in the frontmatter
   - The `tools:` list omits `Task` (the no-subagents rule is enforced by the toolset, not just prose); extensions the user approved (e.g. MCP tools) are fine
   - Description length ≤ 300 characters (the canonical trigger-first descriptions run roughly 170–260 characters; anything over 300 is likely an unconverted prose paragraph, not a description)
   - Model is `inherit` (default) or an explicit pin the user approved — right-sized aliases like `opus` on `ceo`, `sonnet` on `coder`, or `haiku` on a utility agent (see `roster.md` → "Right-sizing models"), or full model IDs such as `claude-opus-5` / `claude-sonnet-5` / `claude-haiku-4-5`
6. **Verify template scaffolding was stripped**: `grep -rln 'TEMPLATE INSTRUCTIONS' --exclude-dir=cast-init --exclude-dir=templates .claude/ artifacts/ CLAUDE.md; grep -ln 'TEMPLATE INSTRUCTIONS' .claude/cast/templates/README.md` must return nothing. (As in check 1, `--exclude-dir=cast-init` keeps a project-local cast-init install's own payload — which legitimately carries template-instruction blocks — out of the scan.) Only the template skeletons under `.claude/cast/templates/` (every file there except `README.md`) may carry `<!-- TEMPLATE INSTRUCTIONS -->` blocks (they install verbatim). Any hit elsewhere means the install-time strip rule in `execution.md` was skipped for that file.
7. **Verify the CLAUDE.md CAST section and version stamp**:
   - The `## CAST Agent Workflow` section exists and points at `.claude/cast/SOURCES.md`.
   - No CAST-owned v3 leftovers survive: no Directory Conventions section describing a CAST `docs/`/`templates/` split, and no CAST-added `@docs/...` Memory Import lines (imports the user authored themselves stay untouched — when provenance is unclear, it was asked at Phase 4).
   - The installed `CLAUDE.md` must contain **exactly one** `Adopted with CAST v<X.Y.Z>` line, and its version must equal this skill's `metadata.version` frontmatter value. Zero occurrences means execution step 5.8.4 was skipped (Phase 1 of the next run cannot detect the install); more than one, or a mismatched version, means a merge duplicated or failed to update the canonical stamp.
8. **Verify UI opt-out consistency**: `.claude/agents/ui.md` and the UI templates (`.claude/cast/templates/UI_SPEC.md`, `.claude/cast/templates/UX_REVIEW.md`) must be present together or absent together, and an absence requires the recorded backend/CLI-only opt-out from Phase 4. An installed `ui` agent whose templates were skipped — or installed UI templates with no `ui` agent — is an error.

If any validation check fails, report it and ask the user how to proceed before writing the Phase 7 report. **In unattended mode, do not prompt**: halt execution, write the Phase 7 report as a failed adoption (`Outcome: Failed at Phase 6`, listing every failed check under Validation results and the recovery steps first under Next steps), and end the run. Do not silently mask failures.

## Phase 7 — Report

Write a final report to `artifacts/adoption-report.md`:

```markdown
# CAST Adoption Report
Completed: <ISO date>
Outcome: <Complete / Complete with warnings / Staged — moves pending / Failed at Phase <N>>
Classification: <A/B/C>
Phase separation before: <None/Implicit/Explicit>
Phase separation after: <Explicit (CAST-enforced) / unchanged — adoption did not complete>

## Actions executed
- **Created**: <N files> — <list>
- **Renamed + Updated**: <N files> — <list with old → new paths>
- **Updated in place**: <N files> — <list>
- **Preserved**: <N files> — <list>
- **Skipped**: <N actions> — <list with rationale>
- **Deleted**: <N files> — <list with user approval reference>

## Validation results
- Placeholder check: <clean / N remaining>
- Required agents: <present / missing list>
- Required pipeline skills: <present / missing list>
- Source map: <all entries resolve / list of dangling or malformed entries>

## Staged paths (include only when `.cast-stage/` is in play)
<list each staged path and its final destination, then the exact `mv` command(s)
that complete the install, ending with removal of the empty `.cast-stage/` directory>

## Remaining TODOs
<list of things the user needs to do manually; for a partial or failed adoption,
list which plan actions executed (per the plan-file ledger) and which did not>

## Files to review
<list of files where CAST merged with user content; the user should verify the merge is correct>

## Preserved customizations
<list of custom sections, files, or agents that were preserved and where they now live>

## Next steps
1. Review the migration diff: `git status` and `git diff`
2. Restart Claude Code (skills are discovered at session start) and confirm the seven skills tab-complete (`/agent`, `/file`, `/add`, `/cast`)
3. Run `/agents` to confirm every subagent is registered
4. Dry-run `/agent-plan "hello world feature"` to verify the planning pipeline
5. Commit the adoption: `git add -A && git commit -m "Adopt CAST template"`
```

Present the report to the user along with a summary, filling every slot to match the actual outcome — never claim success for a staged, partial, or failed adoption:

> CAST adoption <complete / complete with warnings / staged / failed at Phase <N>>. <N> files created, <N> renamed, <N> updated, <N> preserved, <N> deleted. <M> validation warnings or errors listed in the report. <If any paths were staged: "Staged paths: <list>. Complete the install with: <exact `mv` command(s)>, then remove the empty `.cast-stage/` directory."> Recommended next step: <restart Claude Code, confirm the skills tab-complete, and try `/agent-task` on something trivial / for a partial or failed adoption: the first recovery step from the report>. The full report is in `artifacts/adoption-report.md`.
