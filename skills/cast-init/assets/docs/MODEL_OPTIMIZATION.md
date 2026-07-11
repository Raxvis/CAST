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
    add an upgrade-path section — then bump each agent's frontmatter pin.
-->

# [PROJECT_NAME] — Agent Model Optimization Guide

This document is the single source of truth for which Claude model each CAST agent runs on, how the supported models differ in behavior, and how to move the roster between them. Each agent file carries only a compact **Model Configuration** section — the frontmatter `model:` pin, a one-line recommended effort, and a short **Rules (all models)** block holding that role's binding behavioral constraints (no subagents, structured-output handoffs, silence-is-not-a-clean-report for review roles, plus role-specific discipline). The model ladder table, effort rules (`xhigh` requires Opus 4.7+), per-model behavior profiles, and upgrade checklists live only in this file — a model change never requires editing per-agent sections, just the frontmatter pin (and effort substitution when pinning 4.6).

---

## The Opus 4.x Ladder

All CAST agents target the **Claude Opus 4.x family**. The three supported models are priced identically ($5 / $25 per MTok input/output) and share a 1M-token context window with 128K max output — so there is no cost reason to run an older pin. Prefer the newest model your platform serves.

| Model | ID | Status | Key capability notes |
|---|---|---|---|
| Claude Opus 4.8 | `claude-opus-4-8` | **Default — recommended** | Most capable Opus tier. Best long-horizon agentic execution, code review, debugging, and writing. Supports effort `low`–`xhigh`–`max`, fast mode, high-resolution vision, mid-session system messages. |
| Claude Opus 4.7 | `claude-opus-4-7` | Supported | Previous generation. Most literal instruction-follower; terse, precise. Supports effort `xhigh` and fast mode (fast mode on 4.7 is deprecated — 4.8 is the durable fast tier). |
| Claude Opus 4.6 | `claude-opus-4-6` | Minimum supported | Oldest supported pin. No `xhigh` effort (use `high`). No fast mode. Uses the pre-4.7 tokenizer (same text ≈ fewer tokens than 4.7/4.8). |

Do not pin models older than Opus 4.6 — the agent prompts in this template assume Opus 4.6+ behavior (adaptive thinking, close instruction-following) and will overtrigger or underperform on older models.

---

## Default Roster Assignment

Every agent's YAML frontmatter pins `model: claude-opus-4-8`. Differentiation between roles now comes from **reasoning effort**, not model tier (the pre-v0.11.0 template used Opus 4.6 / Sonnet 4.6 / Haiku 4.5 tiers; see Upgrade Paths below if you are migrating an older install).

| Agent | Default model | Recommended effort | Why |
|---|---|---|---|
| Product | `claude-opus-4-8` | `high` | Requirements synthesis and acceptance-criteria validation. |
| Architect | `claude-opus-4-8` | `xhigh` | Hardest design reasoning in the pipeline. |
| UI | `claude-opus-4-8` | `high` | Spec authoring anchored to concrete style-guide tokens. |
| Security | `claude-opus-4-8` | `high` | Coverage-first vulnerability review. |
| Performance | `claude-opus-4-8` | `high` | Measurement-anchored bottleneck review. |
| CEO | `claude-opus-4-8` | `high` | Multi-document synthesis and gating verdict. |
| Coder | `claude-opus-4-8` | `xhigh` | Best coding/agentic setting on Opus 4.7+. |
| Tester | `claude-opus-4-8` | `high` | Test generation and faithful failure reporting. |
| Reviewer | `claude-opus-4-8` | `xhigh` | Recall-critical bug finding. |
| Debugger | `claude-opus-4-8` | `xhigh` | Root-cause analysis, intermittent failures. |
| Refactor | `claude-opus-4-8` | `high` | Behavior-preserving, tightly scoped changes. |
| Bug Gatherer | `claude-opus-4-8` | `low` | Mechanical, structured intake. |
| Docs Writer | `claude-opus-4-8` | `low` | Scoped documentation updates. |
| Release | `claude-opus-4-8` | `low` | Checklist execution. |
| Validator | `claude-opus-4-8` | `low` | Rule enforcement against written process. |

**Effort notes:** `xhigh` requires Opus 4.7 or newer — when pinning an agent to `claude-opus-4-6`, substitute `high`. In Claude Code, effort follows session settings; when driving agents via the Claude API or Agent SDK, set `output_config: {effort: "..."}` per request.

**Cost fallback:** the four utility agents (Bug Gatherer, Docs Writer, Release, Validator) were pinned to `claude-haiku-4-5` before v0.11.0 and still run acceptably there. If cost or latency on utility work matters more than judgment, re-pin them to `claude-haiku-4-5` ($1 / $5 per MTok) — everything else in this guide assumes the Opus family.

---

## Behavior Profiles

Each supported model executes the same agent definitions differently. The per-agent "Model Configuration" sections carry only the role's binding rules; these family-wide profiles are the rationale behind them — consult the profile for whichever model you pin before re-tuning an agent's prompt.

### Claude Opus 4.8 (default)

- **Narrates on its own.** Provides interim progress updates and detailed wrap-ups without scaffolding. Do not add "summarize after every N tool calls" instructions; if an agent is too chatty, instruct a silence-default between tool calls instead.
- **More deliberate — asks more often.** Pauses on minor decisions (naming, defaults, equivalent approaches) and offers follow-up work after finishing. Agent prompts should grant autonomy on small choices and reserve questions for scope changes and destructive actions.
- **Conservative about reaching for tools, subagents, and memory.** It will not use a capability unless told *when* to use it. The explicit "invoke agent X now" stage instructions in the CAST commands are load-bearing — keep them imperative.
- **Best with the full task up front.** Give complete specs in a single well-specified turn and run at `high`/`xhigh` effort; this is where its long-horizon advantage shows.
- **Follows reporting filters literally.** "Only report high-severity issues" measurably depresses recall even though its bug-finding improved. Review-type agents (Reviewer, Security, Performance, Tester) must report everything with severity + confidence and let downstream stages filter.
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
- **Prone to overengineering.** Adds extra files, abstractions, and defensive handling beyond the ask. Coder/Refactor/Architect prompts need explicit minimal-change discipline.
- **May skip verbal summaries after tool use.** The mandatory handoff formats in each agent file compensate — state that summaries are required.
- **No `xhigh` effort** — use `high` for stages that would run `xhigh` on 4.7/4.8. **No fast mode.**

---

## Upgrade Paths

### Opus 4.6 → Opus 4.7

1. **Frontmatter:** change `model: claude-opus-4-6` → `model: claude-opus-4-7` in each agent file.
2. **Effort:** stages previously capped at `high` can move to `xhigh` (Coder, Reviewer, Debugger, Architect).
3. **Prompts — add explicit triggering.** 4.7 under-reaches for tools and subagents where 4.6 over-reached. Verify every tool use and delegation the pipeline depends on is stated imperatively ("run the test suite now", "invoke the debugger agent"), not implied.
4. **Prompts — expect terser output.** If handoff documents come back thin, mark required sections as mandatory rather than lengthening instructions.
5. **Review agents:** confirm coverage-first reporting language is present (report all findings with severity + confidence; filter downstream).
6. **API callers only:** `budget_tokens` and `temperature`/`top_p`/`top_k` are removed on 4.7 (HTTP 400) — use `thinking: {type: "adaptive"}` and prompt-based steering. 4.7 also switches tokenizers (~same text, more tokens) — re-baseline any `max_tokens` and compaction thresholds.

### Opus 4.7 → Opus 4.8

1. **Frontmatter:** change the pin to `model: claude-opus-4-8`. There are no new API breaking changes — this is an ID swap plus prompt re-tuning.
2. **Remove forced-progress scaffolding** ("after every N tool calls, summarize") — 4.8 narrates on its own.
3. **Add small-decision autonomy.** 4.8 asks more often; agent prompts should say "for minor choices, pick a reasonable option and note it; ask only for scope changes or destructive actions." (CAST agents ship with this in their Model Configuration notes.)
4. **Re-check style prompts** written to counter 4.7's terseness — 4.8 is warmer and less hedged by default.
5. **Keep explicit tool/subagent triggering** — 4.8 remains conservative about reaching for capabilities without a stated trigger condition.

### Opus 4.6 → Opus 4.8

Apply both checklists above in order. The high-leverage items: explicit tool/delegation triggers (4.6's overtriggering masked their absence), coverage-first review language, and dropping any prompt hedges that existed to restrain 4.6's overengineering enthusiasm — 4.8 needs the *goal* stated clearly more than it needs guardrails.

### Pinning an older model (downgrade path)

Legitimate reasons to pin `claude-opus-4-7` or `claude-opus-4-6`: platform/model availability in your organization, reproducibility inside an in-flight milestone (don't switch models mid-milestone — finish the milestone, then upgrade), or regression-testing a prompt change against the previous generation. When downgrading:

- 4.8 → 4.7: expect terser handoffs and less narration; nothing breaks.
- Any → 4.6: replace `xhigh` effort with `high`; re-read the 4.6 profile above — its overtriggering/overengineering tendencies are the reverse of 4.7/4.8's and the per-agent notes cover both directions.

---

## Verifying a Model Change

After re-pinning any agent:

1. `grep -n "^model:" .claude/agents/*.md` — every agent shows the intended pin; no `inherit` leftovers unless deliberate.
2. Run `/agents` in Claude Code and confirm each agent registers with the expected model.
3. Run one cheap smoke stage (e.g. `/agent-task` on a trivial fix) and confirm the executing model in the session output matches the pin.
4. Record the change in `docs/DESIGN_RATIONALE.md` (which models, why, date) so mid-milestone reproducibility questions have an answer.
