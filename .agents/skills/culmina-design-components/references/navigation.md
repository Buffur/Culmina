# Navigation: API and state map

Paths are relative to the repository root. Keep existing routing authoritative.

| API/source | Inputs, variants and slots | State and interaction contract | Adopter/check |
| --- | --- | --- | --- |
| `lib/presentation/navigation/app_shell.dart` | Tonight, Logbook, Library, Settings; inspect current router integration | Preserve branch state and Back behavior. Tonight remains the tab name while the page title can name a different selected night | Existing navigation tests; actual Tonight screen |
| `ContextLine` in `lib/presentation/shared/context_line.dart` | Required nullable `siteName`, nullable `night`, callbacks `onSite/onNight`; optional `zoneId`, `nightStartUtc`, `framed=false` | Independent site/night actions; without a site pass `night:null` and omit zone data. `framed:true` is the current Home/planner variant. Zone caption appears once when an instant is supplied | `test/presentation/shared/context_line_test.dart`; Home and planner; isolated skill trial |
| `pickNight` in the same file | Existing calendar picker returning `CalendarDate?`; inspect the current signature | Null means cancelled. Selecting a civil evening date must not shift through UTC conversion or implicitly save a draft | ContextLine tests and current caller |
| `DetailScaffold` in `lib/presentation/shared/detail_scaffold.dart` | Required `title`, `summary:Widget`; optional textual `context`, `zoneRule`, `sections:List<Widget>`, `actions:List<Widget>?` | Title wraps in body with header semantics; app bar retains Back/actions. Summary reports facts. One zone caption, discoverable disclosure for long sections | Native gallery detail-template checks; Night & Moon / Weather |

Callbacks and slots are the Flutter equivalents of editable properties and nested instances. Keep icon/text geometry stable when changing state, allow long labels to wrap and preserve separate accessible action names. Browser analogues do not establish actual routing or Material semantics.

The local browser analogue is `design/home-lab/conditions.html`: Night/Moon/Weather share one viewed context, separate from the active plan. Browsing remains transient; only explicit adoption changes a draft or creates a guarded copy. `plan-model.js` owns canonical saved records and the separate working checkpoint. See `docs/design/PLANNING_SCREENS_2026_10_19.md` for scope and evidence; these are not production router APIs.
