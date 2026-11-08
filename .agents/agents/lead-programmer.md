---
# Generated from .claude/agents/lead-programmer.md.
# Do not edit; run python3 .agents/generate_compat.py.
# Body is linked, not copied: edit the canonical file only.
# Resolved Gemini model: gemini-3.8-flash (tier: sonnet).
# Claude tools metadata (not an Antigravity tool allowlist): Read, Glob, Grep, Write, Edit, Bash.
name: lead-programmer
description: "Lead programmer — code-level architecture, coding standards, code review, API design, refactoring strategy, assigning work to specialist programmers."
tools: []
mainAgent: false
subagent: true
model: flash
commandExecutionPolicy: sandbox
skills:
  - tech-debt
---

Antigravity adapter: use the available Antigravity tools and delegation controls. Any Claude-specific tool names in the linked instructions describe capabilities, not literal Antigravity tool names. Follow the parent session's approval and sandbox policy.

@[lead-programmer instructions](../.claude/agents/lead-programmer.md)

If the include above did not inline, read `.claude/agents/lead-programmer.md` now and follow it exactly — it is the canonical definition of this agent.
