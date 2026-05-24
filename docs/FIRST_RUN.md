<!-- TEMPLATE INSTRUCTIONS
  FILE: FIRST_RUN.md
  PURPOSE: A short interactive checklist the user runs the first time they open
  Claude Code in a freshly-installed template. Verifies that Claude Code actually
  loads the subagents, the slash commands appear, and /agent-plan runs end-to-end.

  This file is reference material and stays in docs/. It does not get populated
  per-project; every project uses it the same way.
-->

# First-Run Checklist

This checklist verifies that a freshly-installed template is wired up correctly inside Claude Code. Walk through it interactively in a Claude Code session after adoption.

---

## Step 1 — Open Claude Code in the target project

Change into your target project directory and start a Claude Code session:

```
cd /path/to/your-project
claude
```

**Verify:** `CLAUDE.md` loads automatically at session start. You should see your populated project identity in the session context (the first line of your `CLAUDE.md` mentions the project name you filled in).

**If it fails:** your `CLAUDE.md` is probably at the wrong path. It must live at the project root, not inside `docs/` or anywhere else. See the CAST template's `TROUBLESHOOTING.md` → "`CLAUDE.md` context is not being loaded".

---

## Step 2 — Run `/agents` and confirm every subagent is registered

In the Claude Code session, type:

```
/agents
```

**Verify:** you see a list of subagents that matches the files in `.claude/agents/`. On a full install you should see all 15: `architect`, `bug-gatherer`, `ceo`, `coder`, `debugger`, `docs-writer`, `performance`, `product`, `refactor`, `release`, `reviewer`, `security`, `tester`, `ui`, `validator`. On a pruned install you should see whatever subset you kept.

**If an agent is missing:** the most common cause is malformed YAML frontmatter. Open the missing agent file and verify the `---` fences are balanced and the `name:`, `description:`, and `model:` keys are present on separate lines.

**If `/agents` is not recognized at all:** your Claude Code version is too old. Update it.

---

## Step 3 — Run `/agent-plan`, `/agent-code`, and `/agent-task` as "tab completion" smoke checks

Type `/agent` and check that all three commands auto-complete:

```
/agent-plan
/agent-code
/agent-task
```

**Verify:** every command you kept in `.claude/commands/` appears in the completion list. You do not need to actually run them yet — just confirm Claude Code sees them.

**If a command is missing:** restart the session. Claude Code reads `.claude/commands/` at session start; if you installed while a session was already open, the new files are not picked up until you restart.

---

## Step 4 — Dry-run `/agent-plan` on a throwaway feature description

With your session still open, run:

```
/agent-plan "Print a hello-world message when the app starts"
```

**Verify:** the Product agent kicks off. You should see it begin writing a milestone definition to `artifacts/milestones/milestone-1-*.md`.

You can interrupt the planning run as soon as Product starts writing — you are not trying to produce a real milestone, you are just confirming the command routing works. If Product writes anything at all into `artifacts/milestones/`, Steps 1–3 are confirmed and the pipeline is wired up correctly.

**If Product never writes a file:** the Product agent is not loading. Check `.claude/agents/product.md` for frontmatter issues, or re-run `/agents` to confirm Product is listed.

**If `/agent-plan` halts with a "missing template" error:** your `templates/` directory is missing `MILESTONE_TASKS.md` or another planning template that the command references. Re-copy `templates/` from the template.

---

## Step 5 — (Optional) Dry-run `/agent-task` on a trivial change

For a lighter-weight verification that the engineering pipeline is working:

```
/agent-task "Add a comment to CLAUDE.md saying this is a test run"
```

**Verify:** the Coder agent picks up the task, makes the one-line change, the Tester agent runs, the Reviewer agent approves, and the Product agent validates. You can roll the commit back afterward.

**If any agent in the chain halts:** read the halt message. It should cite the specific agent and the specific reason. Cross-reference the CAST template's `TROUBLESHOOTING.md`.

---

## Clean up the throwaway artifacts

If you ran Step 4 or Step 5, a few files are now in `artifacts/`. Delete them before your real work begins:

```
rm -f artifacts/milestones/milestone-1-*
rm -f artifacts/architecture/arch-milestone-1*
rm -f artifacts/ui-specs/ui-milestone-1*
rm -f artifacts/reviews/*-review-milestone-1*
```

Or use the completion-report template to keep a record of the first run if you want a historical marker.

---

## Appendix — Per-agent smoke probes (optional)

If Step 4 or Step 5 completes cleanly, the pipeline is working end-to-end and you can usually stop. The probes below are an optional next step for verifying that each individual agent does what its file says it does — useful after you customize an agent file, or if you want a finer-grained trust signal before running a real milestone.

Each probe is a single prompt to launch the named agent explicitly. Each takes under a minute. Run only the ones you care about; you do not need all 15.

### Planning-tier probes

| Agent | Probe | Expected |
|---|---|---|
| `product` | "Use the product agent to write acceptance criteria for 'add a dark mode toggle'." | Testable, specific criteria (not vague statements like "works well"). |
| `architect` | "Use the architect agent to sketch module boundaries for a new authentication system." | A module table plus a Decisions Log entry that cites alternatives considered. |
| `ui` | "Use the ui agent to spec the interaction states for a login form." | Covers default, focused, error, loading, and disabled states explicitly. |
| `security` | "Use the security agent to review a function that concatenates user input into a SQL string." | A Critical finding with an OWASP citation and a concrete remediation. |
| `performance` | "Use the performance agent to review a function that iterates 100k items inside a render loop." | A finding that cites a specific performance budget, not a generic "this is slow". |
| `ceo` | "Use the ceo agent to review a milestone plan where Security has an unaddressed Critical finding." | Verdict is REVISION REQUIRED, not APPROVED WITH CONDITIONS — the CEO does not paper over Critical findings. |

### Engineering-tier probes

| Agent | Probe | Expected |
|---|---|---|
| `coder` | "Use the coder agent to implement a function that returns the sum of two numbers." | Working code plus a completed Pre-Handoff Checklist. |
| `tester` | "Use the tester agent to write tests for a function that divides two numbers." | Tests cover both the happy path and at least one edge case (zero divisor or empty input). |
| `reviewer` | "Use the reviewer agent to review a file with both a logic bug and a style violation." | Classifies the logic bug as a Defect (route to Debugger) and the style issue as an Issue (route to Refactor). |
| `debugger` | "Use the debugger agent to investigate a failing test where the root cause is an off-by-one error." | At least two alternative fix approaches with trade-offs, plus a recommended fix and an Assigned To. |
| `refactor` | "Use the refactor agent to clean up a file with three copies of the same 10-line function." | Extracts a shared helper and cites the quality principle justifying the change (DRY, single-responsibility, etc.). |

### Utility-tier probes

| Agent | Probe | Expected |
|---|---|---|
| `bug-gatherer` | "File a raw bug: 'the login button doesn't work' and ask bug-gatherer to structure it." | Asks for the missing required fields (steps to reproduce, expected/actual, platform). Does not accept the raw report as-is. |
| `docs-writer` | "Use the docs-writer agent to document a newly-added helper function." | Updates an existing doc under `docs/` rather than creating a new file. Does not write to `artifacts/`. |
| `release` | "Use the release agent to prepare a changelog entry for a bug fix." | Entry follows the format in `docs/CHANGELOG.md` and cites the fixed bug by ID. |
| `validator` | "Use the validator agent to review the current process state." | Checks the Agent Status Dashboard, flags any stale or blocked tasks, and does NOT modify code. |

### Interpreting results

- **Probe passes with a reasonable output:** the agent file is loaded and the model is responding consistently with the role definition.
- **Probe returns generic output that could come from any agent:** the role definition is not being loaded. Check that `.claude/agents/<name>.md` has valid frontmatter (see Step 2).
- **Probe returns a "model not available" error:** your account does not have access to the pinned model. Override the `model:` line in the agent's frontmatter to a model you have access to.
- **Probe returns output that contradicts the agent's role definition:** the model is not reading the agent body carefully enough. Try a more capable model tier, or tighten the agent's Interaction Rules section to be more prescriptive.

---

## What this checklist does NOT cover

- **Per-agent model access.** If your Anthropic account does not have access to `claude-opus-4-6`, the planning agents will fail when invoked. The static smoke test cannot detect this — you find out when `/agent-plan` halts. Fix: override the `model:` line in each planning agent file to a model you have access to (e.g., `claude-sonnet-4-6`).
- **Project-specific conventions.** This checklist verifies the template is wired up; it does not verify that your `CLAUDE.md`, `PRD.md`, or code conventions are accurate for your project. That is the user's responsibility.
- **Full end-to-end run of a real milestone.** For that, run `/agent-plan` with a real feature description and follow it through `/agent-code`.

---

_See also: the CAST template's `TROUBLESHOOTING.md` for symptom-based diagnostics and `example/` for a worked fixture showing what successful outputs look like._
