import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/moon_conditions.dart';
import '../../domain/services/moon_calendar.dart';
import '../../domain/services/night_view.dart';
import '../shared/night_text.dart';
import '../shared/night_time_formatter.dart';
import '../viewmodels/night_browser_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';

/// The viewed night's daylight, twilight, darkness and Moon on one bar,
/// with the time slider (F15 A1/A5; AM-01 SP07): the primary explanation
/// of the night. The bar's segments come from [NightView.segments]; the
/// Moon-up row is hatched as well as coloured, so it reads in field mode
/// too. Moving the slider changes viewing state only.
class NightBarSection extends StatelessWidget {
  const NightBarSection({super.key});

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
          child: Text('The night at a glance', style: text.titleSmall),
        ),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          label:
              'Night bar: ${NightBrowseText.bar(view.segments, view.limitDeg, at)}',
          excludeSemantics: true,
          child: SizedBox(
            height: 36,
            child: CustomPaint(
              painter: NightBarPainter(
                view: view,
                cursorIndex: index,
                palette: AppPalette.of(context),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: Text(at(night.startUtc), style: text.bodySmall)),
            Text(at(night.endUtc), style: text.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const _Legend(),
        Slider(
          key: const Key('nightMoon.slider'),
          value: index.toDouble(),
          min: 0,
          max: (n - 1).toDouble(),
          divisions: n - 1,
          label: at(cursor.instantUtc),
          // Each step's own instant, so a screen reader announces the
          // time a step up or down would go to.
          semanticFormatterCallback: (v) =>
              at(night.startUtc.add(Duration(minutes: v.round() * 5))),
          onChanged: (v) => browser.setCursor(
            night.startUtc.add(Duration(minutes: v.round() * 5)),
          ),
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            '${at(cursor.instantUtc)}, $date ($zone): '
            '${NightBrowseText.cursor(cursor, view.limitDeg, at)}',
            key: const Key('nightMoon.cursor'),
            style: text.bodyMedium,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: Key(browser.nowInView ? 'nightMoon.now' : 'nightMoon.start'),
            onPressed: browser.resetCursor,
            child: Text(browser.nowInView ? 'Now' : 'Night start'),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

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
    Color depth(SkyState s) => NightBarPainter.skyColor(s, p);
    return Wrap(
      key: const Key('nightMoon.legend'),
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        chip(ColoredBox(color: depth(SkyState.daylight)), 'Daylight'),
        chip(ColoredBox(color: depth(SkyState.nautical)), 'Twilight'),
        chip(ColoredBox(color: depth(SkyState.dark)), 'Dark'),
        chip(
          CustomPaint(painter: _HatchPainter(p.chartMoon)),
          'Moon above the horizon (hatched)',
        ),
      ],
    );
  }
}

/// Paints [view]: the sky state along the top, the Moon-up time hatched
/// along the bottom, and the slider's instant as a line. Public for tests.
class NightBarPainter extends CustomPainter {
  NightBarPainter({
    required this.view,
    required this.cursorIndex,
    required this.palette,
  });

  final NightView view;
  final int cursorIndex;
  final AppPalette palette;

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
        t.difference(night.startUtc).inMinutes / total * size.width;
    final sky = size.height * 0.6;
    for (final g in view.segments) {
      final r = Rect.fromLTRB(x(g.startUtc), 0, x(g.endUtc), sky);
      canvas.drawRect(r, Paint()..color = skyColor(g.sky, palette));
      if (g.moonUp) {
        final m = Rect.fromLTRB(x(g.startUtc), sky, x(g.endUtc), size.height);
        canvas.save();
        canvas.clipRect(m);
        _HatchPainter.hatch(canvas, m, palette.chartMoon);
        canvas.restore();
      }
    }
    final cx = x(night.startUtc.add(Duration(minutes: cursorIndex * 5)))
        .clamp(0.0, size.width);
    canvas.drawLine(
      Offset(cx, 0),
      Offset(cx, size.height),
      Paint()
        ..color = palette.chartNow
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(NightBarPainter old) =>
      old.view != view ||
      old.cursorIndex != cursorIndex ||
      old.palette != palette;
}

class _HatchPainter extends CustomPainter {
  _HatchPainter(this.color);

  final Color color;

  static void hatch(Canvas canvas, Rect r, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    for (var d = r.left - r.height; d < r.right; d += 5) {
      canvas.drawLine(Offset(d, r.bottom), Offset(d + r.height, r.top), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    hatch(canvas, Offset.zero & size, color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.color != color;
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
    MoonFreeKind.none => '0 h',
    _ => '${(d.moonFree.moonFree.inMinutes / 60).toStringAsFixed(1)} h',
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
    return Column(
      key: const Key('nightMoon.calendar'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
                  'Moon nights · ${months[month - 1]} $year',
                  textAlign: TextAlign.center,
                  style: text.titleSmall,
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
        ),
        Text(
          'Moon-free dark hours per night. Viewing a night changes no plan.',
          style: text.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (browser.monthError != null)
          const Text(
            'The month could not be computed.',
            key: Key('nightMoon.calendarError'),
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
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final cells = <Widget>[
      for (final n in names)
        Center(
          child: ExcludeSemantics(child: Text(n, style: style)),
        ),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (final d in days) _DayCell(day: d, browser: browser),
    ];
    return GridView.count(
      key: const Key('nightMoon.month'),
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.8,
      children: cells,
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
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: viewed ? theme.colorScheme.primary : p.chartGrid,
              width: viewed ? 2 : 0.5,
            ),
          ),
          // Never clipped in a narrow cell; large text uses the week list.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${day.date.day}${plan ? ' •' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: viewed ? FontWeight.bold : null,
                  ),
                ),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CustomPaint(
                    painter: MoonPhasePainter(
                      phaseLongitudeDeg: day.phaseLongitudeDeg,
                      lit: p.moon,
                      dark: p.chartGrid,
                    ),
                  ),
                ),
                Text(
                  MoonCalendarSection._short(day),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Large text: the viewed night's week as a list, each night's facts in
/// words (SP07), with the previous and next week.
class _WeekList extends StatelessWidget {
  const _WeekList({required this.days, required this.browser});

  final List<MoonCalendarDay> days;
  final NightBrowserViewModel browser;

  @override
  Widget build(BuildContext context) {
    final viewed = browser.viewedDate;
    final inMonth = days.any((d) => d.date == viewed);
    final anchor = inMonth ? viewed : days.first.date;
    final start = math.max(0, days.indexWhere((d) => d.date == anchor) - 3);
    final week = days.skip(math.min(start, days.length - 7)).take(7);
    return Column(
      key: const Key('nightMoon.week'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final d in week)
          ListTile(
            key: Key('nightMoon.day.${d.date.toIso8601String()}'),
            contentPadding: EdgeInsets.zero,
            selected: d.date == viewed,
            title: Text(MoonCalendarSection.dayLabel(d)),
            subtitle: d.date == browser.planNight
                ? const Text("Your plan's night")
                : null,
            onTap: () => browser.viewNight(d.date),
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
