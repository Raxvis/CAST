# T-3: `list` command

## Header

| Field | Value |
|-------|-------|
| **Milestone** | `../README.md` (M1: Task CRUD + SQLite Persistence) |
| **Status** | Complete |
| **Dependencies** | T-1 |
| **Needs Arch Doc** | Done -> `../architecture.md` §5.2 |
| **Needs UI Spec** | Done -> `../ui.md` §3 |
| **Loop count** | 1 / 3 |

---

## Description

Implement the `list` command. By default prints only open tasks (where
`completed = 0`); with `--all` it also prints completed tasks. Output columns:
`ID  TITLE  STATUS  CREATED` separated by two spaces, one row per task. **Per CEO
Condition 3**, this command must detect a missing database file and run migrations
on first invocation rather than throwing — this is the path BUG-001 surfaced.

---

## Files

- `src/commands/list.ts` — `runList({ all: boolean }, db: Database): Task[]` plus
  CLI formatter.

---

## Acceptance Criteria

- [x] `acme list` on an empty DB prints a header row and no tasks.
- [x] `acme list` on a fresh machine (no DB file) creates the DB, runs
  migrations, and prints the empty list — does not crash (fixes BUG-001).
- [x] `--all` flag includes completed tasks; without it, only open tasks print.
- [x] Output format is exactly `ID  TITLE  STATUS  CREATED`.
- [x] Query uses parameterized binding for the `completed` filter.
- [x] Vitest suite covers: empty DB, mixed open/completed, `--all` flag, first-run migration.
- [x] No linter or type-check errors introduced.

---

## Context Manifest

| Reference | Sections | Why |
|---|---|---|
| `../architecture.md` | §5.2 (`list` command) | Query contract and formatter boundary |
| `../ui.md` | §3 (`list` output) | Column format and empty-state wording |
| `../README.md` | § CEO Approval Conditions | Conditions 1 (parameterized SQL) and 3 (first-run migration) name this task |
| `docs/CODE_PATTERNS.md` | TypeScript Style Conventions | Naming and module-layout rules |

---

## Handoff Log

### 1. orchestrator -> coder — 2026-04-09

- **Outcome**: Task released; dependency T-1 Complete.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 2. coder -> reviewer — 2026-04-09

- **Outcome**: `list` implemented with the `--all` flag and the column formatter. 5 tests added. **The fresh-machine first-run case fails** — `SqliteError: no such table: tasks` when `list` is the first-ever command. Handing off with the failure rather than fixing blind: criterion 2 is the one it breaks, and it is a real defect in the migration design, not a test bug.
- **Files touched**: `src/commands/list.ts`, `src/commands/list.test.ts`
- **Commit**: `9d4b1c7`
- **Test Results**: `pnpm test` — `Test Files  2 passed | 1 failed (3)` / `Tests  14 passed | 1 failed (15)` / `FAIL  src/commands/list.test.ts > fresh machine first run` / `SqliteError: no such table: tasks`
- **Read next**: Manifest only
- **Open items**: First-run path broken; blocks acceptance criterion 2

### 3. reviewer -> product — 2026-04-09

- **Outcome**: Test Results block present and honest — reviewed the diff anyway since Coder flagged the failure deliberately. One finding, classified **Defect**: first-run crash. Filed as BUG-001 (suggested severity High — the first-run experience is a milestone acceptance criterion and CEO Condition 3 names it). No Issues.
- **Files touched**: `../bugs/bug-001-list-first-run-crash.md`, `artifacts/BUGS.md` (index row)
- **Read next**: `../bugs/bug-001-list-first-run-crash.md`
- **Open items**: Awaiting Product triage
- Finding 1 — **Defect**, High — `list` on a machine with no database file throws instead of creating it. Violates criterion 2 and CEO Condition 3. Filed BUG-001.

### 4. product -> coder — 2026-04-09

- **Outcome**: BUG-001 triaged **Fix Now** (final severity High). The first-run experience is a milestone acceptance criterion — this cannot ship deferred. Loop count set to 1.
- **Files touched**: `../bugs/bug-001-list-first-run-crash.md` (Severity final, status Triaged)
- **Read next**: `../bugs/bug-001-list-first-run-crash.md`
- **Open items**: None

### 5. coder -> reviewer — 2026-04-09

- **Outcome**: Investigated before changing code (mechanism was not obvious from the diff — the symptom is in `list`, the cause is in `add`). Root cause: migration execution lived only on the `add` path, so any other command run first hits an empty database. Chose a central `ensureMigrations(db)` called at every command entry over patching `list` alone — the latter leaves the next new command with the same bug. Investigation written to the bug file; fixed and BUG-001 Resolution → Commit filled.
- **Files touched**: `src/commands/list.ts`, `src/db/connection.ts`, `src/commands/list.test.ts`, `../bugs/bug-001-list-first-run-crash.md`
- **Commit**: `a8f3d12`
- **Test Results**: `pnpm test` — `Test Files  3 passed (3)` / `Tests  17 passed (17)` / `Duration  2.41s`. Red→green proof: checked out `9d4b1c7` (pre-fix), ran `list.test.ts > fresh machine first run` → `FAIL  SqliteError: no such table: tasks`; returned to `a8f3d12` → `PASS`.
- **Read next**: Manifest only
- **Open items**: None

### 6. reviewer -> orchestrator — 2026-04-09

- **Outcome**: Clean review — no Defects, no Issues. Red→green evidence verified against `9d4b1c7`. Conditions 1 and 3 verified on the `list` path. All 7 criteria and the CEO Approval Condition line Met with evidence — closes at Step 3a, no Product spawn. BUG-001 carries Coder's red→green proof, so the orchestrator flips it Verified → Closed once this task passes validation; Product remains the verifier of record for Condition 3 at the milestone close.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None
- **Acceptance Criteria Check**:
  - [1] `acme list` on an empty DB prints a header row and no tasks. — Met — `list.test.ts` › "empty DB prints header only" (`a8f3d12`)
  - [2] `acme list` on a fresh machine creates the DB, runs migrations, and prints the empty list (fixes BUG-001). — Met — `list.test.ts` › "fresh machine first run" (red at `9d4b1c7`, green at `a8f3d12`)
  - [3] `--all` flag includes completed tasks; without it, only open tasks print. — Met — `list.test.ts` › "--all includes completed"
  - [4] Output format is exactly `ID  TITLE  STATUS  CREATED`. — Met — `src/commands/list.ts:31`; `list.test.ts` › "column format"
  - [5] Query uses parameterized binding for the `completed` filter. — Met — `src/commands/list.ts:22`
  - [6] Vitest suite covers: empty DB, mixed open/completed, `--all` flag, first-run migration. — Met — 7 tests in `a8f3d12`
  - [7] No linter or type-check errors introduced. — Met — `pnpm typecheck` clean at `a8f3d12`
  - [C-3] CEO Approval Condition 3 — migrations run on first invocation of any command. — Met — `ensureMigrations()` at every command entry (`a8f3d12`); `list.test.ts` › "fresh machine first run"

### 7. orchestrator — task complete — 2026-04-09

- **Outcome**: Step 3a clean close — every criterion and condition line Met with evidence (entry #6); Status set to Complete. BUG-001 advanced Fixed → Verified → Closed — an orchestrator transcription of facts already on record (red→green evidence, green final suite, task validated), not a judgment; Product re-reviews it at the milestone close.
- **Files touched**: This file (Header Status), `../bugs/bug-001-list-first-run-crash.md`, `artifacts/BUGS.md` (index row)
- **Read next**: —
- **Open items**: None

---

_Last updated: 2026-04-09_
