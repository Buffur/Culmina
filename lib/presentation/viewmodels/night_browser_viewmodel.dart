import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/calendar_date.dart';
import '../../domain/services/moon_calendar.dart';
import '../../domain/services/night_view.dart';
import 'session_plan_viewmodel.dart';
import 'settings_viewmodel.dart';
import 'site_viewmodel.dart';

/// Computes a month (an isolate in the app; tests pass a direct call).
typedef MonthComputer = Future<List<MoonCalendarDay>> Function(
  MoonCalendarRequest request,
);

Future<List<MoonCalendarDay>> _inIsolate(MoonCalendarRequest r) =>
    compute(MoonCalendar.compute, r);

/// Browsing nights on the Night & Moon detail (F15; ADR-022 N10/N11; D9
/// A): which night is viewed, the month shown, and the time slider's
/// instant. All of it is transient viewing state: nothing here writes the
/// plan, its night, a saved snapshot or a result. Only "Plan this night"
/// (`planThisNight`) adopts a viewed night.
class NightBrowserViewModel extends ChangeNotifier {
  NightBrowserViewModel({
    required this._site,
    required this._plan,
    required this._settings,
    required this._nowUtc,
    MonthComputer? computeMonth,
  }) : _computeMonth = computeMonth ?? _inIsolate {
    for (final s in [_site, _plan, _settings]) {
      s.addListener(_onContext);
    }
    _contextKey = _context;
  }

  final SiteViewModel _site;
  final SessionPlanViewModel _plan;
  final SettingsViewModel _settings;
  final DateTime Function() _nowUtc;
  final MonthComputer _computeMonth;

  CalendarDate? _viewed;
  DateTime? _cursorUtc;
  (int, int)? _month;
  Object? _contextKey;

  /// The plan's night (tonight when the plan has none).
  CalendarDate get planNight => _plan.eveningDate ?? _plan.tonightKey;

  /// The night being viewed; the plan's unless another was chosen.
  CalendarDate get viewedDate => _viewed ?? planNight;

  bool get viewingPlanNight => viewedDate == planNight;

  double get _limit => _settings.planningPreferences.darknessLimit.degrees;

  /// A site, zone or darkness-limit change revalidates the viewing state
  /// (A5): the cursor goes back to its default; the viewed date stays.
  Object get _context =>
      (_site.latitude, _site.longitude, _site.timeContext.id, _limit);

  void _onContext() {
    final key = _context;
    if (key != _contextKey) {
      _contextKey = key;
      _cursorUtc = null;
    }
    notifyListeners();
  }

  /// The viewed night, computed by the same calculators as the plan's
  /// (cached per night, limit and target).
  NightView get view {
    final night = _site.nightAt(viewedDate);
    final target = _plan.selectedTarget;
    final key = (night, _limit, target?.rightAscension, target?.declination);
    if (_viewKey != key) {
      _view = NightView.of(night, limitDeg: _limit, target: target);
      _viewKey = key;
    }
    return _view!;
  }

  Object? _viewKey;
  NightView? _view;

  /// Views [date] (browsing only); the cursor and the month follow it.
  void viewNight(CalendarDate date) {
    _viewed = date == planNight ? null : date;
    _cursorUtc = null;
    _month = (date.year, date.month);
    notifyListeners();
  }

  /// Back to the plan's night.
  void viewPlanNight() => viewNight(planNight);

  // The time slider (A5).

  /// Whether now lies in the viewed night (then "Now" is offered).
  bool get nowInView => view.contains(_nowUtc());

  /// The browsed instant: the one chosen, else now when it lies in the
  /// viewed night, else the night's start.
  DateTime get cursorUtc =>
      _cursorUtc ?? (nowInView ? _nowUtc() : view.night.startUtc);

  NightInstant get cursor => view.at(cursorUtc);

  /// Moves the cursor inside the viewed night (clamped to it).
  void setCursor(DateTime utc) {
    final n = view.night;
    _cursorUtc = utc.isBefore(n.startUtc)
        ? n.startUtc
        : utc.isAfter(n.endUtc)
        ? n.endUtc
        : utc;
    notifyListeners();
  }

  /// "Now" within the viewed night, else its start.
  void resetCursor() {
    _cursorUtc = null;
    notifyListeners();
  }

  // The month calendar (A1; N10).

  (int, int) get month => _month ?? (viewedDate.year, viewedDate.month);

  void showMonth(int delta) {
    final (y, m) = month;
    final first = DateTime.utc(y, m + delta);
    _month = (first.year, first.month);
    notifyListeners();
  }

  MoonCalendarRequest _requestFor(int year, int month) {
    final ctx = _site.timeContext.id;
    return MoonCalendarRequest(
      latitude: _site.latitude,
      longitude: _site.longitude,
      zoneId: ctx == 'solar' ? null : ctx,
      limitDeg: _limit,
      year: year,
      month: month,
    );
  }

  final _months = <String, List<MoonCalendarDay>>{};
  final _loading = <String>{};
  final _monthErrors = <String, Object>{};

  /// The shown month's nights, or null while it is computed (it starts
  /// then); cached per N10 key.
  List<MoonCalendarDay>? get monthDays => calendarDays(month.$1, month.$2);

  /// Reads the same cached/isolate-computed calendar for an adjacent month.
  /// Week browsing can cross a month boundary without adopting a night or
  /// changing the month grid's navigation state.
  List<MoonCalendarDay>? calendarDays(int year, int month) {
    final r = _requestFor(year, month);
    final days = _months[r.key];
    if (days == null &&
        !_monthErrors.containsKey(r.key) &&
        _loading.add(r.key)) {
      unawaited(_load(r));
    }
    return days;
  }

  /// Why the month could not be computed, if it could not.
  Object? get monthError => calendarError(month.$1, month.$2);

  /// An adjacent month's failure must not replace the visible month's state.
  Object? calendarError(int year, int month) =>
      _monthErrors[_requestFor(year, month).key];

  /// Explicit retry after a failed computation; no rebuild-driven retry loop.
  void retryCalendar(int year, int month) {
    _monthErrors.remove(_requestFor(year, month).key);
    calendarDays(year, month);
    notifyListeners();
  }

  Future<void> _load(MoonCalendarRequest r) async {
    try {
      _months[r.key] = await _computeMonth(r);
      _monthErrors.remove(r.key);
    } catch (e) {
      _monthErrors[r.key] = e;
    } finally {
      _loading.remove(r.key);
    }
    // The screen may have closed while the isolate computed.
    if (!_disposed) notifyListeners();
  }

  bool _disposed = false;

  /// Completes when every month being computed is done (tests).
  Future<void> get idle async {
    while (_loading.isNotEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final s in [_site, _plan, _settings]) {
      s.removeListener(_onContext);
    }
    super.dispose();
  }
}
