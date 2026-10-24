import 'package:flutter/material.dart';

import '../../shared/document_section.dart';
import '../../shared/geo_controls.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/location_profile.dart';
import '../../navigation/app_router.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/display_units_of.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_icon.dart';
import '../../../core/utils/quantity_text.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';
import 'site_editor_screen.dart';

/// "50.40000°" with a typographic minus (library.js `signed`).
String siteDegrees(double v) => QuantityText.degrees(v, digits: 5);

/// Deletes [site] after the shared confirmation (RD-09); the active site
/// says what deleting it means. Returns whether it was deleted.
Future<bool> deleteSite(BuildContext context, LocationProfile site) async {
  final viewModel = context.read<SiteViewModel>();
  final active = viewModel.activeSite?.id == site.id;
  final confirmed = await confirmDestructive(
    context,
    title: 'Delete this site?',
    message: active
        ? '“${site.name}” is the active site. Its position stays as your '
              'current position, but its time zone and sky data no longer '
              'apply. Saved plans keep what they recorded. Undo is '
              'offered right after.'
        : '“${site.name}” is deleted from your sites. Saved plans keep what '
              'they recorded. Undo is offered right after.',
  );
  if (!confirmed || !context.mounted) return false;
  return deleteWithUndoFeedback(
    context,
    action: 'delete the site',
    message: 'Site deleted',
    remove: () => viewModel.deleteWithUndo(site.id),
  );
}

/// One site, read-only (library.js `detailView` site): its position and
/// zone, the details one tap away, Edit site first and Delete site last.
/// Nothing here makes it the site used for planning (TD-090).
class SiteDetailScreen extends StatefulWidget {
  const SiteDetailScreen({super.key, required this.siteId});

  final int siteId;

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  bool _detailsOpen = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SiteViewModel>();
    final site = vm.sites.where((s) => s.id == widget.siteId).firstOrNull;
    if (site == null) {
      // Deleted meanwhile (or by Delete site): nothing left to show.
      return Scaffold(
        appBar: hybridAppBar(context, title: const Text('Site')),
        body: const Padding(
          padding: settingsPagePadding,
          child: SettingsCopy('This site no longer exists.'),
        ),
      );
    }
    final active = vm.activeSite?.id == site.id;
    final edit = LibraryPrimaryAction(
      key: const Key('siteDetail.edit'),
      icon: HybridIcons.edit,
      label: 'Edit site',
      onPressed: () =>
          context.push(AppRouter.siteEdit, extra: SiteEditorArgs(site: site)),
    );
    final delete = LibraryDeleteAction(
      key: const Key('siteDetail.delete'),
      label: 'Delete site',
      onPressed: () async {
        final navigator = Navigator.of(context);
        if (await deleteSite(context, site) && mounted) navigator.pop();
      },
    );
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(site.name),
        actions: const [FieldModeButton()],
      ),
      body: ListView(
        key: const Key('siteDetail.scroll'),
        padding: settingsPagePadding,
        children: [
          DocumentSection(
            key: const Key('siteDetail.identityGroup'),
            children: [
              GeoHeading(active ? 'Used for planning' : 'Saved site'),
              const SettingsCopy(
                'Saved plans and Logbook entries keep their recorded site.',
                top: AppSpacing.xs,
              ),
              const SizedBox(height: AppSpacing.itemGap),
              LayoutBuilder(
                builder: (context, box) =>
                    MediaQuery.textScalerOf(context).scale(1) >= 1.5 ||
                        box.maxWidth < 280
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.sm,
                        children: [edit, delete],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: AppSpacing.sm,
                          children: [
                            Expanded(child: edit),
                            Expanded(child: delete),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocumentSection(
            key: const Key('siteDetail.positionGroup'),
            children: [
              const GeoHeading('Position and time zone'),
              const SizedBox(height: AppSpacing.sm),
              FactRows(key: const Key('siteDetail.facts'), [
                (
                  'Latitude',
                  siteDegrees(site.latitude),
                  'Decimal degrees, north positive',
                ),
                (
                  'Longitude',
                  siteDegrees(site.longitude),
                  'Decimal degrees, east positive',
                ),
                (
                  'Time zone',
                  site.timeZoneId ?? 'Unknown — night uses mean solar time',
                  null,
                ),
              ]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocumentSection(
            key: const Key('siteDetail.detailsGroup'),
            children: [
              Padding(
                padding: EdgeInsets.zero,
                child: CollapsibleSection(
                  key: const Key('siteDetail.details'),
                  sectionKey: 'library.siteDetails',
                  title: 'Site details',
                  titleStyle: Theme.of(context).textTheme.titleSmall,
                  topRule: false,
                  summary: 'Elevation, sky darkness and notes',
                  open: _detailsOpen,
                  onToggle: () => setState(() => _detailsOpen = !_detailsOpen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FactRows([
                        (
                          'Elevation',
                          switch (site.elevation) {
                            final m? =>
                              '${QuantityText.elevation(m, unitsOf(context))} '
                                  'above sea level',
                            null => 'Unknown',
                          },
                          null,
                        ),
                        (
                          'Bortle class',
                          switch (site.bortleClass) {
                            final b? => 'Bortle $b',
                            null => 'Unknown',
                          },
                          site.bortleClass != null && site.bortleSource != null
                              ? 'Source: ${site.bortleSource}'
                              : null,
                        ),
                        (
                          'SQM',
                          switch (site.sqm) {
                            final q? => '${q.toStringAsFixed(2)} mag/arcsec²',
                            null => 'Unknown',
                          },
                          site.sqm != null && site.sqmSource != null
                              ? 'Source: ${site.sqmSource}'
                              : null,
                        ),
                        ('Notes', site.notes ?? 'None', null),
                      ]),
                      const SettingsCopy(
                        'Bortle and SQM are never converted into each other.',
                        top: AppSpacing.sm,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
