#!/usr/bin/env python3
"""Generate Antigravity discovery metadata from the repository's Claude assets.

The Claude files remain the canonical source. This script creates thin
Antigravity custom-agent wrappers under .agents/agents/: correct
Antigravity frontmatter, body linked to the canonical agent file via an
@[label](path) include (with a read-it-yourself fallback). No body is
copied, so the canonical file is the single source of truth.

Antigravity loads workspace customizations from .agents/:
  skills  -> .agents/skills/<name>/SKILL.md  (already a symlink to
             .claude/skills/, so no generation needed)
  agents  -> .agents/agents/<name>.md        (generated here)
  rules   -> .agents/rules/*.md              (hand-authored, see
             .agents/rules/studio.md)

Custom-agent frontmatter only accepts model: inherit|flash|pro, so the
shared Claude tiers resolve through .agents/agent-models.toml:
  opus   -> pro    -> gemini-4-argon
  sonnet -> flash  -> gemini-3.8-flash
  haiku  -> flash  -> gemini-3.5-flash-lite
  inherit/missing -> inherit (session model)
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
CLAUDE_AGENTS_DIR = ROOT / ".claude" / "agents"
AGENTS_OUT_DIR = ROOT / ".agents" / "agents"
MODELS_FILE = ROOT / ".agents" / "agent-models.toml"

TIER_TO_ANTIGRAVITY_MODEL = {
    "opus": "pro",
    "sonnet": "flash",
    "haiku": "flash",
}

TIER_TO_GEMINI = {
    "opus": "gemini-4-argon",
    "sonnet": "gemini-3.8-flash",
    "haiku": "gemini-3.5-flash-lite",
}


def antigravity_model(tier: str | None) -> str:
    """Map a Claude model tier to an Antigravity model value."""
    return TIER_TO_ANTIGRAVITY_MODEL.get(tier or "", "inherit")


def gemini_model(tier: str | None) -> str | None:
    """Resolve a Claude tier to its Gemini model ID, if any."""
    return TIER_TO_GEMINI.get(tier or "")


def split_frontmatter(text: str) -> tuple[dict[str, str], str]:
    """Return simple frontmatter scalars and the Markdown body."""

    if not text.startswith("---\n"):
        raise ValueError("missing frontmatter")
    end = text.find("\n---\n", 4)
    if end < 0:
        raise ValueError("unterminated frontmatter")

    raw_frontmatter = text[4:end]
    body = text[end + len("\n---\n") :]
    values: dict[str, str] = {}
    for line in raw_frontmatter.splitlines():
        match = re.match(r"^([A-Za-z][A-Za-z0-9_-]*):[ \t]*(.*)$", line)
        if not match:
            continue
        key, value = match.groups()
        if value.startswith("|"):
            continue
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] == '"':
            try:
                value = json.loads(value)
            except json.JSONDecodeError:
                value = value[1:-1]
        values[key] = value
    return values, body


def yaml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def parse_skills(value: str) -> list[str]:
    """Parse a Claude `skills:` frontmatter value into a name list."""

    value = value.strip()
    if not value:
        return []
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [item.strip().strip('"').strip("'") for item in inner.split(",")]
    return [value.strip('"').strip("'")]


def parse_toml_tiers(path: Path) -> dict[str, str]:
    """Read [tiers] from agent-models.toml without a TOML dependency."""

    tiers: dict[str, str] = {}
    if not path.exists():
        return tiers
    in_tiers = False
    for line in path.read_text().splitlines():
        stripped = line.strip()
        if stripped.startswith("["):
            in_tiers = stripped == "[tiers]"
            continue
        if in_tiers and "=" in stripped:
            key, value = stripped.split("=", 1)
            tiers[key.strip()] = value.strip().strip('"')
    return tiers


def generate(out_dir: Path | None = None, root: Path | None = None) -> int:
    root = root or ROOT
    out_dir = out_dir or (root / ".agents" / "agents")
    sources_dir = root / ".claude" / "agents"
    tiers = parse_toml_tiers(root / ".agents" / "agent-models.toml") or TIER_TO_GEMINI

    sources = sorted(sources_dir.glob("*.md"))
    expected_names = {split_frontmatter(s.read_text())[0]["name"] for s in sources}

    out_dir.mkdir(parents=True, exist_ok=True)
    # Remove generated files whose source is gone (mirror Codex behavior).
    for target in out_dir.glob("*.md"):
        if target.stem not in expected_names and "Generated from .claude/agents/" in target.read_text()[:500]:
            target.unlink()

    skill_names = {
        p.parent.name for p in (root / ".claude" / "skills").glob("*/SKILL.md")
    }

    count = 0
    for source in sources:
        metadata, _body = split_frontmatter(source.read_text())
        name = metadata["name"]
        description = metadata["description"]
        tier = metadata.get("model", "")
        model = antigravity_model(tier)
        resolved = tiers.get(tier or "", gemini_model(tier))

        comments = [
            f"# Generated from {source.relative_to(root)}.",
            "# Do not edit; run python3 .agents/generate_compat.py.",
            "# Body is linked, not copied: edit the canonical file only.",
        ]
        if resolved:
            comments.append(f"# Resolved Gemini model: {resolved} (tier: {tier}).")
        else:
            comments.append("# Resolved Gemini model: inherit (session model).")
        comments.append(
            "# Claude tools metadata (not an Antigravity tool allowlist): "
            f"{metadata.get('tools', 'not specified')}."
        )

        # Thin wrapper: frontmatter is transformed, body is linked.
        # The @ include is inlined by Antigravity (verified on agy 1.4.12);
        # the fallback line covers harnesses that don't inline it.
        body_text = (
            "Antigravity adapter: use the available Antigravity tools and "
            "delegation controls. Any Claude-specific tool names in the "
            "linked instructions describe capabilities, not literal "
            "Antigravity tool names. Follow the parent session's approval "
            "and sandbox policy.\n\n"
            f"@[{name} instructions](../.claude/agents/{name}.md)\n\n"
            f"If the include above did not inline, read "
            f"`.claude/agents/{name}.md` now and follow it exactly — it is "
            "the canonical definition of this agent."
        )

        # Frontmatter must be the first thing in the file for Antigravity
        # to parse it, so generated-file notes live as YAML comments inside
        # the frontmatter block.
        lines = [
            "---",
            *comments,
            f"name: {name}",
            f"description: {yaml_string(description)}",
            # Antigravity tool names differ from Claude's (view_file,
            # grep_search, run_command, ...). An unmapped name can hang the
            # subagent, so ship the default set rather than guessing.
            "tools: []",
            "mainAgent: false",
            "subagent: true",
            f"model: {model}",
            "commandExecutionPolicy: sandbox",
        ]

        declared_skills = [
            s for s in parse_skills(metadata.get("skills", "")) if s in skill_names
        ]
        if declared_skills:
            lines.append("skills:")
            lines.extend(f"  - {s}" for s in declared_skills)

        lines.extend(["---", "", body_text, ""])

        (out_dir / f"{name}.md").write_text("\n".join(lines))
        count += 1
    return count


def check(out_dir: Path | None = None, root: Path | None = None) -> int:
    """Exit 1 if committed generated files differ from a fresh generation."""

    root = root or ROOT
    out_dir = out_dir or (root / ".agents" / "agents")
    import tempfile

    with tempfile.TemporaryDirectory() as tmp:
        fresh = Path(tmp) / "agents"
        generate(out_dir=fresh, root=root)
        fresh_files = {p.name: p.read_bytes() for p in fresh.glob("*.md")}
    committed = {p.name: p.read_bytes() for p in out_dir.glob("*.md")}
    stale = sorted(
        name
        for name in set(fresh_files) | set(committed)
        if fresh_files.get(name) != committed.get(name)
    )
    if stale:
        print(f"Stale Antigravity agents: {', '.join(stale)}", file=sys.stderr)
        print("Run: python3 .agents/generate_compat.py", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    if "--check" in sys.argv:
        sys.exit(check())
    agents = generate()
    print(f"Generated Antigravity metadata for {agents} custom agents.")
