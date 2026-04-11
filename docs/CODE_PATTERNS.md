<!-- TEMPLATE INSTRUCTIONS
  FILE: CODE_PATTERNS.md
  PURPOSE: Establishes the coding conventions and structural patterns that all contributors
  (human and AI agent) must follow when writing code for this project. This document is
  the single source of truth for "how we write code here". It exists so that code written
  by different contributors remains consistent and reviewable.

  HOW TO CUSTOMIZE:
  - Replace all [PLACEHOLDER] tokens with real project terms.
  - Replace the code block examples with real, representative code from your project's
    language and framework.
  - Remove any section that is not applicable. For example, if your project is a CLI with
    no UI components, remove the "Component Lifecycle Pattern" section.
  - Add project-specific patterns that are unique to your architecture.
  - Keep this document updated when patterns change. Stale conventions are worse than none.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Coding Conventions

All code in [PROJECT_NAME] must conform to the patterns described in this document.
When in doubt, follow these conventions rather than inventing a new approach. If you
believe a convention needs to change, raise it in `DESIGN_RATIONALE.md` before changing it.

---

## File and Module Structure

### Pure Logic Modules

Modules containing business logic must have no UI or framework dependencies. They export
pure functions and data types only.

```[LANGUAGE]
// [EXAMPLE_MODULE_NAME].ts
// Pure logic module — no framework imports

export interface [DataType] {
  [field1]: [type];
  [field2]: [type];
}

const [MODULE_CONSTANT] = [VALUE] as const;

// Private helper — not exported
function [helperFunction]([param]: [type]): [ReturnType] {
  // ...
}

// Public API — exported
export function [publicFunction](
  [param1]: [type1],
  [param2]: [type2]
): [ReturnType] {
  // ...
}
```

### [FRAMEWORK] Component Modules

UI components import from the framework and from project constants. They do not import
from the state store directly; they receive data as props.

```[LANGUAGE]
import { [UIElement], [StyleAPI] } from '[FRAMEWORK]';
import { [COLOR_CONSTANT], [SPACING_CONSTANT] } from '../constants/[THEME_FILE]';

interface [ComponentName]Props {
  [propName]: [propType];
  [callbackProp]: () => void;
}

export function [ComponentName]({ [propName], [callbackProp] }: [ComponentName]Props) {
  return (
    <[UIElement] style={styles.[containerStyle]} onPress={[callbackProp]}>
      {/* content */}
    </[UIElement]>
  );
}

const styles = [StyleAPI].create({
  [containerStyle]: {
    [property]: [CONSTANT],
  },
});
```

---

## Naming Conventions

| Construct | Convention | Example |
|-----------|-----------|---------|
| Variables and functions | [camelCase / snake_case / other] | `[example]` |
| Types and interfaces | [PascalCase / other] | `[Example]` |
| Constants (module-level) | [UPPER_SNAKE_CASE / other] | `[EXAMPLE_CONSTANT]` |
| Source files | [kebab-case / PascalCase / other] | `[example-file].[ext]` |
| Component files | [PascalCase / kebab-case / other] | `[ExampleComponent].[ext]` |
| Test files | [mirror source + .test / .spec suffix] | `[example-file].test.[ext]` |
| Enums | [PascalCase] members | `[ExampleEnum].[MEMBER]` |

**Rules:**

- Use `interface` for object shapes with named fields; use `type` for unions and aliases.
- No `[ANY_TYPE]` — use proper types or `[UNKNOWN_TYPE]`.
- Exported functions must have explicit return types.
- Private helpers (not exported) do not require explicit return types but may have them.

---

## Function Ordering Convention

Within a module, functions must appear in the following order:

1. Type and interface definitions
2. Module-level constants
3. Private helper functions (bottom-up dependency order: called functions before callers)
4. Exported public functions
5. Default export (if applicable)

Within a component file:

1. Type/interface definitions
2. The component function
3. Helper hooks or callbacks used only by this component
4. `styles` constant at the bottom

---

## Component Lifecycle Pattern

Components follow a consistent structure for managing side effects:

```[LANGUAGE]
export function [ComponentName]() {
  // 1. Read from state store (fine-grained selectors)
  const [stateValue] = use[StateStore]((s) => s.[stateField]);

  // 2. Local state (only what cannot live in the store)
  const [[localValue], set[LocalValue]] = use[LocalStateHook]([initialValue]);

  // 3. Effects — always with cleanup
  use[EffectHook](() => {
    const [handle] = [setupSideEffect]();
    return () => {
      [cleanupSideEffect]([handle]);
    };
  }, [[dependency]]);

  // 4. Derived values (computed from state and props, not stored separately)
  const [derivedValue] = [computeFromState]([stateValue]);

  // 5. Handlers
  function handle[Event]() {
    // ...
  }

  // 6. Render
  return (
    // ...
  );
}
```

**Rules:**

- Never store derived values in state if they can be computed from existing state.
- Always return a cleanup function from effects that set up subscriptions or timers.
- Do not call state store actions inside render; only inside event handlers and effects.

---

## State Management Pattern

All shared application state lives in [STATE_LIBRARY]. Components read state via
selector functions and call actions to mutate it.

```[LANGUAGE]
// Reading state — fine-grained selector
const [value] = use[StoreName]((s) => s.[field]);

// Calling an action
const [actionName] = use[StoreName]((s) => s.[actionName]);
[actionName]([argument]);
```

**Rules:**

- Never subscribe to the entire store object — always use a selector.
- Never mutate state directly from a component. All mutations go through store actions.
- Selectors must be stable across renders; avoid creating objects or arrays inline in
  a selector as this causes unnecessary re-renders.
- Store actions must be pure with respect to their inputs: given the same state and
  arguments, they must always produce the same next state.

---

## Main Loop Pattern

The application's main update loop runs on a fixed interval. All time-based state
updates must go through this loop.

```[LANGUAGE]
// src/hooks/[USE_LOOP_HOOK].[ext]
use[EffectHook](() => {
  if (!isLoaded) return;

  const [intervalHandle] = set[Interval](() => {
    [applyTick]();   // Advance game/simulation state by one tick
    [autoSave]();    // Persist state periodically
  }, [TICK_INTERVAL_MS]);

  return () => clear[Interval]([intervalHandle]);
}, [isLoaded]);
```

**Rules:**

- The tick interval is [TICK_INTERVAL_MS]ms. Do not change it without updating all
  calculations that depend on it.
- Do not perform I/O or async work inside the tick callback; schedule it separately.
- The tick function must be synchronous and complete in well under [TICK_INTERVAL_MS]ms.
- Use wall-clock timestamps (real time in seconds since epoch) for save data and offline
  progress. Never use tick count as a proxy for real-world time.

---

## Platform-Specific Code

When a behavior must differ across platforms, use the platform detection API provided
by [FRAMEWORK]:

```[LANGUAGE]
const [platformSpecificValue] = [Platform].select({
  [PLATFORM_A]: [VALUE_A],
  [PLATFORM_B]: [VALUE_B],
  default: [DEFAULT_VALUE],
});
```

**Rules:**

- Isolate platform-specific logic to the smallest possible scope. Prefer platform-specific
  values in style objects over platform-specific component branches.
- Platform guards must have a `default` case.
- Document why a platform-specific code path is necessary with a comment.
- Test platform-specific paths on the actual target platform, not just the default.

---

## Architecture Document Templates

When documenting a new module, system, data schema, UI screen, or milestone task
breakdown, use the corresponding template from `docs/`:

| What you are documenting | Template to copy |
|--------------------------|-----------------|
| A single code module | `ARCH_MODULE.md` |
| A high-level system | `ARCH_SYSTEM.md` |
| A data/save schema | `ARCH_DATA_SCHEMA.md` |
| A UI screen or component | `UI_SPEC.md` |
| A milestone's task list | `MILESTONE_TASKS.md` |

Copy the template to the correct location per `FILE_CONVENTIONS.md` before filling it in.
Do not create architecture or specification documents from scratch.

---

_Last updated: [YYYY-MM-DD]_
