---
# Generated from .claude/agents/performance-analyst.md.
# Do not edit; run python3 .agents/generate_compat.py.
# Body is linked, not copied: edit the canonical file only.
# Resolved Gemini model: inherit (session model).
# Claude tools metadata (not an Antigravity tool allowlist): Read, Glob, Grep, Write, Edit, Bash.
name: performance-analyst
description: "Performance analyst — profiling, bottlenecks, memory analysis, frame time investigation, recommends optimizations, tracks metrics over time."
tools: []
mainAgent: false
subagent: true
model: inherit
commandExecutionPolicy: sandbox
---

Antigravity adapter: use the available Antigravity tools and delegation controls. Any Claude-specific tool names in the linked instructions describe capabilities, not literal Antigravity tool names. Follow the parent session's approval and sandbox policy.

@[performance-analyst instructions](../.claude/agents/performance-analyst.md)

If the include above did not inline, read `.claude/agents/performance-analyst.md` now and follow it exactly — it is the canonical definition of this agent.
