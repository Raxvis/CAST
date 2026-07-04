# Acme Todo — Security Review: Milestone 1 (Task CRUD + SQLite Persistence)

## Revision History

| Rev | Date | Agent | Change |
|-----|------|-------|--------|
| v1 | 2026-04-08 | security | Initial security review |

---

**Reviewer**: Security Agent
**Model**: claude-opus-4-8
**Date**: 2026-04-08
**Stage**: `/agent-plan` Stage 3a
**Inputs Reviewed**:
- Milestone: `artifacts/milestones/milestone-1-task-crud.md`
- Architecture: `artifacts/architecture/arch-milestone-1.md`
- UI Spec: `artifacts/ui-specs/ui-milestone-1.md`

---

## Summary

Two findings filed against the Milestone 1 architecture. One Critical (SQL injection surface area across every command handler) and one Medium (unvalidated environment variable consumed as a filesystem path). Neither finding requires an architectural rework; both have concrete, localized remediations. The Critical finding is escalated to the CEO for inclusion as an Approval Condition.

---

## Findings

| # | Severity | Module | Status | Date | Notes |
|---|---|---|---|---|---|
| 1 | Critical | `src/db/`, `src/commands/*` | Remediation required | 2026-04-08 | Escalated to CEO as Approval Condition 1 |
| 2 | Medium | `src/db/connection.ts` | Accepted risk (v1) | 2026-04-08 | Logged for Milestone 2 revisit |

---

### Finding 1 — SQL Injection Risk in Command Handlers

- **Severity**: Critical
- **Module**: `src/db/`, `src/commands/*`
- **Cited Standard**: OWASP A03:2021 — Injection
- **Description**: The architecture document describes SQL queries issued from each command handler (`add`, `list`, `done`, `delete`) but does not mandate how query parameters are bound. If any handler constructs SQL via string concatenation or template interpolation, a crafted task title or ID argument can trivially inject arbitrary SQL. Because Acme Todo stores its database at a predictable default path (`~/.acme-todo/tasks.db`), a malicious input through any of the four write paths could drop the `tasks` table or corrupt the schema.
- **Attack Surface**: Every CLI argument that reaches a SQL query — task title (`add`), task ID (`done`, `delete`), and filter flags (`list`).
- **Remediation**: Mandate parameterized bindings via `better-sqlite3`'s `.prepare().run(params)` or `.prepare().all(params)` API across every command handler. Forbid string concatenation, template literals, or any dynamic assembly of SQL strings. Add a lint rule or Reviewer checklist item to catch regressions.
- **Verification**: Reviewer inspects every query site during T-1 through T-4 code review and confirms parameterized bindings are used exclusively.
- **Status**: Remediation enforced via CEO Approval Condition 1. Verified by Reviewer during code review.

---

### Finding 2 — Unvalidated `ACME_TODO_DB` Environment Variable

- **Severity**: Medium
- **Module**: `src/db/connection.ts`
- **Cited Standard**: OWASP A01:2021 — Broken Access Control (trust boundaries)
- **Description**: The architecture allows the user to override the database path via the `ACME_TODO_DB` environment variable. No validation is specified: a value like `../../etc/acme.db`, a UNC path on Windows, or a path inside a world-writable directory would be accepted verbatim and handed to `better-sqlite3`. The CLI would then create (or overwrite) a SQLite file at that location on next run. Because the CLI runs with the invoking user's privileges, this does not cross a privilege boundary, but it violates the principle of validating all inputs at trust boundaries and could be weaponized by a shell-drop attacker to plant data in unexpected locations.
- **Remediation**: In `src/db/connection.ts`, resolve `ACME_TODO_DB` to an absolute path using `path.resolve()`. Reject empty string values. Default to `~/.acme-todo/tasks.db` when the env var is unset. Do not enforce a directory allow-list for v1 — a single-user CLI cannot meaningfully defend against an attacker who already has shell access as the user.
- **Verification**: Coder implements path resolution during T-1. Tester adds a unit test for the default path, an explicit override path, and an empty string override.
- **Status**: Accepted as low risk for v1 (single-user CLI, attacker would already have shell access). Not escalated to a CEO Approval Condition. Logged in the Decisions Log below for revisiting in Milestone 2 if the CLI ever grows a daemon mode or multi-user surface.

---

## Decisions Log

| Date | Decision | Rationale | Impact |
|---|---|---|---|
| 2026-04-08 | Escalate Finding 1 to CEO as Approval Condition | Critical severity; touches every write path | Coder must use `.prepare().run(params)` exclusively; Reviewer gates merge |
| 2026-04-08 | Accept Finding 2 as v1 risk, revisit in M2 | Single-user CLI, no privilege boundary crossed | Path resolution still required, but no allow-list enforcement |

---

## Notes

- No new third-party dependencies beyond `better-sqlite3` were introduced by this milestone; no dependency audit required.
- No authentication, authorization, or network surface exists in Milestone 1 — scope is local filesystem and local SQLite only.
- The `src/types/task.ts` type definition does not itself introduce a security concern but should not be used to validate untrusted input; all validation must happen at the command handler boundary.
