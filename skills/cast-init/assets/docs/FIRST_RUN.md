<!-- TEMPLATE INSTRUCTIONS
  FILE: FIRST_RUN.md
  PURPOSE: A short interactive checklist the user runs the first time they open
  Claude Code in a freshly-installed template. Verifies that Claude Code actually
  loads the subagents, the pipeline skills appear, and /agent-plan runs end-to-end.

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

**If it fails:** your `CLAUDE.md` is probably at the wrong path. It must live at the project root, not inside `docs/` or anywhere else. See the CAST repo's [`TROUBLESHOOTING.md`](https://github.com/Raxvis/CAST/blob/main/TROUBLESHOOTING.md) → "`CLAUDE.md` context is not being loaded".

---

## Step 2 — Run `/agents` and confirm every subagent is registered

In the Claude Code session, type:

```
/agents
```

**Verify:** you see a list of subagents that matches the files in `.claude/agents/`. On a full install you should see all 8: `architect`, `ceo`, `coder`, `docs-writer`, `product`, `reviewer`, `risk`, `ui`. On a pruned install you should see whatever subset you kept.

**If an agent is missing:** the most common cause is malformed YAML frontmatter. Open the missing agent file and verify the `---` fences are balanced and the `name:`, `description:`, and `model:` keys are present on separate lines.

**If `/agents` is not recognized at all:** your Claude Code version is too old. Update it.

---

## Step 3 — Check the installed skills as "tab completion" smoke checks

Type `/agent` and check that the three pipeline skills auto-complete, then `/cast` for the maintenance skill (on current Claude Code versions, skills are invocable as `/<name>`):

```
/agent-plan
/agent-code
/agent-task
/cast-doctor
/cast-release
```

**Verify:** every skill you kept in `.claude/skills/` appears in the completion list. You do not need to actually run them yet — just confirm Claude Code sees them.

**If a pipeline is missing:** restart the session. Claude Code discovers `.claude/skills/` at session start; if you installed while a session was already open, the new files are not picked up until you restart. If it is still missing after a restart, confirm the file exists at `.claude/skills/<name>/SKILL.md` and its frontmatter `name` matches the directory name.

---

## Step 4 — Dry-run `/agent-plan` on a throwaway feature description

With your session still open, run:

```
/agent-plan "Print a hello-world message when the app starts"
```

**Verify:** the Product agent kicks off. You should see it create `artifacts/milestone-1-<slug>/` and begin writing the milestone README there.

You can interrupt the planning run as soon as Product starts writing — you are not trying to produce a real milestone, you are just confirming the command routing works. If Product writes anything at all into a new `artifacts/milestone-1-*/` directory, Steps 1–3 are confirmed and the pipeline is wired up correctly.

**If Product never writes a file:** the Product agent is not loading. Check `.claude/agents/product.md` for frontmatter issues, or re-run `/agents` to confirm Product is listed.

**If `/agent-plan` halts with a "missing template" error:** your `templates/` directory is missing `TASK.md` or another planning template that the pipeline references. Re-run `/cast-init` to reinstall `templates/`.

---

## Step 5 — (Optional) Dry-run `/agent-task` on a trivial change

For a lighter-weight verification that the engineering pipeline is working:

```
/agent-task "Add a comment to CLAUDE.md saying this is a test run"
```

**Verify:** the Coder agent picks up the task, makes the one-line change, writes and runs its tests, and hands off with a verbatim test-results block; the Reviewer agent verifies that block, approves, and records the Acceptance Criteria Check; and the task closes — with no Product spawn if every criterion came back Met. You can roll the commit back afterward.

**If any agent in the chain halts:** read the halt message. It should cite the specific agent and the specific reason. Cross-reference the CAST repo's [`TROUBLESHOOTING.md`](https://github.com/Raxvis/CAST/blob/main/TROUBLESHOOTING.md).

---

## Clean up the throwaway artifacts

If you ran Step 4 or Step 5, a few files are now in `artifacts/`. Delete them before your real work begins:

```
rm -rf artifacts/milestone-1-*
```

(Everything a planning run writes — reviews included — lives inside that one milestone directory.)

---

## Appendix — Per-agent smoke probes (optional)

If Step 4 or Step 5 completes cleanly, the pipeline is working end-to-end and you can usually stop. The probes below are an optional next step for verifying that each individual agent does what its file says it does — useful after you customize an agent file, or if you want a finer-grained trust signal before running a real milestone.

Each probe is a single prompt to launch the named agent explicitly. Each takes under a minute. Run only the ones you care about; you do not need all 8.

### Planning-tier probes

| Agent | Probe | Expected |
|---|---|---|
| `product` | "Use the product agent to write acceptance criteria for 'add a dark mode toggle'." | Testable, specific criteria (not vague statements like "works well"). |
| `architect` | "Use the architect agent to sketch module boundaries for a new authentication system." | A module table plus a Decisions Log entry that cites alternatives considered. |
| `ui` | "Use the ui agent to spec the interaction states for a login form." | Covers all six canonical states (default, pressed, disabled, loading, error, empty) explicitly, per `templates/UI_SPEC.md`. |
| `risk` | "Use the risk agent to review this architecture document." | Produces both lens sections (security and performance) even when one is empty, and ends with both flag lines set. |
| `ceo` | "Use the ceo agent to review a milestone plan where the Risk review has an unaddressed Critical finding." | Verdict is REVISION REQUIRED, not APPROVED WITH CONDITIONS — the CEO does not paper over Critical findings. |

### Engineering-tier probes

| Agent | Probe | Expected |
|---|---|---|
| `coder` | "Use the coder agent to implement a function that returns the sum of two numbers." | Working code, tests written and run, a commit, and a verbatim Test Results block in the handoff entry. |
| `reviewer` | "Use the reviewer agent to review a file with both a logic bug and a style violation." | Classifies the logic bug as a Defect (files a bug file itself) and the style issue as an Issue (back to Coder). |

### Utility-tier probes

| Agent | Probe | Expected |
|---|---|---|
| `docs-writer` | "Use the docs-writer agent to document a newly-added helper function." | Updates an existing doc under `docs/` rather than creating a new file. Does not write to `artifacts/`. |

### Interpreting results

- **Probe passes with a reasonable output:** the agent file is loaded and the model is responding consistently with the role definition.
- **Probe returns generic output that could come from any agent:** the role definition is not being loaded. Check that `.claude/agents/<name>.md` has valid frontmatter (see Step 2).
- **Probe returns a "model not available" error:** your account does not have access to the pinned model. Override the `model:` line in the agent's frontmatter to a model you have access to.
- **Probe returns output that contradicts the agent's role definition:** the model is not reading the agent body carefully enough. Try a more capable model tier, or tighten the agent's Interaction Rules section to be more prescriptive.

---

## After the first run

Once this checklist passes, this file has done its job — later health questions belong to `/cast-doctor`, the run-anytime install check (structural invariants, documentation audit, coverage gaps). Expect a future `/cast-doctor` run to propose deleting this file as self-obsoleted; that is working as intended.

---

## A note on the cast-init skill itself

Keep `.claude/skills/cast-init` installed — it is the upgrade mechanism (`npx skills update` or `/plugin marketplace update`, then re-run `/cast-init`). If it was installed via `npx skills`, two artifacts are normal: a `skills-lock.json` at the project root (commit it — it pins the skill revision for teammates) and the skill directory being a symlink into `.agents/skills/` (harmless; use `npx skills add --copy` if your tooling doesn't follow symlinks).

---

## What this checklist does NOT cover

- **Per-agent model access.** Agents default to `model: inherit` and run on the session model, so they work with whatever model your account already serves. If you pin an agent to a model your account cannot access (e.g. `claude-opus-5`), it will fail when invoked — the static smoke test cannot detect this; you find out when `/agent-plan` halts. Fix: set the `model:` line back to `inherit` or to a model you have access to (see `docs/MODEL_OPTIMIZATION.md` for the per-model notes).
- **Project-specific conventions.** This checklist verifies the template is wired up; it does not verify that your `CLAUDE.md`, `PRD.md`, or code conventions are accurate for your project. That is the user's responsibility.
- **Full end-to-end run of a real milestone.** For that, run `/agent-plan` with a real feature description and follow it through `/agent-code`.

---

_See also: the CAST repo's [`TROUBLESHOOTING.md`](https://github.com/Raxvis/CAST/blob/main/TROUBLESHOOTING.md) for symptom-based diagnostics and its `example/` directory for a worked fixture showing what successful outputs look like._
