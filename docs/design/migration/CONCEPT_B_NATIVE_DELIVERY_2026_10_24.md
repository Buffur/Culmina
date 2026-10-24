# Concept B native implementation — 2026-10-24

Status: **implemented, bounded verification complete; owner visual acceptance pending**. Source base `develop` / `a4798d667007a83e12de3c94d95bb68c22947748`, with preserved pre-existing dirty work and the current uncommitted UI changes. No commit or push.

The [owner-approved task](../CONCEPT_B_IMPLEMENTATION_2026_10_24.md) groups existing content and adopts one production font. Tonight, Plan, Logbook, Night, Moon, Weather, Library, Settings and Record result now use flat semantic document groups. Geist covers production prose, headings, navigation and chart labels; MaterialIcons remains an icon font. Original concepts and frozen references retain their historical bytes.

`DocumentSection` uses existing `surfaceSubtle`, 16 dp padding and an 8 dp radius. Existing page gutters, scientific graphics, disclosures, callbacks and fixed Save/Cancel bars remain. Local Material preserves child ink/focus feedback. Logbook keeps lazy month rows; its badges stack when needed. Plan capture actions stack at large text or narrow width to preserve whole-word wrapping. No domain, database, calculation or persistence implementation changed.

## Evidence

The machine-readable [verification](evidence/concept-b-2026-10-24/verification.json), [source fingerprint](evidence/concept-b-2026-10-24/source-inputs.json) and [build receipt](evidence/concept-b-2026-10-24/build-receipt.json) bind these observations to the dirty source.

| Check | Result and limits |
| --- | --- |
| Affected tests | 251/251 passed. After the final capture-action reflow, the affected screen/widget/accessibility invocation had 59 passes and one new fixture failure; it is not labelled a passing invocation. The final capture widget suite passed 13/13 with bundled Geist and the corrected production-size fixture. Combined applicable passing coverage is 252 distinct tests, with unrelated results reused under V3. |
| Accessibility | Route/editor sweeps passed Light/Dark/Field at 100%/200%, including target sizes and scrolling. New group checks cover 320 dp at both scales. The capture-action regression covers a 303 dp inner group at 200%, button bounds, 48 dp targets and the working Add action. |
| Real-font host renders | 27 frames at 100% and 48 at 200%, all three themes, width 375 dp. The latter include scrolled Plan, timeline, Moon, Weather and result frames. Final Plan 200% frames were regenerated after action reflow. These are synthetic Flutter fixture renders with tall viewports, distinct from the phone observation. |
| Typography | All 2,004 visible prose style records declare Geist; 60 icon records declare MaterialIcons; no other families or horizontal text bounds outside the viewport. Bundled cmap inspection covers Ukrainian letters, units, numbers, minus and square root, with no missing specimen codepoints. Actual render/phone inspection supplements this declaration/asset evidence. |
| Static checks | Final analysis: no issues. Format: 24 affected Dart files unchanged. Encoding and diff whitespace checks passed. |
| Build/device | Debug APK built with Flutter 3.47.4 / Dart 3.13.3. Public certificate matched the installed canonical app. Authorized `adb install -r` succeeded, followed by a verified cold launch of `io.github.buffur.culmina` 1.0.0 (1); installed APK hash matches the receipt. No uninstall or data clear. |
| Physical observation | 1220×2712 phone, 100% text: Tonight, Plan including scrolling, Logbook, Library, Settings, Night, Moon and Weather opened with the new groups and Geist. Existing saved plan/library content remained accessible; no records were edited. Zero Flutter exception/overflow/fatal patterns in the new process log. Private screenshots/logs stay outside Git. |

[Fourteen representative synthetic frames](evidence/concept-b-2026-10-24/frames/) are retained alongside [all 75 frame hashes](evidence/concept-b-2026-10-24/frames-manifest.json). Complete local renders, earlier failed diagnostics and private phone evidence are under `C:\Users\zalub\.codex\tmp\culmina-b-implementation-20261024`.

## Findings resolved during verification

The initial affected run found a real Logbook status-column overflow at 200%; responsive stacking resolved it. Older tests also assumed content remained built or visible after layout growth; their helpers now search from the correct scroll position and assert reachable targets before tapping. A new capture regression initially used Ahem's synthetic glyph geometry; the final fixture uses the shipped Geist face and the actual 375 dp viewport/303 dp group, retaining overflow and interaction checks. Real-font rendering separately exposed a split calibration word, resolved by action stacking.

Hot reload succeeded without runtime errors, but retained an already-initialized static heading style. The full APK cold launch verified the final Geist heading. An initial render sequence also exposed a fixture autosave banner after Logbook seeding; final Plan frames run before that fixture mutation. This is not reported as a product persistence fix or a physical persistence qualification.

All 59 pre-existing dirty/untracked baseline files remain present: 52 unchanged byte-for-byte, seven intentionally extended by this task. The original bytes/patches were saved before edits; the preceding operational handoff was appended verbatim to PROGRESS_HISTORY. No concept/reference PNG was overwritten.

## Pending boundaries

Owner visual acceptance, physical 200%/TalkBack and physical Record result validation remain unperformed. No new full-backend-suite, CI, real-file, F/G, signing or release qualification is claimed. The bounded implementation work is complete; further changes follow an explicit owner task.
