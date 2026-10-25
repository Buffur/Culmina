import 'dart:async';
import 'dart:io';

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/location/location_picker_screen.dart';
import 'package:astroplan/presentation/screens/sites/site_editor_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../support/hybrid_transfer_fixture.dart';
import '../../../support/hybrid_transfer_shots.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProvider,
          (_) async => Directory.systemTemp.path,
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, null);
  });
  for (final mode in ['map', 'dialog', 'latitude', 'cancel']) {
    testWidgets('SiteEditor exact coordinate roundtrip $mode', (t) async {
      late HybridTransferFixture fixture;
      late LocationProfile original;
      await t.runAsync(() async {
        fixture = await HybridTransferFixture.create(
          AppDatabase(NativeDatabase.memory()),
        );
        await fixture.vm.site.saveSite(
          LocationProfile(
            id: 0,
            name: 'Synthetic precise site',
            latitude: 12.345678901,
            longitude: -23.456789012,
            timeZoneId: 'Europe/Kyiv',
          ),
          activate: false,
        );
        original = fixture.vm.site.sites.singleWhere(
          (s) => s.name == 'Synthetic precise site',
        );
      });
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Scaffold()),
          GoRoute(
            path: AppRouter.siteEdit,
            builder: (_, state) =>
                SiteEditorScreen(args: state.extra! as SiteEditorArgs),
          ),
          GoRoute(
            path: AppRouter.sitePick,
            builder: (_, state) => LocationPickerScreen(
              pickOnly: true,
              initial: state.extra as LatLng?,
            ),
          ),
        ],
      );
      addTearDown(() async {
        await t.pumpWidget(const SizedBox.shrink());
        router.dispose();
        fixture.vm.dispose();
        await t.runAsync(fixture.db.close);
      });
      await t.pumpWidget(
        MultiProvider(
          providers: fixture.vm.providers,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      unawaited(
        router.push(
          AppRouter.siteEdit,
          extra: SiteEditorArgs(site: original, activate: false),
        ),
      );
      await hybridSettle(t);
      await t.tap(find.byKey(const Key('siteEditor.pickOnMap')));
      await t.pumpAndSettle();
      var point = t
          .widget<MarkerLayer>(find.byType(MarkerLayer))
          .markers
          .single
          .point;
      expect(
        point.latitude,
        original.latitude,
        reason: 'Map initial must not parse rounded display',
      );
      expect(point.longitude, original.longitude);
      if (mode != 'map') {
        await t.tap(find.byKey(const Key('location.coordinates')));
        await t.pumpAndSettle();
        if (mode == 'latitude' || mode == 'cancel') {
          final fields = find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextFormField),
          );
          await t.enterText(fields.at(0), '-11.123456789');
        }
        await t.tap(find.text(mode == 'cancel' ? 'Cancel' : 'Use'));
        await t.pumpAndSettle();
      }
      point = t
          .widget<MarkerLayer>(find.byType(MarkerLayer))
          .markers
          .single
          .point;
      expect(
        point.latitude,
        mode == 'latitude' ? -11.123456789 : original.latitude,
      );
      expect(point.longitude, original.longitude);
      await t.tap(find.byKey(const Key('location.usePoint')));
      await hybridSettle(t);
      await t.tap(find.byKey(const Key('siteEditor.save')));
      await hybridSettle(t);
      final saved = fixture.vm.site.sites.singleWhere(
        (s) => s.id == original.id,
      );
      expect(
        saved.latitude,
        mode == 'latitude' ? -11.123456789 : original.latitude,
      );
      expect(saved.longitude, original.longitude);
      expect(saved.timeZoneId, original.timeZoneId);
      expect(saved.name, original.name);
      expect(find.byType(SiteEditorScreen), findsNothing);
      expect(t.takeException(), isNull);
    });
  }
}
