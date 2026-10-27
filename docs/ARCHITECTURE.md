# Architecture and data

This describes the current `lib/` implementation and `pubspec.yaml`.

## Modules

- `lib/main.dart`: initializes licenses, staged restore, database and catalog
  seeding; constructs concrete repositories/services and the widget root.
- `lib/presentation/`: screens, shared UI, widgets, navigation and ViewModels.
- `lib/domain/models/`: targets, rigs, sites, nights, plans, weather and results.
- `lib/domain/repositories/`: storage and preferences interfaces.
- `lib/domain/services/`: astronomy, visibility, Moon, candidates, imaging
  opportunities, budgets, fit, calibration, storage and session logic.
- `lib/domain/metadata/`: bounded file readers and metadata result types.
- `lib/domain/equipment_import/`: equipment matching and specification estimates.
- `lib/data/`: Drift persistence, SharedPreferences repositories, network/device
  adapters, metadata file access, export and backup implementations.
- `lib/core/`: math, clock, units, configuration, diagnostics and theme tokens.

UI calls ViewModels; ViewModels use domain interfaces and services.
Data adapters implement those interfaces. Astronomy/math calculations are
separate from Flutter presentation.

## State and navigation

`AppViewModels` constructs dependencies in `presentation/app_view_models.dart`.
Provider exposes shared ViewModel instances, predominantly through
`ChangeNotifierProvider`; lifecycle and candidate coordinators use `Provider`.
Widgets consume state through Provider reads and watches.

- `SiteViewModel`: active site, position and local-time context.
- `SessionPlanViewModel`: editable target, rig, night and capture blocks.
- `PlanLifecycleViewModel` / `CurrentSession`: restore, open, new, copy,
  save and discard of the current plan.
- `NightConditionsViewModel`, `CandidatesViewModel`,
  `CaptureAnalysisViewModel`: forecast/astronomy, candidates and plan analysis.
- `StartupViewModel` / `TonightViewModel`: loading and first-run/home state.
- `GearViewModel`, `TargetsViewModel`, `SessionsViewModel`: library/logbook state.
- `ResultsViewModel`, `MetadataImportViewModel`, `BackupViewModel` and
  `AstroBinExportViewModel`: their respective workflows.
- Settings, display, theme and disclosure ViewModels persist user choices.

`go_router` defines a stateful indexed shell for Tonight, Logbook, Library
and Settings. Plan, results, choosers and Night/Moon/Weather open above the tabs.
Router restoration returns to the appropriate list when object arguments
cannot be restored. The plan flow prompts for unsaved changes.

## Domain data

| Model | Contents |
| --- | --- |
| `AstroTarget` / `TargetAlias` | Catalog/custom identity, J2000 RA/Dec in degrees, type, optional size/magnitude, source and searchable aliases. |
| `EquipmentProfile` | Flattened rig/camera view: sensor dimensions, resolution, pixel pitch, focal length/ratio, camera class, tracking, exposure limit and provenance. |
| `LocationProfile` | Coordinates, optional elevation, IANA zone, manual Bortle/SQM context, sources/dates and notes. |
| `CalendarDate` / `SessionNight` | Evening date and a half-open 24-hour UTC window beginning at site mean solar noon. |
| `CaptureBlock` | Frame type, exposure seconds, count, filter, binning, typed ISO/gain, calibration policy, white balance, AF/MF, origins and file evidence. |
| `SessionPlan` / `PlanOverrides` | Site/target/rig references, night, ordered blocks, labels, tracking override and optional per-plan budget/storage values. |
| `Session` / `SessionLog` | Lifecycle, references, timestamps, snapshots, blocks, counts, results and notes; legacy records remain readable. |
| `SessionSnapshot` | Versioned JSON of saved context, preferences, budget, opportunity and weather. |
| `ResultReport` | Completed as planned, partial per-block counts, or not done with optional reason and observed conditions. |
| `WeatherSnapshot` / `NightWeather` | Provider/model, fetch time, coordinates, hourly values, freshness, cache/failure/out-of-range state. |

`SessionStatus` includes `draft`, `planned`, `inProgress`, `completed` and
`abandoned`. Repository methods enforce lifecycle transitions. Execution
models, events and `ExecutionMachine` remain in the code; the router has no
dedicated live-tracker screen. Results are user reports of acquisition.

Night identity uses the site's evening date. Time contexts display an IANA
zone or mean solar time; DST changes local labels, not the UTC night window.
Unknown optional values are null. Units and provenance are explicit;
ISO/gain does not model photon collection.

## Persistence

`data/database/app_database.dart` defines Drift schema **27** in
`astroplan.sqlite` under the application documents directory.
The supported migration floor is version 8; unsupported older/newer databases
take the recovery path rather than being silently reinterpreted.

| Tables | Stored data |
| --- | --- |
| `Devices` → `CameraModules` → `OpticalRigs` | Device/camera/optics chain, specifications, provenance and capture-format evidence. |
| `LocationProfiles` | Saved sites and optional sky-quality context. |
| `AstroTargets`, `TargetAliases` | Targets and catalog-designation/name aliases. |
| `SessionLogs` | Session aggregate, status, references, timestamps, snapshots, overrides, result kind and notes. |
| `CaptureBlocks` | Ordered blocks, settings, calibration policy, evidence and completed/rejected counters. |
| `SessionEvents` | Ordered event history used to reconstruct execution state. |

SQLite foreign keys are enabled; blocks/events cascade with session deletion,
while camera/device references restrict deletion.
SharedPreferences stores planning/display/privacy/first-run preferences,
planner selection state and weather snapshots.
`FileBackupService` and `BackupStaging` validate and stage local restore;
startup applies it before opening the live database.

## External adapters and dependencies

- Open-Meteo weather through `http`, with cached snapshots.
- GPS through `geolocator`; device zone through `flutter_timezone`/`timezone`.
- OpenStreetMap tiles through `flutter_map`/`latlong2`; opt-in Nominatim lookup.
- Android file picker/range reads through a custom metadata platform channel.
- DNG, JPEG, HEIF still-image and FITS metadata readers in the domain.
- Backup uses `file_picker` and `archive`; export uses `share_plus`;
  external links use `url_launcher`.
- Drift code generation uses `drift_dev` and `build_runner`.

See [Product specification](PRODUCT_SPEC.md) and [Design system](DESIGN_SYSTEM.md).
