# Android phone format correction — 2026-10-19

Scope: local Home/Plan concepts, existing design skills and documentation. The owner requires Android application format and retains the approved restrained Hybrid Notion + Journal direction. Existing Flutter screens supply functional contracts, not a visual template. Earlier desktop Plan captures are historical.

## Applied

- Plan is a maximum 412 CSS-pixel phone viewport on desktop; the preview is a compact Android phone, not a desktop dashboard. Status and gesture bars are mock chrome.
- Android-style top app bar, Back and field-mode action; independent vertical content scroll; persistent bottom Save. Theme, scale and fixture selectors are outside the phone.
- Capture blocks edit on a dedicated phone screen with Cancel, single-column fields and persistent Apply. Draft/plan save boundaries, validation, optional records, Undo and saved-state feedback remain.
- Home's previous wide mode is now “Один Android-екран”. All four Hybrid variants retain one content column and four bottom destinations. Your plan still has no border/shadow.
- Three skills and the existing workflow/review now explicitly preserve the Android target and distinguish the functional reference from visual inspiration.

## Executed checks

- `node --check design/home-lab/app.js` and `node --check design/home-lab/plan.js`: PASS.
- `node --test design/home-lab/scripts/check_plan.mjs`: 11/11 PASS. Fixture arithmetic, scientific exclusions and storage validation are unchanged.
- `python design/home-lab/scripts/check_inventory.py --self-test`: PASS, 21 sources unchanged, 13 proposal roles and 35 palette usage descriptions.
- Browser Plan matrix: 1280×1040 and 412×915, light/dark/field, 100%/200% (12 combinations). Phone width remains at most 412; one content column, no horizontal page/content overflow, visible Save, no tested visible phone button/select below 48 CSS pixels.
- Browser editor: blank Frames stays blank and invalid; Apply accepts 130; Back displays Save/Discard/Cancel; Cancel preserves changes. A failed sample save exposes Retry; retry/reload retains 130. Restored and saved the original 120-frame sample afterward.
- At 412×520, 200% text, dark: exposure input can be focused inside the scroll area and Apply remains visible. This is constrained browser-height evidence, not an Android keyboard test.
- Missing forecast remains Unknown with retry. No site removes the night selector and disables Save with a remedy. Home Open planner preserves selected context.
- Final Home navigation check at 412×915, explicitly verified 200%, all four Hybrid variants: four columns, labels 22px (11px base caption role), targets about 83×93px, no horizontal content/label overflow. Initial 2×2 navigation was found and corrected; final results supersede those initial observations.
- Final tab warning/error logs: empty. Temporary viewport overrides reset; sample Plan left open in light theme, 100%.

Raw browser observations and hashes: [android-browser-checks.json](android-browser-checks.json). Captures: [Plan in desktop host](android-plan.jpg), [phone host](android-plan-phone.jpg), [editor 200%](android-editor-200.jpg), [compact-height editor](android-editor-200-compact.jpg).

## Evidence limits

HTML controls approximate Android/Material appearance. No Flutter production source, database, astronomy or roadmap acceptance was modified. No Android build, emulator, physical-device, predictive Back, native picker, actual IME or TalkBack verification was performed. Browser CSS pixels are a preview convention, not a claim of device-density equivalence. Field-mode contrast retains its already documented product tradeoff; this is not accessibility certification.

Research and platform interpretation: [updated Plan review](../../../docs/design/PLAN_CONCEPT_REVIEW_2026_10_19.md#android-format-correction). The video, Notion/Google and prior Apple HIG / Fluent 2 / Spectrum sources remain in the existing research documents.
