# Dependency audit — 2026-11-06

Scope: current checkout including uncommitted and untracked source, tests, integration hosts, tools, native files, CI and project configuration. Search records literal package-name occurrences in text files; generated/build caches, _archive, historical docs/design, and pubspec declaration/lock are excluded. JSON contains all matched lines and distinguishes package URIs from other literals. Literal matches may include comments, unrelated common words, or test assertions and are not by themselves proof of executable use.

Result: 22 declared packages (17 main, 5 development); none proved unused. No pubspec or lockfile change proposed. Resolved SDK package version 0.0.0 is the lockfile marker, not an installed Flutter SDK version.

| Package | Section | Constraint | Resolved | Package URI occurrences | Representative evidence / decision |
| --- | --- | --- | --- | ---: | --- |
| flutter | dependencies | `SDK flutter` | `0.0.0` | 384 | integration_test/core_loop_test.dart:36; integration_test/hybrid_migration_smoke_test.dart:39 |
| provider | dependencies | `^6.1.5+1` | `6.1.5+1` | 172 | integration_test/core_loop_test.dart:39; integration_test/hybrid_migration_smoke_test.dart:44 |
| go_router | dependencies | `^18.0.1` | `18.0.1` | 37 | lib/presentation/navigation/app_router.dart:4; lib/presentation/navigation/app_shell.dart:2 |
| drift | dependencies | `^2.35.3` | `2.35.3` | 191 | integration_test/core_loop_test.dart:35; integration_test/hybrid_migration_smoke_test.dart:38 |
| path_provider | dependencies | `^2.1.6` | `2.1.6` | 6 | integration_test/hybrid_migration_smoke_test.dart:43; integration_test/native_restore_safety_test.dart:13 |
| path | dependencies | `^1.9.1` | `1.9.1` | 15 | integration_test/hybrid_migration_smoke_test.dart:42; lib/data/backup/backup_staging.dart:5 |
| http | dependencies | `^1.6.0` | `1.6.0` | 8 | lib/data/repositories/open_meteo_weather_repository.dart:3; lib/data/services/nominatim_reverse_geocoder.dart:5 |
| share_plus | dependencies | `^13.3.1` | `13.3.1` | 3 | lib/data/backup/file_backup_service.dart:8; lib/data/export/share_session_exporter.dart:6 |
| url_launcher | dependencies | `^6.3.3` | `6.3.3` | 5 | lib/presentation/screens/location/location_picker_screen.dart:7; lib/presentation/screens/settings/settings_parts.dart:2 |
| shared_preferences | dependencies | `^2.5.6` | `2.5.6` | 118 | integration_test/core_loop_test.dart:40; integration_test/hybrid_migration_smoke_test.dart:45 |
| geolocator | dependencies | `^14.1.2` | `14.1.2` | 3 | lib/data/services/geolocator_location_service.dart:1; test/presentation/viewmodels/planner_location_test.dart:271 |
| flutter_map | dependencies | `^8.3.2` | `8.3.2` | 6 | lib/presentation/screens/location/location_picker_screen.dart:3; test/presentation/screens/wave3_local_layout_test.dart:6 |
| latlong2 | dependencies | `^0.10.1` | `0.10.1` | 8 | lib/presentation/navigation/app_router.dart:5; lib/presentation/screens/location/location_picker_screen.dart:4 |
| timezone | dependencies | `^0.11.2` | `0.11.2` | 2 | lib/domain/models/iana_time_context.dart:1; lib/domain/models/iana_time_context.dart:2 |
| flutter_timezone | dependencies | `5.1.1` | `5.1.1` | 1 | lib/data/services/flutter_timezone_device_time_zone.dart:1 |
| file_picker | dependencies | `13.2.0` | `13.2.0` | 2 | lib/data/backup/file_backup_service.dart:5; test/domain/metadata/metadata_domain_purity_test.dart:14 |
| archive | dependencies | `4.5.2` | `4.5.2` | 3 | lib/data/backup/backup_archive.dart:4; test/data/backup/backup_restore_test.dart:13 |
| flutter_test | dev_dependencies | `SDK flutter` | `0.0.0` | 339 | integration_test/core_loop_test.dart:37; integration_test/hybrid_migration_smoke_test.dart:40 |
| integration_test | dev_dependencies | `SDK flutter` | `0.0.0` | 7 | integration_test/core_loop_test.dart:38 imports SDK test host; CI invokes integration suites |
| flutter_lints | dev_dependencies | `^6.0.0` | `6.0.0` | 2 | analysis_options.yaml:10 activates lint set |
| drift_dev | dev_dependencies | `^2.35.2` | `2.35.2` | 3 | build.yaml:4 configures builder; test/data/database/schema_migration_test.dart:34 imports migrations API |
| build_runner | dev_dependencies | `^2.17.1` | `2.17.1` | 0 | AGENTS.md:95 documents generator command; build.yaml:4 configures drift_dev; retained as generation tool |

Package URI counts are literal occurrences, including comments or string assertions; consult JSON and source before treating an occurrence as a live import. All packages other than build_runner have package URI occurrences; build_runner remains justified by the documented generation workflow. Existing exact pins for flutter_timezone, file_picker and archive remain unchanged.

Configuration review: `.codex/config.toml` contains disabled, host-specific design skill overrides; it does not declare Dart dependencies or dependency commands. This audit does not establish whether those skill exclusions are obsolete, and does not remove them. `analysis_options.yaml` activates flutter_lints; `build.yaml` configures drift_dev.

No package resolution, upgrade, test, or generation command was run for this inventory; the resolved versions are read from the existing lockfile. The audit does not prove runtime execution of every dependency or assess transitive packages for removability.
