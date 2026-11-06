import 'dart:async';

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';

import 'package:astroplan/domain/services/target_progress.dart';
import 'package:astroplan/presentation/screens/logbook/progress_screen.dart';
import 'package:astroplan/presentation/shared/failure_feedback.dart';
import 'package:astroplan/presentation/viewmodels/disclosure_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/in_memory_display_preferences.dart';
import '../../../support/wave1_capture.dart';
import '../../../support/phase2_state_capture.dart';

class _HeldProgress extends ChangeNotifier implements SessionsViewModel {
  final reads = <Completer<List<TargetProgress>>>[];
  @override
  Future<List<TargetProgress>> targetProgress() {
    final pending = Completer<List<TargetProgress>>();
    reads.add(pending);
    return pending.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      '$theme Progress known and unknown sensitivity groups stay separate',
      (t) async {
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final vm = _HeldProgress();
        final disclosure = DisclosureViewModel(InMemoryDisplayPreferences());
        addTearDown(vm.dispose);
        addTearDown(disclosure.dispose);
        await t.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SessionsViewModel>.value(value: vm),
              ChangeNotifierProvider<DisclosureViewModel>.value(
                value: disclosure,
              ),
            ],
            child: phase2Frame(
              theme: theme,
              applyFieldFilter: false,
              child: wave1App(theme, home: const ProgressScreen()),
            ),
          ),
        );
        vm.reads.single.complete([
          TargetProgress(
            targetId: 101,
            label:
                'Synthetic long target name with Ukrainian ІЇЄҐ measurements',
            integration: const Duration(hours: 1),
            perFilter: const {'Ha': Duration(hours: 1)},
            lastNight: CalendarDate(2026, 11, 5),
            sessionCount: 2,
            groups: {
              'Ha': [
                ProgressGroup(
                  exposureSeconds: 300,
                  sensitivity: CaptureGain.iso(800),
                  binning: 2,
                  rig: 'Synthetic known rig',
                  frames: 6,
                  integration: const Duration(minutes: 30),
                  nights: {CalendarDate(2026, 11, 5)},
                ),
                const ProgressGroup(
                  exposureSeconds: 300,
                  sensitivity: CaptureGain.none,
                  binning: 1,
                  rig: 'Synthetic unknown rig',
                  frames: 6,
                  integration: Duration(minutes: 30),
                  nights: {1},
                ),
              ],
            },
          ),
        ]);
        await t.pumpAndSettle();
        expect(find.textContaining('ISO 800'), findsOneWidget);
        expect(find.textContaining('bin 2×2'), findsOneWidget);
        await t.ensureVisible(
          find.textContaining('Sensitivity not recorded: kept separate'),
        );
        expect(
          find.textContaining('Sensitivity not recorded: kept separate'),
          findsOneWidget,
        );
        await capturePhase2State(
          t,
          package: 'package2',
          state: 'progress-filter-groups-unknown',
          theme: theme,
        );
        expect(t.takeException(), isNull);
      },
    );
    testWidgets(
      '$theme Progress Retry projects loading then exact recorded totals',
      (t) async {
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final vm = _HeldProgress();
        final disclosure = DisclosureViewModel(InMemoryDisplayPreferences());
        addTearDown(vm.dispose);
        addTearDown(disclosure.dispose);
        await t.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SessionsViewModel>.value(value: vm),
              ChangeNotifierProvider<DisclosureViewModel>.value(
                value: disclosure,
              ),
            ],
            child: phase2Frame(
              theme: theme,
              applyFieldFilter: false,
              child: wave1App(theme, home: const ProgressScreen()),
            ),
          ),
        );
        await t.pump();
        expect(vm.reads, hasLength(1));
        await capturePhase2State(
          t,
          package: 'package2',
          state: 'package2-progress-$theme-pending',
          theme: theme,
        );
        vm.reads[0].completeError(StateError('synthetic unavailable store'));
        await t.pumpAndSettle();
        expect(find.byType(LoadFailureView), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(
          find.textContaining('synthetic unavailable store'),
          findsNothing,
        );
        await capturePhase2State(
          t,
          package: 'package2',
          state: 'package2-progress-$theme-error',
          theme: theme,
        );
        await t.tap(find.text('Retry'));
        await t.pump();
        expect(vm.reads, hasLength(2));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          find.byType(LoadFailureView),
          findsNothing,
          reason:
              'A replacement pending Future must not retain the old failure',
        );
        expect(find.byKey(const Key('progress.empty')), findsNothing);
        vm.reads[1].complete(const [
          TargetProgress(
            targetId: 101,
            label: 'Synthetic target',
            integration: Duration(hours: 1),
            perFilter: {},
            lastNight: null,
            sessionCount: 2,
          ),
        ]);
        await t.pumpAndSettle();
        expect(find.byType(LoadFailureView), findsNothing);
        expect(find.byKey(const Key('progress.101')), findsOneWidget);
        expect(
          t.widget<Text>(find.byKey(const Key('progress.total.101'))).data,
          '1 h',
        );
        expect(find.byKey(const Key('progress.empty')), findsNothing);
        await capturePhase2State(
          t,
          package: 'package2',
          state: 'package2-progress-$theme-recorded',
          theme: theme,
        );
        await t.ensureVisible(find.text('How totals are grouped'));
        await t.tap(find.text('How totals are grouped'));
        await t.pumpAndSettle();
        expect(find.textContaining('This is integration time'), findsOneWidget);
        await capturePhase2State(
          t,
          package: 'package2',
          state: 'package2-progress-$theme-guide',
          theme: theme,
        );
        await t.pumpWidget(const SizedBox.shrink());
      },
    );
    testWidgets('$theme Progress empty is not a read failure', (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final vm = _HeldProgress();
      addTearDown(vm.dispose);
      await t.pumpWidget(
        ChangeNotifierProvider<SessionsViewModel>.value(
          value: vm,
          child: phase2Frame(
            theme: theme,
            applyFieldFilter: false,
            child: wave1App(theme, home: const ProgressScreen()),
          ),
        ),
      );
      vm.reads.single.complete([]);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('progress.empty')), findsOneWidget);
      expect(find.byType(LoadFailureView), findsNothing);
      await capturePhase2State(
        t,
        package: 'package2',
        state: 'package2-progress-$theme-empty',
        theme: theme,
      );
    });
  }
}
