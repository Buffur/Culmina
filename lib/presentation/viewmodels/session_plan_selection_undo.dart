part of 'session_plan_viewmodel.dart';

/// Selection restoration is scoped to the original plan and revision.
extension _SelectionUndo on SessionPlanViewModel {
  /// Captures only the selected identity; a later choice or different plan
  /// always wins. Restoring a library item is not a new plan edit.
  Future<void> Function() _rememberEquipmentForUndo(int id) {
    final selected = _rig?.id == id;
    final revision = _selectionRevision;
    return () async {
      if (!selected || _rig != null || revision != _selectionRevision) return;
      final restored = await _equipment.getEquipmentById(id);
      if (_rig == null && revision == _selectionRevision) {
        _rig = restored;
        if (_current != null && activeSession?.rigId != restored?.id) {
          await _edited();
        } else {
          markChanged();
        }
      }
    };
  }

  Future<void> Function() _rememberTargetForUndo(int id) {
    final selected = _target?.id == id;
    final revision = _selectionRevision;
    return () async {
      if (!selected || _target != null || revision != _selectionRevision) {
        return;
      }
      final restored = await _targets.getTargetById(id);
      if (_target == null && revision == _selectionRevision) {
        _target = restored;
        if (_current != null && activeSession?.targetId != restored?.id) {
          await _edited();
        } else {
          markChanged();
        }
      }
    };
  }
}
