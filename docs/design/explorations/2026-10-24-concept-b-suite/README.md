# Concept B across eight screens — 2026-10-24

Status: **CONCEPT / NOT IMPLEMENTED**. The owner requested Plan, Logbook, Moon, Weather, Night and other screens in the supplied Home B style before implementation. The additional bounded sample is Library, Settings and Record result. This is a direction study, not adoption of production layouts or tokens.

[Open the gallery](index.html). Switch screens, view the generated concept alone, or compare it with the current Flutter render at the same nominal phone width. [Home style reference](style-reference-home-b.png), [original prompts](prompts.json), [targeted refinement prompts](refinement-prompts.json).

## Source and process

- Base `develop` / `a4798d667007a83e12de3c94d95bb68c22947748`, including the preceding owner's uncommitted layout fixes. All pre-existing application, test and documentation changes were preserved. No production/reference code, dependencies or scientific calculations were changed by this exploration.
- The Home B image is the actual generated image supplied again by the owner, copied without modification as the style reference. Current screen inputs are real Flutter host renders with the existing synthetic Hybrid QA fixture, bundled fonts, dark theme, 100% text, 375 logical px wide / DPR 1. No personal phone records or private coordinates entered generation.
- The eight-screen source run uses the existing `hybrid_transfer_renders_test.dart` harness and existing shots: `plan,logbook,night,moon,weather,library,settings,result`, at 375 × 1450. A separate two-shot 375 × 2200 run captures complete Plan and Weather content. The long Weather capture is the generation input. Plan generation uses the 1450 source and explicit complete text, with the extended capture available in the gallery for full-current comparison. Adjacent JSON files retain actual text geometry/style.
- Tool: built-in `image_gen.imagegen`, one initial call per screen, then one targeted refinement each for Plan, Logbook, Moon, Weather and Record result: **13 actual calls**, within the per-screen exploration limit. Each call uses the Home B style image plus the corresponding actual content screenshot; refinements use the prior generated image. The Plan refinement also uses the complete extended screenshot to restore its lower disclosures and night conditions. No API/paid fallback or new service was used.
- Final PNGs are under `concepts/`; the five refined screens' initial PNGs are retained separately. The source screenshots were never redrawn or presented as generated concepts. Exact image dimensions/hashes and source provenance are in `manifest.json`.

## Hypothesis and tradeoffs

Shared hypothesis: subtle tonal document blocks should make major task sections easier to scan without deleting controls, scientific context or failure/unknown distinctions. The experiment keeps dark charcoal surfaces, Geist-like UI type, existing editorial answers and semantic colors. A generated raster cannot establish exact font metrics, touch targets or runtime behavior.

| Screen / final image | Grouping and expected benefit | Tradeoff / checks before a later Flutter implementation |
| --- | --- | --- |
| [Plan](concepts/plan.png) | Fit summary, context inputs, capture plan and estimate/assumptions become distinct sections. Tracking warning, Unknown storage, relative gain and Save plan remain visible. | More padding can lengthen the editor; preserve keyboard/insets, block actions, warning and save/dirty semantics. Reuse existing widgets/ViewModels, not image text as logic. |
| [Logbook](concepts/logbook.png) | A separate progress action and one monthly record block keep seven entries together. Persistence/result badges remain compact and distinct. | Group padding reduces row width; verify long target/rig names and two badges at large text, filters/search and actual list pagination. |
| [Moon](concepts/moon.png) | Answer, complete 31-day calendar and time browser read as related sections. | The calendar remains dense at phone width; verify the existing large-text week-list adaptation. Phases and durations remain source-owned calculations, never reconstructed from this raster. |
| [Weather](concepts/weather.png) | Summary/provenance, known-sample statistics, optional detail and coming nights separate decisions from explanation. Coverage, unknowns and forecast limits remain. | Long scientific notes require natural growth; verify hourly focus/selection, offline/partial/no-dark states and source/age text. Static statistic rows must not become links. |
| [Night](concepts/night.png) | Context, dark-time answer, timeline/current state and reading disclosures separate reading tasks. | Too many blocks can fragment the answer. Keep preview/current state semantically linked, exact-boundary versus five-minute-step distinction and separate lane cues. |
| [Library](concepts/library.png) | One flat collection block groups the three existing Rigs/Targets/Sites destinations. | Keep the short screen short; do not expand it into a dashboard. Verify long counts/descriptions and existing navigation. |
| [Settings](concepts/settings.png) | Preferences and Data and about become two coherent groups. | Keep summaries as links to existing editors, not new inline toggles. Check long planning units, text scaling and save/cancel ownership. |
| [Record result](concepts/result.png) | Outcome, frame counts, optional notes and optional conditions are clearly separated. | Insets can make forms taller; preserve focus/keyboard reachability, validation and Cancel/Save result. Empty measured values stay empty. |

The direction is feasible with caller-owned section surfaces/padding and existing components. This does not approve a blanket card component, new palette, global font replacement or navigation change. For a selected implementation, specify each caller's tokens, spacing, states and reflow using native roles first.

## Inspection and limits

All eight actual generated outputs were visually inspected against source content. Targeted refinements corrected a serif Logbook root title and missing field-mode icon; an invented Moon-state action arrow/blue selection accents; invented static-weather row arrows and non-answer serif headings; and a blue result radio accent. The complete Plan comparison exposed missing lower content; its refinement restores Stacking gain details, Rig details, The night ahead, Night & Moon, Weather and Sky darkness. The final files retain these functions, the complete calendar, seven log rows, Plan warning/unknown, weather provenance/limitations and optional empty form fields.

Residual artifacts are explicit: background texture/shading remains approximate despite requests for flat fills; exact font size/weight, icon strokes, radii, row heights and lane/phase geometry are not normative. Night's generated date heading has editorial treatment differing from its native sans role, and some disclosure chevrons use navigation-style arrows. Exclude these artifacts from any later specification. The existing native typography and science remain authoritative. This study compares hierarchy/grouping, not pixel parity.

Only dark/100% is generated, matching the selected Home reference. No Light/Field, 200%, keyboard, loading/empty/error or physical accessibility acceptance is inferred from these rasters. The current-source render runs passed, but they certify only those source frames. This turn performs no app install, persistence action, new native acceptance, full suite, CI, commit or push. The previous task's checked code inputs remain unchanged.

The gallery is a local review aid, with screenshot-backed previews rather than working product screens. Its screen/mode controls and image loading are browser-checked separately. Any implementation must await the owner's selection/instruction and then receive its own proportional verification.
