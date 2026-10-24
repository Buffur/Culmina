# Home layout fixes and typography inspection — 2026-10-24

Scope: the owner's annotated phone feedback, web-server request, font inspection and separate Notion-style Home concepts. Base/worktree: primary checkout, `develop` at `a4798d667007a83e12de3c94d95bb68c22947748`, upstream `origin/develop`, 0/0 at preflight and final local comparison. Index and worktree were clean initially. No commit, push, reset, stash, provider, persistence or scientific calculation change. Remote-tracking refs were not freshly fetched in this task.

## Requirement and evidence

| Owner requirement | Delivered behavior / evidence |
| --- | --- |
| Start web server | Frozen Hybrid reference served at `http://127.0.0.1:4173/`; HTTP 200 assets observed. Separate comparison at `http://127.0.0.1:4174/comparison.html`. Both bind loopback; USB reverse ports 4173/4174 support the connected phone. No frozen reference file changed. |
| Remove the large site/date gap; allow long names | `ContextLine`: site uses loose flex instead of an expanded half-row; date uses its natural width, 4 dp between the targets. Short names stay adjacent; long names consume available width with ellipsis and full accessible name/tooltip. Geometric regressions at 320/375/412 px and 100%/200%; physical short-name render; real-font long-name renders. |
| Add breathing room before timeline | 16 dp after jump controls, up from 4. Slider region grows from 42 to 48 dp. Scientific lane/event geometry and callbacks unchanged. Exact gap/touch-height regression, real-font 200% timeline frames, physical render and both jump interactions. |
| Make the explanation optional | Move existing legend and encoding warning into the existing initially collapsed `Exact times & reading key`; exact interval groups remain there. Visible instant/current state and accessible slider readout remain. Regression opens/closes disclosure without changing preview; physical expanded/collapsed observations. No warning text is removed. |
| Centre bottom navigation | Equal-width destinations were already horizontally centred. The actual defect was vertical padding: 8 above versus 0 below. Both are now 8 inside SafeArea. Tests check equal widths and content centres at 320/375/412 px, 100%/200%; scoped phone checks cover all four roots. |
| Inspect fonts across the app | Source-wide explicit family/fallback search, all three theme mappings, bundled declarations and painter paths inspected; current real-font render JSON checked. Findings below. No font-family replacement. |
| Explore blocks and alternative time actions | Actual A/B PNGs, one B refinement, current synthetic host screenshot, exact prompts, tradeoffs and equal-nominal-width comparison in this directory. All labelled CONCEPT / NOT IMPLEMENTED. Owner selection is a future decision. |

## Typography finding

The adopted implementation intentionally uses several roles, rather than one family everywhere:

- **Geist**: `HybridTokens.fontFamily`, all three `AppTheme` base themes, Material text scale and named UI styles. Bundled `assets/fonts/Geist.ttf` is declared in `pubspec.yaml`.
- **Source Serif 4, opsz 14**: `AppTypography.nightHeading` and `answerHeading`; used by Tonight, Plan, Night/Moon and Weather editorial/answer headings. This is documented adoption, explaining the visible serif heading in the owner's photo.
- **Roboto 11**: explicit `navigationLabel`, documented for root navigation. The stacking-gain painter also explicitly uses Roboto for compact chart labels (`stacking_gain_graph.dart`); this caller was preserved and is now explicitly surfaced in this inspection, without asserting a new owner font decision.
- **MaterialIcons** is an icon font, not an additional prose face. Other inspected text painters take their style from the existing UI/theme roles. No other explicit family override/fallback or GoogleFonts usage was found under `lib/`.

The captured ready Home JSON contains 37 Geist text entries, four Roboto navigation entries, one Source Serif 4 heading and one MaterialIcons entry. That frame confirms those roles at runtime; the broader statement above is source inspection, not an exhaustive device render of every screen/glyph. Family unification would require an explicit design decision because it changes the adopted editorial/navigation roles.

## Verification and build receipt

Class: shared presentation behavior, V1/V3/V5. Meaningful affected tests, not a full application/release gate:

- Five affected test files: context line, app-shell navigation, Night/Moon browse, Tonight Home and Home night card. Final coverage **85 PASS**: the first combined run had 79 PASS and six new context tests failing only their SemanticsHandle cleanup; correcting the test cleanup and rerunning its complete file gave 13 PASS. The other 72 passing tests' inputs are unchanged, so their result is reused under V3/V5. Tests retain all behavior assertions; none weakened.
- **21 final real-font frames**: Home, long-site Home and Night at 375 × 900, Light/Dark/Field, 100%/200% (18), plus the scrolled Home timeline at 200% in all themes (3). Source frame for generation is additional, at 375 × 1450. Visual inspection includes long-site 200%, the timeline's 200% wrapping and Field palette. This is host evidence, not physical 200%/TalkBack acceptance.
- Final `flutter analyze --no-pub`, changed-file `dart format --output=none --set-exit-if-changed` and `dart run tool/check_encoding.dart`: **PASS**. `git diff --check`: PASS at handoff. No full suite, CI, release or real-file claim.
- Comparison browser: Chromium at desktop and 375 px. All three images load at equal widths (375 desktop / 327 responsive phone); keyboard Home on the width slider changes all to 280 px and updates its output; Concept B link scrolls to B. Zero console errors/warnings after reload. One initial favicon 404 was fixed. The one Impeccable detector scan reported four contrast warnings against an assumed white background; actual computed page background is `rgb(17,17,17)`, captions `rgb(179,179,177)` and links `rgb(178,220,250)`, so those are false positives for this dark comparison page. The scan is not an app accessibility certification.
- Initial render attempt failed because its output directory did not exist; creating it fixed the attempt. Two overlapping host invocations could not acquire `sqlite3.dll`; after the first host run exited, sequential invocations passed. Neither failure is represented as passing evidence.

Android build: `flutter build apk --debug --no-pub`; Flutter **3.47.4** / Dart **3.13.3**, Windows host. `lib/main.dart`, canonical package **io.github.buffur.culmina**, debug, **1.0.0+1**. APK: `build/app/outputs/flutter-apk/app-debug.apk`, 211453864 bytes, SHA-256 **ff2b94cfe327decd290105b6f3d0c55f22bbba895cd602978cc284ab644e84d1**. Source base plus dirty inputs are fingerprinted in [verification.json](verification.json). Existing SDK XML/Kotlin/native-access warnings were observed; build succeeded, dependencies/toolchain were not upgraded.

The owner explicitly authorized update/verification in this chat. Existing installed and new APK public signing-certificate digests match. `adb install -r` succeeded without clearing/uninstalling; pulling the installed `base.apk` confirms the exact APK hash above. Confirmed the opened canonical package on the connected **2407FPN8EG** phone, physical 1220 × 2712 / density 520, dark theme, app text 100%. Scoped phone checks: adjacent context, timeline gap, disclosure open/close, dark-start/end previews, four root tabs and centred navigation. The existing selected saved plan and four Logbook entries remain visible. This is bounded UI observation, not an exhaustive database-integrity test. Hot reload succeeded through Dart MCP; runtime error query was empty after interactions.

Raw logs, host frames, private phone screenshots and installed APK comparisons remain outside Git in `C:\Users\zalub\.codex\tmp\culmina-layout-20261024\`. The source fingerprint/receipt and synthetic concept inputs in this directory are shareable; private owner screenshots are not copied here. Build timestamp and final file hashes are recorded in `verification.json`.

## Stop boundary

The requested fixes, font inspection and concept deliverables are complete. Owner visual acceptance and the choice/implementation of A/B remain separate. No change to F/G, physical accessibility, historical identity/geo acceptance or release gates is implied. Leave both requested servers available and the working diff reviewable; no Git delivery is authorized.
