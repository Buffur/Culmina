# Hybrid transfer capture tooling (2026-10-22)

Test/design tooling only; never imported by the app and never writes `design/home-lab`.

- `webcap.cjs` — captures the web reference's phone frame and dumps computed styles.
  `REPO=<repo root> node tool/design/hybrid_transfer/webcap.cjs <spec.json> <outDir>` with the preview served by
  `python design/home-lab/scripts/serve_preview.py --port 4197`. Spec: `{"name", "shots":[{"id","file","query",
  "frame","width","height","theme","dpr","css","steps":[{click|fill|check|press|scroll|scrollTo|eval|wait}],
  "dump","fullFrame"}]}`. Set the frame width to 377 for a 375 content box; Home uses
  `"frame": ".concept.variant-blend .app-frame"` and its fake status row is the top 29 px.
- `pair.py` — side-by-side PNG pair: `python pair.py left.png right.png out.png [y0 y1] [scale]`.
- `cmptext.py` — matches the web dump with the Flutter host-render text dump by visible text and prints
  size/weight/leading/tracking/colour/position deltas: `python cmptext.py web.json flutter.json [rows] [webYOffset]`.

Flutter side: `test/presentation/design_system/hybrid_transfer_renders_test.dart` (host, opt-in
`ASTROPLAN_HYBRID_RENDERS`, `_SIZE`, `_THEMES`, `_SHOTS`) and `integration_test/hybrid_transfer_capture_test.dart`
(disposable emulator only, `flutter drive -d emulator-5554 --driver=test_driver/hybrid_migration_driver.dart`).
