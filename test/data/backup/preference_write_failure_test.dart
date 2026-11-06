import 'dart:io';
import 'dart:typed_data';

import 'package:astroplan/data/backup/backup_preferences.dart';
import 'package:astroplan/data/backup/backup_staging.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The plugin platform fake lets this test exercise a false disk commit.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FailedStore extends InMemorySharedPreferencesStore {
  _FailedStore() : super.empty();

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

class _FailOnceStore extends InMemorySharedPreferencesStore {
  _FailOnceStore() : super.withData({'flutter.activeLocationId': 7});
  bool failed = false;
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (!failed) {
      failed = true;
      return false;
    }
    return super.setValue(valueType, key, value);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'activeLocationId': 7});
    await SharedPreferences.getInstance();
    SharedPreferencesStorePlatform.instance = _FailedStore();
  });
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  test('restore refuses a false preference removal result', () async {
    await expectLater(
      BackupPreferences.restore(null),
      throwsA(isA<BackupException>()),
    );
  });

  test('rollback refuses a false preference write result', () async {
    final prefs = await SharedPreferences.getInstance();
    // Empty the local cache first so putBack reaches the setter.
    await prefs.remove('activeLocationId');
    await expectLater(
      BackupPreferences.putBack({'activeLocationId': 7}),
      throwsA(isA<BackupException>()),
    );
  });

  for (final rollbackFails in [false, true]) {
    test(
      'false native commit ${rollbackFails ? 'retains a failed rollback for retry' : 'rolls back the database and preferences'}',
      () async {
        final dir = await Directory.systemTemp.createTemp(
          'restore_false_commit',
        );
        addTearDown(() => dir.delete(recursive: true));
        final live = File('${dir.path}/${BackupStaging.database}');
        await live.writeAsString('old');
        await BackupStaging.stage(
          dir,
          Uint8List.fromList([1]),
          preferences: BackupPreferences.parse({
            'version': 1,
            'int': {'activeLocationId': 1},
          }),
        );
        SharedPreferencesStorePlatform.instance = rollbackFails
            ? _FailedStore()
            : _FailOnceStore();
        Future<RestoreOutcome?> apply() => BackupStaging.apply(
          dir,
          nowUtc: DateTime.utc(2026, 11, 6),
          check: (_) async {},
        );
        if (rollbackFails) {
          await expectLater(apply(), throwsA(isA<BackupException>()));
          expect(
            await File('${dir.path}/${BackupStaging.journal}').exists(),
            isTrue,
          );
          SharedPreferences.setMockInitialValues({});
        }
        final result = await apply();
        expect(result!.result, RestoreResult.refused);
        expect(await live.readAsString(), 'old');
        final p = await SharedPreferences.getInstance();
        await p.reload();
        expect(p.getInt('activeLocationId'), 7);
        expect(
          await File('${dir.path}/${BackupStaging.journal}').exists(),
          isFalse,
        );
      },
    );
  }
}
