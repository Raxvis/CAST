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

- [x] `acme-todo list` on an empty DB prints a header row and no tasks.
- [x] `acme-todo list` on a fresh machine (no DB file) creates the DB, runs
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

### 1. product -> coder — 2026-04-09

- **Outcome**: Task released; dependency T-1 Complete.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 2. coder -> bug-gatherer — 2026-04-09

- **Outcome**: First-run smoke check crashed — `SqliteError: no such table: tasks` when `list` is the first-ever command. Defect, needs filing before the task can proceed.
- **Files touched**: `src/commands/list.ts` (in progress)
- **Read next**: Terminal transcript in the 2026-04-09 session of `artifacts/STANDUP.md`
- **Open items**: Defect blocks acceptance criterion 2 (first-run path)

### 3. bug-gatherer -> product — 2026-04-09

- **Outcome**: Filed BUG-001 (severity High) with repro steps.
- **Files touched**: `../bugs/bug-001-list-first-run-crash.md`, `artifacts/BUGS.md` (index row)
- **Read next**: `../bugs/bug-001-list-first-run-crash.md`
- **Open items**: Awaiting triage

### 4. product -> debugger — 2026-04-09

- **Outcome**: Triaged Fix Now — first-run experience violates CEO Condition 3.
- **Files touched**: `../bugs/bug-001-list-first-run-crash.md` (Severity final, status Triaged)
- **Read next**: `../bugs/bug-001-list-first-run-crash.md`
- **Open items**: None

### 5. debugger -> coder — 2026-04-09

- **Outcome**: Root cause found (migration execution lived only in the `add` path); recommended extracting idempotent `ensureMigrations(db)` called at the top of every command entry path. Loop count set to 1.
- **Files touched**: `../bugs/bug-001-list-first-run-crash.md` (Investigation section, status In Progress)
- **Read next**: `../bugs/bug-001-list-first-run-crash.md` § Investigation
- **Open items**: None

### 6. coder -> tester — 2026-04-09

- **Outcome**: `list` implemented and BUG-001 fixed (commit `a8f3d12`) — `ensureMigrations()` wired into all four command paths.
- **Files touched**: `src/commands/list.ts`, `src/db/connection.ts`
- **Read next**: Manifest only — include the first-run migration case in the suite
- **Open items**: None

### 7. tester -> reviewer — 2026-04-09

- **Outcome**: 7 tests added; `pnpm test` green including the fresh-machine first-run case. BUG-001 fix confirmed.
- **Files touched**: `src/commands/list.test.ts`
- **Read next**: Manifest only
- **Open items**: None

### 8. reviewer -> product — 2026-04-09

- **Outcome**: Clean review — no Defects, no Issues. Conditions 1 and 3 verified on the `list` path.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 9. product — task complete — 2026-04-09

- **Outcome**: All acceptance criteria met; Status set to Complete. BUG-001 advanced to Verified (Closed at milestone sign-off).
- **Files touched**: This file (Header Status), `../bugs/bug-001-list-first-run-crash.md`, `artifacts/BUGS.md` (index row)
- **Read next**: —
- **Open items**: None

---

_Last updated: 2026-04-09_
