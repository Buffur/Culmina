import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../shared/site_label.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/moon_conditions.dart';
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
import '../../shared/hybrid_icon.dart';
import '../../shared/location_feedback.dart';
import '../../shared/night_text.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/plan_night_phrase.dart';
import '../../../domain/models/night_weather_summary.dart';
import '../../shared/plan_state.dart';
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
import 'home_context_sheets.dart';

/// The Tonight tab's root (ADR-015, TASK 12.5; plan first since S6.13,
/// ADR-019 §5), in the accepted Hybrid composition (design/home-lab
/// 86873ce, app.js `plan`/`conditions`): the title and the site and night,
/// then four document sections divided by thin rules — Your plan, The night
/// ahead (Night with its time browser, Moon, Weather), and the next actions
/// (a result due, the candidates). A summary only: every value comes from
/// the ViewModels. The first-run Welcome is reached on first launch; Home
/// no longer links it (owner-accepted reference).
class TonightHomeScreen extends StatelessWidget {
  const TonightHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final startupVm = context.watch<StartupViewModel>();
    final Widget body;
    if (startupVm.hasBootstrapError) {
      // app.js `error` (styles.css `.state-message`): an info icon, the
      // 20/600 heading, what failed and Retry. The site and night are not
      // shown: they did not load.
      final p = AppPalette.of(context);
      body = ListView(
        key: const Key('tonight.loadError'),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: HybridIcon(
              HybridIcons.info,
              size: MediaQuery.textScalerOf(context).scale(20),
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            header: true,
            child: Text(
              "Couldn't load your plan",
              style: AppTypography.homePlanHeading.copyWith(
                height: 1.3,
                color: p.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Your site, settings and current plan couldn't be loaded. Retry "
            'to load them again.',
            style: AppTypography.body.copyWith(
              height: 1.5,
              color: p.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            key: const Key('tonight.retryLoad'),
            onPressed: startupVm.retryBootstrap,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Retry'),
          ),
        ],
      );
    } else if (startupVm.isLoading) {
      // The app root's StartupCover shows the splash's mark meanwhile
      // (owner, 2026-10-23), above the navigation shell.
      body = const SizedBox.shrink();
    } else {
      // app.js `body`: without a site, where to observe comes first, then
      // the plan; no night is computed for the default location (ADR-007
      // §9).
      final noSite = context.watch<SiteViewModel>().isDefaultLocation;
      // styles.css `.app-content` (Hybrid): 20 px on every side.
      body = ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const _Title(),
          const _Context(),
          if (noSite) ...const [
            _NoSite(),
            SizedBox(height: AppSpacing.md),
            _PlanSection(),
          ] else ...const [_PlanSection(), _NightSection(), _NextActions()],
        ],
      );
    }
    return Scaffold(body: SafeArea(child: body));
  }
}

/// The page's title (S6.16) beside the field-mode toggle, then the
/// supporting line (styles.css `.home-title`, `.home-subtitle`). AM03-T =
/// B: "Tonight" for the current night, else the plan's night ("Night of
/// 18 Dec"); the tab stays "Tonight".
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final p = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  container: true,
                  header: true,
                  child: Text(
                    PlanNightPhrase.title(plan.eveningDate, plan.tonightKey),
                    key: const Key('tonight.title'),
                    style: AppTypography.homeHeading.copyWith(
                      color: p.textPrimary,
                    ),
                  ),
                ),
              ),
              const FieldModeButton(home: true),
            ],
          ),
        ),
        Text(
          'A clear plan for the night ahead.',
          style: AppTypography.body.copyWith(color: p.textTertiary),
        ),
      ],
    );
  }
}

/// Site ▾ · night ▾ (ADR-019 §5; UX-11; styles.css `.app-context`): the
/// same control as the planner's; the night picker changes the current
/// plan's night. Its 48 dp targets provide the surrounding space.
class _Context extends StatelessWidget {
  const _Context();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    return KeyedSubtree(
      key: const Key('tonight.context'),
      child: ContextLine(
        siteName: siteVm.isDefaultLocation ? null : SiteLabel.compact(siteVm),
        siteDescription: SiteLabel.of(siteVm),
        compact: true,
        noSiteLabel: ContextLine.setSite,
        night: planVm.eveningDate,
        zoneId: siteVm.displayZoneId,
        // Owner refinement: direct calendar and combined site management.
        onSite: () => showHomeSiteSheet(context),
        onNight: () => showHomeNightSheet(context),
      ),
    );
  }
}

/// A document section (notion-hybrid.css): one thin rule above it, then
/// [top] of space before its content.
class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.child,
    this.top = AppSpacing.md,
    this.strongRule = false,
  });

  final Widget child;
  final double top;

  /// The conditions section's rule is the control border, not the subtle
  /// one (catalog.css `.conditions`).
  final bool strongRule;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: strongRule ? p.controlBorder : p.border),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: top),
        child: child,
      ),
    );
  }
}

/// Where will you observe? (app.js `body`, `no-site`; styles.css
/// `.state-message`): a 20 px pin, the 20/600 question, why, then Set site
/// and the "Use current position" row with its arrow.
class _NoSite extends StatelessWidget {
  const _NoSite();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final p = AppPalette.of(context);
    return Column(
      key: const Key('tonight.noSite'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: HybridIcon(
            HybridIcons.pin,
            size: MediaQuery.textScalerOf(context).scale(20),
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          header: true,
          child: Text(
            'Where will you observe?',
            style: AppTypography.homePlanHeading.copyWith(
              height: 1.3,
              color: p.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Set up your observing site to see the night, Moon and weather '
          'for it.',
          style: AppTypography.body.copyWith(
            height: 1.5,
            color: p.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          key: const Key('tonight.setSite'),
          onPressed: () => context.push(AppRouter.selectSite),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text(ContextLine.setSite),
        ),
        // styles.css `.candidate-button`: 56 tall, 16/500, an arrow.
        Semantics(
          button: true,
          label: 'Use current position',
          excludeSemantics: true,
          child: InkWell(
            key: const Key('tonight.useCurrentPosition'),
            onTap: () => useCurrentPositionWithFeedback(context, siteVm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Use current position',
                        style: AppTypography.itemTitle.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                    HybridIcon(
                      HybridIcons.arrow,
                      size: MediaQuery.textScalerOf(context).scale(15),
                      color: p.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Your plan (ADR-019 §5; app.js `plan`): the heading and the plan's
/// compact status, the target and its rig, the fit line with its reason
/// and the two measures, and Open planner; without a target, Choose a
/// target and What can I image…? (TD-080).
class _PlanSection extends StatelessWidget {
  const _PlanSection();

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final fit = context.watch<CaptureAnalysisViewModel>().fitAnalysis;
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

    return _Section(
      key: const Key('tonight.plan'),
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
                  style: AppTypography.homePlanHeading.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
              if (session != null)
                PlanStateLabel(
                  PlanState.of(session),
                  key: const Key('tonight.planState'),
                  withIcon: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            target == null
                ? 'No target chosen'
                : target.commonName ?? target.catalogId,
            key: const Key('tonight.planTarget'),
            style: AppTypography.homeTarget.copyWith(
              color: target == null
                  ? palette.textSecondary
                  : palette.textPrimary,
            ),
          ),
          if (rig != null) ...[
            const SizedBox(height: 5),
            Text(
              // Hybrid's rig line: the catalogue ID, then the rig (RD-04,
              // S6.8: an example rig says so).
              [
                if (target != null &&
                    target.commonName != null &&
                    target.commonName != target.catalogId)
                  target.catalogId,
                ExampleText.rigName(rig),
              ].join(' · '),
              key: const Key('tonight.planRig'),
              style: AppTypography.body.copyWith(color: palette.textTertiary),
            ),
          ],
          const SizedBox(height: 18),
          StatusBlock(
            key: const Key('tonight.status'),
            separateFigures: true,
            figuresBeforeReason: false,
            fitLine: true,
            state: missing != null ? FitState.needsInput : fit.state,
            missing: missing?.headline,
            needed: measured ? Duration(milliseconds: fit.windowLoadMs) : null,
            usable: measured && fit.availableMs > 0
                ? Duration(milliseconds: fit.availableMs)
                : null,
            // TD-075: a missing input's own reason, else the fit's.
            reason: words(missing?.reason ?? fit.reason),
            action: missing?.headline == PlanStatus.needsRig
                ? OutlinedButton(
                    key: const Key('tonight.chooseRig'),
                    onPressed: () => context.push(AppRouter.selectRigForPlan),
                    child: const Text(AppWords.chooseRig),
                  )
                : null,
          ),
          // TD-080: the two ways to a target, each saying what it offers.
          if (_offersTargets(planVm)) ...[
            const SizedBox(height: AppSpacing.md),
            _ActionRow(
              key: const Key('tonight.chooseTarget'),
              title: 'Choose a target',
              caption: 'Any object in the catalog',
              onTap: () => context.push(AppRouter.selectTarget),
            ),
            _ActionRow(
              key: const Key('tonight.planCandidates'),
              title: _candidatesLabel(planVm),
              caption: _candidatesLine,
              onTap: () => context.push(AppRouter.candidates),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const Key('tonight.openPlanner'),
            onPressed: () => context.push(AppRouter.session()),
            icon: HybridIcon(
              HybridIcons.planner,
              size: MediaQuery.textScalerOf(context).scale(17),
            ),
            label: const Text('Open planner'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

/// "What can I image tonight?" (or "… on 18 Dec?", F17 A5) and its line
/// (TD-080): the candidates for this site and the plan's night, in RD-10's
/// order.
String _candidatesLabel(SessionPlanViewModel plan) =>
    PlanNightPhrase.candidatesAction(
      plan.eveningDate ?? plan.tonightKey,
      plan.tonightKey,
    );
const _candidatesLine = 'Candidates for this site and night, by usable time';

/// Your plan offers the two ways to a target (no target yet, and a night to
/// list candidates for); the next actions then leave the second out, so it
/// is shown once (TD-080).
bool _offersTargets(SessionPlanViewModel plan) =>
    plan.selectedTarget == null && plan.sessionNight != null;

/// The night, the Moon and the weather, each opening its detail (S6.5) —
/// or, without a site, the one site prompt (ADR-007 §9: no night is
/// computed for the default location). catalog.css `.conditions`: 24 below
/// Your plan, a control-border rule, 24 above the serif heading.
class _NightSection extends StatelessWidget {
  const _NightSection();

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final p = AppPalette.of(context);
    final heading = Semantics(
      header: true,
      child: Text(
        'The night ahead',
        style: AppTypography.nightHeading.copyWith(color: p.textPrimary),
      ),
    );
    // Home shows the site prompt instead (`_NoSite`).
    if (siteVm.isDefaultLocation) return const SizedBox.shrink();

    final conditions = context.watch<NightConditionsViewModel>();
    final timeline = conditions.nightTimeline;
    final zoneId = siteVm.displayZoneId;
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
      final darkSpan = switch (dark) {
        SunCrossing(:final duskUtc, :final dawnUtc) => (
          duskUtc ?? timeline.night.startUtc,
          dawnUtc ?? timeline.night.endUtc,
        ),
        SunAlwaysBelow() => (timeline.night.startUtc, timeline.night.endUtc),
        _ => null,
      };
      rows.add(
        _ConditionRow(
          key: const Key('tonight.night'),
          icon: HybridIcons.homeMoon,
          label: 'Night',
          value: darkSpan == null
              ? 'No dark time $phrase'
              : '${at(darkSpan.$1)}–${at(darkSpan.$2)}',
          extra: [
            if (darkSpan != null)
              '${QuantityText.duration(darkSpan.$2.difference(darkSpan.$1))} dark'
            else
              'Sun stays above ${QuantityText.degrees(dark?.thresholdDeg ?? -18)}',
            ?zoneId,
          ].join(' · '),
          onTap: () => context.push(AppRouter.nightMoon),
          topRule: false,
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
          // night.css `.night-slider.compact` under the row it explains,
          // 16 above its bottom rule.
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.border)),
            ),
            child: const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: NightBarSection(home: true),
            ),
          ),
        ),
      );
      if (moon != null) {
        final free = conditions.moonFree;
        rows.add(
          _ConditionRow(
            key: const Key('tonight.moon'),
            icon: HybridIcons.homeMoon,
            label: 'Moon',
            value: [
              if (moon.phaseName case final ph?) MoonText.phaseName(ph),
              '${QuantityText.percent(moon.illuminationAtMidnight * 100)} lit',
            ].join(' · '),
            extra: free == null ? '' : _moonFree(free, at),
            onTap: () => context.push(AppRouter.moon),
          ),
        );
      }
    }
    final (headline, detail) = _weather(context, conditions, phrase);
    rows.add(
      _ConditionRow(
        key: const Key('tonight.weather'),
        icon: HybridIcons.homeCloud,
        label: 'Weather',
        value: headline,
        extra: detail,
        onTap: () => context.push(AppRouter.weather),
        bottomPadding: 0,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: _Section(
        top: AppSpacing.lg,
        strongRule: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            const SizedBox(height: AppSpacing.xs),
            ...rows,
          ],
        ),
      ),
    );
  }

  /// app.js `conditions`: "Moon-free 00:30–04:45 (+1) · 4 h 15 min", or why
  /// there is none.
  static String _moonFree(
    MoonFreeNight m,
    String Function(DateTime) at,
  ) => switch (m.kind) {
    MoonFreeKind.noDark => 'No dark time, so no moon-free dark',
    MoonFreeKind.none => 'Moon above the horizon through dark time',
    _ =>
      'Moon-free ${m.intervals.map((i) => '${at(i.$1)}–${at(i.$2)}').join(', ')}'
          ' · ${QuantityText.duration(m.moonFree)}',
  };

  /// The forecast over the dark span as Home's one headline and one
  /// provenance line (night-ui.js `weatherWidgetSummary`; ADR-022 N6):
  /// temperature and the highest wind, then the coverage and age facts.
  /// Unknown is never shown as 0 (SI-008).
  static (String, String) _weather(
    BuildContext context,
    NightConditionsViewModel c,
    String phrase,
  ) {
    final units = unitsOf(context);
    return switch (c.nightWeather) {
      NightWeatherIdle() ||
      NightWeatherLoading() => ('Loading forecast', 'Forecast · open Weather'),
      NightWeatherOutOfRange() => (
        'No forecast yet',
        'Beyond the 16-day forecast · planning works without weather',
      ),
      NightWeatherUnavailable(:final failure) => (
        'Forecast unavailable',
        WeatherText.failure(failure),
      ),
      final NightWeatherAvailable a => switch (c.nightWeatherSummary) {
        final s? when s.span == NightWeatherSpan.noDark => (
          'No dark-time forecast',
          'No dark time $phrase',
        ),
        final s => (
          [
            if (s?.temperature case final t?)
              WeatherText.temperatureRange(t, units),
            if (s?.windSpeed case final w?)
              'wind up to ${WeatherText.windRange(WeatherRange(w.max, w.max), units)}',
          ].join(' · ').ifEmpty('Measurements incomplete'),
          [
            'Forecast for the dark hours',
            if (s != null && !s.complete) 'Partial coverage',
            switch (a.age) {
              WeatherAge.current => null,
              WeatherAge.aging => 'Aging snapshot',
              WeatherAge.stale => 'Stale snapshot',
            },
          ].whereType<String>().join(' · '),
        ),
      },
    };
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

/// The next actions (app.js `home-actions`): a result due (S8.3) and the
/// target candidates when Your plan does not already offer them; 16 below
/// the conditions, a thin rule, 16 above. No rule between the rows.
class _NextActions extends StatelessWidget {
  const _NextActions();

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final s = context.watch<SessionsViewModel?>()?.dueResult;
    final night = s?.eveningDate;
    final rows = <Widget>[
      if (s != null && night != null)
        _ActionRow(
          key: const Key('tonight.resultDue'),
          title: 'Record result',
          caption: [
            s.record.targetName,
            NightTimeFormatter.eveningDate(night),
            'not recorded',
          ].join(' · '),
          semanticsLabel:
              night == plan.tonightKey || night.addDays(1) == plan.tonightKey
              ? AppWords.howDidItGo(s.record.targetName)
              : AppWords.howDidItGoOn(
                  s.record.targetName,
                  NightTimeFormatter.eveningDate(night),
                ),
          onTap: () => context.push(AppRouter.results(s.id)),
        ),
      if (!_offersTargets(plan))
        _ActionRow(
          key: const Key('tonight.candidates'),
          title: _candidatesLabel(plan),
          onTap: () => context.push(AppRouter.candidates),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: _Section(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        ),
      ),
    );
  }
}

/// A next-action row (styles.css `.due-result`, `.candidate-button`): a
/// 16/500 title, an optional 13 px caption and an 18 px chevron, at least
/// 48 tall with 8 above and below.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    super.key,
    required this.title,
    required this.onTap,
    this.caption,
    this.semanticsLabel,
  });

  final String title;
  final String? caption;
  final String? semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      button: true,
      label: semanticsLabel ?? [title, ?caption].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.itemTitle.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 21 / 16,
                          color: p.textPrimary,
                        ),
                      ),
                      if (caption != null)
                        Text(
                          caption!,
                          style: AppTypography.caption.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                HybridIcon(
                  HybridIcons.chevron,
                  size: 18,
                  color: p.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One condition row (styles.css `.condition-row`, a594837): a 20 px icon
/// and the 16/600 label on one line, the 15 px value and the 13 px extra
/// below it aligned with the icon, an 18 px chevron centred; 12 above and
/// below; a thin rule above unless it follows the row it continues.
class _ConditionRow extends StatelessWidget {
  const _ConditionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.extra,
    required this.onTap,
    this.topRule = true,
    this.bottomPadding = 12,
  });

  final HybridIconData icon;
  final String label;
  final String value;
  final String extra;
  final VoidCallback onTap;
  final bool topRule;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final row = InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: 12, bottom: bottomPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HybridIcon(icon, size: 20, color: p.textPrimary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.itemTitle.copyWith(
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.value.copyWith(
                      color: p.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (extra.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      extra,
                      style: AppTypography.caption.copyWith(
                        height: 1.55,
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            HybridIcon(HybridIcons.chevron, size: 18, color: p.textSecondary),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      label: '$label: $value${extra.isEmpty ? '' : '. $extra'}',
      excludeSemantics: true,
      child: topRule
          ? DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.border)),
              ),
              child: row,
            )
          : row,
    );
  }
}
