# Android release and signing

Distribution: signed APKs on GitHub Releases. Google Play/App Bundle publication is deferred, not the current release path. This runbook grants no signing, installation or publication authorization. Version/signing facts below are source-backed; historical build results are not current qualification.

## Data migration from Astro Planner

Culmina (`io.github.buffur.culmina`) installs beside the earlier `io.github.chacha12.astroplanner` with an empty database; Android Auto Backup does not transfer data between app IDs. In Astro Planner, use Settings → Back up now; keep the `.astroplan` file. Install Culmina, use Settings → Restore, confirm the backup date and reopen. Check sessions/sites/rigs/targets before manually uninstalling the old app. Older backups can migrate forward; newer unsupported backups are refused. Include this in the first Culmina release notes.

## Signing and version invariants

- `android/app/build.gradle.kts` requires complete `android/key.properties` for release packaging and rejects an Android Debug certificate. There is no debug-signing fallback. Local development uses `flutter run --debug` or `flutter run --profile` without a distribution key.
- The signing key, passwords and backups belong to the owner. Never commit or request these secrets from the owner; `key.properties`, `*.jks` and `*.keystore` stay ignored. Keep the key and recovery copy outside the repository.
- Owner-local `android/key.properties` supplies `storePassword`, `keyPassword`, `keyAlias` and `storeFile`. GitHub Releases serves the resulting owner-signed APK directly; no store re-signs it. Keep the same distribution key for updates.
- Increment `pubspec.yaml` version `X.Y.Z+N`; keep `AppIdentity.version` in `lib/core/config/app_identity.dart` equal to `X.Y.Z`. Android version code `N` must exceed previously distributed builds (and all uploads if a store is later used).
- SDK defaults come from the selected Flutter SDK; inspect current build/CI configuration rather than copying old numeric API requirements. R8/shrinking and native-symbol output follow the Flutter Gradle plugin; add ProGuard rules only for a demonstrated release failure.

## Authorized release procedure

1. Run the applicable final quality gate, `dart run tool/check.dart`, and satisfy named release/device/owner criteria. Reuse unchanged-input evidence only with its baseline recorded.
2. Build with `flutter build apk --release`; resolve dependencies/plugin registration before the build. A prior dev integration-test registrant can cause release compilation failure; do not preserve stale generated registration merely to avoid dependency resolution.
3. Verify the actual APK using the installed Android SDK Build Tools: `apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-release.apk`. Compare its certificate SHA-256 with the owner's expected distribution certificate and the previously published APK; reject Android Debug. Retain the APK SHA-256, version and install/update-test evidence, and exercise the core loop on the authorized device. Build success alone does not prove installation, startup, data compatibility or release readiness.
4. Preserve release notes, APK, checksum and matching source/CI/verification references. Publish to GitHub Releases only under the applicable owner task; keep signing material private.

App Bundle tooling remains available for a separately authorized store task: `flutter build appbundle --release` produces `build/app/outputs/bundle/release/app-release.aab`; `dart run tool/check_bundle.dart` checks bundle libraries/symbols and rejects the Android Debug signer. That checker is not APK qualification. Store accounts, upload keys, API deadlines, Data Safety and signing-service configuration require a fresh scoped review before use.

## Completed historical measurements

### Superseded signing policy (2026-11-06)

Previously, missing `key.properties` selected the debug key for release builds, relying on Google Play to reject the artifact. That protection did not apply to GitHub Releases. The current packaging guard replaces that fallback; the measurements below remain historical evidence only.

- [DONE] 2026-09-24: Built a debug-signed release bundle; alignment/symbol checks passed and the signer check rejected it as intended (files: `android/app/build.gradle.kts`, `tool/check_bundle.dart`; historical artifact, not current release evidence).
- [DONE] 2026-09-30: Recorded 68.5 MB multi-ABI bundle, about 24.8 MB arm64 APK and 27.8 MB installed; debug size was substantially larger (files: local `archive/evidence/STAGE_10_MEASUREMENTS.md`; measurements apply only to that build).

Do not adopt optional obfuscation/split-symbol changes from historical size experiments automatically: split symbols require preserving each release's external symbol files, and obfuscation was not recommended for this open-source project. Cross-drive Kotlin incremental-cache failures require a reproduced environment-specific diagnosis, not a permanent application workaround.
