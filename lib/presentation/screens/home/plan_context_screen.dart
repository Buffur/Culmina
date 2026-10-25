import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../../shared/document_section.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/iana_time_context.dart';
import '../../navigation/app_router.dart';
import '../../shared/context_line.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/site_label.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';

/// Site and night (plan.js `context` screen, Hybrid): the observing site
/// and the plan's night as one draft; Apply changes updates the working plan
/// (UX-11: the night is the plan's), and Save plan records it. Close
/// discards the unapplied choice. Sites are managed in the Library.
class PlanContextScreen extends StatefulWidget {
  const PlanContextScreen({super.key});

  @override
  State<PlanContextScreen> createState() => _PlanContextScreenState();
}

class _PlanContextScreenState extends State<PlanContextScreen> {
  int? _siteId;
  CalendarDate? _night;

  @override
  void initState() {
    super.initState();
    _siteId = context.read<SiteViewModel>().activeSite?.id;
    _night = context.read<SessionPlanViewModel>().eveningDate;
  }

  Future<void> _apply() async {
    final site = context.read<SiteViewModel>();
    final plan = context.read<SessionPlanViewModel>();
    final ok = await runWithFeedback(
      context,
      'apply the site and night',
      () async {
        if (_siteId != null && _siteId != site.activeSite?.id) {
          await site.selectSite(_siteId!);
        }
        if (_night != null && _night != plan.eveningDate) {
          await plan.setEveningDate(_night!);
        }
      },
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _pickNight() async {
    final night = _night;
    if (night == null) return;
    final picked = await pickNight(context, initial: night);
    if (picked != null && mounted) setState(() => _night = picked);
  }

  @override
  Widget build(BuildContext context) {
    final site = context.watch<SiteViewModel>();
    final p = AppPalette.of(context);
    final night = _night;
    final selectedSite = site.sites.where((s) => s.id == _siteId).firstOrNull;
    final zone = _siteId == null
        ? site.displayZoneId
        : IanaTimeContext.tryCreate(selectedSite?.timeZoneId)?.id;
    return Scaffold(
      appBar: hybridAppBar(
        context,
        leading: HybridCloseButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Site and night'),
      ),
      body: ListView(
        key: const Key('planContext.scroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.itemGap,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        children: [
          DocumentSection(
            joinNext: true,
            children: [
              const HybridFieldLabel('Observing site'),
              const SizedBox(height: 6),
              if (site.sites.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    SiteLabel.of(site) ?? ContextLine.noSite,
                    style: AppTypography.body.copyWith(color: p.textPrimary),
                  ),
                ),
            ],
          ),
          for (final s in site.sites)
            DocumentSection(
              joinPrevious: true,
              joinNext: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                HybridChoiceRow(
                  key: Key('planContext.site.${s.id}'),
                  title: s.name,
                  caption:
                      s.timeZoneId ??
                      '${s.latitude.toStringAsFixed(4)}, '
                          '${s.longitude.toStringAsFixed(4)}',
                  selected: s.id == _siteId,
                  onTap: () => setState(() => _siteId = s.id),
                ),
              ],
            ),
          DocumentSection(
            joinPrevious: true,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('planContext.manageSites'),
                  onPressed: () => context.push(AppRouter.selectSite),
                  child: const Text('Add or manage sites'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocumentSection(
            key: const Key('planContext.nightGroup'),
            children: [
              const HybridFieldLabel('Night'),
              const SizedBox(height: 4),
              // The select (plan.css): 49 tall, a control-border outline, 12 in.
              Semantics(
                button: true,
                label: night == null
                    ? 'No night without a site'
                    : 'Night of ${NightTimeFormatter.eveningDate(night)}',
                hint: 'Choose a night',
                excludeSemantics: true,
                enabled: night != null,
                onTap: night == null ? null : _pickNight,
                child: InkWell(
                  key: const Key('planContext.night'),
                  borderRadius: BorderRadius.circular(6),
                  onTap: night == null ? null : _pickNight,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 49),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: p.controlBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            night == null
                                ? 'No night without a site'
                                : 'Night of ${NightTimeFormatter.eveningDate(night)}',
                            style: AppTypography.itemTitle.copyWith(
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              color: p.textPrimary,
                            ),
                          ),
                        ),
                        HybridIcon(
                          HybridIcons.down,
                          size: 18,
                          color: p.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (night != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Ends ${NightTimeFormatter.eveningDate(night.addDays(1))}. '
                  '${zone == null ? 'Times are in the device zone.' : 'Times are in the site zone, $zone.'}',
                  style: AppTypography.caption.copyWith(
                    height: 1.55,
                    color: p.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // plan.css `.editor-help`: 13 at 1.6, secondary.
              Text(
                'Changing the night edits this plan. To keep the saved plan and '
                'plan a copy, use More › Copy to another night.',
                key: const Key('planContext.help'),
                style: AppTypography.caption.copyWith(
                  height: 1.6,
                  color: AppPalette.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: HybridApplyBar(
        buttonKey: const Key('planContext.apply'),
        label: 'Apply changes',
        onPressed: _apply,
      ),
    );
  }
}
