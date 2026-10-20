I've rebuilt the Plan prototype as specified. It's only been statically reviewed: I didn't open it in a browser, and per your instructions ran no Bash, tests or browser checks. Treat every behaviour below as unverified until it's run at 412 px, 100%/200% text and in the three themes.

**What's in place, by requirement**

1. **Hierarchy:** the order is:
   - the identity strip, with the night and saved state only;
   - the answer (verdict, "X needed of Y usable", a reason, and the capture end marked as example arithmetic);
   - a checklist of every missing input;
   - three tappable rows, "Site and night", "Target" (the only place the target appears) and "Rig";
   - capture blocks, then the four estimates;
   - the Budget, Stacking gain and Rig disclosures;
   - "The night ahead" (Journal serif) with two rows linking to Night & Moon and Weather.

   There are no selects on the main screen and no target-window chart.
2. **Save:**
   - The button is always visible and is disabled only when site, target or rig is missing (with a "Choose …" link next to it) or while an edit is open.
   - Empty plans can be saved, and weather plays no part.
   - The "Save fails once" scenario keeps your edits and offers "Retry save".
   - Saving goes through `savePlanRecord`. The working plan and any open editor (including invalid typed values) are written to the shared checkpoint on every change, so they survive a reload.
3. **Block editor:** a full-phone screen with one Add/Apply button in the bottom bar. Fields follow the rig's camera type:
   - **Phone/DSLR:** frame type, exposure (fractions work), frames, ISO, white balance (+ Kelvin), AF/MF, filter.
   - **Astro:** gain, with binning in Details.
   - **Unknown:** no ISO or gain field, just a "Choose a rig with a known camera type" button that opens the rig picker and returns to the editor.

   Values for fields the current camera type hides are kept. New blocks start with ISO and WB unrecorded and a labelled "Proposal: 60 s". Switching to Flat proposes 1 s and Bias 1/4000 s, both labelled, so nothing silently inherits the light exposure. Invalid values stay in their fields with an error attached.
4. **Leaving and focus:**
   - Closing a changed editor (✕, Escape or Cancel) asks before discarding; an unchanged one closes at once.
   - Back and New plan offer Save / Discard / Cancel, and a failed save keeps the dialog open with "Retry save".
   - Theme and text-size changes never touch the plan.
   - After Apply or Cancel, focus returns to the row you came from.
5. **Block list:**
   - Add, edit, remove, and Move up/down buttons.
   - Undo after add, edit, remove or adding calibration; it's cleared by a newer edit, a site/target/rig change, or a save.
   - Each row shows its integration, ISO/WB/focus records, whether values are proposals or entered, and how many frames fit the example window.
   - An empty plan shows "Add light frames".
6. **Build calibration frames:**
   - It opens a proposal screen that references a light block, with editable Dark/Flat/Bias counts and labelled exposures planned outside the window.
   - It explicitly makes no claim about an existing calibration library, and there's no import stub.
   - Cancel changes nothing; Apply adds the blocks and offers Undo.
7. **Estimates:**
   - **The four outputs:** integration, total time, theoretical storage, and relative gain per comparable light group ("vs one comparable frame", never absolute SNR).
   - **Budget disclosure:** time inside and outside the window, overheads, setup, fit margin, and the 30 MB basis marked as not measured.
   - **Gain details:** a text table and a small √N line graph.
   - **Edit assumptions:** a working screen that validates and writes this plan's own `plan.assumptions`.
   - **Rig details:** they state that field of view isn't calculated rather than inventing one.
8. **Overflow menu:**
   - **New plan** is guarded. It creates an unsaved plan with a fresh id and empty target and blocks, and the saved record stays untouched until you save.
   - **Copy to another night** opens the Moon view of the conditions page.
9. **Conditions links:** they open `conditions.html` with the parameters you listed, after writing the checkpoint. Nothing is saved to the canonical record and no Save is required to browse. Messages from the conditions page are announced once when you come back.

**Limitations**
- The night is chosen from a select of the 14 example nights inside the "Site and night" editor, not an Android date picker.
- Moving a block clears Undo rather than offering an undo for the move.
- While an editor is open, the bottom bar shows a disabled Save next to Apply, which follows "Save visible at all times" literally but makes the bar busier.
- Unlike the old version, the URL `scenario` (No target / No site / No rig) no longer overrides a saved checkpoint, because the checkpoint deliberately wins over URL context. A leftover checkpoint will therefore mask those scenarios until localStorage is cleared.
- I added one field the shape didn't list: the checkpoint's `editor` holds `{stack, mainScroll}` so Back from conditions restores the scroll position.
- I removed the old "leave page?" browser warning, since the checkpoint now keeps the draft.

**Files changed:** `design/home-lab/plan.js` (rewritten), `plan.html` (overflow menu, leave and discard dialogs, `plan-page` body class) and `plan.css`. Every element ID and `data-*` hook you listed is kept. conditions.html also loads plan.css, so I kept every rule it shares; I found nothing else that used the Plan-only rules I removed. No other files were touched.