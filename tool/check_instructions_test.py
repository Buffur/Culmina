"""Regression checks for instruction validation, using isolated repositories."""

import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

import check_instructions as check


class InstructionTest(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.root = Path(folder.name)
        for name in check.ENTRYPOINTS:
            (self.root / name).write_text("# Entry\n", encoding="utf-8")
        self.skill = self.root / ".agents/skills/example/SKILL.md"
        self.skill.parent.mkdir(parents=True)
        self.write_skill()

    def write_skill(self, front="name: example\ndescription: A scoped task.", body="# Example\n"):
        self.skill.write_text(f"---\n{front}\n---\n{body}", encoding="utf-8")

    def test_valid_yaml_including_multiline_description_and_metadata(self):
        self.write_skill("name: example\ndescription: >-\n  A scoped\n  task.\nmetadata:\n  origin: local")
        self.assertEqual(check.validate(self.root)[0], [])

    def test_invalid_missing_duplicate_and_unsafe_yaml_fail(self):
        for front in ["name: [", "name: example", "name: example\ndescription: ''",
                      "name: example\ndescription: one\ndescription: two",
                      "name: example\ndescription: !!python/object:builtins.object {}",
                      "name: example\ndescription: task\nmetadata:\n  x: 1\n  x: 2",
                      "name: other\ndescription: task", "name: example\ndescription: 1"]:
            with self.subTest(front=front):
                self.write_skill(front)
                self.assertTrue(check.validate(self.root)[0])

    def test_missing_delimiters_and_duplicate_names_fail(self):
        self.skill.write_text("name: example", encoding="utf-8")
        self.assertTrue(check.validate(self.root)[0])
        self.skill.write_text("---\nname: example", encoding="utf-8")
        self.assertTrue(check.validate(self.root)[0])
        self.write_skill()
        other = self.root / ".agents/skills/other/SKILL.md"
        other.parent.mkdir()
        other.write_text(self.skill.read_text(encoding="utf-8"), encoding="utf-8")
        self.assertTrue(any("Duplicate skill name" in e for e in check.validate(self.root)[0]))

    def test_links_images_reference_definitions_and_encoded_spaces(self):
        reference = self.skill.parent / "references/a b(c).md"
        reference.parent.mkdir()
        reference.touch()
        self.write_skill(body='[One](references/a%20b(c).md#heading)\n'
                         '[Two](<references/a b(c).md> "Title")\n'
                         '![Image](references/a%20b(c).md)\n'
                         '[ref]: references/a%20b(c).md\n'
                         '[remote](https://example.com/missing) [anchor](#missing)\n')
        self.assertEqual(check.validate(self.root)[0], [])
        reference.unlink()
        self.assertEqual(len(check.validate(self.root)[0]), 4)

    def test_code_examples_and_archives_are_not_active_links(self):
        self.write_skill(body='```md\n[missing](missing.md)\n```\n'
                         '`[also missing](missing.md)`\n')
        archive = self.root / "docs/archive/SKILL.md"
        archive.parent.mkdir(parents=True)
        archive.write_text("[old](missing.md)", encoding="utf-8")
        self.assertEqual(check.validate(self.root)[0], [])

    def test_missing_entrypoints_and_escaping_links_fail(self):
        (self.root / "AGENTS.md").unlink()
        self.write_skill(body="[escape](../../../../outside.md)")
        errors = check.validate(self.root)[0]
        self.assertEqual(len(errors), 2)
        self.assertTrue(any("escapes repository" in e for e in errors))

    def test_cli_exit_status_fails_closed(self):
        command = [sys.executable, str(check.ROOT / "tool/check_instructions.py"), "--root", str(self.root)]
        valid = subprocess.run(command, capture_output=True, text=True)
        self.assertEqual(valid.returncode, 0, valid.stderr)
        self.write_skill(body="[missing](missing.md)")
        invalid = subprocess.run(command, capture_output=True, text=True)
        self.assertEqual(invalid.returncode, 1)
        self.assertIn("missing local target", invalid.stderr)

    def test_compatibility_frontmatter_is_checked_without_skill_schema(self):
        rule = self.root / ".claude/rules/tooling.md"
        rule.parent.mkdir(parents=True)
        rule.write_text('---\npaths: ["tool/**"]\n---\n[Root](../../AGENTS.md)', encoding="utf-8")
        self.assertEqual(check.validate(self.root)[0], [])
        rule.write_text('---\npaths: [\n---', encoding="utf-8")
        self.assertTrue(check.validate(self.root)[0])

    def test_eval_catalog_references_current_skills_and_has_review_criteria(self):
        # This validates the catalog, not agent behavior or its pass rate.
        catalog = json.loads((check.ROOT / "tool/skill_evals/cases.json").read_text(encoding="utf-8"))
        self.assertEqual(catalog["version"], 1)
        cases = catalog["cases"]
        self.assertTrue(cases)
        self.assertEqual(len({case["id"] for case in cases}), len(cases))
        known = {p.parent.name for p in (check.ROOT / ".agents/skills").glob("*/SKILL.md")}
        for case in cases:
            with self.subTest(case=case["id"]):
                self.assertTrue(case["prompt"].strip())
                for key in ("success", "forbidden"):
                    self.assertTrue(case[key])
                    self.assertTrue(all(isinstance(item, str) and item.strip() for item in case[key]))
                self.assertLessEqual(set(case["consider_skills"] + case["avoid_skills"]), known)
                self.assertFalse(set(case["consider_skills"]) & set(case["avoid_skills"]))


if __name__ == "__main__":
    unittest.main()
