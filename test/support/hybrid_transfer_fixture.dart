// Test-only data for the Hybrid transfer's web/Flutter pairs (2026-10-22).
// It mirrors the web reference's demonstration records where the production
// model can hold them: Kyiv outskirts (50.4, 30.6, Europe/Kyiv), the night of
// 19 Oct 2026, M31 with a DSLR on a 135 mm lens, one ISO 800 light block.
// Numbers come from the real calculations, not from the browser's demo
// model. Never imported by application code.
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_device_time_zone.dart';
import 'fake_location_service.dart';
import 'fake_reverse_geocoder.dart';
import 'in_memory_first_run.dart';
import 'in_memory_privacy_preferences.dart';
import 'planner_harness.dart';

/// 18:00 in Kyiv on 18 Oct 2026: the plan's night (19 Oct) is not tonight,
/// as in the browser reference, whose demo night lies in the past.
final hybridTransferNow = DateTime.utc(2026, 10, 18, 15);

/// The web reference's night.
final hybridTransferNight = CalendarDate(2026, 10, 19);

/// A forecast with every value on whole hours; [failure] makes it fail.
class HybridTransferForecast implements WeatherRepository {
  HybridTransferForecast(this.clock);
  final Clock clock;
  WeatherFailure? failure;

  /// How old the next snapshot is (a stale snapshot).
  Duration age = Duration.zero;

  /// Hours left out at the start of the next snapshot (partial coverage).
  int missingFirstHours = 0;

  /// Every [cloudGapEvery]th hour has no cloud value (gaps); 0: none.
  int cloudGapEvery = 0;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    if (failure case final value?) return WeatherFetchFailed(value);
    final first = DateTime.utc(
      startUtc.year,
      startUtc.month,
      startUtc.day,
      startUtc.hour,
    );
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: clock.nowUtc().subtract(age),
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (
            var t = first.add(Duration(hours: missingFirstHours));
            t.isBefore(endUtc);
            t = t.add(const Duration(hours: 1))
          )
            WeatherHour(
              timeUtc: t,
              cloudCoverPct: cloudGapEvery > 0 && t.hour % cloudGapEvery == 0
                  ? null
                  : (t.hour * 7 % 60).toDouble(),
              cloudCoverLowPct: 10,
              cloudCoverMidPct: 20,
              cloudCoverHighPct: 30,
              precipitationProbabilityPct: 5,
              windSpeedKmh: 9,
              windGustsKmh: 18,
              temperatureC: 6.5,
              dewPointC: 2,
              relativeHumidityPct: 78,
              visibilityM: 24000,
            ),
        ],
      ),
    );
  }
}

/// The web's example rig, with the sensor figures the model requires.
const hybridTransferRig = EquipmentProfile(
  id: 0,
  name: 'DSLR · 135 mm lens',
  manufacturer: 'Canon',
  cameraModel: 'EOS 2000D',
  cameraClass: CameraClass.dslrMirrorless,
  sensorWidthMm: 22.3,
  sensorHeightMm: 14.9,
  pixelPitchUm: 3.72,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  focalLengthMm: 135,
  focalRatio: 2.8,
  apertureDiameterMm: 135 / 2.8,
);

class HybridTransferFixture {
  HybridTransferFixture._(this.db, this.vm, this.forecast, this.sessions);

  final AppDatabase db;
  final PlannerHarness vm;
  final HybridTransferForecast forecast;
  final DriftSessionRepository sessions;

  /// Seeds [db] and builds the app's ViewModels on it. One saved plan for
  /// the night (the Home/Plan state of the web reference). Call inside
  /// `tester.runAsync`.
  static Future<HybridTransferFixture> create(
    AppDatabase db, {
    Clock? clock,
    bool savePlan = true,
    // False: a first install's state, no observing site yet.
    bool withSite = true,
  }) async {
    final c = clock ?? FixedClock(hybridTransferNow);
    SharedPreferences.setMockInitialValues({'firstRunDone': true});
    final targets = DriftTargetRepository(db);
    final rigs = DriftEquipmentRepository(db);
    final sites = DriftLocationRepository(db);
    await CatalogSeeder(targets).seedIfNeeded();
    await rigs.insertEquipment(hybridTransferRig);
    if (withSite) {
      final siteId = await sites.insertLocation(
        LocationProfile(
          id: 0,
          name: 'Kyiv outskirts',
          latitude: 50.4,
          longitude: 30.6,
          timeZoneId: 'Europe/Kyiv',
        ),
      );
      SharedPreferences.setMockInitialValues({
        'activeLocationId': siteId,
        'firstRunDone': true,
      });
    }
    final forecast = HybridTransferForecast(c);
    final sessions = DriftSessionRepository(db, clock: c);
    final vm = PlannerHarness(
      targets,
      rigs,
      forecast,
      sites,
      clock: c,
      sessionRepository: sessions,
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      firstRun: InMemoryFirstRun(done: true),
      privacyPreferences: InMemoryPrivacyPreferences(),
      backup: _InertBackup(),
    );
    await vm.ready;
    await vm.choosePlan(target: 'M31');
    await vm.plan.idle;
    await vm.plan.setEveningDate(hybridTransferNight);
    // plan-model.js example: one light block, 120 × 60 s, ISO 800, WB Auto.
    while (vm.plan.captureBlocks.isNotEmpty) {
      await vm.plan.removeCaptureBlock(0);
    }
    await vm.plan.addCaptureBlock(
      CaptureBlock(
        frameType: FrameType.light,
        exposureTimeSeconds: 60,
        frameCount: 120,
        gain: CaptureGain.iso(800),
        whiteBalance: WhiteBalance.auto(),
      ),
    );
    await vm.plan.idle;
    if (savePlan && withSite) await vm.analysis.saveSession();
    await vm.vms.displaySettings.load();
    await vm.tonight.load(hasStoredSite: withSite);
    return HybridTransferFixture._(db, vm, forecast, sessions);
  }

  bool _logbook = false;

  /// The seeded entries' ids by "target night", e.g. "M31 2026-10-12".
  final Map<String, int> logbookIds = {};

  /// The Logbook of the web reference (logbook.js `exampleEntries`): five
  /// nights before the clock's and one ahead, on two sites and three rigs,
  /// with their results; then the planner goes back to the saved plan.
  /// Only the Logbook frames call it. Call inside `tester.runAsync`.
  Future<void> seedLogbook() async {
    if (_logbook) return;
    _logbook = true;
    final main = vm.plan.activeSession!;
    final kyiv = vm.site.activeSite!.id;
    final rigs = DriftEquipmentRepository(db);
    final targets = DriftTargetRepository(db);
    final rural = await DriftLocationRepository(db).insertLocation(
      LocationProfile(
        id: 0,
        name: 'Rural site',
        latitude: 50.8,
        longitude: 30.95,
        elevation: 160,
        timeZoneId: 'Europe/Kyiv',
      ),
    );
    await rigs.insertEquipment(
      const EquipmentProfile(
        id: 0,
        name: 'Phone · wide camera',
        cameraClass: CameraClass.phone,
        sensorWidthMm: 6.4,
        sensorHeightMm: 4.8,
        pixelPitchUm: 1.6,
        resolutionWidthPx: 4000,
        resolutionHeightPx: 3000,
        focalLengthMm: 4.3,
        focalRatio: 1.8,
      ),
    );
    await rigs.insertEquipment(
      const EquipmentProfile(
        id: 0,
        name: 'Astro camera · refractor',
        cameraClass: CameraClass.astroColour,
        cameraModel: 'ZWO ASI2600MC',
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.7,
        pixelPitchUm: 3.76,
        resolutionWidthPx: 6248,
        resolutionHeightPx: 4176,
        focalLengthMm: 400,
        focalRatio: 400 / 72,
        apertureDiameterMm: 72,
      ),
    );
    final allRigs = await rigs.getAllEquipment();
    EquipmentProfile rig(String name) =>
        allRigs.firstWhere((r) => r.name == name);
    CaptureBlock light(String? filter, int s, int n, CaptureGain gain) =>
        CaptureBlock(
          frameType: FrameType.light,
          filterName: filter,
          exposureTimeSeconds: s.toDouble(),
          frameCount: n,
          gain: gain,
        );
    Future<Session> entry(
      String target,
      int site,
      String rigName,
      CalendarDate night,
      List<CaptureBlock> blocks,
    ) async {
      await vm.lifecycle.newSession();
      await vm.site.selectSite(site);
      await vm.plan.setTarget((await targets.searchTargets(target)).first);
      await vm.plan.setEquipment(rig(rigName));
      await vm.plan.setEveningDate(night);
      for (final b in blocks) {
        await vm.plan.addCaptureBlock(b);
      }
      await vm.plan.idle;
      final saved = await vm.analysis.saveSession();
      logbookIds['$target ${night.toIso8601String()}'] = saved.id;
      return saved;
    }

    List<int> lights(Session s) => [
      for (final b in s.blocks)
        if (b.frameType == FrameType.light) b.id,
    ];
    final iso800 = CaptureGain.iso(800);
    await entry(
      'M42',
      rural,
      'DSLR · 135 mm lens',
      CalendarDate(2026, 10, 24),
      [light('Broadband', 90, 80, iso800)],
    );
    await entry('M33', kyiv, 'DSLR · 135 mm lens', CalendarDate(2026, 10, 15), [
      light('Broadband', 60, 150, CaptureGain.iso(1600)),
    ]);
    final m31 = await entry(
      'M31',
      kyiv,
      'DSLR · 135 mm lens',
      CalendarDate(2026, 10, 12),
      [
        light('Broadband', 60, 120, iso800),
        light('Broadband', 120, 30, iso800),
      ],
    );
    final m45 = await entry(
      'M45',
      kyiv,
      'Phone · wide camera',
      CalendarDate(2026, 10, 10),
      [light(null, 10, 200, CaptureGain.unknown())],
    );
    final ngc = await entry(
      'NGC 7000',
      rural,
      'Astro camera · refractor',
      CalendarDate(2026, 10, 8),
      [
        light('Dual-band', 300, 36, CaptureGain.gain(100)),
        light('Dual-band', 300, 12, CaptureGain.gain(200)),
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 300,
          frameCount: 20,
          gain: CaptureGain.gain(100),
        ),
      ],
    );
    final early = await entry(
      'M31',
      rural,
      'DSLR · 135 mm lens',
      CalendarDate(2026, 10, 5),
      [
        light('Broadband', 60, 100, iso800),
        light('Broadband', 30, 40, CaptureGain.unknown()),
      ],
    );
    final [b1, b2] = lights(m31);
    await sessions.recordResult(
      m31.id,
      PartlyDone(
        {b1: 96, b2: 30},
        notes: const ResultNotes(
          environmentalNotes:
              'Cloud from about 01:10; the 60 s block stopped early.',
        ),
      ),
    );
    await sessions.recordResult(
      ngc.id,
      const CompletedAsPlanned(
        notes: ResultNotes(
          processingNotes:
              'Gain 200 frames kept apart from gain 100 when stacking.',
        ),
      ),
    );
    await sessions.recordResult(
      m45.id,
      const NotDone(reason: NotDoneReason.clouds),
    );
    await sessions.recordResult(
      early.id,
      const CompletedAsPlanned(
        notes: ResultNotes(
          environmentalNotes: 'ISO of the 30 s block was not written down.',
        ),
      ),
    );
    await vm.site.selectSite(kyiv);
    await vm.lifecycle.openSession(main, discard: true);
    await vm.plan.idle;
    await vm.vms.sessionList?.refreshDue();
  }
}

/// Backup & data for renders: present, never writing or restoring.
class _InertBackup implements BackupService {
  @override
  Future<bool> backUpAndShare() async => false;
  @override
  Future<({BackupPreview preview, Object file})?> pick() async => null;
  @override
  Future<void> restoreAndRestart(Object file) async {}
  @override
  Future<RestoreOutcome?> outcome() async => null;
  @override
  Future<void> clearOutcome() async {}
}
