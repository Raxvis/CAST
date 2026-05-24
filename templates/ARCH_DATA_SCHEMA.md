<!-- TEMPLATE INSTRUCTIONS
  FILE: ARCH_DATA_SCHEMA.md
  PURPOSE: Architecture specification for a data schema. Use this document to formally
           define the structure, fields, validation rules, serialization format, and
           migration strategy for a significant data structure in the project.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME], [SCHEMA_NAME], [AUTHOR], [VERSION], [DATE] with actual values.
  - Replace [DOMAIN_ENTITY] with the domain object being modeled (e.g., "UserProfile", "Order").
  - Replace [FIELD_NAME], [TYPE], [REQUIRED/OPTIONAL], [DEFAULT], [DESCRIPTION] in the
    Field Definitions table with actual field details.
  - Replace [PERSISTENCE_LAYER] with your storage mechanism.
  - Update the Example Data section with realistic placeholder values.
  - The Acceptance Checklist is the contract for implementation — keep it accurate.
  - Status values: Draft / In Review / Approved / Implemented
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Architecture Spec: [SCHEMA_NAME] Data Schema

| Field | Value |
|-------|-------|
| **Version** | [VERSION] |
| **Date** | [DATE] |
| **Author** | [AUTHOR] |
| **Status** | Draft / In Review / Approved / Implemented |

---

## Overview

### Purpose

[Describe what data this schema represents, what it is used for, and why it is structured this way. 2–4 sentences.]

**Related documents:** See `ARCH_MODULE.md` for the module that owns this schema. If this data is displayed in a UI, see the related `UI_SPEC.md` document.

### Format

[Describe the serialization format — e.g., structured text, binary, key-value pairs — and why it was chosen.]

### Location

[Describe where this data is stored, accessed, and managed.]

| Storage | Location / Key | Access Pattern |
|---------|---------------|---------------|
| [PERSISTENCE_LAYER] | `[storage-key or path]` | [Read on startup / Write on change / etc.] |

---

## Schema Definition

### Structure

```
// Top-level structure
[SCHEMA_NAME] {
  version: [integer]              // Schema version for migration support
  [DOMAIN_ENTITY]: [EntityType]   // Primary data entity
  [field]: [type]                 // [description]
  [field]: [type]                 // [description]
  [timestampField]: [integer]     // Unix seconds — last save/update time
}

// Entity type definition
[EntityType] {
  [field]: [type]                 // [description]
  [field]: [type]                 // [description]
  [nestedField]: [NestedType][]   // [description]
}

// Nested type
[NestedType] {
  [field]: [type]                 // [description]
  [field]: [type]                 // [description]
}
```

### Field Definitions

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `version` | integer | Yes | [CURRENT_VERSION] | Schema version; increment on breaking changes |
| `[field]` | [type] | Yes / No | [default or "—"] | [Description] |
| `[field]` | [type] | Yes / No | [default or "—"] | [Description] |
| `[field]` | [type] | Yes / No | [default or "—"] | [Description] |
| `[timestampField]` | integer | Yes | [current time] | Unix seconds timestamp of last write |

---

## Example Data

A representative example of a populated schema instance:

```json
{
  "version": [CURRENT_VERSION],
  "[DOMAIN_ENTITY]": {
    "[field]": "[example-value]",
    "[field]": [example-number],
    "[nestedField]": [
      {
        "[field]": "[example-value]",
        "[field]": [example-number]
      }
    ]
  },
  "[field]": "[example-value]",
  "[timestampField]": 1700000000
}
```

---

## Validation Rules

Rules that must be enforced when reading or writing this schema.

| Field | Rule | Error Handling |
|-------|------|---------------|
| `version` | Must be a positive integer | Fall back to default schema |
| `[field]` | [Validation rule — e.g., must be >= 0] | [How to handle violation] |
| `[field]` | [Validation rule — e.g., must be one of: A, B, C] | [How to handle violation] |
| `[timestampField]` | Must not be in the future | Clamp to current time |

**General rules**:
- If the schema is missing or corrupt, fall back to a default (do not crash).
- If a required field is missing, use its default value.
- Unknown fields should be ignored (forward compatibility).

---

## Serialization

### Save Format

[Describe the exact serialization process — how the in-memory structure is written to the persistence layer.]

```
// Pseudo-code for save
function save(data: [SCHEMA_NAME]): void {
  const toSave = {
    ...data,
    [timestampField]: currentUnixSeconds()
  };
  [PERSISTENCE_LAYER].write([STORAGE_KEY], serialize(toSave));
}
```

### Load Format

[Describe the deserialization process — how data is read back and validated.]

```
// Pseudo-code for load
function load(): [SCHEMA_NAME] {
  try {
    const raw = [PERSISTENCE_LAYER].read([STORAGE_KEY]);
    if (!raw) return defaultSchema();
    return migrate(deserialize(raw));
  } catch {
    return defaultSchema();
  }
}
```

### Migration Strategy

Each schema version must have a corresponding migration path. Migrations are applied sequentially.

| From Version | To Version | Changes | Migration Notes |
|-------------|-----------|---------|----------------|
| — | [VERSION_1] | Initial schema | No migration needed |
| [VERSION_1] | [VERSION_2] | [Describe structural change] | [How to transform old → new] |

```
// Migration pseudo-code
function migrate(data: any): [SCHEMA_NAME] {
  if (data.version === [VERSION_1]) {
    // transform from v1 to v2
    return { ...defaultSchema(), ...data, version: [VERSION_2] };
  }
  // unknown version: fall back to default
  return defaultSchema();
}
```

---

## Usage

### How to Access

[Describe how other parts of the system read this data.]

```
// Example: reading from the state layer
const [fieldValue] = useStore((state) => state.[DOMAIN_ENTITY].[field]);

// Example: direct module access
const data = await load();
const value = data.[DOMAIN_ENTITY].[field];
```

### How to Modify

[Describe how other parts of the system write or update this data.]

```
// Example: updating via a state action
[updateAction]: ([param]: [type]) => {
  set((state) => ({
    [DOMAIN_ENTITY]: {
      ...state.[DOMAIN_ENTITY],
      [field]: [newValue]
    }
  }));
  save(get());
}
```

---

## Acceptance Checklist

- [ ] All fields defined in the Field Definitions table are implemented
- [ ] Default schema function returns a valid, complete structure
- [ ] All validation rules are enforced on load
- [ ] Save function writes all fields correctly
- [ ] Load function handles missing data gracefully (falls back to default)
- [ ] Load function handles corrupt data gracefully (falls back to default)
- [ ] Migration function handles all defined version transitions
- [ ] Example data matches the schema definition
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
