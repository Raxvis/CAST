<!-- TEMPLATE INSTRUCTIONS
  FILE: TEST_FRAMEWORK.md
  PURPOSE: Defines the testing strategy, conventions, and requirements for the project.
  This document tells contributors what to test, how to structure tests, what tools to
  use, and what level of coverage is expected for each module category. It exists so that
  tests written by different contributors are consistent, discoverable, and reliable.

  HOW TO CUSTOMIZE:
  - Replace all [PLACEHOLDER] tokens with the real test runner, commands, and paths for
    your project.
  - Update the "Coverage Requirements" table with real targets for each module type.
  - Add project-specific test suite sections under "Required Test Suites".
  - Remove or adapt patterns that do not apply to your project's language or framework.
  - If your project uses snapshot testing, integration testing, or end-to-end testing
    in addition to unit testing, add sections for those test types.
  - Keep the "Test Best Practices" section as-is unless a practice genuinely does not
    apply to your language or testing approach.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Testing Strategy

All code in [PROJECT_NAME] that can be unit tested must be unit tested. Pure logic
modules have no external dependencies and are fully testable. UI components are tested
for logic and integration where practical. This document defines the conventions that
govern all tests in the project.

---

## Overview

| Property | Value |
|----------|-------|
| Test runner | `[TEST_RUNNER]` |
| Test file extension | `[TEST_FILE_EXTENSION]` |
| Test file location | Co-located with source, or in `[TEST_DIRECTORY]` |
| Run all tests | `[TEST_CMD]` |
| Run tests in watch mode | `[TEST_WATCH_CMD]` |
| Run with coverage | `[TEST_COVERAGE_CMD]` |
| Coverage output | `[COVERAGE_OUTPUT_DIRECTORY]` |

---

## Running Tests

```bash
# Run the full test suite
[TEST_CMD]

# Run tests in watch mode (re-runs on file save)
[TEST_WATCH_CMD]

# Run a single test file
[TEST_CMD] [FILE_PATTERN]

# Run tests matching a description string
[TEST_CMD] --[FILTER_FLAG] "[TEST_DESCRIPTION_PATTERN]"

# Generate a coverage report
[TEST_COVERAGE_CMD]
```

---

## Test File Convention

### Naming

Test files must be named after the source file they test:

- Source: `[source-file].[ext]`
- Test: `[source-file].test.[ext]` or `[source-file].spec.[ext]`

### Location

Tests are [co-located with the source file they test / placed in a `[TEST_DIRECTORY]`
directory that mirrors the source structure].

```
[SOURCE_ROOT]/
  [module-name].[ext]
  [module-name].test.[ext]     ← test file lives alongside source
```

or:

```
[SOURCE_ROOT]/
  [module-name].[ext]

[TEST_ROOT]/
  [module-name].test.[ext]     ← test file mirrors source structure
```

---

## Test Structure

### Basic Structure

```[LANGUAGE]
import { [functionToTest] } from './[module-name]';

describe('[ModuleName]', () => {
  describe('[functionToTest]', () => {
    it('[does the expected thing under normal conditions]', () => {
      // Arrange
      const [input] = [setupInputValue];

      // Act
      const [result] = [functionToTest]([input]);

      // Assert
      expect([result]).[matcherMethod]([expectedValue]);
    });

    it('[handles an edge case]', () => {
      // ...
    });

    it('[handles invalid input gracefully]', () => {
      // ...
    });
  });
});
```

### Floating-Point Comparisons

Do not use exact equality for floating-point results. Use an epsilon-based comparison:

```[LANGUAGE]
// Instead of:
expect(result).toBe(1.5);

// Use:
expect(result).toBeCloseTo(1.5, [DECIMAL_PLACES]);
// or:
expect(Math.abs(result - 1.5)).toBeLessThan([EPSILON]);
```

### Edge Cases to Always Cover

For any function that processes numeric input, always include tests for:

- Zero / empty / null input
- Negative values (if the domain includes them or if they should be rejected)
- Very large values (to verify no overflow or precision loss)
- Boundary values (minimum and maximum valid inputs)

For any function that processes collections, always include tests for:

- Empty collection
- Single-element collection
- Collection at maximum expected size

---

## Coverage Requirements

The following minimum coverage targets apply by module category. Coverage is measured
per the output of `[TEST_COVERAGE_CMD]`.

| Module Category | Location | Min Statement Coverage | Min Branch Coverage | Notes |
|----------------|----------|----------------------|-------------------|-------|
| [PURE_LOGIC_CATEGORY] | `[PURE_LOGIC_PATH]` | [TARGET]% | [TARGET]% | [NOTES] |
| [STATE_STORE_CATEGORY] | `[STORE_PATH]` | [TARGET]% | [TARGET]% | [NOTES] |
| [UTILITY_CATEGORY] | `[UTILITY_PATH]` | [TARGET]% | [TARGET]% | [NOTES] |
| [HOOK_CATEGORY] | `[HOOK_PATH]` | [TARGET]% | [TARGET]% | [NOTES] |
| [COMPONENT_CATEGORY] | `[COMPONENT_PATH]` | [TARGET]% | [TARGET]% | [NOTES] |

Coverage is a floor, not a target. 100% coverage does not mean the code is correct;
it means every line was executed at least once.

---

## Test Best Practices

### One Assertion Per Concept

Each test should verify one logical behavior. If a test fails, it should be immediately
clear what behavior is broken.

```[LANGUAGE]
// Preferred: one behavior per test
it('returns zero when input is empty', () => {
  expect([functionToTest]([])).toBe(0);
});

it('returns the sum of all elements', () => {
  expect([functionToTest]([1, 2, 3])).toBe(6);
});

// Avoid: multiple unrelated assertions in one test
it('handles various inputs', () => {
  expect([functionToTest]([])).toBe(0);         // if this fails...
  expect([functionToTest]([1, 2, 3])).toBe(6); // ...this never runs
});
```

### Descriptive Test Names

Test names must describe the behavior being verified, not the implementation. A failing
test name should read as a plain-language description of the regression.

```[LANGUAGE]
// Preferred
it('returns the default state when save data is missing')
it('clamps elapsed time to the maximum offline cap')
it('does not apply negative offline progress')

// Avoid
it('works correctly')
it('handles edge case')
it('test 1')
```

### Arrange-Act-Assert

Structure every test with three clearly separated sections:

1. **Arrange:** Set up the inputs, initial state, and any mocks.
2. **Act:** Call the function or trigger the behavior under test.
3. **Assert:** Verify the output or resulting state.

Do not intermix setup and assertions within the same block.

### Test Independence

Each test must be able to run in isolation and in any order. Tests must not share
mutable state. Use `beforeEach` to reset shared state before each test, not `beforeAll`.

```[LANGUAGE]
describe('[ModuleName]', () => {
  let [sharedResource]: [Type];

  beforeEach(() => {
    [sharedResource] = [createFreshInstance](); // Reset before each test
  });

  it('[test 1]', () => { /* uses [sharedResource] */ });
  it('[test 2]', () => { /* uses [sharedResource] */ });
});
```

### Error Conditions

Every function that can throw or return an error state must have at least one test
that exercises that path.

```[LANGUAGE]
it('throws when [INVALID_CONDITION]', () => {
  expect(() => [functionToTest]([invalidInput])).toThrow('[EXPECTED_ERROR_MESSAGE]');
});

it('returns null when [MISSING_INPUT_CONDITION]', () => {
  expect([functionToTest](null)).toBeNull();
});
```

---

## Mocking

### Module Mocks

When a pure logic function depends on an external module (e.g. a clock, a persistence
layer), inject the dependency rather than importing it directly. This makes the function
testable without real I/O.

```[LANGUAGE]
// Instead of:
export function [myFunction]() {
  const now = Date.now(); // Hard to mock
}

// Prefer:
export function [myFunction](now = Date.now()) { // Injectable
  // ...
}

// In tests:
it('[does something at a specific time]', () => {
  const fakeNow = [FIXED_TIMESTAMP];
  const result = [myFunction](fakeNow);
  // ...
});
```

### Persistence Layer Mocks

Tests that involve reading or writing to the persistence layer must use a mock or
in-memory implementation. Never write to real storage in unit tests.

```[LANGUAGE]
// Mock the persistence module before importing the module under test
jest.mock('[PERSISTENCE_MODULE_PATH]', () => ({
  getItem: jest.fn().mockResolvedValue(null),
  setItem: jest.fn().mockResolvedValue(undefined),
}));
```

---

## Required Test Suites

Each of the following modules must have a corresponding test file. This list is the
minimum; additional test files are encouraged.

| Module | Test File | Priority |
|--------|-----------|---------|
| [MODULE_1] | `[MODULE_1].test.[ext]` | [High / Medium / Low] |
| [MODULE_2] | `[MODULE_2].test.[ext]` | [High / Medium / Low] |
| [MODULE_3] | `[MODULE_3].test.[ext]` | [High / Medium / Low] |
| [MODULE_4] | `[MODULE_4].test.[ext]` | [High / Medium / Low] |
| [MODULE_5] | `[MODULE_5].test.[ext]` | [High / Medium / Low] |

---

## Continuous Integration

All tests must pass before any change is merged to the main branch.

**CI pipeline steps:**

1. Install dependencies
2. Run type checking: `[TYPE_CHECK_CMD]`
3. Run tests with coverage: `[TEST_COVERAGE_CMD]`
4. Verify coverage thresholds are met
5. Build for production: `[BUILD_CMD]`

A pull request with failing tests or coverage below the defined thresholds must not be merged.

---

_Last updated: [YYYY-MM-DD]_
