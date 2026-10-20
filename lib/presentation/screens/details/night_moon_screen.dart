import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
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
import '../../widgets/sky_darkness_widget.dart';
import '../../widgets/weather_forecast_widget.dart';
import '../../widgets/forecast_nights_section.dart';

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
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2,
                color: AppPalette.of(context).textPrimary,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 12),
            ),
            labelStyle: text.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set an observing site',
                          style: text.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Night, Moon and weather belong to a place and its time zone.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton(
                          key: const Key('conditions.chooseSite'),
                          onPressed: () => context.push(AppRouter.selectSite),
                          child: const Text('Choose a site'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    key: ValueKey('conditions.page.$page'),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            SiteLabel.of(site) ?? 'Observing site',
                            key: const Key('detail.context'),
                            style: text.bodySmall,
                          ),
                          Text(
                            ContextLine.zoneRule(
                              browser.view.night.startUtc,
                              zoneId: site.displayZoneId,
                            ),
                            key: const Key('detail.zone'),
                            style: text.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const _ViewedNightHeader(),
                          const SizedBox(height: AppSpacing.lg),
                          if (page == 0) ...[
                            Text(
                              '${QuantityText.duration(browser.view.moonFree.dark)} of dark time',
                              style: text.headlineSmall?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            NightSummary(
                              night: browser.view.night,
                              dark: browser.view.timeline.darkAtLimit,
                              moon: browser.view.moon,
                              zoneId: site.displayZoneId,
                              showMoon: false,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const NightBarSection(compact: true),
                            const SizedBox(height: AppSpacing.lg),
                            const _ReadingDisclosure(),
                            _ConditionsDisclosure(
                              id: 'moonIntervals',
                              title: 'Moon intervals & phase',
                              subtitle: _phaseSummary(browser),
                              child: MoonSection(
                                view: browser.view,
                                compact: true,
                              ),
                            ),
                            _ConditionsDisclosure(
                              id: 'sun',
                              title: 'Sun & twilight',
                              subtitle: 'Event times and darkness limits',
                              child: NightTimelineSection(view: browser.view),
                            ),
                          ] else if (page == 1) ...[
                            Text(
                              'Moon-free dark',
                              style: text.headlineSmall?.copyWith(fontSize: 28),
                            ),
                            Text(
                              MoonText.moonFree(
                                browser.view.moonFree,
                                (utc) => NightTimeFormatter.instant(
                                  context,
                                  utc,
                                  windowStartUtc: browser.view.night.startUtc,
                                  zoneId: site.displayZoneId,
                                ),
                              ),
                            ),
                            Text(_phaseSummary(browser), style: text.bodySmall),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                key: const Key('nightMoon.previewMoon'),
                                onPressed: () {
                                  final target = moonTimelineKey.currentContext;
                                  if (target != null) {
                                    Scrollable.ensureVisible(
                                      target,
                                      duration:
                                          MediaQuery.disableAnimationsOf(
                                            context,
                                          )
                                          ? Duration.zero
                                          : const Duration(milliseconds: 180),
                                    ).then((_) {
                                      if (mounted)
                                        moonTimelineFocus.requestFocus();
                                    });
                                  }
                                },
                                child: const Text(
                                  'Preview Moon through the night ↓',
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const MoonCalendarSection(),
                            const SizedBox(height: AppSpacing.lg),
                            Focus(
                              key: moonTimelineKey,
                              focusNode: moonTimelineFocus,
                              skipTraversal: true,
                              child: const NightBarSection(compact: true),
                            ),
                            const _ReadingDisclosure(),
                            _ConditionsDisclosure(
                              id: 'moonDetails',
                              title: 'Moon details',
                              subtitle: 'Phase, intervals and how to read them',
                              child: MoonSection(
                                view: browser.view,
                                compact: true,
                              ),
                            ),
                          ] else ...[
                            const WeatherForecastWidget(showZone: false),
                            const ForecastNightsSection(),
                          ],
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _phaseSummary(NightBrowserViewModel browser) {
    final moon = browser.view.moon;
    final phase = moon.phaseName;
    return '${phase == null ? 'Phase unknown' : MoonText.phaseName(phase)} · '
        '${QuantityText.percent(moon.illuminationAtMidnight * 100)} lit';
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

class _ConditionsDisclosure extends StatelessWidget {
  const _ConditionsDisclosure({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String id;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    key: PageStorageKey('conditions.$id'),
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
    title: Text(title),
    subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    children: [child],
  );
}

class _ViewedNightHeader extends StatelessWidget {
  const _ViewedNightHeader();

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<NightBrowserViewModel>();
    final text = Theme.of(context).textTheme;
    final date = browser.viewedDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous night',
              onPressed: () => browser.viewNight(date.addDays(-1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  final picked = await pickNight(context, initial: date);
                  if (picked != null && context.mounted) {
                    browser.viewNight(picked);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      browser.viewingPlanNight
                          ? "Your plan's night"
                          : 'Viewing another night',
                      textAlign: TextAlign.center,
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Night of ${NightTimeFormatter.eveningDate(date)}',
                      textAlign: TextAlign.center,
                      style: text.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ends ${NightTimeFormatter.eveningDate(date.addDays(1))}',
                      textAlign: TextAlign.center,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next night',
              onPressed: () => browser.viewNight(date.addDays(1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (!browser.viewingPlanNight) ...[
          Text(
            NightBrowseText.viewing(
              NightTimeFormatter.eveningDate(date),
              NightTimeFormatter.eveningDate(browser.planNight),
            ),
            key: const Key('nightMoon.viewing'),
            style: text.bodySmall,
          ),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilledButton.tonal(
                key: const Key('nightMoon.planThisNight'),
                onPressed: () async {
                  if (await planThisNight(context, date)) {
                    browser.viewNight(date);
                  }
                },
                child: const Text('Plan this night'),
              ),
              TextButton(
                key: const Key('nightMoon.backToPlan'),
                onPressed: browser.viewPlanNight,
                child: const Text("Back to your plan's night"),
              ),
            ],
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
