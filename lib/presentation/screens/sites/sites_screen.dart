import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../shared/site_label.dart';
import '../../../domain/models/location_profile.dart';
import '../../shared/app_words.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/list_mode.dart';
import '../../shared/location_feedback.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../shared/failure_feedback.dart';
import 'site_editor_screen.dart';
import '../../navigation/app_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../shared/hybrid_icon.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';
import 'site_detail_screen.dart';

/// Saved sites and the current position (TASK 7.3): create, edit and delete
/// sites; use the device position or a map pick as a transient position,
/// and save it as a site. Since S9.1 (D9-1) the Library **manages** them (a
/// tap opens the site's record; library.js `listView` sites) and the active
/// site is chosen only from `/select/site` (a tap makes it active).
/// Deleting confirms (RD-09).
class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key, this.mode = ListMode.choose});

  final ListMode mode;

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// A position request is running (TD-112): the button says so.
  bool _locating = false;

  Future<void> _useCurrentPosition(SiteViewModel siteVm) async {
    setState(() => _locating = true);
    try {
      await useCurrentPositionWithFeedback(context, siteVm);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(LocationProfile site) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => SiteDetailScreen(siteId: site.id)),
  );

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final activeId = siteVm.activeSite?.id;
    final hasTransient = siteVm.activeSite == null && !siteVm.isDefaultLocation;
    final sites = siteVm.sites;
    final choosing = widget.mode == ListMode.choose;
    final q = _query.trim().toLowerCase();
    bool has(String? t) => t != null && t.toLowerCase().contains(q);
    final shown = [
      for (final s in sites)
        if (q.isEmpty || has(s.name) || has(s.timeZoneId) || has(s.notes)) s,
    ];
    final p = AppPalette.of(context);
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(choosing ? AppWords.chooseSite : AppWords.sites),
      ),
      body: ListView(
        key: const Key('sites.list'),
        padding: settingsPagePadding,
        children: [
          if (hasTransient)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: p.border)),
              ),
              padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    SiteLabel.of(siteVm, withCoordinates: false)!,
                    style: AppTypography.rowTitle.copyWith(
                      color: p.textPrimary,
                    ),
                  ),
                  SettingsCopy(
                    '${siteDegrees(siteVm.latitude)}, '
                    '${siteDegrees(siteVm.longitude)} · not saved',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    key: const Key('sites.saveTransient'),
                    onPressed: () => context.push(
                      AppRouter.siteEdit,
                      extra: SiteEditorArgs(
                        latitude: siteVm.latitude,
                        longitude: siteVm.longitude,
                        name: siteVm.locationName,
                      ),
                    ),
                    child: const Text('Save as site'),
                  ),
                ],
              ),
            ),
          // Choosing the position used for planning: only when choosing
          // (TD-090, D9-1); the Library manages the saved sites.
          if (choosing) ...[
            if (siteVm.isDefaultLocation)
              const SettingsCopy(
                'No site yet. Use your current position, pick a point on the '
                'map, or add a site.',
              ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              key: const Key('sites.useCurrentPosition'),
              onPressed: _locating ? null : () => _useCurrentPosition(siteVm),
              child: Text(
                _locating ? 'Getting position…' : 'Use current position',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => context.push(AppRouter.position),
              child: const Text('Pick on map'),
            ),
            const SizedBox(height: AppSpacing.itemGap),
          ],
          LibrarySearchField(
            key: const Key('sites.search'),
            controller: _search,
            label: 'Search sites',
            hint: 'Name, time zone or notes',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          LibraryPrimaryAction(
            key: const Key('sites.add'),
            icon: HybridIcons.plus,
            label: 'Add site',
            // TD-090: a site added from the Library is saved, not made
            // active.
            onPressed: () => context.push(
              AppRouter.siteEdit,
              extra: siteVm.isDefaultLocation
                  ? SiteEditorArgs(activate: choosing)
                  : SiteEditorArgs(
                      latitude: siteVm.latitude,
                      longitude: siteVm.longitude,
                      activate: choosing,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (sites.isEmpty)
            const SettingsCopy('No saved sites yet. Add one with “Add site”.')
          else if (shown.isEmpty) ...[
            SettingsCopy('Nothing matches “${_query.trim()}”.'),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {
                _search.clear();
                setState(() => _query = '');
              },
              child: const Text('Clear search'),
            ),
          ],
          for (final site in shown)
            SwipeToDelete(
              itemKey: ValueKey('site-swipe-${site.id}'),
              onDelete: () => deleteSite(context, site),
              child: LibraryRow(
                key: ValueKey('site-${site.id}'),
                title: site.name,
                caption:
                    '${siteDegrees(site.latitude)}, '
                    '${siteDegrees(site.longitude)} · '
                    '${site.timeZoneId ?? 'zone unknown'}',
                note: site.id == activeId ? 'Used for planning' : null,
                onTap: choosing
                    ? () => runWithFeedback(
                        context,
                        'select the site',
                        () => siteVm.selectSite(site.id),
                      )
                    : () => _open(site),
              ),
            ),
        ],
      ),
    );
  }
}
