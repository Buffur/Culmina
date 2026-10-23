import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/collapsible_section.dart';
import '../../../domain/models/session.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/hybrid_view_entrance.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/moon_conditions.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/session_night.dart';
import '../../shared/app_words.dart';
import '../../navigation/app_router.dart';
import '../../shared/context_line.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/night_text.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/plan_this_night.dart';
import '../../shared/site_label.dart';
import '../../viewmodels/night_browser_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../widgets/night_browser_sections.dart';
import '../../widgets/weather_hybrid_view.dart';

/// Hybrid conditions share a transient viewed night across all three tabs.
/// Only the existing explicit Plan this night action adopts it into a plan.
class NightMoonScreen extends StatelessWidget {
  const NightMoonScreen({super.key, this.computeMonth, this.initialPage = 0});

  final MonthComputer? computeMonth;
  final int initialPage;

  @override
  Widget build(BuildContext context) {
    final source = context.read<NightConditionsViewModel>();
    return ChangeNotifierProvider(
      create: (c) => NightBrowserViewModel(
        site: c.read<SiteViewModel>(),
        plan: c.read<SessionPlanViewModel>(),
        settings: c.read<SettingsViewModel>(),
        nowUtc: () => source.nowUtc,
        computeMonth: computeMonth,
      ),
      child: Builder(
        builder: (c) {
          final browser = c.read<NightBrowserViewModel>();
          return ChangeNotifierProvider(
            create: (_) => source.forViewedNight(
              night: () => c.read<SiteViewModel>().isDefaultLocation
                  ? null
                  : browser.view.night,
              changes: browser,
            )..begin(),
            child: _NightMoonBody(initialPage: initialPage),
          );
        },
      ),
    );
  }
}

class _NightMoonBody extends StatefulWidget {
  const _NightMoonBody({required this.initialPage});
  final int initialPage;

  @override
  State<_NightMoonBody> createState() => _NightMoonBodyState();
}

class _NightMoonBodyState extends State<_NightMoonBody> {
  late int page = widget.initialPage;
  final moonTimelineKey = GlobalKey();
  final moonTimelineFocus = FocusNode(debugLabel: 'Moon time browser');

  @override
  void dispose() {
    moonTimelineFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final site = context.watch<SiteViewModel>();
    final browser = context.watch<NightBrowserViewModel>();
    final text = Theme.of(context).textTheme;
    final p = AppPalette.of(context);
    final quiet = AppTypography.caption.copyWith(
      height: 1.65,
      color: p.textSecondary,
    );
    // Three equal tabs hold 14 px labels up to about 1.3x on a phone.
    final largeTabs = MediaQuery.textScalerOf(context).scale(14) > 14 * 1.3;
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialPage,
      child: Scaffold(
        appBar: hybridAppBar(
          context,
          titleSpacing: Navigator.of(context).canPop() ? 8 : 16,
          title: Text(page == 2 ? 'Weather' : 'Night & Moon'),
          actions: const [FieldModeButton()],
          bottom: TabBar(
            // Large text: the three labels scroll instead of being clipped.
            isScrollable: largeTabs,
            tabAlignment: largeTabs ? TabAlignment.start : null,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2,
                color: AppPalette.of(context).textPrimary,
              ),
              insets: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + AppSpacing.xs,
              ),
            ),
            labelColor: p.textPrimary,
            unselectedLabelColor: p.textSecondary,
            labelStyle: text.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: text.bodySmall?.copyWith(fontSize: 14),
            onTap: (value) => setState(() => page = value),
            tabs: const [
              Tab(text: 'Night'),
              Tab(text: 'Moon'),
              Tab(text: 'Weather'),
            ],
          ),
        ),
        body: HybridViewEntrance(
          trigger: page,
          child: SafeArea(
            top: false,
            child: site.isDefaultLocation
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.md,
                      AppSpacing.gutter,
                      AppSpacing.xl,
                    ),
                    children: [
                      // conditions.js `missing-conditions`.
                      Text(
                        'Set an observing site',
                        style: AppTypography.sectionHeading.copyWith(
                          color: p.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Night, Moon and weather belong to a place and its '
                        'time zone. No default-location forecast is '
                        'substituted.',
                        style: quiet,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          key: const Key('conditions.chooseSite'),
                          onPressed: () => context.push(AppRouter.selectSite),
                          child: const Text('Choose a site'),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    key: ValueKey('conditions.page.$page'),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.md,
                      AppSpacing.gutter,
                      AppSpacing.xl,
                    ),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // conditions.js browseHeader: "Kyiv outskirts ·
                          // Europe/Kyiv"; a screen reader hears the full
                          // zone rule.
                          Semantics(
                            label:
                                '${SiteLabel.of(site) ?? 'Observing site'}. '
                                '${ContextLine.zoneRule(browser.view.night.startUtc, zoneId: site.displayZoneId)}',
                            child: ExcludeSemantics(
                              child: Text(
                                '${SiteLabel.of(site) ?? 'No observing site'} · '
                                '${site.displayZoneId ?? 'device time zone'}',
                                key: const Key('detail.context'),
                                style: AppTypography.caption.copyWith(
                                  height: 1.6,
                                  color: p.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const _ViewedNightHeader(),
                          const SizedBox(height: 24),
                          if (page == 0) ...[
                            const _NightAnswer(),
                            const SizedBox(height: 16),
                            const NightBarSection(compact: true),
                            const SizedBox(height: 12),
                            const _ReadingDisclosure(),
                            _ConditionsDisclosure(
                              id: 'moonIntervals',
                              title: 'Moon intervals & phase',
                              subtitle: _phaseSummary(browser),
                              icon: HybridIcons.lucideMoon,
                              child: const _MoonSummary(),
                            ),
                            _ConditionsDisclosure(
                              id: 'sun',
                              title: 'Sun & twilight',
                              subtitle: 'Event times and darkness limits',
                              icon: HybridIcons.lucideSun,
                              iconColor: p.textSecondary,
                              child: const _SunEvents(),
                            ),
                          ] else if (page == 1) ...[
                            _MoonAnswer(
                              onPreview: () {
                                final target = moonTimelineKey.currentContext;
                                if (target != null) {
                                  Scrollable.ensureVisible(
                                    target,
                                    duration:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 180),
                                  ).then((_) {
                                    if (mounted) {
                                      moonTimelineFocus.requestFocus();
                                    }
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            const MoonCalendarSection(),
                            const SizedBox(height: 28),
                            Focus(
                              key: moonTimelineKey,
                              focusNode: moonTimelineFocus,
                              skipTraversal: true,
                              child: const NightBarSection(compact: true),
                            ),
                            const SizedBox(height: 12),
                            const _ReadingDisclosure(),
                            _ConditionsDisclosure(
                              id: 'moonDetails',
                              title: 'Moon details',
                              subtitle: 'Phase, intervals and how to read them',
                              icon: HybridIcons.lucideMoon,
                              child: const _MoonSummary(),
                            ),
                          ] else ...[
                            const HybridWeatherView(),
                          ],
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        // conditions.js render: Plan this night, only while another night
        // is viewed (browsing alone changes nothing).
        bottomNavigationBar: site.isDefaultLocation || browser.viewingPlanNight
            ? null
            : HybridApplyBar(
                buttonKey: const Key('nightMoon.planThisNight'),
                label: 'Plan this night',
                note: _savedPlan(context)
                    ? 'Create a copy for this night. The saved plan stays '
                          'unchanged.'
                    : 'Move this unsaved plan to this night.',
                onPressed: () async {
                  final date = browser.viewedDate;
                  if (await planThisNight(context, date)) {
                    browser.viewNight(date);
                  }
                },
              ),
      ),
    );
  }

  /// Whether the plan has been saved (Plan this night then copies it).
  static bool _savedPlan(BuildContext context) {
    final session = context.read<SessionPlanViewModel>().activeSession;
    return session != null &&
        !(session.status == SessionStatus.draft &&
            session.plannedAtUtc == null);
  }

  String _phaseSummary(NightBrowserViewModel browser) {
    final moon = browser.view.moon;
    final phase = moon.phaseName;
    return '${phase == null ? 'Phase unknown' : MoonText.phaseName(phase)} · '
        '${QuantityText.percent(moon.illuminationAtMidnight * 100)} lit';
  }
}

/// The Night answer (conditions.js `nightBody`): the dark time in the night
/// serif, then its span at the darkness limit with the limit itself.
class _NightAnswer extends StatelessWidget {
  const _NightAnswer();

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<NightBrowserViewModel>();
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final p = AppPalette.of(context);
    final view = browser.view;
    final dark = view.darkInterval;
    final limit = QuantityText.degrees(
      view.timeline.darkAtLimit?.thresholdDeg ?? -18,
    );
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: view.night.startUtc,
      zoneId: zoneId,
    );
    final quiet = AppTypography.caption.copyWith(
      height: 1.65,
      color: p.textSecondary,
    );
    final time = AppTypography.value.copyWith(
      height: 1.65,
      color: p.textSecondary,
    );
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              dark == null
                  ? 'No dark time this night'
                  : '${QuantityText.duration(dark.$2.difference(dark.$1))} '
                        'of dark time',
              key: const Key('nightMoon.answer'),
              style: AppTypography.answerHeading.copyWith(
                height: 1.3,
                color: p.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: dark == null
                  ? [
                      TextSpan(
                        text:
                            'The Sun never reaches the $limit darkness '
                            'limit. · Sun limit $limit',
                      ),
                    ]
                  : [
                      TextSpan(text: at(dark.$1), style: time),
                      const TextSpan(text: ' → '),
                      TextSpan(text: at(dark.$2), style: time),
                      TextSpan(text: ' · Sun limit $limit'),
                    ],
            ),
            key: const Key('nightMoon.answerSpan'),
            style: quiet,
          ),
        ],
      ),
    );
  }
}

/// The Moon answer (conditions.js `moonBody`, hybrid-refinement.css
/// `.moon-answer`): "Moon-free dark" in the night serif with the total at
/// its end (24/600), the intervals, what kind of night it is, the phase,
/// then Preview Moon through the night.
class _MoonAnswer extends StatelessWidget {
  const _MoonAnswer({required this.onPreview});

  final VoidCallback onPreview;

  /// night-model.js `classification`.
  static String classification(MoonFreeKind k) => switch (k) {
    MoonFreeKind.noDark => 'No dark time',
    MoonFreeKind.none => 'No moon-free dark',
    MoonFreeKind.allNight => 'Moon-free all dark time',
    MoonFreeKind.mixed => 'Split moon-free intervals',
    MoonFreeKind.evening => 'Moon-free in the evening',
    MoonFreeKind.morning => 'Moon-free in the morning',
    MoonFreeKind.middle => 'Moon-free in the middle of dark time',
  };

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<NightBrowserViewModel>();
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final p = AppPalette.of(context);
    final view = browser.view;
    final free = view.moonFree;
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: view.night.startUtc,
      zoneId: zoneId,
    );
    final big = switch (free.kind) {
      MoonFreeKind.noDark => 'No dark time',
      MoonFreeKind.none => 'None',
      _ => QuantityText.duration(free.moonFree),
    };
    final sub = switch (free.kind) {
      MoonFreeKind.noDark => 'So there is no moon-free dark interval.',
      MoonFreeKind.none =>
        'The Moon is above the horizon throughout dark time.',
      final k => classification(k),
    };
    final value = AppTypography.itemTitle.copyWith(
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: p.textPrimary,
    );
    final time = AppTypography.value.copyWith(
      height: 1.5,
      color: p.textPrimary,
    );
    final moon = view.moon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Moon-free dark',
                style: AppTypography.answerHeading.copyWith(
                  height: 1.3,
                  color: p.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.nudge),
              child: Text(
                big,
                key: const Key('nightMoon.moonFreeTotal'),
                style: AppTypography.screenTitle.copyWith(
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        if (free.kind != MoonFreeKind.noDark && free.kind != MoonFreeKind.none)
          for (final i in free.intervals)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: at(i.$1), style: time),
                  const TextSpan(text: ' → '),
                  TextSpan(text: at(i.$2), style: time),
                  if (free.intervals.length > 1)
                    TextSpan(
                      text:
                          ' · ${QuantityText.duration(i.$2.difference(i.$1))}',
                    ),
                ],
              ),
              style: value,
            ),
        Text(
          sub,
          key: const Key('nightMoon.moonFreeKind'),
          style: AppTypography.body.copyWith(
            height: 1.5,
            color: p.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${moon.phaseName == null ? 'Phase unknown' : MoonText.phaseName(moon.phaseName!)} · '
          '${QuantityText.percent(moon.illuminationAtMidnight * 100)} lit',
          style: AppTypography.caption.copyWith(
            height: 1.65,
            color: p.textSecondary,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: const Key('nightMoon.previewMoon'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
            onPressed: onPreview,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Flexible(child: Text('Preview Moon through the night')),
                const SizedBox(width: 8),
                HybridIcon(
                  HybridIcons.nightArrow,
                  size: MediaQuery.textScalerOf(context).scale(16),
                  strokeWidth: 1.6,
                  color: p.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadingDisclosure extends StatelessWidget {
  const _ReadingDisclosure();

  @override
  Widget build(BuildContext context) => const _ConditionsDisclosure(
    id: 'reading',
    title: 'Read the time browser',
    subtitle: 'Sky, Moon lanes and exact boundaries',
    child: NightReadingGuide(),
  );
}

/// A conditions disclosure (the Hybrid `.plan-disclosure`, 8 above).
class _ConditionsDisclosure extends StatelessWidget {
  const _ConditionsDisclosure({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon,
    this.iconColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final Widget child;
  final HybridIconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    child: CollapsibleSection(
      key: PageStorageKey('conditions.$id'),
      sectionKey: 'conditions.$id',
      title: title,
      summary: subtitle,
      icon: icon,
      iconColor: iconColor,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: child,
      ),
    ),
  );
}

/// conditions.js browseHeader `.date-browser`: the previous and next night
/// beside the viewed one ("Your plan's night" or "Viewing", 22/500, "Ends
/// …"); another night says it changes nothing, with the way back.
class _ViewedNightHeader extends StatelessWidget {
  const _ViewedNightHeader();

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<NightBrowserViewModel>();
    final p = AppPalette.of(context);
    final date = browser.viewedDate;
    final small = AppTypography.caption.copyWith(color: p.textSecondary);
    Widget arrow(String tip, HybridIconData icon, CalendarDate to) =>
        IconButton(
          tooltip: tip,
          onPressed: () => browser.viewNight(to),
          icon: HybridIcon(
            icon,
            size: MediaQuery.textScalerOf(context).scale(24),
            strokeWidth: 1.8,
            color: p.textPrimary,
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            arrow('Previous night', HybridIcons.previous, date.addDays(-1)),
            const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                button: true,
                hint: 'Choose a night',
                child: InkWell(
                  key: const Key('nightMoon.pickNight'),
                  borderRadius: BorderRadius.circular(6),
                  onTap: () async {
                    final picked = await pickNight(context, initial: date);
                    if (picked != null && context.mounted) {
                      browser.viewNight(picked);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // An inline span on the 16/24 line of its block.
                      Text(
                        browser.viewingPlanNight
                            ? 'Your plan’s night'
                            : 'Viewing',
                        textAlign: TextAlign.center,
                        style: small.copyWith(height: 24 / 13),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Night of ${NightTimeFormatter.eveningDate(date)}',
                        textAlign: TextAlign.center,
                        style: AppTypography.screenTitle.copyWith(
                          height: 1.35,
                          letterSpacing: -0.33,
                          color: p.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ends ${NightTimeFormatter.eveningDate(date.addDays(1))}',
                        textAlign: TextAlign.center,
                        style: small,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            arrow('Next night', HybridIcons.next, date.addDays(1)),
          ],
        ),
        if (!browser.viewingPlanNight) ...[
          const SizedBox(height: 12),
          Text(
            'Your plan: Night of '
            '${NightTimeFormatter.eveningDate(browser.planNight)}. Browsing '
            'changes nothing.',
            key: const Key('nightMoon.viewing'),
            style: small.copyWith(height: 1.6),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('nightMoon.backToPlan'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppSpacing.sm,
                  AppSpacing.itemGap,
                  AppSpacing.sm,
                ),
              ),
              onPressed: browser.viewPlanNight,
              child: const Text('Back to your plan’s night'),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Night of Tue, Nov 10 · Ljubljana" for a detail's header (S6.5).
String? detailContext(SessionNight? night, String? siteName) {
  if (night == null) return null;
  final date =
      '${AppWords.nightOf} '
      '${NightTimeFormatter.eveningDate(night.eveningDate)}';
  return siteName == null ? date : '$date · $siteName';
}

/// The night in two lines (S6.5): the dark span at the user's limit, and
/// when the Moon is up. Shared by the Night & Moon detail's summary and the
/// planner's Night row; facts only.
class NightSummary extends StatelessWidget {
  const NightSummary({
    super.key,
    required this.night,
    required this.dark,
    required this.moon,
    required this.zoneId,
    this.words,
    this.showMoon = true,
  });

  final SessionNight night;
  final SunThresholdResult? dark;
  final MoonConditions? moon;
  final String? zoneId;
  final bool showMoon;

  /// Words the plan's night (F18 A6), e.g. "not tonight" for another night.
  final String Function(String)? words;

  @override
  Widget build(BuildContext context) {
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: night.startUtc,
      zoneId: zoneId,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (dark case final d?)
          Text(
            (words ?? (s) => s)(DarkText.span(d, at)),
            key: const Key('nightSummary.dark'),
          ),
        if (showMoon && moon != null)
          Text(
            (words ?? (s) => s)(MoonText.up(moon!, at)),
            key: const Key('nightSummary.moon'),
          ),
      ],
    );
  }
}

/// conditions.css `.condition-facts`: the label (13/1.4 secondary) with
/// its value 3 below (15 at 1.45, tabular) in a grid of 150 px columns,
/// 18 apart in rows and 20 in columns.
class _ConditionFacts extends StatelessWidget {
  const _ConditionFacts(this.rows);

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth + 20) ~/ (150 * scale + 20);
        final perRow = columns.clamp(1, 4);
        final width = (constraints.maxWidth - 20 * (perRow - 1)) / perRow;
        return Wrap(
          spacing: 20,
          runSpacing: 18,
          children: [
            for (final (label, value) in rows)
              SizedBox(
                width: width,
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          height: 1.4,
                          color: p.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value,
                        style: AppTypography.value.copyWith(
                          height: 1.45,
                          color: p.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Sun & twilight's content (conditions.js `nightBody` events): each Sun
/// event as a dated instant in the site zone, then the twilight limits.
class _SunEvents extends StatelessWidget {
  const _SunEvents();

  @override
  Widget build(BuildContext context) {
    final view = context.watch<NightBrowserViewModel>().view;
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final p = AppPalette.of(context);
    final timeline = view.timeline;
    String at(DateTime utc) =>
        NightTimeFormatter.previewInstant(context, utc, zoneId: zoneId);
    String dusk(SunThresholdResult r) => switch (r) {
      SunCrossing(:final duskUtc?) => at(duskUtc),
      SunAlwaysBelow() => 'Below all night',
      _ => 'Not reached',
    };
    String dawn(SunThresholdResult r) => switch (r) {
      SunCrossing(:final dawnUtc?) => at(dawnUtc),
      SunAlwaysBelow() => 'Below all night',
      _ => 'Not reached',
    };
    final limit = QuantityText.degrees(
      timeline.darkAtLimit?.thresholdDeg ?? -18,
    );
    return Column(
      key: const Key('nightMoon.sunEvents'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _ConditionFacts([
          ('Sunset', dusk(timeline.sunriseSunset)),
          (AppWords.civilDusk, dusk(timeline.civilTwilight)),
          (AppWords.nauticalDusk, dusk(timeline.nauticalTwilight)),
          (AppWords.astronomicalDusk, dusk(timeline.astronomicalTwilight)),
          (AppWords.astronomicalDawn, dawn(timeline.astronomicalTwilight)),
          (AppWords.nauticalDawn, dawn(timeline.nauticalTwilight)),
          (AppWords.civilDawn, dawn(timeline.civilTwilight)),
          ('Sunrise', dawn(timeline.sunriseSunset)),
        ]),
        const SizedBox(height: 22),
        Text(
          'Twilight limits: civil −6°, nautical −12°, astronomical −18°. '
          'The selected dark limit is $limit.',
          style: AppTypography.caption.copyWith(
            height: 1.65,
            color: p.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// The Moon's summary (conditions.js `moonSummary`): its phase beside the
/// phase glyph, when it is up within the night, the moon-free dark time,
/// then what moon-free means. The closest approach to the target stays a
/// plain annotation (ADR-010), never an "impact".
class _MoonSummary extends StatelessWidget {
  const _MoonSummary();

  @override
  Widget build(BuildContext context) {
    final view = context.watch<NightBrowserViewModel>().view;
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final moon = view.moon;
    final night = view.night;
    final free = view.moonFree;
    String instant(DateTime utc) =>
        NightTimeFormatter.previewInstant(context, utc, zoneId: zoneId);
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: night.startUtc,
      zoneId: zoneId,
    );
    final label = AppTypography.caption.copyWith(color: p.textSecondary);
    final value = AppTypography.value.copyWith(
      height: 1.45,
      color: p.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final key = AppTypography.itemTitle.copyWith(color: p.textPrimary);
    final ups = moon.upIntervals;
    final phase = moon.phaseName == null
        ? 'Phase unknown'
        : MoonText.phaseName(moon.phaseName!);
    Widget range(String l, String v) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.nudge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(width: 42, child: Text(l, style: label)),
          Expanded(child: Text(v, style: value)),
        ],
      ),
    );
    return Column(
      key: const Key('nightMoon.moonSummary'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox.square(
              dimension: 48,
              child: CustomPaint(
                painter: MoonPhasePainter.hybrid(
                  theme,
                  phaseLongitudeDeg: moon.phaseLongitudeAtMidnightDeg,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase,
                    style: AppTypography.sectionHeading.copyWith(
                      color: p.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${QuantityText.percent(moon.illuminationAtMidnight * 100)} '
                    'illuminated at midnight',
                    style: label,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Moon above horizon', style: key),
        if (moon.riseSet.alwaysAbove)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.nudge),
            child: Text('All night', style: value),
          )
        else if (ups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.nudge),
            child: Text('Not during this night', style: value),
          )
        else
          for (final (from, until) in ups) ...[
            range(
              'From',
              from == night.startUtc ? 'Up at window start' : instant(from),
            ),
            range(
              'Until',
              until == night.endUtc ? 'Still up at window end' : instant(until),
            ),
          ],
        const SizedBox(height: 18),
        Text('Moon-free dark', style: key),
        const SizedBox(height: 3),
        Text(
          switch (free.kind) {
            MoonFreeKind.noDark => 'No dark time',
            MoonFreeKind.none => 'None',
            _ => QuantityText.duration(free.moonFree),
          },
          style: AppTypography.screenTitle.copyWith(
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: p.textPrimary,
          ),
        ),
        if (free.kind != MoonFreeKind.noDark && free.kind != MoonFreeKind.none)
          for (final i in free.intervals)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.hair),
              child: Text(
                '${at(i.$1)} → ${at(i.$2)}'
                '${free.intervals.length > 1 ? ' · ${QuantityText.duration(i.$2.difference(i.$1))}' : ''}',
                style: value,
              ),
            ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.hair),
          child: Text(
            switch (free.kind) {
              MoonFreeKind.noDark => 'So there is no moon-free dark interval.',
              MoonFreeKind.none =>
                'The Moon is above the horizon throughout dark time.',
              final k => _MoonAnswer.classification(k),
            },
            style: AppTypography.body.copyWith(
              height: 1.5,
              color: p.textSecondary,
            ),
          ),
        ),
        if (moon.closestApproachWhileBothUp case final a?) ...[
          const SizedBox(height: 12),
          Text(
            'Closest to the target while both are up: '
            '${QuantityText.degrees(a.separationDeg)} at ${at(a.instantUtc)}.',
            key: const Key('nightMoon.closestApproach'),
            style: AppTypography.caption.copyWith(
              height: 1.65,
              color: p.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 22),
        Text(
          'Moon-free means dark time with the Moon below the horizon. Phase '
          'alone does not determine it.',
          style: AppTypography.caption.copyWith(
            height: 1.65,
            color: p.textSecondary,
          ),
        ),
      ],
    );
  }
}
