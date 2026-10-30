# Game Studio Agent Architecture -- Quick Start Guide

## What Is This?

This is a complete Claude Code agent architecture for game development. It
organizes 49 specialized AI agents into a studio hierarchy that mirrors
real game development teams, with defined responsibilities, delegation
rules, and coordination protocols. It includes engine-specialist agents
for Godot, Unity, and Unreal — each with dedicated sub-specialists for
major engine subsystems. All design agents and templates are grounded in
established game design theory (MDA Framework, Self-Determination Theory,
Flow State, Bartle Player Types). Use whichever engine set matches your project.

## The Default Path: Rigor Minimal

`modes.rigor` defaults to `minimal` (`/start` infers it from what you describe and shows it
before saving; `/settings` changes it any time). At `minimal` the path to code is four steps:

1. `/setup-engine` -- configure the engine
2. `/brainstorm` -- writes the one-page `design/game-brief.md`, in place of the
   concept doc, systems decomposition and per-system GDDs
3. `/create-stories` -- turns the brief's MVP list into stories under
   `production/epics/<slug>/`; the brief's build order is the plan, so there is
   no `/create-epics` or `/sprint-plan`
4. `/dev-story` then `/story-done`, story by story -- `/story-done` names the
   next story, and `/help` knows this route

Nothing at `minimal` runs `/gate-check`, so `project.stage` stays at Concept.
Every skill still runs at any tier. The trade: no GDDs catch design problems
before code. Raise rigor with `/settings` when the game outgrows the brief;
`standard` and `full` are the longer pipelines under
[First Steps for a New Project](#first-steps-for-a-new-project).

## How to Use

### 1. Understand the Hierarchy

There are three tiers of agents:

- **Tier 1 — Directors** who make high-level decisions (they run on Opus)
  - `creative-director` -- vision and creative conflict resolution
  - `technical-director` -- architecture and technology decisions
  - `producer` -- scheduling, coordination, and risk management

- **Tier 2 — Department leads** who own their domain
  - `game-designer`, `lead-programmer`, `art-director`, `audio-director`,
    `narrative-director`, `qa-lead`, `release-manager`, `localization-lead`

- **Tier 3 — Specialists** who execute within their domain
  - Designers, programmers, artists, writers, testers, engineers

The tiers are seniority of role. Most agents run on your session's model; the
agent file's own `model:` line says which do not
(`.claude/docs/model-tiers.md`).

### 2. Pick the Right Agent for the Job

Ask yourself: "What department would handle this in a real studio?"

| I need to... | Use this agent |
|-------------|---------------|
| Design a new mechanic | `game-designer` |
| Write combat code | `gameplay-programmer` |
| Create a shader | `technical-artist` |
| Write dialogue | `writer` |
| Plan the next sprint | `producer` |
| Review code quality | `lead-programmer` |
| Write test cases | `qa-tester` |
| Design a level | `level-designer` |
| Fix a performance problem | `performance-analyst` |
| Set up CI/CD | `devops-engineer` |
| Design a loot table | `economy-designer` |
| Resolve a creative conflict | `creative-director` |
| Make an architecture decision | `technical-director` |
| Manage a release | `release-manager` |
| Prepare strings for translation | `localization-lead` |
| Test a mechanic idea quickly | `prototyper` |
| Review code for security issues | `security-engineer` |
| Check accessibility compliance | `accessibility-specialist` |
| Get Unreal Engine advice | `unreal-specialist` |
| Get Unity advice | `unity-specialist` |
| Get Godot advice | `godot-specialist` |
| Design GAS abilities/effects | `ue-gas-specialist` |
| Define BP/C++ boundaries | `ue-blueprint-specialist` |
| Implement UE replication | `ue-replication-specialist` |
| Build UMG/CommonUI widgets | `ue-umg-specialist` |
| Design DOTS/ECS architecture | `unity-dots-specialist` |
| Write Unity shaders/VFX | `unity-shader-specialist` |
| Manage Addressable assets | `unity-addressables-specialist` |
| Build UI Toolkit/UGUI screens | `unity-ui-specialist` |
| Write idiomatic GDScript | `godot-gdscript-specialist` |
| Write Godot C# code | `godot-csharp-specialist` |
| Create Godot shaders | `godot-shader-specialist` |
| Build GDExtension modules | `godot-gdextension-specialist` |
| Plan live events and seasons | `live-ops-designer` |
| Write patch notes for players | `community-manager` |
| Brainstorm a new game idea | Use `/brainstorm` skill |

### 3. Use Slash Commands for Common Tasks

| Command | What it does |
|---------|-------------|
| `/start` | First-time onboarding — asks where you are, guides you to the right workflow |
| `/help` | Context-aware "what do I do next?" — reads your current phase and artifacts |
| `/project-stage-detect` | Analyze project state, detect stage, identify gaps |
| `/setup-engine` | Configure engine + version, populate reference docs |
| `/adopt` | Brownfield audit and migration plan for existing projects |
| `/brainstorm` | Guided game concept ideation from scratch |
| `/map-systems` | Decompose concept into systems, map dependencies, guide per-system GDDs |
| `/design-system` | Guided, section-by-section GDD authoring for a single game system |
| `/quick-design` | Lightweight spec for small changes — tuning, tweaks, minor additions |
| `/review-all-gdds` | Cross-GDD consistency and game design theory review |
| `/propagate-design-change` | Find ADRs and stories affected by a GDD change |
| `/art-bible` | Guided, section-by-section Art Bible authoring — creates visual identity spec before asset production |
| `/asset-spec` | Generate per-asset visual specifications and AI generation prompts from GDDs or character profiles |
| `/ux-design` | Author UX specs (screen/flow, HUD, interaction patterns) |
| `/ux-review` | Validate UX specs for accessibility and GDD alignment |
| `/create-architecture` | Master architecture document for the game |
| `/architecture-decision` | Creates an ADR |
| `/architecture-review` | Validate all ADRs, dependency ordering, GDD traceability — writes the index to `docs/architecture/requirements-traceability.md` |
| `/create-control-manifest` | Flat programmer rules sheet from Accepted ADRs |
| `/create-epics` | Translate GDDs + ADRs into epics (one per architectural module) |
| `/create-stories` | Break a single epic into implementable story files |
| `/dev-story` | Read a story and implement it — routes to the correct programmer agent |
| `/sprint-plan` | Creates or updates sprint plans |
| `/sprint-status` | Quick 30-line sprint snapshot |
| `/story-readiness` | Validate a story is implementation-ready before pickup |
| `/story-done` | End-of-story completion review — verifies acceptance criteria |
| `/estimate` | Produces structured effort estimates |
| `/design-review` | Reviews a design document |
| `/code-review` | Reviews code for quality and architecture |
| `/balance-check` | Analyzes game balance data |
| `/asset-audit` | Audits assets for compliance |
| `/content-audit` | GDD-specified content vs. implemented — find gaps |
| `/scope-check` | Detect scope creep against plan |
| `/perf-profile` | Performance profiling and bottleneck ID |
| `/tech-debt` | Scan, track, and prioritize tech debt |
| `/gate-check` | Validate phase readiness (PASS/CONCERNS/NOT ASSESSED/FAIL) |
| `/consistency-check` | Scan all GDDs for cross-document inconsistencies (conflicting stats, names, rules) |
| `/security-audit` | Audit for security vulnerabilities: save tampering, cheat vectors, network exploits, data exposure |
| `/reverse-document` | Generate design/architecture docs from existing code |
| `/milestone-review` | Reviews milestone progress |
| `/retrospective` | Runs sprint/milestone retrospective |
| `/feature-request` | Tiered: simple → domain agent; complex → producer (3-phase) |
| `/bug-report` | Structured bug report creation |
| `/playtest-report` | Creates or analyzes playtest feedback |
| `/onboard` | Generates onboarding docs for a role |
| `/release-checklist` | Validates pre-release checklist |
| `/launch-checklist` | Complete launch readiness validation |
| `/changelog` | Generates changelog from git history |
| `/patch-notes` | Generate player-facing patch notes |
| `/hotfix` | Emergency fix with audit trail |
| `/day-one-patch` | Prepare a focused day-one patch for known issues discovered after gold master |
| `/prototype` | Concept prototype — validate core idea before writing GDDs (Phase 1) |
| `/vertical-slice` | Production-quality end-to-end build — validate full game loop (Phase 4) |
| `/localize` | Localization scan, extract, validate |
| `/team-combat` | Orchestrate full combat team pipeline |
| `/team-narrative` | Orchestrate full narrative team pipeline |
| `/team-ui` | Orchestrate full UI team pipeline |
| `/team-release` | Orchestrate full release team pipeline |
| `/team-polish` | Orchestrate full polish team pipeline |
| `/team-audio` | Orchestrate full audio team pipeline |
| `/team-level` | Orchestrate full level creation pipeline |
| `/team-live-ops` | Orchestrate live-ops team for seasons, events, and post-launch content |
| `/team-qa` | Orchestrate full QA team cycle — test plan, test cases, smoke check, sign-off |
| `/qa-plan` | Generate a QA test plan for a sprint or feature |
| `/bug-triage` | Re-prioritize open bugs, assign to sprints, surface systemic trends |
| `/smoke-check` | Run critical path smoke test gate before QA hand-off (PASS/FAIL) |
| `/soak-test` | Generate a soak test protocol for extended play sessions |
| `/regression-suite` | Map coverage to GDD critical paths, flag gaps, maintain regression suite |
| `/test-setup` | Scaffold test framework + CI pipeline for the project's engine (run once) |
| `/test-helpers` | Generate engine-specific test helper libraries and factory functions |
| `/test-flakiness` | Detect flaky tests from CI history, flag for quarantine or fix |
| `/test-evidence-review` | Quality review of test files and manual evidence — ADEQUATE/INCOMPLETE/MISSING |
| `/skill-test` | Validate skill files for compliance and correctness (static / spec / audit) |
| `/skill-improve` | Improve a skill using a test-fix-retest loop — diagnose, propose fix, rewrite, verify |

### 4. Use Templates for New Documents

Templates are in `.claude/docs/templates/`:

- `game-design-document.md` -- for new mechanics and systems
- `architecture-decision-record.md` -- for technical decisions
- `architecture-traceability.md` -- sample layout for a GDD requirement to ADR to
  story index (`/architecture-review` writes its own index to
  `docs/architecture/requirements-traceability.md`)
- `risk-register-entry.md` -- for new risks
- `narrative-character-sheet.md` -- for new characters
- `test-plan.md` -- for feature test plans
- `sprint-plan.md` -- for sprint planning
- `milestone-definition.md` -- for new milestones
- `level-design-document.md` -- for new levels
- `game-pillars.md` -- for core design pillars
- `art-bible.md` -- for visual style reference
- `technical-design-document.md` -- for per-system technical designs
- `post-mortem.md` -- for project/milestone retrospectives
- `sound-bible.md` -- for audio style reference
- `release-checklist-template.md` -- for platform release checklists
- `changelog-template.md` -- for player-facing patch notes
- `release-notes.md` -- for player-facing release notes
- `incident-response.md` -- for live incident response playbooks
- `game-concept.md` -- for initial game concepts (MDA, SDT, Flow, Bartle)
- `game-brief.md` -- for the one-page brief that replaces the concept doc at `rigor: minimal`
- `pitch-document.md` -- for pitching the game to stakeholders
- `economy-model.md` -- for virtual economy design (sink/faucet model)
- `faction-design.md` -- for faction identity, lore, and gameplay role
- `systems-index.md` -- for systems decomposition and dependency mapping
- `project-stage-report.md` -- for project stage detection output
- `design-doc-from-implementation.md` -- for reverse-documenting existing code into GDDs
- `architecture-doc-from-code.md` -- for reverse-documenting code into architecture docs
- `concept-doc-from-prototype.md` -- for reverse-documenting prototypes into concept docs
- `ux-spec.md` -- for per-screen UX specifications (layout zones, states, events)
- `hud-design.md` -- for whole-game HUD philosophy, zones, and element specs
- `accessibility-requirements.md` -- for project-wide accessibility tier and feature matrix
- `interaction-pattern-library.md` -- for standard UI controls and game-specific patterns
- `player-journey.md` -- for 6-phase emotional arc and retention hooks by time scale
- `difficulty-curve.md` -- for difficulty axes, onboarding ramp, and cross-system interactions
- `test-evidence.md` -- template for recording manual test evidence (screenshots, walkthrough notes)

### 5. Follow the Coordination Rules

1. Work flows down the hierarchy: Directors -> Leads -> Specialists
2. Conflicts escalate up the hierarchy
3. Cross-department work is coordinated by the `producer`
4. Agents do not modify files outside their domain without delegation
5. All decisions are documented

## First Steps for a New Project

**Don't know where to begin?** Run `/start`. It asks where you are and routes
you to the right workflow. No assumptions about your game, engine, or experience level.

The paths below walk the `standard`/`full` pipeline. At `rigor: minimal` (the
default), follow [The Default Path](#the-default-path-rigor-minimal) instead.

If you already know what you need, jump directly to the relevant path:

### Path A: "I have no idea what to build"

1. **Run `/start`** (or `/brainstorm open`) — guided creative exploration:
   what excites you, what you've played, your constraints
   - Generates 3 concepts, helps you pick one, defines core loop and pillars
   - Produces a game concept document and recommends an engine
2. **Set up the engine** — Run `/setup-engine` (uses the brainstorm recommendation)
   - Configures CLAUDE.md, detects knowledge gaps, populates reference docs
   - Writes engine, naming conventions, and performance budgets to `project.yaml`
     (the source of truth), mirrored to `.claude/docs/technical-preferences.md`
   - If the engine version is newer than the LLM's training data, it fetches
     current docs from the web so agents suggest correct APIs
3. **Validate the concept** — Run `/design-review design/gdd/game-concept.md`
   (or `design/game-brief.md`, if `/brainstorm` wrote the one-page brief)
4. **Prototype the mechanic** — Run `/prototype [core-mechanic]` (1 day at most) to
   test that the core idea is fun before you write GDDs
5. **Decompose into systems** — Run `/map-systems` to map all systems and dependencies
6. **Design each system** — Run `/design-system [system-name]` (or `/map-systems next`)
   to write GDDs in dependency order, informed by the prototype findings
7. **Plan the first sprint** — After architecture and `/vertical-slice`, run `/sprint-plan new`
8. Start building

### Path B: "I know what I want to build"

If you already have a game concept and engine choice:

1. **Set up the engine** — Run `/setup-engine [engine] [version]`
   (e.g., `/setup-engine godot 4.7`) — also creates technical preferences
2. **Write the Game Pillars** — delegate to `creative-director`
3. **Decompose into systems** — Run `/map-systems` to enumerate systems and dependencies
4. **Design each system** — Run `/design-system [system-name]` for GDDs in dependency order
5. **Create the initial ADR** — Run `/architecture-decision`
6. **Create the first milestone** in `production/milestones/`
7. **Plan the first sprint** — Run `/sprint-plan new`
8. Start building

### Path C: "I know the game but not the engine"

If you have a concept but don't know which engine fits:

1. **Run `/setup-engine`** with no arguments — it will ask about your game's
   needs (2D/3D, platforms, team size, language preferences) and recommend
   an engine based on your answers
2. Follow Path B from step 2 onward

### Path D: "I have an existing project"

If you have design docs, prototypes, or code already:

1. **Run `/start`** (or `/project-stage-detect`) — analyzes what exists,
   identifies gaps, and recommends next steps
2. **Run `/adopt`** if you have existing GDDs, ADRs, or stories — audits
   internal format compliance and builds a numbered migration plan to fill gaps
   without overwriting your existing work
3. **Configure engine if needed** — Run `/setup-engine` if not yet configured
4. **Validate phase readiness** — Run `/gate-check` to see where you stand
5. **Plan the next sprint** — Run `/sprint-plan new`

## File Structure Reference

```
CLAUDE.md                          -- Master config (read this first, ~80 lines)
project.yaml                       -- Machine-readable project config (engine, modes, stage) — source of truth
.claude/
  settings.json                    -- Claude Code hooks and project settings
  agents/                          -- 49 agent definitions (YAML frontmatter)
  skills/                          -- 76 slash command definitions (YAML frontmatter)
  hooks/                           -- 15 event hooks (.sh, wired by settings.json) + yaml-helper.sh, update-check.sh
  rules/                           -- 14 path-specific rule files
  docs/
    quick-start.md                 -- This file
    technical-preferences.md       -- Legacy fallback for project.yaml config (mirror; see project.yaml at repo root)
    coding-standards.md            -- Coding and design doc standards
    coordination-rules.md          -- Agent coordination rules
    context-management.md          -- Context budgets and compaction instructions
    directory-structure.md         -- Project directory layout
    workflow-catalog.yaml          -- 7-phase pipeline definition (read by /help)
    setup-requirements.md          -- System prerequisites (Git Bash, jq, Python)
    settings-local-template.md     -- Personal settings.local.json guide
    CLAUDE-local-template.md       -- Personal CLAUDE.local.md guide (gitignored overrides)
    templates/                     -- 62 document templates (+ per-section guidance)
```

---

## Optional: Hermes Subagent Routing

When using **Hermes as the harness**, subagent models are resolved from the
`delegation` section of the active profile's
`~/.hermes/profiles/<name>/config.yaml`, not from the `model:` field in
skill/agent frontmatter. The frontmatter values (`haiku` / `sonnet` / `opus`)
stay as the shared tier labels; Codex maps them to GPT models, and Hermes routes
them through the delegation mode you configure.

Run the routing setup during onboarding:

```bash
/start hermes
```

Phase 3d of `/start` detects your profiles, the active `delegation.backend`, and
whether the advanced-delegation plugin is installed, then asks how a subagent
should be routed. It writes a paste-ready `production/hermes-delegation.yaml`
plus `production/hermes-profile-mapping.json` as the recorded plan — the role →
profile map this project has always kept, now backed by a mode that can act on
it.

### Delegation modes

One mode is active at a time:

| `delegation.backend` | Per-task parameter | Behaviour |
|----------------------|--------------------|-----------|
| `profile_routes` (recommended) | `profile` | The agent runs each child as one of your Hermes profiles — that profile's model, credentials, credential pool, skills and `SOUL.md`. |
| `model_map` | `option` | The agent picks a named model route per task, from routes you define. |
| `default` (built in) | none | Every child runs on `delegation.model` / `delegation.provider`, else the parent's model. |

`profile_routes` and `model_map` come from the official **advanced-delegation**
plugin, which needs Hermes 0.22.5 or newer and is installed per profile —
install it in the profile that delegates:

```bash
hermes plugins install advanced-delegation
```

Configure it interactively, or paste the block yourself:

```bash
hermes delegation config          # pick the mode, then edit its routes
hermes delegation config --show   # print the current mode and routes
```

### Profile routes (recommended)

A profile is the unit that already carries a model, its credentials and its
persona, so this is the mode that matches the studio's role → profile model:

```yaml
# ~/.hermes/profiles/<name>/config.yaml
delegation:
  backend: profile_routes
  backends:
    profile_routes:
      profiles:
        - name: <director-profile>
          description: "Producer, creative-director, technical-director: phase gates, review, scheduling."
        - name: <lead-profile>
          description: "Lead programmers and specialists: implementation, refactors, tests."
      default: <lead-profile>
```

Target profiles need nothing installed — they only have to exist
(`hermes profile list`) with a working model. Only the profile names and their
one-line descriptions reach the model.

### Model routes

When the profiles on the machine do not line up with the studio's roles, list
titled provider/model routes instead and let the agent pick per task:

```yaml
delegation:
  backend: model_map
  backends:
    model_map:
      options:
        - name: haiku
          description: "Quick reads and formatting: status checks, lookups, short summaries."
          provider: <provider>
          model: <model>
        - name: sonnet
          description: "Default studio work: implementation, design documents, code review."
          provider: <provider>
          model: <model>
        - name: opus
          description: "Hard synthesis: multi-document analysis, architecture review, phase gates."
          provider: <provider>
          model: <model>
          reasoning_effort: high
      default: sonnet
```

### Rules that apply to both modes

Backend settings live under `delegation.backends.<backend name>`, never beside
the core `delegation` keys.

- **Only names and descriptions reach the model.** The provider, model id,
  endpoint and key are never tool parameters, so the agent cannot invent a route.
  The flip side: the agent chooses the route per task, so the recorded role →
  profile (or role → tier) map is the plan the descriptions encode — not a hard
  per-role binding.
- **`delegation.model` / `delegation.provider` are inactive** while
  `profile_routes` or `model_map` is the active mode. Switching back to
  `default` makes them apply again.
- **Fail closed.** A backend that is selected but missing or unable to run makes
  `delegate_task` return an error naming it and the fix. Hermes never falls back
  to `default` on its own.
- **Profile routes share credentials.** Listing a profile lets this profile's
  subagents use that profile's credentials, credential pool, `SOUL.md` and
  terminal policy — only list profiles you are happy to share that with.
- **The tool schema is cached.** The per-task `profile` / `option` list is built
  when a session starts. `/delegation <mode>` saves the mode for the next session
  (`/new`); `/delegation <mode> --now` also rebuilds the running chat's tools, at
  the cost of one prompt-cache break.

### Studio hierarchy settings

Three `delegation` settings change how studio agents nest or collide. `/start
hermes` asks about the first two; check any of them with
`hermes config get delegation.<key>`.

| Setting | Default | Use it when |
|---------|---------|-------------|
| `max_spawn_depth` | `1` (flat) | `2` lets a director's subagent (spawned with `role="orchestrator"`) spawn its own leads and specialists. |
| `worktree_isolation` | `false` | Parallel implementers edit the same repo and would collide. Each child gets its own git worktree, branched from `HEAD`. |
| `max_concurrent_children` | configurable, `10` in 0.22.x | A wider parallel batch. No hard ceiling; cost is the limit. |

At the default depth, `role="orchestrator"` is a no-op: children are leaves and
stop at one level. Raise `max_spawn_depth` deliberately — each extra level
multiplies spend, and children are where the tokens go.

Backends are ordinary Hermes plugins; see
[Delegation Provider Plugins](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/developer-guide/delegation-provider-plugin.md)
for the interface and
[Subagent Delegation](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/delegation.md)
for the delegation settings themselves.

If you are **not** using Hermes, the `model:` field in each agent/skill definition
is used directly — no changes are needed.

## Optional: Codex Model Setup

When using **Codex as the harness**, the `model:` fields in skill and agent
frontmatter remain the shared `haiku` / `sonnet` / `opus` tier labels. The
project-local `.codex/config.toml` sets the standard GPT model. The tier mapping
is:

| Shared tier | Codex model |
|-------------|-------------|
| Haiku | `gpt-6-luna` |
| Sonnet | `gpt-6.1-terra` |
| Opus | `gpt-6.1-sol` |

The standard tier is the project default. Run `/start codex` during onboarding
to review the mapping and choose a session model.