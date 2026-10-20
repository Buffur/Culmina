// Test-only interchange data for comparing the unchanged browser composition
// with real Flutter calculations. Never imported by production application code.
import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/export/session_manifest_codec.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/moon_conditions.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/night_weather_summary.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/night_view.dart';
import 'package:astroplan/domain/services/night_weather_summarizer.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/presentation/shared/night_text.dart';

import 'planner_harness.dart';

double _ms(DateTime t) => t.toUtc().microsecondsSinceEpoch / 1000;
Map<String, Object?> _span(DateTime a, DateTime b) => {
  'start': _ms(a),
  'end': _ms(b),
};

Map<String, Object?> _hour(WeatherHour h) => {
  'start': _ms(h.timeUtc),
  'end': _ms(h.timeUtc.add(const Duration(hours: 1))),
  'available': true,
  'cloud': h.cloudCoverPct,
  'temp': h.temperatureC,
  'dew': h.dewPointC,
  'wind': h.windSpeedKmh,
  'gust': h.windGustsKmh,
  'precip': h.precipitationProbabilityPct,
  'visibility': h.visibilityM,
  'humidity': h.relativeHumidityPct,
  'low': h.cloudCoverLowPct,
  'mid': h.cloudCoverMidPct,
  'high': h.cloudCoverHighPct,
};

Map<String, Object?> _summary(NightWeatherSummary s) => {
  'fromUtcMs': _ms(s.fromUtc),
  'toUtcMs': _ms(s.toUtc),
  'span': s.span.name,
  'sampleCount': s.totalHours,
  'coveredSamples': s.coveredHours,
  'cloudSamples': s.slots
      .where((slot) => slot.instant && slot.hour?.cloudCoverPct != null)
      .length,
  'cloudGapHours': s.cloudGapHours,
  'complete': s.complete,
  'cloudMin': s.cloudCover?.min,
  'cloudMax': s.cloudCover?.max,
  'tempMin': s.temperature?.min,
  'tempMax': s.temperature?.max,
  'dewMin': s.dewPoint?.min,
  'dewMax': s.dewPoint?.max,
  'dewKnownSamples': s.dewKnownHours,
  'dewRiskSamples': s.dewRiskHours,
  'dewMargin': s.dewMarginC,
  'dewSpreadMin': s.dewSpread?.min,
  'dewSpreadMax': s.dewSpread?.max,
  'ranges': {
    for (final (name, range) in [
      ('cloud', s.cloudCover),
      ('low', s.cloudCoverLow),
      ('mid', s.cloudCoverMid),
      ('high', s.cloudCoverHigh),
      ('precip', s.precipitationProbability),
      ('wind', s.windSpeed),
      ('gust', s.windGusts),
      ('temp', s.temperature),
      ('dew', s.dewPoint),
      ('humidity', s.relativeHumidity),
      ('visibility', s.visibility),
    ])
      name: range == null ? null : {'min': range.min, 'max': range.max},
  },
  'slots': [
    for (final slot in s.slots)
      {
        if (slot.hour case final h?)
          ..._hour(h)
        else ...{
          ..._span(slot.timeUtc, slot.timeUtc.add(const Duration(hours: 1))),
          'available': false,
          for (final key in [
            'cloud',
            'temp',
            'dew',
            'wind',
            'gust',
            'precip',
            'visibility',
            'humidity',
            'low',
            'mid',
            'high',
          ])
            key: null,
        },
        'instant': slot.instant,
        'precedingMinutes': slot.precedingMinutes,
        'preceding': slot.preceding,
        'partial': slot.partial,
        'dewSpread': slot.dewSpreadC,
        'dewRisk': slot.dewRisk,
      },
  ],
};

String _sky(SkyState s) => switch (s) {
  SkyState.daylight => 'Daylight',
  SkyState.civil => 'Civil twilight',
  SkyState.nautical => 'Nautical twilight',
  SkyState.astronomical => 'Astronomical twilight',
  SkyState.dark => 'Dark',
};

String _classification(MoonFreeKind kind) => switch (kind) {
  MoonFreeKind.noDark => 'No dark time',
  MoonFreeKind.none => 'No moon-free dark',
  MoonFreeKind.allNight => 'Moon-free all dark time',
  MoonFreeKind.evening => 'Moon-free in the evening',
  MoonFreeKind.morning => 'Moon-free in the morning',
  MoonFreeKind.middle => 'Moon-free in the middle of dark time',
  MoonFreeKind.mixed => 'Split moon-free intervals',
};

DateTime? _edge(SunThresholdResult result, {required bool dawn}) =>
    result is SunCrossing ? (dawn ? result.dawnUtc : result.duskUtc) : null;

/// Exports the host fixture and a whole calendar month through production
/// NightView/visibility/weather services, without mutating the active plan.
Future<void> exportHybridComparisonFixture({
  required PlannerHarness vm,
  required AppDatabase db,
  required WeatherRepository weather,
  required File destination,
}) async {
  final selected = vm.plan.eveningDate!;
  final preferences = vm.settings.planningPreferences;
  final limit = preferences.darknessLimit.degrees;
  final target = vm.plan.selectedTarget!;
  final rig = vm.plan.selectedEquipment!;
  final nights = <String, Object?>{};
  final rawHours = <double, Map<String, Object?>>{};
  final days = DateTime.utc(selected.year, selected.month + 1, 0).day;
  for (var day = 1; day <= days; day++) {
    final date = CalendarDate(selected.year, selected.month, day);
    final night = vm.site.nightAt(date);
    final view = NightView.of(night, limitDeg: limit, target: target);
    final fetched = await weather.fetchSnapshot(
      latitude: vm.site.latitude,
      longitude: vm.site.longitude,
      startUtc: night.startUtc,
      endUtc: night.endUtc,
    );
    if (fetched is! WeatherFetched) {
      throw StateError(
        'Comparison fixture requires its deterministic forecast.',
      );
    }
    for (final h in fetched.snapshot.hours) {
      rawHours[_ms(h.timeUtc)] = _hour(h);
    }
    final weatherSpan = NightWeatherSummarizer.spanOf(view.timeline);
    final summary = NightWeatherSummarizer.summarize(
      fetched.snapshot,
      fromUtc: weatherSpan.fromUtc,
      toUtc: weatherSpan.toUtc,
      span: weatherSpan.span,
      dewMarginC: preferences.dewMarginC,
    );
    final gridDark = <Map<String, Object?>>[];
    for (final segment in view.segments.where((s) => s.sky == SkyState.dark)) {
      if (gridDark.isNotEmpty &&
          gridDark.last['end'] == _ms(segment.startUtc)) {
        gridDark.last['end'] = _ms(segment.endUtc);
      } else {
        gridDark.add(_span(segment.startUtc, segment.endUtc));
      }
    }
    final continuousDark = [
      if (weatherSpan.span != NightWeatherSpan.noDark)
        _span(weatherSpan.fromUtc, weatherSpan.toUtc),
    ];
    final skySegments = <Map<String, Object?>>[];
    final gridMoonUp = <Map<String, Object?>>[];
    for (final segment in view.segments) {
      final sky = _sky(segment.sky);
      if (skySegments.isNotEmpty && skySegments.last['sky'] == sky) {
        skySegments.last['end'] = _ms(segment.endUtc);
      } else {
        skySegments.add({
          ..._span(segment.startUtc, segment.endUtc),
          'sky': sky,
        });
      }
      if (!segment.moonUp) continue;
      if (gridMoonUp.isNotEmpty &&
          gridMoonUp.last['end'] == _ms(segment.startUtc)) {
        gridMoonUp.last['end'] = _ms(segment.endUtc);
      } else {
        gridMoonUp.add(_span(segment.startUtc, segment.endUtc));
      }
    }
    nights[date.toIso8601String()] = {
      'date': date.toIso8601String(),
      'zone': vm.site.timeContext.id,
      ..._span(night.startUtc, night.endUtc),
      'sunset': switch (_edge(view.timeline.sunriseSunset, dawn: false)) {
        final t? => _ms(t),
        null => null,
      },
      'sunrise': switch (_edge(view.timeline.sunriseSunset, dawn: true)) {
        final t? => _ms(t),
        null => null,
      },
      'limitDeg': limit,
      'skySegments': skySegments,
      'rawNightSegments': [
        for (final segment in view.segments)
          {
            ..._span(segment.startUtc, segment.endUtc),
            'sky': _sky(segment.sky),
            'moonUp': segment.moonUp,
          },
      ],
      'dark': gridDark,
      'gridDark': gridDark,
      'weatherDark': continuousDark,
      'continuousDark': continuousDark,
      'moonUp': [for (final (a, b) in view.moon.upIntervals) _span(a, b)],
      'gridMoonUp': gridMoonUp,
      'moonFree': [for (final (a, b) in view.moonFree.intervals) _span(a, b)],
      'moonFreeKind': view.moonFree.kind.name,
      'gridDarkDurationMs': view.moonFree.dark.inMicroseconds / 1000,
      'gridMoonFreeDurationMs': view.moonFree.moonFree.inMicroseconds / 1000,
      'illumination': (view.moon.illuminationAtMidnight * 100).round(),
      'illuminationFraction': view.moon.illuminationAtMidnight,
      'phase': view.moon.phaseName == null
          ? null
          : MoonText.phaseName(view.moon.phaseName!),
      'classification': _classification(view.moonFree.kind),
      'twilight': [
        for (final (label, threshold, dawn) in [
          ('Sunset', view.timeline.sunriseSunset, false),
          ('Civil dusk', view.timeline.civilTwilight, false),
          ('Nautical dusk', view.timeline.nauticalTwilight, false),
          ('Astronomical dusk', view.timeline.astronomicalTwilight, false),
          ('Astronomical dawn', view.timeline.astronomicalTwilight, true),
          ('Nautical dawn', view.timeline.nauticalTwilight, true),
          ('Civil dawn', view.timeline.civilTwilight, true),
          ('Sunrise', view.timeline.sunriseSunset, true),
        ])
          {
            'label': label,
            'at': switch (_edge(threshold, dawn: dawn)) {
              final t? => _ms(t),
              null => null,
            },
          },
      ],
      'targetWindows': [
        for (final window
            in VisibilityCalculator.calculateVisibilityWindowsForNight(
              night: night,
              target: target,
              minAltitude: preferences.minAltitudeDeg,
              darknessLimitDeg: limit,
            ))
          {
            ..._span(window.start, window.end),
            'clippedAtStart': window.clippedAtStart,
            'clippedAtEnd': window.clippedAtEnd,
          },
      ],
      'nativeSummary': _summary(summary),
    };
  }
  final snapshot = vm.plan.activeSession!.planSnapshot!.json;
  final units = vm.vms.displaySettings.units;
  final rigs = await DriftEquipmentRepository(db).getAllEquipment();
  final targets = await DriftTargetRepository(db).getAllTargets();
  final aliases = await db.select(db.targetAliases).get();
  final sites = await DriftLocationRepository(db).getLocations();
  final sessionRepo = DriftSessionRepository(db);
  final sessions = await sessionRepo.list();
  final fit = vm.analysis.fitAnalysis;
  final budget = vm.analysis.captureBudget;
  final fitData = {
    'state': fit.state.name,
    'reason': fit.reason,
    'availableMs': fit.availableMs,
    'windowLoadMs': fit.windowLoadMs,
    'placedMs': fit.placedMs,
    'unusedMs': fit.unusedMs,
    'endUtcMs': fit.endUtc == null ? null : _ms(fit.endUtc!),
    'unplacedFrames': fit.unplacedFrames,
    'nightsNeeded': fit.nightsNeeded,
    'integrationMs': budget.integrationMs,
    'acquisitionMs': budget.acquisitionMs,
    'inWindowCalibrationMs': budget.inWindowCalibrationMs,
    'outsideWindowCalibrationMs': budget.outsideWindowCalibrationMs,
    'setupMs': budget.setupMs,
    'sessionBudgetMs': budget.sessionBudgetMs,
    'storageMB': budget.storageMB,
    'pixelScaleArcsec': vm.analysis.pixelScale,
  };
  final planningSettings = {
    'minAltitudeDeg': preferences.minAltitudeDeg,
    'darknessLimitDeg': preferences.darknessLimit.degrees,
    'feasibilityMarginPercent': preferences.feasibilityMarginPercent,
    'perFrameOverheadSeconds': preferences.perFrameOverheadSeconds,
    'moonGateEnabled': preferences.moonGateEnabled,
    'moonGateMinIlluminationPct': preferences.moonGateMinIlluminationPct,
    'cloudGateEnabled': preferences.cloudGateEnabled,
    'cloudGateMaxPct': preferences.cloudGateMaxPct,
    'ditherEveryNFrames': preferences.ditherEveryNFrames,
    'ditherSettleSeconds': preferences.ditherSettleSeconds,
    'refocusEveryMinutes': preferences.refocusEveryMinutes,
    'refocusSeconds': preferences.refocusSeconds,
    'filterChangeSeconds': preferences.filterChangeSeconds,
    'meridianFlipSeconds': preferences.meridianFlipSeconds,
    'setupMinutes': preferences.setupMinutes,
    'npfK': preferences.npfK,
    'dewMarginC': preferences.dewMarginC,
  };
  final payload = {
    'fixtureVersion': 1,
    'evidence': 'Controlled host fixture, production Dart calculations; no live provider data.',
    'nowUtcMs': _ms(vm.nowUtc),
    'referenceNowMs': _ms(vm.nowUtc),
    'retrievedAtMs': _ms(vm.nowUtc),
    'selectedEveningDate': selected.toIso8601String(),
    'site': {
      'name': vm.site.activeSite!.name,
      'latitude': vm.site.latitude,
      'longitude': vm.site.longitude,
      'zone': vm.site.timeContext.id,
    },
    'display': {
      'temperature': units.temperature.name,
      'wind': units.wind.name,
      'elevation': units.elevation.name,
      'timeFormat': 'HH:mm',
      'hourCycle': 'h23',
      'theme': 'light',
      'scale': 1,
    },
    'semantics': {
      'utcMilliseconds': 'Exact microsecond timestamp divided by 1000; never rounded to whole minutes.',
      'dark': 'Five-minute NightView segments for visual sky/cursor.',
      'weatherDark': 'Native NightWeatherSummarizer span from continuous twilight crossings.',
      'moonFree': 'Native five-minute inclusive-sample classifier intervals, unmodified.',
      'weatherHours':
          'Merged deterministic fixture requests for each calendar night.',
      'precedingMinutes':
          'Native integer Duration.inMinutes, not fractional overlap minutes.',
    },
    'nights': nights,
    'weatherHours': [
      for (final key in rawHours.keys.toList()..sort()) rawHours[key],
    ],
    'planSnapshot': snapshot,
    'tonight': {
      'firstRunDone': true,
      'selectedEveningDate': selected.toIso8601String(),
      'planId': vm.plan.activeSession!.id,
      'planName': vm.plan.activeSession!.name,
      'targetLabel': target.commonName ?? target.catalogId,
      'rigLabel': rig.name,
      'fit': fitData,
      'opportunity': snapshot['opportunity'],
      'weather': snapshot['weather'],
    },
    'library': {
      'activeSiteId': vm.site.activeSite!.id,
      'counts': {
        'rigs': rigs.length,
        'targets': targets.length,
        'sites': sites.length,
      },
      'rigs': [
        for (final r in rigs)
          {
            'id': 'example-native-rig-${r.id}',
            'nativeId': r.id,
            'example': r.isExample,
            'name': r.name,
            'manufacturer': r.manufacturer,
            'cameraModel': r.cameraModel,
            'cameraClass': r.cameraClass.name,
            'noiseReduction': r.inCameraNoiseReduction,
            'resolutionPx': [r.resolutionWidthPx, r.resolutionHeightPx],
            'sensorMm': [r.sensorWidthMm, r.sensorHeightMm],
            'pixelUm': r.pixelPitchUm,
            'focalLengthMm': r.focalLengthMm,
            'focalRatio': r.focalRatio,
            'apertureMm': r.apertureDiameterMm,
            'tracking': r.trackingType.name,
            'maxExposureS': r.maxExposureS,
            'rawFileSizeMB': r.averageRawFileSizeMB,
            'rotationDeg': r.rotationDeg,
            'captureFormat': r.captureFormat?.name,
            'provenance': {
              'record': 'Native database fixture',
              'camera': r.cameraSource ?? 'Not recorded',
              'optics': r.opticsSource ?? 'Not recorded',
            },
          },
      ],
      'targets': [
        for (final t in targets)
          {
            'id': t.catalogId,
            'nativeId': t.id,
            'catalogId': t.catalogId,
            'name': t.commonName ?? t.catalogId,
            'type': t.type,
            'raDeg': t.rightAscension,
            'decDeg': t.declination,
            'sizeArcmin': t.angularSizeArcmin,
            'magnitude': t.magnitude,
            'source': t.source,
            'epoch': t.epoch,
            'bundled': t.source != 'user',
            'aliasIds': [
              for (final a in aliases)
                if (a.catalogId == t.catalogId && a.kind == 'designation')
                  a.alias,
            ],
            'aliasNames': [
              for (final a in aliases)
                if (a.catalogId == t.catalogId && a.kind == 'name') a.alias,
            ],
          },
      ],
      'sites': [
        for (final s in sites)
          {
            'id': 'example-native-site-${s.id}',
            'nativeId': s.id,
            'example': false,
            'name': s.name,
            'latDeg': s.latitude,
            'lonDeg': s.longitude,
            'elevationM': s.elevation,
            'zone': s.timeZoneId,
            'bortle': s.bortleClass,
            'bortleSource': s.bortleSource,
            'sqm': s.sqm,
            'sqmSource': s.sqmSource,
            'notes': s.notes,
            'provenance': 'Native database fixture',
          },
      ],
    },
    'settings': {
      'display': {
        'appearance': vm.vms.displaySettings.appearance.name,
        'units': {
          'temperature': units.temperature.name,
          'wind': units.wind.name,
          'elevation': units.elevation.name,
        },
      },
      'planning': planningSettings,
      'privacy': {'placeNameLookup': vm.settings.placeNameLookup},
    },
    'logbook': {
      'count': sessions.length,
      'manifest': SessionManifestCodec.encode(
        [
          for (final session in sessions)
            ExportedSession(session, await sessionRepo.events(session.id)),
        ],
        exportedAtUtc: vm.nowUtc,
        appVersion: AppIdentity.version,
      ),
    },
    'plan': {
      'id': vm.plan.activeSession!.id,
      'night': selected.toIso8601String(),
      'target': snapshot['target'],
      'rig': snapshot['rig'],
      'targetLabel': target.catalogId,
      'rigLabel': rig.name,
      'blocks': snapshot['blocks'],
      'budget': snapshot['budget'],
      'blockCount': vm.plan.captureBlocks.length,
      'frameCount': vm.plan.captureBlocks.fold(0, (n, b) => n + b.frameCount),
      'lightFrameCount': budget.lightFrameCount,
      'fit': fitData,
      'planningPreferences': planningSettings,
      'overrides': vm.plan.planOverrides?.toJson(),
      'saved': vm.plan.activeSession!.isSavedPlan,
      'status': vm.plan.activeSession!.status.name,
    },
  };
  await destination.parent.create(recursive: true);
  await destination.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );
}
