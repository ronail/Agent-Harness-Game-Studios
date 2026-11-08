"""Tests for .agents/generate_compat.py (Antigravity generator).

Run: python3 -m unittest .agents/test_generate_compat.py -v
"""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "generate_compat", HERE / "generate_compat.py"
)
gc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gc)

ROOT = HERE.parent


class TestFrontmatterParsing(unittest.TestCase):
    def test_producer_frontmatter(self):
        metadata, _body = gc.split_frontmatter(
            (ROOT / ".claude" / "agents" / "producer.md").read_text()
        )
        self.assertEqual(metadata["name"], "producer")
        self.assertEqual(metadata["model"], "opus")
        self.assertIn("description", metadata)


class TestModelTierMapping(unittest.TestCase):
    def test_tier_to_antigravity_model(self):
        self.assertEqual(gc.antigravity_model("opus"), "pro")
        self.assertEqual(gc.antigravity_model("sonnet"), "flash")
        self.assertEqual(gc.antigravity_model("haiku"), "flash")
        self.assertEqual(gc.antigravity_model("inherit"), "inherit")
        self.assertEqual(gc.antigravity_model(""), "inherit")
        self.assertEqual(gc.antigravity_model(None), "inherit")


class TestGeneratedFile(unittest.TestCase):
    def test_generated_producer_is_valid(self):
        with tempfile.TemporaryDirectory() as tmp:
            out_dir = Path(tmp) / "agents"
            gc.generate(out_dir=out_dir, root=ROOT)
            text = (out_dir / "producer.md").read_text()
            metadata, body = gc.split_frontmatter(text)
            self.assertEqual(metadata["name"], "producer")
            self.assertTrue(metadata["description"])
            self.assertEqual(metadata["model"], "pro")
            self.assertEqual(metadata["subagent"], "true")
            self.assertEqual(metadata["mainAgent"], "false")
            self.assertEqual(metadata["commandExecutionPolicy"], "sandbox")
            self.assertIn("Antigravity adapter", body)
            self.assertIn("gemini-4-argon", text)
            # Body must be linked, not copied.
            self.assertIn("@[producer instructions](../.claude/agents/producer.md)", body)
            self.assertNotIn("You are the Producer for an indie game", text)
            self.assertLess(len(text), 2000)
            # Claude tool names must not leak into the Antigravity tools list.
            self.assertIn("tools: []", text)
            self.assertNotIn("\ntools: Read", text)

    def test_generate_count_and_idempotent(self):
        with tempfile.TemporaryDirectory() as tmp:
            out_dir = Path(tmp) / "agents"
            count = gc.generate(out_dir=out_dir, root=ROOT)
            sources = sorted((ROOT / ".claude" / "agents").glob("*.md"))
            self.assertEqual(count, len(sources))
            first = {p.name: p.read_bytes() for p in out_dir.glob("*.md")}
            gc.generate(out_dir=out_dir, root=ROOT)
            second = {p.name: p.read_bytes() for p in out_dir.glob("*.md")}
            self.assertEqual(first, second)

    def test_stale_cleanup(self):
        with tempfile.TemporaryDirectory() as tmp:
            out_dir = Path(tmp) / "agents"
            out_dir.mkdir(parents=True)
            stale = out_dir / "deleted-agent.md"
            stale.write_text(
                "# Generated from .claude/agents/deleted-agent.md.\n"
                "---\nname: deleted-agent\n---\nbody\n"
            )
            gc.generate(out_dir=out_dir, root=ROOT)
            self.assertFalse(stale.exists())


if __name__ == "__main__":
    unittest.main()
