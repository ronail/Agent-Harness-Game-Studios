---
# Generated from .claude/agents/release-manager.md.
# Do not edit; run python3 .agents/generate_compat.py.
# Body is linked, not copied: edit the canonical file only.
# Resolved Gemini model: inherit (session model).
# Claude tools metadata (not an Antigravity tool allowlist): Read, Glob, Grep, Write, Edit, Bash.
name: release-manager
description: "Release pipeline — certification checklists, store submissions and page prep, platform requirements, version numbering, release-day coordination."
tools: []
mainAgent: false
subagent: true
model: inherit
commandExecutionPolicy: sandbox
skills:
  - release-checklist
  - changelog
  - patch-notes
---

Antigravity adapter: use the available Antigravity tools and delegation controls. Any Claude-specific tool names in the linked instructions describe capabilities, not literal Antigravity tool names. Follow the parent session's approval and sandbox policy.

@[release-manager instructions](../.claude/agents/release-manager.md)

If the include above did not inline, read `.claude/agents/release-manager.md` now and follow it exactly — it is the canonical definition of this agent.
