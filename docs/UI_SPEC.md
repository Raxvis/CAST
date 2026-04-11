<!-- TEMPLATE INSTRUCTIONS
  FILE: UI_SPEC.md
  PURPOSE: UI specification for a single screen or component. Use this document to define
           the visual design, layout, states, animations, data requirements, and accessibility
           requirements for one discrete piece of the user interface.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME], [COMPONENT_OR_SCREEN_NAME], [AUTHOR], [VERSION], [DATE] with
    actual values.
  - Replace [TASK_REFERENCE] with a link or ID to the task or milestone this spec implements.
  - Replace [DOMAIN_ENTITY], [RESOURCE_TYPE], [CORE_MECHANIC], [ACTION] with domain-specific
    terms for your project.
  - Fill in the ASCII diagrams with actual layout sketches, using box-drawing characters.
  - Replace [THEME_KEY] with the keys from your design system or theme file.
  - The Acceptance Checklist at the end of each section is the contract — keep it accurate.
  - Status values: Draft / In Review / Approved / Implemented
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — UI Spec: [COMPONENT_OR_SCREEN_NAME]

| Field | Value |
|-------|-------|
| **Version** | [VERSION] |
| **Author** | [AUTHOR] |
| **Date** | [DATE] |
| **Status** | Draft / In Review / Approved / Implemented |
| **Implements** | [TASK_REFERENCE] |

---

## Overview

[Describe what this component or screen does, when it is shown, and why it exists. 2–4 sentences.]

**Related documents:** This screen's data comes from `[MODULE_NAME]` (see `ARCH_MODULE.md`). If this screen uses a specific data schema, see the related `ARCH_DATA_SCHEMA.md` document.

---

## Position

[Describe where this component appears in the overall screen layout. Replace the ASCII diagram below with an accurate representation.]

```
┌──────────────────────────────────────────┐
│              [SCREEN_NAME]               │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  [This component appears here]     │  │
│  └────────────────────────────────────┘  │
│                                          │
│  [ Rest of the screen ]                  │
└──────────────────────────────────────────┘
```

---

## Layout Diagram

[Provide a detailed ASCII layout of the component's internal structure. Label all sub-elements.]

```
┌─────────────────────────────────────────┐
│  [COMPONENT_OR_SCREEN_NAME]             │
│                                         │
│  ┌───────────────┐  ┌────────────────┐  │
│  │  [Element A]  │  │  [Element B]   │  │
│  └───────────────┘  └────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  [Element C — full width]       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌──────┐                               │
│  │  [D] │  [Label text]                 │
│  └──────┘                               │
└─────────────────────────────────────────┘
```

---

## Visual Style

| Property | Value | Theme Key |
|----------|-------|-----------|
| Background color | [e.g., #1A1A2E] | [THEME_KEY] |
| Border | [e.g., 1px solid #333] | [THEME_KEY] |
| Border radius | [e.g., 8px] | [THEME_KEY] |
| Padding | [e.g., 12px] | [THEME_KEY] |
| Text color (primary) | [e.g., #FFFFFF] | [THEME_KEY] |
| Text color (secondary) | [e.g., #AAAAAA] | [THEME_KEY] |
| Accent color | [e.g., #FFD700] | [THEME_KEY] |
| Font size (heading) | [e.g., 18px] | [THEME_KEY] |
| Font size (body) | [e.g., 14px] | [THEME_KEY] |
| Shadow / elevation | [e.g., 4px blur, 20% opacity] | [THEME_KEY] |
| Minimum touch target | [e.g., 44×44pt] | — |

---

## States

| State | Description | Visual Change |
|-------|-------------|---------------|
| Default | Normal resting state | [Describe appearance] |
| Pressed / Active | User is interacting | [Describe visual feedback — e.g., opacity 0.7, scale 0.97] |
| Disabled | Action not available | [Describe appearance — e.g., reduced opacity, no pointer events] |
| Loading | Awaiting data or result | [Describe loading indicator] |
| Empty | No data to display | [Describe empty state appearance or message] |
| Error | An error occurred | [Describe error state appearance or message] |
| [Custom state] | [Description] | [Visual change] |

---

## Animation

| Property | Value | Notes |
|----------|-------|-------|
| Press feedback | [e.g., scale 0.97, duration 80ms] | [Easing or other notes] |
| Entry animation | [e.g., fade in over 200ms] | [Trigger: on mount / on state change] |
| Exit animation | [e.g., fade out over 150ms] | [Trigger: on unmount / on state change] |
| [Custom animation] | [Specification] | [Notes] |

---

## Data Requirements

### Reads

| Data | Source | Format | Notes |
|------|--------|--------|-------|
| `[fieldName]` | [Store / API / Props] | [type] | [Any transformation needed] |
| `[fieldName]` | [Store / API / Props] | [type] | [Any transformation needed] |

### Writes / Actions

| Action | Trigger | Effect |
|--------|---------|--------|
| `[actionName]` | [User event or condition] | [What changes in state or data] |
| `[actionName]` | [User event or condition] | [What changes in state or data] |

---

## Accessibility

| Property | Requirement |
|----------|------------|
| Touch target size | Minimum [44×44pt or equivalent] |
| Accessibility label | `[Description of what the element does]` |
| Accessibility hint | `[Additional context if needed, or "—"]` |
| Accessibility role | `[button / image / text / header / etc.]` |
| Screen reader order | [Describe the expected reading order] |
| Contrast ratio | [Minimum ratio, e.g., 4.5:1 for text] |
| Keyboard / focus support | [Required / Not required — and why] |

---

## Component Structure

[Describe the component hierarchy in pseudocode or outline form.]

```
[COMPONENT_OR_SCREEN_NAME]
  ├── [ContainerElement]
  │     ├── [ChildElement A]          — [purpose]
  │     ├── [ChildElement B]          — [purpose]
  │     │     ├── [ChildElement B1]   — [purpose]
  │     │     └── [ChildElement B2]   — [purpose]
  │     └── [ChildElement C]          — [purpose]
  └── [SecondaryContainerElement]
        └── [ChildElement D]          — [purpose]
```

---

## Edge Cases

| Case | Expected Behavior |
|------|------------------|
| [e.g., Very long text in label] | [e.g., Truncate with ellipsis at 2 lines] |
| [e.g., Large number value] | [e.g., Use abbreviated format — K, M, B] |
| [e.g., Missing or null data] | [e.g., Show placeholder / skeleton] |
| [e.g., Small screen size] | [e.g., Stack elements vertically] |
| [e.g., Rapid successive taps] | [e.g., Debounce — ignore taps within 300ms of first] |

---

## Acceptance Checklist

- [ ] Layout matches the diagram above
- [ ] All states (default, pressed, disabled, loading, empty, error) implemented
- [ ] Accessibility requirements met (labels, roles, contrast, touch targets)
- [ ] Animations match spec (duration, easing, triggers)
- [ ] Edge cases handled per the Edge Cases table
- [ ] Component renders correctly on all target platforms
- [ ] No linter or type-check errors introduced

---

## Product Approval

| Field | Value |
|-------|-------|
| **Approved by** | [NAME or ROLE] |
| **Date** | [YYYY-MM-DD] |
| **Status** | Pending / Approved / Changes Requested |
| **Notes** | [Any conditions or feedback.] |

---

_Last updated: [YYYY-MM-DD]_
