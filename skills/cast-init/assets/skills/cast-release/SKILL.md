---
name: cast-release
description: >-
  Prepare a release after a milestone closes: verify the quality gates, assign a semantic
  version, update docs/CHANGELOG.md, and run the build verification. Use when the user asks
  to cut a release, prepare release notes, or invokes /cast-release. Runs in-session and
  launches no agents.
---

<!-- TEMPLATE INSTRUCTIONS
PURPOSE: This file defines the /cast-release skill — release preparation.

In CAST v2 this was an agent (agents/release.md). It became a skill in v3 because it does no
independent reasoning a separate cold context buys anything for: it is checklist execution
against files the session can already read, and its output is a changelog entry plus a
go/no-go. An agent spawn to run a checklist is a spawn spent on ceremony. The gates it
enforces are unchanged.

HOW TO CUSTOMIZE:
1. Replace [PROJECT_NAME] with your project name.
2. Replace [TEST_CMD] and [BUILD_CMD] with your project's commands.
3. Replace [VERSIONING_SCHEME] if you do not use semantic versioning.

INSTALLATION: installs to `.claude/skills/cast-release/SKILL.md` (done automatically by
/cast-init). Invoke it with `/cast-release` after a milestone closes.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# /cast-release — Release Preparation

Prepare a release for [PROJECT_NAME]. This skill runs **in the current session and launches no agents** — every check reads a file or runs a command.

## Input

An optional version number or release name. If none was given, derive the version from the change set (below) and confirm it with the user before writing anything.

## Pre-flight

Stop and report if any of these fails; do not continue past a failed gate.

1. **A milestone is actually complete.** The highest-numbered `artifacts/milestone-*/` directory has `reviews/close.md` (or a pre-v3 `reviews/completion.md`) with Status `Complete` or `Complete with Deferrals`. If not, tell the user which milestone is still open and stop.
2. **Tests pass.** Run `[TEST_CMD]`. Record the verbatim tail of the output — it goes in the release record.
3. **Build succeeds.** Run `[BUILD_CMD]`. Record the result.
4. **No blocking bugs.** Read `artifacts/BUGS.md`. **Deferred counts as open** — a Deferred Critical or High bug blocks the release until Product re-triages it. List any that do, and stop.
5. **Risk flags cleared.** If the milestone's `reviews/risk.md` set either implementation-review flag to Yes, confirm the corresponding `reviews/risk-impl.md` exists and carries no unresolved Critical or High finding.

## Versioning

`[VERSIONING_SCHEME]` (default: semantic versioning). Derive the bump from what actually shipped, read from the milestone's close record and the commit range:

| Bump | When |
|---|---|
| **major** | A breaking change to a public interface, a data-schema migration users must run, or a removed feature |
| **minor** | New user-facing capability, backward compatible |
| **patch** | Fixes and internal changes only, no new capability |

State the bump and the reason before applying it. When the change set spans categories, the highest one wins.

## Changelog

Update `docs/CHANGELOG.md` — **this skill is its owner**; Docs Writer routes changelog-worthy items here rather than editing the file. Add one entry for the new version, newest first, describing every substantive change since the prior version, grouped Added / Changed / Fixed / Removed. Source the entries from:

- the milestone's `reviews/close.md` (what shipped),
- the `artifacts/BUGS.md` rows closed during the milestone (what was fixed),
- the commit range since the last release tag.

Known Issues from the close record — including anything still Deferred — go in the entry. A release that ships with known deferrals says so.

## Release record

Write the result to `artifacts/releases/release-{VERSION}.md`:

```
# Release [VERSION] — [DATE]

**Milestone**: [MILESTONE_NAME]
**Verdict**: GO / NO-GO

## Gates

| Gate | Result |
|---|---|
| Milestone complete | [close record path + Status] |
| Tests | [verbatim tail of [TEST_CMD]] |
| Build | [result of [BUILD_CMD]] |
| Blocking bugs | [None / list] |
| Risk implementation reviews | [N/A / clean / findings] |

## Changes

[The CHANGELOG entry for this version.]

## Known Issues

[Deferred items shipping with this release, or "None".]
```

## Output

Report to the user: the version and why, the gate results, the changelog entry, and a **GO** or **NO-GO** recommendation with the specific reason.

**Do not tag, push, or publish anything.** This skill prepares a release; shipping it is the user's call and the user's command.

## Scope boundaries

This skill does not write production code, change acceptance criteria, or close bugs — a bug reaches `Closed` through Product, not through a release. If a gate fails, report it and stop; do not fix it here.
