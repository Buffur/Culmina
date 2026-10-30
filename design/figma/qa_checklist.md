# QA checklist

Revision: AFTER-DARK-1.0. D01 verification results are in [verification.json](verification.json) and [WORKFLOW](WORKFLOW.md). Unchecked F01/native items below are requirements, not claims of completed testing.

## D01 document gate

- [x] Every relative Markdown file link and external local evidence path resolves.
- [x] All required modules exist; router skill has valid frontmatter and valid references.
- [x] Every semantic token has exactly one binding row; only the explicitly proposed focus-width role lacks a current Dart owner.
- [x] No second independent table of target values exists in flutter_mapping.
- [x] Source C/S labels and three live Figma IDs match recorded evidence; no old UI Lab IDs are presented as current.
- [x] Proposed component names/props are explicitly distinguished from actual APIs.
- [x] Components include typed props/defaults/slots, states, actions, Figma properties and transformations.
- [x] Scope remains Dark; no production skill, Flutter code, dependency, reference or BEFORE artifact was edited.
- [x] Run `python design/figma/validate_contract.py`, `python tool/check_instructions.py` and the instruction unit tests; record actual results. No Flutter build is needed.

## F01 functional and visual parity

- [ ] Confirm the three immutable BEFORE source names, IDs and dimensions before copying.
- [ ] Match the source fixture's data, selected context, all actions, warnings, summaries and lower longread sections.
- [ ] Keep fit, persistence and recorded results separate; no invented measurements, forecasts, storage, AF/MF scale or quality score.
- [ ] No-site, missing input, unknown, partial, stale, unavailable, invalid and pending/failure states are represented in appropriate component specimens.
- [ ] Preserve explicit Save, dirty-leave confirmation, Undo intent, picker confirmation and viewed-night isolation in prototype annotations.
- [ ] Use one revision's tokens and styles, no unbound local color/geometry changes, and no shared dependency that modifies BEFORE.
- [ ] Required Figma properties and variant defaults match catalogs; lists use nested instances with labeled data.
- [ ] No production data or science formula is recomputed by a Figma layout.

## F01 layout, text and accessibility design checks

- [ ] Full longreads have no clipped or omitted content. First-viewport comparisons show 375 × 812 at 1:1 and account for chrome/footer/safe insets.
- [ ] Each BEFORE/AFTER pair has a 120-px clear gap; matching widths and content fixtures; no stretching or optical scaling.
- [ ] Auto Layout owns growing screen/section/row content; absolute positioning is restricted to charts and board presentation.
- [ ] Text layers hug height, essential labels wrap, buttons stay reachable, icons do not replace necessary words.
- [ ] Check long target/site names, Cyrillic glyphs including І/Ї/Є/Ґ, negative signs, decimals, units, GMT offsets and +1-day markers.
- [ ] Inspect 100% and 200% text specimens. A wider or taller group must not create clipping or overlapping hit regions.
- [ ] Check normal text contrast at least 4.5:1; large text and essential UI indicators at least 3:1 against their actual adjacent backgrounds. Record evaluated pairs and exceptions, including disabled controls. Numerical checks alone do not establish accessibility.
- [ ] Focus ring remains visible and unclipped; label/word/icon/pattern supplements color. Each action has its intended semantic name and minimum hit region.
- [ ] Weather table preserves pinned local-time column and exposes horizontal overflow intentionally; DST repeats remain distinguishable.
- [ ] Chart gaps remain gaps; event times, legend and selected preview marker remain readable.
- [ ] Semantic layer names and source annotations are present; no placeholder labels or undocumented variants.
- [ ] Correct/incorrect system examples are clearly differentiated so an incorrect specimen cannot be adopted by mistake.

## Later native verification — not satisfied by Figma

- [ ] Owner separately authorizes Flutter migration.
- [ ] Validate actual text scaling, TalkBack semantics/traversal, touch/keyboard focus and reduced motion on relevant native targets.
- [ ] Run scoped behavioral/widget regressions for changed callers, including Save/Undo/draft guards, data gaps, time zones/DST and fixed-time weather table.
- [ ] Verify source/calculation/database/backup behavior and offline/freshness handling remain unchanged.
- [ ] Maintain production Light and Field Red, including the field filter, even though their redesign is deferred.
- [ ] Compare actual native renders against accepted After evidence; record native scope and owner decision separately.

A passing static Figma check is evidence about the artifact, not about native execution, scientific correctness, device accessibility, release acceptance or owner approval.
