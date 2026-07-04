<!-- TEMPLATE INSTRUCTIONS
  FILE: ARCH_MODULE.md
  PURPOSE: Architecture specification for a single, self-contained module. Use this document
           to define the data model, public API, integration points, and testing strategy
           for one logical unit of the system (e.g., a data layer, a calculation engine,
           a service, or a manager).

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME], [MODULE_NAME], [AUTHOR], [VERSION], [DATE] with actual values.
  - Replace [DOMAIN_ENTITY], [RESOURCE_TYPE], [PROGRESSION_UNIT], [CORE_MECHANIC] with
    domain-specific terms appropriate to your project.
  - Replace [FRAMEWORK], [LANGUAGE], [STATE_LIBRARY], [PERSISTENCE_LAYER] with your stack.
  - Fill in the Data Model, API Contract, and Integration sections with real details.
  - Keep the Acceptance Checklist updated — it is the contract between the engineer and
    the product owner.
  - Status values: Draft / In Review / Approved / Implemented
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Architecture Spec: [MODULE_NAME]

| Field | Value |
|-------|-------|
| **Version** | [VERSION] |
| **Date** | [DATE] |
| **Author** | [AUTHOR] |
| **Status** | Draft / In Review / Approved / Implemented |

---

## Overview

### Purpose

[Describe what this module does, why it exists, and what problem it solves. 2–4 sentences.]

**Related documents:** If this module has a UI, see the related `UI_SPEC.md` document. If this module defines a data schema, see the related `ARCH_DATA_SCHEMA.md` document.

### Scope

**In scope**:
- [What this module is responsible for]
- [What this module calculates, manages, or provides]

**Out of scope**:
- [What this module intentionally does NOT do]
- [Concerns handled by a different module]

### Dependencies

| Dependency | Type | Purpose |
|------------|------|---------|
| [MODULE or LIBRARY] | Internal / External | [Why it is needed] |
| [MODULE or LIBRARY] | Internal / External | [Why it is needed] |

---

## Data Model

### Interfaces & Types

```
// Primary data structure
interface [DOMAIN_ENTITY] {
  id: [ID_TYPE];
  [field]: [type];       // [description]
  [field]: [type];       // [description]
  [field]: [type];       // [description]
}

// Supporting type
interface [SUPPORTING_TYPE] {
  [field]: [type];       // [description]
}

// Union / alias example
type [STATUS_TYPE] = '[VALUE_A]' | '[VALUE_B]' | '[VALUE_C]';
```

### Serialization

[Describe how this module's data is serialized for persistence or transmission. Note any fields that require special handling, transformation, or versioning.]

| Field | Serialized As | Notes |
|-------|--------------|-------|
| [field] | [format/type] | [any special handling] |

---

## API Contract

### Public Functions

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `[functionName]` | `([param]: [type]) => [ReturnType]` | `[ReturnType]` | [What it does] |
| `[functionName]` | `([param]: [type], [param]: [type]) => [ReturnType]` | `[ReturnType]` | [What it does] |
| `[functionName]` | `([param]: [type]) => [ReturnType]` | `[ReturnType]` | [What it does] |

### Function Details

#### `[functionName]`

```
function [functionName]([param]: [type]): [ReturnType]
```

**Purpose**: [What this function computes or produces.]

**Parameters**:
- `[param]` — [description and constraints]

**Returns**: [Description of the return value.]

**Edge cases**:
- [What happens when input is zero/null/empty]
- [What happens at boundary values]

---

## Integration with Store

[Describe how this module connects to the application's state management layer.]

```
// Example: how the store calls into this module
[storeAction]: ([param]) => {
  const result = [moduleFunctionName](get().[stateField], [param]);
  set({ [stateField]: result });
}
```

State fields managed by this module's outputs:

| Store Field | Type | Updated By |
|-------------|------|-----------|
| `[field]` | `[type]` | `[action name]` |

---

## File Structure

```
[source-directory]/
  [module-file].[ext]          # [brief description of this file's role]
  [related-file].[ext]         # [brief description]
```

---

## Implementation Notes

### Performance

- [Any performance constraints or targets for this module]
- [Caching strategy, if applicable]
- [Computation complexity notes]

### Edge Cases

| Case | Expected Behavior |
|------|------------------|
| [Edge case description] | [How the module handles it] |
| [Edge case description] | [How the module handles it] |

### [FRAMEWORK]-Specific Patterns

[Note any conventions, idioms, or constraints specific to your framework or runtime that apply to this module.]

- [Pattern or constraint]
- [Pattern or constraint]

---

## Integration Points

### With UI

[Describe how UI components consume this module's output.]

| UI Component | What It Reads | How |
|-------------|--------------|-----|
| `[ComponentName]` | `[data or computed value]` | [via store selector / direct call] |

### With Other Systems

| System | Relationship | Direction |
|--------|-------------|----------|
| `[OtherModule]` | [Description of dependency] | [Reads from / Writes to / Bidirectional] |

---

## Testing Strategy

### Test Cases

| # | Test | Input | Expected Output |
|---|------|-------|----------------|
| 1 | [Description] | [Input values] | [Expected result] |
| 2 | [Description] | [Input values] | [Expected result] |
| 3 | Edge: [Description] | [Input values] | [Expected result] |

### Manual Testing

- [ ] [Manual test step or scenario]
- [ ] [Manual test step or scenario]
- [ ] [Manual test step or scenario]

---

## Performance Budget

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| [Computation time] | [< X ms] | [How to measure] |
| [Memory usage] | [< X KB] | [How to measure] |
| [Other metric] | [Target] | [How to measure] |

---

## Acceptance Checklist

- [ ] All public functions implemented and match the API Contract table
- [ ] All edge cases handled per the Edge Cases table
- [ ] All unit test cases pass
- [ ] All manual testing steps verified
- [ ] Performance budget met
- [ ] Integrated with store and verified via UI
- [ ] No linter or type-check errors
- [ ] Code reviewed and merged

---

## Product Approval

| Field | Value |
|-------|-------|
| **Approved by** | [NAME or ROLE] |
| **Date** | [YYYY-MM-DD] |
| **Notes** | [Any conditions or follow-up items] |

---

_Last updated: [YYYY-MM-DD]_
