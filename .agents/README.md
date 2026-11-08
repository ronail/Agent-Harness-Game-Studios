# Antigravity Harness

Google Antigravity (App and CLI / `agy`) discovers workspace customizations
from this `.agents/` folder plus root `AGENTS.md` / `GEMINI.md`. The Claude
files under `.claude/` remain the canonical source; this folder is the
Antigravity compat layer, mirroring `.codex/`.

## Layout

| Path | Source |
|---|---|
| `skills/` | Symlink to `../.claude/skills/` (76 skills) — Antigravity's workspace skill discovery path. No generation needed. |
| `agents/<name>.md` | **Generated** from `.claude/agents/<name>.md` by `generate_compat.py` (49 custom subagents). Do not edit by hand. |
| `rules/studio.md` | Hand-authored `model_decision` rule pointing at the canonical coordination docs. |
| `agent-models.toml` | Shared tier → Gemini model mapping. |
| `generate_compat.py` | The generator. |
| `test_generate_compat.py` | Generator tests. |

## Regenerating

After editing `.claude/agents/*.md`, regenerate:

```bash
python3 .agents/generate_compat.py          # regenerate
python3 .agents/generate_compat.py --check  # CI: exit 1 if stale
python3 .agents/test_generate_compat.py -v  # unit tests
```

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
- Onboarding: `/start antigravity`
