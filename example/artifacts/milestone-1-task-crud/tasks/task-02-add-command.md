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

### 1. product -> coder — 2026-04-09

- **Outcome**: Task released; dependency T-1 Complete.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 2. coder -> tester — 2026-04-09

- **Outcome**: `add` implemented with a prepared statement and bound parameters; prints new id.
- **Files touched**: `src/commands/add.ts`
- **Read next**: Manifest only — cover happy path and missing-title error
- **Open items**: None

### 3. tester -> reviewer — 2026-04-09

- **Outcome**: 4 tests added; `pnpm test` green (happy path, missing title, ISO `createdAt`, bound params).
- **Files touched**: `src/commands/add.test.ts`
- **Read next**: Manifest only
- **Open items**: None

### 4. reviewer -> product — 2026-04-09

- **Outcome**: Clean review — no Defects, no Issues. Condition 1 verified on the insert path.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 5. product — task complete — 2026-04-09

- **Outcome**: All acceptance criteria met; Status set to Complete.
- **Files touched**: This file (Header Status)
- **Read next**: —
- **Open items**: None

---

_Last updated: 2026-04-09_
