/// Records removed explicitly by the user, eligible for one in-memory Undo.
enum DeletedResource { session, rig, target, site }

/// An optional repository capability; older repository implementations keep
/// their existing delete contract. Production stores implement this capability.
abstract interface class UndoableDeletionRepository {
  Future<DeletionReceipt> deleteWithUndo(int id);
}

/// A single deletion's restore operation. It retains only that deletion's graph,
/// expires with the feedback UI, and is not a backup or persistent trash.
///
/// Duplicate taps share one operation. A failed transaction can be retried;
/// a successful receipt cannot insert the graph twice.
class DeletionReceipt {
  DeletionReceipt({
    required this.resource,
    required this.id,
    required this._restore,
  });

  final DeletedResource resource;
  final int id;
  final Future<void> Function() _restore;
  Future<void>? _pending;
  bool _restored = false;
  bool get restored => _restored;

  Future<void> restore() {
    if (_restored) return Future.value();
    return _pending ??= _run();
  }

  Future<void> _run() async {
    try {
      await _restore();
      _restored = true;
    } finally {
      _pending = null;
    }
  }
}
