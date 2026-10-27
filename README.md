# Culmina

Culmina is a Flutter/Dart astrophotography planner and observing log.
The Dart package is `astroplan`; `pubspec.yaml` declares version `1.0.0+2`
and Dart SDK constraint `^3.13.3`.

Choose a site, night, target and rig, build a capture plan, check its fit,
save it, then record the outcome of imaging performed outside the app.
Local catalogs, saved plans, calculations and Logbook work offline.
Forecast retrieval, map tiles and optional place-name lookup need a network.

## Screens and features

- **Tonight:** site/night context, target candidates, Night/Moon/Weather
  summaries, planner entry and prompts to record results.
- **Plan:** target/rig selection, visibility and imaging windows,
  light/dark/flat/bias/dark-flat blocks, calibration policies, time budget,
  storage estimates, relative stacking gain and fit; save, copy or start a plan.
- **Night, Moon and Weather:** darkness, target altitude, Moon context,
  calendar browsing and hourly forecasts with source, freshness and missing data.
- **Logbook:** saved plans/results, entry details, filters, target progress,
  text/file sharing and acquisition CSV export for AstroBin.
- **Library:** rigs, catalog/custom targets and sites; Android metadata-assisted
  equipment entry from supported DNG, JPEG, HEIF and FITS files.
- **Settings:** appearance, red field mode, units, planning defaults,
  place-name lookup consent, local backup/restore and About/licenses.

The app does not control cameras or mounts. ISO/gain and AF/MF are descriptive;
unknown measurements stay unknown. Stacking gain is relative, not absolute SNR.

## Development

Use a Flutter SDK whose bundled Dart satisfies `pubspec.yaml`, plus the
Android toolchain for Android builds.

```sh
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --debug
```

These are development commands, not a statement that checks have passed.

## Documentation

- [Product specification](docs/PRODUCT_SPEC.md) — current screens and behavior.
- [Architecture and data](docs/ARCHITECTURE.md) — modules, state and persistence.
- [Design system](docs/DESIGN_SYSTEM.md) — implemented themes and UI tokens.
- [Agent commands](AGENTS.md) — build/test commands and documentation links.

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
