<!-- TEMPLATE INSTRUCTIONS
  FILE: docs/MOBILE.md
  PURPOSE: Topic-specific reference for native and cross-platform mobile apps —
  iOS, Android, React Native, Expo, Flutter, SwiftUI, Jetpack Compose. Covers
  the mobile-specific delta on top of the universal UI patterns in docs/FRONTEND.md.
  Loaded into Claude Code's context via an @docs/... memory import in the project's root CLAUDE.md.

  WHO NEEDS THIS FILE:
  - Keep this file if your project ships a native or cross-platform mobile app on
    iOS, Android, or both. This includes React Native, Expo, Flutter, SwiftUI,
    Jetpack Compose, .NET MAUI, and native Swift or Kotlin projects.
  - Keep docs/FRONTEND.md in addition to this file — FRONTEND covers the UI patterns
    shared across every rendered surface (screens, components, navigation,
    performance), and MOBILE covers only the mobile-specific concerns on top.
  - Delete this file if your project is web-only, desktop-only, a headless backend,
    a library, a CLI, or a data pipeline with no mobile target. Also remove the
    @docs/MOBILE.md import line from root CLAUDE.md.

  HOW TO CUSTOMIZE:
  - Replace every [PLACEHOLDER] token with project-specific values.
  - Swap illustrative code blocks for real idioms from your framework — but keep
    the bracketed example identifiers so it is clear the code is a pattern,
    not literal.
  - Delete sections that do not apply (e.g., push notifications on an app that
    does not push).
  - Update the footer date whenever this file changes.
  - This comment block is stripped automatically by /cast-init at install.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Mobile Patterns

## Scope

This document covers the patterns specific to running [PROJECT_NAME] as a native or cross-platform mobile app on **[MOBILE_FRAMEWORK]**, targeting **iOS [MIN_IOS_VERSION]+** and **Android [MIN_ANDROID_VERSION]+**. It is the mobile-specific delta on top of `docs/FRONTEND.md`, which covers the UI patterns shared across every rendered surface (navigation, component structure, state management, virtualized lists, accessibility, input handling).

If you are working on a screen layout, a selector, a touch target, or anything else that also applies to a web or desktop build, start in `docs/FRONTEND.md`. Come back here for the concerns that only exist on mobile: the app lifecycle, the permission system, the storage sandbox, push notifications, deep links, device variety, and the release pipeline.

> **Note:** Bracketed names in code examples below (e.g., `[useAppState]`, `[requestCameraPermission]`) are illustrative example identifiers, not project placeholders. They show patterns you should follow using your own project-specific names.

---

## App Lifecycle

Mobile apps do not run continuously. The OS suspends, resumes, backgrounds, foregrounds, and kills the process on its own schedule, and every screen must survive all of these transitions without data loss.

- Treat **every backgrounding** as a possible process kill. The OS can reclaim memory at any time — a user returning after ten minutes may land on a fresh process.
- Persist in-progress work (form drafts, upload queues, playback position) to local storage on `onAppGoToBackground`. Restore on `onAppBecomeActive`. Do not rely on RAM across background transitions.
- Use the framework's app-state hook, not your own state flags. `[useAppState]()` returns the current phase (`active`, `inactive`, `background`) and fires subscribers on every transition.
- Resumes after long inactivity are **state restoration**, not ordinary navigation. The whole nav stack must rebuild from persisted route state if the process was killed.
- Do not start long-running work in a `background` transition handler — you have a few seconds at most before the OS suspends you. Queue the work to resume on the next `active` transition.

```
[useAppState]((next) => {
  if (next === 'background') {
    [saveDraftsNow]()          // must complete within the short suspension window
  }
  if (next === 'active') {
    [reconcileWithServer]()    // cheap network refresh on resume
  }
})
```

---

## Permissions

Every sensitive capability on mobile — camera, microphone, photo library, location, contacts, notifications, tracking — is gated by an OS permission prompt. The prompt happens once per install per permission, and a denial is sticky: you cannot re-prompt programmatically.

- **Ask lazily.** Request a permission at the moment the user takes an action that requires it (tapping a camera button), not at app launch. Lazy prompts have multiples higher grant rates than launch prompts.
- **Explain before asking.** Show a one-sentence in-app rationale for the permission before calling the OS API. "We need location access to show restaurants near you" reduces denial rates materially.
- **Handle denial gracefully.** After a denial, the feature that required it degrades or disables — it never crashes or shows an indefinite spinner. Link to OS settings if the user wants to reconsider.
- **Re-check on foreground.** The user can grant or revoke permissions in Settings at any time. Re-read permission state on every `onAppBecomeActive`, not just at launch.
- **Never fake a permission.** Do not simulate camera output from the photo library when camera was denied. The user's refusal is the correct answer.

```
async function [openCamera]() {
  const [status] = await [checkCameraPermission]()
  if ([status] === 'granted') return [launchCamera]()
  if ([status] === 'denied-permanently') return [showSettingsDeepLink]()
  const [next] = await [requestCameraPermission]()
  if ([next] === 'granted') return [launchCamera]()
  return [disableCameraFeature]()
}
```

---

## Native Bridges and Platform APIs

When the cross-platform framework does not expose the capability you need, you cross the bridge to native code. The rules for doing this safely:

- **Try the framework first.** Every cross-platform framework has a long tail of community modules. Check there before writing a native module.
- **Wrap native calls in a platform-agnostic interface.** Consumers should import `[useBiometricAuth]()`, not `import { [TouchID] } from '[ios-module]'`. The interface has a single default implementation per platform.
- **Fail to a reasonable degraded mode.** Biometric auth on an older device without a sensor degrades to a passcode prompt; contact picker on a framework that lacks it degrades to manual entry. Never block a flow because a platform capability is missing.
- **Mirror the API surface across platforms.** `[useHaptic]('success')` behaves the same on iOS and Android. If the platforms differ meaningfully, the function names should differ too.
- **Document the bridge.** Every native module gets a README in its directory explaining the iOS class, the Android class, the JS/TS/Dart export, and the minimum OS versions required.

---

## Offline-First and Sync

Connectivity on mobile is intermittent by default, not an edge case. Subways, elevators, airplane mode, and bad hotel wifi all produce partial connectivity.

- **Writes commit locally first, sync later.** The user taps Save; the draft is persisted locally; the UI shows a success state; the upload to the server is an async background concern that can retry.
- **Optimistic updates with reconciliation.** The list gets the new item immediately on tap. When the server responds, the local item is reconciled with the server ID. If the server rejects the write, the UI rolls back with an explanation.
- **Explicit offline indicator.** Show the user when they are offline — a small banner or status dot. Surprising them with a failed save six seconds after the fact is worse than telling them up front.
- **Queue uploads in order.** Out-of-order sync corrupts state. A pending queue with serial upload, a retry policy with exponential backoff, and a poison-pill handler for permanent failures.
- **Conflict resolution is explicit.** When two devices edit the same record, the conflict policy is "last write wins", "first write wins", "merge fields", or "prompt the user". Pick one per entity and document it.

---

## Local Storage and Secrets

Mobile has three tiers of local storage with different durability, security, and size limits. Choose the right tier for the data.

| Tier | Purpose | Typical size | Backed up? | Survives reinstall? |
|---|---|---|---|---|
| **Secure storage** (Keychain / Keystore) | Auth tokens, biometric-gated secrets | small (< 1 KB per key) | varies | no |
| **Key-value store** (UserDefaults / SharedPreferences / MMKV / AsyncStorage) | User prefs, small app state | small to medium | yes | no |
| **Structured database** (SQLite / Realm / Core Data / Room) | Lists, caches, complex records | medium to large | yes | no |
| **File system** (Documents / Library / Cache) | Downloaded files, images, media | large | partial | no |

Rules:

- **Never store secrets in key-value storage or the database.** Access tokens, refresh tokens, OAuth client secrets go in secure storage only.
- **Cache files go in the Cache directory.** The OS may evict them under storage pressure. Your app handles the eviction as a cache miss, not a crash.
- **Enforce a storage budget.** The app has an explicit cap on total on-disk storage (configurable per user). Exceeding the cap triggers a cache prune, starting with the least-recently-used entries.
- **Mark large files as non-backed-up.** iOS and Android both offer flags to exclude files from device backup. Downloaded media that can be re-fetched should be excluded.
- **Schema migrations are mandatory.** Any persisted structured data ships with a migration plan. Never break existing installs by shipping a schema change without a migration.

---

## Deep Links, Universal Links, and App Links

A deep link opens a specific screen in the app from outside the app. It arrives from a tap on a URL in a browser, an email, a push notification, or another app.

- **One resolver.** All deep links route through a single handler that maps the URL to a screen in the existing navigation table. Never build a parallel routing layer for external URLs.
- **Parameter validation.** The deep link body is untrusted input. Validate every parameter before acting on it. A malformed deep link falls back to the home screen, never crashes.
- **Cold-start vs warm-start.** A cold-start deep link arrives before the navigation stack exists — the handler queues the target and replays it once the initial screen mounts. A warm-start deep link can navigate immediately.
- **Universal Links (iOS) / App Links (Android)** are the preferred form — HTTPS URLs that open the app directly and fall back to the browser if the app is not installed. Custom schemes (`[myapp]://`) are legacy; prefer HTTPS.
- **Auth-gated destinations defer.** A deep link to a logged-in screen, received while logged out, queues the target and replays it after the login flow completes. Do not drop the intent.

---

## Push Notifications and Background Work

Background execution on mobile is tightly constrained. The OS grants a small budget for periodic work and will kill a misbehaving app.

- **Push notifications are not a reliable channel.** Delivery is best-effort. A notification may arrive seconds after sending, minutes later, or never. Design for eventual consistency.
- **Notification payloads are small and opaque.** The OS delivers a title, body, and a small data blob. Do not put sensitive data in the payload — the OS may display it on the lock screen.
- **Notification categories / channels are declared up front.** On Android, every notification belongs to a channel the user can configure independently. On iOS, categories declare the interactive actions available on a notification. Declare them at app init, not at send time.
- **Handle taps explicitly.** A tap on a notification triggers a deep link (see above). The deep-link handler routes to the right screen and marks the notification as consumed.
- **Background fetch is rate-limited.** The OS decides when to run background fetch based on battery, network, and user habits. Do not assume a fixed cadence. Treat every fetch as a best-effort opportunity.
- **Silent push is not silent.** A "silent" push still wakes the app briefly. Use it for cache invalidation or data prefetch, but do not abuse it — the OS will throttle apps that consume the budget without good reason.

---

## Build Variants

Every non-trivial mobile app ships at least two build variants: **debug** (local development) and **release** (store submission). Many ship three or more: **debug**, **staging**, **release**, and sometimes **internal** for dogfooding.

- **Each variant has its own bundle ID / package name**. iOS: `[com.acme.app]`, `[com.acme.app.staging]`, `[com.acme.app.debug]`. Android: same pattern. This lets all three variants live side-by-side on a test device.
- **Each variant has its own API endpoint, analytics key, and signing config.** These live in environment files (`[.env.production]`, `[.env.staging]`) — not committed to source control, never hard-coded in source.
- **Release builds are signed and stripped.** Debug symbols, source maps, and test hooks are removed. Crash reports use uploaded symbols to reconstruct stack traces.
- **Version codes are monotonic.** The store rejects uploads with a version code lower than the previous upload. A CI job bumps the version code on every release build.
- **Feature flags gate in-progress work.** An unfinished feature ships behind a flag that is off by default in release, on in debug. Never ship an `if (__DEV__)` guard to production.

---

## Device and Screen Variety

Mobile screen sizes and shapes vary wildly: small phones, large phones, tablets, foldables with two screens, devices with notches, punch-hole cameras, dynamic islands, and rotating aspect ratios. Assume nothing about the viewport.

- **Layouts are flexible, not pixel-perfect.** Use percentage widths, flex, or constraint layouts — never a hard-coded pixel offset.
- **Safe area insets are not optional.** Every screen respects the platform safe-area helper on all four edges. A button hard-coded at `bottom: [0]` will sit behind the home indicator on iOS.
- **Tablet and landscape are real targets**, even on a phone-first app. Test on at least one tablet aspect ratio and at least one landscape orientation. Split-screen on Android and multitasking on iPad are supported where the product allows it.
- **Small phones exist.** Your layout works on the smallest supported screen, not just the reference device. A scroll container is the cheapest fix for a cramped layout.
- **Font scaling is a user preference.** The OS lets users scale text up or down. Your layout does not break when body text is at 1.5×. Test with the OS font scale at its extremes.
- **Foldables have two layouts.** On a foldable device, the app has a folded layout (phone-sized) and an unfolded layout (small-tablet-sized). The fold transition is a configuration change, not a new process.

---

## Release Engineering

Releasing a mobile app is slower and more public than releasing a web app. Plan accordingly.

- **Store review adds a delay.** Assume days, not hours, for App Store review. Plan releases on a weekly or biweekly cadence, not a continuous-deploy cadence.
- **OTA updates for non-native code.** React Native, Expo, Flutter, and others support over-the-air updates for the JavaScript/Dart bundle. Use them for bug fixes and non-structural changes. Anything that touches native code requires a full store submission.
- **Phased rollouts.** Every release goes out to a small percentage of users first (1% → 10% → 50% → 100%) with a pause between steps. A regression detected at 10% rolls back without affecting the rest of the user base.
- **Privacy manifests and data disclosure.** The App Store and Play Store require explicit disclosure of every piece of user data the app collects, the purposes, the third parties it is shared with, and whether it is linked to identity. Keep the manifest up to date — a submission that contradicts the manifest is a review rejection.
- **Minimum OS versions.** Bumping the minimum iOS or Android version is a compatibility break. Announce it before the release, not during the release.
- **Crash reporting is live from day one.** `[CRASH_REPORTER]` (e.g., Sentry, Crashlytics) is wired into every release build before the first submission. A crash that is not reported is a crash you cannot fix.

---

## Performance on Device

Mobile performance budgets are tighter than web. You are optimizing for a mid-range phone with a slow chip, not a developer's laptop.

- **Target 60 fps on the reference low-end device**, not the newest flagship. Frames dropped in animations and scroll feel much worse on a phone than on a desktop.
- **Cold-start budget**: the app launches from a killed state to an interactive first screen in under `[STARTUP_METRIC]`. Optimize the critical launch path ruthlessly; defer non-essential work to a post-launch tick.
- **Memory budget**: steady-state memory stays under `[MEMORY_METRIC]`. A mobile OS kills background apps under memory pressure; larger apps get killed sooner.
- **Avoid large synchronous work on the main thread**. JSON parsing, image decoding, encryption, and database queries are all candidates for a background queue or worker thread.
- **Image decode is surprisingly expensive**. Use a caching image library with resize-on-decode; never decode a 4000×3000 JPEG into a 100×100 avatar at display time.
- **Startup traces are cheap to collect and invaluable**. Every release has a cold-start trace captured in CI. Regressions show up as a step change in the trace, not a gradual drift.

---

## Mobile-Specific Common Pitfalls

- **Trusting the process to stay alive.** A state flag in RAM is lost the moment the OS backgrounds the app. Anything you care about survives a process kill via persistent storage.
- **Launch-time permission prompts.** Asking for camera, notifications, and location all at launch is a denial cascade. Ask lazily, one at a time, at the point of use.
- **Hard-coding screen dimensions.** A layout built for a 6.1-inch iPhone breaks on a 5.4-inch SE, a foldable, and a landscape tablet. Flexible layouts only.
- **Forgetting the safe area.** Anything pinned to the top or bottom of the screen needs to respect the inset — notches, home indicators, and navigation bars will sit on top of your content otherwise.
- **Storing tokens in the wrong tier.** Access tokens in AsyncStorage, SharedPreferences, or UserDefaults are readable by any other app that has access to the backup file. Use secure storage.
- **Assuming online connectivity.** A flow that blocks on a network call without a timeout is a frozen flow on a subway. Every network call has a timeout and a fallback.
- **Burning battery with a wake-lock.** Holding a wake-lock during any long-running task drains the battery visibly. Wake-locks are scoped to the shortest window possible and released on failure paths.
- **Missing Android back-button handling.** On Android, the hardware back button is a core input. A screen that ignores it frustrates users and fails Play Store review. Every screen declares its back-button behavior explicitly.
- **Ignoring the fold transition on foldables.** The app receives a configuration change when the device folds or unfolds. Layout must re-measure; state must not be lost.
- **Non-deterministic push delivery.** A flow that assumes a push arrives within N seconds is broken. Push is a hint that the server has news, not a guaranteed channel.

---

## Cross-References

- `docs/FRONTEND.md` — shared UI patterns for any rendered surface (navigation, state, components, input). This file layers the mobile-specific delta on top of those patterns.
- `docs/CODE_PATTERNS.md` — universal coding conventions (naming, module layout, error handling). Applies regardless of target.
- `docs/FILE_CONVENTIONS.md` — where platform-specific files, native modules, and release configs live in the repository.
- `templates/UI_SPEC.md` — the template for documenting a single screen or component, including mobile-specific states (permission denied, offline, background).
- `artifacts/ui-specs/` — the active UI spec instances produced per milestone by the UI agent.
- `docs/TEST_FRAMEWORK.md` — testing strategy, including real-device vs simulator testing and the UI testing tool used for mobile flows.

---

_Last updated: [YYYY-MM-DD]_
