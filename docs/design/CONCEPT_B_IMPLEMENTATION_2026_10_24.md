# Concept B — approved native implementation

Status: **IMPLEMENTED — bounded verification complete, owner visual acceptance pending**, 2026-10-24. [Implementation report and receipts](migration/CONCEPT_B_NATIVE_DELIVERY_2026_10_24.md); current operational evidence is in PROGRESS. This is the bounded owner task and specification, not a new roadmap.

The subsequent owner-authorized [whole-app 100% completion](CONCEPT_B_COMPLETION_100_2026_10_24.md) extends the same direction to the child pages below, fixes CBA-01/05 and the local CI blockers, and keeps explicit dispositions for CBA-01–10. Its primary review is 100%; 125%/150% follow after that review, while full 200%/TalkBack remains deferred. Existing accessibility tests and open requirements are retained. The original nine-screen implementation/evidence remains historical at its recorded inputs.

The owner's instruction in this chat: “Я погоджую цей концепт, імплементуй його” and “Новий дизайн лише групує існуючі елементи … Весь проект повинен мати один узгоджений шрифт”. This approves the structural direction of Home B and its eight-screen suite, preserving existing functions; it additionally supersedes the former Source Serif 4 editorial and Roboto UI exceptions with **Geist throughout production UI**. MaterialIcons remains an icon font. Historical font files/licences and frozen browser/reference/concept assets are preserved.

## Native specification

- Use existing `HybridTokens.surfaceSubtle` for flat document groups: Light `#F7F7F5`, Dark `#202020`, Field `#110000`. Existing foreground/status/science roles remain. No raster shading, decorative effects or invented affordances become implementation requirements.
- Existing phone gutters remain 20 dp. Ordinary group padding is 16 dp, radius 8 dp, section gaps generally 16 dp. Preserve special source-owned chart/calendar geometry. Calendar content retains its former available width while its group heading is inset. Text grows naturally; no fixed-height text cards or type shrinking to mask overflow.
- Keep current role sizes and hierarchy; `nightHeading` and `answerHeading` become medium-weight Geist. Navigation and chart tick labels also use Geist. Theme, form, button, numeric and inherited prose roles share the existing family. Unsupported Unicode is never deleted; bundled Cyrillic/unit glyph coverage and actual rendered styles are checked.
- Groups add no interaction, clipping, focus/semantic merging, persistence or calculations. Existing callbacks, keys, disclosures, forms, Save/Discard/Cancel and source/UTC/zone/DST semantics remain authoritative. Responsive stacking may make existing content readable in the reduced inner width.

| Screen | Required group coverage |
| --- | --- |
| Tonight | Your plan; The night ahead including compact Weather and the optional timeline key; the existing next-action pair |
| Plan | Fit/persistence identity; site/target/rig; capture blocks/actions; Estimate plus assumptions, gain and rig disclosures; The night ahead with Night/Moon, Weather and Sky darkness; fixed existing Save bar |
| Logbook | Existing progress action; continuous month groups with compact badges, preserving lazy row layout, search/filter/export/navigation and date ordering |
| Night | Viewed context; dark-time answer; existing time browser/current state; reading/Moon/Sun disclosures |
| Moon | Viewed context; moon-free answer; complete calendar or existing large-text week view; time browser/current state; existing detail disclosures |
| Weather | Viewed context; summary/coverage/freshness; statistics/hour selection/limitation; existing forecast details; coming-night coverage and limits. All existing weather presentation modes and failure states remain |
| Library | The three existing Rigs/Targets/Sites destinations; existing count retry and Logbook note |
| Settings | Preferences; Data and about. Existing group editors and their persistence/return behavior stay unchanged |
| Record result | Review/eligibility; outcome; conditional counts or reason; optional notes; optional measured conditions; existing Cancel/Save bar and validation |

### Owner-authorized child-page extension at 100%

| Family | Required functional groups |
| --- | --- |
| Library lists | Search/add; continuous joined result groups; catalogue/source and help where present. Preserve lazy rows, manage/select, current/saved/transient site order and alternative-position actions. |
| Library details | Identity/edit actions; complete camera/optics, target attributes or position/zone facts; optional source/details disclosures; existing plan/delete ownership. Full record names may wrap. |
| Library editors | Identity/type; meaningful characteristic/position groups; optional records. One Form retains every field/validator and existing Save/Cancel/dirty guard. Narrow pairs stack according to available phone width. |
| Plan choosers | Site/manage and night/zone; rig choice/help/manage; target search/count/context and continuous choices. Fixed Apply changes edits the draft; it does not Save plan. |
| Capture editors | Block context/frame/source, exposure/count/settings, conditional camera records and Details; timing versus storage assumptions; calibration context/references and one complete group per frame type. Preserve all units, warnings, provenance and scope copy. |
| Candidates | Night/context, full-width filters and continuous lazy results. Duration, fit reasons and target selection retain their original meaning. |
| Logbook detail/Progress | Outcome, planned-versus-recorded, immutable snapshot, notes/conditions, comparable totals, export/manage; one complete Progress group per target with existing filter/rig subtotals. |
| Settings children | Appearance Theme/Field, Text, Units, Weather; Planning budget/scope, imaging window, gates/optional times, guidance; Privacy setting/disclosure; Back up versus Restore; About identity, continuous sources/notice, privacy and licence. Preserve immediate versus staged behavior. |

Do not turn native calendars/dialogs, map, scientific charts, existing Welcome/metadata cards or sparse safety/error states into obligatory document groups. The per-page [completion matrix](CONCEPT_B_COMPLETION_100_2026_10_24.md#child-page-matrix) records implementation and evidence limits without closing deferred adaptive criteria.

## Acceptance and verification

The complete existing feature set is retained; this task does not implement new functionality or close F/G/release/owner gates. Check actual native groups, resolved font families, theme pairing, reachable targets, centring and full wrapping at 100%/200%, including long names and the current error/empty branches. Use meaningful tests for affected callers, real-font renders, analysis/format/encoding and runtime reload/inspection under V1–V8. A source-render sequence's fixture state is not automatically a product defect or a physical PASS. Record failures and their cause honestly.

No Git delivery, roadmap work, signing or publication is authorized. Stop when the approved implementation and its required evidence are complete; explicit owner visual acceptance remains separate.
