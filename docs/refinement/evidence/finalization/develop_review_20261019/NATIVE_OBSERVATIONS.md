# Native review observations — 2026-10-19

Reviewed code: `8048cfa4e7fd5eadc99cba708a02f055ceddd53f`. Host: Windows / Flutter 3.47.4 / Dart 3.13.3. This is review evidence, not an implementation change, production artifact or physical-phone qualification.

## Isolation and tools

The tracked HEAD was exported to `build/finalization/develop_review_20261019/native/`. No owner database, private samples, `android/key.properties` or keystore was copied. Builds used the existing SDK and JBR. A new API 30 Google APIs x86_64 image and AVD were provisioned, with AVD files under this review's ignored build directory and a unique `CulminaReview20261019Api30` name. Only `emulator-5580` was addressed for installation/interaction; no physical device was used. WHPX was available. The emulator ran without a visible window or snapshots.

Minimal command-line tooling was obtained from Google's SDK repository. The latest sdkmanager compatibility wrapper split legacy semicolon package identifiers; the direct Android CLI slash identifier installed the image. The traditional AVD manager required standard SDK placement to discover it. Existing owner files/AVDs were not overwritten. New SDK command-line tools remain under the dedicated `cmdline-tools/review-20261019` directory. No permission or signing settings on an owner device were changed.

## Native compilation and dependency evidence

- Debug APK build: PASS.
- `:app:testDebugUnitTest`: PASS; `MetadataSequentialReaderTest`, four tests, no failures/errors/skips. [Summary](native_unit_summary.json).
- Release dependency graph: PASS. Concrete resolved libraries include Kotlin stdlib 2.4.0, AndroidX core 1.18.0, Kotlin coroutines Android 1.11.0 and Play services location 21.2.0. [Full graph](native_release_dependencies.log). This makes F23's native-notice inventory available; it does not add those notices to the app.
- Diagnostic release APK build: PASS using the documented command **without** `--no-pub`. A first `--no-pub` attempt after debug used a stale integration_test registrant and failed; this is the already documented tooling exception, not a new defect. Lockfile inputs remained unchanged.
- Diagnostic release package `io.github.buffur.culmina`, versionName `1.0.0`, versionCode `1`, minSdk 24, targetSdk 36. `apksigner verify --print-certs` reports **CN=Android Debug**, certificate SHA-256 `56d00b35cb297aceabc42aef7033d41a7b5c7a1939e7d14cf7329672f8902dbe`. APK SHA-256 `1353150df2e54bdd2e4b316f73a7b83192435503b9bcae6ea5a9565fffa48b84`. This is public certificate metadata; no signing secrets were read. The APK is not F26's expected-signer candidate, D6 evidence, a qualified update or a published release.

## F02 A2 — actual API 30 launch

The fresh AVD had no Culmina installation before this review. The diagnostic debug APK installed successfully. API 30, x86_64, 1080×1920 physical pixels, 420 dpi (about 411 logical px), three-button navigation.

The static mark and background appeared ([capture](native_welcome.png)), then the new Welcome screen ([loaded capture](native_loaded.png)). The first `am start -W` timed out at approximately 11.5 s while the debug runtime was starting; later system logs reported the first display/fully drawn event at approximately 24 s under the concurrent review workload. A later debug restart reported approximately 7.25 s. These are **not physical-phone performance, release-build timing, or the accepted Android 12+ animation measurements**. A short recording ended before the first debug launch finished; it cannot establish the full transition timing. The loaded screen confirms eventual transition. No crash was observed.

API 30 establishes the pre-12 static resource result only. API 24/25 and Android 12+ animation/animation-off were not run; S13V-02/03 and physical timing remain outstanding.

## F22 A1 — real background process death, not host restoration injection

The test used the ordinary installed debug app, no modified Flutter entry point. Setup steps were omitted through Start planning; no stored site, plan result or owner record was needed. Planner and a new-site form were opened through visible UI. Unsaved text restoration is outside the existing TD-094 contract; form arguments must safely fall back rather than fabricate a new edit context.

For the counted runs:

1. Open the intended route and dump its native accessibility tree.
2. Press Home; allow Android to finish saving Activity state. Check `mHaveState=true` with a non-null `mIcicle` in dumpsys.
3. Kill only this isolated app process. The debuggable app's run-as kill attempt did not kill it; adbd root was enabled **only inside the disposable emulator**, then shell kill was used. Verify pidof returns no process.
4. Open Recents, identify the existing Culmina snapshot and tap it. Wait for Flutter to finish loading; dump the new tree and confirm a new PID.

| Route | Before / absent / after PID | Result | Evidence |
| --- | --- | --- | --- |
| Planner | 7972 / absent / 8192 | **PASS**: returns to Plan, with the original empty/missing-site context; no unexpected plan/site adopted | [Before tree](native_planner_confirmed_before.xml), [after tree](native_planner_confirmed_after.xml), [restored capture](native_planner_confirmed_after.png), [Android state facts](native_activity_before_kill.txt) |
| New-site editor | 8192 / absent / 8497 | **PASS for documented safe fallback**: returns to Sites with no stored site or invented editor args | [Before tree](native_form_confirmed_before.xml), [after tree](native_form_confirmed_after.xml), [fallback capture](native_form_confirmed_after.png), [Android state facts](native_form_activity_before_kill.txt) |

Earlier attempts either failed to kill the app, used an explicit launch instead of Recents, or killed before saved state was confirmed; those do **not** establish F22 acceptance or a route-restoration defect. The counted runs above supersede them. This illustrates why a PID change and saved-state/route observations are needed, beyond host `getRestorationData/restoreFrom` tests.

Limits: one API 30 debug emulator, empty Planner and site-form fallback. No saved-result mutation, named-plan/result-status native kill matrix, physical phone, owner-data migration, restore-during-activation, TalkBack, Android 12+, release-build lifecycle or full G1 L1–L6/L8 sweep is claimed. Keep the corresponding rows open.

## Cleanup

The isolated emulator is stopped after review. The ignored AVD/build artifacts are retained for reproducibility. No owner app is uninstalled, and no owner data or SDK directory is recursively deleted.
