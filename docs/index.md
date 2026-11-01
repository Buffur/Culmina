---
title: Culmina
---

<p align="center">
  <img src="assets/culmina-icon.png" alt="Culmina app icon" width="112">
</p>

# Culmina

**Plan the night. Fit the plan. Log what you captured.**

Culmina is a free, open-source astrophotography planner and observing log for Android. Choose a
site, a night, a target and your rig, build a capture plan, and see whether it fits the time the sky
actually gives you. Save it, image with the equipment and software you already use, then record
what really happened.

It has no account, no advertising, no analytics and no tracking, and it works offline.
It plans and records; it does not control cameras or mounts.

- [Privacy policy](privacy/)
- [Source code (GPL-3.0)](https://github.com/Buffur/Culmina)
- [Releases](https://github.com/Buffur/Culmina/releases): signed APKs for Android

## What it does

**See the night.** Darkness and twilight, Moon phase and position, target altitude and a
multi-night weather forecast for each saved site, with the forecast's source and freshness shown.

**Choose a target.** A bundled catalog of Messier objects and well-known imaging targets,
searchable by designation, common name or alias, plus your own custom targets. Culmina can rank
which targets suit the night.

**Build a capture plan.** Ordered light, dark, flat, bias and dark-flat blocks with exposure, count,
filter, ISO/gain and binning, calibration timing, and optional overheads for dither, refocus, filter
changes and meridian flips.

**Check the fit.** Integration time and overheads are weighed against the usable dark window
(target altitude, Moon and optional cloud limits), with storage estimates and a relative
stacking-gain curve.

**Describe your gear.** Keep rigs, sites and targets in the Library. *Add from a photo* reads the
header of a DNG, JPEG, HEIF or FITS file on your device to suggest a rig; you review it before
anything is saved.

**Keep a logbook.** Record each night as completed as planned, partial or not done, with notes and
observed conditions. Review progress by target and filter, share or export a session, or preview an
AstroBin acquisition CSV.

**Work in the field.** Light, Dark and a Field Red theme that protects night vision, configurable
units, and local backup and restore you control.

## Honest by design

- Unknown stays unknown: a missing value is never turned into zero or an invented default.
- Stacking gain is relative, not an absolute signal-to-noise ratio, and each storage estimate says
  where it comes from.
- ISO/gain, focus mode and white balance are descriptive, not measured.
- A draft is not a saved plan, and a recorded result stays distinct from the plan behind it.

## Privacy at a glance

Your sites, equipment, plans and results stay in the app's private storage on your device; the
developer has no server. The network is used only for weather forecasts
([Open-Meteo](https://open-meteo.com)), map images (OpenStreetMap) and, only if you switch it on,
place names (OpenStreetMap Nominatim). Location is requested only when you choose *use current
position*. Read the full [privacy policy](privacy/).

## Install

Culmina 1.0.0 is distributed as a signed APK on the
[Releases](https://github.com/Buffur/Culmina/releases) page. Coming from **Astro Planner**, the
app's earlier name? Culmina installs beside it with an empty database: use *Settings → Back up now*
in Astro Planner, then *Settings → Restore* in Culmina.

## Open source

Culmina is written in Flutter and Dart and released under the GPL-3.0 licence, with an additional
permission for the Google Play services location library. Target data is an adapted subset of
[OpenNGC](https://github.com/mattiaverga/OpenNGC) (CC BY-SA 4.0). The code, build instructions
and licence details are in the [repository](https://github.com/Buffur/Culmina).

Questions about the app or this page:
[culmina.app@gmail.com](mailto:culmina.app@gmail.com)
