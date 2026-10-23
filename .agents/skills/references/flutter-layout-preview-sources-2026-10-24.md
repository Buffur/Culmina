# Flutter layout and preview source check — 2026-10-24

Dated technical reference for the three local Flutter recipes, not a new policy/status register. [AI_WORKFLOW](../../../docs/AI_WORKFLOW.md) owns documentation research; [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md) owns checks and [design/WORKFLOW](../../../docs/design/WORKFLOW.md#work-modes) owns task modes. Refresh relevant technical facts when the actual SDK or API changes.

## Constraints and ParentData

Context7 resolved Flutter and returned official website documentation for [constraints](https://docs.flutter.dev/ui/layout/constraints) and [adaptive measurement](https://docs.flutter.dev/ui/adaptive-responsive/general), plus [adaptive best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices). They establish finite versus unbounded flex space and local BoxConstraints versus app-window size. A copied example breakpoint is not Culmina policy.

Context7's API queries returned only the widgets index for the precise ancestor question. Direct official API fallback verified [Expanded](https://api.flutter.dev/flutter/widgets/Expanded-class.html), [Positioned](https://api.flutter.dev/flutter/widgets/Positioned-class.html) and [SingleChildScrollView](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html):

- Expanded's path to Row/Column/Flex can contain StatelessWidget/StatefulWidget wrappers, but no intervening RenderObjectWidget. Positioned has the analogous Stack rule. Source-level immediate-child wording is too restrictive; inspect the actual built/render-object path.
- A vertical scroll view can offer unbounded height to its Column. Tight Expanded needs a finite main-axis remainder; a minHeight alone does not supply a finite maxHeight. The official scroll-view examples have specific intrinsic-sizing tradeoffs; they are not universal fixes.

## Widget preview SDK compatibility

Context7 returned the official [Widget Previewer documentation](https://docs.flutter.dev/tools/widget-previewer): preview APIs/targets, customization and the web/native-API boundary. Transitive dart:io/dart:ffi dependencies can load in current versions; invoking unsupported APIs fails. This does not authorize conditional-import rewrites or establish native compatibility.

Read-only local inspection found Flutter 3.47.4 stable, revision `9584c6713b324636289d067944a46fd6b49df14b`, Dart 3.13.3 in the installed SDK's `bin/cache/flutter.version.json`. The project `.metadata` records that same Flutter revision; `pubspec.yaml` requires Dart ^3.13.3. No SDK command, installation, update or preview run was performed.

Inspected SDK files: `packages/flutter/lib/widget_previews.dart` and `packages/flutter/lib/src/widget_previews/widget_previews.dart`. The export and Preview annotation exist; WidgetWrapper takes a Widget and returns a Widget; PreviewThemeData is abstract with apply(BuildContext, Widget); PreviewBuilder exposes build(). The prior inline recipe's concrete PreviewThemeData(materialLight/materialDark) and toPreview() examples do not match this SDK. Their replacements are Markdown-only; no executable .dart examples are present in the three recipe folders.

Existing native fixture sources were inspected, not executed: `test/presentation/design_system/gallery_harness.dart` maps AppTheme.light/dark/fieldTheme; `u_renders_test.dart` loads bundled fonts; gallery/render/transfer/skill fixtures already exist. `AppTheme.fieldFilter` remains the production field-mode safety net. These observations prove available sources/API shapes, not a compiled preview, Android/device result or a new application PASS.
