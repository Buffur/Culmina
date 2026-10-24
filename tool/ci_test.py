"""Regression checks for CI selection and fail-closed machine evidence."""

import copy
import itertools
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import ci


class CiTest(unittest.TestCase):
    def test_required_check_fails_closed_for_every_job_state(self):
        states = ["success", "failure", "cancelled", "skipped", ""]
        for changes, full, checks, unit, host in itertools.product(states, ["true", "false", ""], states, states, states):
            expected = changes == "success" and (full, checks, unit, host) in [
                ("true", "success", "success", "success"), ("false", "skipped", "skipped", "skipped")]
            self.assertEqual(ci.required_jobs_pass(changes, full, checks, unit, host), expected)

    def test_docs_class_and_unknown_executables(self):
        docs = ["AGENTS.md", "GEMINI.md", "nested/AGENTS.override.md",
                ".claude/rules/testing.md", ".agents/skills/example/SKILL.md",
                "docs/probe.patch", "docs/README.md"]
        self.assertTrue(ci.documentation_only(docs))
        for executable in ["tool/ci.py", ".agents/example.dart", "docs/test.dart",
                           ".github/workflows/ci.yml", "unknown.txt", "pubspec.lock"]:
            self.assertFalse(ci.documentation_only(docs + [executable]))
        self.assertFalse(ci.documentation_only([]))

    def test_balance_preserves_every_file_including_new_unprofiled_files(self):
        files = ["slow", "medium", "fast", "new"]
        for count in [2, 3]:
            shards, totals = ci.partition(files, {"slow": 100, "medium": 30, "fast": 1}, count)
            self.assertEqual(sorted(f for shard in shards for f in shard), sorted(files))
            self.assertEqual(ci.partition(list(reversed(files)), {"slow": 100, "medium": 30, "fast": 1}, count), (shards, totals))
        with self.assertRaises(ValueError):
            ci.partition(["a", "a"], {}, 2)

    def test_host_inventory_excludes_only_android_contracts(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "integration_test").mkdir()
            for name in ["core_loop_test.dart", "new_test.dart", "hybrid_migration_smoke_test.dart", "hybrid_transfer_capture_test.dart"]:
                (root / "integration_test" / name).touch()
            self.assertEqual(ci.host_files(root), ["integration_test/core_loop_test.dart", "integration_test/new_test.dart"])

    def test_android_exclusions_still_match_device_guards_and_local_gate(self):
        gate = (ci.ROOT / "tool/check.dart").read_text(encoding="utf-8")
        for file in ci.ANDROID_ONLY:
            source = (ci.ROOT / file).read_text(encoding="utf-8")
            self.assertIn("skip: !Platform.isAndroid", source)
            self.assertIn("'" + Path(file).name + "'", gate)

    def test_static_failure_and_independent_unit_process_have_separate_receipts(self):
        files = ["test/a_test.dart"]
        with tempfile.TemporaryDirectory() as folder, patch.object(ci, "inventory", return_value=files), patch.object(ci, "costs", return_value={}), patch.object(ci, "profile", return_value={"files": files, "tests": []}), patch.object(ci, "run", side_effect=[1, 0]) as command:
            args = SimpleNamespace(kind="checks", index=0, shards=1, file=None, output=folder)
            self.assertEqual(ci.execute(args), 1)
            receipt = json.loads((Path(folder) / "receipt.json").read_text())
            self.assertEqual(receipt["kind"], "checks")
            self.assertEqual(receipt["exit_code"], 1)
            args.kind = "unit"
            self.assertEqual(ci.execute(args), 0)
            self.assertEqual(command.call_count, 2)
            self.assertEqual(command.call_args_list[1].args[0][-1], files[0])
            receipt = json.loads((Path(folder) / "receipt.json").read_text())
            self.assertEqual(receipt["exit_code"], 0)

    def reporter(self, path, success=True):
        events = [
            {"type": "suite", "suite": {"id": 0, "path": "C:/repo/test/a_test.dart"}},
            {"type": "testStart", "time": 0, "test": {"id": 1, "suiteID": 0, "name": "loading"}},
            {"type": "testDone", "time": 5, "testID": 1, "hidden": True, "result": "success", "skipped": False},
            {"type": "testStart", "time": 5, "test": {"id": 2, "suiteID": 0, "name": "test"}},
            {"type": "testDone", "time": 15, "testID": 2, "hidden": False, "result": "success", "skipped": False},
            {"type": "done", "time": 20, "success": success},
        ]
        path.write_text("\n".join(json.dumps(e) for e in events), encoding="utf-8")
        return events

    def test_machine_stream_counts_and_incomplete_failure_detection(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "tests.jsonl"
            events = self.reporter(path)
            data = ci.profile(path)
            self.assertEqual(data["counts"], {"success": 1})
            self.assertEqual(data["files"], ["test/a_test.dart"])
            self.assertAlmostEqual(data["file_test_seconds"]["test/a_test.dart"], .015)
            for bad in [events[:-1], events[:-2] + events[-1:], events + [events[-2]]]:
                path.write_text("\n".join(json.dumps(e) for e in bad), encoding="utf-8")
                with self.assertRaises(ValueError):
                    ci.profile(path)
            self.reporter(path, success=False)
            with self.assertRaises(ValueError):
                ci.profile(path)

    def test_aggregate_rejects_missing_duplicate_failed_or_unaccounted_runs(self):
        files = ["test/a_test.dart", "test/b_test.dart", "test/c_test.dart"]
        hosts = ["integration_test/core_loop_test.dart"]
        receipts = [
            {"kind": "unit", "index": i, "selected": [file], "checks_exit_code": 0 if i == 0 else None,
             "exit_code": 0, "wall_seconds": 1, "profile": {"files": [file], "tests": []}}
            for i, file in enumerate(files)
        ] + [{"kind": "host", "index": 0, "selected": hosts, "exit_code": 0,
              "wall_seconds": 1, "profile": {"files": hosts, "tests": []}},
             {"kind": "checks", "exit_code": 0, "wall_seconds": 1}]
        with tempfile.TemporaryDirectory() as folder, patch.object(ci, "inventory", return_value=files), patch.object(ci, "host_files", return_value=hosts):
            def check(values):
                for old in Path(folder).glob("*/receipt.json"):
                    old.unlink()
                for i, value in enumerate(values):
                    ci.write_json(Path(folder) / str(i) / "receipt.json", value)
                return ci.aggregate(folder, 3)
            self.assertEqual(check(receipts)["unit_files"], 3)
            variants = [receipts[:-1], receipts + [receipts[0]], receipts[1:], receipts + [receipts[-1]]]
            for key, value in [("exit_code", 1), ("report_error", "truncated")]:
                variant = copy.deepcopy(receipts)
                variant[0][key] = value
                variants.append(variant)
            variant = copy.deepcopy(receipts)
            variant[1]["profile"]["files"] = []
            variants.append(variant)
            for variant in variants:
                with self.assertRaises(ValueError):
                    check(variant)


if __name__ == "__main__":
    unittest.main()
