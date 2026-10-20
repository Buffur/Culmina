# Assessment B detector interpretation

Raw report: `detector.json`. Static scan of current index.html, plan.html, conditions.html and workspace.html, including linked CSS; ran once. No scan stderr. This is neither live DOM conformance nor a design score.

Nine records: seven warning records for `overused-font` (Inter on all four entrypoints; Roboto on Plan, Conditions and workspace), plus two advisory records (index border with 64px shadow; Conditions repeating gradient).

- Font warnings are generic aesthetic popularity rules, not accessibility findings. Static linked CSS includes the lab default Inter and Android navigation Roboto. The selected Hybrid family is Manrope (`tokens.json:92–94`), with deliberate serif headings. They do not justify replacing the approved typography or count as seven independent UI defects.
- Repeating stripes map to `conditions.css:68`, `.cloud-column .gap-mark`, the missing cloud sample marker. The stripes encode missing data, not decorative background texture. Treat as a contextual false positive; preserving Unknown is a Culmina invariant.
- Hairline border plus diffuse shadow maps to the generic `dialog` rule in `styles.css:9`. Hybrid `#detail.phone-detail` at line 46 overrides geometry/border/background but does not explicitly remove that inherited shadow. This is a real CSS combination; it is only an advisory style observation, not evidence of broken interaction or Android native acceptance. Review its visual contribution against the supplied Home-dialog images before assigning any severity.

No deterministic detector accessibility, responsiveness or functional failure is established by these nine records. Keep them separate from the independent visual review and browser geometry evidence.
