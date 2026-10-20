# Assessment B evidence scope and limitations

- Current Hybrid browser prototype revision `20261020-hybrid6`, loopback `localhost:4173`.
- Fresh isolated headless Microsoft Edge contexts; no owner profile attached, no `127.0.0.1` owner storage accessed. Script-created records and import files only existed in the isolated context.
- No application source or asset edits. All 30 baseline source hashes matched before and after capture.
- Current pack: 116 PNGs listed in `SCREENSHOT_MANIFEST.json`; all eight roots, 17 matrix inner views, six Plan editors, Home dialogs, Conditions guides/calendar/hourly, actual error/empty/unknown/offline/stale, custom target edit, site permission denial, metadata import review, settings restore and full prototype backup entry.
- 36 tab-root, 51 inner, 12 Home layout, 9 palette and 9 state matrix checks completed. No module errors. Existing matrix asserts dimensions, no horizontal overflow and minimum 47.5 CSS px buttons/selects/ordinary inputs.
- 66 supplementary captures include root/content overflow measurements, visible button/input/select dimensions and active-element HTML. No enumerated geometry violations. Checkbox/radio hit areas, link targets, contrast, complete keyboard traversal and screen reader behavior are not certified by these scans.
- Home is 356px at the narrow browser host because the design-lab wrapper consumes width. Use the eight `home-412-*` images for consistent phone comparison; they capture the 410px inner viewport of the 412px phone at a 1280px host. Narrow captures remain separate adaptivity evidence.
- Initial capture harness reused a persisted Plan editor draft across navigation. `fresh-plan-*` clears isolated storage before loading and is the authoritative six-editor pack; initial selector timeouts are not app-defect findings. Initial attempt JSON is retained for transparency.
- Screenshots show the visible phone slice; long screens are not wholly visible in a single screenshot. Matrix screenshots at 200% emphasize first-viewport reflow; source/interaction review is needed for content below the fold.
- Native Android gestures, Back, IME/insets, TalkBack, physical-device performance, production astronomy/weather and persistence acceptance are excluded.
- Impeccable context and detector ran once against the four current entrypoints. Detector output is held separately for independent sequencing and is not incorporated here.
