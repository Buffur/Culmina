# Current design baseline

Status: active source map, reconciled 2026-10-24 against `develop` / `origin/develop` `94cebfb6b2a3379f5991e61e1bd88f7120804601` (application delivery `8a21e7b0a2018b223d8a1e4a73c4baa64167414f`). This is documentation of existing intent, implementation and evidence, not a redesign or a new acceptance contract. Current authorization and pending work live only in [PROGRESS](../refinement/PROGRESS.md).

## Sources and their roles

| Source | Authority / use |
| --- | --- |
| [DECISIONS](../DECISIONS.md), owner briefs and explicit later approvals cited below | Approved product/visual intent; preserve original decisions and their supersession chain. Missing original approval is an uncertainty, never inferred from code. |
| [DESIGN_SYSTEM](../DESIGN_SYSTEM.md) and actual `lib/core/theme/` / `lib/presentation/` | Shared visual/interaction contracts and implemented state. Where a prose table is dated, inspect source and the later approved refinement before changing either. |
| [WORKFLOW](WORKFLOW.md) and five local Culmina skills | Task-specific application guidance; no independent scope or acceptance authority. |
| Frozen `design/home-lab/` at `86873ce343160c860706091e12b257090cc96d94` | Approved final Hybrid (`blend`) visual reference, accepted at `ed2955442110b31eec54fd8db436f1f4e0841993`; not an executable model for native science/data behavior. |
| [Hybrid transfer record](migration/HYBRID_TRANSFER_STATUS.md) | Completed transfer's HT-* coverage, native adaptations/deviations and owner's bounded §9 confirmation. Its old local-branch/push/toolchain remarks are dated evidence. |
| [P-1–P-6 delivery](migration/PHONE_QA_FIXES_DELIVERY_2026_10_23.md), [TD-120](migration/TONIGHT_CONTEXT_FIXES_2026_10_23.md), [TD-121](migration/GEO_OWNER_REFINEMENT_2026_10_23.md), [consolidation](migration/CONSOLIDATED_DELIVERY_2026_10_24.md) | Later implemented refinements and their specific verification/owner-acceptance limits. They are not interchangeable with the frozen browser. |

The frozen web tree ID is `993d674067c3df27a4d71cac2943830dba62226f`. Its files are unchanged between that reference and the reconciliation baseline. Serve/read the reference without modifying or regenerating it. Its fixtures are illustrative; native calculations, persistent data and failure states retain their production contracts.

## Implemented native foundation

Read values from their owners; this map deliberately does not duplicate token tables:

- Semantic colours/surfaces: `lib/core/theme/app_colors.dart`, `app_palette.dart`, `app_theme.dart`; adopted additional Hybrid roles: `hybrid_tokens.dart`.
- Typography: `lib/core/theme/app_typography.dart`, actual call sites and theme mapping. The owner-approved [Concept B implementation](CONCEPT_B_IMPLEMENTATION_2026_10_24.md) uses Geist for all production prose, headings, navigation and chart labels. Compact sizes remain explicit; MaterialIcons is an icon font. Earlier Source Serif 4/Roboto roles are superseded, while frozen reference assets remain historical. Both the Material-role scale and newer named Hybrid roles exist. Do not force current native body/heading roles back to the earlier Manrope or 14/12 bodyMedium/bodySmall instructions.
- Spacing/radii/motion/buttons: `app_spacing.dart`, `app_radius.dart`, `app_motion.dart`, `app_button_styles.dart`, `app_theme.dart`; shared layout/components live in `lib/presentation/shared/` and navigation in `lib/presentation/navigation/`.
- Font files, licences/provenance: `assets/fonts/`, `pubspec.yaml` and `SourceSerif4.source.json`. Browser fonts/licences remain a separate preserved reference collection.

Current Tonight composition, from `tonight_home_screen.dart`: title/context → Your plan → The night ahead → next actions (due result/candidates); no-site and loading/error states have their own branches. The one-time Welcome is not a permanent Home destination. Preserve compact Weather, draft/saved and planned/recorded meaning. Settings supplies initial Plan assumptions; AF/MF is a descriptive record, with no invented numeric MF control.

## Transfer and later refinements

The earlier [2026-10-20/21 migration](WEB_TO_FLUTTER_MIGRATION.md) and [parity follow-up](migration/DESIGN_PARITY_QA_2026_10_21.md) describe the `20261020-hybrid7` port. The final transfer uses the later `86873ce` web reference and is **COMPLETE within its §9 contract**, confirmed by the owner in [HYBRID_TRANSFER_STATUS](migration/HYBRID_TRANSFER_STATUS.md). That confirmation includes the recorded HT-DEV-01/-02/-16 decisions and contract exclusions; it is not acceptance of every later native change or of roadmap/release gates.

P-1–P-6 (TD-114–TD-119) are integrated via `2a43c89981c0f9e0f4d4eddc4a62484c470be928`: saved-status refresh, filled-button weight, unsaved-dialog wrapping, tab roles, exact-time alignment and selected weather-hour treatment. See their [plan and per-item sources](migration/PHONE_QA_FIX_PLAN_2026_10_23.md), [implementation](migration/PHONE_QA_FIXES_IMPLEMENTATION_2026_10_23.md) and [phone recheck](migration/PHONE_QA_FIXES_PHONE_RECHECK_2026_10_23.md). Phone 200%/TalkBack and other excluded scenarios are not inferred from those results; owner acceptance remains pending as recorded.

TD-120/TD-121 and the identity are integrated in `8a21e7b`: compact direct date/site actions, unified saved/transient sites and the later geo editor/search/name/map hierarchy. [TECH_DEBT](../TECH_DEBT.md) keeps their IDs and owner-acceptance state. The later geo presentation intentionally differs from the frozen web in its named scope; preserve it. An unknown approval source is a documentation finding, not a reason to revert native UI.

## Identity and generated outputs

Approved intent: [rounded refreshed-dark R3 mark](../DECISIONS.md#the-culmina-mark-finalised-and-its-launch-gesture-owner-2026-10-23), then [full launch gesture](../DECISIONS.md#the-full-launch-gesture-is-shown-before-the-app-opens-owner-2026-10-23). The second decision supersedes the native 600 ms/cut-short launch, and the earlier one-second held splash is historical. The approved mark geometry remains; Flutter owns the complete 1,400 ms gesture and a single reveal after readiness, with the recorded reduced-motion/error/background exceptions. Android supplies the matching still mark and handover.

The generator is `tool/culmina_mark.py`. Its outputs include Android launcher layers/monochrome and legacy PNGs, `splash_mark_*` / `launch_mark_*` / `launch_background_*` resources, `assets/branding/icon_512.png`, `lib/presentation/shared/culmina_mark_geometry.dart` and `lib/core/theme/culmina_mark_colors.dart`. `launch_gate.dart` and generated timeline implement the launch. [Identity lab](../../design/identity-lab/README.md) contains the historical studies and preview. Do not edit generated assets as independent authorities or run generators for documentation tidiness.

The old `744fe57` identity checkout contains an older UI base and private evidence; never restore it wholesale. Integration selected the intended identity diff onto current design/geo. Old `.s2check` app screens are a separate installed package, not evidence of canonical rollback; see [build selection](migration/DESIGN_BUILD_SELECTION_2026_10_24.md).

## Evidence and acceptance boundaries

| Layer | What it establishes | Limit |
| --- | --- | --- |
| Browser reference / computed styles | Approved visual target and illustrative interactions | No native/provider/database/device acceptance |
| Host tests / real-font widget renders | Named contracts, states, layouts and regressions on recorded inputs | No automatic physical interaction or human comprehension |
| Emulator capture/drive and normal APK | Recorded native states, startup and interactions | No unexercised physical-device, accessibility, provider or owner gate |
| Scoped physical checks | Exact installed package/artifact and observed flows at stated settings | No exhaustive DB proof, untested 200%/TalkBack, signing or release qualification |
| Explicit owner confirmation | Only the named contract/decision accepted | No inferred acceptance of later changes or unrelated F/G criteria |

The consolidation report and its [public verification record](migration/evidence/consolidated-2026-10-24/verification.json) distinguish reused host results, final regressions/analysis, seven-frame Android capture, physical read-only checks and remaining owner visual acceptance. They are dated evidence; this governance cleanup runs no new app checks and grants no new application PASS. Reuse each result only under [V3](../VERIFICATION_POLICY.md#v3), with relevant input/environment comparison.

Older Graphite, Paper/Manrope and early logo variants remain historical/proposal material. `tokens.json`, `inventory.json` and browser-embedded source snapshots are dated exports, not the current native design system. Do not regenerate inventories, screenshots, fixtures, goldens, artwork or fonts merely to reconcile documentation. Keep scientific/data meaning and frozen acceptance separate from visual preference.
