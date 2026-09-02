# Example: Acme Todo

This directory is a **fixture**, not a real, buildable project. It shows what a
populated instance of the CAST template looks like after a solo developer has
run `/agent-plan` and `/agent-code` for Milestone 1 of a small project — with
CAST's v4 bring-your-own-documentation model: the project's own `docs/` and
`CLAUDE.md` are the documentation, and the source map
(`.claude/cast/SOURCES.md`) points the pipelines at them.

## The Mock Project

**Acme Todo** is a minimal command-line todo tracker written in TypeScript
(strict mode) targeting Node.js 20+. Tasks are stored in SQLite via
`better-sqlite3` and the CLI supports `add`, `list`, `done`, and `delete`.
It is a hobby project by a solo developer.

See `CLAUDE.md` for the full project overview and `docs/PRD.md` for requirements.

## What Has Happened

1. `/agent-plan` ran on 2026-04-08. It resolved the source map, read the
   project's own PRD, concept, glossary, and `CLAUDE.md` conventions, and
   produced the Milestone 1 directory (`artifacts/milestone-1-task-crud/`):
   the milestone README — including the **Standards Digest**, the distilled
   conventions engineering reads instead of the sources — one task file per
   task under `tasks/`, the architecture and UI specs, and the risk and CEO
   reviews under `reviews/`.
2. The CEO verdict was **APPROVED WITH CONDITIONS** (three conditions covering
   parameterized SQL, WAL mode plus an index on `completed`, and migration
   on first invocation).
3. `/agent-code` ran on 2026-04-09 and 2026-04-10, implementing tasks T-1
   through T-5 — each stage reading only its task file's Context Manifest and
   appending to its Handoff Log. Two bugs were filed along the way as per-bug
   files under `milestone-1-task-crud/bugs/`, indexed in `artifacts/BUGS.md`.
   Every Coder handoff carries a **verbatim test-results block** (the test gate
   — Reviewer rejects an entry without one), and every Reviewer approval carries
   an **Acceptance Criteria Check**, one line per criterion with its evidence.
   T-1, T-2, T-3, and T-5 closed on that alone (Step 3a — every criterion, and
   each task's CEO Approval Condition lines, Met with evidence; no Product
   spawn); only T-4 routed to Product (Step 3b), and it shows a
   `Product judgment` flag and how Product disposed of it.
4. The milestone-completion checkpoint fired on 2026-04-10: the UI agent
   reviewed the implemented command surface (UX review, APPROVED WITH NOTES);
   the CEO agent ran the risk implementation review (both lenses, no findings);
   then a single Product launch closed the milestone end-to-end — re-triaging
   the Deferred BUG-002 (held Deferred into M2 — Deferred is an open, held
   state, not terminal), writing the close record (`reviews/close.md`,
   "Complete with Deferrals") covering per-task validation, milestone
   validation, and the retrospective in one pass, and verifying all three CEO
   Approval Conditions. Docs Writer then drained all four queued `docs`
   entries in one pass, and the orchestrator recorded the milestone outcome
   and the Decisions Log rows. The per-task checkpoints launched no agents at
   all.

## Where to Start Reading

Read these in order for the clearest picture:

1. **`CLAUDE.md`** — the user's own root context file, with the one appended
   CAST section at the bottom.
2. **`.claude/cast/SOURCES.md`** — the source map: where this project keeps
   its requirements, standards, testing guidance, and documentation home.
3. **`docs/PRD.md`** — requirements and acceptance criteria for M1 and M2.
4. **`artifacts/milestone-1-task-crud/README.md`** — the M1 plan.
5. **`artifacts/milestone-1-task-crud/reviews/ceo.md`** — the APPROVED WITH
   CONDITIONS verdict and the three conditions that shaped implementation.
6. **`artifacts/BUGS.md`** — the bug index pointing at the two per-bug files
   under `artifacts/milestone-1-task-crud/bugs/`: BUG-001 (closed during M1)
   and BUG-002 (Deferred — an open, held state re-triaged by Product at
   milestone completion), each with per-stage field ownership.
7. **`artifacts/milestone-1-task-crud/tasks/task-03-list-command.md`** — the
   clearest worked task file: a seeded Context Manifest and a Handoff Log that
   walks the full defect loop (BUG-001: coder -> reviewer files the bug ->
   product triages Fix Now -> coder investigates, fixes, and proves the test
   red -> reviewer approves).
8. **`artifacts/milestone-1-task-crud/reviews/close.md`** — Product's one-pass
   milestone close record (Sign-Off: Approved with Notes; Header Status:
   "Complete with Deferrals"): per-task validation for all five tasks, the
   milestone validation checklist, known issues, and the retrospective, with
   every metric filled from a recorded fixture source.
9. **`artifacts/milestone-1-task-crud/reviews/ux.md`** — the UI agent's review of
   the implemented command surface against the approved spec.
10. **`artifacts/AGENT_STATE.md`** — project state written by the orchestrator
   after Milestone 1 closed: the Decisions Log, milestone progress, and the
   measured performance budgets. No agent reads this file.
11. **`artifacts/STANDUP.md`** — the rolling session log across the three days,
    written in the canonical Entry Grammar (typed one-liner entries under
    dated session headings, with loop counters and the ✅-marked Docs Writer
    queue).

## Directory Layout

- `CLAUDE.md` — the user's own project context, with the appended CAST section
  (stamped `Adopted with CAST v4.0.0`)
- `.claude/cast/SOURCES.md` — the source map (the one installed file that is
  per-project, so the fixture includes it)
- `docs/` — the project's **own** documentation: PRD, CONCEPT, GLOSSARY (see
  Deliberate Omissions below)
- `artifacts/` — all live milestone work, grouped by milestone:
  - `AGENT_STATE.md`, `BUGS.md` (bug index), `TASKS.md` (one-off backlog, empty), `STANDUP.md` — the cross-milestone state files
  - `milestone-1-task-crud/` — everything M1 produced:
    - `README.md` — milestone definition, Standards Digest, Task Index, CEO Approval Conditions
    - `architecture.md` and `ui.md` — the approved design specs
    - `tasks/task-01…05-*.md` — one isolated file per task, each with its
      Context Manifest and Handoff Log
    - `bugs/bug-001…002-*.md` — one file per bug filed during the milestone
    - `reviews/` — the risk review (security + performance lenses) and the CEO
      planning verdict, plus the milestone-completion UX review, the risk
      implementation review, and the close record
  - `one-off/` — where `/agent-task` work would land (empty in this fixture)

## Deliberate Omissions

- **Almost no `.claude/` directory.** Only `.claude/cast/SOURCES.md` is
  included — it is filled per-project, so it is the interesting one. The rest
  (`.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, the contracts and
  templates under `.claude/cast/`) would just duplicate the template payload
  verbatim.
- **No `artifacts/DOCTOR.md`.** `/cast-doctor` (the install health check) has
  not been run in this fixture's timeline; its report is created on first run.
- **No `src/` directory.** This fixture demonstrates the *planning and review
  artifacts*, not a working build. Acme Todo is not a real package.
- **A small `docs/` set.** `PRD.md`, `CONCEPT.md`, and `GLOSSARY.md` are the
  project's own documentation — CAST installed none of it. The project's code
  conventions live in `CLAUDE.md` rather than separate files, and the source
  map says so; the milestone README's Standards Digest is what planning
  distilled from them.
