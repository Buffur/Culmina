# F02 — The approved static splash before Android 12 (evidence)

Environment: the 2026-10-18 cloud container (Flutter 3.47.4 Linux archive). **No Android SDK,
Gradle Android plugin, aapt2 or emulator can be obtained here:** `dl.google.com` (the SDK
repository, and the target of `maven.google.com`'s redirect) is refused by the container's
network policy (`CONNECT tunnel failed, response 403`, 2026-10-18). The remote CI runs the host
gate only, not an Android build.

## Change

`android/app/src/main/res/drawable/launch_background.xml` and `drawable-v21/…`: the navy colour
plus `<item android:drawable="@drawable/ic_launcher_foreground" android:gravity="center"/>`
(the approved R3-final vector mark at its own 108 dp size) instead of a `<bitmap>` over
`@mipmap/ic_launcher`, which on API 26–30 is the adaptive-icon XML (S13V-01). The Android 12+
resources (`values-v31`, `values-night-v31`, `splash_icon_animated.xml`, `MainActivity.kt`'s
held exit and animation-off path) are unchanged.

## Criteria

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F02.A1 | PASS (TEST) | `test/core/config/app_identity_test.dart`: both launch backgrounds contain no `<bitmap` and no `@mipmap/` while `mipmap-anydpi-v26` exists, and draw the centred vector mark over `@color/splash_background`. The new assertion fails on the previous resources (checked by restoring them: `Expected: not contains '<bitmap'`) and passes on the new ones (`+6: All tests passed!`) |
| CHK-F02.A2 | NEEDS ATTENTION | No API 26–30 launch possible in this environment (above). Resume: an environment with the Android SDK and an API 26–30 system image (emulator) or such a device; build the debug APK, cold-start, capture the starting window |
| CHK-F02.A3 | NEEDS ATTENTION (unchanged-resource reasoning only) | The Android 12+ files are byte-identical to `570581e`'s, whose phone recording passed (S13.3 evidence); this is CODE, not a new observation. First-frame vs visible-content times and animation-off remain G2 rows S13V-02/03 |
