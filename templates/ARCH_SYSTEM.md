<!-- TEMPLATE INSTRUCTIONS
  FILE: ARCH_SYSTEM.md
  PURPOSE: Architecture specification for a multi-module system. Use this document when
           a feature or capability spans several modules that must work together — for
           example, a complete loop involving data, state, and UI layers.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME], [SYSTEM_NAME], [AUTHOR], [VERSION], [DATE] with actual values.
  - Replace [MODULE_A], [MODULE_B], etc. with the actual module names in your system.
  - Replace [DOMAIN_ENTITY], [RESOURCE_TYPE], [CORE_MECHANIC], [STATE_LIBRARY],
    [PERSISTENCE_LAYER], [FRAMEWORK] with domain- and stack-specific terms.
  - Fill in the Component Diagram and Data Flow with real details for your system.
  - The Acceptance Checklist is the contract — keep it accurate and up to date.
  - Status values: Draft / In Review / Approved / Implemented
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Architecture Spec: [SYSTEM_NAME]

| Field | Value |
|-------|-------|
| **Version** | [VERSION] |
| **Date** | [DATE] |
| **Author** | [AUTHOR] |
| **Status** | Draft / In Review / Approved / Implemented |

---

## Overview

### Purpose

[Describe what this system does and why it exists as a multi-module system rather than a single module. 2–4 sentences.]

### Scope

**In scope**:
- [What this system is collectively responsible for]
- [Which user-facing behaviors or capabilities this system enables]

**Out of scope**:
- [What this system does NOT cover]
- [Adjacent systems that interact but are not part of this spec]

### Key Components

| Component | Role |
|-----------|------|
| [MODULE_A] | [Brief description of its responsibility] |
| [MODULE_B] | [Brief description of its responsibility] |
| [MODULE_C] | [Brief description of its responsibility] |
| [STATE_LAYER] | [How state is managed across the system] |
| [PERSISTENCE_LAYER] | [How data is persisted] |

---

## System Architecture

### Component Diagram

```
[Describe the relationship between components using ASCII or a text-based diagram.]

  ┌─────────────────────────────────────────────────────────┐
  │                    [SYSTEM_NAME]                        │
  │                                                         │
  │  ┌──────────────┐       ┌──────────────┐               │
  │  │  [MODULE_A]  │──────▶│  [MODULE_B]  │               │
  │  └──────────────┘       └──────┬───────┘               │
  │                                │                        │
  │                         ┌──────▼───────┐               │
  │                         │  [MODULE_C]  │               │
  │                         └──────────────┘               │
  └─────────────────────────────────────────────────────────┘
```

### Data Flow

[Describe how data moves through the system end-to-end.]

1. [Step 1: Source of input or trigger]
2. [Step 2: First transformation or action]
3. [Step 3: State update or side effect]
4. [Step 4: Output or UI update]
5. [Step 5: Persistence, if applicable]

---

## Module Specifications

### [MODULE_A]

**Responsibility**: [What this module is solely responsible for.]

**Inputs**:
- `[input]` — [type and description]

**Outputs**:
- `[output]` — [type and description]

**Key Functions**:

| Function | Signature | Description |
|----------|-----------|-------------|
| `[fnName]` | `([params]) => [ReturnType]` | [What it does] |
| `[fnName]` | `([params]) => [ReturnType]` | [What it does] |

---

### [MODULE_B]

**Responsibility**: [What this module is solely responsible for.]

**Inputs**:
- `[input]` — [type and description]

**Outputs**:
- `[output]` — [type and description]

**Key Functions**:

| Function | Signature | Description |
|----------|-----------|-------------|
| `[fnName]` | `([params]) => [ReturnType]` | [What it does] |
| `[fnName]` | `([params]) => [ReturnType]` | [What it does] |

---

### [MODULE_C]

**Responsibility**: [What this module is solely responsible for.]

**Inputs**:
- `[input]` — [type and description]

**Outputs**:
- `[output]` — [type and description]

**Key Functions**:

| Function | Signature | Description |
|----------|-----------|-------------|
| `[fnName]` | `([params]) => [ReturnType]` | [What it does] |
| `[fnName]` | `([params]) => [ReturnType]` | [What it does] |

---

## Message Flow

[Describe the sequence of events for the primary use case of this system.]

```
Actor / Source          Action                         Result
────────────────────────────────────────────────────────────────
[USER or SYSTEM]   →   [Initiating event]         →   [Effect]
[MODULE_A]         →   [Processing step]          →   [Effect]
[MODULE_B]         →   [Processing step]          →   [Effect]
[STATE_LAYER]      →   [State update]             →   [UI re-render]
[PERSISTENCE]      →   [Save operation]           →   [Data persisted]
```

---

## State Management

### State Diagram

[Describe the states the system can be in and the transitions between them.]

```
[INITIAL_STATE]
    │
    ▼ [trigger]
[STATE_A]
    │                    │
    ▼ [trigger]          ▼ [trigger]
[STATE_B]           [STATE_C]
    │
    ▼ [trigger]
[FINAL_STATE]
```

### State Storage

| State Field | Type | Persisted | Owner Module |
|-------------|------|-----------|-------------|
| `[field]` | `[type]` | Yes / No | [MODULE] |
| `[field]` | `[type]` | Yes / No | [MODULE] |
| `[field]` | `[type]` | Yes / No | [MODULE] |

---

## Integration Points

| External System | Relationship | Data Exchanged | Direction |
|----------------|-------------|---------------|----------|
| [UI Layer] | Consumers system output | [data type] | System → UI |
| [Other System] | [Description] | [data type] | Bidirectional |
| [PERSISTENCE_LAYER] | Reads/writes save data | [data type] | Bidirectional |

---

## Performance Budget

| Metric | Target | Notes |
|--------|--------|-------|
| End-to-end latency | [< X ms] | [Context] |
| [MODULE_A] compute time | [< X ms] | [Context] |
| Memory footprint | [< X KB/MB] | [Context] |
| [Other metric] | [Target] | [Context] |

---

## Testing Strategy

### Integration Tests

| # | Test Scenario | Modules Involved | Expected Outcome |
|---|--------------|-----------------|-----------------|
| 1 | [Scenario] | [MODULE_A], [MODULE_B] | [Outcome] |
| 2 | [Scenario] | [MODULE_B], [MODULE_C] | [Outcome] |
| 3 | Edge: [Scenario] | [All] | [Outcome] |

### Manual Testing Checklist

- [ ] [End-to-end scenario covering happy path]
- [ ] [Edge case scenario]
- [ ] [Error / failure scenario]
- [ ] [Performance scenario — verify budget is met]
- [ ] [Persistence scenario — data survives app restart]

---

## Acceptance Checklist

- [ ] All modules implemented per their specifications
- [ ] Data flow matches the described sequence end-to-end
- [ ] All integration test cases pass
- [ ] All manual testing checklist items verified
- [ ] Performance budget met for all metrics
- [ ] State persists correctly across sessions
- [ ] No regressions in adjacent systems
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
