# Agent roster, tiers, alias tables, and pipeline-skill mapping

Reference material for Phase 3 (Migration plan). The roster table is the authoritative list every adoption must account for.

## Critical agent requirements

CAST v3 ships **eight** agents. An adoption must account for every one of them.

v2 shipped fifteen. Seven were removed by merging, not by dropping their work — see the v3 CHANGELOG for the full reasoning, and the migration table below for where each one's duties went. When you find a v2 CAST install (or any project with a `tester.md` / `refactor.md` / `debugger.md`), map the role forward rather than preserving the file.

**Tier 1 — Core loop (always required):**

- `product`, `coder`, `reviewer`

**Tier 2 — Strongly recommended for any serious project:**

- `architect`, `docs-writer`

**Tier 3 — Required for the full `/agent-plan` stage:**

- `ui`, `risk`, `ceo`

### Where the v2 agents went

| v2 agent | v3 home | Why |
|---|---|---|
| `tester` | `coder` | It re-read the same task file and the same diff Coder had just written, in order to test it — a second pass by an equally-invested party at full cold-context cost, not an independent check. The gate survives as the verbatim Test Results block Reviewer verifies. |
| `refactor` | `coder` | "Behavior-preserving restructuring" is Coder's own job on a loop-back. |
| `debugger` | `coder` | Two cold contexts on one defect, the second re-deriving the first's context. Root-cause investigation is now a step inside Coder's defect pass. |
| `bug-gatherer` | `reviewer` | It re-read the task to transcribe a finding Reviewer had already written, and its documented workflow ("read the report back to the reporter") was impossible for a subagent. Reviewer holds the finding and writes the bug file. |
| `security` + `performance` | `risk` | Two agents reading the same architecture document in the same round, producing the same document shape and one flag line each. The two lenses stay distinct in the output; the second spawn did not survive. |
| `validator` | `product` + orchestrator | Its bookkeeping (AGENT_STATE rows, archival) is orchestrator file-writing; the retrospective went to Product; its conflict-resolution protocol had time-based triggers ("after 7 days blocked") that could never fire in a pipeline where a milestone runs in one or two sessions. |
| `release` | `/cast-release` skill | Checklist execution against files the session can already read. An agent spawn to run a checklist is a spawn spent on ceremony. |

**`ui` opt-out for backend/CLI-only projects.** The `ui` agent is Tier 3, but it becomes optional when the project is clearly backend/CLI-only with no user interface (the same condition under which `dispositions.md` skips `templates/UI_SPEC.md` and `templates/UX_REVIEW.md`). The opt-out must be explicit: propose it as a Skip in the plan, get the user's confirmation at the Phase 4 gate, and record it in the Phase 7 report. The UI templates are skipped **if and only if** the `ui` agent is skipped — never install one half of the pair (Phase 6 checks this consistency). The installed `/agent-plan` skill skips its UI stage when no `ui` agent is present, so the pipeline stays runnable.

**Default install set: all 8 agents**, `ui` excepted under a recorded opt-out. Do not silently omit any.

**For each missing agent**, the plan must include a Create action. If the user has an existing file that fills the role under a different name, propose Rename + Update. If the fill is ambiguous, mark as Ask and list the candidates. A v2 `tester.md`/`refactor.md`/`debugger.md`/`bug-gatherer.md`/`validator.md`/`security.md`/`performance.md`/`release.md` maps to Delete with its duties folded into the target above — say so in the plan so the user can see nothing was lost.

**Final check before closing the plan:** enumerate all 8 agent names from the table below and verify every one has a Create / Rename+Update / Update-in-place / Preserve action. If any is missing, add the Create action before presenting the plan.

## Canonical CAST agent roster (current release)

Use this table as the authoritative reference when comparing an existing project's agents against CAST. The description column is pulled verbatim from each agent file's YAML frontmatter — match role against role, not name against name. Every agent defaults to `model: inherit` and runs on the session model (the Claude Opus family is the optimized target — `claude-opus-5` preferred, with `claude-opus-4-8`, `claude-opus-4-7`, and `claude-opus-4-6` supported; see `docs/MODEL_OPTIMIZATION.md`); the Effort column is the recommended reasoning effort from each agent's Model Configuration section. Override per-agent only when the user has a reason.

| # | Agent | Tier | Model | Effort | Role (from agent frontmatter) |
|---|---|---|---|---|---|
| 1 | `product` | 1 | `inherit` | `high` / `low` | Use to define milestone scope and write the task files at /agent-plan Stage 1, to triage filed bugs, to validate tasks Reviewer's criteria check flagged, to dispose of task-amendment proposals, and at milestone completion to re-triage Deferred items and write the milestone close record in one pass. |
| 2 | `architect` | 2 | `inherit` | `high` | Use at /agent-plan Stage 2a to produce the milestone architecture document — module boundaries, data schemas, cross-module contracts, data flows, and the performance budget — and to return the Context Manifest rows each task needs. Re-run when the CEO returns REVISION REQUIRED naming Architecture. |
| 3 | `ui` | 3 | `inherit` | `high` | Use at /agent-plan Stage 2b to produce the milestone UI specification — layouts, interaction states, accessibility — and to return the Context Manifest rows each UI-flagged task needs. Also performs the milestone UX review at /agent-code completion for milestones containing UI-flagged tasks. |
| 4 | `risk` | 3 | `inherit` | `high` | Use as the /agent-plan Stage 3 review of an architecture — examines it through the security lens and the performance lens in one pass, files findings with severity and remediation, and sets the two flags that decide whether implementation reviews run at milestone completion. Also runs those implementation reviews. |
| 5 | `ceo` | 3 | `inherit` | `high` | Use as the final planning-stage gate once Product, Architecture, UI, and Risk have completed their milestone outputs — issues APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED before engineering begins. |
| 6 | `coder` | 1 | `inherit` | `medium` | Use to implement each task in /agent-code or /agent-task — writes production code, writes and runs its tests, and commits. Also handles every loop-back: Fix Now defects (investigating root cause first when the mechanism is not obvious), Reviewer Issues (behavior-preserving restructuring), and Product criteria rejections. |
| 7 | `reviewer` | 1 | `inherit` | `high` | Use after every Coder handoff — the independent gate. Verifies the test-results block, reviews the diff for quality, standards, and architecture adherence, classifies findings as Defects (filing each as a bug file) or Issues (back to Coder), and on approval records the per-criterion Acceptance Criteria Check. No code bypasses review. |
| 8 | `docs-writer` | 2 | `inherit` | `low` | Use at the milestone-completion checkpoint, at an overflow drain when the docs queue passes its bound, at the /agent-task completion checkpoint, or on direct user request — drains the docs queue in artifacts/STANDUP.md. Owns docs/ reference material. |

**How to compare against existing project agents.** When the Phase 1 inventory finds an agent file in the project under any name, match it by **role**, not by filename. Read the Role column in the table above and ask: "Does this existing file do what that role describes?" An existing `planner.md` whose purpose is "defines features and acceptance criteria" maps to `product`. An existing `coordinator.md` whose purpose is "resolves conflicts between roles and tracks milestones" has no v3 agent — its duties belong to the orchestrating skill and to `product`; propose Delete with the duties named. An existing `shipper.md` whose purpose is "runs the release cut and updates the changelog" maps to the `/cast-release` skill, not to an agent. Use the agent similar-name candidates table below for alias hints, but the description column above is the tiebreaker — the role always wins over the filename.

**One-line summary you can keep in context:** 8 agents, all on `model: inherit` (the session model) = 5 planning-tier at effort `high` (product, architect, ui, risk, ceo) + 2 loop agents (coder at `medium`, reviewer at `high`) + 1 utility at `low` (docs-writer). Every adoption must account for all 8.

**Right-sizing models (cost optimization).** `model: inherit` is the safe default, but each agent's `model:` line can be pinned independently. Note the ordering: **spawn count dominates both model tier and effort** — a stage you don't launch costs nothing, and each distinct agent type is its own prompt-cache prefix. v3's roster is already right-sized in that dimension; the table below is the second-order lever. Every Phase 3 plan must include an Ask item proposing a right-sized assignment for the user to accept, adjust, or decline. A sensible starting split:

| Workload | Agents | Suggested model |
|---|---|---|
| Judgment-heavy gates and design | `ceo`, `architect`, `reviewer`, `risk` | The most capable model available — e.g. `opus` (or a Fable/Mythos-class model if the account serves one) |
| Planning and implementation | `product`, `ui`, `coder` | `sonnet` — strong coding and spec writing at a fraction of the cost |
| Structured utility work | `docs-writer` | `sonnet` — the cheapest tier that still clears the Context Inference Bar (see caution below) |

Claude Code accepts the `opus` / `sonnet` / `haiku` aliases or full model IDs in agent frontmatter. Record accepted assignments in the plan as part of each agent's Create/Update action; any agent the user leaves undecided keeps `inherit`.

**Caution — a Haiku pin interacts with `/cast-doctor`'s doc audit.** The doctor computes each doc's Tier-B prune eligibility against its **weakest consumer**: a section may be deleted only when every model that reads it can infer the content from the codebase. `docs-writer` cites `docs/FILE_CONVENTIONS.md` and `docs/README.md`, so pinning it to a model below the Inference Bar (Haiku-class) permanently blocks Tier-B prunes on those docs — a per-spawn saving that forfeits a larger always-on saving. Pin utility roles no lower than a Sonnet-class model unless the project has decided against doc pruning.

## Pipeline skills mapping

The five CAST skills are the three pipelines `/agent-plan`, `/agent-code`, `/agent-task`, plus two maintenance skills: `/cast-doctor` (install health checks and model-aware documentation audits) and `/cast-release` (release preparation — this was the `release` agent in v2). Both maintenance skills install unconditionally, with no agent-tier coupling. They install to `.claude/skills/<name>/SKILL.md`. For each, apply this decision:

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
- `/cast-doctor` ← `doctor.md`, `health.md`, `audit.md`, `doc-audit.md`
- `/cast-release` ← `release.md`, `ship.md`, `publish.md`, `cut-release.md`, or a v2 CAST `agents/release.md`

## Agent similar-name candidates

When scanning for existing agent files that might fill a CAST role under a different name, check these aliases. If a match is found, propose Rename + Update rather than Create. If no match is found, propose Create from the canonical CAST template.

| CAST agent | Common aliases |
|---|---|
| `product` | `product-manager`, `pm`, `planner`, `owner`, `po`, `requirements`, `backlog` |
| `architect` | `architect`, `architecture`, `designer`, `sys-design`, `system-design`, `tech-lead`, `techlead` |
| `ui` | `ui`, `ux`, `designer`, `frontend-designer`, `screens`, `wireframe` |
| `risk` | `risk`, `security`, `secops`, `appsec`, `auditor`, `pentester`, `sec`, `performance`, `perf`, `profiler`, `optimizer`, `benchmarker` |
| `ceo` | `ceo`, `approver`, `gate`, `signoff`, `reviewer-final`, `exec`, `director` |
| `coder` | `coder`, `implementer`, `engineer`, `developer`, `dev`, `builder`, `worker`, `tester`, `test`, `qa`, `refactor`, `refactorer`, `debugger`, `debug`, `troubleshooter` |
| `reviewer` | `reviewer`, `code-reviewer`, `review`, `lint`, `critic`, `bug-gatherer`, `bug-reporter`, `triage`, `issue-filer` |
| `docs-writer` | `docs-writer`, `docs`, `documentation`, `writer`, `doc`, `technical-writer`, `tech-writer` |

Aliases that map to **no v3 agent** — propose Delete and name where the duties went (see "Where the v2 agents went" above): `validator`, `validation`, `process`, `coordinator`, `orchestrator`, `enforcer`, `referee`, `arbiter`, `meta`, `supervisor`, `workflow` → the orchestrating skill and `product`. `release`, `release-manager`, `releaser`, `shipper`, `deployer`, `publisher`, `versioner` → the `/cast-release` skill.

**The role most often missed** during adoption is `risk`, because a project rarely has one file covering both security and performance. If the inventory finds a `security.md` **or** a `performance.md` **or** neither, still install `risk` as a single Create action — and when it finds both, propose Rename+Update of one into `risk` and Delete of the other, folding its content in. Installing two half-agents is the failure mode here.

The Phase 3 final check (the 8-name enumeration above) catches anything that slips through the per-role scan.
