<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file is the master overview of the multi-agent documentation system for your project.
It describes every agent, how they interact, and the conventions that govern them.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with the name of your project.
2. Replace [FEATURE_AREA_*] placeholders with real feature areas, modules, or subsystems in your project.
3. Replace [ARTIFACT_TYPE_*] with the categories of deliverables your project produces.
4. Review the Agent table and remove rows for agents your project does not need.
5. Update the ASCII diagram to reflect any changes to the agent lineup.
6. Update the Documentation Placement table to match your actual folder/file conventions.

Per-agent AI models are pre-configured in each agent file's YAML frontmatter and are
not placeholders. Planning agents run on claude-opus-4-6, engineering agents on
claude-sonnet-4-6, and utility agents on claude-haiku-4-5-20251001. Override the
model: line in an individual agent file if you need a different pin.
-->

# [PROJECT_NAME] — Agent System Overview

## What Is This?

This directory contains the working documentation for each specialized agent that assists in developing [PROJECT_NAME]. Each agent owns a domain, maintains its own decisions log, and hands off work to other agents via structured outputs.

Each agent runs on a model tier matched to its workload: planning agents on Opus 4.6, engineering agents on Sonnet 4.6, utility agents on Haiku 4.5. The exact model for each agent is pinned in its YAML frontmatter.

---

## Agent Roster

The **Tier** column indicates which Minimum Viable Agent Set tier each agent belongs to. Tiers form a gradient: `T1` is always required, `T2` is strongly recommended, `T3` adds the Defect/Issue routing that `/agent-task` needs, and `T4` adds the planning-stage producers that `/agent-plan` and `/agent-code` need. See `README.md` → Minimum Viable Agent Set for the full tier description and for which agents you can delete when pruning the roster.

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
| Reviewer | `reviewer.md` | T1 | Reviews everything the Coder produces. Classifies findings as Defects (→ Debugger) or Issues (→ Refactor). |
| Debugger | `debugger.md` | T2 | Investigates defects raised by Reviewer. Logs investigation and hands reports to Bug Gatherer. |
| Refactor | `refactor.md` | T3 | Improves code structure without changing behaviour. Triggered by Reviewer issues. Flows back to Reviewer on completion. |
| Bug Gatherer | `bug-gatherer.md` | T3 | Collects and structures bug reports from Debugger and other sources. Produces standardized reports that Product triages. |
| Docs Writer | `docs-writer.md` | T2 | Produces and maintains developer-facing documentation. Runs after any other agent completes work. Accepts direct user input. |
| Release | `release.md` | Opt | Owns release preparation: changelogs, versioning, and build verification. Keep for projects with formal releases. |
| Validator | `validator.md` | Opt | Owns the process. Enforces agent protocols, resolves conflicts between agents, tracks milestone progress, and runs retrospectives. Keep for large teams or complex workflows. |

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
| **Current Work** | Active tasks, queues, and in-progress items. |
| **Decisions Log** | Record of notable decisions made by this agent and their rationale. Log when: accepting a non-standard approach, deviating from convention, choosing between alternatives, or establishing a precedent that future work should follow. Standard format: `Date / Decision / Rationale / Impact`. The Architect agent uses an extended five-column format (`Date / Decision / Alternatives Considered / Rationale / Impact`) to capture architectural decision records. |
| **Future Work** | Deferred items, nice-to-haves, and post-launch ideas. |

### Domain-Specific Extensions

Agents with specialized responsibilities include additional sections after the core sections. Examples:

- **Architect**: Architecture Document Templates, Code Review Checklist, Performance Budgets, Technical Validation Feedback
- **UI**: Style Guide, Screen Specifications, UX Review Checklist
- **Validator**: Session-Start Checklist, Conflict Resolution Protocol, Agent Status Dashboard
- **Product**: Task Validation Checklist, User Validation Feedback Log
- **Coder**: Pre-Handoff Checklist, Work Selection Strategy, Implementation Status
- **Bug Gatherer**: Workflow, Severity Rubric, Bug Report Template

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
      │   Debugger   │        │   Refactor   │───────┘
      └──────┬───────┘        └──────────────┘   loops back to
             │ investigation                     Tester → Reviewer
             ▼
      ┌──────────────┐
      │ Bug Gatherer │ (single entry point for all bugs)
      └──────┬───────┘
             │ structured reports
             ▼
      ┌──────────────┐
      │   Product    │ (triages bugs, validates work)
      └──────────────┘

  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
  │  Docs Writer │    │   Release    │    │  Validator   │
  │ (after all   │    │ (milestone   │    │ (process     │
  │  agents)     │    │  readiness)  │    │  oversight)  │
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
      │   Debugger   │        │   Refactor   │───────┘
      └──────┬───────┘        └──────────────┘   loops back to
             │ investigation                     Tester → Reviewer
             ▼
      ┌──────────────┐
      │ Bug Gatherer │
      └──────┬───────┘
             │ structured reports
             ▼
      ┌──────────────┐
      │   Product    │ (validates against task description)
      └──────────────┘
```

If Reviewer finds the change needs new architectural decisions, the pipeline
halts and instructs the user to re-run via `/agent-plan`.

---

## Workflow

The workflow is split into two stages, each wrapped by a slash command, plus a third command for self-contained one-off work:

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
   - **Defects** — route to **Debugger** → **Bug Gatherer** → **Product** for triage. If Product triages as fix-now, the defect returns to Coder.
   - **Issues** — route to **Refactor**. Refactor hands off back to **Tester** and **Reviewer** until the issue is resolved.
4. **Product** validates the finished task against its acceptance criteria. On rejection, work returns to Coder.
5. **Docs Writer** updates documentation after each agent completes work.
6. **Validator** records the outcome in the process log.
7. After every task in the milestone is complete, **Release** prepares changelog, versioning, and build verification, and **Validator** runs the milestone retrospective.

### One-Off Task Workflow (`/agent-task`)

Run for a single self-contained task (bug fix, typo, small refactor, dependency bump) that does not justify a full planning stage:

1. **Pre-flight scope check.** Read `CLAUDE.md` and any relevant `docs/` reference material (code patterns, file conventions, topic-specific docs). If the task description implies new modules, new schemas, new screens, new endpoints, or cross-cutting changes, **halt and instruct the user to run `/agent-plan` first**. No milestone is loaded and no planning artifacts are consulted.
2. **Coder** implements the change following the conventions in `CLAUDE.md` and `docs/`, completes the Pre-Handoff Checklist, and hands off.
3. **Tester** writes or updates unit tests and runs the test suite (automated gate). If tests fail, work returns to **Coder**. Tester must pass before Reviewer runs.
4. **Reviewer** reviews the code against project conventions and adjacent patterns. Findings are classified as:
   - **Defects** — route to **Debugger** → **Bug Gatherer** → **Product** for triage. If Product triages as fix-now, the defect returns to Coder.
   - **Issues** — route to **Refactor**. Refactor hands off back to **Tester** and **Reviewer** until the issue is resolved.
   - If Reviewer discovers the change needs new architectural decisions or cross-cutting design work, **halt and instruct the user to re-run via `/agent-plan`**. Do not retrofit design work into a one-off task.
5. **Product** validates the finished change against the task description itself (no milestone means the description is the acceptance criteria). Product also checks that no out-of-scope changes snuck in. On rejection, work returns to Coder.
6. **Completion**: append a one-line entry to `artifacts/STANDUP.md` with the date, task summary, and any bug ID resolved. If the task resolved a bug filed in `artifacts/BUGS.md`, update the bug's status (Open → Fixed) and add the investigation/fix fields.
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

1. **Validator** reviews the Agent Status Dashboard and confirms no agents are in a blocked state.
2. **Product** confirms the current milestone and priority order.
3. **Coder** selects the next unstarted task from the Work Queue.

### Escalation Protocols

| Scenario | Resolution |
|---|---|
| Tester fails but Reviewer would approve | Tester gate takes precedence. Tests must pass before Reviewer runs. Coder fixes the test failure first. |
| Reviewer rejects work that Tester passed | Work returns to Coder with Reviewer's specific change requests. Tester re-runs after Coder's changes. |
| Product rejects work that Reviewer approved | Work returns to Coder with Product's cited acceptance criteria. Tester and Reviewer re-run after changes. Coder may raise an Open Question if the rejection criteria are unclear. |
| Coder disputes Product's rejection | Coder raises an Open Question citing the specific acceptance criterion. Validator mediates using the conflict resolution hierarchy. Product has final say per hierarchy. |
| Debugger cannot reproduce a bug | Debugger marks status as "Cannot Reproduce" with investigation details. Bug Gatherer notifies the original reporter. Product decides whether to close or request further investigation. |
| Tests fail due to infrastructure, not code | Tester flags the failure as "Environment Issue" and notifies Validator. Validator pauses the test gate until infrastructure is resolved. Coder is not blocked from continuing other work. |
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
| Scope classification | Human (via command choice) | Reviewer | The user decides whether a change belongs in `/agent-task` (self-contained) or `/agent-plan` (cross-cutting). Reviewer enforces the boundary during Step 3 — if a `/agent-task` change reveals missing design context, Reviewer halts and instructs the user to re-run via `/agent-plan`. |

---

## Documentation Placement

Three top-level directories separate reference, templates, and work:

- **`docs/`** — Reference material only: requirements, conventions, design rationale. Never receives live work artifacts.
- **`templates/`** — Reusable document templates (architecture, UI spec, milestone files). Agents read them and produce instances under `artifacts/`; never filled in place.
- **`artifacts/`** — All work artifacts produced by the agents: milestone definitions, planning-stage architecture and UI specs, security/performance/CEO reviews, bug reports, and the session progress log. See `artifacts/README.md` for the full structure.

The table below records **where each agent writes its work artifacts**. Templates referenced by agents live in `templates/`; instances produced by the agents live in `artifacts/`.

| Document Type | Owner | Location | Tracking Format |
|---|---|---|---|
| Feature requirements (backlog) | Product | `product.md` → Current Work | Task / Milestone / Status / Notes |
| Milestone definitions and tasks | Product | `artifacts/milestones/milestone-{N}-{slug}.md` + `-tasks.md` | Per `templates/MILESTONE_TASKS.md` template |
| Architecture documents (planning) | Architecture | `artifacts/architecture/arch-milestone-{N}.md` | Per `templates/ARCH_MODULE.md` / `ARCH_SYSTEM.md` / `ARCH_DATA_SCHEMA.md` |
| Architecture document index | Architecture | `architect.md` → Architecture Documents table | Document / Module / Status / Milestone |
| Screen specifications (planning) | UI | `artifacts/ui-specs/ui-milestone-{N}.md` | Per `templates/UI_SPEC.md` |
| Screen specification index | UI | `ui.md` → Screen Specifications table | Screen / Milestone / Status / Notes |
| Code review verdicts | Reviewer | `reviewer.md` → Current Work | Submission / Source Agent / Date / Verdict / Notes |
| Test results and coverage | Tester | `tester.md` → Current Work | Change / Source Agent / Tests Run / Pass-Fail / Coverage Delta |
| Bug investigations | Debugger | `artifacts/BUGS.md` | Bug ID / Source / Status / Assigned To / Notes |
| Bug reports (initial) | Bug Gatherer | `artifacts/BUGS.md` via Bug Report Template | See `bug-gatherer.md` → Bug Report Template |
| Security audit findings (planning) | Security | `artifacts/reviews/security-review-milestone-{N}.md` | Finding / Severity / Module / Status / Notes |
| Security findings index | Security | `security.md` → Current Work | Finding / Severity / Module / Status / Notes |
| Performance analysis (planning) | Performance | `artifacts/reviews/performance-review-milestone-{N}.md` | Finding / Metric / Impact / Status / Notes |
| Performance findings index | Performance | `performance.md` → Current Work | Finding / Metric / Impact / Status / Notes |
| CEO planning reviews | CEO | `artifacts/reviews/ceo-review-milestone-{N}.md` | Milestone / Status / Verdict / Notes |
| CEO review index | CEO | `ceo.md` → Current Work | Milestone / Status / Verdict / Notes |
| Milestone completion reports | Product | `artifacts/milestones/milestone-{N}-{slug}-completion.md` | Per `templates/MILESTONE_COMPLETION.md` |
| Milestone validation records | Product | `artifacts/milestones/milestone-{N}-{slug}-validation.md` | Per `templates/MILESTONE_VALIDATION.md` |
| Rolling session log | Any agent | `artifacts/STANDUP.md` | Date / Agent / Change / Notes |
| Developer documentation | Docs Writer | `docs/` directory | Per `docs/README.md` index |
| Changelog and versioning | Release | `docs/CHANGELOG.md` | Per Release Checklist Template |
| Milestone retrospectives | Validator | `validator.md` → Milestone Retrospective | Per Milestone Retrospective Template |
| Decisions | Each agent | Agent's own Decisions Log table | Date / Decision / Rationale / Impact |

---

## Templates

Each agent file contains reusable templates:

| Template | Location |
|---|---|
| Task Validation Checklist | `product.md` |
| Module Architecture Doc | `architect.md` |
| System Architecture Doc | `architect.md` |
| Data Schema Doc | `architect.md` |
| Code Review Checklist | `architect.md` |
| Pre-Handoff Checklist | `coder.md` |
| Review Checklist | `reviewer.md` |
| UI Spec Template | `ui.md` |
| UX Review Checklist | `ui.md` |
| Refactor Submission Checklist | `refactor.md` |
| Bug Investigation Fields | `debugger.md` |
| Severity Levels | `security.md` |
| Performance Budget Tracking | `performance.md` |
| CEO Review Checklist | `ceo.md` |
| Release Checklist | `release.md` |
| Milestone Retrospective | `validator.md` |
| Process Checklist (Per Task) | `validator.md` |
| Bug Report | `bug-gatherer.md` |
| Severity Rubric | `bug-gatherer.md` |
