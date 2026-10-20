// Host collector for the native integration-test screenshots and report.
import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final output = Directory(
    Platform.environment['CULMINA_NATIVE_EVIDENCE'] ??
        'docs/design/migration/evidence/native',
  );
  await output.create(recursive: true);
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(name)) return false;
      await File('${output.path}/$name.png').writeAsBytes(bytes);
      return true; // Collected, not an automated visual-parity assertion.
    },
    responseDataCallback: (data) async {
      // Screenshot bytes are already saved as PNG files, not duplicated in JSON.
      final report = Map<String, dynamic>.from(data ?? {});
      report.remove('screenshots');
      await File('${output.path}/integration-report.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(report));
    },
    writeResponseOnFailure: true,
  );
}
