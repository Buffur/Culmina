# CI execution and timing

Current CI optimization work, 2026-10-24, based on `develop` at
`56c4208e51b79a820955c2f3406a220efe1b359f`. Local validation and remote
delivery status belong in [PROGRESS](refinement/PROGRESS.md). This changes
execution of checks, not application behavior or acceptance criteria.

## Execution contract

The `CI` workflow always starts for pushes to main/develop and pull requests.
The lightweight `changes` job runs the Python tooling regressions and classifies
the complete Git diff, including deletions/renames. Only V1 documentation paths
are exempt from Flutter work: Markdown under docs/.agents/.claude, Markdown
instruction adapters/README at any level, and docs/*.patch. Unknown paths,
executables, an empty diff or an unavailable base run the full checks.

The existing `quality-gate` check name is retained. It succeeds for documentation
only when classification succeeded and all three heavy job groups were skipped.
For other changes it requires static checks and all unit and host jobs to succeed, downloads their
receipts, and checks their inventory and reporter completeness. Missing,
duplicate, failed, cancelled or unexpectedly skipped jobs cannot pass. The
public branch API reported develop protection disabled and no required contexts
on 2026-10-24; no branch settings were changed.

Full execution uses three unit/widget jobs and one host job per host-capable
integration file, plus an independent static-check job for encoding, format
and analysis through `dart run tool/check.dart --checks-only`. Fail-fast is
disabled; unit/host jobs do not depend on static success, so tests still run
after a static failure. SDK 3.47.4 and Ubuntu 24.04 remain pinned. The existing
Flutter action now caches both SDK and pub dependencies, with its default
SDK/OS/architecture and lockfile-aware pub keys. Build/test outputs are not cached.

## Inventory and receipts

`tool/ci.py` discovers every test/**/*_test.dart and deterministically balances
whole files using `tool/ci_test_costs.json`. New files receive a nonzero default
cost and enter the partition automatically. Cost weights affect scheduling only;
they never select or exclude a test. The checked-in weights come from the Windows
baseline, with the accessibility weight updated after its fixture optimization.
They are not predictions of Ubuntu wall-clock duration. Two shards produced
approximately 637.6/637.6 summed file-seconds; three produced 425.5/424.8/424.8.
These sums include concurrent loading/test intervals and must not be interpreted
as elapsed time. Three was selected for parallel CI; its actual time and runner
cost remain subject to the remote measurement below.

Every selected file goes to exactly one Flutter invocation, without name/tag
filters. Each process writes the JSON reporter stream plus a receipt containing
the selected/loaded files, visible test outcomes and wall time. Aggregation
requires exactly one static receipt, shards 0/1/2, every discovered unit file once, and every host
file once. A successful terminal reporter event and one finish per started test
are required; hidden loading/setup events do not inflate PASS counts. Raw reports,
receipts, static-stage timings and the aggregate summary are retained as Actions
artifacts for 14 days. Their per-test durations identify expensive fixtures.

Host E2E remains one process per file (S10.2). `core_loop_test.dart` and
`perf_scenarios_test.dart` run on host. The two Hybrid capture fixtures declare
`skip: !Platform.isAndroid`; they are excluded from host startup in both local
and CI gates. Their source files and Android/device acceptance contracts are
unchanged. New top-level integration files default to host execution. A regression checks
that the two exclusions still have Android guards and match the local gate.
No Android/device acceptance is claimed by these host runs.

The local full command remains `dart run tool/check.dart`; Python tooling
regressions can also be run with
`python -m unittest discover -s tool -p ci_test.py -v`.
To reproduce a partition: `python tool/ci.py run unit --index 0 --output <dir>`
(repeat indexes 1 and 2); use `run host --file <file> --output <dir>` for each
host file; use `run checks --output <dir>` for static checks, then
`aggregate <parent-dir>`. Each invocation requires Flutter/Dart
on PATH. Use separate checkouts/runners for concurrent Flutter CLI processes.

## Measured evidence

| Measurement | Before | After / boundary |
| --- | --- | --- |
| Remote CI | [Run #21](https://github.com/Buffur/Culmina/actions/runs/40034632176), success at `4ac20a9`; job 12m58s / 12.967 runner-minutes; whole workflow 13m02s. API timestamps: job 22:35:52 to 22:48:50 UTC, 2026-10-23. | New remote run **PENDING newly authorized delivery/run**. No CI speedup or cache-hit saving is claimed yet. |
| Remote stages | Checkout 8s, Flutter setup 65s, pub get 12s, gate 11m28s, from jobs API. Authenticated connector log confirms unit/widget 456.323s and host E2E 199.282s: core 85.505s, Android-only skipped startups 25.300s + 24.927s, perf 63.550s. 2509 PASS / 6 SKIP, host 3 PASS and 2 Android-only SKIP. | Pending new run's jobs/steps and artifacts. Runner-minutes must sum all jobs, not only the critical path; billed rounded minutes are a separate metric. |
| Local baseline, Windows / Flutter 3.47.4 | One complete unmodified unit/widget run: 236.872s process wall, 230.959s reporter, 2509 PASS / 6 SKIP, 285 files. | Three shards: 1021/696/792 PASS and 4/1/1 SKIP; all 285 files exactly once. Exact multiset of file/name/outcome matches baseline, SHA-256 `3caf5bdd9d52388f030328b5b85b22545ab057128b55aa162a99660dbbe04c44`. Host files: 2 + 1 PASS. Local timings are not remote CI predictions. |
| Isolated accessibility comparison, same host | 125.474s reporter / 121.111s visible test time; 16 PASS. | 73.847s reporter / 70.185s visible test time; identical 16 test names/outcomes. Reporter reduction 41.1% in this single before/after pair. |

The baseline's most expensive files by summed load/test seconds were
accessibility (162.702), Night & Moon browse (46.680), lifecycle matrix (36.245),
restore activation (27.427), shell navigation (23.957), forecast nights (23.634),
design gallery (23.107) and schema migrations (21.619). File test counts were
not used as runtime estimates. The baseline full run and isolated comparison
have different competing workloads, so only the isolated pair supports the
accessibility speed comparison.

The first shard's initial combined receipt took 197.834s, including 89.173s
of encoding/format/analysis, versus 67.343s and 63.436s for shards 1/2.
This exposed the static-check critical path, so static checks now have their
own parallel job. Its new runner receipt passed in 56.381s (encoding 1.543s,
format 4.531s, analysis 49.016s); unit/host results are reused because their
commands, selected inputs and outcome streams did not change. Host process
times were 89.149s and 62.894s. All local full validation was sequential to
avoid competing Flutter processes in one checkout. These process times do not
measure parallel CI or include its setup/queue/cache/artifact overhead. Separate
static execution adds another SDK setup on CI; runner-minutes may increase even
if critical-path duration falls. Only the remote run can quantify that tradeoff.

Final local tooling regressions: 8 PASS; workflow YAML parsed with the existing
transitive Dart YAML package; required-check truth table, docs/executable
classification, Android exclusions, complete/failed/truncated streams,
partition inventory and missing/duplicate/failed receipt cases verified.
Encoding, unchanged format of 645 files, full analysis and `git diff --check` passed.
After the final helper error-propagation edit, targeted analysis of that file also
passed; unaffected full-analysis inputs are reused under V3.
No full-suite rerun was performed after splitting static checks from shard zero.
A final helper review preserved VM failure propagation; the affected accessibility
file was rerun alone, 16 PASS with the same names/outcomes. Machine summaries are
[baseline](ci-baseline-2026-10-24.json) and [local validation](ci-local-validation-2026-10-24.json).

The accessibility fixture now waits for mounted FutureBuilder operations,
plan/weather idle futures and the visible calendar's computation, pumping the
test zone while real IO progresses. The original twelve 50ms animation frames,
all routes, three themes, 100%/200% text, scroll audits, guidelines and assertions
remain. A 30s pending-operation timeout fails explicitly; there is no fixed 240ms
sleep at every transition. The first direct-await experiment deadlocked across
FakeAsync/real zones and was stopped; the final helper pumps continuations.
Existing filter-toggle hit-test warnings and mocked tile HTTP 400 messages were
also present in the original fixture and were not hidden or weakened.

Raw local JSONL profiles, baseline jobs API response, logs and preservation
snapshot are outside Git in the session's temporary `culmina-ci-2026-10-24`
directory. No private metadata samples, device data or credentials were read.

## Official references

- [Workflow filters and required checks](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [Dependent jobs and always](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-jobs)
- [Flutter action caching](https://github.com/subosito/flutter-action#caching)
- [Test JSON reporter protocol](https://github.com/dart-lang/test/blob/master/pkgs/test/doc/json_reporter.md)
- [Flutter CLI](https://docs.flutter.dev/reference/flutter-cli); installed `flutter test --help` confirms file-reporter support.
