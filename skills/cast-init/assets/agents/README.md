<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file is the master overview of the multi-agent documentation system for your project.
It describes every agent, how they interact, and the conventions that govern them.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with the name of your project.
2. Review the Agent table and remove rows for agents your project does not need.
3. Update the ASCII diagram to reflect any changes to the agent lineup.
4. Update the Documentation Placement table to match your actual folder/file conventions.

Per-agent AI models are pre-configured in each agent file's YAML frontmatter and are
not placeholders. Every agent is pinned to claude-opus-4-8 (the Claude Opus 4.x family
is the optimized target; claude-opus-4-7 and claude-opus-4-6 are supported executing
models with per-model notes in each agent's "Model Configuration" section). Role
differentiation comes from recommended reasoning effort, not model tier. Override the
model: line in an individual agent file if you need a different pin — see
docs/MODEL_OPTIMIZATION.md for behavior profiles and upgrade paths.
-->

# [PROJECT_NAME] — Agent System Overview

## What Is This?

This directory contains the working documentation for each specialized agent that assists in developing [PROJECT_NAME]. Each agent owns a domain, maintains its own decisions log, and hands off work to other agents via structured outputs.

Every agent runs on the Claude Opus 4.x family, pinned to `claude-opus-4-8` by default in its YAML frontmatter; workload differentiation comes from recommended reasoning effort (`xhigh` for Architect, Coder, Reviewer, and Debugger; `high` for Product, UI, Security, Performance, CEO, Tester, and Refactor; `low` for the utility roles — Bug Gatherer, Docs Writer, Release, and Validator). Opus 4.7 and Opus 4.6 are supported executing models — each agent file carries a compact **Model Configuration** section (effort plus its binding behavioral rules), and `docs/MODEL_OPTIMIZATION.md` holds the full behavior profiles and the 4.6 → 4.7 → 4.8 upgrade checklists.

---

## Agent Roster

The **Tier** column indicates which Minimum Viable Agent Set tier each agent belongs to. Tiers form a gradient: `T1` is always required, `T2` is strongly recommended, `T3` adds the Defect/Issue routing that `/agent-task` needs, `T4` adds the planning-stage producers that `/agent-plan` and `/agent-code` need, and `T5` (Release, Validator) is project-type optional but **installed by default** — `/cast-init` includes both unless you explicitly opt out. See the CAST repo's [`README.md` → Minimum Viable Agent Set](https://github.com/Raxvis/CAST#minimum-viable-agent-set) for the full tier description and for which agents you can delete when pruning the roster.

| Agent | File | Tier | Role |
|---|---|---|---|
| Product | `product.md` | T1 | Owns requirements, validates completed tasks against acceptance criteria, maintains the feature backlog, and signs off on milestones. |
| Architecture | `architect.md` | T2 | Owns system design, module boundaries, data schemas, and code review standards. Produces architecture documents that Coder implements. |
| UI | `ui.md` | T4 | Owns visual design, layout specifications, the style guide, and interaction patterns. Produces screen specs that Coder implements. |
| Security | `security.md` | T4 | Identifies vulnerabilities and insecure patterns. Runs after Architecture produces or updates a document. Findings flow to CEO for final planning review. |
| Performance | `performance.md` | T4 | Profiles, identifies bottlenecks, and proposes optimisations. Runs after Architecture produces or updates a document. Findings flow to CEO for final planning review. |
| CEO | `ceo.md` | T4 | Final reviewer of the planning stage. Reads milestone, architecture, UI spec, and security/performance findings and issues a go/no-go verdict before engineering begins. |
| Coder | `coder.md` | T1 | Implements features as directed by Product, Architecture, and UI. Writes all production code and performs pre-handoff self-review. |
| Tester | `tester.md` | T1 | Generates and maintains automated test coverage. Runs after every change the Coder makes. |
| Reviewer | `reviewer.md` | T1 | Reviews everything the Coder produces. Classifies findings as Defects (→ Bug Gatherer) or Issues (→ Refactor). |
| Debugger | `debugger.md` | T2 | Investigates defects Product triages as Fix Now. Updates the bug record with root-cause analysis for Coder. |
| Refactor | `refactor.md` | T3 | Improves code structure without changing behaviour. Triggered by Reviewer issues. Flows back to Reviewer on completion. |
| Bug Gatherer | `bug-gatherer.md` | T3 | Collects and structures bug reports from Reviewer, Tester, Security, and user reports. Produces standardized reports that Product triages. |
| Docs Writer | `docs-writer.md` | T2 | Produces and maintains developer-facing documentation. Runs at task- and milestone-completion checkpoints. Accepts direct user input. |
| Release | `release.md` | T5 | Owns release preparation: changelogs, versioning, and build verification. User-invoked after milestone completion. Installed by default; drop only for scratch projects that never cut a release. |
| Validator | `validator.md` | T5 | Owns the process. Enforces agent protocols, resolves conflicts between agents, tracks milestone progress, and runs retrospectives. Installed by default; drop only for strict single-developer workflows with no agent-vs-agent escalation. |

---

## Conflict Resolution Priority

When agents disagree, the following hierarchy applies:

1. **Product** — business requirements and user experience goals take highest priority
2. **Architecture** — system design constraints and technical feasibility
3. **UI** — visual and interaction design

The **CEO** agent does not override Product on business intent, but it may block a milestone from leaving the planning stage on technical, security, performance, or cross-cutting risk grounds. CEO disputes with Product escalate to Validator.

The **Validator** agent does not override any of the above; it enforces that all agents follow the documented process.

---

## Agent File Structure

Every agent file follows a core structure of standard sections, listed below. Agents may extend this structure with domain-specific appendix sections (e.g., style guides, checklists, workflow definitions, feedback logs) placed after the standard sections. These extensions are expected and do not break the agent system — they provide domain context that the core sections cannot capture.

### Core Sections

| Section | Description |
|---|---|
| **Purpose** | One-paragraph description of what this agent owns. |
| **Goals** | Bulleted list of success criteria for this agent. |
| **Authority** | What decisions this agent can make unilaterally. |
| **Inputs** | What this agent receives from other agents or external sources. |
| **Outputs** | What this agent produces and who consumes it. |
| **Interaction Rules** | How this agent communicates with other agents. |
| **State** | Pointer to the agent's live working state in `artifacts/AGENT_STATE.md` → `## <agent>`. The mutable tables that used to live inside each agent file — Current Work, Decisions Log, Future Work, queues, and dashboards — live there now, one section per agent, so agent definitions stay immutable and cheap to load. Agents read their section on activation and append rows, never rewriting history. Decisions Log format: `Date / Decision / Rationale / Impact`; log when accepting a non-standard approach, deviating from convention, choosing between alternatives, or establishing a precedent. The architect section uses the extended five-column format (`Date / Decision / Alternatives Considered / Rationale / Impact`). |

### Domain-Specific Extensions

Agents with specialized responsibilities include additional sections after the core sections. Examples:

- **Architect**: Task Handoff Matrix, Concurrency Rules, Parallel Workflow Model (document templates live in `templates/ARCH_*.md`; the Architecture Documents index lives in `artifacts/AGENT_STATE.md`)
- **UI**: Style Guide (spec and review formats live in `templates/UI_SPEC.md` and `templates/UX_REVIEW.md`)
- **Validator**: Session-Start Checklist, Conflict Resolution Protocol, Blocked Agent Protocol (the retrospective skeleton lives in `templates/MILESTONE_RETROSPECTIVE.md`; the live Agent Status Dashboard and Conflicts tables live in `artifacts/AGENT_STATE.md` → `## validator`)
- **Product**: Templates pointer to `templates/MILESTONE_VALIDATION.md` (task validation checklist, feedback log, regression checklists)
- **Coder**: Pre-Handoff Checklist, Work Selection Strategy
- **Bug Gatherer**: Workflow, Severity Rubric (canonical bug entry format lives in `artifacts/BUGS.md`)

---

## Agent Interaction Diagram

### Planning Stage (`/agent-plan`)

```
                    ┌─────────────┐
                    │   Product   │
                    └──────┬──────┘
                           │ milestone & acceptance criteria
               ┌───────────┴───────────┐
               ▼                       ▼
        ┌──────────────┐        ┌─────────────┐
        │ Architecture │        │     UI      │
        └──┬────────┬──┘        └──────┬──────┘
           │        │                  │
           ▼        ▼                  │
   ┌────────────┐ ┌─────────────┐      │
   │  Security  │ │ Performance │      │
   └──────┬─────┘ └──────┬──────┘      │
          │              │             │
          │ findings      │ findings     │ UI spec
          ▼              ▼             ▼
         ┌────────────────────────────────┐
         │              CEO               │
         │  (final planning-stage review) │
         └────────────────┬───────────────┘
                          │ APPROVED / APPROVED WITH CONDITIONS
                          ▼
                   engineering stage
```

### Engineering Stage (`/agent-code`)

```
                  ┌──────────────┐
                  │    Coder     │◄──────────────────┐
                  └──────┬───────┘                   │
                         │ every change              │
                         ▼                           │
                  ┌──────────────┐                   │
                  │    Tester    │ (automated gate)  │
                  └──────┬───────┘                   │
                         │ tests must pass           │
                         ▼                           │
                  ┌──────────────┐◄─────────┐        │
                  │   Reviewer   │          │        │
                  └──────┬───────┘          │        │
                         │                  │        │
             ┌───────────┴───────────┐      │        │
             ▼                       ▼      │        │
      ┌──────────────┐        ┌──────────────┐       │
      │ Bug Gatherer │        │   Refactor   │───────┘
      └──────┬───────┘        └──────────────┘   loops back to
             │ structured report (New)           Tester → Reviewer
             ▼
      ┌──────────────┐
      │   Product    │ (triages: Fix Now / Defer / Not a Bug)
      └──────┬───────┘
             │ Fix Now
             ▼
      ┌──────────────┐
      │   Debugger   │ (investigates, appends root cause)
      └──────┬───────┘
             │ root-cause analysis
             ▼
      back to Coder (fix → Tester → Reviewer loop continues)

  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
  │  Docs Writer │    │   Release    │    │  Validator   │
  │ (completion  │    │ (user-invoked│    │ (completion  │
  │  checkpoints)│    │  post-mstone)│    │  checkpoints)│
  └──────────────┘    └──────────────┘    └──────────────┘
```

### One-Off Task Pipeline (`/agent-task`)

```
                  ┌──────────────────┐
                  │ Task Description │
                  │  (no milestone)  │
                  └────────┬─────────┘
                           │ scope check
                           ▼
                  ┌──────────────┐
                  │    Coder     │◄──────────────────┐
                  └──────┬───────┘                   │
                         │ every change              │
                         ▼                           │
                  ┌──────────────┐                   │
                  │    Tester    │ (automated gate)  │
                  └──────┬───────┘                   │
                         │ tests must pass           │
                         ▼                           │
                  ┌──────────────┐◄─────────┐        │
                  │   Reviewer   │          │        │
                  └──────┬───────┘          │        │
                         │                  │        │
             ┌───────────┴───────────┐      │        │
             ▼                       ▼      │        │
      ┌──────────────┐        ┌──────────────┐       │
      │ Bug Gatherer │        │   Refactor   │───────┘
      └──────┬───────┘        └──────────────┘   loops back to
             │ structured report (New)           Tester → Reviewer
             ▼
      ┌──────────────┐
      │   Product    │ (triages: Fix Now / Defer / Not a Bug;
      └──────┬───────┘  validates against task description)
             │ Fix Now
             ▼
      ┌──────────────┐
      │   Debugger   │ (investigates, appends root cause)
      └──────┬───────┘
             │ root-cause analysis
             ▼
      back to Coder (fix → Tester → Reviewer loop continues)
```

If Reviewer finds the change needs new architectural decisions, the pipeline
halts and instructs the user to re-run via `/agent-plan`.

---

## Workflow

The workflow is split into two stages, each wrapped by a pipeline skill, plus a third pipeline for self-contained one-off work:

- **Planning Stage** — `/agent-plan` — produces planning documents only.
- **Engineering Stage** — `/agent-code` — implements an approved milestone.
- **One-Off Task** — `/agent-task` — runs a mini engineering pipeline for a single self-contained task without a milestone or planning artifacts.

### Planning Stage Workflow (`/agent-plan`)

1. **Product** defines the milestone goals, tasks, and acceptance criteria.
2. **Architecture** produces architecture documents for all new modules.
3. **UI** produces screen specifications for all new interfaces. (Runs in parallel with Architecture.)
4. **Security** reviews the architecture document and files findings.
5. **Performance** reviews the architecture document against the performance budgets and files findings. (Runs in parallel with Security.)
6. **CEO** reads the milestone definition, architecture document, UI specification, and security/performance findings, applies the CEO Review Checklist, and issues a verdict: **APPROVED**, **APPROVED WITH CONDITIONS**, or **REVISION REQUIRED**.
7. On REVISION REQUIRED, the named agent revises and the CEO re-reviews. Planning does not advance until the CEO issues an approval-level verdict.

### Engineering Stage Workflow (`/agent-code`)

Run per task within the approved milestone:

1. **Coder** implements the task, completes the Pre-Handoff Checklist, and hands off.
2. **Tester** writes or updates tests and runs the test suite (automated gate). If tests fail, work returns to **Coder**. Tester must pass before Reviewer runs.
3. **Reviewer** reviews the code against the architecture document, UI specification, project conventions, and any CEO Approval Conditions. Findings are classified as:
   - **Defects** — route to **Bug Gatherer** (files the structured report, status New) → **Product** (triages, sets final severity) with one of three outcomes: **Fix Now** (Debugger investigates the triaged report, then Coder fixes; loop continues), **Defer** (report stays open in `artifacts/BUGS.md` with status Deferred; allowed only if the defect does not violate the task's acceptance criteria; the task proceeds), or **Not a Bug** (closed with rationale). Reviewer treats a version as clean when no Fix Now defects remain open.
   - **Issues** — route to **Refactor**. Refactor hands off back to **Tester** and **Reviewer** until the issue is resolved.
4. **Product** validates the finished task against its acceptance criteria. On rejection, work returns to Coder.
5. **Docs Writer** (invoked by `/agent-code` at the task- and milestone-completion checkpoints) drains the `docs` queue in `artifacts/STANDUP.md` and marks drained entries with ✅.
6. **Validator** (invoked by `/agent-code` at the task-completion checkpoint) records the outcome in `artifacts/AGENT_STATE.md`.
7. After every task in the milestone is complete: **UI** performs the milestone UX review (only for milestones containing UI-flagged tasks, written to `artifacts/reviews/ux-review-milestone-{N}.md`), and **Validator** (invoked by `/agent-code` at the milestone-completion checkpoint) records the milestone outcome in `artifacts/AGENT_STATE.md` and runs the milestone retrospective (`artifacts/reviews/retrospective-milestone-{N}.md`). **Release** is then invoked by the user — not auto-launched by any pipeline — to prepare changelog, versioning, and build verification.

### One-Off Task Workflow (`/agent-task`)

Run for a single self-contained task (bug fix, typo, small refactor, dependency bump) that does not justify a full planning stage:

1. **Pre-flight scope check.** Read `CLAUDE.md` and any relevant `docs/` reference material (code patterns, file conventions, topic-specific docs). If the task description implies new modules, new schemas, new screens, new endpoints, or cross-cutting changes, **halt and instruct the user to run `/agent-plan` first**. No milestone is loaded and no planning artifacts are consulted.
2. **Coder** implements the change following the conventions in `CLAUDE.md` and `docs/`, completes the Pre-Handoff Checklist, and hands off.
3. **Tester** writes or updates unit tests and runs the test suite (automated gate). If tests fail, work returns to **Coder**. Tester must pass before Reviewer runs.
4. **Reviewer** reviews the code against project conventions and adjacent patterns. Findings are classified as:
   - **Defects** — route to **Bug Gatherer** (files the structured report, status New) → **Product** (triages, sets final severity) with one of three outcomes: **Fix Now** (Debugger investigates the triaged report, then Coder fixes; loop continues), **Defer** (report stays open in `artifacts/BUGS.md` with status Deferred; allowed only if the defect does not violate the task's acceptance criteria; the task proceeds), or **Not a Bug** (closed with rationale). Reviewer treats a version as clean when no Fix Now defects remain open.
   - **Issues** — route to **Refactor**. Refactor hands off back to **Tester** and **Reviewer** until the issue is resolved.
   - If Reviewer discovers the change needs new architectural decisions or cross-cutting design work, **halt and instruct the user to re-run via `/agent-plan`**. Do not retrofit design work into a one-off task.
5. **Product** validates the finished change against the task description itself (no milestone means the description is the acceptance criteria). Product also checks that no out-of-scope changes snuck in. On rejection, work returns to Coder.
6. **Completion**: append a one-line entry to `artifacts/STANDUP.md` with the date, task summary, and any bug ID resolved. If the task resolved a bug filed in `artifacts/BUGS.md`, update the bug's status (→ Fixed) and fill in the resolution fields (Commit, Files Changed, Regression Notes).
7. `/agent-task` does **not** write to `artifacts/milestones/`, `artifacts/architecture/`, `artifacts/ui-specs/`, or `artifacts/reviews/` — those directories are owned by `/agent-plan` outputs.

### Cross-Reference Rules

- **Coder** must reference the relevant architecture document section for every module it touches.
- **Coder** must reference the relevant UI spec section for every screen or component it implements.
- **Product** must reference a specific acceptance criterion when rejecting a task.
- **Validator** must cite the specific rule that was violated when flagging a process violation.
- **Reviewer** must cite the specific standard, convention, or document that a piece of code violates when requesting changes.
- **Refactor** must cite the architectural principle or quality issue that justifies each refactoring change.
- **Security** must cite the vulnerability category (e.g., OWASP item) or security principle that applies to each finding.
- **Performance** must cite the specific performance budget or metric that is affected by each finding.

### Session Start

At the start of every working session:

1. **Validator** reviews the Agent Status Dashboard (`artifacts/AGENT_STATE.md` → `## validator`) and confirms no agents are in a blocked state.
2. **Product** confirms the current milestone and priority order.
3. **Coder** selects the next unstarted task from "Current Work — Ready to Start" (`artifacts/AGENT_STATE.md` → `## coder`).

### Escalation Protocols

| Scenario | Resolution |
|---|---|
| Tester fails but Reviewer would approve | Tester gate takes precedence. Tests must pass before Reviewer runs. Coder fixes the test failure first. |
| Reviewer rejects work that Tester passed | Work returns to Coder with Reviewer's specific change requests. Tester re-runs after Coder's changes. |
| Product rejects work that Reviewer approved | Work returns to Coder with Product's cited acceptance criteria. Tester and Reviewer re-run after changes. Coder may raise an Open Question if the rejection criteria are unclear. |
| Coder disputes Product's rejection | Coder raises an Open Question citing the specific acceptance criterion. Validator mediates using the conflict resolution hierarchy. Product has final say per hierarchy. |
| Debugger cannot reproduce a bug | Debugger marks status as "Cannot Reproduce" with investigation details. Bug Gatherer notifies the original reporter. Product decides whether to close or request further investigation. |
| Tests fail due to infrastructure, not code | Tester flags the failure as "Environment Issue" and notifies Validator. Validator pauses the test gate and escalates the environment issue to the user; Coder implements the infrastructure fix once the path is agreed. Coder is not blocked from continuing other work. |
| Security finds Critical issue in Approved architecture | Security files a blocking finding. Architecture must revise the document (status changes to "Superseded"). Coder stops implementation of affected modules. Validator tracks the blocker. |
| Product's acceptance criteria require an architecture change | Coder raises an Open Question to Architecture. Architecture revises the document and routes through Security/Performance review. If Architecture disagrees with the criteria, Validator applies the hierarchy (Product > Architecture). |
| Refactor breaks tests after change | Work returns to Refactor to fix. Tester re-runs. If the failure is a test infrastructure issue, Tester flags as environment issue per the protocol above. |
| An agent is blocked for more than 2 sessions | Validator escalates: reassigns work if possible, calls a process review, or escalates to a human stakeholder. |

---

## Responsibility Boundaries

When two agents cover related territory, one is the **primary owner** and the other defers or escalates.

| Area | Primary Owner | Secondary | Boundary |
|---|---|---|---|
| Code quality assessment | Reviewer | Tester | Reviewer owns conventions, correctness, style, and architecture adherence. Tester owns test adequacy, coverage metrics, and pass/fail results. Tester does not assess code quality; Reviewer does not write or run tests. |
| Architecture adherence | Architecture | Reviewer | Architecture has final say on module boundary disputes and design questions. Reviewer flags violations during code review and defers to Architecture if Coder disagrees. |
| Documentation of code | Docs Writer | Coder | Coder documents in-code references (architecture doc citations, UI spec citations) via the Pre-Handoff Checklist. Docs Writer maintains all files in `docs/` (reference material only) and ensures documentation stays current after every agent action. Coder does not update `docs/` directly. Work artifacts (bug reports, planning specs, progress logs) belong in `artifacts/`, not `docs/`. |
| Bug severity assignment | Bug Gatherer | Debugger | Bug Gatherer suggests initial severity when filing the report (status: New). Debugger does not change severity — it adds investigation fields (root cause, alternative solutions). Product sets final severity during triage. |
| Implementation scope | Coder | Refactor | Coder implements new features and fixes assigned bugs. Refactor restructures existing code without changing behaviour. When Reviewer or Tester flags a structural issue, it goes to Refactor. When a feature or bug fix is needed, it goes to Coder. |
| Pre-submission quality checks | Coder (self-check) | Product (validation) | Coder's Pre-Handoff Checklist is a self-assessment before submission. Product's Task Validation Checklist is an independent verification. Both are required — they are complementary, not redundant. Coder checks before submitting; Product validates after receiving. |
| Scope classification | Human (via pipeline choice) | Reviewer | The user decides whether a change belongs in `/agent-task` (self-contained) or `/agent-plan` (cross-cutting). Reviewer enforces the boundary during Step 3 — if a `/agent-task` change reveals missing design context, Reviewer halts and instructs the user to re-run via `/agent-plan`. |
| Changelog (`docs/CHANGELOG.md`) | Release | Docs Writer | Release is the primary owner of `docs/CHANGELOG.md` and writes every entry (the one deliberate Release-writes-into-`docs/` exception). Docs Writer routes changelog-worthy items to Release rather than editing the file directly; all other `docs/` maintenance remains Docs Writer's. |
| CI/build infrastructure | Coder | Architecture, Validator | Coder implements and fixes CI/build configuration. Architecture approves structural changes to the build system. When tests fail due to environment issues, Validator pauses the test gate and escalates to the user. |
| Dependency maintenance | Coder | Security, Architecture | Coder executes routine dependency bumps. Security audits CVE-driven updates. Architecture approves new dependencies and major-version upgrades. |

---

## Documentation Placement

Three top-level directories separate reference, templates, and work:

- **`docs/`** — Reference material only: requirements, conventions, design rationale. Never receives live work artifacts.
- **`templates/`** — Reusable document templates (architecture, UI spec, milestone files). Agents read them and produce instances under `artifacts/`; never filled in place.
- **`artifacts/`** — All work artifacts produced by the agents: milestone definitions, planning-stage architecture and UI specs, security/performance/CEO reviews, bug reports, and the session progress log. See `artifacts/README.md` for the full structure.

The table below records **where each agent writes its work artifacts**. Templates referenced by agents live in `templates/`; instances produced by the agents live in `artifacts/`.

| Document Type | Owner | Location | Tracking Format |
|---|---|---|---|
| Feature requirements (backlog) | Product | `artifacts/AGENT_STATE.md` → `## product` → Current Work | Task / Milestone / Status / Notes |
| Milestone definitions and tasks | Product | `artifacts/milestones/milestone-{N}-{slug}.md` + `-tasks.md` | Per `templates/MILESTONE_DEFINITION.md` (definition) and `templates/MILESTONE_TASKS.md` (breakdown) |
| Architecture documents (planning) | Architecture | `artifacts/architecture/arch-milestone-{N}.md` | Per `templates/ARCH_MODULE.md` / `ARCH_SYSTEM.md` / `ARCH_DATA_SCHEMA.md` |
| Architecture document index | Architecture | `artifacts/AGENT_STATE.md` → `## architect` → Architecture Documents | Document / Module / Status / Milestone |
| Screen specifications (planning) | UI | `artifacts/ui-specs/ui-milestone-{N}.md` | Per `templates/UI_SPEC.md` |
| Screen specification index | UI | `artifacts/AGENT_STATE.md` → `## ui` → Screen Specifications | Screen / Milestone / Status / Notes |
| Code review verdicts | Reviewer | `artifacts/AGENT_STATE.md` → `## reviewer` → Current Work | Submission / Source Agent / Date / Verdict / Notes |
| Test results and coverage | Tester | `artifacts/AGENT_STATE.md` → `## tester` → Current Work | Change / Source Agent / Tests Run / Pass-Fail / Coverage Delta |
| Bug investigations | Debugger | `artifacts/BUGS.md` | Bug ID / Source / Status / Assigned To / Notes |
| Bug reports (initial) | Bug Gatherer | `artifacts/BUGS.md` | Canonical entry format at the top of `artifacts/BUGS.md` |
| Security audit findings (planning) | Security | `artifacts/reviews/security-review-milestone-{N}.md` | Finding / Severity / Module / Status / Notes |
| Security findings index | Security | `artifacts/AGENT_STATE.md` → `## security` → Current Work | Finding / Severity / Module / Status / Notes |
| Performance analysis (planning) | Performance | `artifacts/reviews/performance-review-milestone-{N}.md` | Finding / Metric / Impact / Status / Notes |
| Performance findings index | Performance | `artifacts/AGENT_STATE.md` → `## performance` → Current Work | Finding / Metric / Impact / Status / Notes |
| CEO planning reviews | CEO | `artifacts/reviews/ceo-review-milestone-{N}.md` | Milestone / Status / Verdict / Notes |
| CEO review index | CEO | `artifacts/AGENT_STATE.md` → `## ceo` → Current Work | Milestone / Status / Verdict / Notes |
| Milestone completion reports | Product | `artifacts/milestones/milestone-{N}-{slug}-completion.md` | Per `templates/MILESTONE_COMPLETION.md` |
| Milestone validation records | Product | `artifacts/milestones/milestone-{N}-{slug}-validation.md` | Per `templates/MILESTONE_VALIDATION.md` |
| Rolling session log | Any agent | `artifacts/STANDUP.md` | Per the entry grammar defined in `artifacts/STANDUP.md`: newest-first session sections headed `### YYYY-MM-DD — <skill> — <milestone/task>`, containing typed one-line entries `- <agent> \| <type> \| <note>` |
| Milestone UX reviews | UI | `artifacts/reviews/ux-review-milestone-{N}.md` | Per `templates/UX_REVIEW.md` |
| Developer documentation | Docs Writer | `docs/` directory | Per `docs/README.md` index |
| Changelog and versioning | Release | `docs/CHANGELOG.md` | Per Release Checklist Template |
| Milestone retrospectives | Validator | `artifacts/reviews/retrospective-milestone-{N}.md` | Per `templates/MILESTONE_RETROSPECTIVE.md` |
| Decisions | Each agent | `artifacts/AGENT_STATE.md` → agent's Decisions Log | Date / Decision / Rationale / Impact |

---

## Templates

Reusable document templates live in the top-level `templates/` directory (see `templates/README.md`); shorter role-internal checklists remain in the agent files:

| Template | Location |
|---|---|
| Task Validation Checklist (+ feedback log, regression checklists) | `templates/MILESTONE_VALIDATION.md` |
| Module Architecture Doc | `templates/ARCH_MODULE.md` |
| System Architecture Doc | `templates/ARCH_SYSTEM.md` |
| Data Schema Doc | `templates/ARCH_DATA_SCHEMA.md` |
| UI Spec Template | `templates/UI_SPEC.md` |
| UX Review Checklist | `templates/UX_REVIEW.md` |
| CEO Review Checklist | `templates/CEO_REVIEW.md` |
| Pre-Handoff Checklist | `coder.md` |
| Review Checklist (incl. architecture-adherence items owned by Architecture) | `reviewer.md` |
| Refactor Submission Checklist | `refactor.md` |
| Bug Investigation Fields | `debugger.md` |
| Severity Levels | `security.md` |
| Performance Budget Tracking | `artifacts/AGENT_STATE.md` → `## performance` |
| Release Checklist | `release.md` |
| Milestone Retrospective | `templates/MILESTONE_RETROSPECTIVE.md` |
| Process Checklist (Per Task) | `validator.md` |
| Bug Report | `bug-gatherer.md` |
| Severity Rubric | `bug-gatherer.md` |
