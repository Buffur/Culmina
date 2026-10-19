// F20 A1/A3: the AstroBin CSV is written to the temporary folder under its
// local-time name and handed to the share sheet as `text/csv`, with the
// row list as its text. HOST: the share sheet and path_provider are the
// plugins' method channels, answered here; nothing leaves the test.

import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/export/share_session_exporter.dart';
import 'package:astroplan/domain/services/astrobin_acquisitions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  const share = MethodChannel('dev.fluttercommunity.plus/share');
  late Directory temp;
  final shared = <MethodCall>[];

  setUp(() {
    temp = Directory.systemTemp.createTempSync('astrobin_share');
    shared.clear();
    messenger.setMockMethodCallHandler(pathProvider, (call) async {
      expect(call.method, 'getTemporaryDirectory');
      return temp.path;
    });
    messenger.setMockMethodCallHandler(share, (call) async {
      shared.add(call);
      return 'dev.fluttercommunity.plus/share/success';
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(pathProvider, null);
    messenger.setMockMethodCallHandler(share, null);
    temp.deleteSync(recursive: true);
  });

  test('A1/A3: share writes the CSV to the temporary folder as '
      'astroplan-astrobin-<local stamp>.csv and shares it as text/csv with '
      'the rows listed', () async {
    final now = DateTime.utc(2026, 12, 16, 7, 5);
    const export = AstroBinExport([
      AstroBinRow(
        date: '2026-12-15',
        filterName: 'Ha',
        number: 24,
        durationS: 300,
      ),
      AstroBinRow(
        date: '2026-12-17',
        filterName: null,
        number: 7,
        durationS: 2,
      ),
    ], []);

    await ShareAstroBinCsvExporter(clock: FixedClock(now)).share(export);

    final name =
        'astroplan-astrobin-${ShareSessionExporter.localFileStamp(now)}.csv';
    expect(ShareAstroBinCsvExporter.fileName(now), name);
    final file = File(p.join(temp.path, name));
    expect(file.existsSync(), isTrue, reason: 'written before sharing');
    expect(file.readAsStringSync(), export.csv);

    expect(shared, hasLength(1));
    final args = (shared.single.arguments as Map).cast<String, Object?>();
    expect(shared.single.method, 'share');
    expect(args['paths'], [file.path]);
    expect(args['mimeTypes'], ['text/csv']);
    expect(args['text'], ShareAstroBinCsvExporter.shareText(export));
    expect((args['text'] as String).split('\n').sublist(1), [
      '1. Ha · 2026-12-15 · 24 × 300 s',
      '2. No filter · 2026-12-17 · 7 × 2 s',
    ]);
  });
}
