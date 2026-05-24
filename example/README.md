# Example: Acme Todo

This directory is a **fixture**, not a real, buildable project. It shows what a
populated instance of the CAST template looks like after a solo developer has
run `/agent-plan` and `/agent-code` for Milestone 1 of a small project.

## The Mock Project

**Acme Todo** is a minimal command-line todo tracker written in TypeScript
(strict mode) targeting Node.js 20+. Tasks are stored in SQLite via
`better-sqlite3` and the CLI supports `add`, `list`, `done`, and `delete`.
It is a hobby project by a solo developer.

See `CLAUDE.md` for the full project overview and `docs/PRD.md` for requirements.

## What Has Happened

1. `/agent-plan` ran on 2026-04-08, producing the Milestone 1 plan, the
   architecture and UI specs, and the security/performance/CEO reviews under
   `artifacts/milestones/`, `artifacts/architecture/`, `artifacts/ui-specs/`,
   and `artifacts/reviews/`.
2. The CEO verdict was **APPROVED WITH CONDITIONS** (three conditions covering
   parameterized SQL, WAL mode plus an index on `completed`, and migration
   on first invocation).
3. `/agent-code` ran on 2026-04-09, implementing tasks T-1 through T-5.
4. Milestone 1 was marked complete on 2026-04-10. Two bugs were filed along
   the way (see `artifacts/BUGS.md`).

## Where to Start Reading

Read these in order for the clearest picture:

1. **`CLAUDE.md`** — the root context file an agent sees at every session.
2. **`docs/PRD.md`** — requirements and acceptance criteria for M1 and M2.
3. **`artifacts/milestones/milestone-1-task-crud.md`** — the M1 plan.
4. **`artifacts/reviews/ceo-review-milestone-1.md`** — the APPROVED WITH
   CONDITIONS verdict and the three conditions that shaped implementation.
5. **`artifacts/BUGS.md`** — BUG-001 (fixed during T-3) and BUG-002 (deferred).
6. **`artifacts/STANDUP.md`** — the rolling session log across the three days.

## Directory Layout

- `CLAUDE.md` — populated project root context
- `docs/` — PRD, CONCEPT, GLOSSARY (only these; see Deliberate Omissions below)
- `artifacts/` — all live milestone work, reviews, bugs, and session log

## Deliberate Omissions

- **No `.claude/` directory.** In a real populated project this would hold
  unchanged copies of the template agent and command files. Including them
  here would just duplicate the template's `agents/` directory verbatim.
- **No `src/` directory.** This fixture demonstrates the *planning and review
  artifacts*, not a working build. Acme Todo is not a real package.
- **No full `docs/` set.** Only `PRD.md`, `CONCEPT.md`, and `GLOSSARY.md`
  are included. The other documentation templates (`CODE_PATTERNS.md`,
  `FILE_CONVENTIONS.md`, `ERROR_HANDLING.md`, etc.) change only trivially
  when populated and are omitted for brevity.
