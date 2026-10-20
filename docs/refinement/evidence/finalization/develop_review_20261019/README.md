# Independent develop review evidence — 2026-10-19

Code: `8048cfa4e7fd5eadc99cba708a02f055ceddd53f`. Contract: P6-2026-10-18-08 / AM-05, unchanged SHA-256 `6ab29ddda5fbea5097a03df04338a4062d5060e133e8c85a075dab7c88e6b6f9`.

The [main review](../../../DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md), [127-criterion matrix](CRITERION_MATRIX.md), [machine-readable criteria](criteria.json), [exact task/source/decision map](task_source_decision_map.json), [observation counts](observations.json) and [native observations](NATIVE_OBSERVATIONS.md) are the entry points. Raw nonprivate outputs are preserved with repository/temporary-directory prefixes normalized; no assertion, failure or result was changed. Private sample error output and manifests stay only in ignored build output, not here. The public FITS file, SDK downloads, AVD and APKs are also kept outside this documentation tree.

## Host reproduction

Use the pinned Flutter/Dart toolchain, resolve the existing lock normally, then:

```powershell
dart run tool/check.dart
flutter test --no-pub --reporter expanded test/presentation/viewmodels/planner_sky_darkness_test.dart test/presentation/screens/location/location_picker_tiles_failing_test.dart
```

The first gate fails only its unit/widget step on Windows; the two E2E files still pass. The focused command reproduces both test failures. Do not describe that as application scraping or a failed map-control assertion.

For the independent probes, when their ignored source files are absent:

```powershell
git apply docs/refinement/evidence/finalization/develop_review_20261019/independent_probes.patch
git apply docs/refinement/evidence/finalization/develop_review_20261018/restore_probe.patch
```

Apply only an absent probe's patch; do not overwrite an existing probe. The old patch is historical evidence retained by the earlier review. The external probe also requires the public FITS fixture below. Then run the current probe commands serially, to avoid Windows sqlite3.dll build-hook locks:

```powershell
flutter test --no-pub --reporter expanded build/finalization/develop_review_20261018/restore_probe_test.dart build/finalization/develop_review_20261019/cleanup_probe_test.dart build/finalization/develop_review_20261019/exposure_probe_test.dart
flutter test --no-pub --reporter expanded build/finalization/develop_review_20261019/external_probe_test.dart
```

Expected reviewed-code results: first command **2 pass, 3 fail**; second **2 pass, 1 fail**. Its live-weather assertion is dated and environment dependent; an unavailable later provider is not the same defect as FITS gain classification. The new probes are deliberately review-only reproductions, not committed production regression fixes.

## Public real FITS provenance

[ccdproc file at immutable commit](https://github.com/astropy/ccdproc/blob/6bab63d0b98f85eab0b4f9e1cbc1ef28087cb7ad/ccdproc/tests/data/a8280271.fits), [raw file](https://raw.githubusercontent.com/astropy/ccdproc/6bab63d0b98f85eab0b4f9e1cbc1ef28087cb7ad/ccdproc/tests/data/a8280271.fits), [BSD license](https://github.com/astropy/ccdproc/blob/6bab63d0b98f85eab0b4f9e1cbc1ef28087cb7ad/LICENSE.rst), [data README](https://github.com/astropy/ccdproc/blob/6bab63d0b98f85eab0b4f9e1cbc1ef28087cb7ad/ccdproc/tests/data/README.rst). Download to `build/finalization/develop_review_20261019/a8280271.fits` and verify [the recorded byte count/hash](fits_provenance.json). The binary is not redistributed here.

The telescope test fixture supports a real-header scientific counterexample and the measured-file path. It is not represented as an owner's full amateur sub-frame or as complete F10 device acceptance. Do not silently change the approved keyword contract to fit it; resolve the documented unsupported-unit assumption explicitly.

## Fresh U renders

```powershell
New-Item -ItemType Directory -Force build/finalization/develop_review_20261019/renders
$env:ASTROPLAN_U_RENDERS = (Resolve-Path build/finalization/develop_review_20261019/renders).Path
flutter test --no-pub --reporter expanded test/presentation/design_system/u_renders_test.dart
```

The corrected run passes all three variant tests and produces 96 PNGs. [Hash inventory](render_hashes.json); six selected fresh images are in [renders](renders). The Windows files are not byte-identical to the committed Linux captures; that is not claimed as a visual regression or a full pixel comparison. The same production widgets, fixture clock and current lock were used. Visual inspection sampled Planner, Night & Moon, Weather, block/keyboard and Logbook and compared the named owner references. The complete render pass and existing accessibility tests are automated evidence; no owner visual or independent-human comprehension acceptance is implied.

## Evidence boundaries

Native build/Kotlin/emulator methods and limits are in [NATIVE_OBSERVATIONS](NATIVE_OBSERVATIONS.md). Live endpoints were read using public fixture coordinates and identifying user agents, with no owner GPS/private coordinates. [Production live forecast](external_probes_corrected.log) confirms the HTTP/parser path; [transport results](live_services.json) do not alone validate Android link launch or permissions.

This review does not close G1/G2/G3/G4, modify the active queue, fix products, approve an ADR, read owner signing secrets, commit/push, migrate owner data or publish a release.
