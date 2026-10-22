// Test-only data for the Hybrid transfer's web/Flutter pairs (2026-10-22).
// It mirrors the web reference's demonstration records where the production
// model can hold them: Kyiv outskirts (50.4, 30.6, Europe/Kyiv), the night of
// 19 Oct 2026, M31 with a DSLR on a 135 mm lens, one ISO 800 light block.
// Numbers come from the real calculations, not from the browser's demo
// model. Never imported by application code.
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
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (
            var t = first;
            t.isBefore(endUtc);
            t = t.add(const Duration(hours: 1))
          )
            WeatherHour(
              timeUtc: t,
              cloudCoverPct: (t.hour * 7 % 60).toDouble(),
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
  }) async {
    final c = clock ?? FixedClock(hybridTransferNow);
    SharedPreferences.setMockInitialValues({'firstRunDone': true});
    final targets = DriftTargetRepository(db);
    final rigs = DriftEquipmentRepository(db);
    final sites = DriftLocationRepository(db);
    await CatalogSeeder(targets).seedIfNeeded();
    await rigs.insertEquipment(hybridTransferRig);
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
    if (savePlan) await vm.analysis.saveSession();
    await vm.vms.displaySettings.load();
    await vm.tonight.load(hasStoredSite: true);
    return HybridTransferFixture._(db, vm, forecast, sessions);
  }
}
