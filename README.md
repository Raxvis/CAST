<!-- TEMPLATE INSTRUCTIONS
  This file is the master index for the CAST repo. It describes the purpose,
  structure, placeholder conventions, and file inventory for every template file
  in this repository. It is never installed into target projects — adoption is
  performed by the /cast-init skill, which substitutes [PLACEHOLDER_NAME] tokens
  and strips TEMPLATE INSTRUCTIONS blocks from the files it installs.
-->

# CAST — Claude Agent Staged Team

> **A portable multi-agent team for Claude Code.** Seven specialist subagents, three pipeline skills plus intake and maintenance skills, and a CEO-gated planning pipeline — shipped as plain Markdown via a single `/cast-init` skill. CAST installs **no documentation**: you bring your own standards and docs, a source map points the pipelines at them, and planning distills what applies into plans complete enough that engineering never reads your docs at all.

![Template version](https://img.shields.io/badge/template-v4.0.0-blue)
![Claude Code](https://img.shields.io/badge/Claude_Code-required-9cf)
![Agents](https://img.shields.io/badge/agents-7-orange)

CAST gives you a real team structure with clear handoffs, typed artifacts, and a review gate you can't accidentally skip — and it plugs into the documentation system you already have instead of imposing one. The name is a double pun: a *cast* is a group of specialists each playing a defined role, and the pipeline runs in *stages* — planning (Product → Architecture + UI → CEO risk-lens review and sign-off) followed by engineering (Coder → Reviewer, with defect and issue routing).

```text
Planning stage — /agent-plan

    feature request        .claude/cast/SOURCES.md — the source map:
          │                YOUR requirements, standards, architecture
          │                docs, wherever you keep them
          ▼                          │  (planning reads the sources and
          │  ◄───────────────────────┘   distills them into the plan)
          ▼
    Product  →  Architecture + UI  →  CEO (risk lenses + verdict)
                                                                      │
                                                                      ▼
                                                         APPROVED (with conditions)


Engineering stage — /agent-code

    Coder  →  Reviewer  ──┬──  Defect  →  Reviewer files the bug  →  Product triage  →  Coder
    (implement,           │             (straight to Coder when it violates a criterion —
     test, commit)        │              Defer is forbidden there, so no triage question)
                          └──  Issue   →  Coder (loop)
                                                                      │
                                                                      ▼
                                          Reviewer's criteria check: all Met?
                                            yes → orchestrator closes the task
                                            no  → Product validates
                                                                      │
                                                                      ▼
                                          task checkpoint: no agents — Status writeback
                                          (+ docs drain only past 10 pending entries)
                                                                      │
                                             ... every task Complete or Deferred? ...
                                                                      ▼
                                          milestone checkpoint:
                                          →  UX review (UI, UI-flagged milestones only)
                                          →  risk implementation review (CEO, if flagged)
                                          →  milestone close — one Product launch
                                             (Deferred re-triage + close record + CEO
                                              conditions + Status)
                                          →  docs drain (Docs Writer, if entries pending)
                                          →  orchestrator records + archives


One-off task — /agent-task  (no planning stage, for small self-contained changes)

    Coder  →  Reviewer  →  validation   (same Defect / Issue routing;
                                         Product only when the criteria check flags one)
```

**What you get out of the box:**

- **7 specialist subagents** defaulting to `model: inherit` — each runs on the session model — with effort enforced per role by frontmatter (`high` on the planning stages and the review gate, `medium` on implementation, `low` on utility). Every role that earned its own cold context has one; the eight v2 roles that did not were merged into the stages that already held their context, with every gate they enforced preserved.
- **Three pipeline skills** — `/agent-plan`, `/agent-code`, `/agent-task` — as plain Markdown orchestration scripts Claude Code discovers at session start, plus two intake skills — **`/file-bug`** (file a user-found bug as its own tracked report) and **`/add-task`** (queue a one-off task in the `artifacts/TASKS.md` backlog, drained by `/agent-task backlog` and reviewed for adoption at `/agent-plan` Stage 1) — and two maintenance skills: **`/cast-doctor`** (install health check and source-map verification) and **`/cast-release`** (gate verification, versioning, changelog via your Project Registers, GO/NO-GO).
- **Bring-your-own documentation.** `/cast-init` interviews you about where your requirements, standards, architecture docs, testing guidance, documentation home, and registers live, and writes the **source map** (`.claude/cast/SOURCES.md`). Planning reads your sources and distills what applies into each milestone's own artifacts — including a **Standards Digest** of the concrete rules that bind the work, each cited back to its source. Engineering reads only the plan; Docs Writer writes documentation updates back to *your* documentation home. Nothing of yours is moved, and nothing CAST-shaped lands in your docs.
- **A tiny install footprint** — `.claude/` (agents, skills, and the `cast/` machinery: source map, two process contracts, ten document templates) plus `artifacts/` for work output **grouped by milestone**: one directory per milestone containing its README, design docs, reviews, one file per task, and one file per bug. Your `CLAUDE.md` gains exactly one appended section.
- **Minimal-context handoffs** — every task is an isolated file carrying its own Context Manifest (the complete read set an agent needs) and Handoff Log (the capped, fixed-format record each stage appends). Agents ship the next agent the least context required, through the task file — never through conversation or whole-directory re-reads — and reply to the orchestrator with a single routing line, so the orchestrating context stays flat across a whole milestone.
- **Parallel task execution** — `/agent-code` runs engineering loops for independent tasks concurrently (disjoint dependencies and file lists, up to 3 at a time), with all shared-state writes serialized by the orchestrator. Task isolation is what makes this safe.
- **Toolset-enforced discipline** — every agent's frontmatter declares an explicit `tools:` list that omits the Task tool, so "agents don't spawn subagents" is a hard guarantee, not a request.
- **A fully populated `example/` fixture** so you can see exactly what a real planning run produces — including a source map pointing at the example project's own docs.

Current template version: `v4.0.0` — see [`CHANGELOG.md`](CHANGELOG.md) for the version history and migration notes.

---

## Install

CAST is distributed as a single skill, `cast-init`, installable two ways. Both routes deliver the same `/cast-init` skill; pick whichever fits your tooling.

**Route A — the `skills` CLI:**

```bash
cd /path/to/your-project
npx skills add Raxvis/CAST        # installs the cast-init skill into .claude/skills/
```

(Add `-g` to install globally for all projects instead.)

**Route B — the Claude Code plugin marketplace:**

```
/plugin marketplace add Raxvis/CAST
/plugin install cast@cast
```

> **Note on plugin-route footprint:** the plugin manifest points at the repo root, so a plugin install copies the entire repository — including `example/`, `CHANGELOG.md`, and `.github/` — into your local plugin cache. This is harmless (none of it is installed into your project; `/cast-init` only ever writes the payload under `skills/cast-init/assets/`), just a few hundred kilobytes of extra cache. The `npx skills` route fetches only the `cast-init` skill directory.

**Then run the adoption.** Open Claude Code inside your project (restart the session if it was already open so the skill is discovered) and invoke:

```
/cast-init
```

The skill reads all template files from its bundled payload — no network access to GitHub is required during execution. It will:

1. **Crawl your project** — detect tech stack, existing agents, customizations, and where your documentation and standards actually live (the source-map candidates).
2. **Propose a migration plan** — numbered list of every file it will create, rename, update, or skip, plus the source-map interview: confirm or correct the documentation locations it found, category by category.
3. **Wait for your approval** — nothing is touched until you explicitly approve.
4. **Execute the plan** — install agents, pipeline skills, the `.claude/cast/` machinery, and the artifacts scaffold, substituting detected project values and writing the source map from your interview answers.
5. **Validate** — verify all 7 agents exist, every source-map entry resolves, and YAML frontmatter is valid.

This works for greenfield projects, existing projects with no agentic workflow, and existing projects with a mature agentic workflow you want to migrate to CAST.

### Deterministic install (no LLM required)

File placement in v4 is fixed by rule — agents to `.claude/agents/`, skills to `.claude/skills/`, the machinery and templates to `.claude/cast/`, the scaffold to `artifacts/` — so the copy itself is a script, and `/cast-init` runs that script rather than deciding placement per file. You can also run it directly for a fully deterministic fresh install:

```bash
bash .claude/skills/cast-init/scripts/install.sh \
  --project-name "Acme Dashboard" --test-cmd "npm test" --build-cmd "npm run build"
```

It substitutes the install-time tokens, strips the repo-documentation comment blocks (template skeletons excepted), **never overwrites an existing file** (each is skipped and reported; `--force` to replace), supports `--no-ui` for the backend/CLI opt-out and `--dry-run` to preview, and tells you what is left to do — chiefly filling in `.claude/cast/SOURCES.md`, the source map. Run `/cast-init` afterwards if you'd rather be interviewed for the source map than write it by hand; the skill detects the installed files, skips them, and conducts only the judgment work (discovery, the interview, migrations of pre-v4 installs, merges of customized files).

The installer also writes `.claude/cast/install-manifest.txt` — the per-file hashes of exactly what it installed plus your substitution values — which is what makes **future upgrades script-only**: `install.sh --upgrade` replaces CAST files you never modified, adds new ones, removes obsolete unmodified ones, and refreshes the CLAUDE.md CAST section and version stamp, while anything you customized is kept and reported for `/cast-init` to merge. Nothing you wrote is ever overwritten or deleted — the script only replaces bytes it itself installed.

**Next steps after adoption:**

1. Restart the session so the installed agents and pipeline skills register.
2. Confirm the seven skills tab-complete (`/agent`, `/file`, `/add`, `/cast`) and `/agents` lists the roster, then try `/agent-task` on something trivial or `/agent-plan` on a real feature.
3. Commit the populated template as your first commit.

### Keeping CAST up to date

Keep the cast-init skill installed after adoption — it is also the upgrade mechanism, and from v4 on upgrades are **script-only**:

1. `npx skills update` refreshes the skill to the latest content of this repo (updates are content-hash based, not semver). Plugin installs use `/plugin marketplace update` instead.
2. `bash .claude/skills/cast-init/scripts/install.sh --upgrade` — deterministic, no LLM: guided by the install manifest, it replaces only byte-unmodified CAST files, adds new ones, removes obsolete unmodified ones, and updates the version stamp. Files you customized are kept and listed; run `/cast-init` only when that list is non-empty (it merges CAST's changes into your customized files) or when upgrading a **pre-v4 install** — that one-time v3→v4 migration is `/cast-init`'s job, and it ends by writing the manifest, so it is the last LLM-driven upgrade the project needs.

Two operational notes about the `npx skills` route:

- It writes a **`skills-lock.json`** at your project root recording the skill's source and content hash. Commit it — it is designed for deterministic team installs (a teammate runs `npx skills add` and gets the same revision).
- By default the skill is installed as a **symlink**: the real copy lives in `.agents/skills/cast-init` and `.claude/skills/cast-init` points at it. Pass `--copy` to `npx skills add` if you prefer a real copy (e.g. your tooling doesn't follow symlinks).

---

## Directory Structure

```
CAST/
  README.md              # This file — master index and usage guide
  .claude-plugin/        # Plugin + marketplace manifests (the /plugin install route)
  skills/
    cast-init/
      SKILL.md           # The /cast-init adoption workflow — replaces the old PROMPT.md
      references/        # Detailed phase docs (discovery, roster, dispositions, execution, validation)
      assets/            # The installable payload:
        root/            #   The CLAUDE.md CAST section (appended to the user's file)
        agents/          #   Agent role definitions (installed to .claude/agents/)
        skills/          #   Pipeline skills (installed to .claude/skills/)
        cast/            #   CAST machinery (installed to .claude/cast/): the SOURCES.md
                         #     source-map template, the two process contracts, and
                         #     templates/ — document templates instantiated into artifacts/
        artifacts/       #   Work artifact scaffold: agent state, bug index, task backlog
  example/               # Populated fixture: a full "Acme Todo" project walkthrough
```

### Bring your own documentation

v4's organizing idea: **your documentation is yours, `.claude/cast/` is CAST's machinery, `artifacts/` is work.**

- **Your documentation stays wherever you keep it** — a `docs/` directory, CONTRIBUTING.md, ADRs, an exported wiki. The source map (`.claude/cast/SOURCES.md`) records the locations by category: Standards & Conventions, Product & Requirements, Architecture & Design, Testing & Quality, Documentation Home (where Docs Writer writes updates), and Project Registers (your changelog). Categories can honestly be empty — the pipelines then plan from code inspection and say so.
- **Planning reads sources; engineering reads plans.** `/agent-plan` resolves the source map, the planning stages read what applies, and everything engineering needs lands in the milestone's own artifacts — the Standards Digest in the milestone README, constraints in the architecture document, criteria in the task files. Coder and Reviewer never open your docs; a digest gap is a planning defect to fix in the plan, not a license to browse.
- **`artifacts/` is work artifacts only, grouped by milestone.** Each `milestone-{N}-{slug}/` directory holds everything one milestone produces: its README (definition + Standards Digest), architecture and UI specs, reviews, per-task files, and per-bug files. Cross-milestone state (bug index, task backlog, session log, agent state) lives at the root; `/agent-task` work lives under `one-off/`.

Both pipelines write exclusively to `artifacts/`; only Docs Writer ever writes into your documentation, and only at the Documentation Home you declared.

All the payload directories described below live under `skills/cast-init/assets/` in this repo; the headings use their short names because that is where they land in a target project.

### skills/cast-init/

The `/cast-init` skill itself: `SKILL.md` carries the seven-phase adoption workflow (discovery → classification → migration plan → approval gate → execution → validation → report), `references/` holds the detailed phase documentation it loads on demand, and `assets/` holds the entire installable payload described below.

### root/

Contains the CAST section that `/cast-init` appends to your `CLAUDE.md` (or writes as a minimal `CLAUDE.md` when none exists): the workflow summary, the source-map pointer, the artifacts conventions, and the version stamp. The rest of `CLAUDE.md` is yours — v4 never owns it.

### agents/

Each file defines one agent role with YAML frontmatter for Claude Code auto-discovery. When installed to `.claude/agents/` in the target project, Claude Code automatically registers them as subagents that can be invoked by name or delegated to automatically based on task type. Files that do not apply to your project type can be deleted without affecting the others.

### skills/ (pipeline skills)

Each subdirectory defines one pipeline skill that orchestrates a multi-agent workflow stage end-to-end. When installed to `.claude/skills/` in the target project, Claude Code registers them as skills named after the directory (e.g. `agent-plan/SKILL.md` becomes `/agent-plan`). Three pipelines ship with this template, plus two intake skills — `/file-bug` (file a user-found bug as its own tracked report: per-bug file plus `artifacts/BUGS.md` index row) and `/add-task` (queue a one-off task in the `artifacts/TASKS.md` backlog; `/agent-task backlog` drains the queue and `/agent-plan` Stage 1 adopts relevant entries into the milestone it plans) — and two maintenance skills — `/cast-doctor` (install health check and source-map verification) and `/cast-release` (release gates, versioning, changelog via the source map's Project Registers): `/agent-plan` runs the Planning Stage (Product → Architecture + UI → CEO), `/agent-code` runs the Engineering Stage (Coder → Reviewer, with Defects routed through Product triage and Issues back to Coder — a clean task is two spawns), and `/agent-task` runs a mini engineering pipeline (Coder → Reviewer → validation) for a single one-off task without requiring a milestone, planning artifacts, or a CEO verdict — use it for bug fixes, typos, small refactors, and dependency bumps, not for new modules or cross-cutting changes. Between the two, `/agent-plan light: <feature>` runs a light planning mode (Product + Architecture + CEO) for a small feature that needs a few design decisions without full milestone ceremony — it also engages automatically when Stage 1 scoping finds 3 tasks or fewer with no new screen set, no security-sensitive scope, no applicable performance budget, and nothing cross-cutting.

### cast/ (→ `.claude/cast/`)

CAST's machinery, installed inside `.claude/` so nothing CAST-shaped lands in your source tree:

- **`SOURCES.md`** — the source-map template. `/cast-init` fills it from your interview answers; you edit it by hand whenever your documentation moves, and `/cast-doctor` verifies every entry still resolves. This one file is what makes the agent team portable: point it at whatever documentation system you already have.
- **`PIPELINE_LOOP.md`** — the canonical engineering-loop contract (per-task sequence, Defect/Issue routing, loop counters, test gate), read by the orchestrating skills only.
- **`STAGE_CONTRACT.md`** — the one process document agents read: the closed read set, the handoff-entry format, and the one-line reply.
- **`templates/`** — the ten reusable document skeletons agents copy into `artifacts/` as instances (never filled in place).

### artifacts/

Work artifacts produced by the agents during `/agent-plan` and `/agent-code`, grouped by milestone: each milestone directory holds its definition README (with the Standards Digest), architecture and UI specifications, reviews, per-task files, and per-bug files. Cross-milestone state (bug index, task backlog, session log, agent state) lives at the artifacts root. See `artifacts/README.md` for the full directory structure.

---

## Placeholders

Project-specific content is marked with `[UPPER_SNAKE_CASE]` tokens. v4's install-time set is deliberately tiny — project context reaches the agents through your own `CLAUDE.md` and the source map, not through baked-in tokens. The `/cast-init` skill detects the values and substitutes them during install; the skill also strips the `<!-- TEMPLATE INSTRUCTIONS -->` comment blocks (repo documentation) from every file it installs — only the `.claude/cast/templates/` skeletons keep theirs, since those blocks instruct the agents that instantiate them.

**Install-time tokens** (substituted by `/cast-init`):

| Placeholder | Description | Example value |
|---|---|---|
| `[PROJECT_NAME]` | Human-readable name of the project | Acme Dashboard |
| `[TEST_CMD]` | Command to execute the full test suite | the project's test command |
| `[BUILD_CMD]` | Command to produce a production build artifact (used by `/cast-release`) | the project's build command |
| `[MAX_LOOP_COUNT]` | Maximum Defect/Issue loop iterations in the engineering pipeline before escalating to the user | 3 |
| `[VERSIONING_SCHEME]` | The project's versioning scheme (used by `/cast-release`) | semantic versioning |
| `[CAST_VERSION]` | CAST template version stamped into the installed `CLAUDE.md` (`Adopted with CAST v[CAST_VERSION]`). Auto-filled by `/cast-init` from its own version — never fill by hand | 4.0.0 |

**Per-use tokens**: the `.claude/cast/templates/` skeletons (and a few example cells in the artifacts scaffold) carry fill-in-per-use tokens like `[MILESTONE_NAME]`, `[TASK_NAME]`, `[PLATFORM_LIST]`, and `[DATE]`. Agents fill these each time they instantiate a template — they are never substituted at install and are not bugs in your customization.

---

## Prerequisites

Before installing, confirm the following:

- **Claude Code CLI installed and authenticated.** This template is built for Claude Code specifically. The pipeline skills (`/agent-plan`, `/agent-code`) and subagent auto-discovery rely on Claude Code's `.claude/skills/` and `.claude/agents/` conventions. Other AI coding assistants do not read these files. Install and sign in to Claude Code before continuing.
- **A target project directory.** Either a new empty git repo or an existing project where you want to introduce the agent workflow. The template does not create the project for you.
- **An Anthropic account with access to the Claude Opus family.** All agents default to `model: inherit` and run on the session model; the Opus family is the optimized target (`claude-opus-5` preferred; `claude-opus-4-8`, `claude-opus-4-7`, and `claude-opus-4-6` are supported — all four share the same standard API pricing, though Opus 5's optional fast mode is priced separately and Opus 5 has its own rate-limit bucket). You can set the `model:` line in an individual agent file if you need an explicit pin; each pipeline skill's Model Compatibility section carries the per-model orchestration notes.

## Known Limitations

A common source of confusion: this repo is a **template**, not a framework. Setting expectations clearly up front:

- **Agents are role definitions, not running processes.** The files in `agents/` describe what each agent is responsible for, what it accepts as input, and what it produces as output. Claude Code reads them as subagent definitions. There is no background daemon, no queue, and no automatic dispatching beyond what Claude Code itself does.
- **The pipeline skills are orchestration scripts written in Markdown.** `/agent-plan` and `/agent-code` tell Claude Code to invoke a specific sequence of subagents. They are not compiled, not executable, and not testable outside Claude Code. Reading them is reading their full behavior.
- **The workflow is Claude Code-specific.** Copilot CLI, Gemini CLI, Cursor, and other AI tools do not honor `.claude/agents/`. Porting the template to another tool requires manual adaptation — read each agent file as a prompt and invoke it however that tool supports role prompts. (The `SKILL.md` format itself is portable across a growing set of agents, but the subagent roster and orchestration are Claude Code conventions.)
- **No code is written by installing this template.** You get a directory layout, agent role files, pipeline skill definitions, document templates, and empty work-artifact scaffolding. Your first real output appears after you run `/agent-plan` on a feature.
- **Templates contain nested placeholders.** Some files (bug report forms, milestone close records) include their own fill-in-per-use placeholders like `[DATE]`, `[MILESTONE_NAME]`, `[TASK_NAME]`. These are not bugs in your customization — they are deliberate sub-templates filled in each time the form is used.

Common problems you may hit during adoption or first use — a pipeline skill not recognized, subagent not delegating, `features/` references after upgrade, CEO returning REVISION REQUIRED — are covered in [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md). Skim it before filing a new issue.

## What a populated project looks like

Before installing, browse [`example/`](example/) to see exactly what a real populated instance of this template looks like. The example is a fixture based on "Acme Todo" — a small TypeScript CLI todo tracker — with one milestone planned and implemented end-to-end through `/agent-plan` and `/agent-code`. It shows:

- A `CLAUDE.md` that is the user's own file with the appended CAST section ([`example/CLAUDE.md`](example/CLAUDE.md))
- The project's **own** documentation — a PRD, concept, and glossary that predate CAST ([`example/docs/`](example/docs/)) — and the source map pointing at it ([`example/.claude/cast/SOURCES.md`](example/.claude/cast/SOURCES.md))
- A complete planning run for Milestone 1, grouped in one milestone directory: milestone README (Standards Digest distilled from the example's own docs, with citations), five per-task files with Context Manifests and Handoff Logs, architecture document, UI spec, one risk review (`reviews/risk.md`), and CEO verdict ([`example/artifacts/`](example/artifacts/))
- The full engineering wrap-up for that milestone: the milestone close record (`reviews/close.md`, covering per-task validation, milestone validation, and the retrospective), the UX review, and the risk implementation review
- An active bug tracker with one fixed bug and one Deferred (held-open) bug, and a session log following the canonical `STANDUP.md` entry grammar

The example includes `.claude/cast/SOURCES.md` (the interesting installed file — it is per-project) but deliberately omits the rest of `.claude/` (those files are unchanged copies of the template agents, skills, contracts, and templates) and `src/` (this is a planning fixture, not a real build). The start-here file is [`example/README.md`](example/README.md).

---

## Using with Claude Code

### Session Initialization

`CLAUDE.md` is automatically loaded from the project root at every session start. It provides the baseline context (project identity, build commands, conventions) that all agents need. Agent files in `.claude/agents/` are auto-discovered as subagents — no manual loading required.

### Agent Invocation

With agent files in `.claude/agents/`, Claude Code can invoke them in three ways:

1. **Automatic delegation** — Claude routes tasks to the matching subagent based on the `description` field in each agent's YAML frontmatter (e.g., asking "review this code" automatically delegates to the reviewer agent).
2. **Explicit request** — Ask Claude directly: "Use the coder agent to implement this feature" or "Have the ceo agent run its risk lenses over this module."
3. **Management** — Use the `/agents` command to view, create, and manage all available subagents.

### Agent Reference by Task Type

| Task | Agent |
|---|---|
| Define or update requirements | `product` |
| Design system architecture | `architect` |
| Design UI screens or components | `ui` |
| Audit for security or performance risk | `ceo` (risk lenses) |
| Final planning-stage review and sign-off | `ceo` |
| Implement features or fixes | `coder` |
| Write or run tests | `coder` (Coder writes and runs the tests for what it implements) |
| Review code quality | `reviewer` |
| Investigate a bug | `coder` |
| Refactor code structure | `coder` (behavior-preserving restructuring is a Coder loop-back) |
| File a bug report | `reviewer` (in-pipeline findings) / `/file-bug` skill (user-found bugs) |
| Queue a small task for later | `/add-task` skill (not an agent) |
| Update documentation | `docs-writer` |
| Prepare a release | `/cast-release` skill (not an agent) |


### Pipeline Skills

| Skill | Purpose |
|---|---|
| `/agent-plan <feature>` | Run the Planning Stage end-to-end. Product → Architecture + UI → CEO (risk lenses + verdict). Produces planning documents and a CEO verdict. No code is written. **Light mode** (`/agent-plan light: <feature>`, or `single:` for the one-task case) plans a small feature with Product + Architecture + CEO only — same milestone layout, minimal ceremony. It also engages automatically when Stage 1 scoping finds 3 tasks or fewer, no new screen set, no security-sensitive scope, no applicable performance budget, and nothing cross-cutting; any one of those failing means the full run, and the per-task flags still pull a skipped stage back in. |
| `/agent-code <milestone-or-task>` | Run the Engineering Stage for a CEO-approved milestone. Coder (implement, test, commit) → Reviewer, with Defects filed by Reviewer and routed through Product triage, and Issues routed back to Coder — then validation. A clean task is two spawns. Reviewer's per-criterion Acceptance Criteria Check decides validation: every criterion (and CEO Approval Condition line) Met with evidence and the orchestrator closes the task with no agent launch — flipping any resolved bug Verified → Closed itself; a flagged criterion or condition line, or a mid-task amendment, launches Product. The task checkpoint launches no agents — just the Status writeback, plus a `docs`-queue drain only once 10 entries are pending. When every task is Complete or Deferred, the milestone checkpoint runs the UX review (UI-flagged milestones), the risk implementation review (flagged milestones), one Product launch that closes the milestone (Deferred re-triage, the close record covering every task, CEO Approval Condition verification, Status), the `docs` drain (when entries are pending), and the orchestrator's outcome records and archival. |
| `/agent-task <task description>` | Run a mini engineering pipeline for a single one-off task without requiring a milestone or CEO verdict. Coder → Reviewer, with the same Defect/Issue routing as `/agent-code`. Also drains the `/add-task` queue: `/agent-task TASK-XXX` runs one `artifacts/TASKS.md` entry, `/agent-task backlog` runs every open entry in sequence. Use for bug fixes, typos, small refactors, and dependency bumps — NOT for new modules or cross-cutting changes (it bails out to `/agent-plan`, whose light mode covers the small-feature middle ground). |
| `/file-bug <bug description>` | File a user-found bug as its own tracked report: one instance of `.claude/cast/templates/BUG_REPORT.md` under `artifacts/one-off/bugs/` plus an `artifacts/BUGS.md` index row, Status New. Runs in-session, launches no agents, fixes nothing — fix later via `/agent-task "Fix BUG-XXX"`, an `/add-task` entry, or adoption at the next `/agent-plan` Stage 1, which reviews open user-filed bugs. |
| `/add-task <task description>` | Queue a small, self-contained task as an entry in the `artifacts/TASKS.md` backlog without running anything. Runs in-session and launches no agents; screens scope and routes planning-tier work to `/agent-plan` instead of queueing it. Drain the queue with `/agent-task` (per entry or `backlog` mode); `/agent-plan` Stage 1 adopts open entries relevant to the milestone it plans. |
| `/cast-doctor` (or `/cast-doctor checkup`) | Run a health check on the CAST install: verify structural and state invariants, verify the source map still resolves and matches the project's documentation reality, and find coverage gaps. Writes `artifacts/DOCTOR.md`; treats only user-approved prescriptions. Run after documentation moves, model changes, or every few milestones. |

### Inter-Agent Handoff

Agents communicate through shared documents. When one agent completes work, the next agent reads the updated files:

- **`.claude/cast/SOURCES.md`** is the source map — where this project's own documentation, standards, and registers live. `/agent-plan` resolves it before Stage 1 and passes each stage the sources it needs; `/agent-task` Pre-Flight reads it for one-off work; `/cast-release` reads its Project Registers; Docs Writer writes to its Documentation Home. Engineering stages never open it.
- **`artifacts/AGENT_STATE.md`** holds the cross-milestone record that is not a task file: the Decisions Log, milestone progress, the live performance-budget table, and open questions. **No agent reads it** — the orchestrating skill writes it at checkpoints. In v2 it was 506 lines of per-agent tables that every agent was told to read on activation, which contradicted the read-set rule the pipeline is built on.
- **`.claude/cast/PIPELINE_LOOP.md`** is the canonical engineering-loop contract (per-task sequence, Defect/Issue routing, loop-counter and test-gate rules) that both `/agent-code` and `/agent-task` execute.
- **`artifacts/STANDUP.md`** is the rolling session log with one canonical Entry Grammar: each run opens a `### YYYY-MM-DD — <skill> — <milestone/task>` session heading, and every entry under it is a `- <agent> | <type> | <note>` line. Any agent with documentation fallout appends a `- <agent> | docs | <note>` entry; Docs Writer drains those entries (marking them ✅) at the milestone-completion checkpoint, at an overflow drain once 10 are pending, and at the `/agent-task` completion checkpoint.
- **`artifacts/BUGS.md`** is the global bug index — every bug lives in its own file beside the work that surfaced it (`milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md`), with one status line in the index (Reviewer files, Product triages, Coder investigates and fixes). Deferred is a held-open state, not a terminal one — the terminal states are Closed, Won't Fix, Duplicate, and Cannot Reproduce — and Product re-triages every Deferred item at milestone completion and at the next `/agent-plan` Stage 1.
- **Planning architecture documents** at `artifacts/milestone-{N}-{slug}/architecture.md` are the contract between Architect and Coder for a specific milestone — reaching engineering agents through each task file's Context Manifest, which cites the exact sections a task needs. Templates live at `.claude/cast/templates/ARCH_MODULE.md`, `ARCH_SYSTEM.md`, and `ARCH_DATA_SCHEMA.md`.
- **Planning UI specifications** at `artifacts/milestone-{N}-{slug}/ui.md` are the contract between UI and Coder. Template lives at `.claude/cast/templates/UI_SPEC.md`. Produced only when the `ui` agent is installed — a backend/CLI project that opted out of `ui` runs both pipelines without a UI spec, and `/agent-code` does not demand one.
- **CEO planning verdicts** at `artifacts/milestone-{N}-{slug}/reviews/ceo.md` gate entry into the engineering stage via a single `**Verdict**: <APPROVED | APPROVED WITH CONDITIONS | REVISION REQUIRED>` line that `/agent-code` Pre-Flight parses; on APPROVED WITH CONDITIONS the conditions are backfilled into the milestone README's CEO Approval Conditions table and referenced from the affected task files' Context Manifests. Template lives at `.claude/cast/templates/CEO_REVIEW.md`.
- **Milestone-close records**: UI writes the UX review for UI-flagged milestones (`.claude/cast/templates/UX_REVIEW.md`), the CEO writes the risk implementation review when flagged, and one Product launch writes the close record — per-task validation, milestone validation, completion summary (Status `Complete`, or `Complete with Deferrals` when Deferred items survive re-triage), and retrospective — under the milestone's `reviews/` directory (`.claude/cast/templates/MILESTONE_CLOSE.md`).

### Minimum Viable Agent Set

The required roster depends on which pipeline skills you keep. Prune from the bottom up.

**Tier 1 — Always required (the core loop):**
- **Product** — scope: acceptance criteria, bug triage, validation
- **Coder** — implementation, its tests, and every loop-back
- **Reviewer** — the independent gate: test-results verification, diff review, Defect/Issue classification, the Acceptance Criteria Check

These three run `/agent-task` on their own. There is no separate Tier for it in v3 — the Defect/Issue routing targets that v2 needed (Bug Gatherer, Debugger, Refactor) are now duties of Reviewer and Coder, so Reviewer's hand-offs cannot dead-end.

**Tier 2 — Strongly recommended for any serious project:**
- **Architect** — for projects with multiple modules or non-trivial structure
- **Docs Writer** — for projects that declare a Documentation Home in the source map (with none declared, it is never launched)

**Tier 3 — Required for `/agent-plan` and `/agent-code`:**

The planning pipeline hard-wires a flow ending at a CEO sign-off. Keeping either skill means keeping both on top of Tiers 1–2:
- **UI** — produces the UI specification during planning
- **CEO** — the planning gate. Runs the security and performance lenses over the plan (setting the two implementation-review flags `/agent-code` reads at milestone completion), then issues the verdict. `/agent-plan` has no meaning without it; `/agent-code` pre-flight reads its verdict file before any task runs.

If you do not want a CEO planning gate, **delete `/agent-plan`, `/agent-code`, and `ceo.md` together** — they are a unit. `/agent-task` remains functional on its own and reads no verdict. Keeping `/agent-plan` or `/agent-code` while deleting the CEO agent produces a broken pipeline.

### Optional based on project type

One conditional opt-out: **UI** becomes optional for backend/CLI-only projects with no user interface. The opt-out is explicit during `/cast-init` (the UI templates are skipped with the agent), `/agent-plan` then skips its UI stage, and `/agent-code` does not require a UI spec when no `ui` agent is installed.

Every other agent is installed by default. **Release is not on this list** — it is a skill (`/cast-release`), not an agent, so there is nothing to opt out of.

---

## File Listing

<details>
<summary><strong>Every file in the template with a one-line description</strong> — expand if you need a map</summary>

All payload paths below are relative to `skills/cast-init/assets/` in this repo.

### Skill and plugin machinery

| File | Description |
|---|---|
| `skills/cast-init/SKILL.md` | The `/cast-init` adoption workflow: seven phases from discovery to the final report |
| `skills/cast-init/references/discovery.md` | Phase 1 checklists and the adoption-inventory template |
| `skills/cast-init/references/roster.md` | Canonical 7-agent roster, tiers, alias tables, and the pipeline-skills mapping |
| `skills/cast-init/references/dispositions.md` | `.claude/cast/` install rules, artifacts and root-file rules, the v3→v4 migration dispositions, and the plan-file format |
| `skills/cast-init/references/execution.md` | Phase 5 install mechanics and customization-preservation rules |
| `skills/cast-init/references/validation.md` | Phase 6 validation checklist and the Phase 7 report template |
| `.claude-plugin/plugin.json` | Plugin manifest (name `cast`, version, the cast-init skill) |
| `.claude-plugin/marketplace.json` | Marketplace manifest enabling `/plugin marketplace add Raxvis/CAST` |

### root/ (1 file)

| File | Description |
|---|---|
| `root/CLAUDE.md` | The CAST section appended to the user's `CLAUDE.md` (or written as a minimal one): workflow summary, source-map pointer, artifacts conventions, version stamp |

### agents/ → `.claude/agents/` (7 agents + README)

> **Note:** `agents/README.md` is metadata about the directory. It should NOT be copied to `.claude/agents/` in the target project — Claude Code would try to register it as a subagent.

| File | Description |
|---|---|
| `agents/product.md` | Defines the product agent; owns scope — milestone definition, task files, bug triage, validation, and the milestone close record |
| `agents/architect.md` | Defines the system design agent; owns module boundaries, data schemas, contracts, and the performance budget |
| `agents/ui.md` | Defines the UI agent; owns visual design, layout, interaction states, accessibility, and the milestone UX review |
| `agents/ceo.md` | Defines the CEO agent; the planning gate — runs the security and performance lenses over the plan (setting the two implementation-review flags), reads across every artifact for what falls between the specialists, and issues the verdict |
| `agents/coder.md` | Defines the implementation agent; writes production code and its tests, commits, and handles every loop-back (defect fixes, Issue restructuring, criteria rejections) |
| `agents/reviewer.md` | Defines the review agent; the independent gate — verifies the test-results block, reviews the diff, classifies findings as Defects (filing each as a bug file) or Issues, and records the Acceptance Criteria Check |
| `agents/docs-writer.md` | Defines the documentation agent; drains the `docs:` queue into the project's own Documentation Home (per the source map) at the milestone-completion checkpoint, at an overflow drain, and at the `/agent-task` checkpoint |
| `agents/README.md` | Master overview of the agent system: roster, interaction diagram, planning and engineering stage workflows, and placeholder reference |

### skills/ → `.claude/skills/` (7 skills + README)

> **Note:** `skills/README.md` is metadata about the directory. It is NOT installed to the target project.

| File | Description |
|---|---|
| `skills/agent-plan/SKILL.md` | Defines the `/agent-plan` pipeline skill; orchestrates the Planning Stage end-to-end (Product → Architecture + UI → CEO, with UI conditional on the plan's flags and the CEO's risk lenses conditional on a security surface or applicable budget) |
| `skills/agent-code/SKILL.md` | Defines the `/agent-code` pipeline skill; orchestrates the Engineering Stage per task (Coder → Reviewer, with Defects through Product triage and Issues back to Coder) |
| `skills/cast-release/SKILL.md` | Defines the `/cast-release` skill; verifies the release gates, derives the version, updates the changelog named in the source map's Project Registers, and issues a GO/NO-GO. Runs in-session, launches no agents |
| `skills/agent-task/SKILL.md` | Defines the `/agent-task` pipeline skill; runs a mini engineering pipeline (Coder → Reviewer → validation) for a single one-off task without requiring a milestone or CEO verdict, and drains the `/add-task` backlog (`TASK-XXX` for one entry, `backlog` for all open entries) |
| `skills/file-bug/SKILL.md` | Defines the `/file-bug` intake skill; files a user-found bug as a per-bug report under `artifacts/one-off/bugs/` plus an `artifacts/BUGS.md` index row. Runs in-session, launches no agents |
| `skills/add-task/SKILL.md` | Defines the `/add-task` intake skill; queues a small self-contained task as an entry in the `artifacts/TASKS.md` backlog for later execution or milestone adoption. Runs in-session, launches no agents |
| `skills/cast-doctor/SKILL.md` | Defines the `/cast-doctor` maintenance skill; run-anytime install health check — state invariants, source-map verification, and coverage gaps. Writes `artifacts/DOCTOR.md` |

### cast/ → `.claude/cast/` (machinery: source map, 2 contracts, document templates, 10 files + README)

The source map, the two process contracts, and the reusable document skeletons. Agents copy templates — never fill in place — to produce instances under `artifacts/`. See [`cast/templates/README.md`](skills/cast-init/assets/cast/templates/README.md).

| File | Description |
|---|---|
| `cast/SOURCES.md` | The source map — where THIS project's documentation, standards, and registers live, by category. Written by `/cast-init` from your answers; read by `/agent-plan`, `/agent-task` Pre-Flight, `/cast-release`, and Docs Writer; verified by `/cast-doctor` |
| `cast/PIPELINE_LOOP.md` | The canonical engineering-loop contract executed by both `/agent-code` and `/agent-task` (orchestrator-only — never passed into a stage): per-task sequence, Defect/Issue routing, loop-counter rules, test gate |
| `cast/STAGE_CONTRACT.md` | The stage contract — the only process document an agent reads: the closed read set, the handoff-entry format, and the one-line reply |
| `cast/templates/MILESTONE_DEFINITION.md` | Template for the milestone README — goal, success metrics, in/out of scope, top-level acceptance criteria, **Standards Digest**, Task Index, CEO Approval Conditions. Instance at `artifacts/milestone-{N}-{slug}/README.md` |
| `cast/templates/TASK.md` | Template for a single task file — the isolated unit of work: description, dependencies, acceptance criteria, Context Manifest (milestone artifacts only), Standards Digest (one-off tasks), and Handoff Log. One instance per task |
| `cast/templates/BUG_REPORT.md` | Template for a single bug file. One instance per bug at `artifacts/milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md` (or `artifacts/one-off/bugs/`), indexed in `artifacts/BUGS.md` |
| `cast/templates/MILESTONE_CLOSE.md` | Template for the milestone close record, written by Product in one pass: per-task validation, milestone validation, completion summary, retrospective. Instance at `reviews/close.md` |
| `cast/templates/ARCH_MODULE.md` | Template for documenting a single code module (instances at `arch-{slug}.md`) |
| `cast/templates/ARCH_SYSTEM.md` | Template for documenting a high-level system (the milestone `architecture.md` is an instance) |
| `cast/templates/ARCH_DATA_SCHEMA.md` | Template for documenting a data schema or save format (instances at `arch-{slug}.md`) |
| `cast/templates/UI_SPEC.md` | Template for specifying a UI screen or component (the milestone `ui.md` is an instance) |
| `cast/templates/CEO_REVIEW.md` | Template for the CEO planning verdict: mandated inputs, review checklist, and the verdict block. Instance at `reviews/ceo.md` |
| `cast/templates/UX_REVIEW.md` | Template for UI's UX review of an implemented milestone (instance at `reviews/ux.md`) |

### artifacts/ (work artifacts)

Live work artifacts produced by the agents. Copied as a seed into the target project so the expected structure is in place from day one.

| Path | Description |
|---|---|
| `artifacts/README.md` | Explains what belongs in `artifacts/` (work instances, never documentation or templates) and lists the subdirectory layout |
| `artifacts/AGENT_STATE.md` | Cross-milestone state tables written by the orchestrator (Decisions Log, Milestone Progress, Performance Budget Tracking, Open Questions) — no agent reads this file |
| `artifacts/BUGS.md` | Global bug index — one line per bug pointing at its per-bug file. Carries the canonical lifecycle and field-ownership rules |
| `artifacts/TASKS.md` | One-off task backlog — entries queued by `/add-task`, drained by `/agent-task` (per entry or backlog mode), reviewed for milestone adoption at `/agent-plan` Stage 1. Carries the canonical backlog lifecycle and field-ownership rules |
| `artifacts/STANDUP.md` | Rolling log of progress updates, blockers, and decisions from work sessions |
| `artifacts/milestone-{N}-{slug}/` | One directory per milestone: `README.md` (definition, Task Index, CEO conditions), `architecture.md`, `ui.md`, `reviews/` (risk, CEO, UX, risk-impl, close), `tasks/` (one file per task), `bugs/` (one file per bug) |
| `artifacts/one-off/` | `/agent-task` work: one-off task files and their bug files, plus user-found bugs filed by `/file-bug` under `one-off/bugs/` |

</details>

---

## License and contributing

CAST is [MIT-licensed](LICENSE) Markdown — every agent definition, pipeline skill, and document template is plain text you can fork, edit, and republish. If you find a rough edge, open an issue or a pull request on [`Raxvis/CAST`](https://github.com/Raxvis/CAST).

Significant changes must bump the template version in **four synchronized locations** and ship an annotated git tag plus a GitHub Release at the same push. The full policy is in [`CLAUDE.md`](CLAUDE.md) → Release and Tagging Policy. Short version:

1. `README.md` — the version badge and the `Current template version` hero line
2. `CHANGELOG.md` — a new version entry following the existing format
3. `.claude-plugin/plugin.json` — the `version` field
4. `skills/cast-init/SKILL.md` — the `metadata.version` frontmatter field

All four land in the same commit, with the message starting `Release v<new>:`. On push to `main`, [`release.yml`](.github/workflows/release.yml) does the rest automatically: it verifies the four locations agree, creates the annotated `v<new>` tag, and publishes the GitHub Release with notes extracted from the top `CHANGELOG.md` entry. After pushing, confirm with `gh release view v<new>`. Tag and Release by hand (`git tag -a` + `gh release create`, per the CLAUDE.md checklist) only if the workflow is unavailable.
