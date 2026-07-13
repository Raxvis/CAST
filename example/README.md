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
3. `/agent-code` ran on 2026-04-09 and 2026-04-10, implementing tasks T-1
   through T-5. Two bugs were filed along the way (see `artifacts/BUGS.md`).
4. The milestone-completion checkpoint fired on 2026-04-10: Product re-triaged
   the Deferred BUG-002 (held Deferred into M2 — Deferred is an open, held
   state, not terminal) and wrote the completion record ("Complete with
   Deferrals") and the milestone validation record; the UI agent reviewed the
   implemented command surface (UX review, APPROVED WITH NOTES); Docs Writer
   drained the `docs` queue; and Validator wrote the milestone retrospective.

## Where to Start Reading

Read these in order for the clearest picture:

1. **`CLAUDE.md`** — the root context file an agent sees at every session.
2. **`docs/PRD.md`** — requirements and acceptance criteria for M1 and M2.
3. **`artifacts/milestones/milestone-1-task-crud.md`** — the M1 plan.
4. **`artifacts/reviews/ceo-review-milestone-1.md`** — the APPROVED WITH
   CONDITIONS verdict and the three conditions that shaped implementation.
5. **`artifacts/BUGS.md`** — BUG-001 (closed during M1) and BUG-002 (Deferred —
   an open, held state re-triaged by Product at milestone completion), in the
   canonical single-list schema with per-stage field ownership.
6. **`artifacts/milestones/milestone-1-task-crud-validation.md`** — Product's
   milestone-grain validation record (Approved with Notes), and its companion
   completion report (`-completion.md`, "Complete with Deferrals").
7. **`artifacts/reviews/ux-review-milestone-1.md`** — the UI agent's review of
   the implemented command surface against the approved spec.
8. **`artifacts/reviews/retrospective-milestone-1.md`** — the Validator's
   retrospective, with every metric filled from a recorded fixture source.
9. **`artifacts/AGENT_STATE.md`** — every agent's live working state after
   Milestone 1 closed: current work, decision logs, and the validator's
   dashboards, one section per agent.
10. **`artifacts/STANDUP.md`** — the rolling session log across the three days,
    written in the canonical Entry Grammar (typed one-liner entries under
    dated session headings, with loop counters and the ✅-marked Docs Writer
    queue).

## Directory Layout

- `CLAUDE.md` — populated project root context, stamped `Adopted with CAST v1.4.0`
- `docs/` — PRD, CONCEPT, GLOSSARY (only these; see Deliberate Omissions below)
- `artifacts/` — all live milestone work:
  - `AGENT_STATE.md`, `BUGS.md`, `STANDUP.md` — the three live state files
  - `milestones/` — milestone definition, task breakdown, completion report,
    and validation record for M1
  - `architecture/arch-milestone-1.md` and `ui-specs/ui-milestone-1.md` — the
    approved design specs
  - `reviews/` — security, performance, and CEO planning reviews, plus the
    milestone-completion UX review and retrospective

## Deliberate Omissions

- **No `.claude/` directory.** In a real populated project this would hold
  the installed agent files (`.claude/agents/*.md`) and pipeline skills
  (`.claude/skills/agent-plan/SKILL.md`, `agent-code`, `agent-task`).
  Including them here would just duplicate the template payload verbatim.
- **No `src/` directory.** This fixture demonstrates the *planning and review
  artifacts*, not a working build. Acme Todo is not a real package.
- **No full `docs/` set.** Only `PRD.md`, `CONCEPT.md`, and `GLOSSARY.md`
  are included. The other documentation templates (`CODE_PATTERNS.md`,
  `FILE_CONVENTIONS.md`, `ERROR_HANDLING.md`, etc.) change only trivially
  when populated and are omitted for brevity.
