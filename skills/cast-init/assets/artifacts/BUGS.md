<!-- TEMPLATE INSTRUCTIONS
  FILE: BUGS.md
  PURPOSE: Central bug tracking log for the project. This file is the SINGLE CANONICAL
           SCHEMA for bug entries — agents (Bug Gatherer, Debugger, Coder, Tester, Product)
           reference this format rather than restating it.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name throughout.
  - Replace [PLATFORM_LIST] with the platforms your project targets (e.g., "iOS, Android, Web").
  - Add bug entries as they are discovered using the BUG-XXX format below.
  - Bugs live in ONE list and carry their status — they are never moved between sections.
  - Keep the Regression Checklist updated with critical paths that must be verified after each fix.
  - Severity levels: Critical / High / Medium / Low (defined in the schema below).
  - Frequency levels: Always / Intermittent — N of M / Observed once / Unknown.
-->

# [PROJECT_NAME] — Bug Tracking Log

This file is the single canonical schema for bug entries. All agents file, update, and verify bugs in exactly the format defined here.

---

## Bug Lifecycle

**ID convention**: `BUG-XXX` — sequential, zero-padded, never reused (e.g., `BUG-001`, `BUG-042`).

**Status flow**: `New → Triaged → In Progress → Fixed → Verified → Closed`

**Terminal states**: `Closed` / `Won't Fix` / `Duplicate` / `Cannot Reproduce` — once set, the entry never advances again. `Won't Fix` is the status a "Not a Bug" triage outcome maps to, and always carries a rationale in Notes.

**Deferred is an OPEN held state, not terminal.** A Deferred bug stays open until Product re-triages it — which happens at every `/agent-code` milestone-completion checkpoint and at `/agent-plan` Stage 1 — and either schedules it (back into the flow), re-defers it with an updated rationale, or closes it as `Won't Fix`.

**Severity**: `Critical` (product unusable or data at risk, no workaround) / `High` (major feature broken or wrong output; workaround cumbersome) / `Medium` (edge-case misbehavior; straightforward workaround) / `Low` (cosmetic or textual; no functional impact)

**Frequency**: `Always` / `Intermittent — N of M` / `Observed once` / `Unknown`

**Field ownership** — who writes what, and when. This table is **canonical**: agent files and pipeline skills cite it rather than restating status ownership.

| Owner | Writes | Status set |
|---|---|---|
| **Bug Gatherer** | Files the initial entry: ID, Description, Expected, Actual, Steps to Reproduce, Platform, Frequency, Evidence, Likely Files, Regression, Related Issues, initial Severity | `New` (or `Duplicate` at filing, when the report duplicates an existing entry — cite the original ID in Related Issues) |
| **Product** | Triages: sets final Severity, accepts/rejects/defers; re-triages `Deferred` entries at `/agent-code` milestone completion and `/agent-plan` Stage 1 | `Triaged` (or `Won't Fix` / `Deferred`) |
| **Debugger** | Investigation fields: Root Cause, Affected Module(s), Alternative Solutions, Recommended Fix, Assigned To, Investigation Date | `In Progress` (or `Cannot Reproduce` after an investigation that fails to reproduce the bug) |
| **Coder** | Resolution fields at fix time: Commit, Files Changed, Regression Notes | `Fixed` |
| **Tester / Product** | Tester confirms the fix; Product signs off | `Verified` → `Closed` |

Bugs never move between file sections — the entry stays in place and its **Status** field advances.

---

## Bug Entry Format

```
### BUG-XXX: [Short Title]
- **Status**: New / Triaged / In Progress / Fixed / Verified / Closed / Cannot Reproduce / Duplicate / Won't Fix / Deferred
- **Severity (initial)**: Critical | High | Medium | Low   _(set by Bug Gatherer)_
- **Severity (final)**: Critical | High | Medium | Low   _(set by Product at triage)_
- **Description**: [Detailed description of the bug and its impact on the user experience.]
- **Expected**: [What should happen.]
- **Actual**: [What actually happens.]
- **Steps to Reproduce**:
  1. [Step one]
  2. [Step two]
  3. [Step three]
- **Platform**: [All | [PLATFORM_LIST]]
- **Frequency**: Always | Intermittent — [N] of [M] | Observed once | Unknown
- **Evidence**: [Link to screenshot, recording, or log. Or: "None available."]
- **Likely Files**:
  - `[path/to/file]`
- **Regression**: [Yes / No — if yes, what changed since it last worked. Or: "Unknown."]
- **Related Issues**: [Related bug IDs or tasks. Or: "None."]

_Investigation (written by Debugger):_
- **Root Cause**: [Why the defect occurs.]
- **Affected Module(s)**: [Files or modules involved.]
- **Alternative Solutions**: [At least two approaches with trade-offs, for non-trivial bugs.]
- **Recommended Fix**: [Debugger's preferred approach and why.]
- **Assigned To**: [Coder or Refactor]
- **Investigation Date**: [YYYY-MM-DD]

_Resolution (written by Coder at fix time):_
- **Commit**: `[commit hash or reference]`
- **Files Changed**:
  - `[path/to/file]`
- **Regression Notes**: [Areas to watch for regressions introduced by the fix.]

- **Notes**: [Any additional context, workarounds, or severity rationale.]
```

---

## Bugs

_No bugs recorded yet._

---

## Regression Checklist

**Owner: Tester.** Tester maintains this table and verifies each critical path after significant fixes or refactors.

| # | Area | Check Description | Last Verified | Verified By |
|---|------|-------------------|--------------|-------------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

---

_Last updated: [YYYY-MM-DD]_
