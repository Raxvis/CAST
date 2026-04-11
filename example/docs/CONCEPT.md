# Acme Todo - Project Vision

---

## Concepts

## A Todo Tracker That Respects Your Terminal

**Summary:** Acme Todo is a local-first command-line todo tracker for
developers who live in the shell and do not want their task manager to
require a network connection, an account, or a browser tab.

**Related Docs:** `PRD.md`, `GLOSSARY.md`

---

### Description

Most task managers assume you want a cloud sync service, a mobile app, and a
sharing model. For a solo developer capturing "buy milk" or "fix that flaky
test" in the middle of real work, that is overkill. The context switch to a
browser or a GUI app is more expensive than the todo itself.

Acme Todo is the opposite extreme. You type `acme add "buy milk"` and a task
ID prints back. You type `acme list` and your open tasks appear in a compact
table. You type `acme done 3` and the task is closed with a completion
timestamp. Everything lives in a single SQLite file under your home
directory. There is no server, no account, no telemetry, no daemon.

The product's reason for existing is the absence of friction. If capturing a
task takes longer than remembering it, the tool has failed. Every feature
decision is measured against that standard: does this make capture faster,
or does it just make the tool bigger?

### Design Pillars

1. **Single binary** - Installed via `pnpm` and runnable as `acme` from any
   shell on macOS, Linux, or Windows with Node 20+.
2. **No dependencies beyond better-sqlite3** - The runtime dependency list
   is one library. Argv parsing, formatting, and dispatch are hand-written.
3. **Offline-first** - No network code, ever. The application cannot
   accidentally leak your task list because it literally cannot open a
   socket.
4. **Stable storage format** - Tasks live in a plain SQLite file you can
   open with any SQLite browser. Schema migrations are versioned and
   idempotent.
5. **Sub-100ms command latency** - Warm `acme list` on a 100-task database
   returns in under 100 milliseconds. Nothing on the happy path is allowed
   to regress this budget.

### Key Principles

- If a feature cannot be explained in one sentence, it probably does not
  belong in v1.
- Errors are printed to stderr with a non-zero exit code. The CLI never
  silently succeeds on a command that did not do what the user asked.
- The storage format is the user's, not the application's. Anyone with
  `sqlite3` installed should be able to inspect and repair their data.
- Every SQL query uses parameterized bindings. No exceptions.

### Core Loop

1. The user types `acme add "buy milk"` in their terminal.
2. The CLI opens the database (running migrations if the file is new),
   inserts a row, and prints the new task ID immediately.
3. Later, the user types `acme list` and sees the open tasks in a small
   columnar table.
4. When the task is done, the user types `acme done 3`. The task's
   `completed` flag flips and `completedAt` is stamped.
5. Optionally, `acme delete 3` removes the row entirely.

The whole loop is sub-100ms per invocation and never touches a network.
That is the entire product.

### Open Questions

| # | Question | Owner | Resolution |
|---|----------|-------|------------|
| 1 | Should completed tasks age out of the default `list` view after N days? | Product | Deferred to M2 |
| 2 | Should `delete` confirm before removing a row? | Product | No; terminal users expect scriptability |

---

_Last updated: 2026-04-10_
