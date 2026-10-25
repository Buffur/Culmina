import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/moon_conditions.dart';
import '../../domain/models/night_timeline.dart';
import '../../domain/models/visibility_window.dart';
import '../../domain/services/moon_calendar.dart';
import '../../domain/services/night_view.dart';
import '../shared/hybrid_icon.dart';
import '../shared/night_text.dart';
import '../shared/sky_color_interpolation.dart';
import '../shared/night_time_formatter.dart';
import '../viewmodels/night_browser_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';

/// The viewed night's daylight, twilight, darkness and Moon on one bar,
/// with the time slider (F15 A1/A5; AM-01 SP07): the primary explanation
/// of the night. The bar's segments come from [NightView.segments]; the
/// Moon-up and Moon-free lanes have distinct positions and thicknesses.
/// Moving the slider changes viewing state only.
///
/// Hybrid composition (night-ui.js `timeline`, night.css, accepted web
/// reference 86873ce): "Preview time" and the previewed instant; two jumps
/// to the start and end of dark time; the 14 px sky band with its two 8 px
/// Moon lanes 4 px below; the rail's end labels and hint, the optional key
/// and encoding note in "Exact times & reading key", and the cursor's state.
class NightBarSection extends StatelessWidget {
  /// The slider's spoken value at [utc]: "21:15, 19 Oct (site zone
  /// Europe/Kyiv, EEST, UTC+03:00): Dark (Sun below −18°) · …".
  static String readout(
    BuildContext context,
    NightView view,
    DateTime utc,
    String? zoneId,
  ) {
    String at(DateTime t) => NightTimeFormatter.instant(
      context,
      t,
      windowStartUtc: view.night.startUtc,
      zoneId: zoneId,
    );
    final wall = NightTimeFormatter.wallClock(utc, zoneId: zoneId);
    final date = NightTimeFormatter.eveningDate(
      CalendarDate.fromDateTimeFields(wall),
    );
    final zone = NightTimeFormatter.zoneCaption(utc, zoneId: zoneId);
    return '${at(utc)}, $date ($zone): '
        '${NightBrowseText.cursor(view.at(utc), view.limitDeg, at)}';
  }

  const NightBarSection({super.key, this.compact = true, this.home = false});

  /// Kept for callers; the Hybrid browser is the compact one everywhere.
  final bool compact;

  /// Tonight's rail end labels use the page's normal leading (17 px at
  /// 13 px, `.concept` cascade); Night & Moon's use 1.5.
  final bool home;

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<NightBrowserViewModel>();
    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    final view = browser.view;
    final night = view.night;
    final p = AppPalette.of(context);
    final caption = AppTypography.caption.copyWith(color: p.textSecondary);
    const tabular = [FontFeature.tabularFigures()];
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: night.startUtc,
      zoneId: zoneId,
    );
    String dated(DateTime utc) =>
        NightTimeFormatter.datedClock(context, utc, zoneId: zoneId);
    final n = view.sun.altitudesDeg.length;
    final cursor = browser.cursor;
    final index = view.indexOf(cursor.instantUtc);
    final dark = view.darkInterval;
    return Column(
      key: const Key('nightMoon.bar'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Semantics(
              header: true,
              child: Text('Preview time', style: caption),
            ),
            Text(
              NightTimeFormatter.previewInstant(
                context,
                cursor.instantUtc,
                zoneId: zoneId,
              ),
              key: const Key('nightMoon.previewTime'),
              style: AppTypography.caption.copyWith(
                color: p.textPrimary,
                fontFeatures: tabular,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final end in [false, true]) ...[
                if (end) const SizedBox(width: 8),
                Expanded(
                  child: _JumpButton(
                    view: view,
                    dark: dark,
                    end: end,
                    at: at,
                    onPressed: () => browser.jumpCursor(end: end),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: SizedBox(
            key: const Key('nightMoon.rail'),
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
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
                        palette: p,
                        hybrid: Theme.of(context).extension<HybridTokens>(),
                        surface: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 0,
                      thumbColor: HybridTokens.transparent,
                      activeTrackColor: HybridTokens.transparent,
                      inactiveTrackColor: HybridTokens.transparent,
                      overlayColor: HybridTokens.transparent,
                      showValueIndicator: ShowValueIndicator.never,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 3,
                        elevation: 0,
                        pressedElevation: 0,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      key: const Key('nightMoon.slider'),
                      padding: EdgeInsets.zero,
                      value: index.toDouble(),
                      min: 0,
                      max: (n - 1).toDouble(),
                      divisions: n - 1,
                      label: at(cursor.instantUtc),
                      // The full read-out: the instant with its date and
                      // zone (named across a DST change), then the sky,
                      // the Moon and the dark interval's end.
                      semanticFormatterCallback: (v) => readout(
                        context,
                        view,
                        night.startUtc.add(Duration(minutes: v.round() * 5)),
                        zoneId,
                      ),
                      onChanged: (v) => browser.setCursor(
                        night.startUtc.add(Duration(minutes: v.round() * 5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                dated(night.startUtc),
                style: caption.copyWith(
                  fontFeatures: tabular,
                  height: home ? 17 / 13 : null,
                ),
              ),
              Text(
                dated(night.endUtc),
                style: caption.copyWith(
                  fontFeatures: tabular,
                  height: home ? 17 / 13 : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('Drag to preview · arrow keys step 5 min.', style: caption),
        const SizedBox(height: 12),
        _ExactTimes(view: view, zoneId: zoneId),
        const SizedBox(height: 10),
        Text(
          cursor.dark
              ? cursor.moonUp
                    ? 'Dark · Moon above horizon'
                    : 'Moon-free dark'
              : '${NightBrowseText.sky(cursor.sky, view.limitDeg)} · '
                    'Moon ${cursor.moonUp ? 'above' : 'below'} horizon',
          key: const Key('nightMoon.cursorState'),
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Semantics(
          liveRegion: true,
          child: Text(
            _compactCursor(view, cursor, at),
            key: const Key('nightMoon.cursorSummary'),
            style: caption.copyWith(height: 1.55),
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

/// "Dark starts 21:15" / "Dark ends 04:45 (+1)" (night.css `.timeline-jump`):
/// a 64 px outlined button whose time is the exact interval boundary; the
/// cursor moves to that boundary's five-minute grid point. Without dark time
/// the rail's ends ("Timeline start/end"); a boundary at the rail's edge is
/// "Window start/end".
class _JumpButton extends StatelessWidget {
  const _JumpButton({
    required this.view,
    required this.dark,
    required this.end,
    required this.at,
    required this.onPressed,
  });

  final NightView view;
  final (DateTime, DateTime)? dark;
  final bool end;
  final String Function(DateTime) at;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final night = view.night;
    final d = dark;
    final boundary = d == null
        ? (end
              ? view.gridAt(night.endUtc.subtract(const Duration(minutes: 5)))
              : night.startUtc)
        : (end ? d.$2 : d.$1);
    final clipped =
        d != null &&
        (end
            ? !boundary.isBefore(night.endUtc)
            : !boundary.isAfter(night.startUtc));
    final label = clipped
        ? (end ? 'Window end' : 'Window start')
        : d != null
        ? (end ? 'Dark ends' : 'Dark starts')
        : (end ? 'Timeline end' : 'Timeline start');
    final what = d != null
        ? (end ? 'end of dark time' : 'start of dark time')
        : (end ? 'end of the timeline' : 'start of the timeline');
    final target = view.gridAt(boundary);
    return Semantics(
      button: true,
      label: 'Go to $what, ${at(target)}',
      excludeSemantics: true,
      enabled: true,
      onTap: onPressed,
      child: OutlinedButton(
        key: Key(end ? 'nightMoon.jumpEnd' : 'nightMoon.jumpStart'),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 64),
          // CSS padding 8 × 12 inside a 1 px border.
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          alignment: Alignment.topLeft,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  height: 1.4,
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                at(boundary),
                style: AppTypography.value.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: p.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Exact times & reading key" (night-ui.js `timelineExactDetails`): a 12 px
/// native disclosure with the sky states, Sun events, dark time and Moon
/// intervals as exact instants with their date and zone.
class _ExactTimes extends StatefulWidget {
  const _ExactTimes({required this.view, required this.zoneId});

  final NightView view;
  final String? zoneId;

  @override
  State<_ExactTimes> createState() => _ExactTimesState();
}

class _ExactTimesState extends State<_ExactTimes> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final view = widget.view;
    final small = AppTypography.dense.copyWith(color: p.textSecondary);
    String instant(DateTime utc) =>
        NightTimeFormatter.previewInstant(context, utc, zoneId: widget.zoneId);
    String span((DateTime, DateTime) x) =>
        '${instant(x.$1)}\nto ${instant(x.$2)}';
    Widget group(String heading, List<(String, String)> rows, String empty) =>
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    heading,
                    style: small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: p.textPrimary,
                    ),
                  ),
                ),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(empty, style: small),
                  ),
                for (final (label, value) in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(label, style: small)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            value,
                            textAlign: TextAlign.right,
                            style: small.copyWith(
                              color: p.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
    final sky = <(String, String)>[];
    SkyState? last;
    var from = view.night.startUtc;
    for (final s in view.segments) {
      if (s.sky == last) continue;
      if (last != null) {
        sky.add((
          NightBrowseText.sky(last, view.limitDeg),
          span((from, s.startUtc)),
        ));
      }
      last = s.sky;
      from = s.startUtc;
    }
    if (last != null) {
      sky.add((
        NightBrowseText.sky(last, view.limitDeg),
        span((from, view.night.endUtc)),
      ));
    }
    final t = view.timeline;
    final events = <(String, String)>[];
    void event(String label, SunThresholdResult r, {required bool dawn}) {
      final at = r is SunCrossing ? (dawn ? r.dawnUtc : r.duskUtc) : null;
      events.add((label, at == null ? 'No event in this night' : instant(at)));
    }

    event('Sunset', t.sunriseSunset, dawn: false);
    event('Civil dusk', t.civilTwilight, dawn: false);
    event('Nautical dusk', t.nauticalTwilight, dawn: false);
    event('Astronomical dusk', t.astronomicalTwilight, dawn: false);
    event('Astronomical dawn', t.astronomicalTwilight, dawn: true);
    event('Nautical dawn', t.nauticalTwilight, dawn: true);
    event('Civil dawn', t.civilTwilight, dawn: true);
    event('Sunrise', t.sunriseSunset, dawn: true);
    final dark = view.darkInterval;
    final ups = <(DateTime, DateTime)>[];
    for (final s in view.segments.where((s) => s.moonUp)) {
      if (ups.isNotEmpty && ups.last.$2 == s.startUtc) {
        ups[ups.length - 1] = (ups.last.$1, s.endUtc);
      } else {
        ups.add((s.startUtc, s.endUtc));
      }
    }
    // The plan's imaging windows, only on the plan's own night (they are
    // the existing opportunity, not a sky-quality rating).
    final target = context.read<NightBrowserViewModel>().viewingPlanNight
        ? [
            for (final w
                in context
                        .read<NightConditionsViewModel?>()
                        ?.visibilityWindows ??
                    const <VisibilityWindow>[])
              (w.start, w.end),
          ]
        : const <(DateTime, DateTime)>[];
    return Column(
      key: const Key('nightMoon.exactTimes'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          key: const Key('nightMoon.exactToggle'),
          button: true,
          enabled: true,
          expanded: _open,
          excludeSemantics: true,
          label: 'Exact times & reading key',
          onTap: _toggle,
          child: InkWell(
            onTap: _toggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // The browser's details marker: a small filled triangle.
                    CustomPaint(
                      size: const Size(12, 12),
                      painter: _MarkerPainter(
                        open: _open,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Exact times & reading key',
                        style: AppTypography.dense.copyWith(
                          fontWeight: FontWeight.w500,
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_open) ...[
          _Legend(
            view: view,
            compact: true,
            at: (utc) => NightTimeFormatter.clockTime(
              context,
              utc,
              zoneId: widget.zoneId,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dark == null
                ? 'Sky colour blends between known Sun-event times. There is no '
                      'dark time (Sun below '
                      '${QuantityText.degrees(view.limitDeg)}) this night. It '
                      'is not measured sky brightness or a quality score.'
                : 'Sky colour blends between known Sun-event times; black marks '
                      'dark time (Sun below '
                      '${QuantityText.degrees(view.limitDeg)}). It is not '
                      'measured sky brightness or a quality score.',
            key: const Key('nightMoon.encoding'),
            style: AppTypography.caption.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Times in ${NightTimeFormatter.zoneCaption(view.night.startUtc, zoneId: widget.zoneId)}. '
              'Interval ends are boundaries; preview steps remain five minutes.',
              style: small,
            ),
          ),
          group('Sky state', sky, 'Sky state unknown.'),
          group('Sun events', events, 'Sun-event data unavailable.'),
          group('Dark time', [
            if (dark != null) ('Dark time', span(dark)),
          ], 'No dark time in this night.'),
          group('Moon above horizon', [
            for (final u in ups) ('Moon above horizon', span(u)),
          ], 'The Moon stays below the horizon.'),
          if (target.isNotEmpty)
            group('Target window', [
              for (final w in target) ('Target window', span(w)),
            ], ''),
          group('Moon-free dark', [
            for (final f in view.moonFree.intervals)
              ('Moon-free dark', span(f)),
          ], 'No moon-free dark time.'),
        ],
      ],
    );
  }
}

/// The browser's `details` marker: a right-pointing (closed) or
/// down-pointing (open) filled triangle in the summary's colour.
class _MarkerPainter extends CustomPainter {
  const _MarkerPainter({required this.open, required this.color});

  final bool open;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = open
        ? (Path()
            ..moveTo(w * .1, h * .25)
            ..lineTo(w * .9, h * .25)
            ..lineTo(w * .5, h * .75)
            ..close())
        : (Path()
            ..moveTo(w * .25, h * .1)
            ..lineTo(w * .75, h * .5)
            ..lineTo(w * .25, h * .9)
            ..close());
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MarkerPainter old) =>
      old.open != open || old.color != color;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.view, required this.compact, this.at});

  final NightView view;
  final bool compact;
  final String Function(DateTime)? at;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final style = AppTypography.caption.copyWith(
      height: 1.45,
      color: p.textSecondary,
    );
    final hybrid =
        Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    // night.css `.key`: 20 × 10, radius 2; sky keys outlined in the control
    // border, the Moon-up key a 4 px bar on the sunken lane.
    Widget key(Decoration fill) => Container(
      width: 20,
      height: 10,
      decoration: fill,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: p.controlBorder),
      ),
    );
    BoxDecoration solid(Color c) =>
        BoxDecoration(color: c, borderRadius: BorderRadius.circular(2));
    Widget chip(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const SizedBox(width: 6),
        // Wraps at large text rather than overflowing (trap 17).
        Flexible(child: Text(label, style: style)),
      ],
    );
    bool present(SkyState state) => view.segments.any((s) => s.sky == state);
    final dark = view.darkInterval;
    final label = at;
    final darkLabel = dark == null
        ? null
        : label == null
        ? 'Dark'
        : 'Dark ${label(dark.$1)}–${label(dark.$2)}';
    return Column(
      key: Key(compact ? 'nightMoon.legend' : 'nightMoon.readingLegend'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            if (present(SkyState.daylight))
              chip(key(solid(hybrid.skyDay)), 'Daylight'),
            if (compact) ...[
              if ([
                SkyState.civil,
                SkyState.nautical,
                SkyState.astronomical,
              ].any(present))
                chip(
                  key(
                    BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          hybrid.skyCivil,
                          hybrid.skyNautical,
                          hybrid.skyAstronomical,
                        ],
                      ),
                    ),
                  ),
                  'Twilight',
                ),
            ] else
              for (final (state, name, color) in [
                (SkyState.civil, 'Civil twilight', hybrid.skyCivil),
                (SkyState.nautical, 'Nautical twilight', hybrid.skyNautical),
                (
                  SkyState.astronomical,
                  'Astronomical twilight',
                  hybrid.skyAstronomical,
                ),
              ])
                if (present(state)) chip(key(solid(color)), name),
            if (darkLabel != null)
              chip(
                key(solid(hybrid.skyDark)),
                compact
                    ? darkLabel
                    // night-ui.js legend: the limit, then the dark times.
                    : 'Dark · Sun below ${QuantityText.degrees(view.limitDeg)}'
                          ' · ${darkLabel.substring('Dark '.length)}',
              )
            else
              Text(
                'No dark time: the Sun stays above '
                '${QuantityText.degrees(view.limitDeg)}',
                style: style,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            chip(
              Container(
                width: 20,
                height: 10,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hybrid.surfaceSunken,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: p.border),
                ),
                child: Container(height: 4, color: hybrid.moonUp),
              ),
              'Moon above horizon',
            ),
            chip(
              Container(
                width: 20,
                height: 10,
                decoration: solid(hybrid.moonFree),
              ),
              'Moon-free dark',
            ),
          ],
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
    final p = AppPalette.of(context);
    final note = AppTypography.caption.copyWith(
      height: 1.5,
      color: p.textTertiary,
    );
    // conditions.js readingGuide: the full key, its note, then how the
    // cursor reads. The cursor's own read-out is the slider's value.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        _Legend(
          view: browser.view,
          compact: false,
          at: (utc) => NightTimeFormatter.clockTime(
            context,
            utc,
            zoneId: context.read<SiteViewModel>().displayZoneId,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sky colour blends between known Sun-event times. It is not '
          'measured sky brightness.',
          style: note,
        ),
        const SizedBox(height: 16),
        Text(
          'The cursor previews five-minute steps. Sky colour is not measured '
          'brightness; Moon-free dark is dark time with the Moon below the '
          'horizon.',
          key: const Key('nightMoon.readingNote'),
          style: AppTypography.caption.copyWith(
            height: 1.65,
            color: p.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Paints [view] on the 42 px rail (night.css, compact Hybrid): the 14 px
/// sky band (radius 4, 1 px control-border outline), the Moon-up lane at
/// 18–26 (a 4 px bar on the sunken lane) and the Moon-free lane at 30–38,
/// both outlined in the subtle border; then the cursor, a 6 × 46 bar with a
/// 2 px surface border, from 2 above the band. Public for tests.
class NightBarPainter extends CustomPainter {
  NightBarPainter({
    required this.view,
    required this.cursorIndex,
    required this.palette,
    this.hybrid,
    this.surface,
  });

  final NightView view;
  final int cursorIndex;
  final AppPalette palette;
  final HybridTokens? hybrid;

  /// The page surface: the cursor's border (night.css thumb).
  final Color? surface;

  static const skyHeight = 14.0;
  static const laneHeight = 8.0;
  static const upTop = skyHeight + 4;
  static const freeTop = skyHeight + 8 + laneHeight;

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
    // night-ui.js skyGradient: a knot at the first segment's start, at each
    // dark run's start and end, at the middle of every other run and at the
    // last end; eight smoothstep stops mixed in Oklab between unlike knots.
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
    final sky = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, skyHeight),
      const Radius.circular(4),
    );
    final skyPaint = Paint()..color = tokens.skyDay;
    if (colors.length >= 2) {
      skyPaint.shader = LinearGradient(
        colors: colors,
        stops: stops,
      ).createShader(sky.outerRect);
    }
    canvas.drawRRect(sky, skyPaint);
    // CSS outline: 1 px outside the box.
    canvas.drawRRect(
      sky.inflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = palette.controlBorder,
    );
    for (final top in [upTop, freeTop]) {
      final lane = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, top, size.width, laneHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(lane, Paint()..color = tokens.surfaceSunken);
      canvas.drawRRect(
        lane.inflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = palette.border,
      );
    }
    final ups = <(DateTime, DateTime)>[];
    for (final s in view.segments.where((s) => s.moonUp)) {
      if (ups.isNotEmpty && ups.last.$2 == s.startUtc) {
        ups[ups.length - 1] = (ups.last.$1, s.endUtc);
      } else {
        ups.add((s.startUtc, s.endUtc));
      }
    }
    for (final u in ups) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x(u.$1), upTop + 2, x(u.$2), upTop + 6),
          const Radius.circular(3),
        ),
        Paint()..color = tokens.moonUp,
      );
    }
    for (final span in view.moonFree.intervals) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x(span.$1), freeTop, x(span.$2), freeTop + laneHeight),
          const Radius.circular(3),
        ),
        Paint()..color = tokens.moonFree,
      );
    }
    final cx = x(night.startUtc.add(Duration(minutes: cursorIndex * 5)))
        .clamp(0.0, size.width);
    if (identical(tokens, HybridTokens.field)) {
      // WQA-03's Field range (hybrid-refinement.css) also styles this
      // input: a 4 px control-border track centred in its 48 px box and a
      // 24 px red thumb, instead of the light/dark bar cursor.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-3, 22, size.width + 6, 4),
          const Radius.circular(2),
        ),
        Paint()..color = palette.controlBorder,
      );
      canvas.drawCircle(
        Offset(cx, 24),
        12,
        Paint()..color = palette.textPrimary,
      );
      return;
    }
    final thumb = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 3, -2, 6, size.height + 4),
      const Radius.circular(3),
    );
    canvas.drawRRect(thumb, Paint()..color = palette.textPrimary);
    canvas.drawRRect(
      thumb.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = surface ?? tokens.onAction,
    );
  }

  @override
  bool shouldRepaint(NightBarPainter old) =>
      old.view != view ||
      old.cursorIndex != cursorIndex ||
      old.palette != palette ||
      old.hybrid != hybrid ||
      old.surface != surface;
}

/// The month of Moon nights (F15 A1; ADR-022 N4/N5/N10): per night its
/// phase, drawn from the phase longitude, and its moon-free dark time.
/// Computed in an isolate and cached; tapping a night views it (browsing
/// only). At large text the month becomes a readable week list rather
/// than squeezed cells.
class MoonCalendarSection extends StatelessWidget {
  const MoonCalendarSection({super.key, this.insetHeader = false});

  final bool insetHeader;

  /// Large text switches to the week view (SP07).
  static const weekViewScale = 1.5;

  /// Seven separate 48 dp day targets in the month view.
  static const minMonthWidth = 7 * kMinInteractiveDimension;

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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final browser = context.watch<NightBrowserViewModel>();
      final (year, month) = browser.month;
      final days = browser.monthDays;
      final week =
          MediaQuery.textScalerOf(context).scale(1) >= weekViewScale ||
          constraints.maxWidth < minMonthWidth;
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
      final p = AppPalette.of(context);
      // conditions.js calendar (`.section-actions`): the heading (20/600) and
      // the month between two 48 px arrows, wrapping as text grows.
      final heading = Semantics(
        header: true,
        child: Text(
          'Moon calendar',
          style: AppTypography.sectionHeading.copyWith(color: p.textPrimary),
        ),
      );
      Widget arrow(Key key, String tip, HybridIconData icon, int step) =>
          IconButton(
            key: key,
            tooltip: tip,
            onPressed: () => browser.showMonth(step),
            icon: HybridIcon(
              icon,
              size: MediaQuery.textScalerOf(context).scale(24),
              strokeWidth: 1.8,
              color: p.textPrimary,
            ),
          );
      final monthControls = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          arrow(
            const Key('nightMoon.prevMonth'),
            'Previous month',
            HybridIcons.previous,
            -1,
          ),
          Semantics(
            header: true,
            child: Text(
              '${months[month - 1]} $year',
              style: AppTypography.caption.copyWith(
                color: p.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          arrow(
            const Key('nightMoon.nextMonth'),
            'Next month',
            HybridIcons.next,
            1,
          ),
        ],
      );
      return Column(
        key: const Key('nightMoon.calendar'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: insetHeader ? 16 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [heading, if (!week) monthControls],
                ),
                Text(
                  'Tap a night to view it; your plan stays unchanged.',
                  style: AppTypography.caption.copyWith(
                    height: 1.65,
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
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
    },
  );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.days, required this.browser});

  final List<MoonCalendarDay> days;
  final NightBrowserViewModel browser;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.dense.copyWith(
      color: AppPalette.of(context).textSecondary,
    );
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
        // `.weekday-row span`: padding-bottom 8, then 4 to the days.
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth / 7 - 2;
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

            // `.calendar-grid button`: padding 4 1 and a 1 px border round
            // the date (12/18), 3, the 20 px glyph, 3, the hours (12/1.4).
            final extent = days.fold<double>(48, (largest, day) {
              return math.max(
                largest,
                10 +
                    18 +
                    3 +
                    20 +
                    3 +
                    height(
                      MoonCalendarSection._short(day),
                      AppTypography.dense.copyWith(height: 1.4),
                    ),
              );
            });
            return GridView.count(
              key: const Key('nightMoon.month'),
              crossAxisCount: 7,
              crossAxisSpacing: 0,
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${day.date.day}'),
                    // conditions.js calendarDay: the plan's night mark.
                    if (plan)
                      TextSpan(
                        text: ' •',
                        style: AppTypography.dense.copyWith(
                          fontSize: HybridTokens.calendarCaptionSize,
                          color: p.textPrimary,
                        ),
                      ),
                  ],
                ),
                style: AppTypography.dense.copyWith(color: p.textPrimary),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(
                  painter: MoonPhasePainter.hybrid(
                    theme,
                    phaseLongitudeDeg: day.phaseLongitudeDeg,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                MoonCalendarSection._short(day),
                textAlign: TextAlign.center,
                style: AppTypography.dense.copyWith(
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
                        painter: MoonPhasePainter.hybrid(
                          theme,
                          phaseLongitudeDeg: d.phaseLongitudeDeg,
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
///
/// Hybrid's `moonGlyph` (conditions.js/css): the shadowed disc in the
/// subtle surface, the lit part in the primary text colour, a 0.7 px
/// control-border outline.
class MoonPhasePainter extends CustomPainter {
  MoonPhasePainter({
    required this.phaseLongitudeDeg,
    required this.lit,
    required this.dark,
    this.shadow,
    this.outlineWidth = 1,
  });

  /// The Hybrid roles of [theme].
  factory MoonPhasePainter.hybrid(
    ThemeData theme, {
    required double? phaseLongitudeDeg,
  }) {
    final palette = theme.extension<AppPalette>()!;
    final field = identical(
      theme.extension<HybridTokens>(),
      HybridTokens.field,
    );
    return MoonPhasePainter(
      phaseLongitudeDeg: phaseLongitudeDeg,
      lit: palette.textPrimary,
      dark: palette.controlBorder,
      shadow: field ? theme.cardColor : theme.colorScheme.surface,
      outlineWidth: 0.7,
    );
  }

  final double? phaseLongitudeDeg;
  final Color lit;

  /// The outline.
  final Color dark;

  /// The unlit disc's fill; none when null.
  final Color? shadow;
  final double outlineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2 - 1;
    final c = size.center(Offset.zero);
    final l = phaseLongitudeDeg;
    if (l != null && shadow != null) {
      canvas.drawCircle(c, r, Paint()..color = shadow!);
    }
    if (l != null) _paintLit(canvas, c, r, l);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth,
    );
  }

  void _paintLit(Canvas canvas, Offset c, double r, double l) {
    final rad = (l % 360) * math.pi / 180;
    final waxing = (l % 360) < 180;
    // The terminator's half-width: cos of the phase angle. It lies on the
    // lit limb's side for a crescent (k > 0) and beyond the centre for a
    // gibbous Moon (k < 0); the path returns along it from the bottom.
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
        clockwise: waxing ? k < 0 : k > 0,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = lit);
  }

  @override
  bool shouldRepaint(MoonPhasePainter old) =>
      old.phaseLongitudeDeg != phaseLongitudeDeg ||
      old.lit != lit ||
      old.dark != dark ||
      old.shadow != shadow ||
      old.outlineWidth != outlineWidth;
}
