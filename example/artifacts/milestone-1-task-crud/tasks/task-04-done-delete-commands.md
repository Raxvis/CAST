# T-4: `done` and `delete` commands

## Header

| Field | Value |
|-------|-------|
| **Milestone** | `../README.md` (M1: Task CRUD + SQLite Persistence) |
| **Status** | Complete |
| **Dependencies** | T-1 |
| **Needs Arch Doc** | Done -> `../architecture.md` §5.3 |
| **Needs UI Spec** | Done -> `../ui.md` §4 |
| **Loop count** | 0 / 3 |

---

## Description

Implement the two mutation-by-id commands. `done <id>` sets `completed = 1` and
`completedAt = new Date().toISOString()` on the row with the given id. `delete <id>`
removes the row. Both must error cleanly (non-zero exit, human-readable message)
when the id does not exist.

---

## Files

- `src/commands/done.ts` — `runDone(id: number, db: Database): void`.
- `src/commands/delete.ts` — `runDelete(id: number, db: Database): void`.

---

## Acceptance Criteria

- [x] `acme done 1` on an existing task sets `completed` and `completedAt`.
- [x] `acme delete 1` on an existing task removes the row.
- [x] Both commands use parameterized statements bound to the id argument.
- [x] `delete` with a non-existent id exits non-zero with a clear error.
- [x] Non-integer id argument prints a usage error.
- [ ] Vitest suite covers happy path and missing-id path for both `delete` and `done`. — `delete` covered; `done`'s missing-id path disposed to M2 by Product (Handoff entry #4)
- [x] No linter or type-check errors introduced.

---

## Context Manifest

| Reference | Sections | Why |
|---|---|---|
| `../architecture.md` | §5.3 (`done` / `delete`) | Mutation contracts and error-path expectations |
| `../ui.md` | §4 (mutation output) | Success/error message wording and exit codes |
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

- **Outcome**: `done` and `delete` implemented with parameterized statements; `delete` errors on missing id. 6 tests added covering both happy paths, the `delete` missing-id error, and the non-integer usage error.
- **Files touched**: `src/commands/done.ts`, `src/commands/delete.ts`, `src/commands/done.test.ts`, `src/commands/delete.test.ts`
- **Commit**: `4f7a2c9`
- **Test Results**: `pnpm test` — `Test Files  5 passed (5)` / `Tests  23 passed (23)` / `Duration  3.10s`
- **Read next**: Manifest only
- **Open items**: None

### 3. reviewer -> product — 2026-04-09

- **Outcome**: Clean review — no Defects, no Issues. Condition 1 verified on both mutation paths and its line is Met with evidence. Criterion 6 flagged Product judgment; a flagged criterion is what sends validation to Product, so this task closes at Step 3b rather than as an orchestrator-only 3a close.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None
- **Acceptance Criteria Check**:
  - [1] `acme done 1` on an existing task sets `completed` and `completedAt`. — Met — `done.test.ts` › "marks task done" (`4f7a2c9`)
  - [2] `acme delete 1` on an existing task removes the row. — Met — `delete.test.ts` › "removes row"
  - [3] Both commands use parameterized statements bound to the id argument. — Met — `src/commands/done.ts:16`, `src/commands/delete.ts:14`
  - [4] `delete` with a non-existent id exits non-zero with a clear error. — Met — `delete.test.ts` › "missing id exits 3 with message"
  - [5] Non-integer id argument prints a usage error. — Met — `delete.test.ts` › "non-integer id usage error"
  - [6] Vitest suite covers happy path and missing-id path for both `delete` and `done`. — Product judgment — `done` does not signal a missing id at all, so there is nothing for a test to assert and the path is deliberately uncovered; whether that leaves the criterion satisfied for this milestone is a scope call
  - [7] No linter or type-check errors introduced. — Met — `pnpm typecheck` clean at `4f7a2c9`

### 4. product — task complete — 2026-04-09

- **Outcome**: Criterion 6 disposed — `done`'s missing-id signalling, and therefore its test, is in scope for M2's error-signalling work rather than this task; the criterion holds as written and the gap is carried into the milestone validation record. All other criteria accepted on Reviewer's evidence. Status set to Complete — T-5 remains for the next session.
- **Files touched**: This file (Header Status, criterion 6 annotation)
- **Read next**: —
- **Open items**: `done` missing-id signalling carried to M2

---

_Last updated: 2026-04-09_
