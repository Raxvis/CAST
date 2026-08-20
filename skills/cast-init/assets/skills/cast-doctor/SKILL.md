---
name: cast-doctor
description: >-
  Run a health check on an installed CAST workflow: verify structural and state
  invariants (bug index, task indexes, STANDUP grammar, bounded logs, resolving
  references), find installed documentation the codebase already expresses
  (model-aware prune prescriptions in two tiers), and find gaps the docs should
  cover but don't. Use when the user says "cast doctor", "check CAST health",
  "audit the docs", "slim the docs", after upgrading models, or every few
  milestones. Writes the report to artifacts/DOCTOR.md; treats only
  user-approved prescriptions.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /cast-doctor maintenance skill. It health-checks an
installed CAST workflow at any time (the run-anytime counterpart to /cast-init's
one-shot Phase 6 validation), prescribes documentation pruning gated on the Context
Inference Bar in docs/MODEL_OPTIMIZATION.md, and finds documentation coverage gaps.
It never edits project source code — only the CAST install itself.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.

INSTALLATION: This skill installs to `.claude/skills/cast-doctor/SKILL.md` in your
target project (done automatically by /cast-init). Invoke it with `/cast-doctor`
(full run) or `/cast-doctor checkup` (report only).
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /cast-doctor — Install Health and Documentation Audit

Examine the CAST install in [PROJECT_NAME], diagnose problems, and treat what the user approves. Three functions in one pass:

1. **State** — verify the structural and state invariants of the install (the run-anytime counterpart to `/cast-init`'s one-shot Phase 6 validation, plus the drift invariants nothing else checks between installs).
2. **Documentation diet** — find installed documentation whose content the codebase itself already expresses. Capable models infer layout, naming, tech stack, and standard practices directly from code; docs that restate them are context weight. Pruning is prescribed in two tiers, gated on the **Context Inference Bar** in `docs/MODEL_OPTIMIZATION.md`.
3. **Coverage** — find what the docs should record but don't: decisions never written down, budgets never filled in, queued documentation debt.

The report lives at `artifacts/DOCTOR.md` — one bounded file, overwritten each run; git history keeps prior reports.

## Modes

- **Full** (default, `/cast-doctor`): all six phases — findings are prescribed, approved, treated, and verified.
- **Checkup** (`/cast-doctor checkup`): Phases 1–3 only — examine, diagnose, write the report, stop before the approval gate. Any run in a non-interactive session downgrades to Checkup automatically: nothing destructive happens without a live approval.

## Safety Rules

These override anything below on conflict:

1. **Read-only until Treat.** Phases 1–3 write nothing except `artifacts/DOCTOR.md`.
2. **The doctor treats the CAST install, never the codebase.** In scope: `docs/`, `.claude/agents/`, `.claude/skills/`, root `CLAUDE.md`, and the `artifacts/` state files. Project source code, tests, and build configuration are never edited, built, or run.
3. **No content removal without itemized approval.** Each diet prescription is approved individually. Mechanical state corrections that follow an already-written canonical rule (e.g. "on a bug-index mismatch, the bug file wins" — `artifacts/BUGS.md`) may be batch-approved as a category.
4. **Rescue before delete.** When a trim or delete would remove a decision, constraint, or rationale embedded in otherwise-mechanical content, the same prescription moves it into `docs/DESIGN_RATIONALE.md` (or the surviving parent doc) first. The rescue destination is named before approval; user approves rescue and removal as one item.
5. **Work output goes to `artifacts/` only.** The report is `artifacts/DOCTOR.md`; never write work output into `docs/` or `templates/`.
6. **Read the previous report before overwriting it.** Carry statuses forward (see Re-runs below). Prescriptions the user previously **Declined** stay declined and are not re-argued — unless the model map changed since the run that declined them, which re-opens them with a note.
7. **Clean git tree before Treat.** Uncommitted changes (other than `artifacts/DOCTOR.md` itself) mean treatment edits can't be reviewed or rolled back in isolation — ask the user to commit or stash first. In a non-git project, warn that rollback is manual and get explicit confirmation.

## Phase 1 — Examine

Read, in order (no writes):

1. `artifacts/DOCTOR.md` if it exists — the previous run's findings and statuses.
2. Root `CLAUDE.md` — the `Adopted with CAST v<X.Y.Z>` stamp and the Memory Imports block (which `@path` lines are live).
3. **The model map**: `grep -n "^model:" .claude/agents/*.md`. Resolve every `inherit` to the session model (the model executing this skill). Note pins.
4. The `docs/` inventory and `docs/README.md`'s index.
5. The `artifacts/` state files (`BUGS.md`, `STANDUP.md`, `AGENT_STATE.md`) and the milestone directory listing (Headers and review filenames only — not task bodies).
6. `docs/CHANGELOG.md` → Upcoming Documentation Work (coverage input).

Then build each candidate doc's **consumer set**: every agent file and skill under `.claude/` that cites the doc's path, plus the orchestrating session itself when the doc is a live Memory Import in `CLAUDE.md`. A doc's **bar model** is the least capable model in its consumer set, judged against the Context Inference Bar table in `docs/MODEL_OPTIMIZATION.md`. This is what makes right-sized rosters behave correctly: a doc cited by a Haiku-pinned utility agent keeps its mechanical content regardless of how capable the session model is.

## Phase 2 — Diagnose

Run the Check Catalog below. Every finding gets: an ID (`S-`/`D-`/`C-` prefix), evidence (paths and line references), a severity (**Error / Warning / Note** for state findings; **Tier A / Tier B** for diet), and a draft prescription.

**Re-runs:** match findings against the previous report by content key (catalog check + target path/section), not ID position. Matched findings keep their ID and gain `Recurring (xN)`. `Treated`/`Verified` findings that reappear are flagged as **regressions**. `Declined` carries forward silently unless the model map changed.

## Phase 3 — Prescribe

Overwrite `artifacts/DOCTOR.md` using the skeleton below. Present the user a summary — counts by category, tier, and severity, plus the estimated per-session context savings if all open diet prescriptions were treated. **In Checkup mode, stop here.**

```markdown
# [PROJECT_NAME] — CAST Doctor Report

**Run**: <ISO date> | **Stamp**: Adopted with CAST v<X.Y.Z> | **Mode**: <Full / Checkup>
**Model map**: session <model>; pins: <agent: model, … or "none — all inherit">
**Inference bar**: <cleared by all consumers / blocked: <doc> → <weakest consumer>>
**Previous run**: <date, or "first run">

## Summary
<counts: state E/W/N · diet by tier and verb · coverage · recurring/regressions;
estimated per-session context savings if all open diet prescriptions are treated>

## State Findings
### S-01 — <title>  (Status: Open | Approved | Treated | Verified | Declined | Recurring xN)
- **Check**: <catalog id> · **Severity**: Error | Warning | Note
- **Evidence**: <paths:lines>
- **Prescription**: <action>

## Diet Prescriptions
### D-01 — <doc, or doc → section>  (Status: <as above>)
- **Tier**: A | B (bar: <weakest consumer> — cleared | blocked)
- **Class**: <rubric class> · **Verb**: Trim | Demote | Merge | Delete | Rescue + Trim | Flag
- **Evidence**: <what already expresses this content> · **Citations**: <list, or "none">
- **Rescue**: <destination, or "n/a"> · **Savings**: <~N lines; note "paid every session" if memory-imported>

## Coverage Gaps
### C-01 — <title>  (Status: <as above>)
- **Missing**: <what> · **Evidence**: <where the gap shows> · **Route**: docs queue | direct treatment | user decision

## Treatment Log (this run)
- <ISO date> · <ID> · <what was done, files touched>

## Next checkup
Re-run /cast-doctor after model re-pins or a /cast-init upgrade, or every few
milestones. History: `git log -- artifacts/DOCTOR.md`.
```

## Phase 4 — Approval Gate

Walk the user through the open prescriptions by ID. Each diet prescription is approved, declined, or amended individually; state corrections following a written canonical rule may be approved as a batch; coverage routings are cheap and may be batch-approved too. Do not proceed on a vague go-ahead: "do whatever you think is best" gets the recommendation restated and confirmed, and "looks good, but maybe skip D-03" means D-03 is Declined, not quietly treated.

## Phase 5 — Treat

Execute approved prescriptions in this order, checking each off in DOCTOR.md's Status column as it completes (that column is the resume ledger if the run is interrupted):

1. **Rescues** — move rescued decisions into `docs/DESIGN_RATIONALE.md` (a dated decision entry) or the surviving parent doc.
2. **Trims and merges** — remove or fold the approved sections.
3. **Demotes** — remove Memory Import lines from `CLAUDE.md` (the file stays; the per-session cost goes).
4. **Deletes** — remove the file, deregister it from `docs/README.md`, and remove any Memory Import line.
5. **State corrections** — apply the canonical-rule fixes (index rows, statuses, archival nudges).
6. **Coverage routing** — append approved authorship gaps as `- cast-doctor | docs | <note>` entries to the current session in `artifacts/STANDUP.md` (Docs Writer drains them at the next completion checkpoint); treat approved restorations directly from git history.

For every treated doc, also update every citation listed in the prescription's evidence — no dangling references survive treatment.

## Phase 6 — Verify

1. Re-run the catalog checks touched by treatments; confirm they now pass.
2. Grep the install (`.claude/`, `docs/`, `templates/`, `artifacts/`, `CLAUDE.md`) for every removed doc path and removed `## heading` — zero hits, or the treatment isn't done.
3. Set treated statuses to `Verified` in DOCTOR.md.
4. Append the session to `artifacts/STANDUP.md` per its Entry Grammar: heading `### YYYY-MM-DD — cast-doctor — install health`, with `progress` entries for treatments and the `docs` entries from routing.
5. Present the closing summary: what was treated, measured context savings, what remains open or declined.

---

## Check Catalog

### State checks

| # | Check | Prescription shape |
|---|---|---|
| S1 | Agent roster complete (recorded opt-outs honored); frontmatter has `name`/`description`/`model`/`tools`; no `tools:` list includes `Task`; model pins are legal per the ladder in `docs/MODEL_OPTIMIZATION.md`; `effort:` values are legal (`low`–`max`), match the roster defaults in that ladder unless deliberately re-tuned, and no `effort: xhigh` pairs with an Opus 4.6 executing model | Correct frontmatter / flag for user |
| S2 | Every kept skill exists at `.claude/skills/<name>/SKILL.md` with frontmatter `name` equal to the directory; no superseded pre-1.0 command file (a leftover `/cast-init` migration Delete target) still registers a duplicate `/<name>` | Fix frontmatter / propose Delete |
| S3 | `CLAUDE.md` carries exactly one `Adopted with CAST v<X.Y.Z>` stamp; every live `@path` Memory Import resolves; report the total per-session import weight in lines | Fix stamp/imports; weight feeds the diet |
| S4 | No real unfilled `[PLACEHOLDER]` tokens in installed files (same scope and per-use whitelist as `/cast-init` validation check 1) | List for user to fill |
| S5 | docs/templates/artifacts split clean in both directions; no `TEMPLATE INSTRUCTIONS` block outside `templates/` | Move / strip |
| S6 | Every `artifacts/BUGS.md` index row's Status matches its per-bug file (file wins); Status values are legal lifecycle enums | Correct index rows (canonical rule) |
| S7 | Every milestone Task Index row points at an existing task file and vice versa; task Statuses are legal enums | Reconcile index/files |
| S8 | Every closed milestone (has `reviews/close.md` — or, pre-v3, `reviews/completion.md` with `validation.md` and `retrospective.md`) also has `ux.md` when `ui.md` exists, and `risk-impl.md` when either flag line in `reviews/risk.md` says Yes | Name the missing review; route to the owning agent |
| S9 | `artifacts/STANDUP.md` conforms to its Entry Grammar (well-formed session headings, known skill names, typed entries) | Correct malformed entries |
| S10 | Bounded files: no STANDUP sessions or closed AGENT_STATE rows older than the last completed milestone's first session remain in the live files | Flag archival overdue (`/agent-code`'s milestone-completion checkpoint owns the move) |
| S11 | Context Manifest rows in In Progress / Not Started task files resolve — cited file exists, cited section anchor exists | Fix the anchor or flag the manifest |
| S12 | Every `docs/*.md` has a row in `docs/README.md` and every index row points at an existing file | Register / deregister |
| S13 | The `CLAUDE.md` stamp version matches the local cast-init skill's `metadata.version` (when a local install exists) | Note "run /cast-init to upgrade" — never self-treat |

### Documentation diet

**The rubric.** Content the *code can say* is prune-eligible: directory trees restating `ls`; naming tables restating observable filenames; tech-stack, command, and dependency lists restating the package manifest; generic best-practice essays not tailored to this project; unfilled skeletons; tables of contents duplicating a directory listing. Content *only docs can say* is never pruned as a class: decisions, trade-offs, and rationale (the "why"); non-inferable constraints (invariants, budgets, security policies, thresholds); process contracts agents execute (entry grammars, lifecycles, loop rules); the historical record.

**Tiers.**

- **Tier A — always prunable, any model:** exact duplication of content canonical elsewhere in the install; unfilled skeletons paid every session through a live Memory Import (Demote the import, keep the file); stale or broken references; self-obsoleted content (e.g. `docs/FIRST_RUN.md` once STANDUP shows completed pipeline sessions); TOC duplication.
- **Tier B — prunable only above the Context Inference Bar** (`docs/MODEL_OPTIMIZATION.md`), judged per doc against its weakest consumer (Phase 1): mechanical restatements of code and structure; generic best-practice essays. A bar-blocked prescription is still reported — with the blocking consumer named — so the user understands what a model upgrade would unlock. Re-run after any model change.

**Never prune (files):** `docs/STAGE_CONTRACT.md` (every stage of every task reads it — it is already at its floor), `docs/PIPELINE_LOOP.md`, `docs/MODEL_OPTIMIZATION.md`, `docs/DESIGN_RATIONALE.md` (its own rules forbid deleting entries), `docs/CHANGELOG.md`. **Never prune (sections):** anything cited by path-and-section from a live task Context Manifest, an agent file, a skill, or `templates/*` — unless the prescription includes the exact citation updates.

**Anchor protection.** Every prescription lists its citation set: grep `.claude/ docs/ templates/ artifacts/ CLAUDE.md` for the doc path and each `## heading` the prescription removes. A cited section is kept, or the citations are updated in the same treatment; Phase 6 re-greps to prove nothing dangles.

**Verbs:** `Trim` (remove sections), `Demote` (remove the Memory Import line; file stays), `Merge` (fold into another doc, then delete the husk), `Delete` (whole file + deregistration), `Rescue + Trim`, `Flag` (structural anomaly needing a user decision rather than a removal).

**Starting dispositions** — priors, not verdicts; the diagnosis always weighs the doc's *actual* content:

| Doc | Prior |
|---|---|
| `docs/CODE_PATTERNS.md` | Skeleton (placeholder-dense) → Tier A **Demote** its always-on import; populated → Tier B **Trim** mechanical parts, keep chosen-convention policies |
| `docs/FILE_CONVENTIONS.md` | Tier B **Trim** the directory trees and naming quick-reference; the split rule, case rule, revision policy, and Anti-Patterns always stay. Never Delete |
| `docs/FRONTEND.md` / `BACKEND.md` / `CLI.md` / `MOBILE.md` | Tier B **Trim** generic best-practice essays; keep project-specific budgets, contracts, and platform decisions |
| `docs/CLAUDE_CODE_SETTINGS.md` | Tier A **Delete** candidate — restates external tool documentation; check citations first |
| `docs/FIRST_RUN.md` | Tier A **Delete** once the install's first run is verified (STANDUP shows completed sessions) |
| `docs/README.md` | Tier B **Trim** to a lean registry. Never Delete — registration is a process contract (`docs/FILE_CONVENTIONS.md` Anti-Patterns) |
| Root `CLAUDE.md` — Tech Stack, Project Structure, Style Conventions, Git Workflow sections | Tier B **Trim** — the highest-value target; every line is paid every session. Build & Test commands and the Directory Conventions stamp section stay |
| `docs/MVP_LAUNCH.md` | **Flag** — template-shaped file living in `docs/`; user decides (move to `templates/`, keep, or delete) |
| `docs/PRD.md`, `CONCEPT.md`, `GLOSSARY.md`, `ADDITIONAL.md`, `ERROR_HANDLING.md`, `TEST_FRAMEWORK.md`, `ASSETS.md` | Evaluate by rubric: filled decision/budget content stays; skeleton or generic sections follow the tiers |
| `docs/STAGE_CONTRACT.md`, `PIPELINE_LOOP.md`, `MODEL_OPTIMIZATION.md`, `DESIGN_RATIONALE.md`, `CHANGELOG.md` | Never prune |

### Coverage checks

| # | Check | Route |
|---|---|---|
| C1 | Un-drained `docs`-typed STANDUP entries older than the last completion checkpoint (documentation debt) | docs queue (re-surface) |
| C2 | `docs/CHANGELOG.md` → Upcoming Documentation Work rows, surfaced with their priority | docs queue / user decision |
| C3 | Decisions Log rows in `artifacts/AGENT_STATE.md` with project-wide implications not recorded in `docs/DESIGN_RATIONALE.md` | docs queue |
| C4 | Skeletons that should now be filled — milestones exist but `docs/PRD.md` (or budget/NFR sections) is still placeholder, so requirements live only in artifacts | user decision |
| C5 | Patterns recurring across Handoff Logs or Reviewer findings but absent from `docs/CODE_PATTERNS.md` | docs queue |
| C6 | Agents or skills citing a `docs/` path or section that does not exist | direct treatment |
| C7 | Model map *downgraded* since the previous report — previously pruned Tier B content may need restoring from git history | direct treatment (on approval) |

Authorship gaps route to the STANDUP docs queue (Docs Writer owns writing docs content); restorations and dangling-citation fixes are treated directly on approval.

---

Do NOT write any work artifact to `docs/` or `templates/`. The report and everything the doctor produces lives under `artifacts/`.
