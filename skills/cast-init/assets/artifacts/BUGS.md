<!-- TEMPLATE INSTRUCTIONS
  FILE: BUGS.md
  PURPOSE: Central bug tracking log for the project. Use this file to record all known bugs,
           their status, severity, reproduction steps, and resolution details.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name throughout.
  - Replace [PLATFORM_LIST] with the platforms your project targets (e.g., "iOS, Android, Web").
  - Add bug entries as they are discovered using the BUG-XXX format.
  - Move bugs from Open Bugs to Fixed Bugs when resolved.
  - Keep the Regression Checklist updated with critical paths that must be verified after each fix.
  - Severity levels: Critical (blocks use), High (major feature broken), Medium (degraded experience), Low (cosmetic).
  - Frequency levels: Always, Often, Sometimes, Rare.
-->

# [PROJECT_NAME] — Bug Tracking Log

---

## Bug Entry Format

```
### BUG-XXX: [Short Title]
- **Status**: Open / In Progress / Fixed / Won't Fix / Deferred
- **Severity**: Critical | High | Medium | Low
- **Description**: [Detailed description of the bug and its impact on the user experience.]
- **Expected**: [What should happen.]
- **Actual**: [What actually happens.]
- **Steps to Reproduce**:
  1. [Step one]
  2. [Step two]
  3. [Step three]
- **Platform**: [All | iOS | Android | Web | Desktop]
- **Frequency**: Always | Often | Sometimes | Rare
- **Likely Files**:
  - `[path/to/file]`
- **Notes**: [Any additional context, related bugs, or workarounds.]
```

---

## Open Bugs

_No open bugs recorded yet._

---

## Fixed Bugs

_No fixed bugs recorded yet._

### Fixed Bug Format

```
### BUG-XXX: [Short Title]
- **Status**: Fixed
- **Severity**: [Severity at time of fix]
- **Fixed**: [YYYY-MM-DD]
- **Commit**: `[commit hash or reference]`
- **Files Changed**:
  - `[path/to/file]`
- **Root Cause**: [Explanation of why the bug occurred.]
- **Fix**: [Description of the change that resolved the bug.]
- **Regression Notes**: [Any areas to watch for regressions introduced by the fix.]
```

---

## Regression Checklist

Use this table to track critical paths that must be manually verified after significant fixes or refactors.

| # | Area | Check Description | Last Verified | Verified By |
|---|------|-------------------|--------------|-------------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

---

_Last updated: [YYYY-MM-DD]_
