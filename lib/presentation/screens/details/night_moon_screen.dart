import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/moon_conditions.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/session_night.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/detail_scaffold.dart';
import '../../shared/night_text.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/plan_night_phrase.dart';
import '../../shared/plan_this_night.dart';
import '../../viewmodels/night_browser_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../widgets/night_browser_sections.dart';
import '../../widgets/sky_darkness_widget.dart';

/// The Night & Moon detail (S6.5; ADR-019 §5, §9; UX-10; F15): a night —
/// the dark span at the user's limit (TD-051), the shared daylight,
/// twilight, darkness and Moon bar with a time slider, the Sun's timeline
/// with the standard twilight names, the Moon, and the month of Moon
/// nights. It opens on the plan's night; choosing another night in the
/// calendar only views it (D9 A), labelled against the plan's, and "Plan
/// this night" is the one action that adopts it (ADR-022 N11). Every time
/// is in the zone the header names once.
class NightMoonScreen extends StatelessWidget {
  const NightMoonScreen({super.key, this.computeMonth});

  /// Tests' direct month computation; the app uses an isolate.
  final MonthComputer? computeMonth;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (c) => NightBrowserViewModel(
      site: c.read<SiteViewModel>(),
      plan: c.read<SessionPlanViewModel>(),
      settings: c.read<SettingsViewModel>(),
      nowUtc: () => c.read<NightConditionsViewModel>().nowUtc,
      computeMonth: computeMonth,
    ),
    child: const _NightMoonBody(),
  );
}

class _NightMoonBody extends StatelessWidget {
  const _NightMoonBody();

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final site = context.watch<SiteViewModel>();
    final browser = context.watch<NightBrowserViewModel>();
    if (plan.sessionNight == null) {
      return DetailScaffold(
        title: 'Night & Moon',
        context: null,
        summary: const Text('Set a site to see the night.'),
        sections: const [],
      );
    }
    final view = browser.view;
    final night = view.night;
    final viewed = NightTimeFormatter.eveningDate(browser.viewedDate);
    final planNight = NightTimeFormatter.eveningDate(browser.planNight);
    return DetailScaffold(
      title: 'Night & Moon',
      context: detailContext(night, site.locationName),
      zoneRule: ContextLine.zoneRule(
        night.startUtc,
        zoneId: site.displayZoneId,
      ),
      summary: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // N11: the viewed night against the plan's, and the one adopt
          // action.
          if (!browser.viewingPlanNight) ...[
            Text(
              NightBrowseText.viewing(viewed, planNight),
              key: const Key('nightMoon.viewing'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                FilledButton.tonal(
                  key: const Key('nightMoon.planThisNight'),
                  onPressed: () async {
                    final date = browser.viewedDate;
                    if (await planThisNight(context, date)) {
                      browser.viewNight(date);
                    }
                  },
                  child: const Text('Plan this night'),
                ),
                TextButton(
                  key: const Key('nightMoon.backToPlan'),
                  onPressed: browser.viewPlanNight,
                  child: Text("Back to your plan's night"),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          NightSummary(
            night: night,
            dark: view.timeline.darkAtLimit,
            moon: view.moon,
            zoneId: site.displayZoneId,
            // The viewed night in the words ("not tonight" only tonight).
            words: (t) =>
                PlanNightPhrase.apply(t, browser.viewedDate, plan.tonightKey),
          ),
        ],
      ),
      sections: [
        const NightBarSection(),
        NightTimelineSection(view: view),
        MoonSection(view: view),
        const MoonCalendarSection(),
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
  });

  final SessionNight night;
  final SunThresholdResult? dark;
  final MoonConditions? moon;
  final String? zoneId;

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
        if (moon case final m?)
          Text(
            (words ?? (s) => s)(MoonText.up(m, at)),
            key: const Key('nightSummary.moon'),
          ),
      ],
    );
  }
}
