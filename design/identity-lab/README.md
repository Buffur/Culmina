# Culmina identity and launch — consolidated implementation

Current implementation (2026-10-24): the approved rounded R3 mark and the complete Flutter launch gesture are integrated with the completed Hybrid design and geo refinements. `LaunchGate` plays the full1,400ms sequence, then reveals the initialized app; reduced motion skips the gesture. Android provides a matching still splash and the handover channel. `tool/culmina_mark.py` generates native assets, Dart geometry/timeline and `lib/core/theme/culmina_mark_colors.dart` from one source. The demo and widget previews use that timeline.

Earlier600ms native-launch measurements and proposals below are historical and superseded by the full-gesture decision in `docs/DECISIONS.md`. Raw phone evidence from the old local identity commit is retained in the external Git bundle at C:/Users/zalub/CulminaQA/2026-10-24/consolidation/all-local-refs.bundle; it is excluded from this public delivery, including the launcher crop showing other owner applications. References to those historic images below describe external evidence, not files shipped in this tree.

## Historical design study

# Culmina identity lab — Stage A (2026-10-23)

Owner request 2026-10-23: audit the Culmina mark, app icon and launch animation and propose up to three directions (Stage A); implementation (Stage B) only after the owner chooses. **Proposals only:** nothing here is wired into the app, and no production resource, launch behaviour, dependency or document of record was changed.

## Files

| Path | Role |
| --- | --- |
| `geometry.py` | The single source of geometry for the current mark (R3-final, as shipped) and concepts A, B, C on the 108-unit adaptive canvas; `frame(t)` per concept, `t = 1` is the static mark |
| `build.py` | Generates `marks/*.svg` and `index.html` from `report.template.html`; `--embed OUT` writes a self-contained copy outside the repository |
| `index.html` | The Stage A report (Ukrainian, the owner's working language): audit, sources, concept comparison, storyboard with a live preview, launch logic, Stage B plan, unverified items |
| `marks/` | SVG masters: monochrome and navy colourway of each variant |
| `evidence/phone-cold-start-2026-10-23.png` | Cold-start frames from the owner's phone, cropped to the mark |

Run `python design/identity-lab/build.py` (no dependencies beyond Python 3). Open `index.html` directly; it loads `assets/fonts/Geist.ttf` relatively.

## Findings (summary; detail and evidence in `index.html`)

- **Current decisions in force:** R3-final approved 2026-10-17 and the one-second splash held until it has played (owner, 2026-10-17; `docs/DECISIONS.md`). The new brief forbids an artificial minimum splash time, so Stage B needs an explicit owner decision replacing the hold.
- **Observed** (Xiaomi 14T Pro, Android 16, installed `io.github.buffur.culmina` 1.0.0, one cold start, `TotalTime` 749 ms): the HyperOS launch transition hides the orbit drawing; the mark is shown complete, then stays visible over the app content while the splash background fades (contrary to `MainActivity.kt`'s intent); navy `#0B1230` changes to the app's `#191919`.
- **From code:** four hand-kept copies of the geometry (three XML, `tool/make_launcher_icons.py`, `startup_mark.dart`); field mode is unknown to the native splash (bright splash before the red UI); iOS/web/macOS/Windows icons and the iOS launch screen are still the Flutter template (`bb327e2`); `StartupMark` size and background differ from the splash; `AppMotion` ignores iOS Reduce Motion.
- **Not verified:** warm/hot resume (the recording did not show the app), light mode, field mode, reduced motion, offline/error/slow first launch on a device, pre-Android 12, iOS, `setSplashScreenTheme` persistence. The phone appeared to be in use during the recording, so phone work stopped after one run.

## Recommendation

**A · Refined orbit** (evolution of R3-final): same orbit, centre, 40° axis and opening; inner orbit 2.4 → 3.2 so it survives 24 px; the curved sparkle replaced by a photographed star (core + diffraction spikes), with the current sparkle kept as option A′; motion: the orbit is static from the first frame and only the star travels 58° along it, the orbit closing behind it (≈ 560–600 ms, `AppMotion.curve`), cut short whenever the app is ready. B (star trail) is the stronger alternative; C (meridian transit) is not recommended as the mark.

Sources and access dates are listed in `index.html` §7.

## Iteration 2 — R3 developed (2026-10-23)

The owner kept the R3-final image (two open circular trajectories, a star at the upper right), stopped directions B and C, and asked for a light-base study and a stronger execution of R3. Files: `r3.py` (parametric R3; `R3_ORIGINAL` reproduces the shipped vector), `build_r3.py`, `r3.template.html` → `r3.html`, `r3/svg/` (editable vectors), `r3/png/` (1024 px renders; lockups 1600 × 400), `r3/light_share.txt` (measured share of light pixels per tone).

- **Step 1, tone on unchanged geometry:** control (navy), A light base, B blue field, C refreshed dark. B fails: orbit 4.0:1 and inner arc 2.6:1 on the field, and the white star merges with the white orbit. A light gives the clearest silhouette and stands apart from the dark astronomy icons studied (Stellarium Mobile, Stellarium, Siril, Stargazing Hub); C is the alternative that keeps "light in the night".
- **Step 2, geometry on the light base:** R3·1 (delicate) wins only at 24 px and loses the open composition at large size; R3·2 (stronger) sets outer 6.4 / inner 3.2, one 3.6 spacing module, a 120° inner opening and a star whose rays end on the orbit's top and right tangents (the mark fits one 50.3-unit square). Recommended: **R3·2 on the light base**; compromise: the star becomes a blue mark on a light field rather than light in the dark.
- Reference icons were viewed on official pages (App Store, siril.org, stellarium.org) and described, not copied; the home-screen neighbours are neutral placeholders.
- Not done: no motion was built, no launcher install, no production change.

## Iteration 3 — the owner's choice (2026-10-23)

The owner chose **C · refreshed dark** (field `#1B2A63` → `#0B1230`, orbit `#F5F7FD`, inner arc `#A4B2E2`, star `#A3D8FF`) on the **unchanged R3 geometry**, and asked only to smooth the star's tips. `r3.py` gained `tip_round` / `tip_keep` and `R3_ROUND` (sharp, soft 0.08, medium 0.14, strong 0.22): each side keeps R3's curve, is trimmed near the tip, and the tip is closed by a curve whose control point is the old sharp tip; the rays are lengthened (+0.7 / +1.2 / +2.0 units) so the star keeps its 19.2-unit span. `R3_ORIGINAL.body` corrected 1.53 → 1.54 to match the vector exactly. Proposed: **medium** (needle tips gone from 48 px, sides and body unchanged, every end in the mark now round); strong reads as drop-shaped tips and changes the star. Exports: `r3/svg/chosen-*.svg`, `star-tips-*.svg`, `lockup-chosen-*.svg` and their PNGs. Still a proposal: no production asset changed.

## Final mark and launch gesture — implemented (2026-10-23)

Owner brief: R3 → "C · refreshed dark" → medium rounding of the star's tips; finalise the static mark, then build the launch motion; no minimum splash time. Decision record: `docs/DECISIONS.md` E.1, "The Culmina mark finalised and its launch gesture". Nothing is committed.

### Static checks (no correction needed)

| Question | Evidence | Result |
| --- | --- | --- |
| A. Space around the star | Geometry: nearest star–orbit distance 1.98 units; render at 24/32/48 dp × 3.25 (the phone's density) and at 1×; the icon on the phone's HyperOS launcher (`evidence/launch-2026-10-23/home-screen-hyperos.png`) | ≈ 2 px at 24 dp on the phone, separate at every size; touches only at 24 px on a 1× screen (mdpi legacy). Kept |
| B. Inner arc at 24/32/48 dp | Same renders | Readable and second to the orbit (stroke 2.4 vs 6, `#A4B2E2` vs `#F5F7FD`). Kept |
| C. Optical centring | Ink centroid (53.2, 54.6) vs canvas centre (54, 54); orbit concentric with round masks; star corner 30.0 units from centre (safe-zone radius 33) | Within 1 unit; the round-5 decision (orbit on the centre) still holds. Kept |

The only changes to the approved artwork are the owner's: the refreshed dark colours and the rounded star tips. Field-mode colours were corrected once on the device (the star had been brighter than the orbit; now orbit `#990000` > star `#850000` > inner `#5C0000`).

### One source

`tool/culmina_mark.py` (replaces `tool/make_launcher_icons.py`) generates: the icon's background (gradient), foreground and monochrome layers; `splash_mark_{light,dark,field}.xml` (Android 12+ animated); `launch_mark.xml` in `drawable` and `drawable-night` (before Android 12); the legacy PNGs and `assets/branding/icon_512.png`; `lib/presentation/shared/culmina_mark_geometry.dart`; and `launch-demo.html` here (from `launch-demo.template.html`). The arc path data is byte-identical to R3-final's vector.

### Launch

- **Gesture (600 ms, native):** the complete mark from the first frame; a light runs along the inner arc (0–360 ms, its own width and caps), the star takes up the accent (300–430 ms) and returns (430–600 ms). The end state is the static mark, so animator scale 0 shows it unchanged.
- **Nothing waits for it:** the splash leaves at the app's first frame; the mark fades (120 ms), then the splash background (120 ms), which is the first screen's own colour.
- **Splash surface:** the mark itself (no icon tile) on `#FFFFFF` / `#191919` with the system's dark mode; on Android 13+ the app's Light/Dark choice and field mode set the next launch's splash (`SplashScreen.setSplashScreenTheme`, channel `io.github.buffur.culmina/splash_theme`).
- **Flutter:** `StartupCover` shows the same mark, still, 288 dp canvas, centred above the shell, only while startup still loads after the first frame. The breathing star is gone.
- **Demo stand:** `launch-demo.html` — play, ×4 slow motion, scrubbing, key frames, light/dark/field, reduced motion, and a simulated "app ready at t" that fades from the current frame. Slow motion and the simulated moment exist only there.

### Device evidence (owner's Xiaomi 14T Pro, Android 16 / HyperOS, release `io.github.buffur.culmina.s2check`, debug-signed, built in a separate worktree from `01b8049` + this change; the owner's apps untouched)

| Scenario | Result | Evidence |
| --- | --- | --- |
| Native size and position | Mark 442 px wide at 3.25× = 136 dp → 108-unit canvas ≈ 288 dp, centred on the screen; `StartupMark` uses the same | measured on `cold_1` |
| Fast cold start | The gesture is visible (light on the inner arc at ≈ 150 ms, star accent ≈ 100 ms later); the mark fades first, no ghost over content | `cold-start-dark-frames.png` |
| Time to usable UI | Launch transition → app fully shown and still: **≈ 1,250 ms** with the old held splash (HEAD, 4 runs) vs **≈ 520–660 ms** now | `measure.py` over the recordings |
| First launch after install (catalog seeding) | Splash stays static on the mark until the first frame; no loop | `first_install` recording |
| Hot start (back from background) | No splash; the app is shown directly (`TotalTime` 91–109 ms) | `hot-start-no-splash.png` |
| Field mode saved | Next cold start: black splash, dim red mark, no bright frame | `field-mode-cold-start.png` |
| App Light while the system is dark | White splash with the navy mark, then the light app | `app-light-on-system-dark.png` |
| Launcher icon | Renders cleanly in HyperOS's squircle among real apps | `home-screen-hyperos.png` |
| Hand-over flicker | In 2 of 3 recorded runs the mark vanished for 1–2 frames (16–33 ms) when the system handed the splash to the app; the system's own exit (no listener, tried and rejected) showed the same gap **and** the mark over the content | `exit-handover-frames.png`, `rejected-system-exit.png` |

### Not verified

Reduced motion on the device (changing the phone's animator setting is the owner's call; the AVD's end state is the static mark by construction and is tested); launch without network on the device (from code: nothing before the first frame uses the network; the forecast starts after it); an initialisation error on the device (covered by existing widget tests: the database recovery screen and Retry); Android 12 (API 31–32) and before 12 (static splash; an emulator on API 30 was running but belonged to another session, so it was not used); iOS (launch screen and icons are still the Flutter template; out of scope here); a dark wallpaper (the owner's wallpaper was not changed); profile-mode frame timing.
