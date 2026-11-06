// Widget tests for the location picker (TASK 7.2): permission outcomes are
// explained with the right remedy, coordinates can be typed (offline, no
// permission needed), and the OpenStreetMap attribution is visible.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../../support/phase2_state_capture.dart';
import '../../../support/wave1_capture.dart';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/presentation/screens/location/location_picker_screen.dart';
import 'package:astroplan/presentation/shared/location_failure_text.dart';

import '../../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

late String _phase2Theme;

ThemeData get _phase2ThemeData => phase2Theme(_phase2Theme);

Widget _phase2Builder(BuildContext context, Widget? child) =>
    phase2Frame(child: child!, theme: _phase2Theme);

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    group('Phase2 $theme', () {
      setUp(() => _phase2Theme = theme);
      late AppDatabase database;
      late PlannerHarness vm;
      late FakeLocationService service;

      setUp(() {
        SharedPreferences.setMockInitialValues({});
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              (call) async => Directory.systemTemp.path,
            );
      });
      tearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              null,
            ),
      );

      Future<void> pumpPicker(
        WidgetTester tester, {
        DeviceLocation? location,
        LocationFailure failure = LocationFailure.permissionDenied,
        Future<LocationResult> Function()? answer,
      }) async {
        service = FakeLocationService(
          location: location,
          failure: failure,
          answer: answer,
        );
        await tester.runAsync(() async {
          database = AppDatabase(NativeDatabase.memory());
          vm = PlannerHarness(
            DriftTargetRepository(database),
            DriftEquipmentRepository(database),
            _NoWeather(),
            DriftLocationRepository(database),
            locationService: service,
            reverseGeocoder: FakeReverseGeocoder(),
          );
          await vm.ready;
        });
        addTearDown(() => tester.runAsync(database.close));
        await tester.pumpWidget(
          MultiProvider(
            providers: vm.providers,
            child: MaterialApp(
              theme: _phase2ThemeData,
              builder: _phase2Builder,
              home: const LocationPickerScreen(),
            ),
          ),
        );
        await tester.pump();
      }

      Future<void> tapCurrentLocation(WidgetTester tester) async {
        await tester.tap(find.byKey(const Key('location.useCurrentPosition')));
        await tester.pump();
        // Let the snack bar finish sliding in.
        await tester.pump(const Duration(seconds: 1));
      }

      testWidgets(
        'pending GPS shows progress and timeout restores controls without selecting',
        (tester) async {
          tester.view.physicalSize = const Size(375, 812);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final gate = Completer<LocationResult>();
          await pumpPicker(tester, answer: () => gate.future);
          final before = (vm.latitude, vm.longitude);
          final initialMarker = tester
              .widget<MarkerLayer>(find.byType(MarkerLayer))
              .markers
              .single
              .point;
          expect((initialMarker.latitude, initialMarker.longitude), before);
          await tapCurrentLocation(tester);
          expect(service.calls, 1);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const Key('location.useCurrentPosition')),
                )
                .onPressed,
            isNull,
          );
          expect(
            tester
                .widget<TextButton>(
                  find.byKey(const Key('location.coordinates')),
                )
                .onPressed,
            isNotNull,
          );
          await capturePhase2State(
            tester,
            package: 'package3',
            state: 'map-gps-pending',
            theme: _phase2Theme,
          );
          gate.completeError(TimeoutException('synthetic GPS timeout'));
          await tester.pumpAndSettle();
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(
            find.text("Couldn't get your position. Please try again."),
            findsOneWidget,
          );
          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const Key('location.useCurrentPosition')),
                )
                .onPressed,
            isNotNull,
          );
          expect((vm.latitude, vm.longitude), before);
          await capturePhase2State(
            tester,
            package: 'package3',
            state: 'map-gps-timeout-unchanged-position',
            theme: _phase2Theme,
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'selected point uses a small dot without a large icon backing',
        (tester) async {
          await pumpPicker(tester);
          final marker = tester
              .widget<MarkerLayer>(find.byType(MarkerLayer))
              .markers
              .single;
          expect(marker.width, 12);
          expect(marker.height, 12);
          expect(find.byKey(const Key('location.marker')), findsOneWidget);
          expect(
            find.byKey(const Key('location.useCurrentPosition')),
            findsOneWidget,
          );
          expect(find.textContaining('OpenStreetMap'), findsOneWidget);
          expect(
            service.calls,
            0,
            reason: 'opening the map never requests GPS',
          );
        },
      );

      testWidgets(
        'a permanently denied permission explains and opens app settings',
        (tester) async {
          await pumpPicker(
            tester,
            failure: LocationFailure.permissionDeniedForever,
          );
          final startupCalls = service.calls;

          await tapCurrentLocation(tester);

          expect(service.calls, startupCalls + 1);
          expect(
            find.text(
              LocationFailureText.message(
                LocationFailure.permissionDeniedForever,
              ),
            ),
            findsOneWidget,
          );
          await tester.tap(find.text('Open settings'));
          await tester.pump();
          expect(service.appSettingsOpened, 1);
          expect(service.locationSettingsOpened, 0);
        },
      );

      testWidgets(
        'location services off explains and opens location settings',
        (tester) async {
          await pumpPicker(tester, failure: LocationFailure.serviceDisabled);

          await tapCurrentLocation(tester);

          expect(
            find.text(
              LocationFailureText.message(LocationFailure.serviceDisabled),
            ),
            findsOneWidget,
          );
          await tester.tap(find.text('Open settings'));
          await tester.pump();
          expect(service.locationSettingsOpened, 1);
        },
      );

      // TD-073, decided in S6.13: a failure the user can fix in settings stays
      // until they act on it or close it; one without an action times out.
      testWidgets('a failure with "Open settings" stays until closed; one '
          'without times out', (tester) async {
        await pumpPicker(
          tester,
          failure: LocationFailure.permissionDeniedForever,
        );
        await tapCurrentLocation(tester);
        final fixable = find.text(
          LocationFailureText.message(LocationFailure.permissionDeniedForever),
        );
        await tester.pump(const Duration(seconds: 20));
        expect(fixable, findsOneWidget, reason: 'kept until dismissed');
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(fixable, findsNothing, reason: 'the close button dismisses it');
      });

      testWidgets('a failure without a settings action times out (TD-073)', (
        tester,
      ) async {
        await pumpPicker(tester, failure: LocationFailure.permissionDenied);
        await tapCurrentLocation(tester);
        final plain = find.text(
          LocationFailureText.message(LocationFailure.permissionDenied),
        );
        expect(plain, findsOneWidget);
        await tester.pump(const Duration(seconds: 9));
        await tester.pumpAndSettle();
        expect(plain, findsNothing);
      });

      testWidgets('a plain denial explains why, with no settings action', (
        tester,
      ) async {
        await pumpPicker(tester, failure: LocationFailure.permissionDenied);

        await tapCurrentLocation(tester);

        expect(
          find.text(
            LocationFailureText.message(LocationFailure.permissionDenied),
          ),
          findsOneWidget,
        );
        expect(find.text('Open settings'), findsNothing);
      });

      testWidgets(
        'granted: the fix moves the marker but is not used until confirmed',
        (tester) async {
          await pumpPicker(
            tester,
            location: const DeviceLocation(latitude: 46.05, longitude: 14.51),
          );
          final before = (vm.latitude, vm.longitude);

          await tapCurrentLocation(tester);

          final marker = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
          expect(marker.markers.single.point.latitude, 46.05);
          expect(marker.markers.single.point.longitude, 14.51);
          expect((vm.latitude, vm.longitude), before);
        },
      );

      for (final (width, scale) in [(375.0, 1.0), (320.0, 2.0)]) {
        testWidgets(
          'typed coordinates are validated and move the marker $width dp ${scale * 100} percent',
          (tester) async {
            tester.view.physicalSize = Size(width, 812);
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await pumpPicker(tester);

            await tester.tap(find.byKey(const Key('location.coordinates')));
            await tester.pumpAndSettle();
            final fields = find.byType(TextFormField);
            await tester.enterText(fields.at(0), '95');
            await tester.enterText(fields.at(1), '14.51');
            await tester.ensureVisible(find.text('Use'));
            await tester.pumpAndSettle();
            expect(find.text('Use').hitTestable(), findsOneWidget);
            expect(find.text('Cancel').hitTestable(), findsOneWidget);
            await tester.tap(find.text('Use').hitTestable());
            await tester.pump();
            expect(
              find.text('Latitude must be between -90 and 90'),
              findsOneWidget,
            );

            final latitudeError = tester.renderObject<RenderParagraph>(
              find.descendant(
                of: find.text('Latitude must be between -90 and 90'),
                matching: find.byType(RichText),
              ),
            );
            expect(latitudeError.didExceedMaxLines, isFalse);
            await capturePhase2State(
              tester,
              package: 'package3',
              state:
                  'map-invalid-latitude-${width.toInt()}-${(scale * 100).toInt()}pct',
              theme: _phase2Theme,
            );
            await tester.enterText(fields.at(0), '46,05');
            await tester.enterText(fields.at(1), '181');
            await tester.ensureVisible(find.text('Use'));
            await tester.pumpAndSettle();
            expect(find.text('Use').hitTestable(), findsOneWidget);
            expect(find.text('Cancel').hitTestable(), findsOneWidget);
            await tester.tap(find.text('Use').hitTestable());
            await tester.pumpAndSettle();
            expect(
              find.text('Longitude must be between -180 and 180'),
              findsOneWidget,
            );
            expect(find.byType(AlertDialog), findsOneWidget);
            final longitudeError = tester.renderObject<RenderParagraph>(
              find.descendant(
                of: find.text('Longitude must be between -180 and 180'),
                matching: find.byType(RichText),
              ),
            );
            expect(longitudeError.didExceedMaxLines, isFalse);
            expect(
              tester
                  .getRect(find.text('Decimal degrees, north positive'))
                  .bottom,
              lessThanOrEqualTo(tester.getRect(find.text('Longitude (°)')).top),
            );
            await capturePhase2State(
              tester,
              package: 'package3',
              state:
                  'map-invalid-longitude-${width.toInt()}-${(scale * 100).toInt()}pct',
              theme: _phase2Theme,
            );
            await tester.enterText(fields.at(1), '14.51');
            await tester.ensureVisible(find.text('Use'));
            await tester.pumpAndSettle();
            expect(find.text('Use').hitTestable(), findsOneWidget);
            expect(find.text('Cancel').hitTestable(), findsOneWidget);
            await tester.tap(find.text('Use').hitTestable());
            await tester.pumpAndSettle();

            expect(find.byType(AlertDialog), findsNothing);
            final marker = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
            expect(marker.markers.single.point.latitude, 46.05);
            expect(marker.markers.single.point.longitude, 14.51);
          },
        );
      }

      testWidgets('the map shows the OpenStreetMap attribution', (
        tester,
      ) async {
        await pumpPicker(tester);

        expect(find.text('OpenStreetMap contributors'), findsOneWidget);
        final tiles = tester.widget<TileLayer>(find.byType(TileLayer));
        expect(
          tiles.tileProvider.headers['User-Agent'],
          AppIdentity.userAgent, // with a contact URL (TASK 16.3)
        );
      });
    });
  }
}
