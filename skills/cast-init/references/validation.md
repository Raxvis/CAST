# Phase 6 — Validation checklist and Phase 7 — Report template

## Phase 6 — Validation checks

After execution:

1. **Scan for remaining placeholders** using `grep -rEn '\[[A-Z][A-Z0-9_]+\]' --include='*.md'`. Distinguish between:
   - Real unfilled placeholders (needs user action — list each in the report)
   - Per-use sub-template placeholders, which are expected and must NOT be substituted at install time. The whitelist: form-fill tokens (`[DATE]`, `[REPRODUCTION_STEPS]`, `[EXPECTED]`, `[ACTUAL]`, `[TASK_NAME]`, `[MILESTONE_NAME]`, `[VERSION_OR_MILESTONE]`, `[PARTICIPANT_ROLES]`, `[LIST_KEY_BEHAVIORS_TESTED]`, `[EDGE_CASE_*]`, `[METRIC_*]`, `[TARGET]`, `[Notes]`-style example cells), naming-pattern examples (`[MODULE]`, `[SYSTEM]`, `[SCHEMA]`, `[SCREEN]`, `[COMPONENT]` in filename patterns like `[MODULE]_MODULE.md`), and anything inside a fenced code block illustrating a template. When in doubt: if the token is filled per-milestone/per-bug by an agent at runtime, it is per-use; if it describes a stable property of the project, it is a real unfilled placeholder.
2. **Verify all 15 agents exist** after execution. Walk the roster table in `roster.md` and check each row's agent name against `.claude/agents/<name>.md`. Flag any missing file as an error. The only acceptable reason for a Tier 5 agent (`release`, `validator`) to be absent is an explicit user opt-out during Phase 4; in that case, record the opt-out in the Phase 7 report. If any Tier 1–4 agent is missing, that is a hard failure — do not proceed to Phase 7 until the gap is fixed. Additionally, for each existing agent file, read the `description:` field from its YAML frontmatter and confirm it matches (or is a reasonable project-specific adaptation of) the Role column in the canonical roster — a divergent description means the file is impersonating a CAST agent name without actually fulfilling the CAST role.
3. **Verify required pipeline skills exist** for the pipeline set the user chose to keep. For each of `agent-plan`, `agent-code`, `agent-task`: check `.claude/skills/<name>/SKILL.md` exists, its YAML frontmatter has `name` and `description`, and the `name` field equals the directory name. List any missing or malformed skill and flag as an error. Also confirm no superseded pre-1.0 command file remains at `.claude/commands/<name>.md` unless the user explicitly chose to keep it — a leftover copy registers a duplicate `/<name>`. Additionally, both `agent-code` and `agent-task` must reference `docs/PIPELINE_LOOP.md` (the shared engineering-loop contract) — a copy that instead carries its own inline step-by-step loop is a pre-1.2 file that was not updated.
3a. **Verify the artifacts scaffold and installed docs**:
   - `artifacts/BUGS.md`, `artifacts/STANDUP.md`, and `artifacts/AGENT_STATE.md` must exist. A missing `AGENT_STATE.md` means the agents' State pointers dangle — install it from `<CAST_SOURCE>/artifacts/AGENT_STATE.md`.
   - `docs/PIPELINE_LOOP.md` must exist whenever `agent-code` or `agent-task` is installed — both skills execute the loop it defines.
4. **Verify the docs/artifacts split**:
   - No files under `docs/` should contain the strings "# Milestone" in an H1 heading or "BUG-" at the start of a line (those would be work artifacts that leaked into reference).
   - No files under `artifacts/` should be templates (no "HOW TO CUSTOMIZE" comment blocks in `artifacts/milestones/` or similar).
5. **Verify YAML frontmatter on every agent file**:
   - Each agent has `name:`, `description:`, `model:` in the frontmatter
   - Description length ≤ 120 characters
   - Model is one of `claude-opus-4-8` (default), `claude-opus-4-7`, or `claude-opus-4-6` (or an override the user approved — e.g. `claude-haiku-4-5` on a utility agent)
6. **Verify template scaffolding was stripped**: `grep -rln 'TEMPLATE INSTRUCTIONS' .claude/ docs/ artifacts/ CLAUDE.md templates/README.md` must return nothing. Only the template skeletons under `templates/` (every `templates/*` file except `README.md`) may carry `<!-- TEMPLATE INSTRUCTIONS -->` blocks (they install verbatim). Any hit elsewhere means the install-time strip rule in `execution.md` was skipped for that file.
7. **Verify topic-doc pairing and imports**:
   - If the project type is mobile (or mixed-with-mobile), both `docs/FRONTEND.md` and `docs/MOBILE.md` must be installed — one without the other is an error.
   - The Memory Imports block in the installed `CLAUDE.md` must reference only docs that actually exist in the project, and must include every installed topic doc. A dangling `@import` or a topic doc missing from the imports means execution step 5.8.4 was skipped.

If any validation check fails, report it and ask the user how to proceed before writing the Phase 7 report. Do not silently mask failures.

## Phase 7 — Report

Write a final report to `artifacts/adoption-report.md`:

```markdown
# CAST Adoption Report
Completed: <ISO date>
Classification: <A/B/C>
Phase separation before: <None/Implicit/Explicit>
Phase separation after: Explicit (CAST-enforced)

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
- docs/artifacts split: <clean / violations>

## Remaining TODOs
<list of things the user needs to do manually>

## Files to review
<list of files where CAST merged with user content; the user should verify the merge is correct>

## Preserved customizations
<list of custom sections, files, or agents that were preserved and where they now live>

## Next steps
1. Review the migration diff: `git status` and `git diff`
2. Restart Claude Code (skills are discovered at session start) and walk through `docs/FIRST_RUN.md`
3. Run `/agents` to confirm every subagent is registered
4. Dry-run `/agent-plan "hello world feature"` to verify the planning pipeline
5. Commit the adoption: `git add -A && git commit -m "Adopt CAST template"`
```

Present the report to the user along with a summary:

> CAST adoption complete. <N> files created, <N> renamed, <N> updated, <N> preserved. <M> validation warnings or errors listed in the report. Recommended next step: restart Claude Code and walk through `docs/FIRST_RUN.md`. The full report is in `artifacts/adoption-report.md`.
