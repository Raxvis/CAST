---
name: cast-doctor
description: >-
  Run a health check on an installed CAST workflow: verify structural and state
  invariants (bug index, task backlog, task indexes, STANDUP grammar, bounded logs,
  resolving references), verify the source map (.claude/cast/SOURCES.md) still resolves
  and matches reality, and find coverage gaps (documentation debt, undocumented
  decisions). Use when the user says "cast doctor", "check CAST health", after moving
  documentation around, or every few milestones. Writes the report to
  artifacts/DOCTOR.md; treats only user-approved prescriptions.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /cast-doctor maintenance skill. It health-checks an
installed CAST workflow at any time (the run-anytime counterpart to /cast-init's
one-shot Phase 6 validation). v4 ships no documentation, so the v3 documentation-diet
function is gone; in its place the doctor verifies the SOURCE MAP — the file the whole
BYO-docs design hangs on. It never edits project source code or the project's own
documentation — only the CAST install itself.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.

INSTALLATION: This skill installs to `.claude/skills/cast-doctor/SKILL.md` in your
target project (done automatically by /cast-init). Invoke it with `/cast-doctor`
(full run) or `/cast-doctor checkup` (report only).
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /cast-doctor — Install Health Check

Examine the CAST install in [PROJECT_NAME], diagnose problems, and treat what the user approves. Three functions in one pass:

1. **State** — verify the structural and state invariants of the install (the run-anytime counterpart to `/cast-init`'s one-shot Phase 6 validation, plus the drift invariants nothing else checks between installs).
2. **Source map** — verify `.claude/cast/SOURCES.md` still tells the truth: every entry resolves, and the project's documentation reality hasn't drifted away from it. Planning trusts this file completely, so a stale map silently corrupts every future plan.
3. **Coverage** — find what should be recorded but isn't: un-drained documentation debt, decisions never written down, plans built while a source category sat empty.

The report lives at `artifacts/DOCTOR.md` — one bounded file, overwritten each run; git history keeps prior reports.

## Modes

- **Full** (default, `/cast-doctor`): all six phases — findings are prescribed, approved, treated, and verified.
- **Checkup** (`/cast-doctor checkup`): Phases 1–3 only — examine, diagnose, write the report, stop before the approval gate. Any run in a non-interactive session downgrades to Checkup automatically: nothing destructive happens without a live approval.

## Safety Rules

These override anything below on conflict:

1. **Read-only until Treat.** Phases 1–3 write nothing except `artifacts/DOCTOR.md`.
2. **The doctor treats the CAST install, never the codebase and never the user's documentation.** In scope: `.claude/agents/`, `.claude/skills/`, `.claude/cast/` (the source map, contracts, templates), the `CLAUDE.md` CAST section, and the `artifacts/` state files. Project source code, tests, build configuration, and the documentation the source map points at are examined but never edited.
3. **No removal without itemized approval.** Mechanical state corrections that follow an already-written canonical rule (e.g. "on a bug-index mismatch, the bug file wins" — `artifacts/BUGS.md`) may be batch-approved as a category.
4. **Work output goes to `artifacts/` only.** The report is `artifacts/DOCTOR.md`.
5. **Read the previous report before overwriting it.** Carry statuses forward (see Re-runs below). Prescriptions the user previously **Declined** stay declined and are not re-argued.
6. **Clean git tree before Treat.** Uncommitted changes (other than `artifacts/DOCTOR.md` itself) mean treatment edits can't be reviewed or rolled back in isolation — ask the user to commit or stash first. In a non-git project, warn that rollback is manual and get explicit confirmation.

## Phase 1 — Examine

Read, in order (no writes):

1. `artifacts/DOCTOR.md` if it exists — the previous run's findings and statuses.
2. Root `CLAUDE.md` — the `Adopted with CAST v<X.Y.Z>` stamp and the CAST section.
3. `.claude/cast/SOURCES.md` — every category, every entry.
4. The model map: `grep -n "^model:" .claude/agents/*.md`. Resolve every `inherit` to the session model; note pins.
5. The `artifacts/` state files (`BUGS.md`, `TASKS.md`, `STANDUP.md`, `AGENT_STATE.md`) and the milestone directory listing (Headers and review filenames only — not task bodies).

## Phase 2 — Diagnose

Run the Check Catalog below. Every finding gets: an ID (`S-`/`M-`/`C-` prefix), evidence (paths and line references), a severity (**Error / Warning / Note**), and a draft prescription.

**Re-runs:** match findings against the previous report by content key (catalog check + target path/section), not ID position. Matched findings keep their ID and gain `Recurring (xN)`. `Treated`/`Verified` findings that reappear are flagged as **regressions**. `Declined` carries forward silently.

## Phase 3 — Prescribe

Overwrite `artifacts/DOCTOR.md` using the skeleton below. Present the user a summary — counts by category and severity. **In Checkup mode, stop here.**

```markdown
# [PROJECT_NAME] — CAST Doctor Report

**Run**: <ISO date> | **Stamp**: Adopted with CAST v<X.Y.Z> | **Mode**: <Full / Checkup>
**Model map**: session <model>; pins: <agent: model, … or "none — all inherit">
**Source map**: <N entries across M categories; K unresolved; categories empty: <list or none>>
**Previous run**: <date, or "first run">

## Summary
<counts: state E/W/N · source-map findings · coverage · recurring/regressions>

## State Findings
### S-01 — <title>  (Status: Open | Approved | Treated | Verified | Declined | Recurring xN)
- **Check**: <catalog id> · **Severity**: Error | Warning | Note
- **Evidence**: <paths:lines>
- **Prescription**: <action>

## Source Map Findings
### M-01 — <title>  (Status: <as above>)
- **Check**: <catalog id> · **Severity**: Error | Warning | Note
- **Evidence**: <entry, and what was found on disk>
- **Prescription**: <map correction to propose, or user decision>

## Coverage Gaps
### C-01 — <title>  (Status: <as above>)
- **Missing**: <what> · **Evidence**: <where the gap shows> · **Route**: docs queue | direct treatment | user decision

## Treatment Log (this run)
- <ISO date> · <ID> · <what was done, files touched>

## Next checkup
Re-run /cast-doctor after documentation moves, model re-pins, or a /cast-init
upgrade, or every few milestones. History: `git log -- artifacts/DOCTOR.md`.
```

## Phase 4 — Approval Gate

Walk the user through the open prescriptions by ID. Source-map corrections are approved individually — the map is configuration the user owns; state corrections following a written canonical rule may be approved as a batch; coverage routings are cheap and may be batch-approved too. Do not proceed on a vague go-ahead: "do whatever you think is best" gets the recommendation restated and confirmed, and "looks good, but maybe skip M-03" means M-03 is Declined, not quietly treated.

## Phase 5 — Treat

Execute approved prescriptions in this order, checking each off in DOCTOR.md's Status column as it completes (that column is the resume ledger if the run is interrupted):

1. **Source-map corrections** — update `.claude/cast/SOURCES.md` entries (fix a moved path, remove an approved-dead entry, add an approved-missing one, refresh the Last updated line).
2. **State corrections** — apply the canonical-rule fixes (index rows, statuses, archival nudges).
3. **Coverage routing** — append approved authorship gaps as `- cast-doctor | docs | <note>` entries to the current session in `artifacts/STANDUP.md` (Docs Writer drains them at the next completion checkpoint, when a Documentation Home is declared); other approved coverage items are treated directly.

## Phase 6 — Verify

1. Re-run the catalog checks touched by treatments; confirm they now pass.
2. Re-resolve every source-map entry after map corrections — zero unresolved, or the treatment isn't done.
3. Set treated statuses to `Verified` in DOCTOR.md.
4. Append the session to `artifacts/STANDUP.md` per its Entry Grammar: heading `### YYYY-MM-DD — cast-doctor — install health`, with `progress` entries for treatments and the `docs` entries from routing.
5. Present the closing summary: what was treated, what remains open or declined.

---

## Check Catalog

### State checks

| # | Check | Prescription shape |
|---|---|---|
| S1 | Agent roster complete (recorded opt-outs honored); frontmatter has `name`/`description`/`model`/`tools`; no `tools:` list includes `Task`; `effort:` values are legal (`low`–`max`) | Correct frontmatter / flag for user |
| S2 | Every kept skill exists at `.claude/skills/<name>/SKILL.md` with frontmatter `name` equal to the directory; no superseded pre-1.0 command file still registers a duplicate `/<name>` | Fix frontmatter / propose Delete |
| S3 | `CLAUDE.md` carries exactly one `Adopted with CAST v<X.Y.Z>` stamp and the CAST section points at `.claude/cast/SOURCES.md` | Fix stamp / section |
| S4 | No real unfilled `[PLACEHOLDER]` tokens in installed files (same scope and per-use whitelist as `/cast-init` validation check 1) | List for user to fill |
| S5 | `.claude/cast/` is complete — `SOURCES.md`, `PIPELINE_LOOP.md`, `STAGE_CONTRACT.md`, the `templates/` skeletons, and `install-manifest.txt` (what makes `install.sh --upgrade` work) all present; no `TEMPLATE INSTRUCTIONS` block survives in any `artifacts/` instance | Re-install from cast-init / strip |
| S6 | Every `artifacts/BUGS.md` index row's Status matches its per-bug file (file wins); Status values are legal lifecycle enums | Correct index rows (canonical rule) |
| S7 | Every milestone Task Index row points at an existing task file and vice versa; task Statuses are legal enums; every `artifacts/TASKS.md` index row has its entry block, statuses legal per its lifecycle | Reconcile index/files |
| S8 | Every closed milestone (has `reviews/close.md`) also has `ux.md` when `ui.md` exists, and `risk-impl.md` when either flag line in `reviews/risk.md` says Yes | Name the missing review; route to the owning agent |
| S9 | `artifacts/STANDUP.md` conforms to its Entry Grammar (well-formed session headings, known skill names, typed entries) | Correct malformed entries |
| S10 | Bounded files: no STANDUP sessions or closed AGENT_STATE rows older than the last completed milestone's first session remain in the live files | Flag archival overdue (`/agent-code`'s milestone-completion checkpoint owns the move) |
| S11 | Context Manifest rows in In Progress / Not Started task files resolve — cited file exists, cited section anchor exists — and cite milestone artifacts only, never a source-map location | Fix the anchor or flag the manifest |
| S12 | Milestone READMEs planned under v4 carry a Standards Digest section (a filled table, or an explicit N/A line naming why) | Flag for Product at the next planning touch |
| S13 | The `CLAUDE.md` stamp version matches the local cast-init skill's `metadata.version` (when a local install exists) | Note "run /cast-init to upgrade" — never self-treat |

### Source-map checks

| # | Check | Prescription shape |
|---|---|---|
| M1 | Every location entry resolves — the path exists, a glob matches at least one file, a directory contains at least one markdown file | Propose the corrected path (search for the moved file by name), or removal if truly gone |
| M2 | Required categories carry either entries or an honest `_None declared._` — never a heading with a dangling or half-filled table | Fix the table shape |
| M3 | Reality drift: documentation-shaped material in the repo that no category maps (README-adjacent doc directories, CONTRIBUTING/ARCHITECTURE/TESTING files, ADR directories) — candidates the user may want mapped | Propose additions; user decides |
| M4 | The Documentation Home entries are writable locations inside the repo (not URLs, not paths outside the project) | Flag for user |
| M5 | `_Last updated_` older than the newest milestone directory **and** any M1–M3 finding present — the map predates recent work and nobody refreshed it | Bundle with the specific fixes above |

### Coverage checks

| # | Check | Route |
|---|---|---|
| C1 | Un-drained `docs`-typed STANDUP entries older than the last completion checkpoint (documentation debt — including entries stranded because no Documentation Home is declared) | docs queue re-surface / user decision on declaring a Home |
| C2 | Decisions Log rows in `artifacts/AGENT_STATE.md` with project-wide implications not recorded anywhere the source map points | docs queue |
| C3 | Milestones planned while a required source category sat `_None declared._` — noted in their READMEs; if the material exists now, flag that re-planning future work will pick it up | user decision |
| C4 | Agents or skills citing a path that does not exist | direct treatment |

Authorship gaps route to the STANDUP docs queue (Docs Writer owns writing documentation content); dangling-citation fixes are treated directly on approval.

---

Do NOT write any work artifact outside `artifacts/`, and never edit the documentation the source map points at — reading it to diagnose drift is the boundary. The report and everything the doctor produces lives under `artifacts/`.
