<!-- TEMPLATE INSTRUCTIONS
  FILE: MVP_LAUNCH.md
  PURPOSE: Launch readiness audit template. Use this document to assess whether the project
           is ready for release by cataloguing bugs, verifying requirements alignment,
           and tracking launch blockers.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - Replace [VERSION] with the target release version (e.g., "1.0.0").
  - Replace [AUDIT_DATE] with the date this audit was conducted.
  - Fill in the Overall Verdict table with the current status for each area.
  - Add entries to bug/issue tables as they are discovered.
  - Update the Requirements Alignment table from your PRD or requirements document.
  - Work through the Launch Checklist and mark items Complete / In Progress / Not Started.
  - Status values used throughout: Complete / In Progress / Not Started / Blocked / N/A.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Launch Readiness Audit

**Version**: [VERSION]
**Audit Date**: [AUDIT_DATE]
**Auditor**: [NAME or ROLE]

---

## Overall Verdict

| Area | Status | Notes |
|------|--------|-------|
| Critical Bugs | | |
| Core Feature Completeness | | |
| Performance | | |
| Persistence / Data Integrity | | |
| UI / UX Polish | | |
| Accessibility | | |
| Store / Distribution Requirements | | |
| Security & Privacy | | |
| **Overall** | | |

---

## Critical Code Bugs

Bugs that will prevent submission or cause unacceptable user-facing failures.

| ID | Title | Severity | Status | Owner |
|----|-------|----------|--------|-------|
| | | | | |

---

## Critical Launch Blockers

Non-bug blockers (missing assets, policy requirements, infrastructure, etc.) that must be resolved before launch.

| # | Blocker | Area | Status | Owner |
|---|---------|------|--------|-------|
| | | | | |

---

## Major Issues

### Logic Issues

_Issues with core [DOMAIN_ENTITY] logic, calculations, or [CORE_MECHANIC] behavior._

| ID | Description | Impact | Status |
|----|-------------|--------|--------|
| | | | |

### State / Data Issues

_Issues with state management, persistence, or data integrity._

| ID | Description | Impact | Status |
|----|-------------|--------|--------|
| | | | |

### UI Issues

_Layout, display, or interaction problems that significantly degrade experience._

| ID | Description | Platform | Status |
|----|-------------|----------|--------|
| | | | |

---

## Minor Issues

_Non-blocking issues acceptable for launch but should be tracked for follow-up._

| ID | Description | Area | Priority |
|----|-------------|------|----------|
| | | | |

---

## What's Working Well

_Areas of the product that are solid and require no action before launch._

- [Item]
- [Item]
- [Item]

---

## Requirements Alignment

Verify that all requirements from the product specification are implemented.

| Section | Feature / Requirement | Status | Notes |
|---------|-----------------------|--------|-------|
| | | | |
| | | | |
| | | | |

---

## Launch Checklist

### Blocking — Cannot Submit Without

| # | Item | Status | Owner |
|---|------|--------|-------|
| 1 | All Critical bugs resolved | | |
| 2 | All Critical launch blockers resolved | | |
| 3 | Production build tested end-to-end on all target platforms | | |
| 4 | Data persistence verified (save/load cycle, migration) | | |
| 5 | Distribution requirements met (platform-specific policies, if applicable) | | |
| 6 | Release artifacts produced and verified (binaries, packages, images) | | |
| 7 | Release notes / changelog updated | | |
| 8 | [Add project-specific blocking items] | | |

### Important — Should Fix Before Launch

| # | Item | Status | Owner |
|---|------|--------|-------|
| 1 | All High severity bugs resolved | | |
| 2 | All Major issues resolved | | |
| 3 | Performance within acceptable targets | | |
| 4 | Accessibility basics verified | | |
| 5 | [Add project-specific important items] | | |

### Optional — Post-Launch Acceptable

| # | Item | Status | Owner |
|---|------|--------|-------|
| 1 | All Medium severity bugs resolved | | |
| 2 | All Minor issues resolved | | |
| 3 | Advanced accessibility support | | |
| 4 | Analytics integration | | |
| 5 | [Add project-specific optional items] | | |

---

## Recommendations

### Do Now (Before Any Submission)

1. [Recommendation]
2. [Recommendation]

### Do Soon (Before Wide Release)

1. [Recommendation]
2. [Recommendation]

### Post-Launch

1. [Recommendation]
2. [Recommendation]

---

_Last updated: [YYYY-MM-DD]_
