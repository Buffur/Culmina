import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../shared/site_label.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/night_weather.dart';
import '../../../domain/services/fit_analyzer.dart';
import '../../navigation/app_router.dart';
import '../../../core/utils/quantity_text.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/example_text.dart';
import '../../shared/display_units_of.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/location_feedback.dart';
import '../../shared/night_text.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/plan_night_phrase.dart';
import '../../../domain/models/night_weather_summary.dart';
import '../../shared/plan_state.dart';
import '../../shared/startup_mark.dart';
import '../../shared/status_block.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/night_browser_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../widgets/night_browser_sections.dart';
import '../../widgets/plan_status.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/startup_viewmodel.dart';
import '../../shared/failure_feedback.dart';

/// The Tonight tab's root (ADR-015, TASK 12.5; plan first since S6.13,
/// ADR-019 §5): which site and night, a result due (S8.3), the
/// current plan with its answer, then the night, the Moon and the weather,
/// each opening its detail, then the secondary actions. A summary only:
/// every value comes from the ViewModels.
///
/// S6.13 records two choices: no compact timeline here (ADR-019 §5's fixed
/// order has none, the plan card gives the usable time, and the full
/// timeline is one tap away in the planner); and no Start (UX-13). The live
/// tracker, its run card and its resume prompt left in S8.4: a run still in
/// progress from before is offered by the result line.
class TonightHomeScreen extends StatelessWidget {
  const TonightHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final startupVm = context.watch<StartupViewModel>();
    final Widget body;
    if (startupVm.hasBootstrapError) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Couldn't load your site, settings and current plan."),
            TextButton(
              onPressed: startupVm.retryBootstrap,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (startupVm.isLoading) {
      // S13.3: the mark continues the splash while startup really loads.
      body = const Center(child: StartupMark());
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        // Owner Hybrid adoption: plan first, then conditions and next actions.
        children: const [
          _Title(),
          _Context(),
          SizedBox(height: AppSpacing.lg),
          _PlanCard(),
          SizedBox(height: AppSpacing.lg),
          _NightCard(),
          _ResultDue(),
          _QuickActions(),
        ],
      );
    }

    // S6.16 (the owner's review, 1.1): the screen's title is the page's own
    // header, in the scale's headline role, as on the detail screens
    // (S5.7): it wraps at large text, which an app bar's title cannot. The
    // app bar keeps the actions.
    // F17 A1: the title and the field-mode toggle share one compact
    // header that wraps at large text (in [_Title]).
    return Scaffold(body: SafeArea(child: body));
  }
}

/// The page's title (S6.16) and the field-mode toggle in one wrapping
/// header (F17 A1). AM03-T = B: "Tonight" for the current night, else the
/// plan's night ("Night of Fri, Dec 18"); the tab stays "Tonight".
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('tonight.welcome'),
                    onPressed: () => context.push(AppRouter.welcome),
                    icon: const Icon(Icons.nights_stay_outlined, size: 20),
                    label: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text('culmina'), Text('Welcome & setup')],
                    ),
                  ),
                ),
              ),
              const FieldModeButton(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            container: true,
            header: true,
            child: Text(
              PlanNightPhrase.title(plan.eveningDate, plan.tonightKey),
              key: const Key('tonight.title'),
              style: AppTypography.homeHeading.copyWith(
                color: AppPalette.of(context).textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A clear plan for the night ahead.',
            style: AppTypography.support.copyWith(
              color: AppPalette.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Site ▾ · night ▾ (ADR-019 §5; UX-11): the same control as the planner's;
/// the night picker changes the current plan's night. On a card since S6.16
/// (the owner's review, 1.2).
class _Context extends StatelessWidget {
  const _Context();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    return KeyedSubtree(
      key: const Key('tonight.context'),
      child: ContextLine(
        framed: false,
        siteName: SiteLabel.of(siteVm),
        night: planVm.eveningDate,
        zoneId: siteVm.displayZoneId,
        // The explicit zone stays with the clock times in the Night row.
        // Repeating it above this summary adds an unrelated extra line.
        onSite: () => context.push(AppRouter.selectSite),
        onNight: () async {
          final picked = await pickNight(context, initial: planVm.eveningDate);
          if (picked != null && context.mounted) {
            await runWithFeedback(
              context,
              'change the night',
              () => planVm.setEveningDate(picked),
            );
          }
        },
      ),
    );
  }
}

/// "Last night: M42. How did it go?" (S8.3; ADR-019 §4–§5, I-8): the saved
/// plan (or run in progress) whose night has ended most recently without a
/// result; it opens the result form. Quiet, and gone once recorded; no
/// notification.
class _ResultDue extends StatelessWidget {
  const _ResultDue();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionsViewModel?>()?.dueResult;
    final night = s?.eveningDate;
    if (s == null || night == null) return const SizedBox.shrink();
    final tonight = context.watch<SessionPlanViewModel>().tonightKey;
    final lastNight = night == tonight || night.addDays(1) == tonight;
    final target = s.record.targetName;
    return ListTile(
      key: const Key('tonight.resultDue'),
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.edit_note_outlined),
      title: Text(
        lastNight
            ? AppWords.howDidItGo(target)
            : AppWords.howDidItGoOn(
                target,
                NightTimeFormatter.eveningDate(night),
              ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(AppRouter.results(s.id)),
    );
  }
}

/// Your plan (ADR-019 §5): the target and state, the verdict with its
/// reason and usable time (`StatusBlock`, the planner's words), and Open
/// planner; without a target, Choose a target and What can I image tonight?
///
/// S6.16: "Your plan" is the card's heading in the card-heading role, above
/// the target (body text) and the rig (a caption) (TD-077); Open planner is
/// the card's primary action in every state (the owner's review, 3.2); the
/// two ways to a target each say what they offer (TD-080).
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final fit = context.watch<CaptureAnalysisViewModel>().fitAnalysis;
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final target = planVm.selectedTarget;
    final rig = planVm.selectedEquipment;
    final session = planVm.activeSession;
    final missing = PlanStatus.missingInput(planVm);
    final measured =
        missing == null &&
        (fit.state == FitState.fits ||
            fit.state == FitState.tight ||
            fit.state == FitState.doesNotFit);
    // F17 A5: the status describes the plan's night in its words.
    String words(String text) => PlanNightPhrase.apply(
      text,
      planVm.eveningDate ?? planVm.tonightKey,
      planVm.tonightKey,
    );

    return Card(
      key: const Key('tonight.plan'),
      color: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(),
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              AppSpacing.md,
              0,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        AppWords.yourPlan,
                        key: const Key('tonight.planHeading'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    if (session != null)
                      PlanStateLabel(
                        PlanState.of(session),
                        key: const Key('tonight.planState'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  target == null
                      ? 'No target chosen'
                      : target.commonName ?? target.catalogId,
                  key: const Key('tonight.planTarget'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: target == null
                        ? palette.textSecondary
                        : palette.textPrimary,
                  ),
                ),
                if (rig != null)
                  Text(
                    // Hybrid's rig line: the catalogue ID, then the rig
                    // (RD-04, S6.8: an example rig says so).
                    [
                      if (target != null &&
                          target.commonName != null &&
                          target.commonName != target.catalogId)
                        target.catalogId,
                      ExampleText.rigName(rig),
                    ].join(' · '),
                    key: const Key('tonight.planRig'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.textTertiary,
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                StatusBlock(
                  key: const Key('tonight.status'),
                  separateFigures: true,
                  figuresBeforeReason: false,
                  fitLine: true,
                  state: missing != null ? FitState.needsInput : fit.state,
                  missing: missing?.headline,
                  needed: measured
                      ? Duration(milliseconds: fit.windowLoadMs)
                      : null,
                  usable: measured && fit.availableMs > 0
                      ? Duration(milliseconds: fit.availableMs)
                      : null,
                  // TD-075: a missing input's own reason, else the fit's.
                  reason: words(missing?.reason ?? fit.reason),
                  action: missing?.headline == PlanStatus.needsRig
                      ? OutlinedButton(
                          key: const Key('tonight.chooseRig'),
                          onPressed: () =>
                              context.push(AppRouter.selectRigForPlan),
                          child: const Text(AppWords.chooseRig),
                        )
                      : null,
                ),
              ],
            ),
          ),
          // TD-080: the two ways to a target, each saying what it offers.
          if (_offersTargets(planVm)) ...[
            const Divider(height: 1),
            _Row(
              key: const Key('tonight.chooseTarget'),
              icon: Icons.search,
              label: 'Choose a target',
              lines: const ['Any object in the catalog'],
              onTap: () => context.push(AppRouter.selectTarget),
            ),
            const Divider(height: 1, indent: AppSpacing.md),
            _Row(
              key: const Key('tonight.planCandidates'),
              icon: Icons.format_list_numbered,
              label: _candidatesLabel(planVm),
              lines: const [_candidatesLine],
              onTap: () => context.push(AppRouter.candidates),
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: FilledButton.icon(
              key: const Key('tonight.openPlanner'),
              onPressed: () => context.push(AppRouter.session()),
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Open planner'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "What can I image tonight?" (or "… on Fri, Dec 18?", F17 A5) and its
/// line (TD-080): the candidates for this site and the plan's night, in
/// RD-10's order.
String _candidatesLabel(SessionPlanViewModel plan) =>
    PlanNightPhrase.candidatesAction(
      plan.eveningDate ?? plan.tonightKey,
      plan.tonightKey,
    );
const _candidatesLine = 'Candidates for this site and night, by usable time';

/// Your plan offers the two ways to a target (no target yet, and a night to
/// list candidates for); the secondary actions then leave the second out,
/// so it is shown once (TD-080).
bool _offersTargets(SessionPlanViewModel plan) =>
    plan.selectedTarget == null && plan.sessionNight != null;

/// The night, the Moon and the weather, each opening its detail (S6.5) —
/// or, without a site, the one site prompt (ADR-007 §9: no night is
/// computed for the default location).
class _NightCard extends StatelessWidget {
  const _NightCard();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final theme = Theme.of(context);
    if (siteVm.isDefaultLocation) {
      return Card(
        key: const Key('tonight.noSite'),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Set up your observing site to see tonight: the night, the '
                'Moon and the weather are computed for it.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: () =>
                        useCurrentPositionWithFeedback(context, siteVm),
                    child: const Text('Use current position'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push(AppRouter.selectSite),
                    child: const Text('Set site'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final conditions = context.watch<NightConditionsViewModel>();
    final timeline = conditions.nightTimeline;
    final zoneId = siteVm.displayZoneId;
    // S6.5 (UX-10): each row opens its detail, not the top of the planner.
    void openNight() => context.push(AppRouter.nightMoon);
    final moon = conditions.moonConditions;

    final plan = context.watch<SessionPlanViewModel>();
    final phrase = PlanNightPhrase.of(
      plan.eveningDate ?? plan.tonightKey,
      plan.tonightKey,
    );
    final rows = <Widget>[];
    if (timeline != null) {
      String at(DateTime utc) => NightTimeFormatter.instant(
        context,
        utc,
        windowStartUtc: timeline.night.startUtc,
        zoneId: zoneId,
      );
      final dark = timeline.darkAtLimit;
      rows.add(
        _Row(
          key: const Key('tonight.night'),
          icon: Icons.nights_stay_outlined,
          label: 'Night',
          lines: [
            // F17 A1/A5: the dark interval at the user's limit (TD-054),
            // in the plan-night phrase when there is none.
            if (dark case final d?)
              d is SunNeverBelow
                  ? 'Dark (Sun below ${QuantityText.degrees(d.thresholdDeg)}): '
                        'none $phrase'
                  : DarkText.span(d, at),
            // Hybrid's extra line: how long it is dark (app.js conditions).
            if (dark case final SunCrossing d)
              '${QuantityText.duration((d.dawnUtc ?? timeline.night.endUtc).difference(d.duskUtc ?? timeline.night.startUtc))} dark',
            'Times in ${NightTimeFormatter.zoneCaption(timeline.night.startUtc, zoneId: zoneId)}',
          ],
          onTap: openNight,
        ),
      );
      rows.add(
        ChangeNotifierProvider(
          create: (c) => NightBrowserViewModel(
            site: c.read<SiteViewModel>(),
            plan: c.read<SessionPlanViewModel>(),
            settings: c.read<SettingsViewModel>(),
            nowUtc: () => c.read<NightConditionsViewModel>().nowUtc,
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: NightBarSection(compact: true),
          ),
        ),
      );
      if (moon != null) {
        final free = conditions.moonFree;
        rows.add(
          _Row(
            key: const Key('tonight.moon'),
            icon: Icons.nightlight_round,
            label: 'Moon',
            // F17 A1: the phase and the moon-free dark time (ADR-022 N4,
            // N5); rise and set are on Night & Moon.
            lines: [
              [
                if (moon.phaseName case final p?) MoonText.phaseName(p),
                '${QuantityText.percent(moon.illuminationAtMidnight * 100)} '
                    'lit at midnight',
              ].join(', '),
              if (free != null) MoonText.moonFree(free, at),
            ],
            onTap: () => context.push(AppRouter.moon),
          ),
        );
      }
    }
    rows.add(
      _Row(
        key: const Key('tonight.weather'),
        icon: Icons.cloud_outlined,
        label: 'Weather',
        lines: _weatherLines(context, conditions, phrase),
        onTap: () => context.push(AppRouter.weather),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'The night ahead',
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...rows,
        ],
      ),
    );
  }

  /// The forecast over the dark span (ADR-022 N6): its cloud range, what
  /// of the span it covers, and its age; no dark time, or why there is no
  /// forecast. Unknown is never shown as 0 (SI-008).
  static List<String> _weatherLines(
    BuildContext context,
    NightConditionsViewModel c,
    String phrase,
  ) => switch (c.nightWeather) {
    NightWeatherIdle() || NightWeatherLoading() => [WeatherText.loading],
    NightWeatherOutOfRange() => [WeatherText.outOfRange],
    NightWeatherUnavailable(:final failure) => [
      'No forecast. ${WeatherText.failure(failure)}',
    ],
    final NightWeatherAvailable a => [
      switch (c.nightWeatherSummary) {
        final s? when s.span == NightWeatherSpan.noDark =>
          'No dark time $phrase: no hours to forecast',
        final s => WeatherText.compactConditions(s, unitsOf(context)),
      },
      if (c.nightWeatherSummary case final s?) ?WeatherText.coverage(s),
      WeatherText.freshness(a),
    ],
  };
}

/// The secondary action (F17 A1/A2): the target candidates, when Your plan
/// does not already offer them. Home has no New plan action; the planner
/// keeps its own guarded New plan menu.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    if (_offersTargets(plan)) return const SizedBox.shrink();
    return TextButton.icon(
      key: const Key('tonight.candidates'),
      onPressed: () => context.push(AppRouter.candidates),
      icon: const Icon(Icons.format_list_numbered),
      label: Text(_candidatesLabel(plan)),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}

/// One summary row: an icon, a label and a few lines; tap to drill down.
class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.icon,
    required this.label,
    required this.lines,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<String> lines;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    // Hybrid's condition row (styles.css .condition-row): a 13 px label,
    // the answer as a 15 px value, then 12 px supporting lines.
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 74),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(icon, size: 18, color: palette.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                    for (final (i, l) in lines.indexed)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 2 : 0),
                        child: Text(
                          l,
                          style: i == 0
                              ? theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                )
                              : theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  height: 1.55,
                                  color: palette.textTertiary,
                                ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
