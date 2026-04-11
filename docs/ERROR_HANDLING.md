<!-- TEMPLATE INSTRUCTIONS
  FILE: ERROR_HANDLING.md
  PURPOSE: Defines how the project handles errors at every layer — from silent recovery
  of corrupt data to user-facing messages for failed purchases. This document ensures
  that error handling is consistent, deliberate, and appropriate to context. Without
  explicit conventions, engineers make ad-hoc decisions that produce inconsistent user
  experiences and silent data loss.

  HOW TO CUSTOMIZE:
  - Replace all [PLACEHOLDER] tokens with real project terms.
  - Review the error categories and remove any that do not apply to your project.
  - Add project-specific error categories that are not covered here.
  - The "Development vs Production" section is critical — make sure it reflects your
    actual build configuration.
  - Update the Logging Conventions to match whatever logging infrastructure your project
    actually uses (console, remote error tracker, etc.).
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Error Handling Guidelines

All code in [PROJECT_NAME] must handle errors consistently according to the principles
and patterns defined in this document. Silent failures and unhandled exceptions are never
acceptable in production builds.

---

## General Principles

1. **Never lose user data silently.** If a save, write, or sync operation fails, the
   error must be caught, logged, and if possible surfaced to the user. Do not pretend
   success when the operation failed.

2. **Always fail to a safe default.** When data is missing, corrupt, or in an unexpected
   format, fall back to a known-good default state rather than crashing or producing
   undefined behavior. Document the fallback behavior where it occurs.

3. **Distinguish recoverable from fatal errors.** Recoverable errors (missing save file,
   expired session, network timeout) should be handled gracefully without interrupting
   the user. Fatal errors (invariant violations, critical asset failures) should be
   surfaced clearly.

4. **Do not swallow errors without logging.** An empty `catch` block is always wrong.
   At minimum, log the error with enough context to reproduce and diagnose it.

5. **Error messages are user-facing product decisions.** Do not expose raw exception
   messages, stack traces, or technical jargon to users. Write user-facing error
   messages in plain language. See the "User-Facing Messages" section.

---

## Error Categories

### Save Data Corruption

**Scenario:** The persisted save data is missing, malformed, or contains a version that
cannot be migrated.

**Handling:**
- Attempt to load save data inside a try/catch.
- If parsing fails for any reason, log the error and fall back to `[DEFAULT_SAVE_FUNCTION]()`.
- Never crash due to a missing or corrupt save file; always return a playable state.
- Log the raw data (or its length/hash) at debug level to assist diagnosis.

```[LANGUAGE]
try {
  const raw = await [persistenceLayer].getItem([SAVE_KEY]);
  if (!raw) return [defaultSave]();
  return [migrateSave](JSON.parse(raw));
} catch (error) {
  [log].error('[MODULE_NAME] save load failed', { error });
  return [defaultSave]();
}
```

---

### Invalid User Actions

**Scenario:** The user attempts an action they cannot perform (e.g. spending more
[RESOURCE_TYPE] than they have, exceeding a capacity limit).

**Handling:**
- Guard against invalid actions in store action functions, not just in the UI.
- Return early from the action without modifying state.
- Do not show an error message for common, expected cases (e.g. tapping a locked item).
- If the invalid state indicates a bug (the UI should have prevented this), log a warning.

```[LANGUAGE]
function [actionName]([args]) {
  if ([invalidCondition]) {
    // Expected: user cannot afford this. UI should prevent this tap, but guard here too.
    return;
  }
  // ... proceed with action
}
```

---

### Math and Calculation Errors

**Scenario:** A calculation produces `NaN`, `Infinity`, or a negative value where only
non-negative values are valid.

**Handling:**
- Validate outputs of all arithmetic functions when the input space is not fully controlled.
- Replace `NaN` and `Infinity` with safe defaults (typically `0` or a known minimum).
- Log a warning when a calculation result is clamped or replaced, including the inputs
  that produced the bad result.
- Never allow `NaN` or `Infinity` to propagate into the save data.

```[LANGUAGE]
function [safeCalculation]([input]: [Type]): number {
  const result = [someArithmetic]([input]);
  if (!isFinite(result) || isNaN(result)) {
    [log].warn('[MODULE_NAME] calculation produced invalid result', { input, result });
    return [SAFE_DEFAULT_VALUE];
  }
  return result;
}
```

---

### Network Errors

**Scenario:** A network request (e.g. purchase validation, cloud sync, remote config)
fails due to connectivity, timeout, or server error.

**Handling:**
- All network calls must be wrapped in try/catch.
- Retry transient failures a maximum of [MAX_RETRY_COUNT] times with [RETRY_DELAY]ms
  backoff before giving up.
- On failure, fall back to locally cached data where possible. Note what is and is not
  available offline.
- Surface persistent failures to the user with a plain-language message and a retry option.
- Do not block the main experience on network requests that are not strictly required
  to proceed.

---

### Asset Loading Failures

**Scenario:** An image, font, or other asset fails to load.

**Handling:**
- All asset loading must occur inside a try/catch or with an `onError` handler.
- For non-critical assets (decorative images), fail silently and render a
  fallback (blank space or placeholder).
- For critical assets (primary font, core UI icons), surface a user-facing error and
  prevent the application from entering an inconsistent visual state.
- Log all asset failures with the asset path and error details.

---

### Async Operation Timeouts

**Scenario:** An asynchronous operation (e.g. save, load, network call) does not resolve
within an acceptable time.

**Handling:**
- Wrap long-running async operations with a timeout using `Promise.race` or an equivalent.
- On timeout, log a warning and proceed with a fallback behavior.
- Do not leave the UI in a loading state indefinitely. Always have a maximum wait time.

```[LANGUAGE]
const [TIMEOUT_MS] = [VALUE];

const result = await Promise.race([
  [asyncOperation](),
  new Promise((_, reject) =>
    setTimeout(() => reject(new Error('[OPERATION_NAME] timed out')), [TIMEOUT_MS])
  ),
]).catch((error) => {
  [log].warn('[MODULE_NAME] operation timed out or failed', { error });
  return [fallbackValue];
});
```

---

## Development vs Production Behavior

| Behavior | Development | Production |
|----------|-------------|------------|
| Unhandled exceptions | Throw visibly; crash or show overlay | Log to error tracker; show user-facing message |
| Validation failures | `throw` with descriptive message | Log warning; fall back silently |
| `console.log` output | Visible | Stripped by build tooling |
| `console.warn` output | Visible | Forwarded to error tracker |
| `console.error` output | Visible | Forwarded to error tracker; may trigger alert |
| Raw error messages | Shown to developer | Never shown to user |

---

## Logging Conventions

Use the following log levels consistently:

| Level | When to use |
|-------|------------|
| `[log].debug` | Detailed state for active debugging. Stripped in production builds. |
| `[log].info` | Significant application events (app start, save written, milestone reached). |
| `[log].warn` | Recoverable anomalies (clock skew detected, cache miss, fallback applied). |
| `[log].error` | Failures that affect the user or indicate a bug (save failed, purchase failed). |

**Log format:** Each log entry must include the module name as a prefix and enough
context to reproduce the issue:

```[LANGUAGE]
[log].warn('[MODULE_NAME] [brief description]', { [relevant_context_key]: [value] });
```

Do not log personally identifiable information, payment details, or device identifiers.

---

## User-Facing Messages

When an error must be surfaced to the user, the message must meet these standards:

- **Plain language.** Write for a non-technical audience. Avoid terms like "exception",
  "null pointer", "timeout", or "404".
- **Actionable.** Tell the user what they can do: "Try again", "Check your connection",
  "Restart the app".
- **Accurate but vague on internals.** Acknowledge that something went wrong without
  exposing implementation details.
- **Tone-appropriate.** Match the tone of the rest of the application. Do not use
  alarming language for recoverable errors.

**Example templates:**

| Scenario | Message |
|----------|---------|
| Save failed | "Your progress could not be saved. We'll try again shortly." |
| Purchase failed | "Something went wrong with your purchase. Please try again or check your payment method." |
| Network unavailable | "You appear to be offline. Some features may be unavailable." |
| Unexpected error | "Something went wrong. Please restart the app. Your progress has been saved." |

Adapt these templates to the specific context and tone of [PROJECT_NAME].

---

_Last updated: [YYYY-MM-DD]_
