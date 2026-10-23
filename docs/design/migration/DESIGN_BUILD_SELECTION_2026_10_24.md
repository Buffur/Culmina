# Old design investigation — installed application selection — 2026-10-24

Owner request: identify where About/Privacy and other tabs reverted, and restore the current design. Result: the phone was displaying a separate old-base identity-test application. The current geo application is intact and has been brought back to the foreground. No production source fix, APK reinstall, database change or merge was needed.

## Direct evidence and cause

Two separately installed Android packages both present Culmina UI:

| Package | Installed APK SHA256 | Observed state |
| --- | --- | --- |
| `io.github.buffur.culmina` | `82aeacc839af960ef560edc6216861013d10a5fa977788fd67356991ee4e6359` | Matches the final geo release from TD-121 exactly. Updated2026-10-23 at23:17:11 according to Android package metadata. Completed design transfer plus the owner geo refinements. |
| `io.github.buffur.culmina.s2check` | `da223ce47748befa5125cd762daa98e8af33b1c478f7710b283f60aa1a3b6582` | Separate identity-test application, installed2026-10-23 at22:43:13. Initial UI XML reports this package, not the geo package. About and Privacy visibly use the earlier layout. |

The first phone capture showed Library in `s2check`. Navigating Settings produced the old About & data sources label,16dp gutters, older headings and summaries. Actual old About shows a long expanded catalog notice; old Privacy has the introductory card and old switch row. In the correct package, About uses the new compact source list and collapsed OpenNGC notice; Privacy uses Place names and What leaves the device in the app. Both packages were opened by their exact activity for comparison; neither was removed, disabled, renamed or modified.

Git confirms the cause. Main owner checkout is `744fe57` (identity changes based on partial transfer checkpoint2 `01b8049`); its identity and equipment/target edits were left untouched. Separate `cwt` identity-test checkout contains the application-ID override for `s2check`. Geo checkout `C:/Users/zalub/AppData/Local/Temp/culqa` remains on `codex/tonight-context-controls`, HEAD and freshly fetched `origin/develop` both `2a43c89981c0f9e0f4d4eddc4a62484c470be928`, containing completed transfer checkpoint3 `1577cdd` and later phone fixes. The source revisions are divergent, not a case of the geo files being overwritten.

## Other affected surfaces

Compared the58 presentation paths changed from checkpoint2 to completed transfer against current geo sources. Remaining current differences are the intentional previous Tonight/geo changes, including the shared footer/icons. Main/identity-test presentation differs from the current geo checkout in60 paths. Source comparison identifies these old-base surface groups:

- Settings root, Appearance, Planning, Privacy, Backup & data and About (`HT-S01`–`HT-S06`).
- Logbook list, entry detail and target progress; result entry.
- Library index, rig/target/site lists, detail records and editors.
- Weather and forecast layout/view selection.
- Plan calibration/assumption editors and supporting shared controls, plus prior Tonight improvements.

This is a source/build inventory, not a claim every nested state was re-tested on the physical phone today. The correct geo application already contains the completed-transfer implementations for those groups. No old identity-test source was copied over it.

## Verification and restored working state

- Recomputed all six latest geo-refinement source hashes: exactly match the final delivery manifest. Earlier TD-120/TD-121 changes remain; no geo regression or source edits made in this investigation.
- Rechecked the installed geo APK hash against the archived release: exact match. The initial hypothesis that another APK replaced it was ruled out; it was another foreground package instead.
- Fresh actual Flutter host captures at375x760 logical app area,DPR1,dark,text100%: Settings root, Appearance, Planning, Privacy, Backup & data, About, Logbook, Library and Weather. Render run passed1 test covering all9 frames, screenshots inspected. Uses existing Hybrid fixture/fonts/settled capture; no web reference changed.
- Physically inspected both packages' Settings/About/Privacy on Xiaomi14T Pro Android16,1220x2712,DPR3.25,text100%,dark. Read-only navigation only: no setting toggles, permissions, GPS, Save/Delete, backup/restore or file operations on owner data.
- Brought `io.github.buffur.culmina/.MainActivity` to foreground explicitly. Correct About/Privacy restored for use; no reinstall required. The separately installed identity test remains available for its independent purpose and still contains the old-base screens. Integrating that identity work with the current baseline is a separate task, not silently claimed here.

Evidence outside Git, preserving private phone data: `C:/Users/zalub/CulminaQA/2026-10-24/design-restoration/`. `packages.json` contains installed hashes; `complete-transfer-source-inventory.json` lists the58 paths; `restored-surface-inventory.json` confirms representative unchanged current sources. `host/` holds9 fixture renders and JSON; `host.log` is the new run. `phone/old-test-about.*`, `old-test-privacy.*`, `restored-about.*`, `restored-privacy.*`, `final-current-privacy.*` distinguish packages using original XML and raw screenshots. No crops/stretching or edits to the images.

Latest geo report remains [GEO_OWNER_REFINEMENT_2026_10_23.md](GEO_OWNER_REFINEMENT_2026_10_23.md). No new defect ID duplicates the existing transfer IDs; this is a build-selection finding. No commit, push, identity merge, production change or new full-suite result is claimed.
