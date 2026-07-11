# Agent roster, tiers, alias tables, and pipeline-skill mapping

Reference material for Phase 3 (Migration plan). The roster table is the authoritative list every adoption must account for.

## Critical agent requirements

CAST ships **fifteen** agents. An adoption must account for every one of them — not only the required tiers but also Docs Writer, Release, and Validator, which are listed as "Optional based on project type" in the main README but **are still installed by default** by this skill unless the user explicitly opts out. A common mistake is to migrate the tiered agents and silently drop Validator and Release — **do not do this**.

**Tier 1 — Core development loop (always required):**

- `product`, `coder`, `reviewer`, `tester`

**Tier 2 — Strongly recommended for any serious project:**

- `architect`, `debugger`, `docs-writer`

**Tier 3 — Required for `/agent-task`** (on top of Tiers 1–2):

- `debugger`, `refactor`, `bug-gatherer`

**Tier 4 — Required for `/agent-plan` and `/agent-code`** (on top of Tiers 1–3):

- `architect`, `ui`, `security`, `performance`, `ceo`

**Tier 5 — Project-type optional but installed by default:**

- `release` — owns changelog, version bumping, and release preparation. Keep for any project that ships formal releases or maintains `docs/CHANGELOG.md`. Drop only for personal scratch projects that never cut a release.
- `validator` — owns process integrity, conflict resolution between agents, milestone tracking, retrospectives, and the session-start checklist. Keep for any project that runs `/agent-plan` or `/agent-code` — Validator is the arbiter when Product and Architecture disagree, when a Reviewer and Tester classification conflicts, or when a milestone stalls. Drop only if you have a strict single-developer workflow where there is no need for agent-vs-agent escalation.

**`ui` opt-out for backend/CLI-only projects.** The `ui` agent is Tier 4, but it becomes optional — mirroring the Tier 5 treatment — when the project is clearly backend/CLI-only with no user interface (the same condition under which `dispositions.md` skips `templates/UI_SPEC.md` and `templates/UX_REVIEW.md`). The opt-out must be explicit: propose it as a Skip in the plan, get the user's confirmation at the Phase 4 gate, and record it in the Phase 7 report. The UI templates are skipped **if and only if** the `ui` agent is skipped — never install one half of the pair (Phase 6 checks this consistency). The installed `/agent-plan` skill skips its UI design stage when no `ui` agent is present, so the pipeline stays runnable.

**Default install set: all 15 agents.** Every Tier 5 agent must appear as either Create or Preserve in the plan unless the user explicitly says "skip validator" or "skip release" during the Phase 4 approval gate; the same applies to `ui` under the backend/CLI-only opt-out above. Do not silently omit them.

**For each missing required agent** (Tiers 1–4, `ui` excepted under a recorded opt-out) or each missing Tier 5 agent (unless the user opts out), the plan must include a Create action. If the user has an existing file that fills the role under a different name, propose Rename + Update. If the fill is ambiguous, mark as Ask and list the candidates.

**Final check before closing the plan:** enumerate all 15 agent names from the table below and verify every one has a corresponding Create / Rename+Update / Update-in-place / Preserve action in the plan. If any of the 15 is missing from the plan, add the corresponding Create action before presenting the plan to the user.

## Canonical CAST agent roster (current release)

Use this table as the authoritative reference when comparing an existing project's agents against CAST. The description column is pulled verbatim from each agent file's YAML frontmatter — match role against role, not name against name. Every agent is pinned to `claude-opus-4-8` (the Claude Opus 4.x family is the optimized target; `claude-opus-4-7` and `claude-opus-4-6` are supported alternatives — see `docs/MODEL_OPTIMIZATION.md`); the Effort column is the recommended reasoning effort from each agent's Model Configuration section. Override per-agent only when the user has a reason.

| # | Agent | Tier | Model | Effort | Role (from agent frontmatter) |
|---|---|---|---|---|---|
| 1 | `product` | 1 | `claude-opus-4-8` | `high` | Use at the start of /agent-plan to define milestone goals and acceptance criteria, when validating completed work against those criteria, and when triaging bug reports (Fix Now / Defer / Not a Bug). Owns requirements and final sign-off. |
| 2 | `architect` | 2 / 4 | `claude-opus-4-8` | `xhigh` | Use during /agent-plan after Product publishes a milestone definition, and whenever Coder raises a design question, a new dependency is proposed, or Security/Performance findings require remediation. Owns system design, module boundaries, and data schemas. |
| 3 | `ui` | 4 | `claude-opus-4-8` | `high` | Use during /agent-plan after Product publishes a milestone definition (in parallel with Architecture) to produce screen specs, and at /agent-code milestone completion for the UX review of milestones with UI-flagged tasks. Owns visual design and the style guide. |
| 4 | `security` | 4 | `claude-opus-4-8` | `high` | Use after Architecture publishes or revises a design document, approves a new dependency, or changes a data schema — audits for vulnerabilities and insecure patterns with Critical/High/Medium/Low/Informational findings. |
| 5 | `performance` | 4 | `claude-opus-4-8` | `high` | Use after Architecture publishes or revises a design document — reviews the plan against performance budgets, identifies bottlenecks, and files findings for the CEO gate. |
| 6 | `ceo` | 4 | `claude-opus-4-8` | `high` | Use as the final planning-stage gate once Product, Architecture, UI, Security, and Performance have all completed their milestone outputs — issues APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED before engineering begins. |
| 7 | `coder` | 1 | `claude-opus-4-8` | `xhigh` | Use to implement each task in /agent-code or /agent-task, and whenever a test failure, review change request, Fix Now defect, or Product rejection returns work. Writes all production code, then submits to Tester. |
| 8 | `tester` | 1 | `claude-opus-4-8` | `high` | Use PROACTIVELY after every Coder change — automated test gate. Also runs after every Refactor handoff; tests must pass before Reviewer runs. Failures route back to Coder. |
| 9 | `reviewer` | 1 | `claude-opus-4-8` | `xhigh` | Use after Tester passes on every Coder or Refactor submission — reviews quality, standards compliance, and architecture adherence, classifying findings as Defects (→ Bug Gatherer) or Issues (→ Refactor). No code bypasses review. |
| 10 | `debugger` | 2 / 3 | `claude-opus-4-8` | `xhigh` | Use when Product triages a defect as Fix Now — investigates root cause and appends findings to the existing triaged bug report for Coder or Refactor. Never files new reports. |
| 11 | `refactor` | 3 | `claude-opus-4-8` | `high` | Use when Reviewer classifies a finding as an Issue, or on direct user request for structural cleanup — behavior-preserving restructuring, then hands back to Tester and Reviewer. |
| 12 | `bug-gatherer` | 3 | `claude-opus-4-8` | `low` | Use whenever a defect surfaces — Reviewer defect classifications, Tester failures worth tracking, Security findings, or user reports — files the structured report (status New) for Product triage. Single entry point for all bugs. |
| 13 | `docs-writer` | 2 | `claude-opus-4-8` | `low` | Use only at task- or milestone-completion checkpoints to drain the docs queue in artifacts/STANDUP.md, or on direct user request for documentation updates. Owns docs/ reference material. |
| 14 | `release` | 5 | `claude-opus-4-8` | `low` | Use when the user requests a release after milestone completion — changelog, versioning, and build verification. Not auto-launched by any pipeline. Primary owner of docs/CHANGELOG.md. |
| 15 | `validator` | 5 | `claude-opus-4-8` | `low` | Use at task- and milestone-completion checkpoints (invoked by /agent-code) to record outcomes in artifacts/AGENT_STATE.md, and whenever agents conflict or a process rule needs enforcement. Owns process integrity and milestone retrospectives. |

**How to compare against existing project agents.** When the Phase 1 inventory finds an agent file in the project under any name, match it by **role**, not by filename. Read the Role column in the table above and ask: "Does this existing file do what that role describes?" An existing `planner.md` whose purpose is "defines features and acceptance criteria" maps to `product`. An existing `coordinator.md` whose purpose is "resolves conflicts between roles and tracks milestones" maps to `validator`. An existing `shipper.md` whose purpose is "runs the release cut and updates the changelog" maps to `release`. Use the agent similar-name candidates table below for alias hints, but the description column above is the tiebreaker — the role always wins over the filename.

**One-line summary you can keep in context:** 15 agents, all on `claude-opus-4-8` = 6 planning-tier at effort high/xhigh (product, architect, ui, security, performance, ceo) + 5 engineering-tier at effort high/xhigh (coder, tester, reviewer, debugger, refactor) + 4 utility-tier at effort low (bug-gatherer, docs-writer, release, validator). Every adoption must account for all 15, not just the 13 in Tiers 1–4.

## Pipeline skills mapping

The three CAST pipeline skills are `/agent-plan`, `/agent-code`, `/agent-task`. They install to `.claude/skills/<name>/SKILL.md`. For each, apply this decision:

| State | Action |
|---|---|
| Missing | Create from `<CAST_SOURCE>/skills/<name>/SKILL.md` |
| Exact match at `.claude/skills/<name>/SKILL.md` | Update in place, preserving any custom pre-flight or post-completion steps |
| Pre-1.0 CAST command at `.claude/commands/<name>.md` | **Migrate**: create the skill from the CAST template, merge any preserved custom sections from the old command file, then propose Delete of the old command file (requires approval — keeping both registers a duplicate `/<name>`) |
| Similar name match (e.g., `plan.md`, `implement.md`, `fix.md`) | Rename + Update into the skill location. Keep the custom stages as appendix sections. |
| Matches but with different phase structure | Rename + Update, and explicitly note in the plan which old stages map to which CAST stages |

**Similar-name candidates to look for** (as commands, skills, or loose instruction files):

- `/agent-plan` ← `plan.md`, `planning.md`, `design.md`, `spec.md`, `prd.md`, `requirements.md`, `architect.md`
- `/agent-code` ← `code.md`, `implement.md`, `engineer.md`, `build.md`, `work.md`, `develop.md`, `dev.md`
- `/agent-task` ← `task.md`, `fix.md`, `do.md`, `patch.md`, `tweak.md`, `small.md`, `quick.md`

## Agent similar-name candidates

When scanning for existing agent files that might fill a CAST role under a different name, check these aliases. If a match is found, propose Rename + Update rather than Create. If no match is found, propose Create from the canonical CAST template.

| CAST agent | Common aliases |
|---|---|
| `product` | `product-manager`, `pm`, `planner`, `owner`, `po`, `requirements`, `backlog` |
| `architect` | `architect`, `architecture`, `designer`, `sys-design`, `system-design`, `tech-lead`, `techlead` |
| `ui` | `ui`, `ux`, `designer`, `frontend-designer`, `screens`, `wireframe` |
| `security` | `security`, `secops`, `appsec`, `auditor`, `pentester`, `sec` |
| `performance` | `performance`, `perf`, `profiler`, `optimizer`, `benchmarker` |
| `ceo` | `ceo`, `approver`, `gate`, `signoff`, `reviewer-final`, `exec`, `director` |
| `coder` | `coder`, `implementer`, `engineer`, `developer`, `dev`, `builder`, `worker` |
| `tester` | `tester`, `test`, `qa`, `quality`, `test-writer`, `test-runner` |
| `reviewer` | `reviewer`, `code-reviewer`, `review`, `lint`, `critic` |
| `debugger` | `debugger`, `debug`, `troubleshooter`, `investigator`, `diagnose`, `fix-finder` |
| `refactor` | `refactor`, `refactorer`, `cleaner`, `restructurer`, `tidy` |
| `bug-gatherer` | `bug-gatherer`, `bug-reporter`, `triage`, `bug-filer`, `issue-filer`, `reporter` |
| `docs-writer` | `docs-writer`, `docs`, `documentation`, `writer`, `doc`, `technical-writer`, `tech-writer` |
| `release` | `release`, `release-manager`, `releaser`, `shipper`, `deployer`, `publisher`, `versioner` |
| `validator` | `validator`, `validation`, `process`, `coordinator`, `orchestrator`, `enforcer`, `referee`, `arbiter`, `meta`, `supervisor`, `workflow`, `workflow-validator` |

**Two agents that are frequently missed** during adoption because their CAST role is abstract rather than tied to a concrete artifact:

1. **`validator`** — owns **process integrity, conflict resolution, milestone tracking, and retrospectives**. A project rarely has a file literally named `validator.md`, but the role often exists under names like `coordinator`, `process`, `orchestrator`, `meta`, or "the agent that makes sure everyone follows the rules". If the inventory doesn't find a direct match, **still install validator** as a Create action — do not silently skip it.
2. **`release`** — owns **changelog, versioning, and build verification**. If the project has a `CHANGELOG.md` (anywhere — root, `docs/`, or loose), it almost certainly has an implicit release workflow, even without a dedicated agent file. Install `release` as a Create action in that case and note it will take ownership of the existing changelog going forward.

The Phase 3 final check (the 15-name enumeration above) catches both of these if they slip through the per-role scan.
