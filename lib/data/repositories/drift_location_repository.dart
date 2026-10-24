import 'package:drift/drift.dart';

import '../../domain/models/calendar_date.dart';
import '../../domain/models/location_profile.dart' as domain;
import '../../domain/repositories/location_repository.dart';
import '../database/app_database.dart';
import '../../domain/repositories/undoable_deletion.dart';
import 'drift_deletion.dart';

class DriftLocationRepository
    implements LocationRepository, UndoableDeletionRepository {
  final AppDatabase _db;

  DriftLocationRepository(this._db);

  @override
  Future<DeletionReceipt> deleteWithUndo(int id) =>
      DriftDeletion(_db)
          .delete(DeletedResource.site, id, () => deleteLocation(id));

  domain.LocationProfile _mapToDomain(LocationProfile row) {
    return domain.LocationProfile(
      id: row.id,
      name: row.name,
      latitude: row.latitude,
      longitude: row.longitude,
      elevation: row.elevation,
      bortleClass: row.bortleClass,
      bortleSource: row.bortleSource,
      bortleDate: _date(row.bortleDate),
      sqm: row.sqm,
      sqmSource: row.sqmSource,
      sqmDate: _date(row.sqmDate),
      timeZoneId: row.timeZone,
      notes: row.notes,
    );
  }

  static CalendarDate? _date(String? iso) =>
      iso == null ? null : CalendarDate.parse(iso);

  static LocationProfilesCompanion _companion(domain.LocationProfile l) =>
      LocationProfilesCompanion(
        name: Value(l.name),
        latitude: Value(l.latitude),
        longitude: Value(l.longitude),
        elevation: Value(l.elevation),
        bortleClass: Value(l.bortleClass),
        bortleSource: Value(l.bortleSource),
        bortleDate: Value(l.bortleDate?.toIso8601String()),
        sqm: Value(l.sqm),
        sqmSource: Value(l.sqmSource),
        sqmDate: Value(l.sqmDate?.toIso8601String()),
        timeZone: Value(l.timeZoneId),
        notes: Value(l.notes),
      );

  @override
  Future<int> insertLocation(domain.LocationProfile location) =>
      _db.transaction(() async {
        await _refuseDuplicate(location);
        return _db.into(_db.locationProfiles).insert(_companion(location));
      });

  Future<void> _refuseDuplicate(domain.LocationProfile location) async {
    final matches =
        await (_db.select(_db.locationProfiles)..where(
              (t) =>
                  t.latitude.equals(location.latitude) &
                  t.longitude.equals(location.longitude) &
                  t.id.equals(location.id).not(),
            ))
            .get();
    if (matches.isNotEmpty) throw DuplicateSite(matches.first.name);
  }

  @override
  Future<List<domain.LocationProfile>> getLocations() async {
    final rows = await _db.select(_db.locationProfiles).get();
    return rows.map(_mapToDomain).toList();
  }

  @override
  Future<domain.LocationProfile?> getLocationById(int id) async {
    final row = await (_db.select(
      _db.locationProfiles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapToDomain(row);
  }

  @override
  Future<void> updateLocation(domain.LocationProfile location) =>
      _db.transaction(() async {
        // Keep legacy duplicate records editable without merging owner data.
        final original = await getLocationById(location.id);
        if (original?.latitude != location.latitude ||
            original?.longitude != location.longitude) {
          await _refuseDuplicate(location);
        }
        await (_db.update(
          _db.locationProfiles,
        )..where((t) => t.id.equals(location.id))).write(_companion(location));
      });

  @override
  Future<void> deleteLocation(int id) {
    return (_db.delete(
      _db.locationProfiles,
    )..where((t) => t.id.equals(id))).go();
  }
}
