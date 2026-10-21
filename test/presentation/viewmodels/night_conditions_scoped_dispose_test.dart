// The Night, Moon and Weather browser owns a scoped NightConditionsViewModel
// (`forViewedNight`) that listens to the site, the plan, the settings and
// the browsed night. Once its route is gone and it is disposed, none of them
// may reach it: a later plan edit (a new plan, say) or a browsed-night
// change must not notify a disposed ViewModel. (The migration's
// accessibility sweep found the listener left registered: an extension
// method's tear-off is a new closure each time, so `removeListener` never
// matched it.)

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  testWidgets('a disposed scoped conditions ViewModel is no longer notified '
      'by the plan or the browsed night', (tester) async {
    SharedPreferences.setMockInitialValues({});
    late AppDatabase db;
    late PlannerHarness vm;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoWeather(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(const SizedBox());

    final browsed = ValueNotifier(0);
    addTearDown(browsed.dispose);
    final scoped = vm.conditions.forViewedNight(
      night: () => null,
      changes: browsed,
    );
    var notified = 0;
    scoped.addListener(() => notified++);
    vm.plan.markChanged();
    browsed.value++;
    expect(notified, 2, reason: 'while alive it follows its inputs');

    scoped.dispose();
    vm.plan.markChanged();
    browsed.value++;
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(notified, 2);
  });
}
