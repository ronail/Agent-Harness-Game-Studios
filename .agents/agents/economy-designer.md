---
# Generated from .claude/agents/economy-designer.md.
# Do not edit; run python3 .agents/generate_compat.py.
# Body is linked, not copied: edit the canonical file only.
# Resolved Gemini model: inherit (session model).
# Claude tools metadata (not an Antigravity tool allowlist): Read, Glob, Grep, Write, Edit.
name: economy-designer
description: "Resource economies — loot tables, sink/faucet analysis, progression curve calibration, economic balance."
tools: []
mainAgent: false
subagent: true
model: inherit
commandExecutionPolicy: sandbox
---

Antigravity adapter: use the available Antigravity tools and delegation controls. Any Claude-specific tool names in the linked instructions describe capabilities, not literal Antigravity tool names. Follow the parent session's approval and sandbox policy.

@[economy-designer instructions](../.claude/agents/economy-designer.md)

If the include above did not inline, read `.claude/agents/economy-designer.md` now and follow it exactly — it is the canonical definition of this agent.
