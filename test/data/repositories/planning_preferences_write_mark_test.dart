// F21 A5: the planning preferences are several SharedPreferences keys, so a
// save marks itself incomplete BEFORE it writes them and clears the mark
// only after the last one. The store is the plugin's method channel,
// answered here by a recording "disk" that can fail one write; a restart
// is a new SharedPreferences instance read from that disk. (This file never
// calls `setMockInitialValues`, which would replace the channel store.)

import 'package:astroplan/data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _mark = 'flutter.${SharedPrefsPlanningPreferencesRepository.writingKey}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');

  /// What the platform has stored, and every write in the order it came.
  late Map<String, Object> disk;
  late List<String> writes;

  /// The 1-based write that fails (a full disk, a killed process), or null.
  int? failAt;

  setUp(() {
    disk = {};
    writes = [];
    failAt = null;
    SharedPreferences.resetStatic();
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = (call.arguments as Map?)?.cast<String, Object?>();
      switch (call.method) {
        case 'getAll':
          return Map<String, Object>.of(disk);
        case 'remove':
          final key = args!['key']! as String;
          writes.add('remove $key');
          if (writes.length == failAt) throw PlatformException(code: 'io');
          disk.remove(key);
          return true;
        default:
          if (!call.method.startsWith('set')) {
            throw MissingPluginException(call.method);
          }
          final key = args!['key']! as String;
          writes.add('set $key');
          if (writes.length == failAt) throw PlatformException(code: 'io');
          disk[key] = args['value']!;
          return true;
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    SharedPreferences.resetStatic();
  });

  /// A new process: nothing cached, everything read from [disk].
  SharedPrefsPlanningPreferencesRepository restart() {
    SharedPreferences.resetStatic();
    return SharedPrefsPlanningPreferencesRepository();
  }

  test('A5: the mark is written before every preference key and removed '
      'after the last one', () async {
    final repo = SharedPrefsPlanningPreferencesRepository();
    await repo.save(PlanningPreferences(minAltitudeDeg: 25, setupMinutes: 10));

    expect(writes.first, 'set $_mark', reason: 'marked before any key');
    expect(writes.last, 'remove $_mark', reason: 'cleared after every key');
    expect(writes.where((w) => w.endsWith(_mark)), hasLength(2));
    // Every key the repository stores is written in between.
    final between = writes.sublist(1, writes.length - 1).toSet();
    for (final key in SharedPrefsPlanningPreferencesRepository.keys) {
      if (key == SharedPrefsPlanningPreferencesRepository.writingKey) continue;
      expect(
        between.any((w) => w.endsWith(' flutter.$key')),
        isTrue,
        reason: key,
      );
    }
    expect(disk.containsKey(_mark), isFalse);
    expect(await restart().lastSaveIncomplete(), isFalse);
    expect((await restart().load()).minAltitudeDeg, 25);
  });

  test('A5: a save interrupted after some keys leaves the mark on disk; '
      'the next start reports it', () async {
    final repo = SharedPrefsPlanningPreferencesRepository();
    failAt = 4; // the mark and two keys are written, the third fails
    await expectLater(
      repo.save(PlanningPreferences(minAltitudeDeg: 25)),
      throwsA(isA<StorageFailure>()),
    );
    expect(disk[_mark], isTrue);
    expect(disk['flutter.minAltitude'], 25.0, reason: 'partly written');
    expect(await restart().lastSaveIncomplete(), isTrue);

    // A later complete save clears it.
    failAt = null;
    await restart().save(PlanningPreferences(minAltitudeDeg: 30));
    expect(await restart().lastSaveIncomplete(), isFalse);
  });

  test('A5: a save that fails on its first key, before anything else is '
      'written, is still reported', () async {
    failAt = 2;
    await expectLater(
      SharedPrefsPlanningPreferencesRepository().save(PlanningPreferences()),
      throwsA(isA<StorageFailure>()),
    );
    expect(disk.keys, [_mark]);
    expect(await restart().lastSaveIncomplete(), isTrue);
  });
}
