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
| `model: haiku` | `gpt-5.6-luna` |
| `model: sonnet` or omitted | `gpt-5.6-terra` |
| `model: opus` | `gpt-5.6-sol` |

Example: `producer`, `creative-director`, and `technical-director` declare
`model: opus`, so a Codex-spawned instance of any of them must receive
`gpt-5.6-sol` explicitly.

Before spawning, also read any original skill referenced by the agent or
orchestration workflow. The Codex model mapping changes execution selection;
it does not replace the original skill or agent instructions.

## Feature Request & Bug Report Handling Protocol

Every feature request or bug report follows a **3-phase protocol**:

1. **Digest & Breakdown (Producer)**: The `producer` agent reads and decomposes the request into tasks with acceptance criteria.
2. **Coordinate & Handle**: The producer delegates tasks to responsible domain agents. Agents must not begin until assigned.
3. **Verify**: The producer (or originating director) verifies all acceptance criteria are met and signs off.

**Escalation**: If the producer is unavailable, `creative-director` (features) or `technical-director` (bugs) may act as interim coordinator, re-delegating to the producer when available.
