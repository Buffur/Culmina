# F03 — Freeze the capture contract and persist it compatibly (evidence)

Run: full final-plan group, second cloud session, 2026-10-18. Environment: Linux container,
Flutter 3.47.4 / Dart 3.13.3 (the CI pin), system SQLite. No Android SDK.

## Changed files

- `lib/domain/models/capture_evidence.dart` (new): `WhiteBalance` (C1), `FocusMode` (C3),
  `FieldOrigin`/`FieldOrigins` (C4, C5), `FileEvidence` (C6, C12), `CaptureFormat` (C7). Every
  reader turns an absent, unknown or out-of-bounds value into *unrecorded*.
- `lib/domain/models/capture_block.dart`: `whiteBalance`, `focusMode`, `origins`, `fileEvidence`
  (copyWith clears a nullable value with a function).
- `lib/domain/models/equipment_profile.dart`: `captureFormat`, `captureFormatSource`,
  `rawFileSizeEvidence`, `withCaptureEvidence`; kept by `withEditProvenance`.
- `lib/presentation/shared/equipment_draft.dart`: a rig edit keeps the format, and keeps the
  measured file only while the raw size is unchanged (C7/C8).
- `lib/data/database/app_database.dart`, `tables/equipment_foundation_tables.dart`: schema
  **v26**, step `from25To26` (C19, additive nullable columns against the step's own shapes);
  `drift_schemas/drift_schema_v26.json`, `generated_migrations/schema_v26.dart`,
  `schema_versions.dart`, `app_database.g.dart` regenerated with the documented workflow.
- `lib/data/repositories/drift_session_repository.dart`, `drift_equipment_repository.dart`:
  write and read the new columns.
- `lib/domain/services/session_snapshot_builder.dart`, `saved_plan_reader.dart`: snapshot keys
  (C17, version 1 unchanged); `lib/data/export/session_manifest_codec.dart`: manifest keys (C18,
  version 2 unchanged; origins without evidence).
- Docs: `DECISIONS.md` (ADR-021/022 accepted; ADR-009/010/013 index notes), `DATA_MODEL.md`
  (v26 row, CaptureBlock), `EXPORT_MANIFEST.md` (block keys), `ENGINEERING_GUARDRAILS.md`
  (schema note).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F03.A1 | PASS (OWNER) | ADR-021 decision sheet C1–C21/V1–V15 accepted in full by the owner, 2026-10-18 (`DECISIONS.md` ADR-021); C20 lists each required rig field's calculations and supply; legacy origins stay unrecorded (`capture_evidence_test.dart`, migration test) |
| CHK-F03.A2 | PASS (TEST) | `schema_migration_test.dart` group "F03: v26": v8–v25 → v26 equal the v26 snapshot exactly (18 cases); a v25 file with a rig (device, camera, optics, provenance), a target and its alias, a site, a named partly-completed plan with plan and execution snapshots, a legacy log, light and dark blocks with counters and three events: every pre-v26 column kept value for value, the snapshot texts byte-equal, the new columns present and NULL, and the repositories read the same rig, plan, blocks, result, name and replayed counts, with every new value unrecorded. Restore of a real v24 database now migrates to v26 (`restore_activation_test.dart` CHK-F01.A2) |
| CHK-F03.A3 | PASS (TEST) | `test/data/capture_contract_round_trip_test.dart`: blocks with every new value (and one with none) through create, reopen, a new connection to the file and a plan update; a rig's format, source and measured file through insert, reopen, an unchanged editor save (kept) and a changed raw size (file dropped, format kept); the snapshot (version 1) records and `SavedPlanReader` reads them, an older snapshot without the keys reads unrecorded; the manifest (version 2) round trips them, origins without evidence values, an older manifest reads unrecorded; a backup restore (`FileBackupService` → `BackupStaging.apply`) keeps every block and rig value. Mutations: not writing `field_origins`, or not reading the snapshot's focus mode, fail it. `capture_evidence_test.dart`: 14 value-type cases (bounds, unknown names, basename-only labels, an unread file without dimensions) |
| CHK-F03.A4 | PASS (TEST) | `unsupported_database_test.dart` and `restore_activation_test.dart`/`backup_restore_test.dart` repinned: the current version is 26, v27 is refused as newer with the file and live data unchanged |
| CHK-F03.A5 | NEEDS ATTENTION (recorded at task start) | No owner FITS file or licensed fixture in the repository or this container (PROGRESS attention register). Blocks only F10 and FITS-specific rows, not F04–F09/F11/F12 |

## Commands (final working tree)

- `flutter test --no-pub -r failures-only test` → `+1968 ~2: All other tests passed!`
- `flutter test --no-pub integration_test/core_loop_test.dart -d flutter-tester` → `+2`
- `flutter analyze --no-pub` → `No issues found!`; `dart format --set-exit-if-changed lib test
  integration_test` → 0 changed; `dart run tool/check_encoding.dart` → passed.
