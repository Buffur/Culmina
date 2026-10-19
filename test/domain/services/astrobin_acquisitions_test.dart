// F20 (S16.5, Q4; AstroBin "Importing acquisitions from CSV", read
// 2026-10-17, its rules re-confirmed by search 2026-10-19): only recorded
// acquisitions become rows; unknown stays blank, never 0; the `filter`
// column (a numeric equipment ID) stays empty and the filter names are
// listed in row order; calibration counts only from confirmed frames whose
// block proves the whole C15 tuple of exactly one row. The expected CSV
// lines are written out by hand from the contract, not from the encoder.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_log.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/services/astrobin_acquisitions.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 12, 15, 19);
const _header =
    'date,filter,number,duration,iso,binning,gain,sensorCooling,fNumber,'
    'darks,flats,flatDarks,bias,bortle,meanSqm,meanFwhm,temperature';

CaptureBlock _b(
  int id,
  FrameType type, {
  String? filter,
  double exp = 300,
  CaptureGain gain = CaptureGain.none,
  int binning = 1,
}) => CaptureBlock(
  id: id,
  frameType: type,
  filterName: filter,
  exposureTimeSeconds: exp,
  frameCount: 50,
  gain: gain,
  binning: binning,
);

SessionSnapshot _snap(String night, {String? cameraClass, double? f}) =>
    SessionSnapshot.tryRead({
      'v': SessionSnapshot.currentVersion,
      'takenAtUtcMs': _t.millisecondsSinceEpoch,
      'night': {'eveningDate': night},
      'rig': {'cameraClass': cameraClass, 'focalRatio': f},
    })!;

/// A session whose events confirm [confirmed] frames per block id.
ExportedSession _entry({
  required int id,
  required List<CaptureBlock> blocks,
  Map<int, int> confirmed = const {},
  SessionStatus status = SessionStatus.completed,
  bool legacy = false,
  SessionSnapshot? snapshot,
  CalendarDate? night,
  double? temperature,
}) {
  final events = <ExecutionEvent>[];
  var s = ExecutionMachine.fold({for (final b in blocks) b.id}, const []);
  void add(ExecutionEventKind kind, {int? blockId, int? delta}) {
    final e = ExecutionMachine.next(
      s,
      kind,
      _t,
      blockId: blockId,
      delta: delta,
    );
    events.add(e);
    s = ExecutionMachine.apply(s, e);
  }

  if (confirmed.isNotEmpty) {
    add(ExecutionEventKind.reported, blockId: blocks.first.id);
    // As the repository does, a Partly 0 writes no confirmation.
    for (final MapEntry(:key, :value) in confirmed.entries) {
      if (value != 0) {
        add(ExecutionEventKind.framesConfirmed, blockId: key, delta: value);
      }
    }
  }
  return ExportedSession(
    Session(
      record: SessionLog(
        id: id,
        targetName: 'M42',
        equipmentName: 'Rig',
        sessionDate: _t,
        captureBlocks: blocks,
        temperature: temperature,
      ),
      status: status,
      legacy: legacy,
      eveningDate: night,
      planSnapshot: snapshot,
      resultKind: status == SessionStatus.completed ? ResultKind.partly : null,
    ),
    events,
  );
}

void main() {
  test('A1/A3: a partial result: one row per filter in plan order, the '
      "filter column empty, its names listed in that order; a DSLR's ISO, "
      'no binning, its recorded temperature', () {
    final out = AstroBinExport.of([
      _entry(
        id: 1,
        blocks: [
          _b(1, FrameType.light, filter: 'Ha', gain: CaptureGain.iso(800)),
          _b(2, FrameType.light, filter: 'OIII', gain: CaptureGain.iso(800)),
          _b(3, FrameType.light, filter: ' ha ', gain: CaptureGain.iso(800)),
        ],
        confirmed: {1: 20, 2: 7, 3: 4},
        snapshot: _snap('2026-12-15', cameraClass: 'dslrMirrorless', f: 5),
        temperature: -3.5,
      ),
    ]);
    expect(out.filterNames, ['Ha', 'OIII']);
    expect(out.csv.split('\n'), [
      _header,
      '2026-12-15,,24,300,800,,,,5,,,,,,,,-3.5',
      '2026-12-15,,7,300,800,,,,5,,,,,,,,-3.5',
    ]);
    expect(out.skipped, isEmpty);
  });

  test('A1: no result, in progress, not done, an old log and a result '
      'without light frames give no rows, each with its reason', () {
    final blocks = [_b(1, FrameType.light, filter: 'L')];
    final out = AstroBinExport.of([
      _entry(id: 1, blocks: blocks, status: SessionStatus.planned),
      _entry(id: 2, blocks: blocks, status: SessionStatus.draft),
      _entry(id: 3, blocks: blocks, status: SessionStatus.inProgress),
      _entry(id: 4, blocks: blocks, status: SessionStatus.abandoned),
      _entry(id: 5, blocks: blocks, legacy: true),
      _entry(id: 6, blocks: blocks, confirmed: {1: 0}),
    ]);
    expect(out.rows, isEmpty, reason: 'nothing made up from a plan');
    expect(out.csv, _header);
    expect(
      [for (final (s, why) in out.skipped) (s.id, why)],
      [
        (1, AstroBinSkip.noResult),
        (2, AstroBinSkip.noResult),
        (3, AstroBinSkip.notRecorded),
        (4, AstroBinSkip.notDone),
        (5, AstroBinSkip.oldLog),
        (6, AstroBinSkip.noLightFrames),
      ],
    );
  });

  test('A1/A2: a mixed group over two nights: different exposure, gain or '
      'binning are separate rows; unknown gain, date and focal ratio blank; '
      'fractional values with a dot', () {
    final out = AstroBinExport.of([
      // Given out of order: rows follow the nights' dates, unknown last.
      _entry(id: 2, blocks: [_b(5, FrameType.light)], confirmed: {5: 30}),
      _entry(
        id: 1,
        blocks: [
          _b(
            1,
            FrameType.light,
            filter: 'L',
            exp: 120,
            gain: CaptureGain.gain(100),
          ),
          _b(
            2,
            FrameType.light,
            filter: 'L',
            exp: 120,
            gain: CaptureGain.gain(139.5),
          ),
          _b(
            3,
            FrameType.light,
            filter: 'L',
            exp: 120,
            gain: CaptureGain.gain(100),
            binning: 2,
          ),
          _b(4, FrameType.light, filter: 'L', exp: 0.25),
        ],
        confirmed: {1: 10, 2: 11, 3: 12, 4: 13},
        snapshot: _snap('2026-12-15', cameraClass: 'astroMono', f: 4.8),
      ),
    ]);
    expect(out.filterNames, ['L', 'L', 'L', 'L', 'No filter']);
    expect(out.csv.split('\n'), [
      _header,
      '2026-12-15,,10,120,,1,100,,4.8,,,,,,,,',
      '2026-12-15,,11,120,,1,139.5,,4.8,,,,,,,,',
      '2026-12-15,,12,120,,2,100,,4.8,,,,,,,,',
      '2026-12-15,,13,0.25,,1,,,4.8,,,,,,,,',
      ',,30,300,,,,,,,,,,,,,',
    ]);
    expect(out.csv, isNot(contains(',0,')), reason: 'never a 0 for unknown');
  });

  test('A4: calibration counts attach only from confirmed frames proving '
      'the whole tuple of exactly one row; planned-only, mismatched and '
      'ambiguous counts stay blank', () {
    final gain = CaptureGain.gain(100);
    final out = AstroBinExport.of([
      _entry(
        id: 1,
        blocks: [
          _b(1, FrameType.light, filter: 'Ha', gain: gain),
          _b(2, FrameType.light, filter: 'OIII', exp: 180, gain: gain),
          _b(3, FrameType.dark, gain: gain), // 300 s: Ha only
          _b(4, FrameType.flat, filter: 'Ha', exp: 2, gain: gain),
          _b(5, FrameType.darkFlat, exp: 2, gain: gain), // via the Ha flat
          _b(6, FrameType.bias, gain: gain), // both rows: ambiguous
          _b(7, FrameType.dark, exp: 600, gain: gain), // matches no row
          _b(8, FrameType.flat, filter: 'OIII', exp: 2, gain: gain),
        ],
        // The OIII flat (8) is planned but has no confirmed frames.
        confirmed: {1: 20, 2: 15, 3: 30, 4: 25, 5: 25, 6: 50, 7: 10},
        snapshot: _snap('2026-12-15', cameraClass: 'astroMono'),
      ),
    ]);
    expect(out.csv.split('\n'), [
      _header,
      '2026-12-15,,20,300,,1,100,,,30,25,25,,,,,',
      '2026-12-15,,15,180,,1,100,,,,,,,,,,',
    ]);
  });

  test('A4: without a readable snapshot no tuple can be proved: no '
      'calibration counts and no binning', () {
    final out = AstroBinExport.of([
      _entry(
        id: 1,
        night: CalendarDate(2026, 12, 16),
        blocks: [_b(1, FrameType.light), _b(2, FrameType.dark)],
        confirmed: {1: 20, 2: 30},
      ),
    ]);
    expect(out.csv.split('\n'), [_header, '2026-12-16,,20,300,,,,,,,,,,,,,']);
  });

  test('A1: two known nights give their rows in date order, whatever order '
      'the entries come in or their ids say; an unknown night is last', () {
    ExportedSession night(int id, String date, int frames) => _entry(
      id: id,
      blocks: [_b(id, FrameType.light, filter: 'L')],
      confirmed: {id: frames},
      snapshot: _snap(date),
    );
    final out = AstroBinExport.of([
      _entry(id: 1, blocks: [_b(9, FrameType.light)], confirmed: {9: 5}),
      // The later night has the lower id: neither the input order nor the
      // ids give the date order.
      night(2, '2026-12-17', 7),
      night(3, '2026-12-15', 3),
    ]);
    expect(out.csv.split('\n'), [
      _header,
      '2026-12-15,,3,300,,,,,,,,,,,,,',
      '2026-12-17,,7,300,,,,,,,,,,,,,',
      ',,5,300,,,,,,,,,,,,,',
    ]);
    expect(out.rowLines, [
      '1. L · 2026-12-15 · 3 × 300 s',
      '2. L · 2026-12-17 · 7 × 300 s',
      '3. No filter · date unknown · 5 × 300 s',
    ]);
  });

  test('rows of the same night follow the entries\' order by id, whatever '
      'order they are given in', () {
    ExportedSession night(int id, String filter) => _entry(
      id: id,
      blocks: [_b(id, FrameType.light, filter: filter)],
      confirmed: {id: id},
      snapshot: _snap('2026-12-15'),
    );
    final out = AstroBinExport.of([
      night(3, 'C'),
      night(1, 'A'),
      night(2, 'B'),
    ]);
    expect(out.filterNames, ['A', 'B', 'C']);
  });

  test('numbers: at most the contract\'s decimals, trailing zeros dropped', () {
    expect(AstroBinCsv.number(300, 4), '300');
    expect(AstroBinCsv.number(0.00012, 4), '0.0001');
    expect(AstroBinCsv.number(1.5, 2), '1.5');
    expect(AstroBinCsv.number(-0.001, 2), '0');
  });
}
