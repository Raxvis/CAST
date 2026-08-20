# T-2: `add` command

## Header

| Field | Value |
|-------|-------|
| **Milestone** | `../README.md` (M1: Task CRUD + SQLite Persistence) |
| **Status** | Complete |
| **Dependencies** | T-1 |
| **Needs Arch Doc** | Done -> `../architecture.md` §5.1 (Commands) |
| **Needs UI Spec** | Done -> `../ui.md` §2 |
| **Loop count** | 0 / 3 |

---

## Description

Implement the `add` command. Takes a single positional argument (the task title),
inserts a new row into `tasks` with `completed = 0`, `createdAt = new Date().toISOString()`,
`completedAt = null`, and prints the new integer id on stdout.

---

## Files

- `src/commands/add.ts` — `runAdd(title: string, db: Database): number` plus a
  thin CLI wrapper that prints the id.

---

## Acceptance Criteria

- [x] `acme-todo add "buy milk"` prints the new task id to stdout and exits 0.
- [x] Insert uses a prepared statement with bound parameters (no string interpolation).
- [x] Missing title argument prints an error and exits non-zero.
- [x] Inserted row has `completed = false` and a valid ISO `createdAt`.
- [x] Vitest suite covers happy path and missing-title error path.
- [x] No linter or type-check errors introduced.

---

## Context Manifest

| Reference | Sections | Why |
|---|---|---|
| `../architecture.md` | §5.1 (`add` command) | Handler signature and insert contract |
| `../ui.md` | §2 (`add` output) | Stdout format and error wording |
| `../README.md` | § CEO Approval Conditions | Condition 1 (parameterized SQL) names this task |
| `docs/CODE_PATTERNS.md` | TypeScript Style Conventions | Naming and module-layout rules |

---

## Handoff Log

### 1. orchestrator -> coder — 2026-04-09

- **Outcome**: Task released; dependency T-1 Complete.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 2. coder -> reviewer — 2026-04-09

- **Outcome**: `add` implemented with a prepared statement and bound parameters; prints the new id. 4 tests added covering the happy path, missing title, ISO `createdAt`, and bound params.
- **Files touched**: `src/commands/add.ts`, `src/commands/add.test.ts`
- **Commit**: `e3a94f0`
- **Test Results**: `pnpm test` — `Test Files  2 passed (2)` / `Tests  10 passed (10)` / `Duration  0.88s`
- **Read next**: Manifest only
- **Open items**: None

### 3. reviewer -> product — 2026-04-09

- **Outcome**: Clean review — no Defects, no Issues. Condition 1 verified on the insert path. All 6 criteria Met; routing to Product anyway (Step 3b — this task carries a CEO Approval Condition).
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None
- **Acceptance Criteria Check**:
  - [1] `acme-todo add "buy milk"` prints the new task id to stdout and exits 0. — Met — `add.test.ts` › "prints new id, exits 0" (`e3a94f0`)
  - [2] Insert uses a prepared statement with bound parameters (no string interpolation). — Met — `src/commands/add.ts:14` (`.prepare().run(params)`); `add.test.ts` › "binds params"
  - [3] Missing title argument prints an error and exits non-zero. — Met — `add.test.ts` › "missing title exits 1"
  - [4] Inserted row has `completed = false` and a valid ISO `createdAt`. — Met — `add.test.ts` › "ISO createdAt, completed false"
  - [5] Vitest suite covers happy path and missing-title error path. — Met — 4 tests in `e3a94f0`
  - [6] No linter or type-check errors introduced. — Met — `pnpm typecheck` clean at `e3a94f0`

### 4. product — task complete — 2026-04-09

- **Outcome**: All acceptance criteria met; Status set to Complete.
- **Files touched**: This file (Header Status)
- **Read next**: —
- **Open items**: None

---

_Last updated: 2026-04-09_
