---
name: feature-request
description: "Handle a feature request through the Producer-led protocol with tiered routing. Simple single-domain requests delegate directly to domain agents; complex cross-domain requests go through the producer for full 3-phase coordination."
argument-hint: "[feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion, request_user_input, clarify
model: sonnet
---

# Feature Request Handler

When a feature request is submitted, it is routed through a **tiered
coordination protocol** that dispatches simple requests to domain agents
directly (sonnet-level) and reserves the full Producer-led 3-phase workflow
(opus-level) for complex, cross-domain features.

**This skill does not write files directly.** All decomposition, assignment,
and verification is performed by delegated agents.

---

## Tiered Routing Overview

| Complexity | Routing | Model tier | When to use |
|-----------|---------|------------|-------------|
| **Simple** (≤ 2 domains, ≤ 3 stories) | Direct delegation to domain agent | sonnet (terra) | Single-domain, straightforward features |
| **Complex** (> 2 domains OR > 3 stories OR technical-architecture keywords) | Delegate to `producer` agent | opus (sol) | Cross-domain, needs coordination |

**Escalation**: If the producer is unavailable (Complex route),
`creative-director` acts as interim coordinator for feature requests,
re-delegating to the producer when available.

**When to use this skill**:
- A user submits a new feature request
- A feature idea emerges mid-sprint that needs scope assessment
- An external stakeholder (community, publisher) requests a feature

---

## Phase 0: Parse Arguments

- `$ARGUMENTS[0]` — the feature request description
- `--review [full|lean|solo]` — optional review mode override

Resolve review mode (stored for downstream use):
1. If `--review [mode]` was passed → use that
2. Else read `production/review-mode.txt` → use that value
3. Else default to `lean`

**Argument check**: If no feature description is provided, output:

> "Usage: `/feature-request [feature description] [--review full|lean|solo]`
> Provide a description of the feature to handle (e.g., `add daily quests`,
> `implement character customization screen`)."

Then stop — do not spawn any agents.

---

## Phase 0.5: Complexity Assessment

Scan `$ARGUMENTS[0]` for domain keywords to determine routing:

**Domain keyword mapping**:

| Domain | Keywords (case-insensitive) | Agent |
|--------|---------------------------|-------|
| `design` | design, ui, ux, balance, mechanic, interface, gameplay | `game-designer` |
| `programming` | code, function, implement, fix, system, architect, engine, perform, optimi | `lead-programmer` |
| `art` | art, sprite, texture, asset, model, animation, visual, render | `art-director` |
| `audio` | sound, music, sfx, voice, audio | `audio-director` |
| `narrative` | story, dialogue, quest, mission, npc, character, plot, writer | `narrative-director` |
| `live-ops` | monetiz, event, season, battle-pass, retention, engagement | `live-ops-designer` |

**Assessment algorithm**:
1. **Count domains**: Scan the description for keywords across all 6 domains. Count how many distinct domains have ≥ 1 match.
2. **Estimate stories**: 
   - If the description mentions "epic" or lists 2+ distinct features → estimate ≥ 3 stories
   - If "and" connects 2+ features → estimate 2 stories
   - Otherwise → estimate 1 story
3. **Flag for opus-level consultation**: If the description contains technical
   architecture keywords (architect, database, network, security, performance,
   scaling, migration, refactor, rewrite, migration), treat as **Complex** even
   if domain count is ≤ 2 — these require `technical-director` (opus) review.
4. **Route**:
   - If `domains ≤ 2` AND `estimated_stories ≤ 3` → **Simple** → proceed to Phase 1A (Direct Delegation)
   - If `domains > 2` OR `estimated_stories > 3` → **Complex** → proceed to Phase 1B (Producer Delegation)

---

## Phase 1A: Direct Delegation (Simple Route)

Spawn the domain agent for the **dominant** (highest keyword match count) domain
via `delegate_task` with context:

> "A simple feature request has been submitted. This is a single-domain
> request (scope does not require cross-department coordination).
>
> **Feature Request**: [paste entire description]
>
> **Your task**: Apply the relevant domain expertise to this request.
> Review project context: `production/stage.txt`, `production/sprints/`,
> `design/gdd/game-concept.md`. Review mode: [resolved mode].
>
> Produce:
> 1. A breakdown into concrete, assignable tasks (with acceptance criteria)
> 2. Any questions for the user (use AskUserQuestion/clarify if needed)
> 3. Identification of any cross-domain concerns that would warrant
>    escalation to the producer for complex coordination
>
> Spawn subagents only if the work genuinely spans sub-domains within your
> expertise. Do NOT delegate across to other domain leads unless you
> identify cross-domain concerns.
>
> **Do NOT invoke `producer`, `creative-director`, or `technical-director`**
> (all opus/sol). Only use sonnet-level domain agents within your expertise.
> If you identify cross-domain concerns, surface them for the user to decide
> whether to re-route to the producer."

**Wait for results**. Then proceed to Phase 2A (Review Direct Delegation).

---

## Phase 1B: Producer Delegation (Complex Route)

Spawn `producer` via `delegate_task` with full context:

> "A complex feature request has been submitted that spans multiple domains.
> Handle it through the Producer-led 3-phase protocol:
>
> **Phase 1 — Digest & Breakdown**: Read the feature request below, clarify
> scope if needed (ask the user questions via AskUserQuestion/clarify), and
> decompose it into epics and stories with clear acceptance criteria.
> Consult `creative-director` for vision/pillar alignment and
> `technical-director` for feasibility assessment if the request touches
> architecture or engine constraints.
>
> **Model-tier guidance**: For all other subagent spawns, use sonnet-level
> agents (game-designer, lead-programmer, qa-tester, etc.). Only invoke
> opus-level agents (`producer`, `creative-director`, `technical-director`)
> when explicitly required by the request scope.
>
> **Phase 2 — Coordinate & Handle**: Assign tasks to responsible domain
> agents using the delegation map in `.claude/docs/agent-coordination-map.md`.
> Agents must NOT begin until assigned with defined scope and acceptance
> criteria. Spawn subagents (game-designer, lead-programmer, etc.) as
> needed within your iteration budget.
>
> **Phase 3 — Verify**: Validate that all acceptance criteria are met and
> sign off. If you are unavailable or blocked, escalate to `creative-director`
> as interim coordinator for this feature request.
>
> **Escalation rule**: If producer is unavailable, `creative-director`
> handles features, `technical-director` handles bugs.
>
> **Feature Request**: [paste entire feature description argument]
>
> **Project context**: Read `production/stage.txt` for current phase,
> `production/sprints/` for current sprint context, and
> `design/gdd/game-concept.md` for pillars. Review mode: [resolved mode].
>
> Report back with:
> 1. The decomposed epics/stories with acceptance criteria
> 2. The domain agents assigned to each task
> 3. The verification verdict (APPROVED / CONCERNS / BLOCKED)
> 4. Next steps for implementation"

Wait for the producer's full report. The producer may spawn its own subagents
(qa-tester, game-designer, etc.) — that is expected.

Then proceed to Phase 2B (Review Producer Delegation).

---

## Phase 2A: Review Direct Delegation

Review the domain agent's response:

- **If the agent produced a task breakdown** with acceptance criteria: confirm
  the tasks are clear and actionable.
- **If the agent identified cross-domain concerns** that warrant producer-level
  coordination: surface to the user:
  - `[A] Re-route to producer — this needs cross-domain coordination`
  - `[B] Proceed with direct delegation — I'll handle the cross-domain parts myself`
- **If the agent raised CONCERNS** about scope/feasibility: surface via
  `AskUserQuestion`/`clarify`:
  - `[A] Address the concerns — adjust the feature description`
  - `[B] Proceed anyway — I accept the risk`

---

## Phase 2B: Review Producer Delegation

Review the producer's response (Complex route only):

- **If the producer decomposed the request** and assigned tasks: confirm the
  assignment list and acceptance criteria are clear.
- **If the producer returned CONCERNS**: surface them via `AskUserQuestion`/
  `clarify`:
  - `[A] Proceed with adjustments — apply the producer's recommendations`
  - `[B] Revise scope — I'll adjust the feature description and re-run`
  - `[C] Escalate to creative-director — let the director make the call`
- **If the producer returned BLOCKED**: report the blockers, surface the
  producer's recommended next actions, and present:
  - `[A] Address blockers first, then re-run /feature-request`
  - `[B] Cancel — defer this feature`
- **If the producer escalated to creative-director** (producer unavailable):
  note the interim coordinator and present their recommendation.

---

## Phase 3: Verify

**For Direct Delegation (Simple)**: The domain agent has provided a task
breakdown with acceptance criteria. Present the breakdown to the user and
ask them to confirm the acceptance criteria are understood and acceptable
before proceeding to implementation.

**For Producer Delegation (Complex)**: Review the producer's verification
report. The producer validates that all acceptance criteria are met.

- **APPROVED**: All acceptance criteria met. Present the producer's sign-off.
- **CONCERNS**: Surface to user with options to resolve or accept.
- **BLOCKED**: Explain what remains and recommend next steps.

---

## Phase 4: Output

Present a concise summary:

```markdown
## Feature Request Processed

**Request**: [feature description]
**Routing**: [Direct Delegation → [agent name] / Producer-led → producer]
**Verdict**: [APPROVED / CONCERNS / BLOCKED]

**Epics/Stories**:
- [Epic: ...] → [N] stories, acceptance criteria: [...]
- [Epic: ...] → [N] stories, acceptance criteria: [...]

**Domain agents involved**: [list of agents spawned]
**Verification**: [summary of acceptance criteria validation]
**Escalation path**: [producer / creative-director (interim) / direct]
```

Verdict: **COMPLETE** — feature request has been processed; epics/stories
and acceptance criteria are defined and assigned.

Verdict: **BLOCKED** — [reason]. Recommended: [resolve blocker] and re-run.

Verdict: **UPGRADED** — a simple request was identified as needing cross-domain
coordination. Re-run `/feature-request` to route through the producer.

---

## Next Steps

- `/create-epics` — if epics were identified that need formal epic files
- `/create-stories [epic-slug]` — to break epics into implementable story files
- `/sprint-plan new` — to schedule the work into a sprint
- `/scope-check` — to verify no scope creep against the original intent