<!-- TEMPLATE INSTRUCTIONS
PURPOSE: Master overview of the agent system for your project — every agent, how they
interact, and the conventions that govern them.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.
2. If you pruned an agent, remove its row and update the diagrams.

Per-agent models and tool lists are pre-configured in each agent file's YAML frontmatter,
not placeholders. The `tools:` line is deliberate enforcement — every list omits the Task
tool, which makes "do not spawn subagents" a hard guarantee rather than an instruction.
Every agent defaults to `model: inherit` (it runs on the session model); role
differentiation comes from recommended reasoning effort. See docs/MODEL_OPTIMIZATION.md.
-->

# [PROJECT_NAME] — Agent System Overview

## What Is This?

Eight specialist agents. Each owns a domain, hands work off through files rather than conversation, and reads a deliberately small slice of the project.

**The read set is the whole design.** An agent working a task reads that task file, the entries in its Context Manifest, and whatever the last handoff entry says to read next — nothing else. It appends one capped entry to the task file and replies to the orchestrator with a single routing line. Capped reads in, one line out, so the orchestrating context stays flat across an entire milestone. The full contract is `docs/STAGE_CONTRACT.md`, and it is the only process document an agent ever reads.

**Why eight and not fifteen.** Every agent launch pays a cold context — the agent definition, project memory, the task file, the manifest — before doing any work, and each distinct agent *type* is a separate prompt-cache prefix. A role earns its own agent when it brings **independence**: a different reader, examining work someone else did, where the risk is self-serving judgment. Reviewer reading Coder's diff is independence and is worth its spawn. A separate agent writing tests for code another agent just wrote is not independence — it is a second pass by an equally-invested party, at full cold-context cost. v3 merged those cases into the stages that already held the context, and kept every gate they enforced.

## Agent Roster

`T1` is the always-required core loop, `T2` is strongly recommended, `T3` completes the full `/agent-plan` stage. `ui` is optional for backend/CLI-only projects.

| Agent | File | Tier | Role |
|---|---|---|---|
| Product | `product.md` | T1 | Owns scope. Writes the milestone definition and one file per task, triages bugs, validates what Reviewer flags, disposes of amendments, writes the completion / validation / retrospective records. |
| Coder | `coder.md` | T1 | Owns every change to production code and its tests. Implements, tests, commits; handles every loop-back — defect fixes (investigating root cause when needed), Issue restructuring, and criteria rejections. |
| Reviewer | `reviewer.md` | T1 | The independent gate. Verifies the test-results block, reviews the diff, classifies findings as Defects (filing each as a bug file) or Issues, and records the per-criterion Acceptance Criteria Check. |
| Architect | `architect.md` | T2 | Owns system design: module boundaries, data schemas, cross-module contracts, the performance budget. Returns the manifest rows each task needs. |
| Docs Writer | `docs-writer.md` | T2 | Owns `docs/`. Drains the documentation queue at milestone completion, at an overflow drain, and at `/agent-task` completion. |
| UI | `ui.md` | T3 | Owns visual design, layout, interaction states, accessibility. Performs the milestone UX review. Optional for backend/CLI-only projects. |
| Risk | `risk.md` | T3 | Reviews the architecture through the security lens and the performance lens in one pass. Sets the two flags that decide whether implementation reviews run at milestone completion. |
| CEO | `ceo.md` | T3 | The planning gate. Reads across every planning artifact for what falls *between* the specialists, and issues APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED. |

**Release is a skill, not an agent** — `/cast-release`. It is checklist execution against files the session can already read, and a spawn to run a checklist is a spawn spent on ceremony.

## Conflict Resolution Priority

When agents disagree: **Product > Architecture > UI**. The higher-priority position is the default resolution.

Two exceptions. **CEO** does not override Product on business intent, but may block a milestone from leaving planning on technical, security, performance, or cross-cutting risk grounds. **A blocking technical or legal reason from the lower-priority agent** escalates to the user instead of applying the hierarchy.

v2 routed conflicts through a Validator agent. v3 escalates to the user: an unresolved disagreement between two specialists is a decision a human should make, and interposing a third agent to apply a fixed priority table added a spawn without adding judgment.

## Agent File Structure

| Section | Purpose |
|---|---|
| **Model Configuration** | Effort default and when to raise it; the pointer to `docs/STAGE_CONTRACT.md`; the role's binding rules |
| **Role** | What this agent owns, in a few lines |
| **Duties / What a pass does** | The actual work, step by step |
| **Boundaries** | What this agent may **not** do |
| **Documentation queue** | What to append to the `docs` queue and when |

Agents may add domain-specific sections (checklists, rubrics, output formats). They may **not** re-add the v2 org-chart sections — Purpose, Goals, Authority, Inputs, Outputs — which averaged 52 lines per agent restating what the Rules block and the task file already carried. That is documentation *about* a role, loaded as instruction *to* it, on every spawn.

## Agent Interaction Diagram

### Planning Stage (`/agent-plan`)

```
  feature request
        │
        ▼
  ┌──────────┐
  │ Product  │  milestone README + one file per task (each with a Context Manifest)
  └────┬─────┘
       │
       ├──────────────┬─────────────────┐
       ▼              ▼                 │  (2a and 2b run in parallel)
  ┌──────────┐  ┌──────────┐            │
  │Architect │  │    UI    │            │  each returns Manifest Rows;
  └────┬─────┘  └────┬─────┘            │  the ORCHESTRATOR applies them (2c)
       └───────┬─────┘                  │  — two agents editing the same task
               ▼                        │    files concurrently would lose rows
        ┌─────────────┐                 │
        │ 2c: manifest│◄────────────────┘
        │ application │  (orchestrator, no spawn)
        └──────┬──────┘
               ▼
         ┌──────────┐
         │   Risk   │  security lens + performance lens, one pass, two flag lines
         └────┬─────┘
              ▼
         ┌──────────┐
         │   CEO    │  APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED
         └──────────┘
```

Light mode skips 2b and 3 for small, low-risk work — 3 tasks or fewer, no new screens, no security surface, no applicable budget, nothing cross-cutting. The per-task flags pull a skipped stage back in, and the CEO is the backstop.

### Engineering Stage (`/agent-code`)

```
  ┌───────┐   implement + test + commit    ┌──────────┐
  │ Coder │ ─────────────────────────────► │ Reviewer │
  └───┬───┘                                └────┬─────┘
      ▲                                         │
      │                                         ├── Defect → bug file → Product triage
      │                                         │      ├─ Fix Now  ──┐
      │                                         │      ├─ Defer      │ (task proceeds)
      │                                         │      └─ Not a Bug  │ (task proceeds)
      │                                         │                    │
      │                                         └── Issue ───────────┤
      └─────────────────────────────────────────────────────────────┘
                                                │
                                     all criteria Met?
                                    ┌───────────┴───────────┐
                                   yes                      no
                                    │                       │
                          orchestrator closes         Product validates
                           (no spawn)                       │
                                    └───────────┬───────────┘
                                                ▼
                              task checkpoint — no agents at all
                                                │
                            ...every task Complete or Deferred?...
                                                ▼
                          milestone checkpoint: Deferred re-triage, completion +
                          validation records, UX review (if UI-flagged), risk
                          implementation review (if flagged), retrospective,
                          docs drain, then orchestrator records and archives
```

**A clean task is two spawns.** Loop-backs reuse the same two agent types, so they hit a warm cache prefix.

### One-Off Task Pipeline (`/agent-task`)

Same loop, no milestone and no CEO verdict: Coder → Reviewer → validation, with the task description serving as the acceptance criteria. Pre-Flight halts and routes to `/agent-plan` if the task turns out to need design work.

## Workflow

### Planning (`/agent-plan`)

1. **Product** defines scope and writes the milestone README plus one task file per task, each seeded with the smallest sufficient Context Manifest. It also sweeps the Deferred backlog and disposes of the previous retrospective's open actions.
2. **Architect** and **UI** run in parallel, each producing its document and returning **Manifest Rows** rather than editing task files.
3. **2c**: the orchestrator applies both agents' rows to the task files. Single-writer, no spawn.
4. **Risk** reviews the architecture through both lenses and sets the two implementation-review flags.
5. **CEO** reads across everything for cross-cutting problems and issues the verdict. REVISION REQUIRED returns the plan to the named agent; a revision that touches the architecture re-runs Risk before the CEO re-review. Cap: 3 revision cycles, then escalate.
6. After approval, **Product** backfills the CEO Approval Conditions table and sets the README Status.

### Engineering (`/agent-code`)

1. **Coder** implements, writes and runs the tests, commits, and hands off with a **verbatim Test Results block**.
2. **Reviewer** rejects the entry unread if that block is missing or failing — that is the test gate. Otherwise it reviews the diff, classifies every finding, files Defects as bug files, and on approval records the Acceptance Criteria Check.
3. **Defects** go to **Product** for triage (Fix Now returns the task to Coder; Defer and Not a Bug do not block). **Issues** return to Coder. Findings from one review are resolved in one pass.
4. **Validation**: all criteria `Met` → the orchestrator closes the task, no spawn. Anything flagged, amended, condition-bearing, or bug-resolving → **Product**.
5. **Task checkpoint launches no agents** — Status writeback, progress entry, and a `docs` drain only past 10 pending entries.
6. **Milestone checkpoint**: Product re-triages Deferred items and writes the completion, validation, and retrospective records; UI runs the UX review for UI-flagged milestones; Risk runs the implementation review when either flag is Yes; Docs Writer drains the queue; the orchestrator records outcomes and archives. Then the user may invoke `/cast-release`.

### Cross-Reference Rules

- **Coder** cites the architecture section for every module it touches, and the UI spec section for every screen.
- **Reviewer** cites the specific standard, convention, or document a finding violates.
- **Product** cites a specific criterion when rejecting.
- **Architect** records every new dependency in the Decisions Log with what it buys and costs.
- **Risk** cites a vulnerability category for security findings and a named budget for performance findings.

### Escalation

Escalate to the **user**, not to another agent:

| Situation | Escalated by |
|---|---|
| Loop cap reached on a task (`[MAX_LOOP_COUNT]` cycles) | Orchestrator |
| Milestone circuit breaker (breadth or depth) trips | Orchestrator |
| Tests fail for environmental reasons | Orchestrator, on Coder's Environment Issue flag |
| Two specialists disagree and the priority hierarchy does not settle it | Orchestrator |
| A change needs design context the plan does not cover | Reviewer or Coder, via the halt condition |
| 3 CEO revision cycles without approval | Orchestrator |

## Responsibility Boundaries

| Question | Owner |
|---|---|
| What are we building, and is it done? | Product |
| How is it structured? | Architect |
| What does it look like? | UI |
| What could go wrong? | Risk |
| Should this plan proceed at all? | CEO |
| Does the code work? | Coder (writes it and its tests) |
| Is the code right? | Reviewer (independently) |
| Is it documented? | Docs Writer |

## Documentation Placement

The hard rule: **`docs/` is reference, `templates/` is skeletons, `artifacts/` is work.**

| Content | Location | Owner |
|---|---|---|
| Requirements, conventions, design rationale | `docs/` | Docs Writer |
| Reusable document skeletons | `templates/` | (not modified during work) |
| Milestone definitions, design docs, reviews, task files, bug files | `artifacts/milestone-{N}-{slug}/` | The producing agent |
| Bug index, session log, project state | `artifacts/` root | Orchestrator |
| One-off task work | `artifacts/one-off/` | The producing agent |

No agent writes a work artifact to `docs/` or fills a template in place.

## Templates

Agents that produce a document read its template from `templates/` **first** and follow its structure. Required sections are always present; sections marked `(required, scales)` collapse to one `N/A — <reason>` line when the work does not exercise them; `(optional)` sections are omitted unless their trigger fires. **Depth scales; coverage does not** — the milestone validation record still carries one block per task, and UI_SPEC's six interaction states and accessibility section are the gate, not a suggestion.

Revisions happen in place. Git is the audit log — v2's hand-maintained `## Revision History` tables are gone (`docs/FILE_CONVENTIONS.md` → Revisions).
