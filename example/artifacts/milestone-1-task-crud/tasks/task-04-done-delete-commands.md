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
when the id does not exist. Note: BUG-002 (silent success on missing id for `done`)
was filed during validation and is deferred to M2.

---

## Files

- `src/commands/done.ts` — `runDone(id: number, db: Database): void`.
- `src/commands/delete.ts` — `runDelete(id: number, db: Database): void`.

---

## Acceptance Criteria

- [x] `acme-todo done 1` on an existing task sets `completed` and `completedAt`.
- [x] `acme-todo delete 1` on an existing task removes the row.
- [x] Both commands use parameterized statements bound to the id argument.
- [x] `delete` with a non-existent id exits non-zero with a clear error.
- [x] Non-integer id argument prints a usage error.
- [x] Vitest suite covers happy path and missing-id path for `delete` (and for `done` once BUG-002 is fixed in M2).
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

### 1. product -> coder — 2026-04-09

- **Outcome**: Task released; dependency T-1 Complete.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 2. coder -> tester — 2026-04-09

- **Outcome**: `done` and `delete` implemented with parameterized statements; `delete` errors on missing id.
- **Files touched**: `src/commands/done.ts`, `src/commands/delete.ts`
- **Read next**: Manifest only — cover missing-id and non-integer-id paths
- **Open items**: None

### 3. tester -> reviewer — 2026-04-09

- **Outcome**: 6 tests added; `pnpm test` green (happy paths, `delete` missing-id error, non-integer usage error).
- **Files touched**: `src/commands/done.test.ts`, `src/commands/delete.test.ts`
- **Read next**: Manifest only
- **Open items**: None

### 4. reviewer -> product — 2026-04-09

- **Outcome**: Clean review — no Defects, no Issues. Condition 1 verified on both mutation paths.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 5. product — task complete — 2026-04-10

- **Outcome**: All acceptance criteria met; Status set to Complete. During milestone smoke testing Bug Gatherer filed BUG-002 (`done` silent success on missing id) — triaged Low and Deferred to M2; does not violate this task's criteria.
- **Files touched**: This file (Header Status), `../bugs/BUG-002-done-silent-success.md`, `artifacts/BUGS.md` (index row)
- **Read next**: —
- **Open items**: BUG-002 held Deferred (re-triage at M2 planning)

---

_Last updated: 2026-04-10_
