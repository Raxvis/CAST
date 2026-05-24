<!-- TEMPLATE INSTRUCTIONS
  FILE: docs/FRONTEND.md
  PURPOSE: Topic-specific reference for projects that render a user-facing interface —
  web apps, mobile apps, desktop GUIs, or game UIs. Loaded into Claude Code's context
  via an @import in the project's root CLAUDE.md. Establishes the frontend conventions
  that human and AI contributors must follow.

  WHO NEEDS THIS FILE:
  - Keep this file if your project has ANY user-facing visual interface (React, Vue,
    Svelte, SolidJS, React Native, Expo, SwiftUI, Jetpack Compose, Flutter, a game UI
    layer, an Electron/Tauri desktop shell, etc.).
  - Delete this file if your project is a headless backend, library, CLI, or data
    pipeline with no rendered UI. Also remove the @import line from root CLAUDE.md.

  HOW TO CUSTOMIZE:
  - Replace every [PLACEHOLDER] token with project-specific values.
  - Swap illustrative code blocks for real idioms from your framework — but keep the
    bracketed example identifiers so it is clear the code is a pattern, not literal.
  - Delete sections that do not apply (e.g., platform differences on a web-only app).
  - Update the footer date whenever this file changes.
  - Delete this comment block before committing.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Frontend Patterns

## Scope

This document applies to any user-facing visual interface in [PROJECT_NAME]: web pages,
mobile screens, desktop GUI windows, or in-game UI layers. It is the single source of
truth for how screens, components, navigation, and user input are structured. Universal
conventions (naming, module layout, error handling) live in `docs/CODE_PATTERNS.md` —
this file only covers patterns that are specific to rendering a UI and handling user
interaction. Pure-backend, CLI, and library-only projects should delete this file and
remove the matching `@import` from the root `CLAUDE.md`.

> **Note:** Bracketed names in code examples below (e.g., `[MyComponent]`, `[useStore]`)
> are illustrative example identifiers, not project placeholders. They show naming
> patterns you should follow using your own project-specific names.

---

## Navigation and Routing

Navigation is managed through **[NAVIGATION_LIBRARY]**. Routes are declared in one place
and referenced by name, never by string literal scattered across the codebase.

- Define route names as constants in `[ROUTES_FILE]`. Screens import the constant; they
  never hard-code route paths.
- Route parameters must be typed. A screen reading `params.[id]` should fail type-check
  if the caller forgot to pass it.
- Deep links resolve through the same route table. Do not build a second routing layer
  for external URLs.
- Back-navigation is the platform default. Override it only when leaving a screen would
  lose unsaved state, and always pair the override with a confirmation prompt.
- Screens are lazy-loaded when the framework supports it. Route-level code splitting is
  the cheapest performance win available.

```
// [ROUTES_FILE]
export const [ROUTES] = {
  [HOME]: '[/home]',
  [DETAIL]: '[/detail/:id]',
} as const

// Typed params
export interface [DetailParams] {
  [id]: string
}

// Usage from a screen
const [params] = use[RouteParams]<[DetailParams]>()
[navigate]([ROUTES].[DETAIL], { [id]: [params].[id] })
```

---

## State Management

Shared UI state lives in **[STATE_LIBRARY]**. Components read state through selectors
and dispatch actions — they never subscribe to the whole store.

- One selector per value read. A component that needs three fields calls three selectors,
  not one selector returning an object.
- Selectors must be stable: no inline object or array literals. Inline shapes force
  re-renders on every parent render even when underlying data is unchanged.
- Side effects (network, storage, timers) live in actions or dedicated effect modules —
  never inside render. Components are for rendering and dispatch only.
- Derived values are computed in the render body or a memoized selector. Never store
  derived state in the store itself; it drifts from its source.
- Local state (form drafts, hover flags, transient toggles) stays local. Do not lift it
  into the global store unless two siblings actually need it.

```
// Good — fine-grained selectors
const [userName] = use[Store]((s) => s.[user].[name])
const [unreadCount] = use[Store]((s) => s.[inbox].[unreadCount])
const [markAllRead] = use[Store]((s) => s.[markAllRead])

// Bad — whole-store subscription, re-renders on every state change
const [everything] = use[Store]((s) => s)
```

---

## UI Component Patterns

Components are small, typed, and dumb. They receive data via props, emit events via
callbacks, and delegate all non-presentational logic to pure modules in `[LOGIC_DIR]`.

- Every component has an explicit `Props` interface. No implicit or inferred-only shapes.
- Children are typed as the framework's "renderable" type, not `any`.
- A component file contains one component plus its immediate helpers. Multi-component
  files are split as soon as the second component needs its own state.
- Presentational components never import from the store. Container components read from
  the store and pass primitives down.
- Style objects are declared once at module scope, not rebuilt per render.

```
interface [MyComponent]Props {
  [label]: string
  [count]: number
  [onPress]: () => void
  [children]?: [Renderable]
}

export function [MyComponent]({ [label], [count], [onPress], [children] }: [MyComponent]Props) {
  const [displayLabel] = [formatLabel]([label], [count])   // pure helper from [LOGIC_DIR]
  return (
    <[Container] style={[styles].[root]} onPress={[onPress]}>
      <[Text]>{[displayLabel]}</[Text]>
      {[children]}
    </[Container]>
  )
}

const [styles] = [StyleAPI].create({
  [root]: { [padding]: [SPACING_UNIT] },
})
```

---

## Performance

The frontend must meet the performance budget defined in `docs/PRD.md`:
`[STARTUP_METRIC]` for cold start, `[TICK_METRIC]` per update tick, `[RENDER_METRIC]`
per frame, and `[MEMORY_METRIC]` steady-state memory.

- **Virtualize long lists.** Any list that can exceed ~50 items renders through a
  virtualized list primitive. Plain map-over-array is fine for small, fixed collections.
- **Memoize carefully.** Memoize pure components whose props change rarely and whose
  render is expensive. Memoizing trivial components wastes more cycles than it saves.
- **Stable keys.** List items use a stable ID as their key, never the array index, never
  a value computed during render.
- **Images are sized.** Every image has an explicit width and height to avoid layout
  shift. Remote images go through a caching/resizing helper, not the raw URL.
- **No inline style objects.** `style={{ [color]: [red] }}` creates a new object every
  render and defeats memoization. Move it to a module-scope style map or a constant.
- **Avoid over-rendering.** Profile before optimizing. If a component re-renders without
  a prop change, the cause is almost always a non-stable selector or an inline callback.

---

## Input Handling

- **Touch targets**: any pressable region must be at least `[MIN_TOUCH_TARGET]` on its
  shortest side. Small icons get an invisible hit-slop, not a smaller tappable area.
- **Press feedback**: every pressable surface shows a state change within one frame of
  touch-down — opacity, color, ripple, or scale. Silence feels broken.
- **Focus management**: after a modal or sheet opens, focus moves into it. After it
  closes, focus returns to the element that opened it. Lost focus is a bug, not a detail.
- **Keyboard**: all interactive elements are reachable via tab order on platforms that
  expose a keyboard. Custom controls declare their role and state.
- **Accessibility labels**: every interactive element without visible text has an
  accessibility label. Icon buttons, image buttons, and custom gestures all qualify.
- **Safe areas**: screens respect platform safe-area insets (notches, home indicators,
  system bars). Read them from the framework's safe-area helper, never hard-code.

---

## Platform Differences

Values that differ per platform are isolated to the narrowest possible scope. Prefer a
per-value platform switch inside a style object over a per-component branch.

```
const [HEADER_HEIGHT] = [Platform].select({
  [IOS]: [44],
  [ANDROID]: [56],
  [WEB]: [64],
  default: [56],
})
```

- Every platform switch has a `default` branch — an unhandled platform is a bug, not a
  crash.
- Platform-specific files (`[name].[ios].[ext]`, `[name].[android].[ext]`,
  `[name].[web].[ext]`) are acceptable for whole-module divergence but must share an
  identical exported API.
- Document *why* a platform divergence exists with an inline comment. "Because it looks
  wrong on Android" is a reason; "// FIXME" is not.
- Test each platform branch on the actual target. The default branch is not a substitute
  for verification.

---

## Frontend-Specific Common Pitfalls

- **Whole-store subscriptions.** Reading the entire store object re-renders the component
  on every state change anywhere in the app. Always use a narrow selector.
- **Missing effect cleanup.** An effect that subscribes, opens a socket, sets an interval,
  or adds a listener must return a cleanup function. Leaked subscriptions produce ghost
  updates on unmounted components.
- **Inline style objects.** `style={{ ... }}` defeats memoization and causes every
  child to re-render when the parent re-renders. Promote styles to module scope.
- **Inline callbacks in memoized children.** A fresh `() => ...` every render gives a
  memoized child a new prop and re-renders it anyway. Use a stable callback helper.
- **Hard-coded dimensions.** Pixel values that look right on one device break on smaller
  screens, tablets, and foldables. Compose from spacing and sizing constants.
- **Missing accessibility labels.** Icon-only buttons without a label fail WCAG and are
  invisible to screen readers. Every interactive element needs a name.
- **Derived state stored separately.** Copying a prop into local state and then reading
  from the copy produces stale reads the moment the prop changes. Compute it instead.
- **Navigation state in the render path.** Calling `[navigate](...)` inside render causes
  infinite loops. Navigation belongs in event handlers and effects.

---

## Cross-References

- `docs/CODE_PATTERNS.md` — universal coding conventions (naming, module layout, function
  ordering, state management rules). This file extends those patterns with UI specifics.
- `docs/FILE_CONVENTIONS.md` — where components, screens, hooks, and styles live in the
  repository.
- `templates/UI_SPEC.md` — the template for documenting a single screen or component.
- `artifacts/ui-specs/` — the active UI spec instances produced per milestone by the UI
  agent. Always check here before implementing a screen.

---

_Last updated: [YYYY-MM-DD]_
