import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps Android fixture runners out of the owner's production data sandbox.
Future<void> requireIsolatedAndroidVerification() async {
  if (!Platform.isAndroid) return;
  expect(
    const bool.fromEnvironment('CULMINA_ISOLATED_VERIFY'),
    isTrue,
    reason: 'Build with CULMINA_VERIFICATION=true and CULMINA_ISOLATED_VERIFY=true.',
  );
  final documents = await getApplicationDocumentsDirectory();
  expect(
    documents.path,
    contains('/io.github.buffur.culmina.verification/'),
    reason: 'Fixture runners must use the separate .verification install.',
  );
}
