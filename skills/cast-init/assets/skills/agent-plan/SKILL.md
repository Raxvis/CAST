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
3. Delete this comment block once the skill is customized for your project.

INSTALLATION: This skill installs to `.claude/skills/agent-plan/SKILL.md` in your target
project (done automatically by /cast-init). Claude Code registers it as the /agent-plan
skill. Invoke it with `/agent-plan <feature description or milestone>`.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /agent-plan — Feature Planning Pipeline

Run the planning stage for a new feature or milestone. Produces milestone definitions, architecture documents, UI specifications, security and performance findings, and a CEO sign-off. No code is written. Every artifact produced by this skill is written to `artifacts/`; templates are read from `templates/`.

## Related agent files

This skill invokes the following agents. Open any of them for the full role definition, authority boundaries, and output format:

- [product](../../agents/product.md) — defines milestone scope, goals, and acceptance criteria; writes the milestone definition and task breakdown
- [architect](../../agents/architect.md) — produces the milestone architecture document, data schemas, and module boundaries
- [ui](../../agents/ui.md) — produces the milestone UI specification and interaction states
- [security](../../agents/security.md) — reviews the architecture for vulnerabilities and files findings
- [performance](../../agents/performance.md) — reviews the architecture for performance budget violations and files findings
- [ceo](../../agents/ceo.md) — reads every prior artifact and issues the APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED verdict

## Model Compatibility

Each stage runs on the model pinned in that agent's file (default: `claude-opus-4-8`; `claude-opus-4-7` and `claude-opus-4-6` are supported — full profiles and upgrade paths in `docs/MODEL_OPTIMIZATION.md`). Orchestration notes by executing model:

- **Opus 4.8 / 4.7** — these models delegate conservatively; the explicit stage invocations below are load-bearing. Execute every stage exactly as written and do not collapse a stage into direct work because delegation feels unnecessary.
- **Opus 4.6** — this model over-delegates; invoke only the agents named in the stages below and spawn no ad-hoc subagents beyond them.
- **Effort** — run planning stages at `high` reasoning effort, and the Architecture stage at `xhigh` on Opus 4.7+ (Opus 4.6 caps at `high`).

## Input

The argument text the user provided when invoking this skill (e.g. `/agent-plan add dark mode`) — a description of the feature to plan, or an existing milestone identifier to re-plan. If none was provided, ask for one before Stage 1.

## Instructions

This skill orchestrates the **Planning Stage** of the agent workflow. It runs the agents in the order below, each building on the previous agent's output. All outputs are planning documents under `artifacts/` — no production code is modified and nothing is written to `docs/`.

### Stage 1 — Product

Launch the **product** agent to:

1. Define the feature scope, goals, and success metrics.
2. Write the milestone definition at `artifacts/milestones/milestone-{N}-{slug}.md` using `templates/MILESTONE_DEFINITION.md` as the template. This file captures what the milestone is and why it matters — goal, success metrics, in-scope, out-of-scope, top-level acceptance criteria, dependencies and risks, cross-cutting concerns.
3. Write the task breakdown at `artifacts/milestones/milestone-{N}-{slug}-tasks.md` using `templates/MILESTONE_TASKS.md` as the template. This file captures how the work is decomposed — one task per row with ID, dependencies, per-task acceptance criteria, and files touched.
4. Reference existing context in `docs/PRD.md`, `docs/CONCEPT.md`, and `docs/GLOSSARY.md`.

The two files are deliberately separate: the definition is the CEO's primary read during planning review, the breakdown is the Coder's primary read during engineering. Keeping them in separate files means each audience can find what they need without scrolling past the other.

Input to pass:
- Feature request: the invocation input
- Output directory: `artifacts/milestones/`
- Templates: `templates/MILESTONE_DEFINITION.md` (for the definition file) and `templates/MILESTONE_TASKS.md` (for the task breakdown)

### Stage 2a — Architecture

After Product completes, launch the **architect** agent to:

1. Read the milestone definition and task breakdown from Stage 1.
2. Produce the architecture document at `artifacts/architecture/arch-milestone-{N}.md` using the templates in `templates/ARCH_MODULE.md`, `templates/ARCH_SYSTEM.md`, and `templates/ARCH_DATA_SCHEMA.md` as appropriate.
3. Define module boundaries, data schemas, cross-module contracts, and data flows.
4. Reference existing architecture artifacts in `artifacts/architecture/` for consistency and name any new dependencies in the Decisions Log.

Input to pass: the milestone definition and task breakdown from Stage 1.

### Stage 2b — UI

In parallel with Architecture, launch the **ui** agent to:

1. Read the milestone definition from Stage 1.
2. Produce the UI specification at `artifacts/ui-specs/ui-milestone-{N}.md` using the template in `templates/UI_SPEC.md`.
3. Define screen layouts, component structure, interaction states, and accessibility notes.
4. Reference existing UI specs in `artifacts/ui-specs/` for consistency.

Input to pass: the milestone definition from Stage 1. Coordinate state-shape questions with the architect agent if they arise.

Both Architecture and UI must complete before Stage 3 begins.

### Stage 3a — Security

After Architecture completes, launch the **security** agent to:

1. Read the architecture document and milestone definition.
2. Identify vulnerabilities, insecure patterns, and risky dependencies introduced by the milestone.
3. File findings at `artifacts/reviews/security-review-milestone-{N}.md` with severity, cited vulnerability category, and remediation recommendation.
4. Any Critical finding blocks the milestone until remediated.

Input to pass: the milestone definition and architecture document.

### Stage 3b — Performance

In parallel with Security, launch the **performance** agent to:

1. Read the architecture document and UI specification.
2. Evaluate hot paths, state-update frequency, memory footprint, and rendering cost against the project performance budgets.
3. File findings at `artifacts/reviews/performance-review-milestone-{N}.md` with the specific budget or metric affected.
4. Any finding that breaks a budget must be resolved or explicitly accepted by Product before CEO review.

Input to pass: the milestone definition, architecture document, and UI specification.

Both Security and Performance must complete before Stage 4 begins. If either requires architectural changes, return to Stage 2a for revision and re-run Stage 3 on the revised architecture.

### Stage 4 — CEO Final Review

After Security, Performance, and UI have all completed, launch the **ceo** agent to:

1. Read every Stage 1–3 artifact: milestone definition, architecture document, UI specification, security findings, and performance findings.
2. Apply the CEO Review Checklist from `.claude/agents/ceo.md`.
3. Save the review to `artifacts/reviews/ceo-review-milestone-{N}.md`.
4. Produce a verdict: **APPROVED**, **APPROVED WITH CONDITIONS**, or **REVISION REQUIRED**.

Input to pass: all artifacts from Stages 1–3.

**If REVISION REQUIRED**: the CEO's Revision Requests identify which agent owns each change. Re-run the affected stage with the revision notes, then re-run the CEO review on the revised plan. Planning does not advance until the CEO issues APPROVED or APPROVED WITH CONDITIONS.

**If APPROVED WITH CONDITIONS**: record the Approval Conditions. They are tracked by Coder during engineering and verified by Reviewer and Product on completion.

### Revision Handling

When an agent revises a file during a re-run of an earlier stage (for example, the Architect rewriting `arch-milestone-{N}.md` to address a CEO Revision Request), the revision happens **in place** — the existing file is overwritten. Full historical diffs are preserved by git, not by filename churn.

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
