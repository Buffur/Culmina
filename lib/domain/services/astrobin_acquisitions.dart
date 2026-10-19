import '../models/calendar_date.dart';
import '../models/camera_class.dart';
import '../models/capture_block.dart';
import '../models/execution.dart';
import '../models/session.dart';
import 'calibration_match.dart';
import 'execution_machine.dart';
import 'session_exporter.dart';

/// One acquisition row (F20; AstroBin "Importing acquisitions from CSV").
/// Every value is recorded data or null (blank), never a guess or a zero.
class AstroBinRow {
  const AstroBinRow({
    required this.date,
    required this.filterName,
    required this.number,
    required this.durationS,
    this.iso,
    this.gain,
    this.binning,
    this.fNumber,
    this.darks,
    this.flats,
    this.flatDarks,
    this.bias,
    this.temperatureC,
  });

  /// The saved night's evening date, `YYYY-MM-DD`; null when unknown.
  final String? date;

  /// The light block's filter as the user wrote it, for the share text
  /// only: AstroBin's `filter` column takes its equipment-database ID, so it
  /// stays empty (CA-08, M7). Null = no filter recorded.
  final String? filterName;
  final int number;
  final double durationS;
  final int? iso;
  final double? gain;
  final int? binning;
  final double? fNumber;
  final int? darks, flats, flatDarks, bias;
  final double? temperatureC;
}

/// Why an entry gives no rows. Nothing is made up from a plan (A1).
enum AstroBinSkip {
  /// A saved plan or a draft: no result recorded.
  noResult,

  /// A run left in progress: its result is not recorded yet.
  notRecorded,

  /// Not done: nothing reported as acquired.
  notDone,

  /// An old log: no per-block record of exposures.
  oldLog,

  /// A result with no light frame recorded.
  noLightFrames,
}

/// AstroBin's acquisition CSV (F20, S16.5, Q4; mapping v1 in
/// `docs/EXPORT_MANIFEST.md`): the rows of an export, in order, and the
/// entries that give none. Pure.
///
/// - **Only recorded acquisitions:** a completed, non-legacy entry; its
///   light frames are the confirmed counts its events replay to (a
///   reported result, a Partly count or a tracked run). Saved plans, runs
///   in progress, Not done and old logs give no rows ([AstroBinSkip]).
/// - **One row per night and light setting:** light blocks with the same
///   normalized filter (C15), exposure (integer ms), recorded ISO or gain
///   and, where the camera class offers it, binning are one row (counts
///   summed); others are separate rows, in plan order; nights in date
///   order (an unknown date last), then by entry.
/// - **Calibration counts** (`darks`, `flats`, `flatDarks`, `bias`) only
///   from confirmed calibration frames (a tracked run; a manual result
///   records lights only) whose block covers exactly one row by the whole
///   C15 tuple (`CalibrationMatch.covers`, with the saved rig's camera
///   class); otherwise blank (A4).
/// - **Blank, never zero:** `filter` (a numeric equipment ID Culmina does
///   not have), `sensorCooling`, `bortle`, `meanSqm`, `meanFwhm`, an
///   unrecorded ISO or gain, binning outside astro classes, an unknown date
///   or focal ratio. `temperature` is the result's recorded temperature.
class AstroBinExport {
  const AstroBinExport(this.rows, this.skipped);

  factory AstroBinExport.of(List<ExportedSession> sessions) {
    final rows = <AstroBinRow>[];
    final skipped = <(Session, AstroBinSkip)>[];
    // Nights in date order (an unknown night last), then by entry.
    final ordered = [...sessions]
      ..sort((a, b) {
        final x = _date(a.session), y = _date(b.session);
        if (x != y) {
          if (x == null || y == null) return x == null ? 1 : -1;
          return x.compareTo(y);
        }
        return a.session.id.compareTo(b.session.id);
      });
    for (final e in ordered) {
      final s = e.session;
      final skip = s.legacy
          ? AstroBinSkip.oldLog
          : switch (s.status) {
              SessionStatus.completed => null,
              SessionStatus.abandoned => AstroBinSkip.notDone,
              SessionStatus.inProgress => AstroBinSkip.notRecorded,
              SessionStatus.planned ||
              SessionStatus.draft => AstroBinSkip.noResult,
            };
      final night = skip == null ? _night(s, e.events) : const <AstroBinRow>[];
      if (skip != null || night.isEmpty) {
        skipped.add((s, skip ?? AstroBinSkip.noLightFrames));
      }
      rows.addAll(night);
    }
    return AstroBinExport(rows, skipped);
  }

  final List<AstroBinRow> rows;
  final List<(Session, AstroBinSkip)> skipped;

  /// The filter names in row order ("No filter" when none was recorded):
  /// the share text and the preview list them, so each row's filter can be
  /// chosen on AstroBin (A3).
  List<String> get filterNames => [
    for (final r in rows) r.filterName ?? 'No filter',
  ];

  String get csv => AstroBinCsv.encode(rows);

  /// One line per row, in the CSV's order (A3): the preview and the share
  /// text both list these. "1. Ha · 2026-12-15 · 24 × 300 s".
  List<String> get rowLines => [
    for (final (i, r) in rows.indexed)
      '${i + 1}. ${filterNames[i]} · ${r.date ?? 'date unknown'} · '
          '${r.number} × ${AstroBinCsv.number(r.durationS, 4)} s',
  ];

  static CalendarDate? _date(Session s) =>
      (s.executionStartSnapshot ?? s.planSnapshot)?.eveningDate ??
      s.eveningDate;

  static int _ms(double seconds) => (seconds * 1000).round();

  /// One night's rows: its confirmed light frames grouped by setting, with
  /// the calibration counts that can be attributed.
  static List<AstroBinRow> _night(Session s, List<ExecutionEvent> events) {
    final state = ExecutionMachine.fold({
      for (final b in s.blocks) b.id,
    }, events);
    final snap = s.executionStartSnapshot ?? s.planSnapshot;
    final cameraClass = snap?.cameraClass;
    // Binning is the user's per-exposure choice only on astro cameras; an
    // unknown class's default 1 is not a record of it.
    final binned =
        cameraClass == CameraClass.astroColour ||
        cameraClass == CameraClass.astroMono;
    Object key(CaptureBlock b) => (
      CalibrationMatch.normalizedFilter(b.filterName),
      _ms(b.exposureTimeSeconds),
      b.gain,
      binned ? b.binning : null,
    );
    // Light rows in plan order: their blocks and summed counts.
    final groups = <Object, List<CaptureBlock>>{};
    final counts = <Object, int>{};
    for (final b in s.blocks) {
      final n = state.completedFor(b.id);
      if (!b.isLight || n <= 0) continue;
      (groups[key(b)] ??= []).add(b);
      counts[key(b)] = (counts[key(b)] ?? 0) + n;
    }
    final keys = groups.keys.toList();
    final calibration = <Object, Map<FrameType, int>>{};
    if (cameraClass != null) {
      // Dark flats calibrate the flats actually recorded that night.
      final flats = [
        for (final b in s.blocks)
          if (b.frameType == FrameType.flat && state.completedFor(b.id) > 0) b,
      ];
      for (final c in s.blocks) {
        final n = state.completedFor(c.id);
        if (c.isLight || n <= 0) continue;
        // A dark flat covers a flat; it belongs to that flat's light row.
        bool coversRow(Object k) => groups[k]!.any(
          (light) => c.frameType == FrameType.darkFlat
              ? flats.any(
                  (f) =>
                      CalibrationMatch.covers(c, f, cameraClass) &&
                      CalibrationMatch.covers(f, light, cameraClass),
                )
              : CalibrationMatch.covers(c, light, cameraClass),
        );
        final covered = keys.where(coversRow).toList();
        if (covered.length != 1) continue; // unproven or ambiguous: blank
        final row = calibration[covered.single] ??= {};
        row[c.frameType] = (row[c.frameType] ?? 0) + n;
      }
    }
    final date = _date(s)?.toIso8601String();
    return [
      for (final k in keys)
        () {
          final first = groups[k]!.first;
          final cal = calibration[k] ?? const <FrameType, int>{};
          return AstroBinRow(
            date: date,
            filterName: first.filterName,
            number: counts[k]!,
            durationS: first.exposureTimeSeconds,
            iso: first.gain.kind == GainKind.iso
                ? first.gain.value?.round()
                : null,
            gain: first.gain.kind == GainKind.gain ? first.gain.value : null,
            binning: binned ? first.binning : null,
            fNumber: snap?.rigFocalRatio,
            darks: cal[FrameType.dark],
            flats: cal[FrameType.flat],
            flatDarks: cal[FrameType.darkFlat],
            bias: cal[FrameType.bias],
            temperatureC: s.record.temperature,
          );
        }(),
    ];
  }
}

/// The CSV text (AstroBin, "Importing acquisitions from CSV"): a header
/// line, comma-separated with no spaces, one line per row; a blank cell
/// for every unknown. Every value is a date or a number, so no cell needs
/// quoting; numbers use a dot and no grouping.
abstract final class AstroBinCsv {
  static const columns = [
    'date',
    'filter',
    'number',
    'duration',
    'iso',
    'binning',
    'gain',
    'sensorCooling',
    'fNumber',
    'darks',
    'flats',
    'flatDarks',
    'bias',
    'bortle',
    'meanSqm',
    'meanFwhm',
    'temperature',
  ];

  static String encode(List<AstroBinRow> rows) => [
    columns.join(','),
    for (final r in rows)
      [
        r.date ?? '',
        '', // filter: AstroBin's numeric equipment ID, not a name (CA-08)
        '${r.number}',
        number(r.durationS, 4),
        r.iso?.toString() ?? '',
        r.binning?.toString() ?? '',
        r.gain == null ? '' : number(r.gain!, 2),
        '', // sensorCooling: not recorded
        r.fNumber == null ? '' : number(r.fNumber!, 2),
        r.darks?.toString() ?? '',
        r.flats?.toString() ?? '',
        r.flatDarks?.toString() ?? '',
        r.bias?.toString() ?? '',
        '', // bortle: a planning input, not a measurement of the night
        '', // meanSqm: likewise
        '', // meanFwhm: not recorded
        r.temperatureC == null ? '' : number(r.temperatureC!, 2),
      ].join(','),
  ].join('\n');

  /// [v] with at most [decimals] decimals, trailing zeros dropped: 300,
  /// 0.5, 1.25.
  static String number(double v, int decimals) {
    var t = v.toStringAsFixed(decimals);
    if (t.contains('.')) t = t.replaceFirst(RegExp(r'\.?0+$'), '');
    return t == '-0' ? '0' : t;
  }
}
