# Acme Todo — Bug Index

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
| **Bug Gatherer** | Creates the bug file from `templates/BUG_REPORT.md` and adds its index row: ID, Description, Expected, Actual, Steps to Reproduce, Platform, Frequency, Evidence, Likely Files, Regression, Related Issues, initial Severity | `New` (or `Duplicate` at filing, when the report duplicates an existing entry — cite the original ID in Related Issues) |
| **Product** | Triages: sets final Severity, accepts/rejects/defers; re-triages `Deferred` entries at `/agent-code` milestone completion and `/agent-plan` Stage 1 | `Triaged` (or `Won't Fix` / `Deferred`) |
| **Debugger** | Investigation fields: Root Cause, Affected Module(s), Alternative Solutions, Recommended Fix, Assigned To, Investigation Date | `In Progress` (or `Cannot Reproduce` after an investigation that fails to reproduce the bug) |
| **Coder** | Resolution fields at fix time: Commit, Files Changed, Regression Notes | `Fixed` |
| **Tester / Product** | Tester confirms the fix; Product signs off | `Verified` → `Closed` |

A bug file never moves between directories — it stays where it was filed and its **Status** field advances (mirrored in the index).

---

## Index

| ID | Title | Severity (final) | Status | File |
|---|---|---|---|---|
| BUG-001 | `list` crashes with "no such table: tasks" on first invocation | High | Closed | `milestone-1-task-crud/bugs/bug-001-list-first-run-crash.md` |
| BUG-002 | `done <id>` silently succeeds on non-existent task ID | Low | Deferred | `milestone-1-task-crud/bugs/bug-002-done-silent-success.md` |

---

## Regression Checklist

**Owner: Tester.** Tester maintains this table and verifies each critical path after significant fixes or refactors.

| # | Area | Check Description | Last Verified | Verified By |
|---|------|-------------------|--------------|-------------|
| 1 | DB bootstrap | Migrations run on a fresh DB file (delete `~/.acme-todo/` and run any command) | 2026-04-10 | Product |
| 2 | `list` first-run | `acme list` on a machine with no prior state prints empty-state message and exits 0 | 2026-04-10 | Product |
| 3 | `done`/`delete` on non-existent ID | CLI signals failure (tracked via BUG-002; currently silent) | — | — |
| 4 | WAL mode persistence | `PRAGMA journal_mode;` returns `wal` after a migration run | 2026-04-09 | Reviewer |
| 5 | Index presence | `EXPLAIN QUERY PLAN SELECT * FROM tasks WHERE completed = 0` uses `idx_tasks_completed` | 2026-04-09 | Reviewer |

---

_Last updated: 2026-04-10_
