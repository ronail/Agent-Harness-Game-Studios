---
# Generated from .claude/agents/technical-director.md.
# Do not edit; run python3 .agents/generate_compat.py.
# Body is linked, not copied: edit the canonical file only.
# Resolved Gemini model: gemini-4-argon (tier: opus).
# Claude tools metadata (not an Antigravity tool allowlist): Read, Glob, Grep, Write, Edit, Bash, WebSearch.
name: technical-director
description: "High-level technical decisions — engine architecture, technology choices, performance strategy, technical risk, cross-system conflicts."
tools: []
mainAgent: false
subagent: true
model: pro
commandExecutionPolicy: sandbox
---

Antigravity adapter: use the available Antigravity tools and delegation controls. Any Claude-specific tool names in the linked instructions describe capabilities, not literal Antigravity tool names. Follow the parent session's approval and sandbox policy.

@[technical-director instructions](../.claude/agents/technical-director.md)

If the include above did not inline, read `.claude/agents/technical-director.md` now and follow it exactly — it is the canonical definition of this agent.
