---
name: flutter-add-widget-test
description: Add a focused Culmina widget behavior or regression test using existing flutter_test hosts, themes and handwritten fakes.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 21:15:41 GMT
---

# Culmina widget tests

Use for a named component behavior or regression. Follow [AGENTS](../../../AGENTS.md), read the affected widget and existing tests, and reuse `flutter_test`, which is already declared in `pubspec.yaml`.

1. Put the test under the matching `test/presentation/` area with an `_test.dart` suffix. Reuse `test/support/` fakes and existing local fixtures/providers rather than introducing a demo app or mocking dependency.
2. Build the smallest representative host with the actual Culmina theme and required providers/localizations. Inspect `test/presentation/design_system/gallery_harness.dart` for shared rendering needs; do not force every behavior test through the gallery.
3. Assert observable initial state, perform the relevant interaction using stable finders, pump the required frames, then assert the resulting state or callback. Preserve assertions for missing/error/disabled data where the behavior depends on them.
4. Use bounded pumping when work/animations do not settle. Do not add arbitrary delays or replace a failing meaningful assertion with a screenshot.
5. Run `flutter test --no-pub test/<actual_file>_test.dart` and the affected checks described in AGENTS. The angle-bracket path is a placeholder; select an existing or newly authored test.

For layout/theme work, exercise relevant width, scaler, long-label and Light/Dark/Field Red cases. A static render test records pixels/geometry for its fixture; it does not establish screen-reader, physical-device or owner acceptance.

Report the tested behavior, fixture/state, command/result and limits.
