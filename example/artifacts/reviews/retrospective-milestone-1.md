# Milestone Retrospective: M1: Task CRUD + SQLite Persistence

## Revision History

| # | Date | Agent | Reason |
|---|---|---|---|
| v1 | 2026-04-10 | validator | Initial retrospective |

---

## Header

**Date**: 2026-04-10
**Facilitator**: Validator Agent
**Participants**: product, architect, ui, security, performance, ceo, coder, tester, reviewer, debugger, bug-gatherer, docs-writer, validator

---

## Estimated vs Actual Effort

- **Estimated**: ~1.5 engineer-days — from the "Estimated Effort" field in the milestone definition (`artifacts/milestones/milestone-1-task-crud.md`)
- **Actual**: 3 sessions across 3 calendar days, 2026-04-08 to 2026-04-10 — from the session dates for this milestone in `artifacts/STANDUP.md` (first to last session)
- **Delta**: The engineering work itself (2026-04-09 and 2026-04-10) matched the ~1.5-day estimate; the third calendar day is the planning session, which the estimate deliberately excluded. The only unplanned engineering cost was the BUG-001 fix in T-3, which stayed inside the same session (loop 2/3, no escalation).

---

## What Went Well

_Be specific. Reference tasks, agents, or decisions that were particularly effective._

- CEO Approval Condition 3 was written defensively during planning and caught BUG-001 during T-3 implementation — the fix landed in the same session instead of becoming a post-release hotfix.
- The Defect routing on BUG-001 worked end to end in one session: Reviewer classified it, Bug Gatherer filed it, Product triaged fix-now, Debugger produced three costed alternatives, and Coder shipped the recommended fix (`a8f3d12`).
- T-1 shipping first as a hard dependency gate kept T-2/T-3/T-4 from colliding — the three parallel tasks touched only their own command files.
- The Docs Writer queue kept documentation current without a dedicated docs pass: all 4 queued `docs` entries were drained at task-completion checkpoints, and the milestone-completion drain found nothing pending.

---

## What Didn't Go Well

_Be specific and honest. This is not a blame log — it is a process improvement record._

- BUG-002 (`done` silently succeeds on a missing ID) should have been caught by T-4's acceptance criteria. The criteria required "error if ID not found" for `delete` but left the equivalent for `done` implicit; the gap surfaced only in manual smoke testing during T-5 validation.
- The migration runner's directory-creation step for `~/.acme-todo/` was added late, after manual testing on Linux — architecture review did not explicitly cover filesystem prerequisites.
- The performance budget table could not be populated until after T-5 landed, because the benchmark plan depended on end-to-end CLI wiring. Budget tracking was blind for most of the milestone.

---

## Process Issues

No process issues. (Process Violations and Conflicts tables in `artifacts/AGENT_STATE.md` → `## validator` are both empty; every handoff followed the pipeline loop.)

---

## Metrics

_Fill each metric from its recorded source (validator.md → Metric Sources) — do not estimate._

| Metric | Value | Source |
|---|---|---|
| Tasks planned | 5 | Summary table in `artifacts/milestones/milestone-1-task-crud-tasks.md` |
| Tasks completed | 5 | Summary table in `artifacts/milestones/milestone-1-task-crud-tasks.md` |
| Tasks rejected by Product | 0 | Summary table in `artifacts/milestones/milestone-1-task-crud-tasks.md` — average rejections per task: 0 |
| Process violations | 0 | Process Violations table in `artifacts/AGENT_STATE.md` → `## validator` |
| Conflicts escalated to Validator | 0 | Conflicts table in `artifacts/AGENT_STATE.md` → `## validator` |
| Architecture doc revisions | 1 | `## Revision History` table in `artifacts/architecture/arch-milestone-1.md` |
| UI spec revisions | 1 | `## Revision History` table in `artifacts/ui-specs/ui-milestone-1.md` |

---

## Actions for Next Milestone

| # | Action | Owner | Due |
|---|---|---|---|
| 1 | Fix BUG-002: `done <id>` must error non-zero when the ID does not exist; un-skip the reserved Vitest case | coder | M2 |
| 2 | Make "error on missing id" a standard acceptance criterion for every id-based mutation command | product | M2 planning (Stage 1) |
| 3 | Add filesystem prerequisites (DB parent-directory creation) to the architecture review checklist | architect | M2 planning (Stage 2a) |
| 4 | Automate the performance benchmark suite so budget tracking is populated during engineering, not after close | tester | M2 |
