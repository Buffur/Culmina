# Native emulator evidence — Hybrid migration

Prepared 2026-10-20. This directory records **Android emulator** evidence, not physical-device acceptance.

## Active QA device after IDE ownership changed

The original `emulator-5580` was subsequently claimed by Android Studio's `flutter run --machine lib/main.dart` session (observed Dart PID 17116). That IDE process and its emulator were left untouched. Subsequent integration, normal-entry APK, and hot-reload validation must target **`emulator-5582` only**:

- New dedicated AVD: `culmina_hybrid_native_qa`, created without `--force` from the same installed API 30 x86_64 Google APIs image.
- Hidden emulator wrapper PID: `17532` (also `qa-emulator-process-id.txt`).
- Boot verified with `sys.boot_completed=1`; AVD identity verified as `culmina_hybrid_native_qa`.
- Test display: 824×1830 physical pixels, density 320; system 24-hour clock verified as `24`.
- Launch/create evidence: `qa-avd-create.log`, `qa-emulator-stdout.log`, `qa-emulator-stderr.log`.
- No install, stop, restart, reload or settings change was directed to the IDE-owned 5580 after the ownership change was observed.

## Isolated environment

- SDK: `C:\Users\zalub\AppData\Local\Android\Sdk`.
- Existing system image: `system-images;android-30;google_apis;x86_64`, revision 16.
- Acceleration probe: WHPX `10.0.26300` installed and usable.
- `avdmanager list avd` reported no existing AVDs.
- Created only `culmina_hybrid_migration`, using the existing Pixel 5 device profile and installed image, without `--force`.
- AVD files: `C:\Users\zalub\.android\avd\culmina_hybrid_migration.avd`.
- Emulator serial reserved for this run: `emulator-5580`.
- Initial wrapper process ID: see `emulator-process-id.txt`; stdout/stderr retained separately.
- Launch: `emulator.exe -avd culmina_hybrid_migration -port 5580 -no-window -no-audio -no-boot-anim -no-snapshot -gpu swiftshader_indirect`, using PowerShell `Start-Process -WindowStyle Hidden`.
- No wipe-data or deletion of another AVD. User data outside this isolated AVD is not part of the test.

The installed `avdmanager` warned that it understands SDK XML through version 3 while a version-4 file exists; creation succeeded using the installed system image. `avd-create.log` records this warning.

During read-only device inventory, SDK adb encountered an existing server version 40 while its client uses version 41 and automatically restarted that server. A physical Android device was visible afterward. No install, shell interaction or test was directed to that device; every emulator command explicitly uses `-s emulator-5580`.

## Tool references

Official Android documentation read during this pass:

- [Android emulator command-line options](https://developer.android.com/studio/run/emulator-commandline)
- [avdmanager](https://developer.android.com/tools/avdmanager)

Local `avdmanager` help also verified the create options. The installed emulator/avdmanager tools are used without a toolchain upgrade.

## Current evidence status

Boot confirmed: `sys.boot_completed=1`, Android 11, AVD name verified through `adb -s emulator-5580 emu avd name`. Display override in this isolated AVD: 824×1830 physical pixels, density 320, giving 412×915 logical screen pixels before system insets. Original Pixel 5 profile is 1080×2340 / density 440.

Prepared native harness:

- `integration_test/hybrid_migration_smoke_test.dart`: real production widgets/router/ViewModels/astronomy with an isolated in-memory SQLite database and explicitly simulated weather/GPS/preferences. Fixture matches the host-render harness's Ljubljana, M42, 2026-11-10 evening context.
- `test_driver/hybrid_migration_driver.dart`: PNG/report collection; successful collection is not a visual-parity assertion.
- Planned checks: visible Save → repository read → Logbook detail → reopen same ID/counts; fullscreen block editor input/cancel; browse next night without modifying active/stored plan; change a display unit and planning overhead without rewriting the saved snapshot; capture all eight routes in three themes at 100%/200%; cached forecast refresh failure and out-of-range state; record a partial result and inspect detail/progress.
- Prepared Android file-I/O checks: write the existing test fixture's synthetic FITS header and data to an isolated application-documents subdirectory, read through `FileMetadataSource`/`CaptureMetadataReader`, and verify values/provenance. This is not a real camera sample.
- Prepared backup check: `FileBackupService.createBackup` → `checkFully` (production connection, schema/integrity/repository checks) → `stage` → `BackupStaging.apply` → reopen the restored file in SQLite and compare saved plan, block counts, result, notes and event count. Destination is an isolated test subdirectory, removed after completion; the app's actual database is never replaced. This checks file persistence without a process restart or native chooser.
- Exclusions: actual file providers, live GPS/weather, permissions, sharing, process-death persistence, physical devices, and identical web fixture parity.

First application installation succeeded: `flutter drive --driver=test_driver/hybrid_migration_driver.dart --target=integration_test/hybrid_migration_smoke_test.dart -d emulator-5580 --no-pub` built the test-entry debug APK in 80.9 seconds and installed it in 8.5 seconds. `drive.log` records this attempt. The app started under the Android Flutter engine, but the harness failed before its first interaction because `scrollUntilVisible` received `finder.first` while the lazy target was not mounted. The helper was corrected to receive the base finder. This is an intermediate harness failure, not successful workflow evidence.

The isolated emulator's system `time_12_24` setting was set to `24` and read back as `24`. Both migration harnesses additionally wrap the real app with an explicit 24-hour `MediaQuery`; the host harness asserts the effective value. A dispatcher test override alone proved insufficient and the initial host screenshots were superseded by `matched/host-light100-24h.log` and its actual 24-hour PNGs.

Successful native screen checks, screenshot comparison and platform workflows remain **pending** until actual results are appended. The test-entry APK is not the production deliverable; a final build targeting `lib/main.dart` is still required.

## Matrix B coverage still requiring separate evidence

This bounded smoke harness does not claim complete runtime coverage of Matrix B. In particular, library rig/target/site editing and deletion/Undo, native image/document selection, actual camera EXIF/DNG/HEIF/FITS samples, sharing receivers, GPS permissions, cold-start recovery, interrupted restores, all calibration policies and focus/white-balance combinations, and human accessibility acceptance remain separate scenarios. Host tests and source inspection must be reported at their own evidence level.

The per-plan assumption override and schema migration change is being implemented concurrently. The harness now follows its current contract: buffered typing, Apply, reset to defaults, unchanged global preferences, Save/reopen, 100%/200% rendering, and backup preservation of all four override fields. Its final contract must be reviewed before native execution after the source is stable. Preparing this harness does not establish migration or override correctness.
