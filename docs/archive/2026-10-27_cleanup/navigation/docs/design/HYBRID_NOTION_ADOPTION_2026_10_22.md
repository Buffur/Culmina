> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/HYBRID_NOTION_ADOPTION_2026_10_22.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/HYBRID_NOTION_ADOPTION_2026_10_22.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `beaf56e56247614515d5721bfc3816b64d32fc8be94550d5c6dd68f445db72f8`.

# Main Hybrid web reference: Notion accents and Weather A/B

Owner decision: use the Notion treatment in the main design, keep Gradient, and retain Weather A/B with a setting to choose the view. This adopts the selected treatment in the existing **web** prototype; no native Flutter implementation or device acceptance is implied.

## Applied behaviour

- `notion-hybrid.css` is shared by Home, Plan, Conditions and Workspace. Existing light/dark neutral surfaces, ordinary text/actions, navigation and scientific values remain in place. Weather icons and main chart lines use blue (`#0075DE` light / `#62AFF3` dark). Selected weather hours use pale-blue treatment. Cloud, dew point and gust secondary lines remain neutral, with existing line styles. Plan gain colours use the same blue family.
- Main Home/Night/Moon timelines keep `gradient`, a soft blue ramp and an explicit black dark interval. Dates, event positions, cursor steps and Moon lanes are unchanged. Comparison studies retain their alternative presentations.
- Saved plan labels use a compact green treatment. Not saved / Saved · changed use amber, retaining their exact words and existing dirty-state logic. Logbook saved/completed labels share the green semantics; Partly and Not recorded retain caution wording/treatment. Not done is not reclassified as an error.
- Field explicitly retains red/black only, including selected weather hours, statuses and timelines. Other design concepts are not recoloured.
- Settings → Appearance → Weather view offers **A · Compact rows** and **B · Hourly charts**. A is the initial default. The existing summary on Tonight remains compact for either preference. The studio-only selector was removed from the main Weather page; that page links to Settings → Appearance.

## Persistence and compatibility

The preference is stored as optional `settings.display.weatherPresentation` (`rows` / `charts`) in the existing version-1 preview settings payload. Older records/backups without it validate and read as `rows`; defaults are added in memory without rewriting old data on read. Invalid enum values fail settings validation. Export/review/restore includes Weather view and normalises missing legacy values. The existing storage-error and retry flow applies to this setting.

The Conditions page reads the shared preference on entry and settings storage events. A stored setting, including the legacy rows default, overrides a stale `weatherPresentation` URL. With no settings record, an explicit comparison link may still preview A/B. No setting change writes a plan, navigation draft, Library record or Logbook entry.

## Verification

`node design/home-lab/scripts/check_notion_adoption.cjs` passed. Fresh isolated browser storage was used, not the owner's profile. Coverage: A default; Settings saves B; navigation through Tonight to Weather; reload; cross-tab switch to A; stale URL precedence; actual JSON export and confirmed restore of both legacy and new settings; legacy read without rewriting; invalid preference rejection; unchanged planning/privacy and plan/draft data; main Home/Night gradient and black night; Light/Dark/Field roles; Plan/Logbook/Library/Settings smoke; 375/412-px Settings layout and >=48px radio-label targets. No browser page errors occurred.

Nine existing Node checks in `check_bridge.mjs` and `check_hybrid_defaults.mjs` passed, covering Library/plan snapshot boundaries, budget assumptions and preview backup rollback. JavaScript syntax and whitespace checks passed. Browser screenshots of Home, Weather and Appearance were visually inspected. Evidence: `design/home-lab/evidence/notion-adoption-2026-10-22/qa.json` and PNG captures. Palette-study contrast evidence remains bounded to its existing sampled-role checks; this adoption is not a blanket accessibility certification or native validation.

The final main-page harness also verifies Home persistence labels and selected-hour text at >=4.5:1 and primary/secondary weather chart paths at >=3:1 in Light/Dark. Field is checked for preserved red/black roles, not ordinary contrast conformance. The Home studio's old sky picker is now labelled as applying to the other concepts because Hybrid uses the selected Notion ramp.

Source colour rationale and retrieved Notion observations: [Palette comparison](HYBRID_PALETTE_COMPARISON_2026_10_22.md). Owner-selected web treatment is applied; other comparison palettes remain proposals.
