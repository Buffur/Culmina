import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/plan_state.dart';
import 'package:astroplan/presentation/widgets/capture_plan/plan_overrides_editor.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/hybrid_transfer_fixture.dart';
import '../../../support/hybrid_transfer_shots.dart';
import '../../../support/in_memory_first_run.dart';
import '../../../support/in_memory_privacy_preferences.dart';
import '../../../support/planner_harness.dart';
import '../../../support/wave1_capture.dart';

class _HeldWrites extends DriftSessionRepository {
  _HeldWrites(super.db) : super(clock: FixedClock(hybridTransferNow));
  bool hold = false;
  final writes = <({int id, SessionPlan plan, Completer<void> gate})>[];

  @override
  Future<Session> updatePlan(int id, SessionPlan plan) async {
    if (hold) {
      final gate = Completer<void>();
      writes.add((id: id, plan: plan, gate: gate));
      await gate.future;
    }
    return super.updatePlan(id, plan);
  }
}

Future<({HybridTransferFixture seed, PlannerHarness vm, _HeldWrites repo})>
_mount(WidgetTester t, String theme) async {
  if (!wave1IsNative) {
    t.view.physicalSize = const Size(375, 812);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }
  t.platformDispatcher.platformBrightnessTestValue = theme == 'light'
      ? Brightness.light
      : Brightness.dark;
  addTearDown(t.platformDispatcher.clearAllTestValues);
  late HybridTransferFixture seed;
  late PlannerHarness vm;
  late _HeldWrites repo;
  await t.runAsync(() async {
    seed = await HybridTransferFixture.create(
      AppDatabase(NativeDatabase.memory()),
    );
    repo = _HeldWrites(seed.db);
    vm = PlannerHarness(
      DriftTargetRepository(seed.db),
      DriftEquipmentRepository(seed.db),
      seed.forecast,
      DriftLocationRepository(seed.db),
      clock: FixedClock(hybridTransferNow),
      sessionRepository: repo,
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      firstRun: InMemoryFirstRun(done: true),
      privacyPreferences: InMemoryPrivacyPreferences(),
    );
    await vm.ready;
    await vm.plan.idle;
    if (theme == 'field') await vm.theme.toggleFieldMode();
  });
  addTearDown(() async {
    await t.pumpWidget(const SizedBox.shrink());
    repo.hold = false;
    for (final write in repo.writes) {
      if (!write.gate.isCompleted) write.gate.complete();
    }
    await hybridSettle(t);
    await t.runAsync(() async {
      vm.dispose();
      seed.vm.dispose();
      await seed.db.close();
    });
  });
  AppRouter.router.go(AppRouter.tonight);
  await t.pumpWidget(
    RepaintBoundary(
      key: wave1CaptureKey,
      child: MultiProvider(
        providers: vm.providers,
        child: const AstroPlanApp(),
      ),
    ),
  );
  await hybridSettle(t);
  return (seed: seed, vm: vm, repo: repo);
}

Future<void> _tap(WidgetTester t, String key) async {
  final target = find.byKey(Key(key));
  if (target.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      target,
      300,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
  await t.ensureVisible(target);
  await hybridSettle(t);
  await t.tap(target);
  await hybridSettle(t);
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      'UIA-0018: $theme working target pending, failure, recovery, explicit Save',
      (t) async {
        final f = await _mount(t, theme);
        final original = f.vm.plan.activeSession!;
        final m42 = (await t.runAsync(
          () => DriftTargetRepository(f.seed.db).searchTargets('M42'),
        ))!.single;
        f.repo.hold = true;
        final edit = f.vm.plan.setTarget(m42);
        await hybridSettle(t);
        expect(f.repo.writes, hasLength(1));
        final badge = find.byKey(const Key('tonight.planState'));
        await Scrollable.ensureVisible(t.element(badge), alignment: 0.2);
        await hybridSettle(t);
        expect(t.widget<PlanStateLabel>(badge).state, PlanState.savedChanged);
        expect(f.vm.plan.hasUnsavedChanges, isTrue);
        expect(PlanState.of(original), PlanState.saved);
        await captureWave1(t, 'tonight-$theme-pending');
        await t.runAsync(() async {
          final stored = (await f.repo.get(original.id))!;
          expect(stored.status, SessionStatus.planned);
          expect(stored.targetId, original.targetId);
          f.repo.writes.last.gate.completeError(
            const StorageFailure('synthetic draft write'),
          );
        });
        await hybridSettle(t);
        await edit;
        expect(t.widget<PlanStateLabel>(badge).state, PlanState.savedChanged);
        expect(f.vm.plan.selectedTarget!.id, m42.id);
        expect(f.vm.plan.autosaveFailure, isA<StorageFailure>());
        await captureWave1(t, 'tonight-$theme-failure');
        final recovery = f.vm.plan.setTarget(m42);
        await hybridSettle(t);
        expect(f.repo.writes, hasLength(2));
        f.repo.writes.last.gate.complete();
        await hybridSettle(t);
        await recovery;
        await t.runAsync(() async {
          final stored = (await f.repo.get(original.id))!;
          expect(stored.targetId, m42.id);
          expect(stored.status, SessionStatus.draft);
          expect(stored.id, original.id);
          expect(stored.eveningDate, original.eveningDate);
          expect(stored.plannedAtUtc, original.plannedAtUtc);
          expect(stored.planSnapshot!.json, original.planSnapshot!.json);
        });
        await hybridSettle(t);
        expect(f.vm.plan.autosaveFailure, isNull);
        expect(t.widget<PlanStateLabel>(badge).state, PlanState.savedChanged);
        await captureWave1(t, 'tonight-$theme-recovered');
        await _tap(t, 'tonight.openPlanner');
        expect(find.text('Saved · changed'), findsOneWidget);
        await t.ensureVisible(find.byKey(const Key('planner.save')));
        expect(find.text('Changes are not saved yet.'), findsOneWidget);
        await captureWave1(t, 'planner-$theme-changed');
        f.repo.hold = false;
        await t.runAsync(f.vm.analysis.saveSession);
        await hybridSettle(t);
        expect(f.vm.plan.activeSessionId, original.id);
        expect(f.vm.plan.hasUnsavedChanges, isFalse);
        expect(find.text('Saved'), findsOneWidget);
      },
    );

    testWidgets(
      'UIA-0003: $theme assumptions Apply freezes input and supports retry/reopen/discard',
      (t) async {
        final f = await _mount(t, theme);
        final original = f.vm.plan.activeSession!;
        await _tap(t, 'tonight.openPlanner');
        await _tap(t, 'section.planner.budgetDetails');
        await _tap(t, 'planOverride.edit');
        final field = find.byKey(const Key('planOverride.0'));
        await t.enterText(field, '7.5');
        f.repo.hold = true;
        await _tap(t, 'planOverride.apply');
        expect(f.repo.writes, hasLength(1));
        expect(f.repo.writes.single.plan.planOverrides!.interframeSeconds, 7.5);
        for (final input in t.widgetList<TextFormField>(
          find.byType(TextFormField),
        )) {
          expect(input.enabled, isFalse);
        }
        await t.tap(field, warnIfMissed: false);
        await t.pump();
        if (!wave1IsNative) expect(t.testTextInput.hasAnyClients, isFalse);
        await t.binding.handlePopRoute();
        await hybridSettle(t);
        expect(find.byType(PlanOverridesEditor), findsOneWidget);
        expect(find.text('Discard this edit?'), findsNothing);
        await captureWave1(t, 'assumptions-$theme-pending');
        await t.runAsync(() async {
          f.repo.writes.last.gate.completeError(
            const StorageFailure('synthetic Apply'),
          );
          await Future<void>.delayed(const Duration(milliseconds: 40));
        });
        await hybridSettle(t);
        expect(find.byType(PlanOverridesEditor), findsOneWidget);
        expect(t.widget<TextFormField>(field).enabled, isTrue);
        expect(t.widget<TextFormField>(field).controller!.text, '7.5');
        await t.runAsync(
          () async => expect(
            (await f.repo.get(original.id))!.planOverrides,
            original.planOverrides,
          ),
        );
        await t.enterText(field, '12');
        await _tap(t, 'planOverride.apply');
        expect(f.repo.writes, hasLength(2));
        expect(f.repo.writes.last.plan.planOverrides!.interframeSeconds, 12);
        await t.runAsync(() async {
          f.repo.writes.last.gate.complete();
          await Future<void>.delayed(const Duration(milliseconds: 40));
        });
        await hybridSettle(t);
        expect(find.byType(PlanOverridesEditor), findsNothing);
        expect(
          find.textContaining("Couldn't apply the plan assumptions"),
          findsNothing,
        );
        await t.runAsync(() async {
          final stored = (await f.repo.get(original.id))!;
          expect(stored.planOverrides!.interframeSeconds, 12);
          expect(stored.planSnapshot!.json, original.planSnapshot!.json);
          expect(stored.plannedAtUtc, original.plannedAtUtc);
        });
        await _tap(t, 'planOverride.edit');
        expect(t.widget<TextFormField>(field).controller!.text, '12');
        await captureWave1(t, 'assumptions-$theme-reopened');
        await t.enterText(field, '15');
        await t.pump();
        await t.binding.handlePopRoute();
        await hybridSettle(t);
        await t.tap(find.text('Keep editing'));
        await hybridSettle(t);
        expect(t.widget<TextFormField>(field).controller!.text, '15');
        await t.binding.handlePopRoute();
        await hybridSettle(t);
        await t.tap(find.text('Discard edit'));
        await hybridSettle(t);
        expect(find.byType(PlanOverridesEditor), findsNothing);
        expect(f.repo.writes, hasLength(2));
      },
    );
  }
}
