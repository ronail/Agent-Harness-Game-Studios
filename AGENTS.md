# Agent Harness Game Studios

## Codex studio-agent spawning

When Codex spawns a game-studio agent, use the agent definition in
`.claude/agents/<agent-name>.md` as the source of truth. Read its YAML
frontmatter `model` field and resolve that shared tier through
`.codex/agent-models.toml` before creating the subagent.

Pass the resolved Codex model explicitly on the subagent or child-task request.
Do not rely on the project-wide `model` in `.codex/config.toml` when the agent's
tier is `haiku` or `opus`; that setting is only the fallback for unclassified
work.

| Agent frontmatter | Codex model |
|-------------------|-------------|
| `model: haiku` | `gpt-6-luna` |
| `model: sonnet` or omitted | `gpt-6.1-terra` |
| `model: opus` | `gpt-6.1-sol` |

Example: `producer`, `creative-director`, and `technical-director` declare
`model: opus`, so a Codex-spawned instance of any of them must receive
`gpt-6.1-sol` explicitly.

Before spawning, also read any original skill referenced by the agent or
orchestration workflow. The Codex model mapping changes execution selection;
it does not replace the original skill or agent instructions.

## Antigravity studio-agent spawning

When Antigravity spawns a game-studio agent, use the agent definition in
`.agents/agents/<agent-name>.md` as the source of truth (generated from
`.claude/agents/<agent-name>.md` by `.agents/generate_compat.py`). Read its
YAML frontmatter `model` field (`inherit`, `flash`, or `pro`) and resolve
the shared tier through `.agents/agent-models.toml` before creating the
subagent.

| Agent frontmatter | Antigravity tier | Gemini model |
|-------------------|------------------|--------------|
| `model: flash` (haiku source tier) | `flash` | `gemini-3.5-flash-lite` |
| `model: pro` (sonnet source tier) | `pro` | `gemini-3.1-pro-preview` |
| `model: pro` (opus source tier) | `pro` | `gemini-4-argon` |
| `model: inherit` | `inherit` | (session model) |

Pass the resolved Gemini model explicitly on the subagent or child-task
request when the harness allows it. Do not rely on the session model for
`pro`/`flash` agents. Before spawning, also read any original skill
referenced by the agent or orchestration workflow. The model mapping changes
execution selection; it does not replace the original skill or agent
instructions.

