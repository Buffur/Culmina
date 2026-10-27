---
name: flutter-add-widget-preview
description: Create or update an isolated Flutter widget preview only for a named preview task. First inspect existing Culmina gallery/render fixtures and actual SDK support; ordinary UI fixes do not require preview infrastructure.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 20:05:23 GMT
---

# Previewing Flutter widgets

Local Culmina amendment, 2026-10-24; upstream frontmatter metadata is retained. Use only when an isolated preview is part of the requested task. Do not add preview annotations, a preview scaffold, dependencies or conditional-import refactoring merely because a UI component changes. Follow [AGENTS](../../../AGENTS.md).

## Preview guidelines

1. Inspect existing native fixtures first: `test/presentation/design_system/gallery_entries.dart`, `gallery_harness.dart`, `render_gallery_test.dart`, `u_renders_test.dart`, `hybrid_transfer_renders_test.dart` and `skill_application_test.dart`. Reuse an appropriate fixture/host render for the requested state before proposing infrastructure.
2. Check the actual SDK/API and available preview tooling without installing/updating them. Preview APIs evolve; a package's minimum Dart constraint is not proof of the active Flutter version. The [dated SDK/source check](../references/flutter-layout-preview-sources-2026-10-24.md#widget-preview-sdk-compatibility) records what was inspected here, not a permanent version promise or a running-preview result.
3. For an authorized preview implementation, `package:flutter/widget_previews.dart` supplies Preview. Use supported public top-level functions/static methods returning Widget/WidgetBuilder or eligible public widget constructors/factories without required arguments. Annotation values must be constant; callbacks supplied to annotations must be static/top-level and public. Confirm exact targets and signatures in the installed API.
4. Supply the requested context/constraints, state fixtures and Culmina themes: `AppTheme.light`, `AppTheme.dark`, `AppTheme.fieldTheme` in `lib/core/theme/app_theme.dart`, not arbitrary ThemeData.light/dark. Preserve the production field filter where applicable and load the actual bundled fonts for typography comparisons. A theme's brightness alone does not select field mode.
5. Choose a wrapper/theme hook supported by that SDK, keep the scenario isolated, and retain all recorded evidence limitations. See the Markdown-only example below; no .dart preview file is created by this recipe.

## Handling limitations

The Widget Previewer runs on Flutter Web. Native plugins and invoking dart:io/dart:ffi APIs are unsupported; a transitive import alone is not proof that loading fails in current versions. A native gallery/host fixture may be the suitable route for such a widget. Prefer existing injected fakes/seams; do not restructure production imports automatically to make a preview compile. Record a required .dart/example/infrastructure change as separate work if the current task does not authorize it.

Check asset loading paths for the actual loader/package and preview environment. Public callbacks, constraints, fonts, providers/localizations and error/loading/disabled state are part of the preview scenario, not optional evidence to infer from its appearance.

## Examples

A public wrapper can provide the Culmina theme without depending on a version-specific PreviewThemeData constructor. This Markdown example matches the inspected 3.47.4 `WidgetWrapper = Widget Function(Widget)` signature; confirm it for another SDK. It is a static source example, not compiled or runtime-tested evidence.

```dart
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

Widget culminaLightPreview(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

@Preview(name: 'Culmina light', wrapper: culminaLightPreview)
Widget labelPreview() => const Text('Unknown');
```

Use the corresponding existing theme/field wrapper for other requested scenarios. In the inspected SDK, PreviewThemeData is abstract and custom implementations override apply; PreviewBuilder returns a Preview through build(), not toPreview(). Do not copy the superseded generic theme/builder examples. No executable .dart example files exist in this recipe directory at this task's baseline, so none need editing here.

## Workflows

Only for an authorized preview run, use the installed supported IDE route or `flutter widget-preview start` after confirming that command exists in that SDK. Do not assume every IDE auto-starts a previewer or launch a browser/server in a documentation task. Capture the exact widget state/theme/size/scaler and actual launch/result; a static API check is not runtime compatibility proof.

## Finish

Apply [AGENTS](../../../AGENTS.md) for the actual change class. Report whether existing fixtures sufficed, actual SDK/API, changes made or separately needed, rendered evidence and limits. A browser/widget preview is not Android, physical-device, accessibility certification or owner acceptance; do not close those rows from it.
