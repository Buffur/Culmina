"""CI partitioning, machine reporter receipts and fail-closed result aggregation.

Standard library only. Android-only capture contracts stay in integration_test;
host-capable files run in separate Flutter processes (S10.2).
"""

import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent.parent
ANDROID_ONLY = {
    "integration_test/hybrid_migration_smoke_test.dart",
    "integration_test/hybrid_transfer_capture_test.dart",
}


def inventory(root=ROOT):
    return sorted(p.relative_to(root).as_posix() for p in (root / "test").rglob("*_test.dart"))


def host_files(root=ROOT):
    return sorted(p.relative_to(root).as_posix() for p in (root / "integration_test").glob("*_test.dart")
                  if p.relative_to(root).as_posix() not in ANDROID_ONLY)


def partition(files, costs, count):
    if count < 1 or len(files) != len(set(files)):
        raise ValueError("Invalid shard count or duplicate input files")
    buckets, totals = [[] for _ in range(count)], [0.0] * count
    default = max(1.0, sum(costs.values()) / max(1, len(costs)))
    for file in sorted(files, key=lambda f: (-costs.get(f, default), f)):
        index = min(range(count), key=lambda i: (totals[i], i))
        buckets[index].append(file)
        totals[index] += costs.get(file, default)
    return [sorted(b) for b in buckets], totals


def documentation_only(paths):
    if not paths:
        return False
    adapters = {"AGENTS.md", "AGENTS.override.md", "CLAUDE.md", "GEMINI.md", "README.md"}
    return all(
        Path(p).name in adapters or
        (p.endswith(".md") and p.startswith(("docs/", ".agents/", ".claude/"))) or
        (p.startswith("docs/") and p.endswith(".patch"))
        for p in paths
    )


def required_jobs_pass(changes, full, checks, unit, host):
    return changes == "success" and (
        (full == "true" and checks == unit == host == "success") or
        (full == "false" and checks == unit == host == "skipped")
    )


def relative_path(path):
    # Reporter paths are absolute on both Windows and Linux runners.
    normalized = path.replace("\\", "/")
    for prefix in ("integration_test/", "test/"):
        if normalized.startswith(prefix):
            return normalized
        marker = "/" + prefix
        if marker in normalized:
            return prefix + normalized.rsplit(marker, 1)[1]
    raise ValueError(f"Unexpected test suite path: {path}")


def profile(path, require_done=True):
    suites, starts, finishes, rows = {}, {}, {}, []
    final = None
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        event = json.loads(line)
        kind = event["type"]
        if kind == "suite":
            suites[event["suite"]["id"]] = relative_path(event["suite"]["path"])
        elif kind == "testStart":
            test = event["test"]
            if test["id"] in starts:
                raise ValueError("Duplicate testStart")
            starts[test["id"]] = (test, event["time"])
        elif kind == "testDone":
            if event["testID"] in finishes:
                raise ValueError("Duplicate testDone")
            finishes[event["testID"]] = event
        elif kind == "done":
            final = event
    if require_done and (not final or not final["success"] or starts.keys() != finishes.keys()):
        raise ValueError("Incomplete or failed machine reporter stream")
    costs = Counter()
    for key, (test, start) in starts.items():
        if key not in finishes:
            continue
        end = finishes[key]
        file = suites[test["suiteID"]]
        costs[file] += (end["time"] - start) / 1000
        if not end.get("hidden", False):
            rows.append({"file": file, "name": test["name"],
                         "result": "skip" if end["skipped"] else end["result"],
                         "seconds": (end["time"] - start) / 1000})
    return {"files": sorted(set(suites.values())), "tests": rows,
            "counts": dict(Counter(r["result"] for r in rows)),
            "file_test_seconds": dict(costs), "reporter_seconds": final["time"] / 1000 if final else None}


def write_json(path, data):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def test_fingerprint(tests):
    rows = sorted((t["file"], t["name"], t["result"]) for t in tests)
    return hashlib.sha256(json.dumps(rows, ensure_ascii=True, separators=(",", ":")).encode()).hexdigest()


def costs():
    path = ROOT / "tool/ci_test_costs.json"
    return json.loads(path.read_text(encoding="utf-8"))["file_test_seconds"] if path.exists() else {}


def run(command):
    print("+ " + " ".join(command), flush=True)
    return subprocess.call(command, cwd=ROOT, shell=os.name == "nt")


def execute(args):
    out = Path(args.output)
    out.mkdir(parents=True, exist_ok=True)
    started = time.monotonic()
    if args.kind == "checks":
        code = run(["dart", "run", "tool/check.dart", "--checks-only", f"--report={out / 'checks.json'}"])
        write_json(out / "receipt.json", {"kind": "checks", "exit_code": code,
                   "wall_seconds": time.monotonic() - started})
        return int(code != 0)
    buckets, _ = partition(inventory(), costs(), args.shards)
    selected = buckets[args.index] if args.kind == "unit" else [args.file]
    if args.kind == "host" and args.file not in host_files():
        raise ValueError("Host file is outside the host inventory")
    command = ["flutter", "test", "--no-pub", "--file-reporter", f"json:{out / 'tests.jsonl'}"]
    if args.kind == "host":
        command += ["-d", "flutter-tester"]
    code = run(command + selected)
    receipt = {"kind": args.kind, "index": args.index, "shards": args.shards,
               "selected": selected, "exit_code": code,
               "wall_seconds": time.monotonic() - started}
    try:
        receipt["profile"] = profile(out / "tests.jsonl")
        if receipt["profile"]["files"] != selected:
            raise ValueError("Loaded suite inventory differs from selected files")
    except (ValueError, OSError, KeyError) as error:
        receipt["report_error"] = str(error)
    write_json(out / "receipt.json", receipt)
    return int(code != 0 or "report_error" in receipt)


def aggregate(directory, shards):
    receipts = [json.loads(p.read_text(encoding="utf-8")) for p in Path(directory).rglob("receipt.json")]
    units = [r for r in receipts if r["kind"] == "unit"]
    hosts = [r for r in receipts if r["kind"] == "host"]
    checks = [r for r in receipts if r["kind"] == "checks"]
    if len(checks) != 1 or checks[0]["exit_code"] != 0:
        raise ValueError("Missing, duplicate or failed static-check job")
    if len(units) + len(hosts) + len(checks) != len(receipts):
        raise ValueError("Unexpected receipt kind")
    if sorted(r["index"] for r in units) != list(range(shards)):
        raise ValueError("Missing or duplicate unit shards")
    if Counter(f for r in hosts for f in r["selected"]) != Counter(host_files()):
        raise ValueError("Missing, extra or duplicate host files")
    if Counter(f for r in units for f in r["selected"]) != Counter(inventory()):
        raise ValueError("Unit file coverage is not exactly once")
    for receipt in units + hosts:
        if receipt["exit_code"] != 0 or "report_error" in receipt:
            raise ValueError("A runner failed or reported incomplete results")
        if receipt["selected"] != receipt["profile"]["files"]:
            raise ValueError("Reporter did not account for every selected file")
    tests = [t for r in units + hosts for t in r["profile"]["tests"]]
    return {"counts": dict(Counter(t["result"] for t in tests)),
            "unit_counts": dict(Counter(t["result"] for r in units for t in r["profile"]["tests"])),
            "host_counts": dict(Counter(t["result"] for r in hosts for t in r["profile"]["tests"])),
            "unit_tests_sha256": test_fingerprint([t for r in units for t in r["profile"]["tests"]]),
            "unit_files": len(inventory()), "host_files": host_files(),
            "android_only_not_run_on_host": sorted(ANDROID_ONLY),
            "runner_execution_seconds": sum(r["wall_seconds"] for r in receipts)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    p = sub.add_parser("profile")
    p.add_argument("report")
    p.add_argument("output")
    p = sub.add_parser("classify")
    p.add_argument("base")
    p.add_argument("head")
    p = sub.add_parser("plan")
    p = sub.add_parser("run")
    p.add_argument("kind", choices=["checks", "unit", "host"])
    p.add_argument("--index", type=int, default=0)
    p.add_argument("--shards", type=int, default=3)
    p.add_argument("--file")
    p.add_argument("--output", required=True)
    p = sub.add_parser("aggregate")
    p.add_argument("directory")
    p.add_argument("--shards", type=int, default=3)
    p = sub.add_parser("require-jobs")
    for name in ("changes", "full", "checks", "unit", "host"):
        p.add_argument(name)
    args = parser.parse_args()
    if args.action == "profile":
        write_json(args.output, profile(args.report))
    elif args.action == "classify":
        try:
            paths = subprocess.check_output(["git", "diff", "--name-only", "--no-renames", "-z", args.base, args.head], cwd=ROOT).decode().strip("\0").split("\0")
            full = not documentation_only(paths)
        except subprocess.CalledProcessError:
            full = True  # Missing/zero base is never a documentation exemption.
        print("full=" + str(full).lower())
    elif args.action == "plan":
        print("hosts=" + json.dumps(host_files()))
    elif args.action == "run":
        return execute(args)
    elif args.action == "require-jobs":
        return int(not required_jobs_pass(args.changes, args.full, args.checks, args.unit, args.host))
    else:
        result = aggregate(args.directory, args.shards)
        write_json(Path(args.directory) / "summary.json", result)
        if "GITHUB_OUTPUT" in os.environ:
            with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
                for group in ("unit", "host"):
                    for outcome, label in (("success", "pass"), ("skip", "skip")):
                        output.write(f"{group}_{label}={result[group + '_counts'].get(outcome, 0)}\n")
                output.write("unit_sha=" + result["unit_tests_sha256"] + "\n")
        if "GITHUB_STEP_SUMMARY" in os.environ:
            with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as output:
                output.write("## Complete test inventory\n\n```json\n" + json.dumps(result, indent=2) + "\n```\n")
        print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
