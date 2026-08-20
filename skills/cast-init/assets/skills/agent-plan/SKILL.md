---
name: agent-plan
description: >-
  Run the CAST Planning Stage end-to-end for a feature or milestone: Product →
  Architecture + UI → Risk → CEO verdict, with UI and Risk launched only when the plan
  shows a UI-flagged task, a security surface, or an applicable performance budget. Use
  when the user asks to plan a feature or milestone, or invokes /agent-plan. Auto-engages
  a light mode (Product + Architecture + CEO only) for small features — 3 tasks or fewer
  with no new screens, no security surface, no applicable performance budget, and nothing
  cross-cutting. Produces planning documents under artifacts/ and a CEO sign-off; writes
  no code.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /agent-plan pipeline skill. It runs the Planning Stage of the
multi-agent workflow end-to-end: Product → (Architecture + UI) → Risk → CEO. No code is written — the stage produces planning documents only.

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

Run the planning stage for a new feature or milestone. Produces milestone definitions, architecture documents, UI specifications, a risk review, and a CEO sign-off. No code is written. Every artifact produced by this skill is written to `artifacts/`; templates are read from `templates/`.

## Related agent files

This skill invokes the following agents. Open any of them for the full role definition, authority boundaries, and output format:

- [product](../../agents/product.md) — defines milestone scope, goals, and acceptance criteria; writes the milestone README and one task file per task
- [architect](../../agents/architect.md) — produces the milestone architecture document, data schemas, and module boundaries
- [ui](../../agents/ui.md) — produces the milestone UI specification and interaction states
- [risk](../../agents/risk.md) — reviews the architecture through the security and performance lenses in one pass, files findings, and sets the two implementation-review flags
- [ceo](../../agents/ceo.md) — reads every prior artifact and issues the APPROVED / APPROVED WITH CONDITIONS / REVISION REQUIRED verdict

## Model Compatibility

Each stage runs on the model set in that agent's file (default: `inherit` — the session model). Invoke only the agents named in the stages below, exactly as written: no ad-hoc subagents, no added verification passes (the executing model self-verifies), no collapsing a stage into direct work. Effort is per agent file — v3 planning defaults are `high` across the stage; raise Architecture to `xhigh` only for a new subsystem, a schema migration, or a cross-cutting contract change. Per-model profiles: `docs/MODEL_OPTIMIZATION.md`.

## Input

The argument text the user provided when invoking this skill (e.g. `/agent-plan add dark mode`) — a description of the feature to plan, or an existing milestone identifier to re-plan. If none was provided, ask for one before Stage 1.

## Instructions

This skill orchestrates the **Planning Stage** of the agent workflow. It runs the agents in the order below, each building on the previous agent's output. All outputs are planning documents under `artifacts/` — no production code is modified and nothing is written to `docs/`.

**Pass paths, not bodies.** Each stage's "Input to pass" means name the artifact paths (plus section pointers where a stage needs only part of one) in the agent's invocation — the stage reads its own inputs. Do not read stage outputs into your own context to paste them forward: a subagent is cold either way, so pasting pays an extra copy per receiving stage *and* permanently bloats this orchestrating context, which stage replies are designed to keep flat. Inline content belongs in an invocation only when you produced it yourself (the feature request, manifest-row corrections, revision notes).

**Stage replies are routing metadata.** Per `docs/STAGE_CONTRACT.md`, each stage's final report is a short completion notice (artifact written, one-line outcome) — plus, for Stages 2a/2b, the per-task manifest-rows block described below. Do not relay or summarize document contents between stages; the documents on disk are the record.

**Milestone numbering.** Unless the invocation input names an existing milestone to re-plan, allocate `{N}` as the highest `milestone-{N}-*` directory number already present under `artifacts/` plus one (`1` if there are none). Allocate it once, before Stage 1; Stage 1 creates the milestone directory `artifacts/milestone-{N}-{slug}/` and every artifact of the run is written inside it.

### Light Mode

Between `/agent-task` (no design content at all) and a full planning run there is a real middle tier: a small, well-understood feature that needs a handful of genuine design decisions. Light mode plans it without full ceremony — design work still gets planned and engineering still requires a CEO verdict; only the ceremony scales with the work. `/agent-plan single: <feature>` remains an accepted invocation and is the one-task case of this mode.

**Entering the mode.** Run light mode when the user asks for it (`/agent-plan light: <feature>`, or `/agent-plan single: <feature>` for the one-task case), **or automatically when Stage 1 scoping concludes that every one of the following holds**:

1. The work decomposes to **3 tasks or fewer**.
2. It introduces **no new screen set** — no new screens, and no change to the interaction model of existing ones. (A cosmetic change to one existing screen does not disqualify; a new screen does.)
3. It is **not security-sensitive** — it does not touch authentication or authorization, input handling, secrets or sensitive data, and adds no new dependency.
4. **No performance budget applies** to it — the architecture document sets no budget this work exercises, and it introduces no hot path, no new persistence or network round trip, and no unbounded data growth.
5. It is **not cross-cutting** — no change to a shared contract, module boundary, or convention that other milestones' code depends on.

Any one of these failing means full mode. **Judge them from Stage 1's output, not from the invocation text** — a feature request that sounds small often is not, and the point of the gate is to catch that before four stages are skipped. When a condition is genuinely borderline, choose full mode: a wrongly-full plan costs stages, a wrongly-light one ships an unreviewed design decision.

**What changes:**

- **Stages run:** Stage 1 (Product) → Stage 2a (Architecture) → Stage 2c → Stage 4 (CEO). Stages 2b (UI) and 3 (Risk) are skipped by default.
- **Stage 1** creates the milestone directory exactly as in full mode — same layout, so `/agent-code` consumes it unchanged — with one task file per task. Every required README section is still present (lean is fine; absent is not). Stage 1 also sets the flags that pull skipped stages back in: **Needs UI Spec** = Yes on any task pulls in Stage 2b; security-sensitive scope (auth, input handling, new dependencies, sensitive data) or an applicable performance budget pulls in Stage 3. A pulled-in stage runs exactly as in full mode, including its completion-flag line. These flags are the safety net under the entry conditions above: a stage wrongly skipped at scoping time is pulled back the moment a task declares its need.
- **Stage 4 (CEO)** reviews as usual; the skipped stages' checklist sections and input rows read "N/A — <stage> skipped: <reason>" (permitted by `templates/CEO_REVIEW.md`). **The CEO is the backstop:** if the plan in front of it clearly needed a skipped stage, the correct verdict is REVISION REQUIRED naming that stage, which re-runs it and re-reviews. The verdict line, Approval Conditions, and the post-verdict backfill work identically.
- **Downstream:** a skipped Risk stage leaves no `reviews/risk.md` and therefore no flag lines, so the `/agent-code` milestone-completion checkpoint skips the implementation review automatically.

Record the mode and why it was chosen in the Stage 1 checkpoint entry — `- agent-plan | progress | Stage 1 complete (light mode: 2 tasks, no new screens, no security or perf surface): ...` — so a resumed run knows which stages to expect and a later reader can audit the call.

**Stage checkpoints.** At the start of the run, add a session heading `### YYYY-MM-DD — agent-plan — milestone-{N}-{slug}` to `artifacts/STANDUP.md`. After each stage completes, append a checkpoint entry under it using that file's Entry Grammar, e.g. `- architect | progress | Stage 2a complete: artifacts/milestone-{N}-{slug}/architecture.md`. These checkpoints are what let an interrupted planning run resume at the right stage. Planning stages may also enqueue documentation work in their checkpoint entries: when a stage's output changes something documentation-worthy (APIs, commands, config, conventions, user-facing behavior), append a `- <agent> | docs | <note>` entry under the session heading — Docs Writer drains these at the next `/agent-code` or `/agent-task` completion checkpoint.

### Stage 1 — Product

Launch the **product** agent to:

1. Define the feature scope, goals, and success metrics.
2. Create the milestone directory `artifacts/milestone-{N}-{slug}/` and write the milestone README at `artifacts/milestone-{N}-{slug}/README.md` using `templates/MILESTONE_DEFINITION.md` as the template. This is the milestone's highest-order document: what it is and why it matters — goal, success metrics, in-scope, out-of-scope, top-level acceptance criteria, dependencies and risks, cross-cutting concerns — plus the Task Index (one row per task file; no status column) and the CEO Approval Conditions table (backfilled after Stage 4).
3. Decompose the work into tasks and write **one task file per task** at `artifacts/milestone-{N}-{slug}/tasks/task-{T}-{slug}.md` using `templates/TASK.md` — each file self-contained: ID, dependencies, description, files touched, per-task acceptance criteria, and a **seeded Context Manifest** naming the smallest read set the task needs (convention docs now; Architecture and UI append their section references in Stage 2). Every manifest entry forces a downstream read — keep them minimal.
4. Review the Deferred backlog while defining the milestone: re-triage every Deferred bug in the `artifacts/BUGS.md` index and any Deferred task files from prior milestone directories (Status field in each task file's Header) — pull items into this milestone's scope, keep them Deferred with an updated rationale, or close them as Won't Fix with a rationale. Deferred is a held-open state, not terminal (see `artifacts/BUGS.md` → Bug Lifecycle).
5. **Retrospective intake.** Read the previous milestone's close record, `reviews/close.md` (the highest-numbered milestone directory that has one — or a pre-v3 `reviews/retrospective.md`; skip this step if neither exists). For each row of its **Actions for Next Milestone** table that has no disposition yet, dispose of it: **adopt** it into this milestone's Cross-Cutting Concerns (or as a task), or **decline** it with a reason. Write the disposition into that Actions table (Disposition column: `Adopted → M{N}` or `Declined — <reason>`). No open action may be left undisposed — this step is what makes retrospectives feed planning instead of being write-only.
6. Reference existing context in `docs/PRD.md`, `docs/CONCEPT.md`, and `docs/GLOSSARY.md`.

The README and the task files are deliberately separate: the README is the CEO's primary read during planning review; each task file is the Coder's **complete** read during engineering (together with its Context Manifest). Isolated task files mean an engineering stage never loads more than its one task.

Input to pass:
- Feature request: the invocation input
- Output directory: `artifacts/milestone-{N}-{slug}/`
- Templates: `templates/MILESTONE_DEFINITION.md` (for the README) and `templates/TASK.md` (one instance per task)
- Deferred backlog: the Deferred rows in the `artifacts/BUGS.md` index and any Deferred task files in prior milestone directories (for the re-triage in step 4)
- Prior close record: the previous milestone's `reviews/close.md` (for the disposition duty in step 5), when one exists

### Stage 2a — Architecture

After Product completes, launch the **architect** agent to:

1. Read the milestone README and task files from Stage 1.
2. Produce the architecture document at `artifacts/milestone-{N}-{slug}/architecture.md` as an **instance of `templates/ARCH_SYSTEM.md`** — that template defines the milestone architecture document's required headings. When the milestone needs module- or schema-level depth beyond it, additionally instantiate `templates/ARCH_MODULE.md` and/or `templates/ARCH_DATA_SCHEMA.md` as `artifacts/milestone-{N}-{slug}/arch-{slug}.md`, and link them from the milestone document.
3. Define module boundaries, data schemas, cross-module contracts, and data flows.
4. **Return a Manifest Rows block** in its completion report: for each affected task, the specific `architecture.md` sections (by anchor) that task needs and why — one proposed Context Manifest row per line, in the manifest's table format. Do **not** edit the task files directly: Stage 2b runs in parallel and edits to the same files would collide; the orchestrator applies both agents' rows in Stage 2c.
5. Reference prior milestones' architecture documents (`artifacts/milestone-*/architecture.md`) for consistency and name any new dependencies in the Decisions Log.

Input to pass: the paths of the milestone README and task files from Stage 1.

### Stage 2b — UI

In parallel with Architecture, launch the **ui** agent to:

1. Read the milestone README from Stage 1.
2. Read the task files from Stage 1 — the per-task `Needs UI Spec` flags identify every screen the milestone introduces.
3. Produce the UI specification at `artifacts/milestone-{N}-{slug}/ui.md` using the template in `templates/UI_SPEC.md`.
4. Define screen layouts, component structure, interaction states, and accessibility notes.
5. **Return a Manifest Rows block** in its completion report: for each affected task, the specific `ui.md` sections (by anchor) that task needs and why — one proposed Context Manifest row per line. Do **not** edit the task files directly (Stage 2a runs in parallel; the orchestrator applies both agents' rows in Stage 2c).
6. Reference prior milestones' UI specs (`artifacts/milestone-*/ui.md`) for consistency.

Input to pass: the paths of the milestone README and the task files from Stage 1 (the `Needs UI Spec` flags live in each task file's Header). Coordinate state-shape questions with the architect agent if they arise.

**This stage is conditional in full mode too**, on the same flag light mode uses: run it only when at least one task file's Header has **Needs UI Spec** = Yes. A full-mode backend milestone with no UI-flagged task would otherwise pay a UI launch for a spec no manifest cites. Skip with a checkpoint note (`- agent-plan | progress | Stage 2b skipped: no UI-flagged tasks`); the CEO reviews the skip like any light-mode skip ("N/A" input row), and a task that later declares **Needs UI Spec** = Yes pulls the stage back in.

If the project installed no `ui` agent (a backend/CLI adoption that opted out of the UI role), skip this stage entirely and note the skip in the stage checkpoint entry (`- agent-plan | progress | Stage 2b skipped: no ui agent installed`); downstream stages then run without a UI specification.

### Stage 2c — Manifest application (orchestrator)

After both Stage 2a and Stage 2b complete (or 2a alone in a no-ui run), the orchestrator applies the returned Manifest Rows blocks to the task files — no agent launch needed:

1. For each task, append the rows from Architecture's and UI's blocks to that task file's Context Manifest table.
2. Set each affected task's `Needs Arch Doc` / `Needs UI Spec` Header field to Done with the link.
3. This single-writer step exists because 2a and 2b run in parallel — two agents editing the same task files concurrently would silently lose rows. All task-file manifest writes during planning go through this step.

**Stage trigger:** Stage 3 starts once its inputs exist — after Stages 2a and 2b complete (or 2a alone when 2b is skipped). Risk reads the architecture document, the README, and the UI spec; it never reads a task-file manifest, so it does not wait on Stage 2c. Run 2c in the same round.

### Stage 3 — Risk

**Conditional in full mode, on the same tests light mode uses.** Launch Risk only when Stage 1's scoping shows a security surface (the milestone touches authentication or authorization, input handling, secrets or sensitive data, or adds a dependency) **or** an applicable performance budget (the architecture document sets a budget this milestone exercises, or the plan introduces a hot path, new persistence or network round trip, or unbounded data growth). When neither holds, skip with a checkpoint note (`- agent-plan | progress | Stage 3 skipped: no security surface, no applicable budget`) — a skipped Risk stage leaves no `reviews/risk.md`, so `/agent-code` skips the implementation review automatically, and the CEO reviews the skip ("N/A" input row) as its backstop. **When genuinely unsure, run it** — a wasted Risk launch costs one stage; an unreviewed security surface ships a risk.

When it runs, launch the **risk** agent once to review the architecture through both lenses in a single pass:

1. Read the architecture document, the milestone README, and the UI specification (when one exists).
2. **Security lens** — vulnerabilities, insecure patterns, and risky dependencies the milestone introduces: authentication and authorization boundaries, input handling and injection surfaces, secret handling, sensitive-data storage and transit, and the trust assumptions of every new dependency.
3. **Performance lens** — hot paths, state-update frequency, memory footprint, rendering and query cost, and unbounded growth, against the architecture document's Performance Budget.
4. Write both lens sections to `artifacts/milestone-{N}-{slug}/reviews/risk.md`, each finding carrying severity, its cited category or budget, the affected module or path, and a remediation recommendation. **Both sections appear even when one is empty** — "No findings" is a result.
5. End the file with the two flag lines, both mandatory and both parsed by `/agent-code`:
   - `**Security implementation review required**: Yes/No` — Yes whenever the milestone touches auth, input handling, new dependencies, or sensitive data.
   - `**Performance measured check required**: Yes/No` — Yes whenever the plan sets a budget this milestone exercises.

   A Yes on either commits `/agent-code` to a `reviews/risk-impl.md` at milestone completion. When unsure, answer Yes.
6. Any **Critical** finding blocks the milestone until remediated or rolled into a CEO Approval Condition. Any finding that breaks a performance budget must be resolved or explicitly accepted by Product before CEO review.

Input to pass: the paths of the milestone definition, architecture document, and UI specification.

**Stage trigger:** Stage 4 starts after Stage 3 completes. If Risk requires architectural changes, return to Stage 2a for revision and re-run Stage 3 against the revised architecture.

### Stage 4 — CEO Final Review

After Stage 3 completes, launch the **ceo** agent to:

1. Read the Stage 1–3 artifacts per the **Read set** in `agents/ceo.md` — that section bounds what the CEO opens; do not restate or widen it in the invocation.
2. Produce the review using `templates/CEO_REVIEW.md` — copy it, fill in every section, and list all five inputs reviewed by path; a skipped stage's input row and section read "N/A — <stage> skipped: <reason>", per the template.
3. Save the review to `artifacts/milestone-{N}-{slug}/reviews/ceo.md`.
4. Produce a verdict — **APPROVED**, **APPROVED WITH CONDITIONS**, or **REVISION REQUIRED** — recorded as the review's single `**Verdict**:` line with exactly one of the three strings, per `templates/CEO_REVIEW.md`. This skill's revision handling and `/agent-code`'s Pre-Flight both parse that `**Verdict**:` line.

Input to pass: the milestone directory path and the template `templates/CEO_REVIEW.md`. The CEO reads its own set — do not paste artifact bodies into the invocation; this is the most expensive stage in the pipeline and its read set is deliberately bounded.

**If REVISION REQUIRED** (read from the review's `**Verdict**:` line): the CEO's Revision Requests identify which agent owns each change. Re-run the affected stage with the revision notes. If the revision touched the architecture — a Stage 2a re-run, or a UI revision that changes the architecture — re-run Stage 3 (Risk) on the revised plan **before** the CEO re-review, so the CEO never re-reviews against a stale risk position. Then re-run the CEO review on the revised plan. Planning does not advance until the CEO issues APPROVED or APPROVED WITH CONDITIONS. **Revision cap:** allow at most 3 revision cycles (one cycle = re-running the affected stages plus one CEO re-review). If the third cycle still ends in REVISION REQUIRED, stop the run and escalate to the user with a summary of the unresolved objections — do not keep looping.

**After any approval-level verdict**, the orchestrator backfills — no agent launch. This is pure transcription from the CEO review (the same operation `/agent-code`'s Pre-Flight performs as a repair when it finds the table missing or stale): (a) copy the conditions into the **CEO Approval Conditions** table in the milestone README (`artifacts/milestone-{N}-{slug}/README.md`, table defined by `templates/MILESTONE_DEFINITION.md`) — one row per condition with its source and Status Open, or a single "None — verdict was APPROVED" row; (b) add a `../README.md § CEO Approval Conditions` row to the Context Manifest of every task file a condition names; and (c) set the README's Status to CEO-Approved. `/agent-code` reads the conditions from the README table (its Pre-Flight may still cross-check them against the CEO review); Coder tracks them during engineering and Reviewer and Product verify them on completion.

### Revision Handling

When an agent revises a file during a re-run of an earlier stage (for example, the Architect rewriting the milestone's `architecture.md` to address a CEO Revision Request), the revision happens **in place** — the existing file is overwritten. Full historical diffs are preserved by git, not by filename churn.

**Revised design docs invalidate manifests.** A revision to `architecture.md`, `ui.md`, or a supplemental design doc can move or remove the section anchors that task-file Context Manifests cite — and a stale anchor silently defeats the minimal-context contract. On every such revision, the revising agent re-checks each of its returned manifest rows against the new document and returns corrected rows in its completion report; the orchestrator re-runs the Stage 2c application for the affected tasks before any downstream stage reads them.

**Git is the revision record** — no hand-maintained revision tables; `git log --follow <path>` and `git diff` are what the CEO re-reviews against (`docs/FILE_CONVENTIONS.md` → Revisions).

### Output

Summarize the run:

1. What was planned — milestone scope, key architecture decisions, UI highlights.
2. Risk findings by lens, and their resolution status.
3. Which of the two implementation-review flags Risk set, and what that commits `/agent-code` to at milestone completion.
4. CEO verdict and any Approval Conditions or Revision Requests.
5. Next step — if the verdict is approval-level, the milestone is ready for `/agent-code`.

Do NOT proceed to implementation. The planning stage ends with the CEO verdict. Do NOT write any artifact to `docs/`; that directory is reference-only.
