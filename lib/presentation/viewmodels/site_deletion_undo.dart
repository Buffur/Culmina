part of 'site_viewmodel.dart';

/// A deleted site's stored-record Undo: restoring it reselects it only when
/// it was active and no later position replaced it.
extension _SiteDeletionUndo on SiteViewModel {
  Future<DeletionReceipt?> _deleteWithUndo(int id) async {
    final repository = _locationRepository;
    if (repository is! UndoableDeletionRepository) {
      await deleteSite(id);
      return null;
    }
    final active = _activeSite?.id == id;
    final receipt = await (repository as UndoableDeletionRepository)
        .deleteWithUndo(id);
    await _afterSiteDeleted(id);
    final revision = _positionRevision;
    return DeletionReceipt(
      resource: receipt.resource,
      id: id,
      restore: () async {
        await receipt.restore();
        _sites = await _locationRepository.getLocations();
        if (active && _activeSite == null && _positionRevision == revision) {
          await selectSite(id);
        } else {
          _notify();
        }
      },
    );
  }
}
