import 'package:astroplan/presentation/screens/location/location_picker_screen.dart';
import 'package:astroplan/presentation/viewmodels/site_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class _Site extends ChangeNotifier implements SiteViewModel {
  @override
  double get latitude => 44.123456789;
  @override
  double get longitude => -13.987654321;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final axis in ['none', 'latitude', 'longitude', 'cancel']) {
    testWidgets('coordinate dialog preserves untouched axes: $axis', (t) async {
      final site = _Site();
      addTearDown(site.dispose);
      const original = LatLng(44.123456789, -13.987654321);
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        ChangeNotifierProvider<SiteViewModel>.value(
          value: site,
          child: const MaterialApp(
            home: LocationPickerScreen(initial: original),
          ),
        ),
      );
      await t.pump();
      await t.tap(find.byKey(const Key('location.coordinates')));
      await t.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      if (axis == 'latitude' || axis == 'cancel') {
        await t.enterText(fields.at(0), '-12.345678901');
      }
      if (axis == 'longitude') {
        await t.enterText(fields.at(1), '23.456789012');
      }
      await t.tap(find.text(axis == 'cancel' ? 'Cancel' : 'Use'));
      await t.pumpAndSettle();
      final point = t
          .widget<MarkerLayer>(find.byType(MarkerLayer))
          .markers
          .single
          .point;
      expect(
        point.latitude,
        axis == 'latitude' ? -12.345678901 : original.latitude,
      );
      expect(
        point.longitude,
        axis == 'longitude' ? 23.456789012 : original.longitude,
      );
      await t.pumpWidget(const SizedBox.shrink());
    });
  }
}
