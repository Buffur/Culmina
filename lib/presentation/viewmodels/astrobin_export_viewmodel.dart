import '../../domain/models/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/astrobin_acquisitions.dart';
import '../../domain/services/session_exporter.dart';

/// The AstroBin acquisition CSV (F20, S16.5): prepares the rows of one
/// entry or of the whole Logbook for the preview, then shares exactly what
/// was previewed. Reads the store; writes nothing.
class AstroBinExportViewModel {
  AstroBinExportViewModel(this._sessions, this._exporter);

  final SessionRepository _sessions;
  final AstroBinCsvExporter _exporter;

  /// Entry [id]'s rows, or every saved entry's when [id] is null (the
  /// Logbook's list: saved plans, results and old logs, never an unsaved
  /// draft).
  Future<AstroBinExport> prepare({int? id}) async {
    final list = id == null
        ? [
            for (final s in await _sessions.list())
              if (s.legacy ||
                  s.status != SessionStatus.draft ||
                  s.plannedAtUtc != null)
                s,
          ]
        : [?await _sessions.get(id)];
    return AstroBinExport.of([
      for (final s in list)
        ExportedSession(s, s.legacy ? const [] : await _sessions.events(s.id)),
    ]);
  }

  /// Shares [acquisitions] as previewed.
  Future<void> share(AstroBinExport acquisitions) =>
      _exporter.share(acquisitions);
}
