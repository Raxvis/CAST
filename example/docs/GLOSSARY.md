# Acme Todo - Glossary

All terms are listed alphabetically within each category. Terms shown in **bold**
within a definition are themselves defined in this glossary.

---

## Core Concepts

_Terms fundamental to understanding the product._

**Closed Task**
A **Task** whose `completed` field is `true`. Closed tasks are hidden from
`acme list` by default and shown only when `--all` is passed.

**Open Task**
A **Task** whose `completed` field is `false`. Open tasks are what `acme list`
prints by default.

**Task**
The primary data entity. A Task has an `id` (integer primary key), a `title`
(string), a `completed` boolean (default `false`), a `createdAt` ISO
timestamp, and a nullable `completedAt` ISO timestamp. Persisted as one row
in the `tasks` table.

**Task ID**
The integer primary key of a **Task** row. Printed by `acme add` and used as
the argument to `acme done` and `acme delete`.

**Title**
The human-readable description of a **Task**, supplied as the argument to
`acme add`. Stored verbatim, including spaces and punctuation.

---

## Domain-Specific Terms

_Terminology specific to the command-line todo tracker domain._

**Completed**
The boolean flag on a **Task** indicating whether it has been marked done.
Defaults to `false` on insertion.

**Completed At**
The ISO-8601 UTC timestamp recording when a **Task** was marked done. Null
for an **Open Task**. Set by `acme done`.

**Created At**
The ISO-8601 UTC timestamp recording when a **Task** was first inserted.
Set by `acme add` and never modified.

**DB Path**
The filesystem location of the SQLite database. Defaults to
`~/.acme-todo/tasks.db` and can be overridden with the `ACME_TODO_DB`
environment variable.

---

## Technical Terms

_Terms related to the codebase, architecture, and storage._

**Command**
A top-level invocation of the CLI, e.g. `acme`. The single binary the user
runs.

**Exit Code**
The process exit status. `0` means success, `1` means a user error (missing
argument, unknown **Subcommand**, **Task ID** not found), `2` is reserved
for internal errors.

**Migration**
A schema change applied by `src/db/migrations.ts`. Migrations run
idempotently on every invocation, which means running them twice is safe and
a missing database file is created on first use (per CEO Condition 3).

**Parameterized Query**
A SQL statement that uses `?` placeholders rather than string concatenation
for user input. Required for every query per CEO Condition 1.

**Subcommand**
The second argv token after the binary name, identifying which action to
run: `add`, `list`, `done`, or `delete`.

**WAL Mode**
SQLite's write-ahead logging journal mode, enabled in the migration runner
via `PRAGMA journal_mode = WAL;`. Improves durability and concurrent-read
behavior. Required by CEO Condition 2.

---

## Abbreviations

| Abbreviation | Meaning |
|-------------|---------|
| CLI | Command-Line Interface |
| CRUD | Create, Read, Update, Delete |
| DB | Database |
| ISO | ISO-8601 (timestamp format) |
| WAL | Write-Ahead Log (SQLite journal mode) |
| MVP | Minimum Viable Product |
| PRD | Product Requirements Document |

---

_Last updated: 2026-04-10_
