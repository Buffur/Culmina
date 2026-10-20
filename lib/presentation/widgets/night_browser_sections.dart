import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/moon_conditions.dart';
import '../../domain/services/moon_calendar.dart';
import '../../domain/services/night_view.dart';
import '../shared/night_text.dart';
import '../shared/sky_color_interpolation.dart';
import '../shared/night_time_formatter.dart';
import '../viewmodels/night_browser_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';

/// The viewed night's daylight, twilight, darkness and Moon on one bar,
/// with the time slider (F15 A1/A5; AM-01 SP07): the primary explanation
/// of the night. The bar's segments come from [NightView.segments]; the
/// Moon-up and Moon-free lanes have distinct positions and thicknesses. Moving the slider changes viewing state only.
class NightBarSection extends StatelessWidget {
  const NightBarSection({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<NightBrowserViewModel>();
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final view = browser.view;
    final night = view.night;
    final text = Theme.of(context).textTheme;
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: night.startUtc,
      zoneId: zoneId,
    );
    final n = view.sun.altitudesDeg.length;
    final cursor = browser.cursor;
    final index = view.indexOf(cursor.instantUtc);
    final wall = NightTimeFormatter.wallClock(
      cursor.instantUtc,
      zoneId: zoneId,
    );
    final date = NightTimeFormatter.eveningDate(
      CalendarDate.fromDateTimeFields(wall),
    );
    final zone = NightTimeFormatter.zoneCaption(
      cursor.instantUtc,
      zoneId: zoneId,
    );
    return Column(
      key: const Key('nightMoon.bar'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text('Preview time', style: text.bodySmall),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            Text('${at(cursor.instantUtc)}, $date', style: text.bodySmall),
            OutlinedButton(
              key: Key(browser.nowInView ? 'nightMoon.now' : 'nightMoon.start'),
              onPressed: browser.resetCursor,
              child: Text(
                browser.nowInView ? 'Return to now' : 'Return to night start',
              ),
            ),
          ],
        ),
        SizedBox(
          height: 56,
          child: Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  label:
                      'Night bar: ${NightBrowseText.bar(view.segments, view.limitDeg, at)}',
                  excludeSemantics: true,
                  child: CustomPaint(
                    painter: NightBarPainter(
                      view: view,
                      cursorIndex: index,
                      palette: AppPalette.of(context),
                      hybrid: Theme.of(context).extension<HybridTokens>(),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 0,
                    thumbColor: AppPalette.of(context).textPrimary,
                    activeTrackColor: HybridTokens.transparent,
                    inactiveTrackColor: HybridTokens.transparent,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 4,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    key: const Key('nightMoon.slider'),
                    padding: EdgeInsets.zero,
                    value: index.toDouble(),
                    min: 0,
                    max: (n - 1).toDouble(),
                    divisions: n - 1,
                    label: at(cursor.instantUtc),
                    semanticFormatterCallback: (v) {
                      final instant = night.startUtc.add(
                        Duration(minutes: v.round() * 5),
                      );
                      return '${at(instant)}: ${NightBrowseText.cursor(view.at(instant), view.limitDeg, at)}';
                    },
                    onChanged: (v) => browser.setCursor(
                      night.startUtc.add(Duration(minutes: v.round() * 5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(child: Text(at(night.startUtc), style: text.bodySmall)),
            Text(at(night.endUtc), style: text.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Drag to preview · arrow keys step 5 min.', style: text.bodySmall),
        _Legend(view: view, compact: compact),
        if (compact) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            cursor.dark
                ? cursor.moonUp
                      ? 'Dark · Moon above horizon'
                      : 'Moon-free dark'
                : '${NightBrowseText.sky(cursor.sky, view.limitDeg)} · '
                      'Moon ${cursor.moonUp ? 'above' : 'below'} horizon',
            key: const Key('nightMoon.cursorState'),
            style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Semantics(
            liveRegion: true,
            child: Text(
              _compactCursor(view, cursor, at),
              key: const Key('nightMoon.cursorSummary'),
              style: text.bodySmall,
            ),
          ),
        ] else
          Semantics(
            liveRegion: true,
            child: Text(
              '${at(cursor.instantUtc)}, $date ($zone): '
              '${NightBrowseText.cursor(cursor, view.limitDeg, at)}',
              key: const Key('nightMoon.cursor'),
              style: text.bodyMedium,
            ),
          ),
      ],
    );
  }

  static String _compactCursor(
    NightView view,
    NightInstant cursor,
    String Function(DateTime) at,
  ) {
    final instant = cursor.instantUtc;
    if (cursor.dark && !cursor.moonUp) {
      for (final interval in view.moonFree.intervals) {
        if (!instant.isBefore(interval.$1) && instant.isBefore(interval.$2)) {
          return 'Moon-free for ${QuantityText.duration(interval.$2.difference(instant))}'
              ' · until ${at(interval.$2)}';
        }
      }
    }
    final change = cursor.darkChangeUtc;
    if (cursor.dark) {
      return change == null
          ? 'Dark until the night ends'
          : '${QuantityText.duration(change.difference(instant))} remaining';
    }
    return change != null
        ? 'Darkness in ${QuantityText.duration(change.difference(instant))}'
        : view.moonFree.dark == Duration.zero
        ? 'No dark time at the selected ${QuantityText.degrees(view.limitDeg)} limit.'
        : 'Dark time has ended for this night.';
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.view, required this.compact});

  final NightView view;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    Widget chip(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 16, height: 12, child: swatch),
        const SizedBox(width: AppSpacing.xs),
        // Wraps at large text rather than overflowing (trap 17).
        Flexible(child: Text(label, style: style)),
      ],
    );
    final hybrid = Theme.of(context).extension<HybridTokens>();
    Color depth(SkyState s) => switch (s) {
      SkyState.daylight => hybrid?.skyDay ?? p.chartDay,
      SkyState.civil => hybrid?.skyCivil ?? p.chartTwilight,
      SkyState.nautical => hybrid?.skyNautical ?? p.chartTwilight,
      SkyState.astronomical => hybrid?.skyAstronomical ?? p.chartTwilight,
      SkyState.dark => hybrid?.skyDark ?? p.chartDark,
    };
    bool present(SkyState state) => view.segments.any((s) => s.sky == state);
    return Wrap(
      key: Key(compact ? 'nightMoon.legend' : 'nightMoon.readingLegend'),
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        if (present(SkyState.daylight))
          chip(ColoredBox(color: depth(SkyState.daylight)), 'Daylight'),
        if (compact) ...[
          if ([
            SkyState.civil,
            SkyState.nautical,
            SkyState.astronomical,
          ].any(present))
            chip(ColoredBox(color: depth(SkyState.nautical)), 'Twilight'),
        ] else ...[
          for (final (state, label) in [
            (SkyState.civil, 'Civil twilight'),
            (SkyState.nautical, 'Nautical twilight'),
            (SkyState.astronomical, 'Astronomical twilight'),
          ])
            if (present(state)) chip(ColoredBox(color: depth(state)), label),
        ],
        if (present(SkyState.dark))
          chip(
            ColoredBox(color: depth(SkyState.dark)),
            compact
                ? 'Dark'
                : 'Dark · Sun below ${view.limitDeg.toStringAsFixed(0)}°',
          )
        else
          Text('No dark time at the selected limit.', style: style),
        chip(
          ColoredBox(color: hybrid?.moonUp ?? p.chartMoon),
          'Moon above horizon',
        ),
        chip(
          ColoredBox(color: hybrid?.moonFree ?? p.textPrimary),
          'Moon-free dark',
        ),
        if (!compact)
          Text(
            'Sky colour blends between calculated Sun states. It is not measured sky brightness.',
            style: style,
          ),
      ],
    );
  }
}

/// The complete key remains reachable behind Hybrid's reading disclosure.
class NightReadingGuide extends StatelessWidget {
  const NightReadingGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<NightBrowserViewModel>();
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final view = browser.view;
    final cursor = browser.cursor;
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: view.night.startUtc,
      zoneId: zoneId,
    );
    final wall = NightTimeFormatter.wallClock(
      cursor.instantUtc,
      zoneId: zoneId,
    );
    final date = NightTimeFormatter.eveningDate(
      CalendarDate.fromDateTimeFields(wall),
    );
    final zone = NightTimeFormatter.zoneCaption(
      cursor.instantUtc,
      zoneId: zoneId,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Legend(view: view, compact: false),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${at(cursor.instantUtc)}, $date ($zone): '
          '${NightBrowseText.cursor(cursor, view.limitDeg, at)}',
          key: const Key('nightMoon.cursor'),
        ),
      ],
    );
  }
}

/// Paints [view]: a sky gradient, separate Moon-up and Moon-free lanes,
/// and the slider's instant as a line. Public for tests.
class NightBarPainter extends CustomPainter {
  NightBarPainter({
    required this.view,
    required this.cursorIndex,
    required this.palette,
    this.hybrid,
  });

  final NightView view;
  final int cursorIndex;
  final AppPalette palette;
  final HybridTokens? hybrid;

  static Color skyColor(SkyState s, AppPalette p) => switch (s) {
    SkyState.daylight => p.chartDay,
    SkyState.civil => p.chartTwilight,
    SkyState.nautical => Color.lerp(p.chartTwilight, p.chartDark, 1 / 3)!,
    SkyState.astronomical => Color.lerp(p.chartTwilight, p.chartDark, 2 / 3)!,
    SkyState.dark => p.chartDark,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final night = view.night;
    final total = night.endUtc.difference(night.startUtc).inMinutes;
    double x(DateTime t) =>
        (t.difference(night.startUtc).inMinutes / total * size.width).clamp(
          0.0,
          size.width,
        );
    final tokens =
        hybrid ??
        (palette == AppPalette.field
            ? HybridTokens.field
            : palette == AppPalette.dark
            ? HybridTokens.dark
            : HybridTokens.light);
    Color color(SkyState state) => switch (state) {
      SkyState.daylight => tokens.skyDay,
      SkyState.civil => tokens.skyCivil,
      SkyState.nautical => tokens.skyNautical,
      SkyState.astronomical => tokens.skyAstronomical,
      SkyState.dark => tokens.skyDark,
    };
    final groups = <(DateTime, DateTime, SkyState)>[];
    for (final segment in view.segments) {
      if (groups.isNotEmpty &&
          groups.last.$3 == segment.sky &&
          groups.last.$2 == segment.startUtc) {
        final previous = groups.removeLast();
        groups.add((previous.$1, segment.endUtc, segment.sky));
      } else {
        groups.add((segment.startUtc, segment.endUtc, segment.sky));
      }
    }
    final knots = <(double, Color)>[];
    void push(double position, Color c) {
      if (knots.isNotEmpty && knots.last.$1 == position) knots.removeLast();
      knots.add((position, c));
    }

    for (var i = 0; i < groups.length; i++) {
      final g = groups[i];
      final start = x(g.$1) / size.width, end = x(g.$2) / size.width;
      final c = color(g.$3);
      if (i == 0) push(start, c);
      if (g.$3 == SkyState.dark) {
        push(start, c);
        push(end, c);
      } else {
        push((start + end) / 2, c);
      }
      if (i == groups.length - 1) push(end, c);
    }
    final stops = <double>[];
    final colors = <Color>[];
    for (var i = 0; i < knots.length; i++) {
      final k = knots[i];
      stops.add(k.$1.clamp(0.0, 1.0));
      colors.add(k.$2);
      if (i + 1 < knots.length && k.$2 != knots[i + 1].$2) {
        final next = knots[i + 1];
        for (var step = 1; step < 8; step++) {
          final t = step / 8;
          stops.add((k.$1 + (next.$1 - k.$1) * t).clamp(0.0, 1.0));
          colors.add(mixSkyColors(k.$2, next.$2, t * t * (3 - 2 * t)));
        }
      }
    }
    final skyRect = Rect.fromLTWH(0, 0, size.width, 16);
    final skyPaint = Paint()..color = tokens.skyDay;
    if (colors.length >= 2) {
      skyPaint.shader = LinearGradient(
        colors: colors,
        stops: stops,
      ).createShader(skyRect);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(skyRect, const Radius.circular(3)),
      skyPaint,
    );
    final bracket = Paint()
      ..color = tokens.moonFree
      ..strokeWidth = 2;
    for (final g in groups.where((g) => g.$3 == SkyState.dark)) {
      final left = x(g.$1), right = x(g.$2);
      canvas.drawLine(Offset(left, 20), Offset(left, 26), bracket);
      canvas.drawLine(Offset(left, 26), Offset(right, 26), bracket);
      canvas.drawLine(Offset(right, 26), Offset(right, 20), bracket);
    }
    for (final y in [32.0, 45.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, y, size.width, 10),
          const Radius.circular(3),
        ),
        Paint()..color = palette.border,
      );
    }
    for (final g in view.segments.where((g) => g.moonUp)) {
      canvas.drawRect(
        Rect.fromLTRB(x(g.startUtc), 35, x(g.endUtc), 39),
        Paint()..color = tokens.moonUp,
      );
    }
    for (final span in view.moonFree.intervals) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x(span.$1), 46, x(span.$2), 54),
          const Radius.circular(2),
        ),
        Paint()..color = tokens.moonFree,
      );
    }
    final cx = x(night.startUtc.add(Duration(minutes: cursorIndex * 5)))
        .clamp(0.0, size.width);
    canvas.drawLine(
      Offset(cx, 0),
      Offset(cx, size.height),
      Paint()
        ..color = palette.textPrimary
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(NightBarPainter old) =>
      old.view != view ||
      old.cursorIndex != cursorIndex ||
      old.palette != palette ||
      old.hybrid != hybrid;
}

/// The month of Moon nights (F15 A1; ADR-022 N4/N5/N10): per night its
/// phase, drawn from the phase longitude, and its moon-free dark time.
/// Computed in an isolate and cached; tapping a night views it (browsing
/// only). At large text the month becomes a readable week list rather
/// than squeezed cells.
class MoonCalendarSection extends StatelessWidget {
  const MoonCalendarSection({super.key});

  /// Large text switches to the week view (SP07).
  static const weekViewScale = 1.5;

  /// "Thu 17 Dec: Waxing gibbous, 82 % lit; moon-free dark 3 h 10 min".
  static String dayLabel(MoonCalendarDay d) {
    final phase = d.phase == null
        ? 'phase unknown'
        : MoonText.phaseName(d.phase!);
    final lit = QuantityText.percent(d.illumination * 100);
    final free = switch (d.moonFree.kind) {
      MoonFreeKind.noDark => 'no dark time',
      MoonFreeKind.none => 'no moon-free dark time',
      _ => 'moon-free dark ${QuantityText.duration(d.moonFree.moonFree)}',
    };
    return '${NightTimeFormatter.eveningDate(d.date)}: $phase, $lit lit; $free';
  }

  static String _short(MoonCalendarDay d) => switch (d.moonFree.kind) {
    MoonFreeKind.noDark => 'no dark',
    _ => QuantityText.duration(d.moonFree.moonFree),
  };

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<NightBrowserViewModel>();
    final text = Theme.of(context).textTheme;
    final (year, month) = browser.month;
    final days = browser.monthDays;
    final week = MediaQuery.textScalerOf(context).scale(1) >= weekViewScale;
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final heading = Semantics(
      header: true,
      child: Text(
        'Moon calendar',
        style: text.titleMedium?.copyWith(fontSize: 18),
      ),
    );
    final monthControls = Row(
      children: [
        IconButton(
          key: const Key('nightMoon.prevMonth'),
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left),
          onPressed: () => browser.showMonth(-1),
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              '${months[month - 1]} $year',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
          ),
        ),
        IconButton(
          key: const Key('nightMoon.nextMonth'),
          tooltip: 'Next month',
          icon: const Icon(Icons.chevron_right),
          onPressed: () => browser.showMonth(1),
        ),
      ],
    );
    return Column(
      key: const Key('nightMoon.calendar'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (week)
          heading
        else
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 360
                ? Row(
                    children: [
                      heading,
                      const SizedBox(width: 8),
                      Expanded(child: monthControls),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [heading, monthControls],
                  ),
          ),
        Text(
          'Moon-free dark time per night. Viewing a night changes no plan.',
          style: text.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        if (browser.monthError != null)
          Column(
            children: [
              const Text(
                'The month could not be computed.',
                key: Key('nightMoon.calendarError'),
              ),
              TextButton(
                onPressed: () => browser.retryCalendar(year, month),
                child: const Text('Retry month'),
              ),
            ],
          )
        else if (days == null)
          const LinearProgressIndicator(key: Key('nightMoon.calendarLoading'))
        else if (week)
          _WeekList(days: days, browser: browser)
        else
          _MonthGrid(days: days, browser: browser),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.days, required this.browser});

  final List<MoonCalendarDay> days;
  final NightBrowserViewModel browser;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final lead =
        DateTime.utc(days.first.date.year, days.first.date.month, 1).weekday -
        1; // Monday first
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (final d in days) _DayCell(day: d, browser: browser),
    ];
    final scaler = MediaQuery.textScalerOf(context);
    return Column(
      children: [
        Row(
          children: [
            for (final n in names)
              Expanded(
                child: Center(
                  child: ExcludeSemantics(child: Text(n, style: style)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final theme = Theme.of(context);
            final width = (constraints.maxWidth - 24) / 7 - 4;
            double height(String text, TextStyle? style) {
              final painter = TextPainter(
                text: TextSpan(
                  text: text,
                  style: DefaultTextStyle.of(context).style.merge(style),
                ),
                textDirection: Directionality.of(context),
                textScaler: scaler,
              )..layout(maxWidth: width);
              final result = painter.height;
              painter.dispose();
              return result;
            }

            final extent = days.fold<double>(72, (largest, day) {
              final date =
                  '${day.date.day}${day.date == browser.planNight ? ' •' : ''}';
              return math.max(
                largest,
                36 +
                    height(
                      date,
                      theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: day.date == browser.viewedDate
                            ? FontWeight.bold
                            : null,
                      ),
                    ) +
                    height(
                      MoonCalendarSection._short(day),
                      theme.textTheme.labelSmall?.copyWith(
                        fontSize: HybridTokens.calendarCaptionSize,
                        height: 1.4,
                      ),
                    ),
              );
            });
            return GridView.count(
              key: const Key('nightMoon.month'),
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              mainAxisExtent: extent.ceilToDouble(),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: cells,
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.browser});

  final MoonCalendarDay day;
  final NightBrowserViewModel browser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final viewed = day.date == browser.viewedDate;
    final plan = day.date == browser.planNight;
    return Semantics(
      button: true,
      selected: viewed,
      // The InkWell's own semantics are excluded with its label, so the
      // tap is given here, or a double tap would do nothing.
      enabled: true,
      onTap: () => browser.viewNight(day.date),
      excludeSemantics: true,
      label:
          '${MoonCalendarSection.dayLabel(day)}${plan ? '; your plan\'s night' : ''}',
      child: InkWell(
        key: Key('nightMoon.day.${day.date.toIso8601String()}'),
        onTap: () => browser.viewNight(day.date),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
          decoration: BoxDecoration(
            color: viewed
                ? theme.extension<HybridTokens>()?.selection ??
                      theme.colorScheme.surfaceContainerHighest
                : HybridTokens.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: viewed ? p.controlBorder : HybridTokens.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.date.day}${plan ? ' •' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: viewed ? FontWeight.bold : null,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(
                  painter: MoonPhasePainter(
                    phaseLongitudeDeg: day.phaseLongitudeDeg,
                    lit: p.moon,
                    dark: p.chartGrid,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                MoonCalendarSection._short(day),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: HybridTokens.calendarCaptionSize,
                  height: 1.4,
                  color: p.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large text: the viewed night's week as a list, each night's facts in
/// words (SP07), with the previous and next week.
class _WeekList extends StatefulWidget {
  const _WeekList({required this.days, required this.browser});

  final List<MoonCalendarDay> days;
  final NightBrowserViewModel browser;

  @override
  State<_WeekList> createState() => _WeekListState();
}

class _WeekListState extends State<_WeekList> {
  late CalendarDate _start;
  late CalendarDate _observedView;

  void _followViewedNight() {
    _observedView = widget.browser.viewedDate;
    final anchor = widget.days.any((d) => d.date == _observedView)
        ? _observedView
        : widget.days.first.date;
    final weekday = anchor.atUtcHour(12).weekday;
    _start = anchor.addDays(1 - weekday);
  }

  @override
  void initState() {
    super.initState();
    _followViewedNight();
  }

  @override
  void didUpdateWidget(_WeekList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.browser.viewedDate != _observedView ||
        !identical(widget.days, oldWidget.days)) {
      _followViewedNight();
    }
  }

  @override
  Widget build(BuildContext context) {
    final browser = widget.browser;
    final viewed = browser.viewedDate;
    final dates = [for (var i = 0; i < 7; i++) _start.addDays(i)];
    final months = {for (final date in dates) (date.year, date.month)};
    final available = <CalendarDate, MoonCalendarDay>{};
    var loading = false;
    var failed = false;
    for (final (year, month) in months) {
      final days = browser.calendarDays(year, month);
      if (browser.calendarError(year, month) != null) {
        failed = true;
      } else if (days == null) {
        loading = true;
      } else {
        for (final day in days) {
          available[day.date] = day;
        }
      }
    }
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final selection =
        theme.extension<HybridTokens>()?.selection ??
        theme.colorScheme.surfaceContainerHighest;
    return Column(
      key: const Key('nightMoon.week'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('nightMoon.prevWeek'),
              tooltip: 'Previous Moon week',
              onPressed: () => setState(() => _start = _start.addDays(-7)),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  '${NightTimeFormatter.eveningDate(dates.first)}'
                  ' – ${NightTimeFormatter.eveningDate(dates.last)}',
                  key: const Key('nightMoon.weekRange'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            IconButton(
              key: const Key('nightMoon.nextWeek'),
              tooltip: 'Next Moon week',
              onPressed: () => setState(() => _start = _start.addDays(7)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (failed)
          Column(
            children: [
              const Text(
                'The week could not be computed.',
                key: Key('nightMoon.weekError'),
              ),
              TextButton(
                onPressed: () {
                  for (final (year, month) in months) {
                    if (browser.calendarError(year, month) != null) {
                      browser.retryCalendar(year, month);
                    }
                  }
                },
                child: const Text('Retry week'),
              ),
            ],
          )
        else if (loading)
          const LinearProgressIndicator(key: Key('nightMoon.weekLoading'))
        else
          for (final date in dates)
            if (available[date] case final d?)
              Semantics(
                button: true,
                selected: d.date == viewed,
                child: Material(
                  color: d.date == viewed
                      ? selection
                      : HybridTokens.transparent,
                  child: ListTile(
                    key: Key('nightMoon.day.${d.date.toIso8601String()}'),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    selected: d.date == viewed,
                    selectedColor: p.textPrimary,
                    leading: SizedBox(
                      width: 20,
                      height: 20,
                      child: CustomPaint(
                        painter: MoonPhasePainter(
                          phaseLongitudeDeg: d.phaseLongitudeDeg,
                          lit: p.moon,
                          dark: p.chartGrid,
                        ),
                      ),
                    ),
                    title: Text(
                      MoonCalendarSection.dayLabel(d),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    subtitle: d.date == browser.planNight
                        ? const Text("Your plan's night")
                        : null,
                    onTap: () => browser.viewNight(d.date),
                  ),
                ),
              ),
      ],
    );
  }
}

/// A small Moon disc lit from the phase longitude (0 new, 180 full; waxing
/// lit on the right). Unknown draws only the outline.
class MoonPhasePainter extends CustomPainter {
  MoonPhasePainter({
    required this.phaseLongitudeDeg,
    required this.lit,
    required this.dark,
  });

  final double? phaseLongitudeDeg;
  final Color lit;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2 - 1;
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke,
    );
    final l = phaseLongitudeDeg;
    if (l == null) return;
    final rad = (l % 360) * math.pi / 180;
    final waxing = (l % 360) < 180;
    // The terminator's half-width: cos of the phase angle.
    final k = math.cos(rad) * r;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..arcToPoint(
        Offset(c.dx, c.dy + r),
        radius: Radius.circular(r),
        clockwise: waxing,
      )
      ..arcToPoint(
        Offset(c.dx, c.dy - r),
        radius: Radius.elliptical(k.abs(), r),
        clockwise: waxing ? k > 0 : k < 0,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = lit);
  }

  @override
  bool shouldRepaint(MoonPhasePainter old) =>
      old.phaseLongitudeDeg != phaseLongitudeDeg ||
      old.lit != lit ||
      old.dark != dark;
}
