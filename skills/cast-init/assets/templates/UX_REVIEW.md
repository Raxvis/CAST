<!-- TEMPLATE INSTRUCTIONS
  FILE: UX_REVIEW.md
  PURPOSE: UX review template. The UI Agent copies this skeleton once per milestone, at
           the /agent-code milestone-completion checkpoint (only for milestones containing
           UI-flagged tasks), reviewing the implemented screens against the approved UI
           specification and recording the verdict Product uses during sign-off.

  HOW TO CUSTOMIZE:
  - Replace [SCREEN_OR_COMPONENT_NAME] with the screen or component under review; a
    milestone with several screens repeats the per-screen sections within the one instance.
  - Reference the approved spec instance in artifacts/ui-specs/, not the template.
  - Work through every section; check items only after verifying them against the
    running implementation.
  - For CLI projects, read the layout-oriented items against terminal output (alignment,
    color usage, truncation, exit-state messaging) rather than pixels.
  - Instance destination: artifacts/reviews/ux-review-milestone-{N}.md — one instance per
    milestone. Never fill this template in place.
  - Sections marked (required) must be present and non-empty in every instance;
    (optional) sections may be omitted. Reviewer and Product check required sections.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# UX Review: [SCREEN_OR_COMPONENT_NAME]

## Revision History (required)

| # | Date | Agent | Reason |
|---|---|---|---|
| v1 | [DATE] | ui | Initial review |

---

## Header (required)

**Date**: [DATE]
**Reviewer**: UI Agent
**Spec Reference**: [SPEC_NAME_OR_LINK]

---

## Responsiveness (required)

- [ ] Layout renders correctly at minimum supported screen size
- [ ] Layout renders correctly at maximum supported screen size
- [ ] No elements are clipped, overlapping, or obscured at any supported size

## Readability (required)

- [ ] All text is legible at the specified sizes
- [ ] No text is truncated unexpectedly
- [ ] Contrast ratios meet accessibility targets

## Touch Targets (required)

- [ ] All interactive elements meet the minimum touch target size requirement
- [ ] Targets do not overlap
- [ ] Feedback is present for all touch interactions (pressed state, animation, etc.)

## Interaction States (required)

- [ ] All six interaction states from the spec are implemented: default, pressed, disabled, loading, error, empty

## Visual Hierarchy (required)

- [ ] The primary action is visually dominant
- [ ] Secondary and tertiary elements are appropriately de-emphasized
- [ ] Empty and error states are visually distinct from the default state

## Consistency (required)

- [ ] Colors match the style guide
- [ ] Typography matches the style guide
- [ ] Spacing matches the style guide
- [ ] Component appearance matches the component spec (if applicable)

## Polish (required)

- [ ] Animations and transitions are implemented per the spec
- [ ] No placeholder text or images remain in the implementation
- [ ] No visual artifacts (misaligned pixels, incorrect shadows, clipped borders)

## Accessibility (required)

- [ ] All interactive elements have accessible labels
- [ ] No information is conveyed by color alone
- [ ] Screen reader behavior is reasonable (if testable)

## Overall Feel (required)

- [ ] The screen feels consistent with the rest of the product
- [ ] The interaction pattern is intuitive — no UI explains itself, the affordance is clear
- [ ] The visual weight and density feel appropriate for the content

---

## Issues Found (required)

| # | Element / Area | Issue | Severity | Action Required |
|---|---|---|---|---|
| | | | | |

---

## Verdict (required)

- [ ] **APPROVED** — Implementation matches spec. No changes required.
- [ ] **APPROVED WITH NOTES** — Minor issues noted. Follow-up in next pass.
- [ ] **CHANGES REQUIRED** — See Issues Found. Coder must revise before Product review.
