import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/details/weather_detail_screen.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_block_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/block_editor_finders.dart';
import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';
import '../../support/wave1_capture.dart';
import '../../support/wave2_fixture.dart';

class _ShortForecast extends HybridTransferForecast {
  _ShortForecast(this.hours) : super(FixedClock(hybridTransferNow));
  final int hours;
  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final result = await super.fetchSnapshot(
      latitude: latitude,
      longitude: longitude,
      startUtc: startUtc,
      endUtc: endUtc,
    );
    if (result is! WeatherFetched) return result;
    final s = result.snapshot;
    return WeatherFetched(
      WeatherSnapshot(
        provider: s.provider,
        model: s.model,
        fetchedAtUtc: s.fetchedAtUtc,
        latitude: s.latitude,
        longitude: s.longitude,
        hours: s.hours.take(hours).toList(),
      ),
    );
  }
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      'UIA-0001 $theme: retained forecast failure keeps values/coverage/age truthful',
      (t) async {
        final f = await mountWave2(t, theme);
        await t.tap(find.byKey(const Key('tonight.openPlanner')));
        await hybridSettle(t);
        final weather = find.byKey(const Key('planner.weather'));
        await revealWave2(t, weather);
        for (final age in [
          Duration.zero,
          const Duration(hours: 4),
          const Duration(hours: 15),
        ]) {
          f.seed.forecast.age = age;
          f.seed.forecast.failure = null;
          await t.runAsync(f.vm.refreshWeather);
          await hybridSettle(t);
          final before = f.vm.conditions.nightWeather as NightWeatherAvailable;
          final value = t.widget<HybridNightRow>(weather).value;
          final complete = f.vm.conditions.nightWeatherSummary!.complete;
          for (final failure in [
            WeatherFailure.malformed,
            WeatherFailure.unavailable,
          ]) {
            f.seed.forecast.failure = failure;
            await t.runAsync(f.vm.refreshWeather);
            await hybridSettle(t);
            final after = f.vm.conditions.nightWeather as NightWeatherAvailable;
            final row = t.widget<HybridNightRow>(weather);
            expect(after.refreshFailed, failure);
            expect(row.extra, contains('Refresh failed'));
            expect(row.extra, contains('cached forecast'));
            expect(row.extra, contains(WeatherText.failure(failure)));
            if (failure == WeatherFailure.malformed) {
              expect(row.extra!.toLowerCase(), isNot(contains('offline')));
            }
            expect(row.extra, contains('updated ${WeatherText.ago(age)}'));
            expect(row.value, value);
            expect(f.vm.conditions.nightWeatherSummary!.complete, complete);
            expect(after.snapshot.fetchedAtUtc, before.snapshot.fetchedAtUtc);
            expect(
              after.snapshot.hours.map((h) => (h.timeUtc, h.cloudCoverPct)),
              before.snapshot.hours.map((h) => (h.timeUtc, h.cloudCoverPct)),
            );
            if ((age == Duration.zero && failure == WeatherFailure.malformed) ||
                (age.inHours == 15 && failure == WeatherFailure.unavailable)) {
              await captureWave1(
                t,
                'wave2-plan-weather-$theme-${age.inHours}-${failure.name}',
              );
            }
          }
        }
        f.seed.forecast.failure = null;
        await t.runAsync(f.vm.refreshWeather);
        await hybridSettle(t);
        expect(
          t.widget<HybridNightRow>(weather).extra,
          isNot(contains('Refresh failed')),
        );
        expect(
          (f.vm.conditions.nightWeather as NightWeatherAvailable).refreshFailed,
          isNull,
        );
      },
    );

    testWidgets(
      'UIA-0004 $theme: short/full/aged snapshots use their actual boundary',
      (t) async {
        for (final (hours, age) in [
          (48, Duration.zero),
          (384, Duration.zero),
          (48, const Duration(hours: 15)),
        ]) {
          final forecast = _ShortForecast(hours)..age = age;
          final f = await mountWave2(
            t,
            theme,
            screen: (_) => const WeatherDetailScreen(),
            weather: forecast,
          );
          await t.runAsync(f.vm.refreshWeather);
          await hybridSettle(t);
          final overview = f.vm.conditions.forecastNights!;
          final beforePlan = f.vm.plan.activeSession!;
          final boundary = overview.firstBeyond;
          final copy = find.byKey(const Key('weather.nights.beyond'));
          if (boundary != null) {
            await revealWave2(t, copy);
            expect(
              t.widget<Text>(copy).data,
              'No forecast in this snapshot from ${NightTimeFormatter.eveningDate(boundary)}. Night and Moon browsing remain available.',
            );
            await captureWave1(t, 'wave2-coming-$theme-$hours-${age.inHours}');
          } else {
            expect(copy, findsNothing);
          }
          expect(f.vm.plan.activeSessionId, beforePlan.id);
          expect(
            f.vm.plan.activeSession!.planSnapshot!.json,
            beforePlan.planSnapshot!.json,
          );
          await f.close(t);
          AppRouter.router.go(AppRouter.tonight);
        }
      },
    );

    testWidgets(
      'UIA-0012 $theme: proposal copy follows available controls and preserves submitted values',
      (t) async {
        await mountWave2(
          t,
          theme,
          screen: (_) => Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                key: const Key('proposal.open'),
                onPressed: () {},
                child: const Text('Open proposal'),
              ),
            ),
          ),
        );
        final context = t.element(find.byKey(const Key('proposal.open')));
        for (final camera in CameraClass.values) {
          final gain = switch (camera.lightSensitivity) {
            LightSensitivity.iso => CaptureGain.iso(800),
            LightSensitivity.gain => CaptureGain.gain(100),
            LightSensitivity.either => CaptureGain.none,
          };
          final proposal = CaptureBlock(
            frameType: FrameType.light,
            exposureTimeSeconds: 120,
            frameCount: 30,
            filterName: 'L',
            binning: camera.offersLightBinning ? 2 : 1,
            gain: gain,
          );
          final future = showCaptureBlockDialog(
            context,
            cameraClass: camera,
            proposal: proposal,
            rigName: 'Synthetic ${camera.label}',
          );
          await hybridSettle(t);
          final copy = t
              .widget<Text>(find.byKey(const Key('blockDialog.proposal')))
              .data!;
          expect(
            copy,
            'Proposed from your last light block. Review the values available for this camera type and change them if needed.',
          );
          expect(copy, isNot(contains('binning')));
          if (camera == CameraClass.unknown) {
            expect(
              find.byKey(const Key('blockDialog.gainValue')),
              findsNothing,
            );
          }
          await captureWave1(
            t,
            'wave2-proposal-$theme-${camera.name.toLowerCase()}',
          );
          await t.enterText(find.byKey(const Key('blockDialog.count')), '20');
          FocusManager.instance.primaryFocus?.unfocus();
          await hybridSettle(t);
          await openBlockDisclosure(t, 'blockDialog.details');
          expect(
            find.byKey(const Key('blockDialog.binning')),
            camera.offersLightBinning ? findsOneWidget : findsNothing,
          );
          await t.tap(find.byKey(const Key('blockDialog.submit')));
          await hybridSettle(t);
          final result = await future;
          expect(result, isNotNull);
          expect(result!.exposureTimeSeconds, proposal.exposureTimeSeconds);
          expect(result.binning, proposal.binning);
          expect(result.gain, proposal.gain);
          expect(result.frameCount, 20);
        }
      },
    );
  }
}
