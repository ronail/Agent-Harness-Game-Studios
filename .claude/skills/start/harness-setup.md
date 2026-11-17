# Harness setup (Hermes, Codex, Antigravity)

Loaded by `/start hermes`, `/start codex` and `/start antigravity`. Run only the phase for the harness named.

## Phase 3d: Configure Hermes Subagent Routing for Agent Roles

**Only applicable when the `hermes` argument is provided.** This phase is
skipped if the argument is omitted or if `claude` is explicitly provided.

Hermes resolves a subagent's model from the `delegation` section of the active
profile's `config.yaml`, and `delegation.backend` picks how each task is routed:

| `delegation.backend` | Per-task parameter | Behaviour |
|----------------------|--------------------|-----------|
| `profile_routes` | `profile` | The agent runs each child as one of your Hermes profiles — that profile's model, credentials, pool, skills and `SOUL.md`. |
| `model_map` | `option` | The agent picks a named model route per task, from routes you define. |
| `default` | none | Every child runs on `delegation.model` / `delegation.provider`, else the parent's model. |

`profile_routes` and `model_map` come from the official `advanced-delegation`
plugin, which must be installed in the profile that delegates (plugins are per
profile; it needs Hermes 0.22.5 or newer). Backend settings live under
`delegation.backends.<backend name>`, never beside the core `delegation` keys.
While either plugin mode is active, `delegation.model` / `delegation.provider`
are inactive. A selected backend that is missing or cannot run makes
`delegate_task` fail closed with an error naming the backend and the fix — it
never silently falls back to `default`.

**Profile routes are the default choice for this repository.** The studio already
models capability as a per-role tier, and a Hermes profile is the unit that
carries a model, its credentials and its persona — so the role → profile mapping
stays the thing this project keeps, and `profile_routes` is what makes it
enforceable per task. Only fall back to `model_map` when the profiles on the
machine do not line up with the studio's roles.

Detect this silently before asking anything:

- `command -v hermes` and `hermes --version`. If Hermes is absent, say: "Hermes
  not detected. Model resolution will use the agent definitions' `model` fields
  directly." and continue to Phase 3b. If it is older than 0.22.5, say so and
  treat both plugin modes as unavailable.
- `hermes profile list` — profiles and the model each one runs.
- `HERMES_PROFILE=<profile> hermes config get delegation.backend` — the active
  backend (`default` when unset).
- `HERMES_PROFILE=<profile> hermes plugins list` — whether
  `advanced-delegation` is installed in that profile, and whether it is enabled.
- `HERMES_PROFILE=<profile> hermes delegation config --show` — the current mode
  and its routes, when the plugin is installed.
- Roles in use: `grep -h '^model:' .claude/agents/*.md | sort | uniq -c`. The
  frontmatter `model:` value is the shared tier label (`haiku`, `sonnet`,
  `opus`). Under profile routes it is no longer the routing key — the profile is
   — so keep it as the intent recorded in each agent definition.

**If the argument is omitted or `claude` is provided** (Claude mode): Proceed
directly to Phase 3b without detection. Model resolution uses the agent
definitions' `model` fields directly. If `codex` is provided, skip this phase
and continue to Phase 3e.

Check if `production/hermes-profile-mapping.json` already exists.

**If it exists**: Read it and say: "Hermes subagent routing is configured:
strategy `[strategy]`, backend `[backend]`, routes `[route summary]`." — then
proceed to Phase 3b. Do not ask again. A file with no `schemaVersion` key is a
legacy profile mapping (`{"agent-name": "profile-name"}`): report it as the
profile strategy and leave it unchanged.

**If it does not exist** and the `hermes` argument was provided, use
`AskUserQuestion`, `request_user_input` or `clarify`:

- **Prompt**: "How should Hermes choose the model for a subagent?"
- **Options**:
  - `Profile per subagent (recommended)` — `delegation.backend: profile_routes`:
    the agent picks a Hermes profile per task, and that profile's model runs the
    child.
  - `Named model routes` — `delegation.backend: model_map`: the agent picks a
    named provider/model route per task.
  - `One model for all subagents` — `delegation.backend: default` with
    `delegation.model`; no plugin required.
  - `Skip for now` — I'll configure this later.

Create the `production/` directory if it does not exist.

If `profile_routes` or `model_map` was chosen and `advanced-delegation` is
missing from `hermes plugins list`, say: "That mode needs the official
`advanced-delegation` plugin, installed in the profile that delegates:
`hermes plugins install advanced-delegation`, then `hermes plugins enable
advanced-delegation` if it lands disabled. Nothing routes on it until the plugin
is there — `delegate_task` fails closed while it is missing." Continue anyway;
the config is written and takes effect once the plugin is installed.

### If "Profile per subagent":

1. Offer the assignment shape:
   - `Auto-assign by tier` — reuse any profile whose name matches a tier or a
     studio role, otherwise map every role to the active profile. Fastest, and
     fine for a first pass.
   - `Assign each role` — go through all agents and pick a profile for each.
   - `One profile for every role` — every role runs as one profile.
2. For `Assign each role`, walk `.claude/agents/*.md` sorted by name. Prompt:
   "Which Hermes profile should `<agent-name>` (tier: `<model-tier>`) run as?"
   Present the discovered profiles as options, with the profile name and the
   model it runs shown. Record the choice.
3. Group the assignments by profile. Each distinct profile becomes one entry in
   `delegation.backends.profile_routes.profiles`, and its description names the
   studio roles it serves plus what that work is — that description is the only
   thing the agent sees when it picks.
4. Ask for the default profile (or `No default`). A task that picks nothing runs
   on the default; with none set it runs on the main agent's model.

Write `production/hermes-delegation.yaml`:

```yaml
# Paste into ~/.hermes/profiles/<profile>/config.yaml, or run
# `hermes delegation config` and edit the profile list there instead.
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
  # max_spawn_depth: 2          # only when nested orchestration was selected
  # worktree_isolation: true    # only when worktree isolation was selected
```

Say explicitly: "Listing a profile lets this profile's subagents use that
profile's credentials, credential pool, `SOUL.md` and terminal policy. Only list
profiles whose keys and terminal access you are happy to share."

Also state the honest limitation: in `profile_routes` mode the agent picks the
profile per task from the names and descriptions, so the recorded role → profile
map is the plan the descriptions encode — it is not a hard binding per role.

### If "Named model routes":

Ask once per tier found in the detection step:

- **Prompt**: "What should the `<tier>` route use? (`<count>` agent roles carry
  this tier)"
- **Options**:
  - `Pin a provider and model` — ask for the provider and the model id. Never
    invent a model id: reuse one from `hermes profile list` or ask.
  - `Skip this route` — leave it out of the table.
  - `Rename it` — the route name is what the agent picks on. It must match
    `^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$`.

Then ask which tier should be the default route, offering the tier with the most
agents first.

Write `production/hermes-delegation.yaml`:

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
  # max_spawn_depth: 2          # only when nested orchestration was selected
  # worktree_isolation: true    # only when worktree isolation was selected
```

Only the route names and descriptions reach the model, never the provider, model
id or key. `reasoning_effort` and `service_tier` are optional per route; a
`service_tier` the route does not offer refuses that task rather than running it
anyway. The agent chooses the route per task, so the frontmatter tier is guidance
carried by the descriptions and `default` — it is not enforced either.

### If "One model for all subagents":

- Ask for the provider and model, or `Inherit the parent's model`.
- Write `production/hermes-delegation.yaml` with `backend: default` and, unless
  inheriting, `model:` / `provider:`.

### Studio delegation limits (ask in every branch that writes config)

Ask once, before writing the file — multi-select:

- **Prompt**: "Two delegation limits matter for a studio hierarchy. Which should
  I set?"
- **Options**:
  - `Nested orchestration` — `max_spawn_depth: 2`, so a director's subagent
    (spawned with `role="orchestrator"`) can spawn its own leads and
    specialists. At the default of 1, `role="orchestrator"` is a no-op.
  - `Worktree isolation` — `worktree_isolation: true`: each child gets its own
    git worktree, so parallel implementers cannot collide on the same files.
  - `Neither` — Keep flat delegation in a shared workspace (the default).

Warn before enabling nested orchestration: each level multiplies spend, and a
depth-2 tree at `max_concurrent_children` 10 can reach 100 concurrent children.
Never raise `max_concurrent_children` from this workflow without being asked.

### Write the routing record

In every branch that writes config, write
`production/hermes-profile-mapping.json`:

```json
{
  "schemaVersion": 2,
  "harness": "hermes",
  "profile": "<active profile>",
  "delegation": {
    "strategy": "profile_routes",
    "backend": "profile_routes",
    "parameter": "profile",
    "profiles": [
      {
        "name": "<profile>",
        "description": "Producer, creative-director, technical-director: phase gates, review, scheduling.",
        "roles": ["producer", "creative-director", "technical-director"]
      }
    ],
    "default": "<profile>"
  },
  "roles": {
    "<agent-name>": {"profile": "<profile>", "tier": "<tier>"}
  }
}
```

In the `model_map` branch use `"strategy": "model_map"`, `"parameter": "option"`
and a `routes` object (`{"haiku": {"provider": ..., "model": ...}, ...}`) instead
of `profiles`; every role then records `{"tier": "<tier>"}`. In the single-model
branch use `"strategy": "default"` with the chosen route and no `profiles` or
`routes`. Record every agent from `.claude/agents/*.md` in `roles` rather than
leaving the mapping implicit, so a later frontmatter edit surfaces as a diff
instead of silently changing intent.

Say: "Wrote `production/hermes-delegation.yaml` and
`production/hermes-profile-mapping.json`. Either paste the YAML into
`~/.hermes/profiles/<profile>/config.yaml`, or run `hermes delegation config` and
edit the routes there. Route changes apply to new sessions; in a running chat
`/delegation profile_routes --now` saves the mode and rebuilds that chat's tools
(one prompt-cache break), while `/delegation profile_routes` alone saves it for
the next session."

### If "Skip for now":

- Say: "You can configure Hermes subagent routing anytime by running
  `/start hermes` again, by running `hermes delegation config`, or by editing
  the `delegation` section of `~/.hermes/profiles/<name>/config.yaml`."
- Proceed to Phase 3b.

---

## Phase 3e: Configure Codex Model Setup

**Only applicable when the `codex` argument is provided.** This phase is
skipped if the argument is omitted or if `claude` or `hermes` is explicitly
provided.

Use `Bash` to check whether the Codex CLI is installed (`command -v codex`). If
it is not installed, say: "Codex CLI not detected. Install it from
https://developers.openai.com/codex/cli, then run `/start codex` again to
configure model selection." Continue to the configuration check so the user
can still review the project files.

Read `.codex/config.toml` and confirm that the project-local Codex
configuration exists. If it is missing, say:
"No project-local Codex configuration was found. Add `.codex/config.toml` or
continue with your existing Codex user configuration."

Read `.codex/agent-models.toml` as well. This file is required for spawning
studio agents because `.codex/config.toml` contains only the project-wide
fallback model. If it is missing, say:
"No Codex agent model map was found. Add `.codex/agent-models.toml` before
spawning studio agents so their model tiers resolve explicitly."

If the file exists, explain the shared model-tier mapping and the corresponding
Codex model:

| Shared tier | Codex model |
|-------------|-------------|
| Haiku | `gpt-6-luna` |
| Sonnet | `gpt-6.1-terra` |
| Opus | `gpt-6.1-sol` |

The standard tier is the project default. Use `AskUserQuestion`, `request_user_input` or `clarify` to
ask:

- **Prompt**: "Which Codex model tier would you like to use for this session?"
- **Options**:
  - `Fast` — Use `gpt-6-luna` for quick status checks and simple lookups.
  - `Standard (recommended)` — Use `gpt-6.1-terra` for implementation and design work.
  - `Deep` — Use `gpt-6.1-sol` for multi-document synthesis and phase gates.
  - `Keep current setting` — Leave the active Codex model unchanged.

After the user selects a tier, show its corresponding model from the table
above. If they choose `Keep current setting`, say: "Your current Codex model
setting will remain active." Do not change the user's global Codex
configuration from this skill.

### Codex agent spawn rule

When Codex creates a game-studio subagent, it must:

1. Read the target definition in `.claude/agents/<agent-name>.md`.
2. Read its YAML frontmatter `model` field. Treat an omitted field as `sonnet`.
3. Resolve that tier through `.codex/agent-models.toml`.
4. Pass the resolved model explicitly on the subagent or child-task request.

For example, `producer`, `creative-director`, and `technical-director` use
`model: opus`, so Codex must spawn them with `gpt-6.1-sol`; the project-wide
Sonnet default must not silently replace that selection. The model mapping does
not replace the original agent or skill instructions: read and follow those
references as part of the same spawn.

---

## Phase 3f: Configure Antigravity Model Setup

**Only applicable when the `antigravity` argument is provided.** This phase is
skipped if the argument is omitted or if `claude`, `codex`, or `hermes` is
explicitly provided.

Use `Bash` to check whether the Antigravity CLI is installed
(`command -v agy`). If it is not installed, say: "Antigravity CLI not
detected. Install the Antigravity App or CLI from
https://antigravity.google/docs, then run `/start antigravity` again to
verify the setup." Continue to the configuration check so the user can
still review the project files.

Read `.agents/agent-models.toml` and confirm that the Antigravity model
map exists. If it is missing, say: "No Antigravity agent model map was
found. Add `.agents/agent-models.toml` before spawning studio agents so
their model tiers resolve explicitly."

Verify the generated custom agents: `.agents/agents/*.md` is gitignored
and generated on demand — run `python3 .agents/generate_compat.py` to
create it (ask for approval first if it does not exist), then count
`.agents/agents/*.md` and compare with `.claude/agents/*.md`. If
`python3 .agents/generate_compat.py --check` reports stale files, ask for
approval to regenerate them.
Verify `.agents/skills` resolves to `.claude/skills` (Antigravity's
workspace skill discovery path).
Verify hooks: `.agents/hooks.json` exists and its scripts are executable
(`.agents/hooks/session-start.sh`, `.agents/hooks/pre-tool-use.sh`).
Antigravity runs hooks from `.agents/hooks.json`, not from
`.claude/settings.json`.

If the files exist, explain the shared model-tier mapping and the
corresponding Antigravity tier and Gemini model:

| Shared tier | Antigravity tier | Gemini model |
|-------------|------------------|--------------|
| Haiku | `flash` | `gemini-3.5-flash-lite` |
| Sonnet | `pro` | `gemini-3.1-pro-preview` |
| Opus | `pro` | `gemini-4-argon` |
| Inherit | `inherit` | (session model) |

Antigravity subagent frontmatter only accepts `inherit`, `flash`, or
`pro` — never write a Gemini model ID into an agent's `model:` field.
The resolved Gemini model from `.agents/agent-models.toml` is passed
explicitly on the subagent or child-task request when the harness allows
it. Do not change the user's global Antigravity configuration from this
skill.

### Antigravity agent spawn rule

When Antigravity creates a game-studio subagent, it must:

1. Read the target definition in `.agents/agents/<agent-name>.md`.
2. Read its YAML frontmatter `model` field (`inherit`, `flash`, or `pro`).
3. Resolve that tier through `.agents/agent-models.toml`.
4. Pass the resolved Gemini model explicitly on the subagent or
   child-task request when the harness allows it.

The model mapping does not replace the original agent or skill
instructions: read and follow those references as part of the same spawn.

---

