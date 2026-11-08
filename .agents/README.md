# Antigravity Harness

Google Antigravity (App and CLI / `agy`) discovers workspace customizations
from this `.agents/` folder plus root `AGENTS.md` / `GEMINI.md`. The Claude
files under `.claude/` remain the canonical source; this folder is the
Antigravity compat layer, mirroring `.codex/`.

## Layout

| Path | Source |
|---|---|
| `skills/` | Symlink to `../.claude/skills/` (76 skills) — Antigravity's workspace skill discovery path. No generation needed. |
| `agents/<name>.md` | **Generated on demand** (gitignored) from `.claude/agents/<name>.md` by `generate_compat.py`, run by `/start antigravity`. Frontmatter is transformed; the body is linked via `@[name instructions](../.claude/agents/<name>.md)`, never copied — edit the canonical file only. |
| `hooks.json` + `hooks/*.sh` | Antigravity hook wiring + adapters (see Hooks below). Committed. |
| `rules/studio.md` | Hand-authored `model_decision` rule pointing at the canonical coordination docs. |
| `agent-models.toml` | Shared tier → Gemini model mapping. |
| `generate_compat.py` | The generator. |
| `test_generate_compat.py` / `test_hooks.sh` | Generator + hook adapter tests. |

## Regenerating

`agents/` is gitignored, so wrappers are created by `/start antigravity`
(or manually):

```bash
python3 .agents/generate_compat.py          # generate into .agents/agents/
python3 .agents/generate_compat.py --check  # verify local wrappers match generator
python3 .agents/test_generate_compat.py -v  # unit tests
bash .agents/test_hooks.sh                  # hook adapter tests
```

Editing `.claude/agents/*.md` bodies needs no regeneration (bodies are
linked); only frontmatter changes (name/description/tier) require it.

## Hooks

Antigravity loads hooks from `.agents/hooks.json` (not
`.claude/settings.json`). Its hook contract differs from Claude Code's —
stdin is `{toolCall:{name,args}, workspacePaths}`, stdout must be JSON
(`{"decision":"allow"|"deny"}` for PreToolUse, `{"injectSteps":[...]}` for
SessionStart), and empty/malformed PreToolUse output fails closed — so
Claude hook scripts can't be wired directly. The adapters in
`hooks/*.sh` translate both ways and reuse the canonical scripts in
`.claude/hooks/` + `.codex/hooks/guard-command.sh`:

| Antigravity event | Adapter | Claude scripts reused |
|---|---|---|
| SessionStart | `hooks/session-start.sh` | `session-start.sh`, `detect-gaps.sh` → `injectSteps` |
| PreToolUse (`run_command`) | `hooks/pre-tool-use.sh` | `guard-command.sh`, `validate-commit.sh`, `validate-push.sh` (exit 2 → `deny`) |
| PreToolUse (write tools) | `hooks/pre-tool-use.sh` | `validate-registry.sh`, `validate-write.sh` |
| PreToolUse (`view_file`) | `hooks/pre-tool-use.sh` | `validate-read.sh` |
| PostToolUse (write tools) | `hooks/post-tool-use.sh` | `validate-assets.sh`, `validate-skill-change.sh` (always `{}` — PostToolUse can't gate) |
| Stop | `hooks/stop.sh` | `session-stop.sh` (always allows stop) |

Not covered — Antigravity has no equivalent events: `SubagentStart`,
`SubagentStop`, `PreCompact`, `Notification`. Agent lifecycle logging
(`log-agent.sh`) and compaction checkpointing (`pre-compact.sh`) therefore
don't run under Antigravity; the collaboration protocol in `CLAUDE.md`
still governs agent behavior.

## Model mapping

Antigravity subagent frontmatter only accepts `model: inherit|flash|pro`.
The shared Claude tiers resolve through `agent-models.toml`:

| Shared tier | Antigravity tier | Gemini model |
|-------------|------------------|--------------|
| Haiku | `flash` | `gemini-3.5-flash-lite` |
| Sonnet | `flash` | `gemini-3.8-flash` |
| Opus | `pro` | `gemini-4-argon` |
| Inherit | `inherit` | (session model) |

Never write a Gemini model ID into an agent's `model:` field — pass the
resolved ID explicitly on the spawn request. Before bumping the mapping,
re-verify against <https://aistudio.google.com/docs/models> and update the
"last verified" date in `agent-models.toml`.

Generated agents ship with `tools: []` (Antigravity's default tool set).
Claude tool names (`Read`, `Glob`, …) are preserved only as a metadata
comment — copying them into Antigravity's `tools:` list can hang the
subagent, because Antigravity tool names differ (`view_file`,
`grep_search`, `run_command`, …).

## Docs

- [Customization discovery](https://antigravity.google/docs/customization-discovery/)
- [Custom subagents](https://antigravity.google/docs/subagents)
- [Agent skills](https://antigravity.google/docs/skills/)
- [Rules](https://antigravity.google/docs/rules)
- [Hooks](https://antigravity.google/docs/hooks)
- Onboarding: `/start antigravity`
