---
# Generated from .claude/agents/ue-blueprint-specialist.md.
# Do not edit; run python3 .agents/generate_compat.py.
# Body is linked, not copied: edit the canonical file only.
# Resolved Gemini model: gemini-3.8-flash (tier: sonnet).
# Claude tools metadata (not an Antigravity tool allowlist): Read, Glob, Grep, Write, Edit.
name: ue-blueprint-specialist
description: "Blueprint architecture and Blueprint/C++ boundary — optimization, maintainable graphs. Prevents Blueprint spaghetti, enforces clean BP patterns."
tools: []
mainAgent: false
subagent: true
model: flash
commandExecutionPolicy: sandbox
---

Antigravity adapter: use the available Antigravity tools and delegation controls. Any Claude-specific tool names in the linked instructions describe capabilities, not literal Antigravity tool names. Follow the parent session's approval and sandbox policy.

@[ue-blueprint-specialist instructions](../.claude/agents/ue-blueprint-specialist.md)

If the include above did not inline, read `.claude/agents/ue-blueprint-specialist.md` now and follow it exactly — it is the canonical definition of this agent.
