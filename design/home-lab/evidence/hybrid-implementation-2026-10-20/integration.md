# Final Hybrid browser integration verification

Version: `20261020-hybrid3`, after the parent's version-bump READY message. Original Hybrid only, loopback `localhost:4173`, isolated Edge contexts. Existing owner `127.0.0.1` tab/storage and preview server were untouched.

## Final results

| Existing suite | Completed cases | Result |
| --- | ---: | --- |
| `scripts/check_tabs_browser.cjs` | 36 root matrix, 51 inner, 12 Home, 9 palette, 9 state | All existing mount/overflow/target/module assertions passed; pageerrors empty |
| `scripts/check_tabs_interactions.cjs` | 11 contract groups | Passed; pageerrors and resource failures empty |
| Final screenshot pack | 12 main captures plus focused calendar/hourly/settings views | Current version, zero page/module errors in capture run |

Browser enumeration recorded two transient request failures: `fonts/roboto-8.woff2` and `preview-backup.css`, both `net::ERR_NO_BUFFER_SPACE`. A bounded resource recheck returned 200 with 43,136 and 2,831 bytes respectively; its final Home/condition captures had no failed requests or page errors (`qa-resource-probe.json`). Do not describe the complete enumeration as having zero resource failures.

## Test adaptations

- Both scripts accept `CULMINA_EVIDENCE`; their historical default folder remains unchanged. This run explicitly writes to this new folder, preserving historical evidence.
- Browser enumeration clears only the isolated profile's Logbook/Library session-navigation keys on each new document, so named root visits actually test roots. Real continuity is checked separately in the interaction suite.
- Interaction `open()` clears those session contexts in the next document after pagehide, keeping explicit reload and browser Back semantics intact.
- Logbook snapshot checks now open the intentional read-only disclosure and compare its complete content. After result Save and reload, the same detail and full immutable snapshot are asserted, then Back returns to the list for the next action.
- Library reload asserts the saved site's restored detail and coordinates, then Back returns through Sites to Library before visiting Rigs.
- Required-field validation, CRUD, Cancel/Back/Undo, failed-save recovery, malformed data preservation, denied storage and saved-plan checkpoint assertions were retained. Current camera-class radios are exercised directly; no validation was weakened.
- Failure-only URL/body and failed-resource diagnostics were added. Browser enumeration also produces 17 light child-screen captures at text 200%.

## Initial failure accounting

The first simultaneous suite launches each timed out at the initial workspace mount before completing any case:

- Browser: `page.waitForFunction: Timeout 30000ms exceeded`, waiting for `#workspace-main` text.
- Interactions: `page.waitForSelector: Timeout 30000ms exceeded`, waiting for `.logbook-view`.

Their zero-case artifacts remain as `browser-matrix-initial-mount-failure.json` and `interactions-initial-mount-failure.json`. Fresh probes with and without the exact init reset mounted normally (200, complete Logbook, no console/request/module errors). The still-unverified suites were retried sequentially and passed. The later observed `ERR_NO_BUFFER_SPACE` provides evidence of host network-resource pressure, but its relationship to the first stalls is an inference, not a confirmed root cause. No product edit was made for this transient failure.

## Useful visual evidence

See [CLAUDE_QA_SCREENSHOTS.md](CLAUDE_QA_SCREENSHOTS.md). Eight current root views, child forms/details at 200%, important disclosures and the parent's Home/Plan/backup captures are available in this folder. `qa-root-home.png` was cropped from a 1280 px host so the phone itself is exactly412 px; workspace/Plan/conditions use a 412 × 915 host. `qa-final-captures.json` records that Home override.

The Planning settings first screen at 200% shows the actual first usable budget control, `perFrameOverheadSeconds`, inside the scroll area (top560.77, bottom608.77, viewport scroll area256–878); see `qa-planning-first-control.json`. Minimum altitude is intentionally lower in the form and was not used as a proxy for the first control.

These are HTML browser checks and lab text 200%, not physical Android, TalkBack, IME or browser-zoom certification. Field mode retains its documented contrast exception. Parent owns final cross-module integration interpretation and requested Claude design QA. No additional full model/layout/Flutter suite ran here.

Cleanup: suite and capture browsers closed in finally blocks; own temporary scripts removed. No helper server was started or stopped. Evidence retained deliberately.

