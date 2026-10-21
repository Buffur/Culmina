part of 'session_plan_viewmodel.dart';

/// Block edits keep their own revision and snapshot-preserving Undo protocol.
extension _BlockUndo on SessionPlanViewModel {
  /// Runs [change], a blocks edit, and returns what it replaced for [undoBlocksEdit] (TD-079,
  /// S6.16): the blocks once applied, the session once its autosave has finished.
  Future<BlocksEdit> _recordBlocksEdit(
    Future<Object?> Function() change,
  ) async {
    final before = List.of(_blocks), example = _isExample, gen = _contents;
    final done = change();
    final after = List.of(_blocks);
    await done;
    return BlocksEdit(
      before: before,
      wasExample: example,
      after: after,
      contents: gen,
      sessionId: activeSessionId,
    );
  }

  Future<bool> _restoreCaptureBlock(
    int index,
    CaptureBlock block,
    BlocksEdit deletion,
  ) async {
    if (!deletion.inPlan(_contents, activeSessionId)) return false;
    final untouched = deletion.isCurrent(_blocks, _contents, activeSessionId);
    _blocks.insert(index.clamp(0, _blocks.length), block);
    _isExample = untouched && deletion.wasExample;
    await _edited();
    return true;
  }

  /// Undo (TD-079): the blocks and badge as [edit] found them, autosaved (a saved snapshot is never
  /// touched); refused (false) if they changed since.
  Future<bool> _undoBlocksEdit(BlocksEdit edit) async {
    if (!edit.isCurrent(_blocks, _contents, activeSessionId)) return false;
    _blocks = List.of(edit.before);
    _isExample = edit.wasExample;
    await _edited();
    return true;
  }
}
