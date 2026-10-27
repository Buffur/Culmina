# Culmina

Culmina is a Flutter/Dart astrophotography planner and observing log.
The Dart package is `astroplan`; `pubspec.yaml` declares version `1.0.0+2`
and Dart SDK constraint `^3.13.3`. Android is the primary application target.

Choose a site, night, target and rig, build a capture plan, check its fit,
save it, then record the outcome of imaging performed outside the app.
Local catalogs, saved plans, calculations and Logbook work offline.
Forecast retrieval, map tiles and optional place-name lookup need a network.

The main tabs are **Tonight, Logbook, Library and Settings**. The **Plan**
opens above the tab shell and combines capture/calibration blocks, usable night
windows, time budgets, storage estimates and relative stacking gain. Night,
Moon and Weather detail views explain conditions and forecast freshness.
Library manages rigs, catalog/custom targets and sites. Settings includes
Light, Dark and Field Red themes, units, planning defaults and local backups.

The app does not control cameras or mounts. ISO/gain and AF/MF are descriptive;
unknown measurements stay unknown. Stacking gain is relative, not absolute SNR.

## Development

Use a Flutter SDK whose bundled Dart satisfies `pubspec.yaml`, plus the
Android toolchain for Android builds.

```sh
flutter pub get
flutter run
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug
```

These are development commands, not a statement that checks have passed.

## Project map

`lib/presentation/` contains UI and Provider/ViewModels; `lib/domain/` owns
models, interfaces and calculations; `lib/data/` implements storage and services;
`lib/core/` contains time, units, diagnostics and theme tokens. Drift currently
uses schema v27, with exported snapshots in `drift_schemas/`.

- [Shared agent instructions](AGENTS.md) — architecture, invariants, generation and render commands.
- [Project skills](.agents/skills/README.md) — 26 focused Dart, Flutter and design recipes.
- [Visual Atlas](.audit/atlas/index.html) — archived synthetic Flutter host captures;
  inspect its [manifest](.audit/atlas/manifest.json) before reusing evidence.
- [Product overview](docs/PRODUCT_SPEC.md), [architecture](docs/ARCHITECTURE.md)
  and [design system](docs/DESIGN_SYSTEM.md) — supporting documentation; verify against source.

`design/` is currently empty. Browser comparison helpers under `tool/design/`
retain historical workflows whose lab inputs are absent. The native Flutter
render harness remains available through the commands in `AGENTS.md`.

## License

See [LICENSE](LICENSE), [catalog attribution](assets/catalog/OPENNGC_NOTICE.txt)
and the in-app license page for bundled dependencies, fonts and icons.

**License exception.** The app is GPL-3.0. Its Android build includes Google Play services
location (through `geolocator`), so the licensors add:

> Additional permission under GNU GPL version 3 section 7: if you modify this program, or any
> covered work, by linking or combining it with the Google Play services libraries (or a modified
> version of those libraries), containing parts covered by the terms of the Android Software
> Development Kit License, the licensors of this program grant you additional permission to convey
> the resulting work.
