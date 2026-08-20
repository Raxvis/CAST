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

1. `/agent-plan` ran on 2026-04-08, producing the Milestone 1 directory
   (`artifacts/milestone-1-task-crud/`): the milestone README, one task file
   per task under `tasks/`, the architecture and UI specs, and the
   security/performance/CEO reviews under `reviews/`.
2. The CEO verdict was **APPROVED WITH CONDITIONS** (three conditions covering
   parameterized SQL, WAL mode plus an index on `completed`, and migration
   on first invocation).
3. `/agent-code` ran on 2026-04-09 and 2026-04-10, implementing tasks T-1
   through T-5 — each stage reading only its task file's Context Manifest and
   appending to its Handoff Log. Two bugs were filed along the way as per-bug
   files under `milestone-1-task-crud/bugs/`, indexed in `artifacts/BUGS.md`.
   Every Reviewer approval carries an **Acceptance Criteria Check** — one line
   per criterion with its evidence. T-5 closed on that alone (Step 4a: 7/7 Met,
   no Product spawn); T-1 through T-4 still routed to Product (Step 4b) because
   each carries a CEO Approval Condition, and T-4 shows a `Product judgment`
   flag and how Product disposed of it.
4. The milestone-completion checkpoint fired on 2026-04-10: Product re-triaged
   the Deferred BUG-002 (held Deferred into M2 — Deferred is an open, held
   state, not terminal) and wrote the completion record ("Complete with
   Deferrals") and the milestone validation record covering all five tasks; the
   UI agent reviewed the implemented command surface (UX review, APPROVED WITH
   NOTES); Docs Writer drained all four queued `docs` entries in one pass; and
   Validator recorded every task outcome plus the milestone outcome and wrote
   the retrospective. The per-task checkpoints launched no agents at all.

## Where to Start Reading

Read these in order for the clearest picture:

1. **`CLAUDE.md`** — the root context file an agent sees at every session.
2. **`docs/PRD.md`** — requirements and acceptance criteria for M1 and M2.
3. **`artifacts/milestone-1-task-crud/README.md`** — the M1 plan.
4. **`artifacts/milestone-1-task-crud/reviews/ceo.md`** — the APPROVED WITH
   CONDITIONS verdict and the three conditions that shaped implementation.
5. **`artifacts/BUGS.md`** — the bug index pointing at the two per-bug files
   under `artifacts/milestone-1-task-crud/bugs/`: BUG-001 (closed during M1)
   and BUG-002 (Deferred — an open, held state re-triaged by Product at
   milestone completion), each with per-stage field ownership.
6. **`artifacts/milestone-1-task-crud/tasks/task-03-list-command.md`** — the
   clearest worked task file: a seeded Context Manifest and a Handoff Log that
   walks the full defect loop (BUG-001: coder → bug-gatherer → product →
   debugger → coder → tester → reviewer → product).
7. **`artifacts/milestone-1-task-crud/reviews/validation.md`** — Product's
   milestone-grain validation record (Approved with Notes), and its companion
   completion report (`reviews/completion.md`, "Complete with Deferrals").
8. **`artifacts/milestone-1-task-crud/reviews/ux.md`** — the UI agent's review of
   the implemented command surface against the approved spec.
9. **`artifacts/milestone-1-task-crud/reviews/retrospective.md`** — the Validator's
   retrospective, with every metric filled from a recorded fixture source.
10. **`artifacts/AGENT_STATE.md`** — every agent's live working state after
    Milestone 1 closed: current work, decision logs, and the validator's
    dashboards, one section per agent.
11. **`artifacts/STANDUP.md`** — the rolling session log across the three days,
    written in the canonical Entry Grammar (typed one-liner entries under
    dated session headings, with loop counters and the ✅-marked Docs Writer
    queue).

## Directory Layout

- `CLAUDE.md` — populated project root context, stamped `Adopted with CAST v2.0.0`
- `docs/` — PRD, CONCEPT, GLOSSARY (only these; see Deliberate Omissions below)
- `artifacts/` — all live milestone work, grouped by milestone:
  - `AGENT_STATE.md`, `BUGS.md` (bug index), `STANDUP.md` — the cross-milestone state files
  - `milestone-1-task-crud/` — everything M1 produced:
    - `README.md` — milestone definition, Task Index, CEO Approval Conditions
    - `architecture.md` and `ui.md` — the approved design specs
    - `tasks/task-01…05-*.md` — one isolated file per task, each with its
      Context Manifest and Handoff Log
    - `bugs/bug-001…002-*.md` — one file per bug filed during the milestone
    - `reviews/` — security, performance, and CEO planning reviews, plus the
      milestone-completion UX review, validation and completion records, and
      the retrospective
  - `one-off/` — where `/agent-task` work would land (empty in this fixture)

## Deliberate Omissions

- **No `.claude/` directory.** In a real populated project this would hold
  the installed agent files (`.claude/agents/*.md`) and skills
  (`.claude/skills/agent-plan/SKILL.md`, `agent-code`, `agent-task`,
  `cast-doctor`). Including them here would just duplicate the template
  payload verbatim.
- **No `artifacts/DOCTOR.md`.** `/cast-doctor` (the install health check) has
  not been run in this fixture's timeline; its report is created on first run.
- **No `src/` directory.** This fixture demonstrates the *planning and review
  artifacts*, not a working build. Acme Todo is not a real package.
- **No full `docs/` set.** Only `PRD.md`, `CONCEPT.md`, and `GLOSSARY.md`
  are included. The other documentation templates (`CODE_PATTERNS.md`,
  `FILE_CONVENTIONS.md`, `ERROR_HANDLING.md`, etc.) change only trivially
  when populated and are omitted for brevity.
