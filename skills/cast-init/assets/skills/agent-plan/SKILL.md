---
name: agent-plan
description: >-
  Run the CAST Planning Stage end-to-end for a feature or milestone: Product →
  Architecture + UI → Security + Performance → CEO verdict. Use when the user asks to
  plan a feature or milestone, or invokes /agent-plan. Produces planning documents
  under artifacts/ and a CEO sign-off; writes no code.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /agent-plan pipeline skill. It runs the Planning Stage of the
multi-agent workflow end-to-end: Product → (Architecture + UI) → (Security + Performance) →
CEO. No code is written — the stage produces planning documents only.

All work artifacts are written to `artifacts/`. Templates are read from `templates/`;
guidelines are read from `docs/`. Never mix them: `docs/` and `templates/` are
reference-only, `artifacts/` is where live work lives.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.
2. If your project uses milestone identifiers other than `{N}` (numeric), update the
   filename patterns below (e.g., swap `milestone-{N}-{slug}` for `M{N}-{slug}`).

INSTALLATION: This skill installs to `.claude/skills/agent-plan/SKILL.md` in your target
project (done automatically by /cast-init). Claude Code registers it as the /agent-plan
skill. Invoke it with `/agent-plan <feature description or milestone>`.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /agent-plan — Feature Planning Pipeline

Run the planning stage for a new feature or milestone. Produces milestone definitions, architecture documents, UI specifications, security and performance findings, and a CEO sign-off. No code is written. Every artifact produced by this skill is written to `artifacts/`; templates are read from `templates/`.

## Related agent files

This skill invokes the following agents. Open any of them for the full role definition, authority boundaries, and output format:

- [product](../../agents/product.md) — defines milestone scope, goals, and acceptance criteria; writes the milestone README and one task file per task
- [architect](../../agents/architect.md) — produces the milestone architecture document, data schemas, and module boundaries
- [ui](../../agents/ui.md) — produces the milestone UI specification and interaction states
- [security](../../agents/security.md) — reviews the architecture for vulnerabilities and files findings
- [performance](../../agents/performance.md) — reviews the architecture for performance budget violations and files findings
- [ceo](../../agents/ceo.md) — reads every prior artifact and issues the APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED verdict

## Model Compatibility

Each stage runs on the model set in that agent's file (default: `inherit` — the session model; the Claude Opus 4.x family is the optimized target, with `claude-opus-4-8`, `claude-opus-4-7`, and `claude-opus-4-6` supported — full profiles and upgrade paths in `docs/MODEL_OPTIMIZATION.md`). Orchestration notes by executing model:

- **Opus 4.8 / 4.7** — these models delegate conservatively; the explicit stage invocations below are load-bearing. Execute every stage exactly as written and do not collapse a stage into direct work because delegation feels unnecessary.
- **Opus 4.6** — this model over-delegates; invoke only the agents named in the stages below and spawn no ad-hoc subagents beyond them.
- **Effort** — run planning stages at `high` reasoning effort, and the Architecture stage at `xhigh` on Opus 4.7+ (Opus 4.6 caps at `high`).

## Input

The argument text the user provided when invoking this skill (e.g. `/agent-plan add dark mode`) — a description of the feature to plan, or an existing milestone identifier to re-plan. If none was provided, ask for one before Stage 1.

## Instructions

This skill orchestrates the **Planning Stage** of the agent workflow. It runs the agents in the order below, each building on the previous agent's output. All outputs are planning documents under `artifacts/` — no production code is modified and nothing is written to `docs/`.

**Pass inputs forward.** Each stage's "Input to pass" means include the content in the agent's invocation — read each artifact once as it is produced and hand it to the consuming stages. Do not make every agent independently re-open files the orchestrator has already read; an agent re-reads a file itself only when it needs sections that were not supplied.

**Milestone numbering.** Unless the invocation input names an existing milestone to re-plan, allocate `{N}` as the highest `milestone-{N}-*` directory number already present under `artifacts/` plus one (`1` if there are none). Allocate it once, before Stage 1; Stage 1 creates the milestone directory `artifacts/milestone-{N}-{slug}/` and every artifact of the run is written inside it.

**Stage checkpoints.** At the start of the run, add a session heading `### YYYY-MM-DD — agent-plan — milestone-{N}-{slug}` to `artifacts/STANDUP.md`. After each stage completes, append a checkpoint entry under it using that file's Entry Grammar, e.g. `- architect | progress | Stage 2a complete: artifacts/milestone-{N}-{slug}/architecture.md`. These checkpoints are what let an interrupted planning run resume at the right stage. Planning stages may also enqueue documentation work in their checkpoint entries: when a stage's output changes something documentation-worthy (APIs, commands, config, conventions, user-facing behavior), append a `- <agent> | docs | <note>` entry under the session heading — Docs Writer drains these at the next `/agent-code` or `/agent-task` completion checkpoint.

### Stage 1 — Product

Launch the **product** agent to:

1. Define the feature scope, goals, and success metrics.
2. Create the milestone directory `artifacts/milestone-{N}-{slug}/` and write the milestone README at `artifacts/milestone-{N}-{slug}/README.md` using `templates/MILESTONE_DEFINITION.md` as the template. This is the milestone's highest-order document: what it is and why it matters — goal, success metrics, in-scope, out-of-scope, top-level acceptance criteria, dependencies and risks, cross-cutting concerns — plus the Task Index (one row per task file; no status column) and the CEO Approval Conditions table (backfilled after Stage 4).
3. Decompose the work into tasks and write **one task file per task** at `artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md` using `templates/TASK.md` — each file self-contained: ID, dependencies, description, files touched, per-task acceptance criteria, and a **seeded Context Manifest** naming the smallest read set the task needs (convention docs now; Architecture and UI append their section references in Stage 2). Every manifest entry forces a downstream read — keep them minimal.
4. Review the Deferred backlog while defining the milestone: re-triage every Deferred bug in the `artifacts/BUGS.md` index and any Deferred task files from prior milestone directories (Status field in each task file's Header) — pull items into this milestone's scope, keep them Deferred with an updated rationale, or close them as Won't Fix with a rationale. Deferred is a held-open state, not terminal (see `artifacts/BUGS.md` → Bug Lifecycle).
5. Reference existing context in `docs/PRD.md`, `docs/CONCEPT.md`, and `docs/GLOSSARY.md`.

The README and the task files are deliberately separate: the README is the CEO's primary read during planning review; each task file is the Coder's **complete** read during engineering (together with its Context Manifest). Isolated task files mean an engineering stage never loads more than its one task.

Input to pass ("pass" means include the content in the agent's invocation — do not make each stage re-open files the orchestrator already read):
- Feature request: the invocation input
- Output directory: `artifacts/milestone-{N}-{slug}/`
- Templates: `templates/MILESTONE_DEFINITION.md` (for the README) and `templates/TASK.md` (one instance per task)
- Deferred backlog: the Deferred rows in the `artifacts/BUGS.md` index and any Deferred task files in prior milestone directories (for the re-triage in step 4)

### Stage 2a — Architecture

After Product completes, launch the **architect** agent to:

1. Read the milestone README and task files from Stage 1.
2. Produce the architecture document at `artifacts/milestone-{N}-{slug}/architecture.md` as an **instance of `templates/ARCH_SYSTEM.md`** — that template defines the milestone architecture document's required headings. When the milestone needs module- or schema-level depth beyond it, additionally instantiate `templates/ARCH_MODULE.md` and/or `templates/ARCH_DATA_SCHEMA.md` as `artifacts/milestone-{N}-{slug}/arch-{slug}.md`, and link them from the milestone document.
3. Define module boundaries, data schemas, cross-module contracts, and data flows.
4. **Update each affected task file's Context Manifest** with the specific `architecture.md` sections (by anchor) that task needs, and set its `Needs Arch Doc` field to Done with the link. The manifest, not the whole document, is what engineering agents will read.
5. Reference prior milestones' architecture documents (`artifacts/milestone-*/architecture.md`) for consistency and name any new dependencies in the Decisions Log.

Input to pass: the milestone README and task files from Stage 1.

### Stage 2b — UI

In parallel with Architecture, launch the **ui** agent to:

1. Read the milestone README from Stage 1.
2. Read the task files from Stage 1 — the per-task `Needs UI Spec` flags identify every screen the milestone introduces.
3. Produce the UI specification at `artifacts/milestone-{N}-{slug}/ui.md` using the template in `templates/UI_SPEC.md`.
4. Define screen layouts, component structure, interaction states, and accessibility notes.
5. **Update each affected task file's Context Manifest** with the specific `ui.md` sections (by anchor) that task needs, and set its `Needs UI Spec` field to Done with the link.
6. Reference prior milestones' UI specs (`artifacts/milestone-*/ui.md`) for consistency.

Input to pass: the milestone README and the task files from Stage 1 (the `Needs UI Spec` flags live in each task file's Header). Coordinate state-shape questions with the architect agent if they arise.

If the project installed no `ui` agent (a backend/CLI adoption that opted out of the UI role), skip this stage entirely and note the skip in the stage checkpoint entry (`- agent-plan | progress | Stage 2b skipped: no ui agent installed`); downstream stages then run without a UI specification.

**Stage trigger:** Stage 3 (both 3a and 3b) starts only after **both** Architecture (Stage 2a) and UI (Stage 2b) have completed — Stage 3b's input includes the UI spec. (If Stage 2b was skipped because no `ui` agent is installed, Stage 3 starts when Architecture completes.)

### Stage 3a — Security

After both Architecture and UI have completed (the Stage 3 trigger above), launch the **security** agent to:

1. Read the architecture document and milestone README.
2. Identify vulnerabilities, insecure patterns, and risky dependencies introduced by the milestone.
3. File findings at `artifacts/milestone-{N}-{slug}/reviews/security.md` with severity, cited vulnerability category, and remediation recommendation.
4. Any Critical finding blocks the milestone until remediated.

Input to pass: the milestone definition and architecture document.

### Stage 3b — Performance

In parallel with Security, launch the **performance** agent to:

1. Read the architecture document and UI specification.
2. Evaluate hot paths, state-update frequency, memory footprint, and rendering cost against the project performance budgets.
3. File findings at `artifacts/milestone-{N}-{slug}/reviews/performance.md` with the specific budget or metric affected.
4. Any finding that breaks a budget must be resolved or explicitly accepted by Product before CEO review.

Input to pass: the milestone definition, architecture document, and UI specification.

**Stage trigger:** Stage 4 starts only after **both** Stage 3 reviews (Security and Performance) have completed. If either requires architectural changes, return to Stage 2a for revision and re-run Stage 3 on the revised architecture.

### Stage 4 — CEO Final Review

After both Stage 3 reviews (Security and Performance) have completed (the Stage 4 trigger above), launch the **ceo** agent to:

1. Read every Stage 1–3 artifact in the milestone directory: the README, task files, architecture document, UI specification, security findings, and performance findings.
2. Produce the review using `templates/CEO_REVIEW.md` as the template — copy it, fill in every section, and list all six inputs reviewed by path. (In a no-ui run, the UI Spec input row and Section 3 read "N/A — no ui agent installed", per the template.)
3. Save the review to `artifacts/milestone-{N}-{slug}/reviews/ceo.md`.
4. Produce a verdict — **APPROVED**, **APPROVED WITH CONDITIONS**, or **REVISION REQUIRED** — recorded as the review's single `**Verdict**:` line with exactly one of the three strings, per `templates/CEO_REVIEW.md`. This skill's revision handling and `/agent-code`'s Pre-Flight both parse that `**Verdict**:` line.

Input to pass: all artifacts from Stages 1–3, and the template `templates/CEO_REVIEW.md`.

**If REVISION REQUIRED** (read from the review's `**Verdict**:` line): the CEO's Revision Requests identify which agent owns each change. Re-run the affected stage with the revision notes. If the revision touched the architecture — a Stage 2a re-run, or a UI revision that changes the architecture — re-run Stage 3 (Security and Performance) on the revised plan **before** the CEO re-review, so the CEO never re-reviews against stale security or performance findings. Then re-run the CEO review on the revised plan. Planning does not advance until the CEO issues APPROVED or APPROVED WITH CONDITIONS. **Revision cap:** allow at most 3 revision cycles (one cycle = re-running the affected stages plus one CEO re-review). If the third cycle still ends in REVISION REQUIRED, stop the run and escalate to the user with a summary of the unresolved objections — do not keep looping.

**After any approval-level verdict**: launch the **product** agent to (a) backfill the **CEO Approval Conditions** table in the milestone README (`artifacts/milestone-{N}-{slug}/README.md`, table defined by `templates/MILESTONE_DEFINITION.md`) — one row per condition with its source and Status Open, or a single "None — verdict was APPROVED" row; (b) add a `../README.md § CEO Approval Conditions` row to the Context Manifest of every task file a condition names; and (c) set the README's Status to CEO-Approved. `/agent-code` reads the conditions from the README table (its Pre-Flight may still cross-check them against the CEO review); Coder tracks them during engineering and Reviewer and Product verify them on completion.

### Revision Handling

When an agent revises a file during a re-run of an earlier stage (for example, the Architect rewriting the milestone's `architecture.md` to address a CEO Revision Request), the revision happens **in place** — the existing file is overwritten. Full historical diffs are preserved by git, not by filename churn.

Every planning-stage artifact includes a `## Revision History` section at the top of the file, directly under the title and above the body. Each revision adds an entry to the top of that table (most recent first):

```
## Revision History

| # | Date | Agent | Reason |
|---|---|---|---|
| v2 | 2026-04-09 | architect | Addressed CEO Revision Request: SQL injection risk — introduced parameterized query contract at the db/ module boundary |
| v1 | 2026-04-08 | architect | Initial version |

---
```

Rules:

- The **first** write of any planning artifact must include a Revision History table with one `v1` entry.
- A **revision** must add a new row at the top of the table with the next version number and a one-line reason citing the specific finding or request that triggered the revision.
- The body of the file is rewritten as needed — there is no expectation that prior content is preserved inline. Git history is the audit log.
- The CEO, on re-review, reads the Revision History table first to understand what changed and which of its prior Revision Requests have been addressed.

If a file is being produced by an agent for the first time and no prior version exists, the agent writes the Revision History block with a single `v1` entry. This keeps the format consistent across all artifacts and signals "this file is versioned" to downstream consumers.

### Output

Summarize the run:

1. What was planned — milestone scope, key architecture decisions, UI highlights.
2. Security findings summary and their resolution status.
3. Performance findings summary and their resolution status.
4. CEO verdict and any Approval Conditions or Revision Requests.
5. Next step — if the verdict is approval-level, the milestone is ready for `/agent-code`.

Do NOT proceed to implementation. The planning stage ends with the CEO verdict. Do NOT write any artifact to `docs/`; that directory is reference-only.
