# Android prototype quality refinement — 2026-10-20

Owner amendment later on 2026-10-20: Home Weather stays a compact widget, and the sky rail gains smoother muted palette experiments. The earlier expanded Home Weather row below is historical. [Current amendment and new tab scope](ANDROID_TABS_2026_10_20.md), [current integrated evidence](../../design/home-lab/evidence/TABS_PREVIEW.md). Earlier source/research remains preserved.

Scope: the owner's [quality brief](../../design/home-lab/evidence/ai/quality-owner-brief.md), applied to the existing browser Android prototype. Preserve the Hybrid Notion + Journal direction and all earlier [video and reference research](WORKFLOW.md). No native implementation, astronomy engine or additional production feature is authorized by this refinement. Current proof and review dispositions belong in [completion evidence](../../design/home-lab/evidence/QUALITY_REFINEMENT.md).

## Decisions and source constraints

| Brief | Decision and implementation |
| --- | --- |
| 1 — Colour | Preserve neutral controls/surfaces. Reuse existing chart/caution colours in named browser roles; exact values and per-theme boundaries are in [colour guidance](QUALITY_COLOR_GUIDANCE_2026_10_20.md) and the token skill. Time/state has additional shape/text cues. No production palette changed. |
| 2.1 — Scales | One shared Home/Night/Moon component: continuous sky ramp over existing event segments, exact dark bracket, two solid Moon lanes. Blends smooth the presentation without calculating sky brightness. UTC cursor, local labels and five-minute exclusive-end behavior remain. |
| 2.2 — Night ahead | Night row and its time rail form one group; Moon summary follows, then Weather. Consistent spacing and label roles keep related information together. |
| 2.3 — Home Weather | Cloud range and clearest/cloudiest sampled hour, then air, wind/gust, dew-margin samples and precipitation. Only eligible known values contribute. Coverage is hourly samples, not elapsed hours; no observing score, seeing or transparency is inferred. |
| 3.1–3.3 — Night/Moon facts | Replace competing 57%/63% right-aligned flex widths with label-over-value grid cells. Moon intervals have explicit From/Until subrows; dates and offsets remain. Key fact labels are 15 px, values 22 px at 100%. Moon-free duration, range and classification are grouped. |
| 4 — Moon focus | Main content is the time browser and calendar. Phase/interval facts and reading guide move into a closed end disclosure. Large text retains the seven-day calendar list. |
| 5 — Weather | Observing-period answer and relevant measurements precede coverage/freshness/retrieval lead. Hourly strips have separate named units, exact values and source table. Missing cloud does not hide known temperatures or become clear sky. |
| 6.1 — Target | Search a clearly identified six-object subset of the actual 164-object bundled catalogue. Exact designation/alias, designation prefix and name substring follow `lib/domain/services/target_search.dart`. Query text does not select, save or dirty a plan. No fake all-catalogue backend. |
| 6.2 — Rig | Camera-class SVG icon and only recorded equipment properties; missing values say Not recorded. Astro example copies the existing `equipment_seeder.dart` entry, including verified camera versus illustrative optics provenance. DSLR's prior guessed sensor/optics values are removed. |
| 6.3/6.6 — WB | Follow `capture_evidence.dart` and `capture_block_dialog.dart`: Auto, six presets, Kelvin, Custom; numeric Kelvin and applicable tint appear beside Mode. Kelvin 1000–40000 and tint ±1000 are model sanity bounds, not a device range. Custom is measured camera WB, not a Kelvin synonym. WB/focus records are offered only on supported camera classes' Light blocks; existing hidden values are preserved. |
| 6.4 — MF | Preserve AF/MF recording. `FocusMode` explicitly has no numeric lens position or camera command. A graduated slider would invent precision and control. [Nikon's manual-focus reference](https://onlinemanual.nikonimglib.com/z7_z6/en/05_basic_settings_01.html) illustrates focus-ring/indicator behavior; that capability is absent from Culmina's model. |
| 6.5 — Filter | New Light/Flat fields start genuinely empty with an italic placeholder and explicit empty meaning. Existing recorded filters remain values. `newBlock` differs from the intentionally recorded default demonstration block. |
| 6.7 — Gain | Three reviewable mathematical alternatives, described below. Comparable groups and unknown sensitivity stay separate; no SNR or image-quality prediction. |
| 6.8 — Workflow | Site/target/rig precede dependent block settings; filter sits with exposure/count, conditional WB fields together. Exactly one editor Apply and persistent main Save; Undo, calibration proposals, working checkpoint and adoption guards retained. Phone height now follows actual remaining viewport after wrapped lab controls. |

## Gain alternatives

Use the lab's **Gain graph** selector, or open `plan.html?gain=all`, to compare all three inside the existing Details disclosure. Lab selectors stay outside the phone.

| Variant | Question / reference | Strength and limit |
| --- | --- | --- |
| A — Time curve (default) | How does integration time change relative to this group's planned time? `sqrt(T/T_plan)`, plan = 1.00× | Best fit for planning a time budget; matches the actual `StackingGainCurve`/O2b contract. Includes half-time and double-time comparison, explicit axes, marked plan and text equivalent. It is not the headline gain against one frame. |
| B — Group bars | What is each group's ideal `sqrt(N)` gain against one of its own frames? | Compact overview across groups; warns that different filters/exposures do not compare signal. Explicit numeric table remains authoritative. |
| C — Block steps | What does each block add within its comparable group, in plan order? | Shows cumulative frame count and diminishing increments through the actual block boundaries. Less useful for a one-block plan, so it is an optional alternative. |

A stays the default because the task is allocating time to a capture plan. B and C remain reviewable alternatives, not new product workflows. At 200% the graph itself can scroll horizontally to preserve labels; the phone page/content cannot overflow. Graph data also has captions, values and a group table, following [W3C's complex-image guidance](https://www.w3.org/WAI/tutorials/images/complex/).

## Execution boundary

Claude CLI Sonnet completed sections 1–5. Opus implemented part of Plan before a session-limit interruption; main-session integration completed and verified the remaining wiring/controls/styles. A separate review attempt also hit that limit; a fresh read-only integration review was launched after the owner renewed limits. Only actual returned findings and executed checks count as evidence. No failed CLI attempt is labelled completed work.
