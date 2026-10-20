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

- [Paired gallery](evidence/matched/gallery/index.html).
- [Pair hashes, dimensions and review status](evidence/matched/gallery/manifest.json).
- [Browser capture manifest](evidence/matched/browser-capture-manifest.json).
- [Original and generated source manifest](evidence/matched/browser-source-manifest.json).
- [Canonical fixture](evidence/matched/canonical-fixture.json).

The gallery generator does not resize, align, crop or edit source PNGs.
Diagnostic overlays blend original RGB pixels at 50%; difference images use
absolute channel difference. Those include text antialiasing and composition
differences and have no automatic pass/fail threshold.

## Review status: intermediate composition checkpoint

Browser capture completed at 2026-10-20T18:43:47Z: 90 PNGs, all 412 × 915,
zero browser diagnostics, 145 original source hashes reverified unchanged.
The fixture SHA-256 is `39b1dfa55e396d3a82d04776439b125e26896e12d8578ea915c4d0a19cd1f849`.
Platform media is light/dark alongside the requested theme so the stored System
appearance preference is displayed honestly. Local/session storage resets before
each document; invalid editor experiments cannot change later root captures.

The gallery currently pairs 48 roots and 24 Settings sections with the **intermediate**
Flutter host run, archived in
`evidence/matched/history/host-allroots-39b1dfa55e39-before-final-polish/`.
Final host recapture and per-pair review remain pending bounded repairs. These
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

Browser-only illustrative/demo notices are intentionally absent from production.
Native backup remains the full existing capability, while the prototype demonstrates
only a subset. Native Material glyph shapes and system insets are presentation
adaptations, not evidence of pixel identity. Calculated domain values, missing-data
states and existing actions remain the native authority.

Supplemental browser references include four Settings sections (24 matched host
pairs), weather charts, first-block editing and invalid exposure. Editor/chart
references are unmatched until a host/native capture uses the same state. Android
keyboard screenshots have different available content height and are not identical
frame comparisons. No native pass is claimed by this browser/host audit.
