# Docs, templates, artifacts, and root-file dispositions + plan file format

Reference material for Phase 3 (Migration plan). Agent and pipeline-skill dispositions live in `roster.md`.

## Docs and templates mapping

For each CAST reference doc and document template, determine the disposition from this table. `Existing match` means the inventory from Phase 1 found a file that serves the same purpose under a different name. The `templates/*` rows install to the top-level `templates/` directory, not `docs/`.

| CAST file | If missing and no match | If existing match |
|---|---|---|
| `docs/README.md` | Create (CAST index) | Update to CAST format, preserving existing entries |
| `docs/PRD.md` | Prompt user — PRD is user content, not template | Rename to `docs/PRD.md`, update header to CAST format |
| `docs/CONCEPT.md` | Skip (optional) | Rename to `docs/CONCEPT.md` |
| `docs/GLOSSARY.md` | Skip (optional) | Rename to `docs/GLOSSARY.md` |
| `docs/DESIGN_RATIONALE.md` | Skip (optional) | Rename to `docs/DESIGN_RATIONALE.md`, preserve all decision entries |
| `docs/CODE_PATTERNS.md` | Skip (optional) | Rename, preserve existing conventions |
| `docs/FILE_CONVENTIONS.md` | **Always install** — load-bearing for docs/artifacts split | Rename + merge with CAST's enforcement rules |
| `docs/ERROR_HANDLING.md` | Skip (optional) | Rename |
| `docs/TEST_FRAMEWORK.md` | Skip (optional) | Rename |
| `docs/MODEL_OPTIMIZATION.md` | **Always install** — referenced by every agent's Model Configuration section | Install CAST version; preserve any user-added model pins as notes |
| `docs/CHANGELOG.md` | Skip (optional) | Preserve — note Release agent will maintain going forward |
| `docs/ASSETS.md` | Skip (optional) | Preserve |
| `docs/MVP_LAUNCH.md` | Skip (optional) | Preserve |
| `templates/MILESTONE_DEFINITION.md` | **Always install** — consumed by /agent-plan Stage 1 | Install CAST version; any existing content moves to `artifacts/milestones/` as an instance |
| `templates/MILESTONE_TASKS.md` | **Always install** — consumed by /agent-plan Stage 1 | Same |
| `templates/MILESTONE_COMPLETION.md` | **Always install** | Same |
| `templates/MILESTONE_VALIDATION.md` | **Always install** | Same |
| `templates/ARCH_MODULE.md` | **Always install** — consumed by /agent-plan Stage 2a | Same |
| `templates/ARCH_SYSTEM.md` | **Always install** | Same |
| `templates/ARCH_DATA_SCHEMA.md` | **Always install** | Same |
| `templates/UI_SPEC.md` | Install unless project is clearly backend/CLI-only with no user interface | Same |
| `docs/FRONTEND.md` | Install if project type is frontend, mobile, or mixed | Prompt user if ambiguous |
| `docs/BACKEND.md` | Install if project type is backend, data pipeline, or mixed | Same |
| `docs/CLI.md` | Install if project type is CLI or mixed | Same |
| `docs/MOBILE.md` | Install if project type is mobile or mixed-with-mobile. Always pair with `docs/FRONTEND.md` — mobile apps need both. | Same |
| `docs/FIRST_RUN.md` | Always install | Same |
| `docs/CLAUDE_CODE_SETTINGS.md` | Always install | Same |
| `docs/ADDITIONAL.md` | Skip (optional) | Rename |

## Artifacts directory

If `artifacts/` does not exist, Create it with:

- `BUGS.md` from CAST template
- `STANDUP.md` from CAST template
- `README.md` from CAST template
- Empty subdirectories: `milestones/`, `architecture/`, `ui-specs/`, `reviews/`

If `artifacts/` already exists and contains CAST-shaped files, preserve as-is and integrate.

If a directory named `features/`, `work/`, or `planning/` exists and contains CAST-shaped files (detected by filename patterns `milestone-*.md`, `arch-milestone-*.md`, `ceo-review-*.md`), propose Rename + Update: rename the directory to `artifacts/` and update every reference across agents, pipeline skills, docs. This is the pre-0.3.0 CAST migration path. **Ask the user before renaming a directory.**

## Root files

- `CLAUDE.md` — if present, merge with CAST's agnostic template; preserve user content. If absent, Create from CAST's `root/CLAUDE.md` with detected placeholders substituted.
- `README.md` — preserve the user's existing README. Do not touch it. Optionally offer to add a CAST adoption note at the bottom if the user wants.
- `TROUBLESHOOTING.md` / `CHANGELOG.md` — preserve if present; do **not** create them. CAST ships no root-level template for either. Point the user at the CAST repo's troubleshooting guide (`https://github.com/Raxvis/CAST/blob/main/TROUBLESHOOTING.md`) instead, and note that the Release agent maintains `docs/CHANGELOG.md` inside the project.

`root/CLAUDE.md` is the only file /cast-init installs at the target project root.

## Write the migration plan

Write the full plan to `artifacts/adoption-plan.md`. Structure:

```markdown
# CAST Adoption Plan
Generated: <ISO date>
Classification: <A. Greenfield / B. Partial / C. Full existing>
Phase separation: <None / Implicit / Explicit>

## Summary
<3-5 sentences describing the scope of changes, total file counts by action, and anything the user should read carefully>

## Proposed actions

### Create (N actions)
1. **Create** `.claude/agents/ceo.md`
   - Source: `<CAST_SOURCE>/agents/ceo.md`
   - Substitutions: `[PROJECT_NAME]` → `<detected>`
   - Rationale: CAST requires CEO for /agent-plan Stage 4; no existing equivalent found.

### Rename + Update (N actions)
1. **Rename + Update** `planner.md` → `.claude/agents/product.md`
   - Source: `<CAST_SOURCE>/agents/product.md`
   - Preserve: custom "Planning heuristics" section from original file as an appendix
   - Rationale: existing planner agent fills the Product role; renaming to match CAST canonical name.

### Update in place (N actions)
1. **Update** `CLAUDE.md`
   - Source: merge with `<CAST_SOURCE>/root/CLAUDE.md`
   - Preserve: every existing section (Project Overview, Tech Stack, Common Pitfalls, Domain-Specific Patterns)
   - Add: Directory Conventions section, updated Memory Imports referencing newly-installed docs
   - Rationale: user's CLAUDE.md is mostly compatible; just needs the CAST-specific sections.

### Preserve as-is (N actions)
1. **Preserve** `docs/PRD.md`
   - Rationale: already matches CAST's reference format.

### Skip (not applicable) (N actions)
1. **Skip** `docs/FRONTEND.md`
   - Rationale: project is a CLI tool, no user-facing interface.

### Delete (requires explicit approval) (N actions)
1. **Delete** `.claude/commands/agent-plan.md`
   - Rationale: superseded by `.claude/skills/agent-plan/SKILL.md` after the pre-1.0 migration. Keeping both would register a duplicate /agent-plan. Requires user approval.

### Ask — decisions requiring user input (N questions)
1. You have an existing `designer.md` agent. It looks closer to CAST's UI agent than the Product agent. Should I rename it to `.claude/agents/ui.md`, map it to Product, or create both fresh and leave designer.md alone?
2. Your project has both frontend (React) and backend (Express) code. Should I install both `docs/FRONTEND.md` and `docs/BACKEND.md`? (Recommended: yes.)
3. Your project is a React Native app. Should I install `docs/FRONTEND.md` and `docs/MOBILE.md` as a pair? (Recommended: yes — mobile projects need both the shared UI patterns and the mobile-specific delta.)
4. You have a `features/` directory with 12 files matching CAST's pre-0.3.0 naming. Confirm renaming to `artifacts/` and updating all cross-references?
5. CAST installs 15 agents by default, including `validator` (owns process integrity, conflict resolution, milestone tracking) and `release` (owns changelog and version bumping). Your project doesn't currently have either. Should I install both, install only one, or skip both? (Recommended: install both. Skip only if you're certain you don't need them — CAST installs them by default.)
```

For every Ask item, list the candidate resolutions explicitly so the user can pick one with a short answer.
