import '../models/capture_block.dart';
import '../models/execution.dart';
import 'calibration_match.dart';

/// One block, planned against what was confirmed (TASK 13.4).
class BlockReconciliation {
  const BlockReconciliation({
    required this.block,
    required this.confirmed,
    required this.rejected,
  });

  final CaptureBlock block;
  final int confirmed;
  final int rejected;

  int get planned => block.frameCount;
  bool get isLight => block.frameType == FrameType.light;

  /// planned × exposure (lights only; zero for calibration blocks).
  Duration get plannedIntegration => _integration(planned);

  /// confirmed × exposure (lights only).
  Duration get actualIntegration => _integration(confirmed);

  Duration _integration(int frames) => isLight
      ? Duration(
          milliseconds: (frames * block.exposureTimeSeconds * 1000).round(),
        )
      : Duration.zero;
}

/// Planned vs actual for a run (TASK 13.4, CALC-37): per block, and the
/// light-frame integration. Rejected frames are captured but not counted as
/// integration. Pure; the counts come from the run's fold.
class SessionReconciliation {
  const SessionReconciliation(this.blocks);

  final List<BlockReconciliation> blocks;

  static SessionReconciliation of(
    List<CaptureBlock> blocks,
    ExecutionState state,
  ) => SessionReconciliation([
    for (final b in blocks)
      BlockReconciliation(
        block: b,
        confirmed: state.completedFor(b.id),
        rejected: state.rejectedFor(b.id),
      ),
  ]);

  /// The plan alone, nothing confirmed (F19 A1: an entry without a
  /// recorded result shows what was planned, never invented counts).
  static SessionReconciliation plannedOnly(List<CaptureBlock> blocks) =>
      SessionReconciliation([
        for (final b in blocks)
          BlockReconciliation(block: b, confirmed: 0, rejected: 0),
      ]);

  Duration get plannedIntegration =>
      blocks.fold(Duration.zero, (sum, b) => sum + b.plannedIntegration);

  Duration get actualIntegration =>
      blocks.fold(Duration.zero, (sum, b) => sum + b.actualIntegration);

  /// Confirmed and rejected light frames (the session's result totals).
  int get actualLightFrames =>
      blocks.where((b) => b.isLight).fold(0, (sum, b) => sum + b.confirmed);

  int get rejectedLightFrames =>
      blocks.where((b) => b.isLight).fold(0, (sum, b) => sum + b.rejected);

  /// actual ÷ planned integration; null when nothing was planned.
  double? get fraction => plannedIntegration == Duration.zero
      ? null
      : actualIntegration.inMilliseconds / plannedIntegration.inMilliseconds;

  /// The light frames by comparable group (ADR-021 C16, the planner's
  /// grouping; logbook.js `entryGainGroups`): equal filter, exposure,
  /// recorded ISO or gain and binning stack together; a block whose
  /// sensitivity is not recorded stays apart. Groups with nothing planned
  /// are left out. Pure.
  List<EntryLightGroup> lightGroups() {
    final groups = <Object, EntryLightGroup>{};
    for (final (i, r) in blocks.indexed) {
      final b = r.block;
      if (!r.isLight) continue;
      final ms = (b.exposureTimeSeconds * 1000).round();
      final Object key = b.gain.kind == GainKind.unknown
          ? i
          : (
              CalibrationMatch.normalizedFilter(b.filterName),
              ms,
              b.gain,
              b.binning,
            );
      final g = groups[key];
      groups[key] = EntryLightGroup(
        first: g?.first ?? b,
        exposureMs: ms,
        planned: (g?.planned ?? 0) + r.planned,
        confirmed: (g?.confirmed ?? 0) + r.confirmed,
      );
    }
    return [
      for (final g in groups.values)
        if (g.planned > 0) g,
    ];
  }
}

/// One comparable light group of an entry: planned and confirmed frames.
class EntryLightGroup {
  const EntryLightGroup({
    required this.first,
    required this.exposureMs,
    required this.planned,
    required this.confirmed,
  });

  /// The group's first block (its filter spelling, ISO or gain, binning).
  final CaptureBlock first;
  final int exposureMs;
  final int planned;
  final int confirmed;
}
