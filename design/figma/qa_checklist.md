# QA checklist

Revision: AFTER-DARK-1.0. **F01 COMPLETE and owner-accepted.** The [workflow](WORKFLOW.md) records the final decision and evidence; [verification.json](verification.json) preserves D01 document verification. Checked items below describe confirmed evidence only. Future pilot and native requirements remain unchecked until their own verification.

## Historical D01 document gate

- [x] Every relative Markdown file link and external local evidence path resolves.
- [x] All required modules exist; router skill has valid frontmatter and valid references.
- [x] Every semantic token has exactly one binding row; only the explicitly proposed focus-width role lacks a current Dart owner.
- [x] No second independent table of target values exists in flutter_mapping.
- [x] Source C/S labels and three live Figma IDs match recorded evidence; no old UI Lab IDs are presented as current.
- [x] Proposed component names/props are explicitly distinguished from actual APIs.
- [x] Components include typed props/defaults/slots, states, actions, Figma properties and transformations.
- [x] Scope remains Dark; no production skill, Flutter code, dependency, reference or BEFORE artifact was edited.
- [x] Run `python design/figma/validate_contract.py`, `python tool/check_instructions.py` and the instruction unit tests; record actual results. No Flutter build is needed.

## Completed F01 — confirmed evidence and accepted limits

- [x] Owner explicitly accepted F01 as fully complete; closure does not depend on completing the remaining visual route.
- [x] Final structural readback: 94 variables, 18 text styles, 24 catalog sets and 417 variants, with zero findings.
- [x] Geometry source mapping closed all recorded entries; essential-indicator review has zero unresolved entries, including four verified inside-stroke cases.
- [x] Three BEFORE copies are locked and match their current sources. Historical provenance is stronger for Tonight than for Plan/Weather.
- [x] Three BEFORE longreads inspected at 100% through 11 overlapping captures.
- [x] 93/514 After review regions (tiles 0–92) inspected at 100%; no defects observed within those regions. This is partial visual coverage, accepted at closure.
- [x] Owner excluded 200% QA. Historical 200% findings remain evidence and are not passes.
- [x] Contract/instruction validators and all nine instruction tests passed, as recorded in the workflow.

No exhaustive 100% visual pass, native verification or prototype-playback pass is claimed. Reserved After pilot positions remain empty. F01 acceptance does not satisfy the following future screen criteria.

## Future F02/F03 — AFTER screen parity

Apply these active criteria to each authorized AFTER pilot. Next: **F02 — Tonight Pilot**, using the [Tonight contract](screens/tonight.md). Later F03 scope must be defined by its own task.

- [ ] Confirm the three immutable BEFORE source names, IDs and dimensions before copying.
- [ ] Match the source fixture's data, selected context, all actions, warnings, summaries and lower longread sections.
- [ ] Keep fit, persistence and recorded results separate; no invented measurements, forecasts, storage, AF/MF scale or quality score.
- [ ] No-site, missing input, unknown, partial, stale, unavailable, invalid and pending/failure states are represented in appropriate component specimens.
- [ ] Preserve explicit Save, dirty-leave confirmation, Undo intent, picker confirmation and viewed-night isolation in prototype annotations.
- [ ] Use one revision's tokens and styles, no unbound local color/geometry changes, and no shared dependency that modifies BEFORE.
- [ ] Required Figma properties and variant defaults match catalogs; lists use nested instances with labeled data.
- [ ] No production data or science formula is recomputed by a Figma layout.

## Future F02/F03 — AFTER layout, text and accessibility design checks

- [ ] Full longreads have no clipped or omitted content. First-viewport comparisons show 375 × 812 at 1:1 and account for chrome/footer/safe insets.
- [ ] Each BEFORE/AFTER pair has a 120-px clear gap; matching widths and content fixtures; no stretching or optical scaling.
- [ ] Auto Layout owns growing screen/section/row content; absolute positioning is restricted to charts and board presentation.
- [ ] Text layers hug height, essential labels wrap, buttons stay reachable, icons do not replace necessary words.
- [ ] Check long target/site names, Cyrillic glyphs including І/Ї/Є/Ґ, negative signs, decimals, units, GMT offsets and +1-day markers.
- [ ] Inspect each AFTER screen at 100% and record exact visual coverage. A wider or taller group must not create clipping or overlapping hit regions.
- [ ] Inspect 200% text specimens for future AFTER screens unless explicitly excluded by that pilot task; record the scope and any exclusion. The F01 200% exclusion is not a 200% pass or an automatic waiver for future screens.
- [ ] Check normal text contrast at least 4.5:1; large text and essential UI indicators at least 3:1 against their actual adjacent backgrounds. Record evaluated pairs and exceptions, including disabled controls. Numerical checks alone do not establish accessibility.
- [ ] Focus ring remains visible and unclipped; label/word/icon/pattern supplements color. Each action has its intended semantic name and minimum hit region.
- [ ] Weather table preserves pinned local-time column and exposes horizontal overflow intentionally; DST repeats remain distinguishable.
- [ ] Chart gaps remain gaps; event times, legend and selected preview marker remain readable.
- [ ] Semantic layer names and source annotations are present; no placeholder labels or undocumented variants.
- [ ] Correct/incorrect system examples are clearly differentiated so an incorrect specimen cannot be adopted by mistake.

## Flutter migration — separate authorization and native verification

Native checks have not been performed. These requirements become applicable only to an explicitly authorized migration.

- [ ] Owner separately authorizes Flutter migration.
- [ ] Validate actual text scaling, TalkBack semantics/traversal, touch/keyboard focus and reduced motion on relevant native targets.
- [ ] Run scoped behavioral/widget regressions for changed callers, including Save/Undo/draft guards, data gaps, time zones/DST and fixed-time weather table.
- [ ] Verify source/calculation/database/backup behavior and offline/freshness handling remain unchanged.
- [ ] Maintain production Light and Field Red, including the field filter, even though their redesign is deferred.
- [ ] Compare actual native renders against accepted After evidence; record native scope and owner decision separately.

A passing static Figma check is evidence about the artifact, not about native execution, scientific correctness, device accessibility, release acceptance or owner approval.
