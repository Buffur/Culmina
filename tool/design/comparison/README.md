# Canonical fixture comparison

This is test tooling. It never imports into the application and never writes
`design/home-lab`. The original Hybrid presentation remains the reference.

The Flutter render harness exports a fixed-clock fixture using the actual
production NightView and weather summarizer. It contains a full calendar month,
continuous event times, five-minute visual intervals, raw forecast rows, native
summary slots and the saved plan snapshot. It is controlled host data, not live
weather or device evidence.

```powershell
node --test tool/design/comparison/adapter.test.mjs
node tool/design/comparison/prepare.mjs docs/design/migration/evidence/matched/canonical-fixture.json
node tool/design/comparison/inspect.mjs build/design-comparison/<printed-fingerprint>
python build/design-comparison/<printed-fingerprint>/scripts/serve_preview.py --port 4174
```

Use the printed `conditions.html` URL on port4174, selecting `view=night`,
`view=moon` or `view=weather`, `theme=light|dark|field`, and `scale=1|2`.
`font=Geist` and `variant=blend` are required. Capture `.android-device` at a
matching logical width, with desktop lab controls excluded. Record both viewport
and phone-content dimensions. Browser-simulated status/gesture chrome differs
from Flutter host rendering and must be treated separately.

The generated source tree has a source/fixture/hash manifest. The adapter fails
when expected source anchors change or a required DTO field is absent. It
rejects non-metric display units because the original prototype labels those
units explicitly. All original source files are rehashed after generation.

The copied `night-model.js` replaces illustrative generators with the canonical
native DTO. Existing formatting and cursor helpers remain. Rendered weather
slots come directly from the native export, preserving unknown values and
preceding-hour masks. Original browser aggregators stay exported as
`sourceWeatherForNight` and `sourceWeatherSlots`; `inspect.mjs` reports numerical
disagreements rather than hiding them under a visual comparison.

Scope is all eight roots. Tonight and Plan use the exported native initial plan,
fit and budget; Logbook uses the production portable manifest; Library uses the
actual fixture database records and catalogue; Settings uses native preferences.
The original `sourceEstimate` remains available, but the initial rendered fit,
budget and storage are native output (unknown storage stays unknown). Edits made
inside the copied prototype still use its illustrative model and are not native
calculation evidence. No original CSS, HTML, or presentation template is edited.
Use `index.html?view=wide`, `plan.html`, and
`workspace.html?tab=logbook|library|settings` for the remaining roots, preserving
the theme/scale/font/variant query parameters above.

Fixed explanatory copy in the source may retain illustrative dates; record it
as such. Continuous Moon-up
events can differ from the native five-minute rail boundaries; both sets are
exported and no production interval is modified to make them agree. Browser,
host widget, Android emulator and physical-device evidence are separate.
