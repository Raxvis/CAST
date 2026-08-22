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
   per task under `tasks/`, the architecture and UI specs, and the risk and
   CEO reviews under `reviews/`.
2. The CEO verdict was **APPROVED WITH CONDITIONS** (three conditions covering
   parameterized SQL, WAL mode plus an index on `completed`, and migration
   on first invocation).
3. `/agent-code` ran on 2026-04-09 and 2026-04-10, implementing tasks T-1
   through T-5 — each stage reading only its task file's Context Manifest and
   appending to its Handoff Log. One bug was filed during implementation
   (BUG-001, in T-3); a second came out of the milestone-completion checkpoint
   (BUG-002). Both are per-bug files under `milestone-1-task-crud/bugs/`,
   indexed in `artifacts/BUGS.md`.
   Every Coder handoff carries a **verbatim test-results block** (the test gate
   — Reviewer rejects an entry without one), and every Reviewer approval carries
   an **Acceptance Criteria Check**, one line per criterion with its evidence.
   T-1, T-2, T-3, and T-5 closed on that alone (Step 3a — every criterion, and
   each task's CEO Approval Condition lines, Met with evidence; no Product
   spawn); only T-4 routed to Product (Step 3b), and it shows a
   `Product judgment` flag and how Product disposed of it.
4. The milestone-completion checkpoint fired on 2026-04-10: the UI agent
   reviewed the implemented command surface (UX review, APPROVED WITH NOTES)
   and filed BUG-002 out of it; the CEO agent ran the risk implementation
   review (both lenses, no findings); then a single Product launch closed the
   milestone end-to-end — triaging that fresh BUG-002 Low and setting it
   Deferred into M2 (Deferred is an open, held state, not terminal),
   writing the close record (`reviews/close.md`,
   "Complete with Deferrals") covering per-task validation, milestone
   validation, and the retrospective in one pass, and verifying all three CEO
   Approval Conditions. Docs Writer then drained all four queued `docs`
   entries in one pass, and the orchestrator recorded the milestone outcome
   and the Decisions Log rows. The per-task completion checkpoints launched no
   agent at all: the docs queue never reached its overflow bound, so every
   entry waited for this single drain.

## Where to Start Reading

Read these in order for the clearest picture:

1. **`CLAUDE.md`** — the root context file an agent sees at every session.
2. **`docs/PRD.md`** — requirements and acceptance criteria for M1 and M2.
3. **`artifacts/milestone-1-task-crud/README.md`** — the M1 plan.
4. **`artifacts/milestone-1-task-crud/reviews/ceo.md`** — the APPROVED WITH
   CONDITIONS verdict and the three conditions that shaped implementation.
5. **`artifacts/BUGS.md`** — the bug index pointing at the two per-bug files
   under `artifacts/milestone-1-task-crud/bugs/`: BUG-001 (closed during M1)
   and BUG-002 (Deferred — an open, held state, filed by the UI agent at the
   UX review and triaged by Product in the close pass), each with per-stage
   field ownership.
6. **`artifacts/milestone-1-task-crud/tasks/task-03-list-command.md`** — the
   clearest worked task file: a seeded Context Manifest and a Handoff Log that
   walks the full defect loop (BUG-001: coder -> reviewer files the bug ->
   product triages Fix Now -> coder investigates, fixes, and proves the test
   red -> reviewer approves).
7. **`artifacts/milestone-1-task-crud/reviews/close.md`** — Product's one-pass
   milestone close record (Sign-Off: Approved with Notes; Header Status:
   "Complete with Deferrals"): per-task validation for all five tasks, the
   milestone validation checklist, known issues, and the retrospective, with
   every metric filled from a recorded fixture source.
8. **`artifacts/milestone-1-task-crud/reviews/ux.md`** — the UI agent's review of
   the implemented command surface against the approved spec.
9. **`artifacts/AGENT_STATE.md`** — project state written by the orchestrator
   after Milestone 1 closed: the Decisions Log, milestone progress, and the
   measured performance budgets. No agent reads this file.
10. **`artifacts/STANDUP.md`** — the rolling session log across the three days,
    written in the canonical Entry Grammar (typed one-liner entries under
    dated session headings, plus the ✅-marked Docs Writer queue). Loop counts
    are not mirrored here — they live in each task file's `Loop count` Header,
    which is why only T-3 shows `1 / 3`.

## Directory Layout

- `CLAUDE.md` — populated project root context, stamped `Adopted with CAST v3.0.0`
- `docs/` — PRD, CONCEPT, GLOSSARY (only these; see Deliberate Omissions below)
- `artifacts/` — all live milestone work, grouped by milestone:
  - `AGENT_STATE.md`, `BUGS.md` (bug index), `STANDUP.md` — the cross-milestone state files
  - `milestone-1-task-crud/` — everything M1 produced:
    - `README.md` — milestone definition, Task Index, CEO Approval Conditions
    - `architecture.md` and `ui.md` — the approved design specs
    - `tasks/task-01…05-*.md` — one isolated file per task, each with its
      Context Manifest and Handoff Log
    - `bugs/bug-001…002-*.md` — one file per bug filed during the milestone
    - `reviews/` — the risk review (security + performance lenses) and the CEO
      planning verdict, plus the milestone-completion UX review, the risk
      implementation review, and the close record

## Deliberate Omissions

- **No `.claude/` directory.** In a real populated project this would hold
  the installed agent files (`.claude/agents/*.md`) and skills
  (`.claude/skills/agent-plan/SKILL.md`, `agent-code`, `agent-task`,
  `cast-doctor`, `cast-release`). Including them here would just duplicate the template
  payload verbatim.
- **No `artifacts/DOCTOR.md`.** `/cast-doctor` (the install health check) has
  not been run in this fixture's timeline; its report is created on first run.
- **No `src/` directory.** This fixture demonstrates the *planning and review
  artifacts*, not a working build. Acme Todo is not a real package.
- **No full `docs/` set.** Only `PRD.md`, `CONCEPT.md`, and `GLOSSARY.md`
  are included. The other documentation templates (`CODE_PATTERNS.md`,
  `FILE_CONVENTIONS.md`, `ERROR_HANDLING.md`, etc.) change only trivially
  when populated and are omitted for brevity. `CLAUDE.md` still points at a
  few of them by path, as a real install would.
- **No `templates/` directory and no `artifacts/README.md`.** A real install
  has both — `templates/` holds the document skeletons agents copy into
  `artifacts/` (this fixture ships the *instances* those skeletons produce,
  which is the interesting half), and `artifacts/README.md` is the navigation
  index. `CLAUDE.md` and the artifacts reference them by path; the files
  themselves are template payload, reproduced verbatim, so they are left out.
- **No `artifacts/one-off/` directory.** `/agent-task` work would land there,
  but this fixture's timeline contains no one-off task, and git does not track
  empty directories — so the path exists only in the conventions text.
