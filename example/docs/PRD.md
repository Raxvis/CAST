# Acme Todo - Product Requirements Document

**Version:** 0.1.0
**Status:** Approved

---

## Executive Summary

Acme Todo is a command-line todo tracker for macOS, Linux, and Windows. It
targets solo developers and terminal-first power users who want a fast,
offline, local-only way to track personal tasks without leaving the shell.
The product is differentiated by its zero-network design, sub-100ms command
latency, and a stable SQLite storage format that the user can inspect with
any SQLite tool.

**MVP scope:** Milestone 1 ships the four core commands (`add`, `list`,
`done`, `delete`) backed by a single SQLite database. Tags, priorities,
search, and any form of sync or multi-user support are explicitly deferred.

---

## Problem Statement

**User problem:** Developers who live in the terminal find it disruptive to
switch to a GUI or web app to capture a quick todo. Existing CLI todo tools
either require a cloud account, lag on startup, or use fragile flat-file
formats that corrupt easily.

**Opportunity:** Node 20+ ships on most developer machines, `better-sqlite3`
provides a fast synchronous SQLite binding, and a single-binary install via
`pnpm` or `npm` is now routine. A minimal, durable, offline-first tracker
can be built and shipped in a weekend.

**Hypothesis:** If we build a CLI todo tracker that installs in one command,
responds in under 100ms, and never touches the network, then terminal-first
developers will use it as their default personal task capture tool, which
will validate the "small durable local tool" niche.

---

## Target Users

### Primary User

- **Segment:** Solo developers and terminal-first power users
- **Context of use:** At the shell, while working on other projects; capture
  a task in one line, review open tasks periodically, close tasks inline
- **Key need:** A todo tracker that never makes them leave the terminal and
  never loses their data
- **Behavior pattern:** 5-20 `acme` invocations per day, short bursts

### Secondary User

- **Segment:** Hobbyists learning SQLite and Node CLI patterns
- **Context of use:** Reading the source to understand how a small, correct
  CLI is structured
- **Key need:** A codebase small enough to read end to end in one sitting
- **Behavior pattern:** Occasional contributor; cares about test coverage
  and readable code more than features

---

## Success Metrics

### Quality Metrics

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Command latency (warm) | < 100ms | Manual `time acme list` on a 100-task DB |
| Crash-free command rate | 100% | Vitest suite plus manual matrix |
| Type check | 0 errors | `pnpm typecheck` in CI |
| Test coverage (logic) | >= 80% lines | Vitest coverage report |

### Adoption Signals (informal, solo project)

| Signal | Target | How observed |
|--------|--------|--------------|
| Daily self-use | 5+ invocations | Author usage |
| Data durability | 0 data loss events | Author usage |

---

## Core Features

### Feature 1: Add a Task

**Description:** Insert a new task with a title. The task starts in the open
(not completed) state, and the new task ID is printed so the user can
reference it immediately.

**User Stories:**

- As a terminal user, I want to run `acme add "buy milk"` so that I can
  capture a todo without leaving the shell.
- As a terminal user, I want the new task ID printed so that I can follow
  up with `acme done <id>` or `acme delete <id>`.

**Acceptance Criteria:**

- [x] `acme add "<title>"` inserts a row with `completed=false` and a
      `createdAt` ISO timestamp.
- [x] The new task's numeric ID is printed to stdout.
- [x] Titles containing spaces and quotes are preserved verbatim.
- [x] Exit code is 0 on success, 1 if no title is supplied.

**Out of scope for MVP:** Tags, priorities, due dates, descriptions.

---

### Feature 2: List Tasks

**Description:** Print the user's open tasks in a readable columnar format.
An `--all` flag also includes completed tasks.

**User Stories:**

- As a terminal user, I want to run `acme list` so that I can see what I
  still need to do.
- As a terminal user, I want to run `acme list --all` so that I can
  review everything, including completed tasks.

**Acceptance Criteria:**

- [x] `acme list` prints only tasks where `completed=false`, ordered by
      `createdAt` ascending.
- [x] `acme list --all` prints all tasks including completed ones.
- [x] Output columns are `ID  TITLE  STATUS  CREATED`.
- [x] If the database file does not exist yet, `list` creates it by running
      migrations rather than throwing (CEO Condition 3).

**Out of scope for MVP:** Filtering by text, sorting options, paging.

---

### Feature 3: Mark a Task Done

**Description:** Mark a task as completed and record the completion timestamp.

**User Stories:**

- As a terminal user, I want to run `acme done 3` so that I can close a
  task I have just finished.

**Acceptance Criteria:**

- [x] `acme done <id>` sets `completed=true` and `completedAt` to the
      current ISO timestamp.
- [x] Exit code is 0 on success, 1 if the ID does not exist.
- [ ] An informative error is printed when the ID does not exist (tracked
      as BUG-002, deferred to Milestone 2).

**Out of scope for MVP:** Un-done (re-open), bulk done.

---

### Feature 4: Delete a Task

**Description:** Permanently remove a task row from the database.

**User Stories:**

- As a terminal user, I want to run `acme delete 3` so that I can drop a
  task I should not have captured.

**Acceptance Criteria:**

- [x] `acme delete <id>` removes the row.
- [x] Exit code is 0 on success, 1 if the ID does not exist.
- [x] An informative error is printed when the ID does not exist.

**Out of scope for MVP:** Soft delete, undo, bulk delete.

---

## Non-Functional Requirements

### Performance

- Warm command latency must stay under 100ms for `list` on a database of
  100 tasks (measured on the author's MacBook).
- SQLite WAL mode must be enabled for durability and read concurrency.
- An index on the `completed` column must exist to keep `list` fast as
  the task count grows.

### Compatibility

- Must run on macOS, Linux, and Windows with Node 20 or later.
- No external services, no network calls, no telemetry.

### Reliability

- User data must never be silently lost. Every write uses a parameterized
  prepared statement and is wrapped in SQLite's default durability.
- The application must recover gracefully from a missing database file by
  running migrations on first invocation.

### Security

- All SQL queries must use parameterized bindings. No string concatenation
  of user input into SQL (CEO Condition 1).
- The database file lives under the user's home directory and inherits
  normal file permissions; no elevated privileges are required.

---

## Technical Constraints

### Language and Architecture

- TypeScript in strict mode. No `any`.
- No CLI framework (commander, yargs). A hand-written argv parser in
  `src/cli.ts` keeps the dependency surface minimal.
- All business logic lives in pure TypeScript modules under `src/` that can
  be unit-tested with Vitest without spawning a subprocess.

### Persistence

- SQLite database at `~/.acme-todo/tasks.db` by default, overridable via
  the `ACME_TODO_DB` environment variable.
- Schema versioned and migrated idempotently on every invocation.

### Build

- Must build successfully via `pnpm build` on macOS, Linux, and Windows.

---

## Timeline

| Milestone | Description |
|-----------|-------------|
| M1: Task CRUD + SQLite persistence | The four core commands work end to end against a real SQLite file. Acceptance criteria above are all met. |
| M2: Tags, priorities, search | Add tagging, a priority field, and a text search subcommand. Scope and criteria to be written when M1 ships. |

---

## Post-Launch Roadmap

These items are confirmed out of scope for v1 and are listed so architecture
decisions account for them.

- **Tags:** Many-to-many tag table; `acme list --tag work`.
- **Priorities:** Integer priority column with a default of 0.
- **Search:** `acme search <pattern>` using SQLite `LIKE` or FTS5.
- **Sync:** Explicitly never. Acme Todo is offline-only by design.
- **Multi-user:** Explicitly never. Single user per database file.

---

## Explicit Non-Goals

- No network synchronization, ever.
- No accounts, no authentication.
- No tags in v1.
- No priorities in v1.
- No multi-user support in v1 (or later).
- No GUI or web frontend.

---

## Appendix

### A. Revision History

| Version | Change Summary |
|---------|---------------|
| 0.1.0 | Initial PRD; M1 approved with conditions by CEO on 2026-04-08 |

---

_Last updated: 2026-04-10_
