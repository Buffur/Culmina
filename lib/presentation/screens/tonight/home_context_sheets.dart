import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/calendar_date.dart';
import '../../navigation/app_router.dart';
import '../../shared/context_line.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/night_time_formatter.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';

/// Home's site chip (app.js `site` detail, WQA-06): "Observing site" on a
/// full-phone sheet, the saved sites in a select, Cancel and Apply site.
/// Applying changes the working plan's site; Save plan records it.
Future<void> showHomeSiteSheet(BuildContext context) =>
    // Over the whole phone, root navigation included (`#detail`).
    AppRouter.rootNavigatorKey.currentState!.push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _SiteSheet(),
      ),
    );

/// Home's night chip (app.js `date` detail, WQA-06): "Choose a night" on a
/// full-phone sheet. The reference's select of example nights is the
/// platform date picker here (any night can be planned); Apply night
/// changes the working plan's night.
Future<void> showHomeNightSheet(BuildContext context) =>
    // Over the whole phone, root navigation included (`#detail`).
    AppRouter.rootNavigatorKey.currentState!.push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _NightSheet(),
      ),
    );

const _intro =
    'Choose for the working plan. Save plan records the change. '
    'Cancel leaves the draft unchanged.';

class _SiteSheet extends StatefulWidget {
  const _SiteSheet();

  @override
  State<_SiteSheet> createState() => _SiteSheetState();
}

class _SiteSheetState extends State<_SiteSheet> {
  int? _siteId;

  @override
  void initState() {
    super.initState();
    final site = context.read<SiteViewModel>();
    _siteId = site.isDefaultLocation ? null : site.activeSite?.id;
  }

  Future<void> _apply() async {
    final site = context.read<SiteViewModel>();
    final id = _siteId;
    final ok =
        id == null ||
        id == site.activeSite?.id ||
        await runWithFeedback(
          context,
          'apply the site',
          () => site.selectSite(id),
        );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final site = context.watch<SiteViewModel>();
    final sites = site.sites;
    return _Sheet(
      title: 'Observing site',
      applyKey: const Key('homeSite.apply'),
      applyLabel: 'Apply site',
      onApply: sites.isEmpty ? null : _apply,
      note: 'Add or manage coordinates in Library → Sites.',
      fields: [
        _Label('Site'),
        if (sites.isEmpty)
          Text(
            'No saved sites yet.',
            style: AppTypography.body.copyWith(
              height: 1.5,
              color: AppPalette.of(context).textSecondary,
            ),
          )
        else
          DropdownButtonFormField<int>(
            key: const Key('homeSite.select'),
            initialValue: sites.any((s) => s.id == _siteId) ? _siteId : null,
            isExpanded: true,
            // `.phone-detail select`: the sheet's 14 px.
            style: AppTypography.body.copyWith(
              height: 1.5,
              color: AppPalette.of(context).textPrimary,
            ),
            icon: hybridSelectIcon(context),
            hint: const Text('Choose a site'),
            decoration: const InputDecoration(
              contentPadding: hybridSelectPadding,
            ),
            items: [
              for (final s in sites)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: (id) => setState(() => _siteId = id),
          ),
      ],
      after: Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(
          key: const Key('homeSite.manage'),
          // The native list adds the device position and saves sites.
          onPressed: () => context.push(AppRouter.selectSite),
          child: const Text('Add or manage sites'),
        ),
      ),
    );
  }
}

class _NightSheet extends StatefulWidget {
  const _NightSheet();

  @override
  State<_NightSheet> createState() => _NightSheetState();
}

class _NightSheetState extends State<_NightSheet> {
  CalendarDate? _night;

  @override
  void initState() {
    super.initState();
    final plan = context.read<SessionPlanViewModel>();
    _night = plan.eveningDate ?? plan.tonightKey;
  }

  Future<void> _apply() async {
    final plan = context.read<SessionPlanViewModel>();
    final night = _night;
    final ok =
        night == null ||
        night == plan.eveningDate ||
        await runWithFeedback(
          context,
          'change the night',
          () => plan.setEveningDate(night),
        );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final night = _night;
    return _Sheet(
      title: 'Choose a night',
      applyKey: const Key('homeNight.apply'),
      applyLabel: 'Apply night',
      onApply: _apply,
      fields: [
        _Label('Evening date'),
        // A select's closed state (styles.css `#detail-body select`): 48
        // tall, a control-border outline; it opens the date picker.
        Semantics(
          button: true,
          label: night == null
              ? 'Evening date'
              : 'Evening date, night of '
                    '${NightTimeFormatter.eveningDate(night)}',
          excludeSemantics: true,
          child: InkWell(
            key: const Key('homeNight.date'),
            borderRadius: BorderRadius.circular(6),
            onTap: () async {
              final picked = await pickNight(context, initial: night);
              if (picked != null && mounted) {
                setState(() => _night = picked);
              }
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: hybridSelectPadding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: p.controlBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      night == null
                          ? 'Choose a night'
                          : 'Night of ${NightTimeFormatter.eveningDate(night)}',
                      style: AppTypography.body.copyWith(
                        height: 1.5,
                        color: p.textPrimary,
                      ),
                    ),
                  ),
                  hybridSelectIcon(context),
                ],
              ),
            ),
          ),
        ),
        if (night != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ends ${NightTimeFormatter.eveningDate(night.addDays(1))}',
            key: const Key('homeNight.ends'),
            style: AppTypography.body.copyWith(
              height: 1.5,
              color: p.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// A field's label (`#detail-body label`): 14 px, 8 above the control.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      text,
      style: AppTypography.body.copyWith(
        height: 1.5,
        color: AppPalette.of(context).textPrimary,
      ),
    ),
  );
}

/// The phone detail sheet (styles.css `#detail.phone-detail`): the app's
/// name and a close button over a subtle rule, then 16 in: the 23 px
/// title, the intro, the fields, Cancel and the primary action, each the
/// full width and 48 tall (WQA-06), and a note.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.title,
    required this.applyKey,
    required this.applyLabel,
    required this.onApply,
    required this.fields,
    this.note,
    this.after,
  });

  final String title;
  final Key applyKey;
  final String applyLabel;
  final VoidCallback? onApply;
  final List<Widget> fields;
  final String? note;
  final Widget? after;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final secondary = AppTypography.body.copyWith(
      height: 1.5,
      color: p.textSecondary,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HomeSheetHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: AppTypography.homeTarget.copyWith(
                        fontSize: 23,
                        height: 1.3,
                        color: p.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(_intro, style: secondary),
                  const SizedBox(height: AppSpacing.md),
                  ...fields,
                  const SizedBox(height: AppSpacing.lg),
                  // `.phone-detail` buttons inherit the sheet's 14 px.
                  OutlinedButton(
                    key: const Key('homeSheet.cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      textStyle: AppTypography.body.copyWith(height: 1.5),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(height: AppSpacing.itemGap),
                  FilledButton(
                    key: applyKey,
                    onPressed: onApply,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      textStyle: AppTypography.body.copyWith(
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(applyLabel),
                  ),
                  if (note != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(note!, style: secondary),
                  ],
                  ?after,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The phone detail sheet's header (styles.css `.dialog-header` in
/// `#detail.phone-detail`): the app's name in 12 px tertiary, [actions],
/// then Close, over a subtle rule.
class HomeSheetHeader extends StatelessWidget {
  const HomeSheetHeader({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Culmina',
                style: AppTypography.dense.copyWith(color: p.textTertiary),
              ),
            ),
            ...actions,
            IconButton(
              key: const Key('homeSheet.close'),
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: HybridIcon(
                HybridIcons.close,
                size: MediaQuery.textScalerOf(context).scale(20),
                color: p.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
