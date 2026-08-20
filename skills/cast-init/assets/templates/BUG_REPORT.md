<!-- TEMPLATE INSTRUCTIONS
  FILE: BUG_REPORT.md
  PURPOSE: Template for a SINGLE bug report file. One instance per bug:
           artifacts/milestone-{N}-{slug}/bugs/bug-{XXX}-{slug}.md for bugs found during
           pipeline work, artifacts/one-off/bugs/bug-{XXX}-{slug}.md for /agent-task work.
           Reviewer creates the instance and adds a row to the global index in
           artifacts/BUGS.md, which also carries the canonical lifecycle, severity scale,
           and field-ownership rules — this template only defines the file's shape.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace [PLATFORM_LIST] with the platforms your project targets (e.g., "iOS, Android, Web").
  - The ID comes from artifacts/BUGS.md (sequential across the project, never reused).
  - The file never moves; its Status field advances per the lifecycle in artifacts/BUGS.md,
    and the owner mirrors each status change into the index row in the same step.
  - Sections marked (required) are written at filing by Reviewer. The Investigation
    and Resolution sections are appended later by their owners (see the field-ownership
    table in artifacts/BUGS.md) — leave them out at filing time.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# BUG-XXX: [Short Title]

## Report (required)

- **Status**: New / Triaged / In Progress / Fixed / Verified / Closed / Cannot Reproduce / Duplicate / Won't Fix / Deferred
- **Severity (initial)**: Critical | High | Medium | Low   _(set by Reviewer; Product sets the final severity at triage)_
- **Severity (final)**: Critical | High | Medium | Low   _(set by Product at triage)_
- **Found during**: [Task ID or milestone reference, or "one-off"]
- **Description**: [Detailed description of the bug and its impact on the user experience.]
- **Expected**: [What should happen.]
- **Actual**: [What actually happens.]
- **Steps to Reproduce**:
  1. [Step one]
  2. [Step two]
  3. [Step three]
- **Platform**: [All | [PLATFORM_LIST]]
- **Frequency**: Always | Intermittent — [N] of [M] | Observed once | Unknown
- **Evidence**: [Link to screenshot, recording, or log. Or: "None available."]
- **Likely Files**:
  - `[path/to/file]`
- **Regression**: [Yes / No — if yes, what changed since it last worked. Or: "Unknown."]
- **Related Issues**: [Related bug IDs or tasks. Or: "None."]

## Investigation (optional) — written by Coder before a non-obvious fix

- **Root Cause**: [Why the defect occurs.]
- **Affected Module(s)**: [Files or modules involved.]
- **Alternative Solutions**: [At least two approaches with trade-offs, for non-trivial bugs.]
- **Recommended Fix**: [The approach chosen and why; one line on what else was considered.]
- **Assigned To**: [Coder or Refactor]
- **Investigation Date**: [YYYY-MM-DD]

## Resolution (optional) — written by Coder at fix time

- **Commit**: `[hash of the stacking fix commit — produced by the Commit discipline in docs/PIPELINE_LOOP.md]`
- **Files Changed**:
  - `[path/to/file]`
- **Regression Notes**: [Areas to watch for regressions introduced by the fix.]

## Notes (optional)

[Any additional context, workarounds, or severity rationale.]

---

_Last updated: [YYYY-MM-DD]_
