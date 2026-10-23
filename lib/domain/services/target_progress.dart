import '../models/calendar_date.dart';
import '../models/camera_class.dart';
import '../models/capture_block.dart';
import '../models/execution.dart';
import '../models/session.dart';

/// Multi-night progress on one target (TASK 14.2, CALC-38) — without a
/// project entity: the confirmed light integration of its completed
/// sessions, per filter, the last imaged night and the session count.
class TargetProgress {
  const TargetProgress({
    required this.targetId,
    required this.label,
    required this.integration,
    required this.perFilter,
    required this.lastNight,
    required this.sessionCount,
    this.groups = const {},
  });

  final int targetId;

  /// The name stored with the most recent session.
  final String label;
  final Duration integration;

  /// By filter name ("No filter" when none was set).
  final Map<String, Duration> perFilter;
  final CalendarDate? lastNight;
  final int sessionCount;

  /// By filter name, the frames that would stack together (logbook.js
  /// `progressByTarget`): the same rig, exposure, recorded ISO or gain and
  /// binning. A block whose sensitivity is not recorded is its own group,
  /// never combined with another.
  final Map<String, List<ProgressGroup>> groups;

  static const noFilter = 'No filter';

  /// Progress per target id over [runs] (a session with its run state).
  /// Only completed, non-legacy sessions with a target count — a legacy
  /// log has no reliable target or per-block counts (ADR-014 §7).
  static Map<int, TargetProgress> of(Iterable<(Session, ExecutionState)> runs) {
    final out = <int, TargetProgress>{};
    for (final (s, state) in runs) {
      final id = s.targetId;
      if (id == null || s.legacy || s.status != SessionStatus.completed) {
        continue;
      }
      final before = out[id];
      final perFilter = {...?before?.perFilter};
      final groups = {
        for (final MapEntry(:key, :value) in (before?.groups ?? {}).entries)
          key: [...value],
      };
      final rig = s.record.equipmentName;
      final camera = (s.executionStartSnapshot ?? s.planSnapshot)?.cameraClass;
      var total = before?.integration ?? Duration.zero;
      for (final b in s.blocks) {
        if (b.frameType != FrameType.light) continue;
        final d = Duration(
          milliseconds:
              (state.completedFor(b.id) * b.exposureTimeSeconds * 1000).round(),
        );
        final key = (b.filterName?.trim().isEmpty ?? true)
            ? noFilter
            : b.filterName!.trim();
        perFilter[key] = (perFilter[key] ?? Duration.zero) + d;
        total += d;
        final list = groups[key] ??= [];
        final known = b.gain.kind != GainKind.unknown;
        final at = known
            ? list.indexWhere(
                (g) =>
                    g.known &&
                    g.rig == rig &&
                    g.exposureSeconds == b.exposureTimeSeconds &&
                    g.sensitivity == b.gain &&
                    g.binning == b.binning,
              )
            : -1;
        final g = at < 0 ? null : list[at];
        final next = ProgressGroup(
          exposureSeconds: b.exposureTimeSeconds,
          sensitivity: b.gain,
          binning: b.binning,
          rig: rig,
          cameraClass: camera,
          frames: (g?.frames ?? 0) + state.completedFor(b.id),
          integration: (g?.integration ?? Duration.zero) + d,
          nights: {...?g?.nights, s.eveningDate ?? s.id},
        );
        at < 0 ? list.add(next) : list[at] = next;
      }
      final night = s.eveningDate;
      final last = before?.lastNight;
      final newer =
          night != null && (last == null || night.compareTo(last) > 0);
      out[id] = TargetProgress(
        targetId: id,
        label: newer || before == null ? s.record.targetName : before.label,
        integration: total,
        perFilter: perFilter,
        lastNight: newer ? night : last,
        sessionCount: (before?.sessionCount ?? 0) + 1,
        groups: groups,
      );
    }
    return out;
  }
}

/// Frames of one target and filter that would stack together.
class ProgressGroup {
  const ProgressGroup({
    required this.exposureSeconds,
    required this.sensitivity,
    required this.binning,
    required this.rig,
    this.cameraClass,
    required this.frames,
    required this.integration,
    required this.nights,
  });

  final double exposureSeconds;
  final CaptureGain sensitivity;
  final int binning;
  final String rig;

  /// The saved rig's camera class, which names an unrecorded sensitivity.
  final CameraClass? cameraClass;
  final int frames;
  final Duration integration;

  /// The evening dates (or, without one, the entry ids) it was imaged on.
  final Set<Object> nights;

  /// Whether its ISO or gain was recorded (else it stays apart).
  bool get known => sensitivity.kind != GainKind.unknown;
}
