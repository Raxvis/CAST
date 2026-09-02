# Acme Todo - CLAUDE.md

## Project Overview

Acme Todo is a CLI tool built with **standalone Node.js (Node 20+)**. Targets
**macOS, Linux, and Windows** (anywhere Node 20+ runs). It is a minimal
command-line todo tracker that stores tasks in SQLite and supports add, list,
done, and delete.

## Tech Stack

- **Framework**: None (standalone Node CLI binary)
- **Language**: TypeScript (strict mode)
- **Runtime**: Node.js 20+
- **Persistence**: SQLite via `better-sqlite3`
- **Platforms**: macOS, Linux, Windows
- **Build**: `pnpm dev` (dev) / `pnpm build` (production)

## Build & Test

- **Dev command**: `pnpm dev`
  - Runs the CLI directly from source via `tsx`
  - Pass subcommands after `--`, e.g. `pnpm dev -- add "buy milk"`
- **Type check**: `pnpm typecheck`
- **Tests**: `pnpm test` (Vitest)
- **Production build**: `pnpm build` (emits `dist/cli.js` and the `acme` bin)
- **Debug**: `NODE_OPTIONS=--inspect-brk pnpm dev -- <cmd>`, or structured
  `console.error` logging to stderr

## Common Pitfalls

- **Shell escaping on Windows**: Titles containing spaces or quotes behave
  differently in PowerShell, cmd.exe, and POSIX shells. Always test quoting
  on all three before assuming a case is covered.
- **Path handling between platforms**: Use `node:path` and `node:os.homedir()`
  for the database location. Never hand-build `~/.acme-todo/tasks.db` with
  string concatenation; `path.join(os.homedir(), '.acme-todo', 'tasks.db')`.
- **SQLite database file permissions on first run**: The parent directory
  may not exist yet. Create it with `fs.mkdirSync(dir, { recursive: true })`
  before opening the database, and tolerate the `ENOENT` case gracefully.
- **Parameterized queries only**: Never interpolate user input into SQL
  strings. Use `better-sqlite3`'s prepared-statement `.run(params)` form.
  This is enforced by CEO Condition 1.
- **WAL mode and the completed index**: The migration runner must enable
  WAL and create an index on the `completed` column. See CEO Condition 2.

## Project Structure

```
acme-todo/
  src/
    commands/                  # One file per subcommand
      add.ts                   # acme add <title>
      list.ts                  # acme list [--all]
      done.ts                  # acme done <id>
      delete.ts                # acme delete <id>
    db/
      schema.ts                # Table definitions and type mapping
      migrations.ts            # Idempotent migration runner
    types/
      task.ts                  # Task type, TaskRow row shape
    cli.ts                     # argv parser and subcommand dispatcher
    index.ts                   # Entry point (shebang, calls cli.ts)
  package.json                 # pnpm manifest, bin: { acme: dist/index.js }
  tsconfig.json                # strict: true, target ES2022
  vitest.config.ts             # Test runner config
```

## TypeScript Style Conventions

> **Note:** Bracketed names in code examples below (e.g., `Task`, `runMigrations`)
> are the real project identifiers, not placeholders.

- **camelCase** for variables, functions, and file names
- **PascalCase** for types, interfaces, and enums
- **UPPER_SNAKE_CASE** for module-level constants
- Prefer `interface` for object shapes and `type` aliases for unions
- Explicit return types on all exported functions
- No `any`. Use `unknown` plus narrowing when the shape is not known
- All business logic lives in pure TypeScript modules that can be imported
  from tests without spinning up the CLI

```ts
// src/types/task.ts
export interface Task {
  id: number
  title: string
  completed: boolean
  createdAt: string
  completedAt: string | null
}

// src/db/schema.ts
export const TASK_TABLE = 'tasks' as const

// src/commands/add.ts
import type { Database } from 'better-sqlite3'
import type { Task } from '../types/task.js'

export function addTask(db: Database, title: string): Task {
  const stmt = db.prepare(
    'INSERT INTO tasks (title, completed, createdAt) VALUES (?, ?, ?)'
  )
  const createdAt = new Date().toISOString()
  const info = stmt.run(title, 0, createdAt)
  return {
    id: Number(info.lastInsertRowid),
    title,
    completed: false,
    createdAt,
    completedAt: null,
  }
}
```

## Architecture

### CLI Entry Flow

`src/index.ts` is the shebang entry (`#!/usr/bin/env node`). It delegates
immediately to `src/cli.ts`, which parses `process.argv.slice(2)` with a
minimal custom parser (no commander, no yargs) and dispatches to one of the
`src/commands/*.ts` handlers. Each command handler opens the database via
`src/db/schema.ts`, which first calls `runMigrations()` from
`src/db/migrations.ts` to ensure the schema is up to date.

```ts
// src/cli.ts
import { openDatabase } from './db/schema.js'
import { addCommand } from './commands/add.js'

export async function run(argv: readonly string[]): Promise<number> {
  const [sub, ...rest] = argv
  const db = openDatabase()
  switch (sub) {
    case 'add':    return addCommand(db, rest)
    case 'list':   return listCommand(db, rest)
    case 'done':   return doneCommand(db, rest)
    case 'delete': return deleteCommand(db, rest)
    case '--help':
    case undefined: printUsage(); return 0
    default: printUsage(); return 1
  }
}
```

## Domain-Specific Patterns

- **Exit codes**: `0` on success, `1` on user error (missing arg, unknown
  command, task ID not found), `2` reserved for internal errors.
- **Stdout vs stderr**: All normal command output goes to stdout. Errors,
  warnings, and usage on failure go to stderr.
- **Time format**: All timestamps stored as ISO-8601 UTC strings. Never
  `Date.now()` numbers in the database.

## Persistence

Tasks are persisted in a single SQLite database file. The default location
is `~/.acme-todo/tasks.db` and it can be overridden with the `ACME_TODO_DB`
environment variable.

- Schema is versioned through `src/db/migrations.ts`. Migrations run
  idempotently on every command invocation.
- WAL mode is enabled (`PRAGMA journal_mode = WAL;`) for concurrent-reader
  safety and durability under `kill -9`.
- An index on the `completed` column keeps `list` fast as task counts grow.
- A missing database file is not an error; the migration runner will create
  the file and apply the schema on the first invocation (CEO Condition 3).

## Git Workflow

- **Branching**: Feature branches off `main`, merged via pull request.
- **Branch naming**: `feature/description`, `fix/description`, `refactor/description`.
- **Commits**: Short imperative messages (e.g., "Add done command", "Fix list crash on first run").
- **Ignore**: `dist/`, `node_modules/`, `*.db`, `.DS_Store` (already in `.gitignore`).

## Dependencies

Manage with `pnpm`. Add new dependencies:

```bash
pnpm add <package>           # runtime dependency
pnpm add -D <package>        # dev dependency
```

Current dependencies (see `package.json`):
- **better-sqlite3** - synchronous SQLite bindings
- **tsx** (dev) - TypeScript execution for `pnpm dev`
- **typescript** (dev) - type checker and compiler
- **vitest** (dev) - test runner
- **@types/node** (dev) - Node 20 type definitions

## File Naming

- camelCase for source files: `add.ts`, `migrations.ts`, `schema.ts`
- PascalCase is reserved for exported types, not filenames
- Group by responsibility:
  ```
  src/
    commands/    # One file per subcommand
    db/          # Database schema and migrations
    types/       # Shared type declarations
  ```

## CAST Agent Workflow

Acme Todo uses the CAST staged agent team (https://github.com/Raxvis/CAST): `/agent-plan` plans a milestone (Product → Architecture + UI → CEO verdict), `/agent-code` implements it (Coder → Reviewer → validation), `/agent-task` runs small one-off work, `/file-bug` and `/add-task` capture bugs and backlog entries, and `/cast-doctor` / `/cast-release` maintain the install and prepare releases.

- **CAST brings no documentation — this project's own docs drive it.** `.claude/cast/SOURCES.md` (the **source map**) records where the requirements, standards, architecture docs, testing guidance, documentation home, and registers live. Planning reads those sources and distills what applies into each milestone's own artifacts; engineering reads only the artifacts. Keep the source map current when documentation moves — `/cast-doctor` verifies it.
- **`artifacts/`** holds all live work, grouped by milestone: each `milestone-{N}-{slug}/` directory carries that milestone's README (definition, Standards Digest, CEO conditions), design docs, reviews, per-task files, and per-bug files. Cross-milestone state sits at the root — the bug index (`artifacts/BUGS.md`), the one-off task backlog (`artifacts/TASKS.md`), the session log (`artifacts/STANDUP.md`), and the orchestrator's state tables (`artifacts/AGENT_STATE.md`). One-off `/agent-task` work goes under `artifacts/one-off/`.
- **`.claude/cast/`** is CAST's machinery — the source map, the process contracts (`PIPELINE_LOOP.md`, `STAGE_CONTRACT.md`), and the document templates (`templates/`). Agents copy templates into `artifacts/` as instances; nothing under `.claude/cast/` is edited during work except the source map, by you or `/cast-doctor`.

Adopted with CAST v4.0.0
