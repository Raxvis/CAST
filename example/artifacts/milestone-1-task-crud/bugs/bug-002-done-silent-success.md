# BUG-002: `done <id>` silently succeeds on non-existent task ID

## Report

- **Status**: Deferred
- **Severity (initial)**: Low
- **Severity (final)**: Low
- **Found during**: M1 milestone-completion smoke testing (relates to T-4, `tasks/task-04-done-delete-commands.md`)
- **Description**: Running `acme done <id>` with an ID that does not correspond to any row in the `tasks` table returns exit code 0 and produces no output. The user has no signal that their command did nothing. This does not affect correctness of normal flows — if the user supplies a real ID, the task is marked completed as expected — but it is a usability papercut that also makes shell scripting around the CLI error-prone.
- **Expected**: The CLI should print an error message to stderr (e.g., `Error: no task with id 999`) and exit with a non-zero status code.
- **Actual**: No output. Exit code 0. The underlying `UPDATE tasks SET completed = 1 WHERE id = ?` runs, affects zero rows, and returns without signalling.
- **Steps to Reproduce**:
  1. Run `acme add "test task"` (creates task with id=1).
  2. Run `acme done 999`.
  3. Observe: no output, `echo $?` prints `0`.
- **Platform**: All (macOS, Linux, Windows)
- **Frequency**: Always
- **Evidence**: None available — reproduces deterministically from the steps above.
- **Likely Files**:
  - `src/commands/done.ts`
- **Regression**: No — the zero-row case was never handled.
- **Related Issues**: None yet — `delete` should receive the same treatment for consistency; add it to the Milestone 2 task when filed.

## Notes

Filed by Reviewer during Milestone 1 manual smoke testing. Triaged by Product on 2026-04-10 and set Deferred (no investigation — deferral decided at triage). Reason for deferral: does not affect correctness of normal flows; usability papercut that can wait. Deferred is an open held state, not terminal: Product re-triaged this entry at the M1 milestone-completion checkpoint on 2026-04-10 and held it Deferred into M2 (paired with the M2 error-signaling task); it will be re-triaged again at the M2 `/agent-plan` Stage 1. The fix will likely check the `changes` field returned by `better-sqlite3`'s `.run()` result and error out when `changes === 0`.

---

_Last updated: 2026-04-10_
