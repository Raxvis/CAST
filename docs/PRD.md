<!-- TEMPLATE INSTRUCTIONS
  FILE: PRD.md
  PURPOSE: The Product Requirements Document is the authoritative source for what the
  product must do. It bridges the vision in CONCEPT.md with the implementation work
  in code. Every feature must be traceable back to a user story and acceptance criterion
  in this document. Engineers, designers, and QA all refer to the PRD to determine
  whether a feature is "done".

  HOW TO CUSTOMIZE:
  - Replace every [PLACEHOLDER] token with real project content.
  - User Stories follow the format: "As a [USER_TYPE], I want to [ACTION] so that [BENEFIT]."
  - Acceptance Criteria are written as binary pass/fail statements (present tense).
  - Keep the Success Metrics section honest — define what "success" means before you ship,
    not after.
  - The Timeline section uses milestone names, not calendar dates. Add dates only in a
    separate project management tool, not here.
  - The Appendix should contain reference data (tables, formulae) that would disrupt
    reading flow if placed inline.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Product Requirements Document

**Version:** [VERSION]
**Status:** Draft / In Review / Approved

---

## Executive Summary

[PROJECT_NAME] is a [PRODUCT_TYPE] for [TARGET_PLATFORM_LIST]. It targets [PRIMARY_USER_SEGMENT]
who want [USER_NEED]. The product is differentiated by [KEY_DIFFERENTIATOR] and is
targeting [PRIMARY_USER_SEGMENT].

**MVP scope:** [2-3 sentences summarizing what will ship in the initial release and what
is explicitly deferred to post-launch.]

---

## Problem Statement

**User problem:** [Describe the real-world need or frustration this product addresses.
Avoid describing the solution here — focus on the problem.]

**Opportunity:** [Why is now the right time to build this? What market gap or user
behavior makes this product viable?]

**Hypothesis:** If we build [SOLUTION_DESCRIPTION], then [USER_TYPE] will [MEASURABLE_BEHAVIOR],
which will result in [BUSINESS_OUTCOME].

---

## Target Users

### Primary User

- **Segment:** [E.g. "Casual mobile gamers aged 18-35"]
- **Context of use:** [When and where do they use the product?]
- **Key need:** [What is the single most important thing they need from this product?]
- **Behavior pattern:** [E.g. "Checks in 2-5 times per day for sessions of 3-10 minutes"]

### Secondary User

- **Segment:** [E.g. "Enthusiast players who engage deeply with progression systems"]
- **Context of use:** [When and where do they use the product?]
- **Key need:** [What does this user want that the primary user does not prioritize?]
- **Behavior pattern:** [E.g. "Plays daily, optimizes for efficiency, reads wikis"]

---

## Success Metrics

### Retention KPIs

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Day 1 Retention | [TARGET]% | [HOW_MEASURED] |
| Day 7 Retention | [TARGET]% | [HOW_MEASURED] |
| Day 30 Retention | [TARGET]% | [HOW_MEASURED] |
| [CUSTOM_METRIC] | [TARGET] | [HOW_MEASURED] |

### Revenue KPIs

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Conversion Rate (free → paying) | [TARGET]% | [HOW_MEASURED] |
| Average Revenue Per User (ARPU) | [TARGET] | [HOW_MEASURED] |
| Average Revenue Per Paying User (ARPPU) | [TARGET] | [HOW_MEASURED] |
| [CUSTOM_METRIC] | [TARGET] | [HOW_MEASURED] |

### Quality Metrics

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Crash-Free Session Rate | [TARGET]% | [HOW_MEASURED] |
| [PERFORMANCE_METRIC] | [TARGET] | [HOW_MEASURED] |
| App Store / Platform Rating | [TARGET] stars | User reviews |

---

## Core Features

### Feature 1: [FEATURE_NAME]

**Description:** [Brief plain-language description of this feature and what user need it satisfies.]

**User Stories:**

- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].
- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].

**Acceptance Criteria:**

- [ ] [Criterion 1: a binary, testable statement of the feature's behavior.]
- [ ] [Criterion 2: another binary, testable statement.]
- [ ] [Criterion 3: edge case or error state handling.]
- [ ] [Criterion 4: performance or quality requirement specific to this feature.]

**Out of scope for MVP:** [List anything related to this feature that will NOT ship in MVP.]

---

### Feature 2: [FEATURE_NAME]

**Description:** [Brief plain-language description.]

**User Stories:**

- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].
- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].

**Acceptance Criteria:**

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Out of scope for MVP:** [List anything deferred.]

---

### Feature 3: [FEATURE_NAME]

**Description:** [Brief plain-language description.]

**User Stories:**

- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].
- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].

**Acceptance Criteria:**

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Out of scope for MVP:** [List anything deferred.]

---

### Feature 4: [FEATURE_NAME]

**Description:** [Brief plain-language description.]

**User Stories:**

- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].

**Acceptance Criteria:**

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Out of scope for MVP:** [List anything deferred.]

---

### Feature 5: [FEATURE_NAME]

**Description:** [Brief plain-language description.]

**User Stories:**

- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].

**Acceptance Criteria:**

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Out of scope for MVP:** [List anything deferred.]

---

### Feature 6: [FEATURE_NAME] (Post-Launch)

**Description:** [Brief plain-language description. Mark post-launch features clearly.]

**User Stories:**

- As a [USER_TYPE], I want to [ACTION] so that [BENEFIT].

**Acceptance Criteria:**

- [ ] [Criterion 1]
- [ ] [Criterion 2]

---

## Non-Functional Requirements

### Performance

- [PERFORMANCE_REQUIREMENT_1, e.g. "The application must maintain a stable update rate
  of at least [RATE] on [MINIMUM_SPEC_DEVICE]."]
- [PERFORMANCE_REQUIREMENT_2, e.g. "Cold start time must not exceed [TIME] seconds."]
- [PERFORMANCE_REQUIREMENT_3, e.g. "Memory usage must not exceed [LIMIT] on the target
  minimum-spec device."]

### Compatibility

- [COMPATIBILITY_REQUIREMENT_1, e.g. "Must support [PLATFORM_LIST]."]
- [COMPATIBILITY_REQUIREMENT_2, e.g. "Minimum supported OS versions: [OS_LIST]."]
- [COMPATIBILITY_REQUIREMENT_3, e.g. "Must function correctly in both portrait and
  landscape orientation." — or delete if not applicable.]

### Reliability

- [RELIABILITY_REQUIREMENT_1, e.g. "User data must never be silently lost. If a save
  operation fails, the error must be caught and the user must be notified."]
- [RELIABILITY_REQUIREMENT_2, e.g. "The application must recover gracefully from corrupt
  or missing save data by falling back to a valid default state."]
- [RELIABILITY_REQUIREMENT_3, e.g. "Offline progress must be calculated deterministically.
  The same save state loaded at the same elapsed time must always yield the same result."]

### Accessibility

- [ACCESSIBILITY_REQUIREMENT_1, e.g. "All interactive elements must meet minimum touch
  target size guidelines for the target platform."]
- [ACCESSIBILITY_REQUIREMENT_2, e.g. "Text must meet minimum contrast ratios as defined
  by [ACCESSIBILITY_STANDARD]."]
- [ACCESSIBILITY_REQUIREMENT_3, e.g. "Critical information must not be conveyed by color
  alone."]

### Security

- [SECURITY_REQUIREMENT_1, e.g. "Purchase receipts must be validated before granting
  entitlements."]
- [SECURITY_REQUIREMENT_2, e.g. "User data must be stored with appropriate access controls."]
- [SECURITY_REQUIREMENT_3, e.g. "No sensitive user information may be logged."]

---

## Technical Constraints

### [FRAMEWORK] and Architecture

- The project is built with [FRAMEWORK] and must conform to the patterns described in
  `CODE_PATTERNS.md`.
- The project uses [STATE_LIBRARY] for state management. All shared application state
  must flow through [STATE_LIBRARY].
- File placement must conform to `FILE_CONVENTIONS.md`.

### Persistence

- User data is persisted via [PERSISTENCE_LAYER].
- The save format must include a version field and support forward migration.
- The application must handle missing, empty, or corrupt save data without crashing.

### Dependencies

- New dependencies must be evaluated for [FRAMEWORK] compatibility before adoption.
- Dependencies must be managed via the project's package manager. See `README.md` for
  the correct installation command.

### Build

- The project must build successfully for [PLATFORM_LIST] without modification.
- The build process is documented in the root `README.md`.

---

## Timeline

The project is organized into the following milestones. Each milestone has a dedicated
task file (`artifacts/milestones/milestone-{N}-{slug}-tasks.md`) listing concrete acceptance criteria.

| Milestone | Description |
|-----------|-------------|
| [M1_NAME] | [Brief description of what is complete when this milestone is done.] |
| [M2_NAME] | [Brief description.] |
| [M3_NAME] | [Brief description.] |
| [M4_NAME] | [Brief description.] |
| [M5_NAME] | [Brief description.] |
| MVP Launch | All core features accepted. Product is publicly available. |

---

## Post-Launch Roadmap

These items are confirmed as out of scope for MVP but are planned for future releases.
They are listed here to inform architectural decisions made during MVP development.

- **[POST_LAUNCH_ITEM_1]:** [Brief description.]
- **[POST_LAUNCH_ITEM_2]:** [Brief description.]
- **[POST_LAUNCH_ITEM_3]:** [Brief description.]
- **[POST_LAUNCH_ITEM_4]:** [Brief description.]

---

## Appendix

### A. [APPENDIX_TITLE, e.g. "Economy Scaling Reference"]

[Insert reference table, formula, or data set here. Example:]

| [LEVEL] | [COST] | [REVENUE] | [NOTES] |
|---------|--------|-----------|---------|
| 1 | [VALUE] | [VALUE] | [NOTE] |
| 2 | [VALUE] | [VALUE] | [NOTE] |
| ... | ... | ... | ... |

### B. [APPENDIX_TITLE, e.g. "Platform-Specific Notes"]

[Insert platform-specific notes, constraints, or store submission requirements.]

### C. Revision History

| Version | Change Summary |
|---------|---------------|
| [VERSION] | [CHANGE_SUMMARY] |
| [VERSION] | [CHANGE_SUMMARY] |

---

_Last updated: [YYYY-MM-DD]_
