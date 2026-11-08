---
# Generated from .claude/agents/game-designer.md.
# Do not edit; run python3 .agents/generate_compat.py.
# Body is linked, not copied: edit the canonical file only.
# Resolved Gemini model: inherit (session model).
# Claude tools metadata (not an Antigravity tool allowlist): Read, Glob, Grep, Write, Edit, WebSearch.
name: game-designer
description: "Mechanical and systems design — core loops, progression, combat, economy, player-facing rules. Mechanics-level questions."
tools: []
mainAgent: false
subagent: true
model: inherit
commandExecutionPolicy: sandbox
skills:
  - balance-check
---

Antigravity adapter: use the available Antigravity tools and delegation controls. Any Claude-specific tool names in the linked instructions describe capabilities, not literal Antigravity tool names. Follow the parent session's approval and sandbox policy.

@[game-designer instructions](../.claude/agents/game-designer.md)

If the include above did not inline, read `.claude/agents/game-designer.md` now and follow it exactly — it is the canonical definition of this agent.
