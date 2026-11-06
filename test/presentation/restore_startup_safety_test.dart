import 'dart:io';

import 'package:astroplan/data/backup/backup_staging.dart';
import 'package:astroplan/main.dart' as app;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'startup never opens writable storage when restore recovery fails',
    () async {
      final dir = await Directory.systemTemp.createTemp('restore_startup');
      final journal = File('${dir.path}/${BackupStaging.journal}');
      final database = File('${dir.path}/${BackupStaging.database}');
      await journal.writeAsString('{');
      await database.writeAsString('untouched');
      SharedPreferences.setMockInitialValues({});
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => dir.path,
      );
      addTearDown(() async {
        binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
        await dir.delete(recursive: true);
      });
      await expectLater(app.initializeApplication(), throwsFormatException);
      expect(await database.readAsString(), 'untouched');
      expect(await journal.readAsString(), '{');
    },
  );
}
