# Matched Hybrid / Flutter visual audit

This audit is being assembled after the bounded composition, Planning Settings,
calendar and feedback corrections. The earlier conditions comparison remains
archived under `evidence/matched/history/conditions-ab6308520925/`; its defects
are historical findings, not an assessment of the latest sources.

## Comparison contract

- Eight roots: Tonight, Plan, Night, Moon, Weather, Logbook, Library, Settings.
- Three themes: light, dark, red field. Text scaling: 100% and 200%.
- Shared initial fixture exported from actual native models/repositories:
  Ljubljana, evening 10 November 2026, fixed clock, metric units, 24-hour time.
- Both browser and host canvas: 412 ×915 logical pixels, actual Geist.
- Original approved Hybrid source remains frozen. The isolated browser adapter
  replaces initial data only; its source/generated hashes and fixture hash must
  be recorded. Edits inside the copied browser still use its illustrative model.
- Browser fake status/gesture bars and lab controls are excluded with recorded
  capture-only framing CSS. Native system bar, keyboard, permission and file
  behavior require the separate Android evidence.

## Artifacts

Latest owner-requested local follow-up (2026-10-21, baseline `1aceb65`):
[design parity QA](DESIGN_PARITY_QA_2026_10_21.md) and its
[84-pair current gallery](evidence/audit-2026-10-21/index.html).
It records additional source typography, navigation, editor/IME and 200%
segmented-control repairs; the dated checkpoints below remain historical.

- [Paired gallery](evidence/matched/gallery/index.html).
- [Pair hashes, dimensions and review status](evidence/matched/gallery/manifest.json).
- [Browser capture manifest](evidence/matched/browser-capture-manifest.json).
- [Original and generated source manifest](evidence/matched/browser-source-manifest.json).
- [Canonical fixture](evidence/matched/canonical-fixture.json).

The gallery generator does not resize, align, crop or edit source PNGs.
Diagnostic overlays blend original RGB pixels at 50%; difference images use
absolute channel difference. Those include text antialiasing and composition
differences and have no automatic pass/fail threshold.

## Review status: intermediate composition checkpoint (2026-10-20, superseded below)

Browser capture completed at 2026-10-20T18:43:47Z: 90 PNGs, all 412 × 915,
zero browser diagnostics, 145 original source hashes reverified unchanged.
The fixture SHA-256 is `39b1dfa55e396d3a82d04776439b125e26896e12d8578ea915c4d0a19cd1f849`.
Platform media is light/dark alongside the requested theme so the stored System
appearance preference is displayed honestly. Local/session storage resets before
each document; invalid editor experiments cannot change later root captures.

The gallery currently pairs 48 roots and 24 Settings sections with the **intermediate**
Flutter host run, archived in
`evidence/matched/history/host-allroots-39b1dfa55e39-before-final-polish/`.
(2026-10-20 checkpoint, superseded by the final section below.) These
images identify defects; they are not acceptance of the latest production tree.

| Inspected surface | Confirmed composition difference | Bounded response |
| --- | --- | --- |
| Tonight light 100% | Plan begins about 45 px lower; Open CTA and Night ahead similarly displaced; needed duration drops seconds. | Parent/QA own context, spacing and duration precision repair. |
| Plan light 100% | Capture plan below viewport because rig note and detail rows consume vertical space; original first block visible. | Parent owns compact selectors and accessible detail disclosures. |
| Night/Moon/Weather light 100% | Site/zone and date-browser metadata consume an extra row. | Parent owns single-line context and centered date block; full zone remains accessible. |
| Logbook light 100% | Search hidden in app bar, filters modal, result count absent, share icon replaces row chevron; metadata larger than source. | Visible stable search, inline filters, count and 14 px metadata implemented; existing detail Share preserved. Focused tests pending. |
| Library/Settings light 100% | Root field-mode action absent; Planning summary omits Sun limit. | Field action added to all three workspace roots; actual darkness limit included. Focused tests pending. |
| Root app bars 200% | Material title clamp prevents source-equivalent scaling. | Parent owns measured title-height factory with preserved standard AppBar type. |
| Bottom navigation 200% | Label size exceeds source 11 × 2 px role. | Parent owns shared 11 px navigation role. |

## Final host recapture and per-pair review (2026-10-21)

The host side was recaptured on the step-2 tree (`ccd0227`) with
`ASTROPLAN_MIGRATION_RENDERS` (6 variants passed, 72 PNGs,
`evidence/matched/flutter/render-run-2026-10-21.log`) and again after the
visual repairs below (the final PNGs in `evidence/matched/flutter/`). The
re-exported canonical fixture is **byte-for-byte equal in content** to the
committed `canonical-fixture.json` (recursive JSON comparison), so the browser
captures of 2026-10-20 remain the matched reference for the same inputs; they
were not recaptured. `gallery.py` regenerated the 48 root pairs and their
diagnostics (`gallery/manifest.json`).

Reviewed by eye, side by side, for every root in light 100 %, plus dark 100 %,
field 100 % and light 200 % samples (Tonight, Plan, Moon, Settings/Planning):

| Surface | Result against the approved Hybrid | Response |
| --- | --- | --- |
| Tonight | Same order and hierarchy (title, context, Your plan, verdict, Needed/Usable to the second, Open planner, The night ahead, preview time). The earlier ~45 px offset is now ~6 px. Fit verdict is the native 18 px heading with the native reason instead of the web's 13 px check line with an illustrative "example window" note; the Night row keeps the native wording "Dark (Sun below −18°): …" and the zone rule. | Kept: native wording carries the darkness limit and zone (ENGINEERING_GUARDRAILS time/zone rules, F17); the web note is browser-only. Recorded deviation D-01. |
| Plan | Status figures, context, Target and Rig rows match; capture list starts below the first screen because the rig's active **capability warnings** (NPF / Max sub when tracking is unknown) stay visible and the per-plan Tracking row follows. | Kept: TASK 8.6 / PD-11 keep active capability warnings in view; reference data is in the Target/Rig details disclosures. Deviation D-02. |
| Night / Moon / Weather | Composition matches; the context uses two lines ("Ljubljana" + the explicit zone rule) where the web writes "Ljubljana · Europe/Ljubljana". Moon calendar glyphs were **inverted** (New Moon drawn as a full disc). The Moon answer had no primary number. | Glyph geometry fixed and coloured with Hybrid's roles (lit = text-primary, shadow = surface-subtle, 0.7 outline = border-control); `moon_phase_painter_test.dart` fails on the old geometry. Moon answer now leads with the 24 px total (`nightMoon.moonFreeTotal`). The zone line is kept (time-zone rule), deviation D-03. |
| Logbook | Matches: visible search, inline filters, count, groups, rows, Record result. Native adds the overflow menu (exports, AstroBin) absent from web. | Native capability kept (Decision 5). |
| Library | Matches; "1 rigs" was ungrammatical. | Singular/plural fixed for rigs and targets. |
| Settings root and sections | Root matches. Planning sliders had the value beside a long help text and no range ends. Trailing app-bar actions sat 8–16 px closer to the edge than the web. | `_SliderTile` now puts the name and value on one line, the help below, the slider and its range ends (settings.css). App bars end on the 16 px page margin at roots and 8 px on details. |
| Dates | Native writes "Tue, Nov 10" / "Night of Tue, Nov 10"; web writes "10 Nov". | Existing app-wide `NightTimeFormatter` (device locale) kept; deviation D-04. |
| Host glyph tofu | `|δ|` in the NPF row renders as a box on the host only (no system fallback font in `flutter test`). | On Android the same string renders correctly (`native/run-2026-10-21/plan-light_100.png`): host-only, not a defect. |

After the independent review (ledger, "Independent review"): its F1 — the
Weather tab clipped at 200 % — was missed in this review and is now fixed; its
F2 (override labels at 200 %) and the block-editor field gap are fixed. The host
was recaptured once more on the final code (`render-run-2026-10-21-final.log`;
fixture again unchanged) and every root at 200 % was reviewed (light for six
roots, Weather dark, Settings field): no clipped label remains. The gallery now
records which pairs were reviewed by eye (20) and which were not individually
reviewed (52) in `evidence/matched/visual-review.json`. The block editor's composition (OPEN-01) was then adopted: the harness now
also captures `plan_editor` and `plan_editor_invalid` in every theme and scale,
paired with the browser references; light 100/200 %, dark 200 %, field 100 % and
the invalid state in light and dark were reviewed side by side and match the
web's order, hierarchy and controls, apart from the native differences D-08.

Later the same day the remaining adoptable web details were adopted and the
pairs regenerated (fixture again unchanged): Tonight's fit line and condition
rows (D-01), the one-line Night/Moon/Weather context (D-03), Settings groups
above the tabs with web-style sliders (D-05), Weather's clearest/cloudiest
line, span length and coverage, and the catalogue ID on Tonight (D-07).
Tonight, Weather and Planning light 100 % were reviewed again side by side.

Deviations D-01 to D-08 are listed in the migration ledger; D-01, D-03, D-05 and D-07 are now adopted.

Browser-only illustrative/demo notices are intentionally absent from production.
Native backup remains the full existing capability, while the prototype demonstrates
only a subset. Native Material glyph shapes and system insets are presentation
adaptations, not evidence of pixel identity. Calculated domain values, missing-data
states and existing actions remain the native authority.

Supplemental browser references include four Settings sections (24 matched host
pairs), weather charts, first-block editing and invalid exposure. Editor/chart
references were unmatched at this checkpoint; the editor is now paired (`plan_editor`,
`plan_editor_invalid`, final section) while the weather chart reference stays unmatched. Android
keyboard screenshots have different available content height and are not identical
frame comparisons. No native pass is claimed by this browser/host audit.
