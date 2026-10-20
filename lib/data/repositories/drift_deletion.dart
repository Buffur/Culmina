import 'package:drift/drift.dart';

import '../../domain/repositories/undoable_deletion.dart';
import '../database/app_database.dart';

/// Transactional, lossless storage support for the short Undo affordance.
/// Raw storage values retain unknown/legacy JSON and every execution column.
/// Table/column identifiers below are fixed schema names, never user input.
class DriftDeletion {
  DriftDeletion(this.db);
  final AppDatabase db;

  Future<List<Map<String, dynamic>>> _rows(
    String table,
    String column,
    int id,
  ) async => [
    for (final row
        in await db
            .customSelect(
              'SELECT * FROM "$table" WHERE "$column" = ?',
              variables: [Variable.withInt(id)],
            )
            .get())
      Map.of(row.data),
  ];

  Future<DeletionReceipt> delete(
    DeletedResource resource,
    int id,
    Future<void> Function() remove,
  ) => db.transaction(() async {
    final table = switch (resource) {
      DeletedResource.session => 'session_logs',
      DeletedResource.rig => 'optical_rigs',
      DeletedResource.target => 'astro_targets',
      DeletedResource.site => 'location_profiles',
    };
    final root = await _rows(table, 'id', id);
    if (root.isEmpty) throw StateError('The record was already deleted.');
    final graph = <(String, List<Map<String, dynamic>>)>[];
    if (resource == DeletedResource.rig) {
      final cameras = await _rows(
        'camera_modules',
        'id',
        root.single['camera_module_id'] as int,
      );
      if (cameras.isNotEmpty) {
        graph.add((
          'devices',
          await _rows('devices', 'id', cameras.single['device_id'] as int),
        ));
        graph.add(('camera_modules', cameras));
      }
    }
    graph.add((table, root));
    if (resource == DeletedResource.session) {
      graph.add((
        'capture_blocks',
        await _rows('capture_blocks', 'session_log_id', id),
      ));
      graph.add((
        'session_events',
        await _rows('session_events', 'session_log_id', id),
      ));
    }
    // Aliases are keyed by catalog_id and are intentionally not deleted when
    // a target is removed. Re-inserting its row makes them visible again.
    final reference = switch (resource) {
      DeletedResource.session => null,
      DeletedResource.rig => 'rig_id',
      DeletedResource.target => 'target_id',
      DeletedResource.site => 'site_id',
    };
    final affected = reference == null
        ? <Map<String, dynamic>>[]
        : await _rows('session_logs', reference, id);
    await remove();
    // A camera or device may be shared. Keep only rows this deletion removed.
    final removed = <(String, List<Map<String, dynamic>>)>[];
    for (final (name, rows) in graph) {
      final missing = <Map<String, dynamic>>[];
      for (final row in rows) {
        if ((await _rows(name, 'id', row['id'] as int)).isEmpty) {
          missing.add(row);
        }
      }
      removed.add((name, missing));
    }
    return DeletionReceipt(
      resource: resource,
      id: id,
      restore: () => db.transaction(() async {
        for (final (name, rows) in removed) {
          for (final row in rows) {
            final columns = row.keys.map((name) => '"$name"').join(', ');
            final parameters = List.filled(row.length, '?').join(', ');
            // Plain INSERT: any identity collision fails the whole restore;
            // never REPLACE a row written since deletion.
            await db.customStatement(
              'INSERT INTO "$name" ($columns) VALUES ($parameters)',
              row.values.toList(),
            );
          }
        }
        if (reference != null) {
          for (final row in affected) {
            // A later plan edit or new selected reference wins over Undo.
            final unchanged = row.entries
                .where((entry) => entry.key != reference)
                .toList();
            await db.customStatement(
              'UPDATE session_logs SET "$reference" = ? '
              'WHERE id = ? AND "$reference" IS NULL '
              'AND ${unchanged.map((entry) => '"${entry.key}" IS ?').join(' AND ')}',
              [id, row['id'], ...unchanged.map((entry) => entry.value)],
            );
          }
        }
        db.notifyUpdates({
          for (final table in db.allTables) TableUpdate.onTable(table),
        });
      }),
    );
  });
}
