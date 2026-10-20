# Culmina Home lab

Run `python design/home-lab/scripts/serve_preview.py --port 4173` from the repository root. Open <http://127.0.0.1:4173>.

Ten Home composition proposals (four in the default Hybrid family) in a horizontal slider, eleven locally bundled font families, reference analysis, theme/text/scenario controls and simulated detail/edit interactions. The Design code section includes all source palette roles, type scale, spacing, shape, component examples and complete source snapshots. See [the workflow](../../docs/design/WORKFLOW.md) for contracts, skill routing, boundaries and adoption.

All displayed night, forecast and plan values are illustrative fixtures. They are not live calculations or a forecast. Fonts retain their licences in `fonts/`. This lab has no dependency on the Flutter database or application state.

Check source freshness and semantic completeness with `python design/home-lab/scripts/check_inventory.py --self-test`. This read-only command names stale/missing source files; it also checks role descriptions and variant radius coverage.

Refresh the source catalogue after relevant source changes: `python design/home-lab/scripts/build_inventory.py` (the local Flutter SDK colour definitions are read from `C:/flutter`). Font refreshing is a separate explicit operation: `python design/home-lab/scripts/sync_fonts.py` downloads official assets and licence files. Neither script modifies production application files.


The current Home review removes the Hybrid plan outline and offers a plan-first/conditions-first comparison. Open planner leads to `plan.html`, with editable blocks, explicit fixture estimates, Details and Save/Discard/Cancel. Saves affect only the browser sample; gallery Reset clears it. Run `node design/home-lab/scripts/check_plan.mjs` from the repository root for its arithmetic/grouping/validation/storage checks. See `docs/design/PLAN_CONCEPT_REVIEW_2026_10_19.md` and `evidence/PLAN_PREVIEW.md` for source mapping and verification.


## Current Hybrid

The owner-authorised refinement now includes interactive Tonight/Plan, Night/Moon/Weather and Logbook/Library/Settings. Library records can be explicitly selected into Plan snapshots. Supported global time budgets update the current estimate; Save plan captures them, with plan-specific overrides taking priority. Weather stays a compact Home widget. All astronomy/forecast windows remain labelled fixtures; custom site/target coordinates show unknown windows rather than invented calculations.

Welcome, reviewed local metadata JSON, explicit browser geolocation/manual coordinates, privacy-scoped session downloads and checked full-prototype backup represent existing tasks locally. Image-header extraction, map tiles, native share sheets and `.astroplan` database backup require the app. The full browser backup has its own format and does not touch the native database.

[Seven focused Hybrid refinements and Claude QA](../../docs/design/HYBRID_SEVEN_REFINEMENTS_2026_10_20.md) records the current `20261020-hybrid6` revision. The [preceding implementation report](../../docs/design/HYBRID_IMPLEMENTATION_2026_10_20.md) remains evidence for the broader browser flows. Open [Hybrid](http://127.0.0.1:4173/index.html?variant=blend&view=wide#concepts). No-cache responses prevent stale modules during local review.
