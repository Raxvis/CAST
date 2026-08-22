<!-- TEMPLATE INSTRUCTIONS
  FILE: BUGS.md
  PURPOSE: Global bug INDEX for the project. Every bug lives in its own file
           (milestone-{N}-{slug}/bugs/bug-XXX-{slug}.md, or one-off/bugs/ for /agent-task
           work); this file assigns IDs and tracks one line per bug so triage sweeps read
           one small file instead of every report. This file is also the SINGLE CANONICAL
           definition of the bug lifecycle, severity scale, and field ownership — agents
           (Reviewer, UI, CEO, Coder, Product) reference these rules rather
           than restating them. Three agents file bugs: Reviewer at a task's review step,
           UI from the milestone UX review, and the CEO from the risk implementation review. The per-bug entry format lives in templates/BUG_REPORT.md.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name throughout.
  - Add one index row per bug as it is filed; never remove rows — terminal bugs keep
    their row with a terminal status.
  - Keep the Regression Checklist updated with critical paths that must be verified
    after each fix.
-->

# [PROJECT_NAME] — Bug Index

Every bug is a standalone file created from `templates/BUG_REPORT.md` and filed beside the work that surfaced it: `artifacts/milestone-{N}-{slug}/bugs/bug-XXX-{slug}.md` for pipeline work, `artifacts/one-off/bugs/bug-XXX-{slug}.md` for `/agent-task` work. This file is the index: it assigns IDs and carries one status line per bug. Triage and re-triage sweeps read this index and open only the bug files they act on.

---

## Bug Lifecycle

**ID convention**: `BUG-XXX` — sequential across the whole project (not per milestone), zero-padded, never reused (e.g., `BUG-001`, `BUG-042`). The next free ID is one greater than the highest ID in the index below.

**Status flow**: `New → Triaged → In Progress → Fixed → Verified → Closed`

**Terminal states**: `Closed` / `Won't Fix` / `Duplicate` / `Cannot Reproduce` — once set, the entry never advances again. `Won't Fix` is the status a "Not a Bug" triage outcome maps to, and always carries a rationale in the bug file's Notes.

**Deferred is an OPEN held state, not terminal.** A Deferred bug stays open until Product re-triages it — which happens at every `/agent-code` milestone-completion checkpoint and at `/agent-plan` Stage 1 — and either schedules it (back into the flow), re-defers it with an updated rationale, or closes it as `Won't Fix`.

**Severity**: `Critical` (product unusable or data at risk, no workaround) / `High` (major feature broken or wrong output; workaround cumbersome) / `Medium` (edge-case misbehavior; straightforward workaround) / `Low` (cosmetic or textual; no functional impact)

**Frequency**: `Always` / `Intermittent — N of M` / `Observed once` / `Unknown`

**Field ownership** — who writes what, and when. This table is **canonical**: agent files and pipeline skills cite it rather than restating status ownership. All fields live in the per-bug file; the owner also updates the bug's Status cell in the index below in the same step.

| Owner | Writes | Status set |
|---|---|---|
| **Reviewer** (at a task's review step), **UI** (from the UX review), **CEO** (from the risk implementation review) | Creates the bug file from `templates/BUG_REPORT.md` and adds its index row: ID, Description, Expected, Actual, Steps to Reproduce, Platform, Frequency, Evidence, Likely Files, Regression, Related Issues, initial Severity | `New` (or `Duplicate` at filing, when the report duplicates an existing entry — cite the original ID in Related Issues) |
| **Product** | Triages: sets final Severity, accepts/rejects/defers; re-triages `Deferred` entries at `/agent-code` milestone completion and `/agent-plan` Stage 1 | `Triaged` (or `Won't Fix` / `Deferred`) |
| **Coder (investigation)** | Investigation fields: Root Cause, Affected Module(s), Alternative Solutions, Recommended Fix, Assigned To, Investigation Date | `In Progress` (or `Cannot Reproduce` after an investigation that fails to reproduce the bug) |
| **Coder** | Resolution fields at fix time: Commit, Files Changed, Regression Notes | `Fixed` |
| **Coder / orchestrator** | Coder's red→green evidence confirms the fix (`Verified`); the orchestrating skill flips `Verified` → `Closed` when the resolving task passes validation — a transcription of facts already on record (red→green evidence, green final suite, task validated), not a judgment. Product re-reviews every closed bug at the milestone close | `Verified` → `Closed` |

A bug file never moves between directories — it stays where it was filed and its **Status** field advances (mirrored in the index).

---

## Index

| ID | Title | Severity (final) | Status | File |
|---|---|---|---|---|
| _No bugs recorded yet._ | | | | |

---

## Regression Checklist

**Owner: Coder.** Coder maintains this table and verifies each critical path after significant fixes or refactors.

| # | Area | Check Description | Last Verified | Verified By |
|---|------|-------------------|--------------|-------------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

---

_Last updated: [YYYY-MM-DD]_
