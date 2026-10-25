import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../../core/utils/astro_math.dart';
import '../../../domain/models/astro_target.dart';
import '../../../domain/models/target_alias.dart';
import '../../../domain/models/target_types.dart';
import '../../shared/app_words.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_icon.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';

/// One target, read-only (library.js `detailView` target / catalogue): a
/// target you added with Edit target first and Delete target last; a
/// catalogue entry as its bundled record. The reference keeps the catalogue
/// read-only; the app keeps its earlier edit and delete of a catalogue entry
/// (a rename keeps the exact coordinates and the source), offered here when
/// [onEdit] and [onDelete] are given (owner decision 2026-10-23,
/// HYBRID_TRANSFER_STATUS HT-DEV-02). Plan this target starts a new plan
/// with it (S9.1, D9-1); nothing else here changes the plan.
class TargetDetailScreen extends StatefulWidget {
  const TargetDetailScreen({
    super.key,
    required this.target,
    required this.onPlan,
    this.onEdit,
    this.onDelete,
  });

  final AstroTarget target;
  final Future<void> Function(AstroTarget) onPlan;

  /// Edits the target; its saved form, or null when nothing was saved.
  final Future<AstroTarget?> Function(AstroTarget)? onEdit;

  /// Deletes the target; whether it was deleted.
  final Future<bool> Function(AstroTarget)? onDelete;

  @override
  State<TargetDetailScreen> createState() => _TargetDetailScreenState();
}

class _TargetDetailScreenState extends State<TargetDetailScreen> {
  late AstroTarget _t = widget.target;
  late Future<Map<String, List<TargetAlias>>> _aliases = context
      .read<TargetsViewModel>()
      .aliases();

  static String _n(double v) {
    final r = double.parse(v.toStringAsFixed(2));
    return r == r.roundToDouble() ? r.toInt().toString() : r.toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final catalogue = t.isCatalogEntry;
    final name = t.commonName ?? t.catalogId;
    final coordinates = <(String, String, String?)>[
      (
        'Right ascension (J2000)',
        AstroMath.formatRightAscension(t.rightAscension),
        null,
      ),
      ('Declination (J2000)', AstroMath.formatDeclination(t.declination), null),
      (
        'Apparent size (arcmin)',
        switch (t.angularSizeArcmin) {
          final s? => '${_n(s)}′',
          null => 'Not recorded',
        },
        null,
      ),
    ];
    final plan = OutlinedButton(
      key: const Key('targetDetail.plan'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(HybridTokens.minTarget),
      ),
      onPressed: () => widget.onPlan(t),
      child: const Text(AppWords.planThisTarget),
    );
    final edit = LibraryPrimaryAction(
      key: const Key('targetDetail.edit'),
      icon: HybridIcons.edit,
      label: AppWords.editTarget,
      onPressed: widget.onEdit == null
          ? null
          : () async {
              final saved = await widget.onEdit!(t);
              if (saved != null && mounted) setState(() => _t = saved);
            },
    );
    final delete = [
      if (widget.onDelete != null) ...[
        const SizedBox(height: AppSpacing.sm),
        LibraryDeleteAction(
          key: const Key('targetDetail.delete'),
          label: 'Delete target',
          onPressed: () async {
            final navigator = Navigator.of(context);
            if (await widget.onDelete!(t) && mounted) navigator.pop();
          },
        ),
      ],
    ];
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(name),
        actions: const [FieldModeButton()],
      ),
      body: ListView(
        key: const Key('targetDetail.scroll'),
        padding: settingsPagePadding,
        children: catalogue
            ? [
                DocumentSection(
                  key: const Key('targetDetail.identityGroup'),
                  children: [
                    if (widget.onEdit == null) ...const [
                      SettingsHeading('Catalogue record', top: 0),
                      SettingsHint('Bundled catalogue · read-only', top: 0),
                    ] else
                      LibraryRecordHeader(
                        title: 'Catalogue record',
                        caption: 'Bundled catalogue',
                        action: edit,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DocumentSection(
                  key: const Key('targetDetail.factsGroup'),
                  children: [
                    FutureBuilder<Map<String, List<TargetAlias>>>(
                      future: _aliases,
                      builder: (context, snapshot) {
                        final pending =
                            snapshot.connectionState != ConnectionState.done;
                        final failed = !pending && snapshot.hasError;
                        final also = [
                          for (final a
                              in snapshot.data?[t.catalogId] ?? const [])
                            if (a.alias != name) a.alias,
                        ];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FactRows(key: const Key('targetDetail.facts'), [
                              ('Designation', t.catalogId, null),
                              ('Name', name, null),
                              (
                                'Also known as',
                                pending
                                    ? 'Loading aliases…'
                                    : failed
                                    ? 'Unavailable'
                                    : also.isEmpty
                                    ? 'None recorded'
                                    : also.join(', '),
                                failed
                                    ? FailureText.message(
                                        'load the aliases',
                                        snapshot.error!,
                                      )
                                    : null,
                              ),
                              ('Object type', t.type, null),
                              ...coordinates,
                              (
                                'Magnitude (V)',
                                switch (t.magnitude) {
                                  final m? => _n(m),
                                  null => 'Not recorded',
                                },
                                t.magnitude == null
                                    ? 'Not in the catalogue; never estimated.'
                                    : null,
                              ),
                            ]),
                            const SettingsHint('Source', top: AppSpacing.sm),
                            const SettingsCopy(
                              "OpenNGC, via the app's bundled catalogue",
                              key: Key('targetDetail.source'),
                              primary: true,
                              top: AppSpacing.xs,
                            ),
                            if (failed)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  key: const Key('targetDetail.aliasRetry'),
                                  onPressed: () => setState(() {
                                    _aliases = context
                                        .read<TargetsViewModel>()
                                        .aliases();
                                  }),
                                  child: const Text('Retry'),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DocumentSection(
                  key: const Key('targetDetail.actionsGroup'),
                  children: [
                    SettingsCopy(
                      widget.onEdit == null
                          ? 'For different values, add your own target. The '
                                'bundled record stays unchanged.'
                          : 'An edit changes this entry in your app; untouched '
                                'coordinates keep their catalogue values.',
                      top: 0,
                    ),
                    const SizedBox(height: AppSpacing.itemGap),
                    plan,
                    ...delete,
                  ],
                ),
              ]
            : [
                DocumentSection(
                  key: const Key('targetDetail.identityGroup'),
                  children: [
                    LibraryRecordHeader(
                      title: 'Your target',
                      caption: 'Editable · J2000 coordinates',
                      action: edit,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DocumentSection(
                  key: const Key('targetDetail.factsGroup'),
                  children: [
                    FactRows(key: const Key('targetDetail.facts'), [
                      if (t.catalogId != name)
                        (
                          'Catalogue id',
                          t.catalogId,
                          'Kept from when the target was added.',
                        ),
                      (
                        'Object type',
                        t.type,
                        TargetTypes.isMoving(t.type)
                            ? TargetTypes.movingWarning
                            : null,
                      ),
                      ...coordinates,
                      (
                        'Magnitude',
                        switch (t.magnitude) {
                          final m? => _n(m),
                          null => 'Not recorded',
                        },
                        null,
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DocumentSection(
                  key: const Key('targetDetail.actionsGroup'),
                  children: [plan, ...delete],
                ),
              ],
      ),
    );
  }
}
