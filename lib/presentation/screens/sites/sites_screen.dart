import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../shared/site_label.dart';
import '../../shared/geo_controls.dart';
import '../../shared/hybrid_parts.dart';
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
import '../../../core/theme/app_text_theme.dart';
import '../../shared/hybrid_icon.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';
import 'site_detail_screen.dart';

/// Saved sites and the current position (TASK 7.3): create, edit and delete
/// sites; use the device position or a map pick as a transient position,
/// and save it as a site. Since S9.1 (D9-1) the Library **manages** them (a
/// tap opens the site's record; library.js `listView` sites) and the active
/// site is chosen only from `/select/site` (a tap makes it active).
/// The chooser also exposes each record for management, so Tonight needs
/// no intermediate site sheet. Deleting confirms (RD-09).
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
    final showTransient =
        hasTransient &&
        (q.isEmpty ||
            has(siteVm.locationName) ||
            has('Position') ||
            has(SiteLabel.coordinates(siteVm.latitude, siteVm.longitude)));
    final choices = sites;
    final shown = [
      for (final s in choices)
        if (q.isEmpty || has(s.name) || has(s.timeZoneId) || has(s.notes)) s,
    ];
    void add() => context.push(
      AppRouter.siteEdit,
      extra: siteVm.isDefaultLocation
          ? SiteEditorArgs(activate: choosing)
          : SiteEditorArgs(
              latitude: siteVm.latitude,
              longitude: siteVm.longitude,
              name: siteVm.activeSite == null ? siteVm.locationName : null,
              activate: choosing,
            ),
    );
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(choosing ? 'Manage sites' : AppWords.sites),
      ),
      body: ListView(
        key: const Key('sites.list'),
        padding: settingsPagePadding,
        children: [
          DocumentSection(
            key: const Key('sites.searchGroup'),
            children: [
              LayoutBuilder(
                builder: (context, box) {
                  final heading = const GeoHeading('Sites');
                  final button = TextButton(
                    key: const Key('sites.add'),
                    onPressed: add,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HybridIcon(HybridIcons.plus, size: 18),
                        const SizedBox(width: 8),
                        const Text('Add site'),
                      ],
                    ),
                  );
                  if (MediaQuery.textScalerOf(context).scale(1) >= 1.5) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [heading, button],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: heading),
                      button,
                    ],
                  );
                },
              ),
              if (sites.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                LibrarySearchField(
                  key: const Key('sites.search'),
                  controller: _search,
                  label: 'Search sites',
                  hint: 'Name, time zone or notes',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
              if (!showTransient && shown.isEmpty) ...[
                if (sites.isEmpty && !hasTransient)
                  const SettingsCopy(
                    'No saved sites yet. Add one with “Add site”.',
                  )
                else if (q.isNotEmpty) ...[
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
              ],
            ],
          ),
          if (showTransient || shown.isNotEmpty)
            const SizedBox(height: AppSpacing.itemGap),
          if (showTransient)
            DocumentSection(
              joinNext: shown.isNotEmpty,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                _transientRow(siteVm, choosing, divider: shown.isNotEmpty),
              ],
            ),
          for (final (i, site) in shown.indexed)
            DocumentSection(
              joinPrevious: showTransient || i > 0,
              joinNext: i < shown.length - 1,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                _siteRow(
                  site,
                  activeId,
                  choosing,
                  siteVm,
                  divider: i < shown.length - 1,
                ),
              ],
            ),
          if (choosing) ...[
            const SizedBox(height: AppSpacing.md),
            DocumentSection(
              children: [
                GeoHeading(
                  siteVm.isDefaultLocation
                      ? 'Choose where you will observe'
                      : 'Use another position',
                ),
                const SizedBox(height: AppSpacing.sm),
                GeoActionRow(
                  key: const Key('sites.useCurrentPosition'),
                  icon: HybridIcons.locate,
                  label: _locating
                      ? 'Getting position…'
                      : 'Use current position',
                  onTap: _locating ? null : () => _useCurrentPosition(siteVm),
                ),
                GeoActionRow(
                  key: const Key('sites.pickOnMap'),
                  icon: HybridIcons.map,
                  label: 'Pick on map',
                  divider: false,
                  onTap: () => context.push(AppRouter.position),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// A temporary position shares the list, with an honest state and explicit save.
  Widget _transientRow(
    SiteViewModel vm,
    bool choosing, {
    required bool divider,
  }) {
    final p = AppPalette.of(context);
    return Container(
      key: const Key('sites.transient'),
      constraints: const BoxConstraints(minHeight: 72),
      foregroundDecoration: !divider
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: p.border)),
            ),
      child: Row(
        children: [
          if (choosing) ...[
            Semantics(
              label: 'Position used for planning',
              selected: true,
              child: const HybridRadio(checked: true, size: 24),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.itemGap + AppSpacing.xs / 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SiteLabel.compact(vm),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTheme.of(context).rowTitle
                        .copyWith(color: p.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${siteDegrees(vm.latitude)}, ${siteDegrees(vm.longitude)} · Not saved',
                    style: AppTextTheme.of(context)
                        .resolve(
                          AppTextTheme.of(context).body,
                          AppTextGeometry.standard,
                        )
                        .copyWith(color: p.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            key: const Key('sites.saveTransient'),
            tooltip: 'Save as site',
            onPressed: () => context.push(
              AppRouter.siteEdit,
              extra: SiteEditorArgs(
                latitude: vm.latitude,
                longitude: vm.longitude,
                name: vm.locationName,
                activate: choosing,
              ),
            ),
            icon: HybridIcon(
              HybridIcons.plus,
              size: 20,
              color: p.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _siteRow(
    LocationProfile site,
    int? activeId,
    bool choosing,
    SiteViewModel vm, {
    required bool divider,
  }) {
    final p = AppPalette.of(context);
    final caption =
        '${siteDegrees(site.latitude)}, ${siteDegrees(site.longitude)} · ${site.timeZoneId ?? 'zone unknown'}';
    return SwipeToDelete(
      itemKey: ValueKey('site-swipe-${site.id}'),
      onDelete: () => deleteSite(context, site),
      child: choosing
          ? Container(
              key: ValueKey('site-${site.id}'),
              constraints: const BoxConstraints(minHeight: 72),
              foregroundDecoration: !divider
                  ? null
                  : BoxDecoration(
                      border: Border(bottom: BorderSide(color: p.border)),
                    ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: site.id == activeId,
                      child: InkWell(
                        onTap: () => runWithFeedback(
                          context,
                          'select the site',
                          () => vm.selectSite(site.id),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.itemGap + AppSpacing.xs / 2,
                          ),
                          child: Row(
                            children: [
                              HybridRadio(
                                checked: site.id == activeId,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      SiteLabel.displayName(site.name),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextTheme.of(context).rowTitle
                                          .copyWith(color: p.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      caption,
                                      style: AppTextTheme.of(context)
                                          .resolve(
                                            AppTextTheme.of(context).body,
                                            AppTextGeometry.standard,
                                          )
                                          .copyWith(color: p.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    key: ValueKey('site-manage-${site.id}'),
                    tooltip: 'Manage site: ${site.name}',
                    onPressed: () => _open(site),
                    icon: HybridIcon(
                      HybridIcons.edit,
                      size: 20,
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : LibraryRow(
              divider: divider,
              key: ValueKey('site-${site.id}'),
              title: site.name,
              caption: caption,
              note: site.id == activeId ? 'Used for planning' : null,
              onTap: () => _open(site),
            ),
    );
  }
}
