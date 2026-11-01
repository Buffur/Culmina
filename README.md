<p align="center">
  <img src="assets/branding/icon_512.png" alt="Culmina app icon" width="112">
</p>

<h1 align="center">Culmina</h1>

<p align="center">
  <strong>Plan the night. Fit the plan. Log what you captured.</strong><br>
  A free, open-source astrophotography planner and observing log for Android.
</p>

<p align="center">
  <a href="https://buffur.github.io/Culmina/">Project page</a> ·
  <a href="https://buffur.github.io/Culmina/privacy/">Privacy policy</a> ·
  <a href="https://github.com/Buffur/Culmina/releases">Releases</a> ·
  <a href="LICENSE">GPL-3.0</a>
</p>

---

## What Culmina is

Culmina answers the question every imager asks before a night under the sky:
**is this plan realistic for tonight?** Pick a site, a night, a target and your
rig, lay out the exposures you want, and see whether they fit the time the sky
actually gives you. Save the plan, shoot with whatever software and hardware you
already use, then come back and record what really happened.

It is a planner and a logbook. It does **not** control cameras, mounts or
any other equipment.

```
Site + night  →  Target + rig  →  Capture plan  →  Does it fit?  →  Save
                                                                      ↓
                          Logbook  ←  Record the result  ←  Image outside the app
```

## What you can do

- **See the night.** Darkness, twilight, Moon phase and position, target
  altitude and a multi-night forecast (Open-Meteo, up to 16 days ahead) for any
  saved site, with the forecast's source and freshness always shown.
- **Find a target.** Browse a bundled catalog of Messier objects and well-known
  imaging targets (a subset of OpenNGC), search by designation, common name or
  alias, add your own, and let Culmina rank what suits the night.
- **Build a capture plan.** Ordered light, dark, flat, bias and dark-flat blocks
  with exposure, count, filter, ISO/gain and binning, calibration timing, and
  optional overheads such as dither, refocus, filter changes and meridian flips.
- **Check the fit.** Integration time, overheads, usable dark windows (target
  altitude, Moon and optional cloud limits), storage estimates and a relative
  stacking-gain curve are weighed against the time you really have.
- **Describe your gear.** Save rigs, sites and targets in the Library. Add a rig
  from a photo: Culmina reads the header of a DNG, JPEG, HEIF or FITS file on
  your device to suggest the camera and optics — you review before anything is
  saved.
- **Keep a logbook.** Record each night as completed as planned, partial or not
  done, with notes and observed conditions. Review progress per target and
  filter, share a session, export it, or preview an AstroBin acquisition CSV.
- **Work in the field.** Light, Dark and a dedicated Field Red theme that
  protects night vision, plus configurable units.
- **Own your data.** Back up and restore everything locally, in a file you
  control.

## Honest by design

Astrophotography planning is full of estimates, and Culmina tries not to
pretend otherwise.

- **Unknown stays unknown.** A missing value is never silently turned into zero
  or a made-up default; sensor specifications, catalog values and measurements
  are never invented.
- **Relative, not absolute.** The stacking-gain curve shows relative improvement,
  not a physical signal-to-noise ratio. Storage estimates say whether they come
  from a file, a stated size or a calculation.
- **Descriptive settings.** ISO/gain, autofocus/manual focus and white balance
  are recorded as you describe them, not as measured numbers.
- **A draft is not a saved plan.** Edits stay a draft until you choose
  *Save plan*, and a recorded result stays distinct from the plan it came from.

## Offline-first and private

Catalogs, saved plans, astronomy calculations and the Logbook all work without a
connection. Culmina has **no account, no advertising, no analytics and no
tracking**; your data lives in the app's private storage on your device.

The network is used only for:

| Purpose | Service | When |
| --- | --- | --- |
| Weather forecast | Open-Meteo | when you load or refresh a forecast |
| Map images | OpenStreetMap tiles | while you pick a position on the map |
| Place names | OpenStreetMap Nominatim | only if you switch on *Look up place names* (off by default) |

Location is requested only when you tap *use current position*. The full
details are in the [privacy policy](https://buffur.github.io/Culmina/privacy/).

## Status and installation

Culmina **1.0.0** is built for Android (minimum API and target API come from the
Flutter toolchain in use). Signed APKs are distributed through the repository's
[GitHub Releases](https://github.com/Buffur/Culmina/releases) page; installing
one means allowing your browser or file manager to install apps from outside a
store.

Coming from **Astro Planner**, the app's earlier name? Culmina installs beside
it with an empty database. Use *Settings → Back up now* in Astro Planner,
then *Settings → Restore* in Culmina to bring your sites, rigs, targets and
sessions across.

## Built with

[Flutter](https://flutter.dev) and Dart, with SQLite through
[Drift](https://drift.simonbinder.eu), Provider for state, go_router for
navigation and flutter_map for the position picker. Target data is an adapted
subset of [OpenNGC](https://github.com/mattiaverga/OpenNGC) (CC BY-SA 4.0);
forecasts come from [Open-Meteo](https://open-meteo.com); maps and place names
from [OpenStreetMap](https://www.openstreetmap.org). The interface is set in
Geist.

## Build from source

You need a Flutter SDK whose bundled Dart satisfies `pubspec.yaml`
(`^3.13.3`) and, for Android builds, the Android toolchain.

```sh
flutter pub get
flutter run
flutter test --no-pub
flutter build apk --debug
```

Contributors and coding agents: start with [AGENTS.md](AGENTS.md) for the
architecture, invariants and verification commands. Supporting notes live in
[docs/](docs/): [product behaviour](docs/PRODUCT_SPEC.md),
[architecture](docs/ARCHITECTURE.md) and [design system](docs/DESIGN_SYSTEM.md).

## License

Culmina is free software under the [GPL-3.0](LICENSE). See the
[catalog attribution](assets/catalog/OPENNGC_NOTICE.txt) and the in-app license
page for bundled dependencies, fonts and icons.

**License exception.** The app is GPL-3.0. Its Android build includes Google Play services
location (through `geolocator`), so the licensors add:

> Additional permission under GNU GPL version 3 section 7: if you modify this program, or any
> covered work, by linking or combining it with the Google Play services libraries (or a modified
> version of those libraries), containing parts covered by the terms of the Android Software
> Development Kit License, the licensors of this program grant you additional permission to convey
> the resulting work.
