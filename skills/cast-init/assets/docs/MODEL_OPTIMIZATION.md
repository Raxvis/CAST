<!-- TEMPLATE INSTRUCTIONS
  FILE: MODEL_OPTIMIZATION.md
  PURPOSE: This file is the model policy for the agent roster. It defines which Claude model
  each agent runs on by default, how each supported model behaves differently, and the exact
  upgrade path between models. Agents reference this file from their "Model Configuration"
  sections; humans reference it when re-pinning agents or upgrading after a new model release.

  HOW TO CUSTOMIZE:
  - Replace [PROJECT_NAME] with your project name.
  - The model IDs in this file are real Anthropic model IDs, NOT placeholders. Do not rewrite
    them during adoption.
  - If your organization restricts model access, update the Default Roster Assignment table to
    match the models you can actually serve, then apply the matching behavior profile notes.
  - When Anthropic ships a newer model, add it to the ladder, write its behavior profile, and
    add an upgrade-path section — then switch the session model (or update each agent's
    frontmatter pin, if you pinned explicitly).
-->

# [PROJECT_NAME] — Agent Model Optimization Guide

This document is the single source of truth for which Claude model each CAST agent runs on, how the supported models differ in behavior, and how to move the roster between them. Each agent file carries only a compact **Model Configuration** section — the frontmatter `model:` setting (default `inherit`, meaning the agent runs on the session model), the frontmatter `effort:` key (the role's enforced default) plus a one-line note on the cases that warrant raising it, a pointer to `docs/STAGE_CONTRACT.md`, and a short **Rules** block holding that role's binding constraints. The model ladder table, effort rules (`xhigh` requires Opus 4.7+), per-model behavior profiles, and upgrade checklists live only in this file — a model change never requires editing per-agent sections: switch the session model (or the frontmatter pin, if you set one), substituting effort when running 4.6.

---

## The Opus Ladder

All CAST agents target the **Claude Opus family**. The four supported models share the same standard API pricing ($5 / $25 per MTok input/output; Opus 5's optional fast mode is priced separately at $10 / $50) and a 1M-token context window with 128K max output — so there is no cost reason to run an older pin. Prefer the newest model your platform serves: **Claude Opus 5 is the preferred executing model**.

| Model | ID | Status | Key capability notes |
|---|---|---|---|
| Claude Opus 5 | `claude-opus-5` | **Preferred** | Newest and most capable Opus tier. Best agentic execution, code review, debugging, and writing in the family. Full effort ladder `low`–`xhigh`–`max` with unusually strong `low`/`medium`; extended thinking on by default; self-verifies its own work unprompted; fast mode supported (Claude API only). Additional requirements below — see the Opus 5 behavior profile and the 4.8 → 5 upgrade path. |
| Claude Opus 4.8 | `claude-opus-4-8` | Supported | Previous generation. Strong long-horizon agentic execution; conservative about delegation (the reverse of Opus 5). Supports effort `low`–`xhigh`–`max`, fast mode, high-resolution vision, mid-session system messages. |
| Claude Opus 4.7 | `claude-opus-4-7` | Supported | Most literal instruction-follower; terse, precise. Supports effort `xhigh` and fast mode (fast mode on 4.7 is deprecated — 4.8+ is the durable fast tier). |
| Claude Opus 4.6 | `claude-opus-4-6` | Minimum supported | Oldest supported pin. No `xhigh` effort (use `high`). No fast mode. Uses the pre-4.7 tokenizer (same text ≈ fewer tokens than 4.7+). |

Do not pin models older than Opus 4.6 — the agent prompts in this template assume Opus 4.6+ behavior (adaptive thinking, close instruction-following) and will overtrigger or underperform on older models.

**Opus 5 additional requirements** (details in the behavior profile and upgrade path below):

- **Rate limits are a separate bucket.** Opus 5 does not share the combined Opus 4.x rate-limit pool — a roster moving to Opus 5 starts from its own throughput allocation. Check your organization's Opus 5 limits before switching an in-flight milestone.
- **Thinking is on by default** and can only be disabled at effort `high` or below — `thinking: {type: "disabled"}` combined with `xhigh`/`max` effort is rejected (HTTP 400). In Claude Code this is handled for you; it matters when driving agents via the Claude API or Agent SDK.
- **Safety classifiers can end a response with `stop_reason: "refusal"`** — automation that drives the pipeline over the API should handle that stop reason (retry with rephrased input or surface to the user) rather than treating it as an error.
- **Prompt-cache minimum drops to 512 tokens** (from 1024 on 4.8) — smaller agent definitions become cacheable; re-check any caching assumptions in API-driven setups.

---

## Default Roster Assignment

Every agent's YAML frontmatter sets `model: inherit` — each agent runs on the model of the invoking session, with Claude Opus 5 as the preferred executing model (Opus 4.8 / 4.7 / 4.6 supported). The per-role **effort** column below is **enforced frontmatter**: Claude Code agent frontmatter supports `effort: low | medium | high | xhigh | max`, and each agent file (except Product — see below) ships the key set to its default. A frontmatter `effort:` is fixed for that agent type — the orchestrator cannot raise it per invocation — so the "Raise to" cases are handled by prompt emphasis in the invocation, or by editing the pin for an exceptional milestone and reverting after. Product ships without the key (its `high` planning / `low` triage split cannot be expressed in one value; it follows the session effort and the prompt-body guidance). The frontmatter `model:` pin and `effort:` key are the roster's two mechanically enforceable per-role levers (see Right-sizing below). (The pre-v0.11.0 template used Opus 4.6 / Sonnet 4.6 / Haiku 4.5 tiers; see Upgrade Paths below if you are migrating an older install.)

| Agent | Default model | Default effort | Raise to | Why |
|---|---|---|---|---|
| Product | `inherit` | `high` planning / `low` triage | — | Requirements synthesis is `high`; disposing of one flagged criterion or a batch of bug triages is not. |
| Architect | `inherit` | `high` | `xhigh` for a new subsystem, schema migration, or cross-cutting contract change | Hardest design reasoning in the pipeline — but most milestones extend an existing design. |
| UI | `inherit` | `high` | — | Spec authoring anchored to concrete style-guide tokens. |
| Risk | `inherit` | `high` | — | Coverage-first review through two lenses. |
| CEO | `inherit` | `high` | — | Multi-document synthesis and gating verdict. |
| Coder | `inherit` | `medium` | `high` for a plan-flagged complex task or a non-obvious defect | See the effort note below — this is the biggest single change in v3's model policy. |
| Reviewer | `inherit` | `high` | `xhigh` on security-flagged milestones or plan-flagged complex tasks | Recall-critical, and the only independent check in the loop. |
| Docs Writer | `inherit` | `low` | — | Scoped documentation updates against a queue. |

### Effort notes

**`xhigh` is opt-in in v3, not a standing default.** CAST v2 set `xhigh` on four roles (Architect, Coder, Reviewer, Debugger). On Opus 5 that is the most expensive setting in the family — extended thinking is **on by default**, and lowering effort **does not shorten the response**, so a standing `xhigh` buys reasoning tokens without buying concision back. Opus 5's `low` and `medium` are strong enough that the mid-loop stages do not need it for ordinary work, and the table's "Raise to" column names the cases that do. Raise deliberately, per milestone or per task; do not restore it as a default.

**Coder at `medium`** is the change most likely to raise an eyebrow. The reasoning: v3's Coder implements against a task file that already carries the design decisions (made by Architect at `high`), an explicit Files list, and acceptance criteria — the hard thinking happened upstream, and what remains is execution against a spec. The safety net is not effort, it is the loop: Reviewer runs at `high` and reads the diff independently. Spending `xhigh` on the stage that writes code and `high` on the stage that checks it inverts where the leverage is.

**`xhigh` requires Opus 4.7 or newer** — when the executing model is Opus 4.6, substitute `high`.

In Claude Code, each agent's frontmatter `effort:` key sets its enforced default; an agent without the key (Product) follows the session's effort setting. When driving agents via the Claude API or Agent SDK, set `output_config: {effort: "..."}` per request (on Opus 5, `thinking: {type: "disabled"}` is only accepted at effort `high` or below).

**Right-sizing for cost:** `inherit` keeps every agent on the session model; the shipped `effort:` keys are the first enforceable cost lever, and per-agent model pins are the second — match model capability to each role's workload. A sensible split: keep the judgment-heavy gates (CEO, Architect, Reviewer, Risk) on the most capable model available (e.g. `claude-opus-5`, or a Fable/Mythos-class model if your account serves one); run Product, UI, Coder, and Docs Writer on Sonnet (`claude-sonnet-5`). **Do not pin Docs Writer below Sonnet-class:** the Context Inference Bar below is applied per document against its *weakest consumer*, and Docs Writer cites `docs/FILE_CONVENTIONS.md` and `docs/README.md` — a Haiku-class pin fails the bar and permanently blocks `/cast-doctor`'s Tier B prunes on those docs, forfeiting a larger always-on saving than the pin recovers. Claude Code also accepts the `opus` / `sonnet` / `haiku` aliases in agent frontmatter.

**Spawn count beats both.** Before tuning effort or pins, count the spawns. Each subagent launch pays a cold context — the agent definition, project memory, the task file, the manifest — before it does any work, and each distinct agent *type* is a separate prompt-cache prefix that must be written before it can be read. v3 cut a clean task from six spawns to two and the roster from fifteen types to eight for exactly this reason; it is a larger saving than any effort or model change, and it compounds on every loop-back. If you extend the roster, extend it knowing that.

---

## Behavior Profiles

Each supported model executes the same agent definitions differently. The per-agent "Model Configuration" sections carry only the role's binding rules; these family-wide profiles are the rationale behind them — consult the profile for whichever model you pin before re-tuning an agent's prompt.

### Claude Opus 5 (preferred)

- **Self-verifies without being told.** Opus 5 re-checks its own work — re-reading diffs, re-running tests, validating output against the ask — unprompted. Delete verification scaffolding from custom prompts ("double-check your changes", "re-read the file before handing off"): it duplicates work the model already does and inflates cost. The CAST agent prompts assume this; do not re-add checking ceremony when tuning them.
- **Expands task scope.** The strongest drift in the family toward fixing adjacent problems it notices along the way. The minimal-change discipline in the Coder prompt and the task-file Files list are load-bearing on Opus 5 — keep both, and treat out-of-scope discoveries as handoff-log notes, not silent fixes. (This is 4.6's overengineering tendency in a new form; 4.7/4.8 did not need the guardrail as much.)
- **Delegates to subagents readily — the reverse of 4.7/4.8.** Where 4.8 needed imperative "invoke agent X now" instructions, Opus 5 will spawn subagents on its own initiative. The CAST agents' `tools:` lists (which omit `Task`) make ad-hoc delegation impossible at the agent level; at the orchestrator level, the pipeline skills' "spawn only the agents each stage names" restriction is load-bearing on Opus 5 (as it was on 4.6). Keep the explicit stage invocations anyway — they define *which* agent runs, not just *that* one runs.
- **Longer responses, and lowering effort does not shorten them.** Verbosity must be constrained by prompt, not effort setting. The capped Handoff Log entries and one-line reply-channel rule in `docs/STAGE_CONTRACT.md` are the mechanism — keep them, and prompt for conciseness explicitly anywhere output length matters.
- **Follows reporting filters literally — same coverage-first rule as 4.7/4.8.** Severity filters still depress review recall. Review-type agents (Reviewer, Risk) must report everything with severity + confidence and let downstream stages filter.
- **Thinking is on by default** (unlike every 4.x model) and can be disabled only at effort `high` or below. **Full effort ladder with unusually strong `low`/`medium`** — see the effort notes above.
- **API/platform requirements:** separate rate-limit bucket from the Opus 4.x pool; 512-token prompt-cache minimum; fast mode at $10 / $50 per MTok (Claude API only); safety classifiers may return `stop_reason: "refusal"`. Details under "Opus 5 additional requirements" above.

### Claude Opus 4.8

- **Narrates on its own.** Provides interim progress updates and detailed wrap-ups without scaffolding. Do not add "summarize after every N tool calls" instructions; if an agent is too chatty, instruct a silence-default between tool calls instead.
- **More deliberate — asks more often.** Pauses on minor decisions (naming, defaults, equivalent approaches) and offers follow-up work after finishing. Agent prompts should grant autonomy on small choices and reserve questions for scope changes and destructive actions.
- **Conservative about reaching for tools, subagents, and memory.** It will not use a capability unless told *when* to use it. The explicit "invoke agent X now" stage instructions in the CAST commands are load-bearing — keep them imperative.
- **Best with the full task up front.** Give complete specs in a single well-specified turn and run at `high`/`xhigh` effort; this is where its long-horizon advantage shows.
- **Follows reporting filters literally.** "Only report high-severity issues" measurably depresses recall even though its bug-finding improved. Review-type agents (Reviewer, Risk) must report everything with severity + confidence and let downstream stages filter.
- **Warmer, clearer prose** than 4.7 — re-check any style instructions written to counter 4.7's terseness; they may now overcorrect.

### Claude Opus 4.7

- **Most literal instruction-follower.** It will not generalize an instruction beyond its stated scope or infer unstated requirements. Specs, acceptance criteria, and rules must say exactly what they mean — ambiguity becomes a question, not an assumption.
- **Terse by default.** Calibrates response length to task complexity. Required sections in handoff documents must be marked mandatory or they may be thinned out.
- **Uses tools and subagents less than 4.6.** Reaches for reasoning before tools. Keep explicit tool-use and delegation instructions; raise effort to `high`/`xhigh` for tool-heavy stages.
- **Same coverage-first reporting rule as 4.8** — conservative-severity filters depress measured recall.
- **`xhigh` effort available** and is the best setting for coding and agentic stages.

### Claude Opus 4.6 (minimum)

- **Follows the system prompt very closely — measured wording required.** Aggressive directives ("CRITICAL:", "You MUST", "If in doubt, do X") overtrigger. The CAST agent prompts are written in calibrated language; do not escalate them.
- **Overeager subagent spawning.** May delegate work a direct read or grep would solve. Commands should restrict it to the stages they define — no ad-hoc delegation.
- **Prone to overengineering.** Adds extra files, abstractions, and defensive handling beyond the ask. Coder and Architect prompts need explicit minimal-change discipline.
- **May skip verbal summaries after tool use.** The mandatory handoff formats in each agent file compensate — state that summaries are required.
- **No `xhigh` effort** — use `high` for stages that would run `xhigh` on 4.7/4.8. **No fast mode.**

---

## Context Inference Bar

Newer models infer project facts — directory layout, naming conventions, tech stack, standard best practices — directly from the codebase, which turns documentation that merely restates them into redundant context weight. `/cast-doctor`'s **Tier B** prune prescriptions (mechanical restatements of code/structure and generic best-practice material) are gated on the bar below. **Tier A** findings (duplication, dead references, unfilled skeletons) apply on any supported model.

| Model | Clears the bar |
|---|---|
| Claude Opus 4.8 (`claude-opus-4-8`) and newer Opus | Yes |
| Fable/Mythos-class models | Yes |
| Claude Sonnet 5 (`claude-sonnet-5`) and newer Sonnet | Yes |
| Claude Opus 4.7 (`claude-opus-4-7`) | No — the most literal instruction-follower; it does not infer unstated conventions, so written restatements still carry weight |
| Claude Opus 4.6 (`claude-opus-4-6`) | No |
| Claude Haiku 4.5 (`claude-haiku-4-5`) and older Haiku | No — utility-tier; relies on written structure |

The bar is applied **per document, against its weakest consumer**: `/cast-doctor` resolves each consuming agent's executing model (the frontmatter pin, or the session model under `inherit` — plus the session itself for docs that are live Memory Imports) and prescribes a Tier B prune only when the least capable consumer clears the bar. On a right-sized roster this means a doc cited by a Haiku-pinned utility agent keeps its mechanical content no matter how capable the session model is — correct, not a bug.

Re-run `/cast-doctor` after any model change: upgrades unlock previously bar-blocked Tier B prescriptions; downgrades surface restoration findings for previously pruned mechanical content (git history has it).

---

## Upgrade Paths

### Opus 4.6 → Opus 4.7

1. **Model:** switch the session model to Opus 4.7 (agents default to `model: inherit`); if you pinned explicitly, change `model: claude-opus-4-6` → `model: claude-opus-4-7` in each agent file.
2. **Effort:** `xhigh` becomes available. In v3 it is opt-in per the Default Roster Assignment table's "Raise to" column — do not apply it as a standing default.
3. **Prompts — add explicit triggering.** 4.7 under-reaches for tools and subagents where 4.6 over-reached. Verify every tool use and delegation the pipeline depends on is stated imperatively ("run the test suite now", "invoke the reviewer agent"), not implied.
4. **Prompts — expect terser output.** If handoff documents come back thin, mark required sections as mandatory rather than lengthening instructions.
5. **Review agents:** confirm coverage-first reporting language is present (report all findings with severity + confidence; filter downstream).
6. **API callers only:** `budget_tokens` and `temperature`/`top_p`/`top_k` are removed on 4.7 (HTTP 400) — use `thinking: {type: "adaptive"}` and prompt-based steering. 4.7 also switches tokenizers (~same text, more tokens) — re-baseline any `max_tokens` and compaction thresholds.

### Opus 4.7 → Opus 4.8

1. **Model:** switch the session model to Opus 4.8 (agents default to `model: inherit`); if you pinned explicitly, change the pin to `model: claude-opus-4-8`. There are no new API breaking changes — this is a model swap plus prompt re-tuning.
2. **Remove forced-progress scaffolding** ("after every N tool calls, summarize") — 4.8 narrates on its own.
3. **Add small-decision autonomy.** 4.8 asks more often; agent prompts should say "for minor choices, pick a reasonable option and note it; ask only for scope changes or destructive actions." (CAST agents ship with this in their Model Configuration notes.)
4. **Re-check style prompts** written to counter 4.7's terseness — 4.8 is warmer and less hedged by default.
5. **Keep explicit tool/subagent triggering** — 4.8 remains conservative about reaching for capabilities without a stated trigger condition.

### Opus 4.6 → Opus 4.8

Apply both checklists above in order. The high-leverage items: explicit tool/delegation triggers (4.6's overtriggering masked their absence), coverage-first review language, and dropping any prompt hedges that existed to restrain 4.6's overengineering enthusiasm — 4.8 needs the *goal* stated clearly more than it needs guardrails.

### Opus 4.8 → Opus 5

1. **Model:** switch the session model to Opus 5 (agents default to `model: inherit`); if you pinned explicitly, change the pin to `model: claude-opus-5`. Pricing is unchanged ($5 / $25 per MTok) — but Opus 5 draws from a **separate rate-limit bucket**, not the shared Opus 4.x pool, so confirm your organization's Opus 5 limits support the pipeline's parallel-task fan-out before switching an in-flight milestone.
2. **Delete verification scaffolding.** Remove any "double-check your work" / "re-read your diff before handing off" instructions you added to agent prompts — Opus 5 self-verifies unprompted, and the scaffolding doubles the work.
3. **Tighten scope discipline.** Opus 5 expands task scope more than any 4.x model. Confirm the minimal-change language in Coder prompt is intact and that task Files lists are treated as binding (out-of-scope discoveries go in the Handoff Log, not into the diff).
4. **Delegation caution flips direction.** 4.8 under-delegates; Opus 5 over-delegates. Keep the pipeline skills' "spawn only the agents each stage names" restriction (already present for 4.6) and keep the agents' `tools:` lists omitting `Task` — both are load-bearing again on Opus 5.
5. **Prompt for conciseness where length matters.** Opus 5 writes longer responses and lowering effort does not shorten them — rely on the capped Handoff Log entries and explicit length limits, not effort settings.
6. **Effort:** existing recommendations carry over unchanged (`xhigh` supported). Optionally re-tier for cost: Opus 5's `low`/`medium` are strong enough that mid-loop agents can often drop a step without quality loss.
7. **API callers only (two breaking changes + handling):** thinking is **on by default** — remove any explicit thinking-enable, and note `thinking: {type: "disabled"}` is rejected (HTTP 400) at effort `xhigh`/`max`; `budget_tokens` and `temperature`/`top_p`/`top_k` remain removed as on 4.7/4.8. Handle `stop_reason: "refusal"` from the safety classifiers. The prompt-cache minimum drops to 512 tokens — smaller shared prefixes become cacheable.

### Opus 4.7 or 4.6 → Opus 5

Apply the intermediate checklists in order (4.6 → 4.7 → 4.8 as applicable), then the 4.8 → 5 checklist above. The high-leverage items when skipping generations: coverage-first review language (constant across the family), scope discipline (4.6 and 5 both need it; 4.7/4.8 masked its absence), and the delegation restriction (same story).

### Pinning an older model (downgrade path)

Legitimate reasons to pin `claude-opus-4-8`, `claude-opus-4-7`, or `claude-opus-4-6`: platform/model availability in your organization, reproducibility inside an in-flight milestone (don't switch models mid-milestone — finish the milestone, then upgrade), or regression-testing a prompt change against the previous generation. When downgrading:

- 5 → 4.8: re-add explicit tool/delegation triggering if stages stop firing (4.8 is conservative where 5 is eager); if review or handoff quality slips, verification prompts that were correctly deleted for Opus 5 may need to return.
- 4.8 → 4.7: expect terser handoffs and less narration; nothing breaks.
- Any → 4.6: replace `xhigh` effort with `high`; re-read the 4.6 profile above — its overtriggering/overengineering tendencies are the reverse of 4.7/4.8's and the per-agent notes cover both directions.

---

## Verifying a Model Change

After re-pinning any agent:

1. `grep -n "^model:\|^effort:" .claude/agents/*.md` — every agent shows `model: inherit` (the default) or the intended explicit pin, and its shipped `effort:` value; no stale model IDs left over from a previous pin, and no `xhigh` effort on an agent whose executing model is Opus 4.6 (which lacks it).
2. Run `/agents` in Claude Code and confirm each agent registers with the expected model.
3. Run one cheap smoke stage (e.g. `/agent-task` on a trivial fix) and confirm the executing model in the session output matches the intended model (the session model under `inherit`, or the pin).
4. Record the change in `docs/DESIGN_RATIONALE.md` (which models, why, date) so mid-milestone reproducibility questions have an answer.
5. Run `/cast-doctor` — a model change moves the Context Inference Bar for Tier B documentation: upgrades unlock prunes, downgrades surface restoration findings.
