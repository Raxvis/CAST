# T-5: CLI argument parser wiring

## Header

| Field | Value |
|-------|-------|
| **Milestone** | `../README.md` (M1: Task CRUD + SQLite Persistence) |
| **Status** | Complete |
| **Dependencies** | T-2, T-3, T-4 |
| **Needs Arch Doc** | Done -> `../architecture.md` §6 (Entrypoint) |
| **Needs UI Spec** | Done -> `../ui.md` §5 (help output) |
| **Loop count** | 0 / 3 |

---

## Description

Wire all four commands behind a single `acme-todo` entrypoint. Implement a minimal
custom argv parser in `src/cli.ts` — no `commander`, no `yargs`. Supported routes:
`add <title>`, `list [--all]`, `done <id>`, `delete <id>`, `--help` / `-h`.
Unknown commands print usage and exit non-zero. `src/index.ts` is the Node entrypoint
that opens the DB, runs migrations, dispatches, and closes the DB.

---

## Files

- `src/cli.ts` — `parseArgv(argv: string[]): ParsedCommand` and `dispatch` helper.
- `src/index.ts` — entrypoint: open DB, `runMigrations`, dispatch, handle errors.

---

## Acceptance Criteria

- [x] `acme-todo --help` prints usage listing all four commands.
- [x] `acme-todo` with no args prints usage and exits non-zero.
- [x] Unknown command (e.g. `acme-todo frobnicate`) prints usage and exits non-zero.
- [x] `list --all` is parsed correctly (flag routed to `runList`).
- [x] `src/index.ts` always calls `runMigrations` before dispatching — this is what
      makes Condition 3 / BUG-001 impossible to regress.
- [x] Vitest suite covers parser happy paths, `--help`, and unknown-command error.
- [x] No linter or type-check errors introduced.

---

## Context Manifest

| Reference | Sections | Why |
|---|---|---|
| `../architecture.md` | §6 (Entrypoint) | Dispatch shape and migration-before-dispatch rule |
| `../ui.md` | §5 (help output) | Usage text format |
| `docs/CODE_PATTERNS.md` | TypeScript Style Conventions | Naming and module-layout rules |

---

## Handoff Log

### 1. orchestrator -> coder — 2026-04-10

- **Outcome**: Task released; dependencies T-2, T-3, T-4 all Complete.
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None

### 2. coder -> tester — 2026-04-10

- **Outcome**: Parser and entrypoint implemented; `runMigrations` called unconditionally before dispatch.
- **Files touched**: `src/cli.ts`, `src/index.ts`
- **Commit**: `8e51f9a`
- **Read next**: Manifest only — cover `--help`, no-args, unknown-command, `--all` routing
- **Open items**: None

### 3. tester -> reviewer — 2026-04-10

- **Outcome**: 8 tests added; full `pnpm test` suite green across all five tasks.
- **Files touched**: `src/cli.test.ts`
- **Commit**: `2b6d0e7`
- **Read next**: Manifest only
- **Open items**: None

### 4. reviewer -> orchestrator — 2026-04-10

- **Outcome**: Clean review — no Defects, no Issues. Migration-before-dispatch guard confirmed (Condition 3 regression-proof). All 7 acceptance criteria Met; no Product spawn needed (Step 4a).
- **Files touched**: None
- **Read next**: Manifest only
- **Open items**: None
- **Acceptance Criteria Check**:
  - [1] `acme-todo --help` prints usage listing all four commands. — Met — `cli.test.ts` › "prints usage for --help" (`2b6d0e7`)
  - [2] `acme-todo` with no args prints usage and exits non-zero. — Met — `cli.test.ts` › "no args exits 1 with usage"
  - [3] Unknown command prints usage and exits non-zero. — Met — `cli.test.ts` › "unknown command exits 1"
  - [4] `list --all` is parsed correctly (flag routed to `runList`). — Met — `src/cli.ts:41`; `cli.test.ts` › "routes --all to runList"
  - [5] `src/index.ts` always calls `runMigrations` before dispatching. — Met — `src/index.ts:12` (unconditional, ahead of the switch); `cli.test.ts` › "migrations run before dispatch"
  - [6] Vitest suite covers parser happy paths, `--help`, and unknown-command error. — Met — 8 tests added in `2b6d0e7`
  - [7] No linter or type-check errors introduced. — Met — `pnpm typecheck` and lint clean at `8e51f9a`

### 5. orchestrator — task closed (Step 4a) — 2026-04-10

- **Outcome**: Every criterion Met with evidence in entry #4; task closed without a Product spawn. Status set to Complete. Milestone-completion checkpoint fires (all five tasks Complete) — Product reviews this task in the milestone validation record like every other.
- **Files touched**: This file (Header Status)
- **Read next**: —
- **Open items**: None

---

_Last updated: 2026-04-10_
