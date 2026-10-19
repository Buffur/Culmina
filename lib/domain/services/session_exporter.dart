import '../models/execution.dart';
import '../models/session.dart';
import 'astrobin_acquisitions.dart';

/// A session as exported (TASK 14.3): the aggregate with its run's events
/// (owner decision: the event log is included).
class ExportedSession {
  const ExportedSession(this.session, this.events);

  final Session session;
  final List<ExecutionEvent> events;
}

/// Writes sessions to a portable manifest file and shares it with a short
/// text summary (TASK 14.3; manifest v2, `docs/EXPORT_MANIFEST.md`).
/// Implemented in the data layer; import is deferred.
abstract class SessionExporter {
  Future<void> share(List<ExportedSession> sessions);
}

/// Shares an AstroBin acquisition CSV (F20; mapping v1 in
/// `docs/EXPORT_MANIFEST.md`) through the platform share sheet, with the
/// rows' filter names in order. Implemented in the data layer.
abstract class AstroBinCsvExporter {
  Future<void> share(AstroBinExport acquisitions);
}
