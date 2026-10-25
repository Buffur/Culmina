import 'dart:async';

import 'package:astroplan/domain/services/target_progress.dart';
import 'package:astroplan/presentation/screens/logbook/progress_screen.dart';
import 'package:astroplan/presentation/shared/failure_feedback.dart';
import 'package:astroplan/presentation/viewmodels/disclosure_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/in_memory_display_preferences.dart';

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
  testWidgets('Progress Retry projects loading then exact recorded totals', (
    t,
  ) async {
    final vm = _HeldProgress();
    final disclosure = DisclosureViewModel(InMemoryDisplayPreferences());
    addTearDown(vm.dispose);
    addTearDown(disclosure.dispose);
    await t.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessionsViewModel>.value(value: vm),
          ChangeNotifierProvider<DisclosureViewModel>.value(value: disclosure),
        ],
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
    await t.pump();
    expect(vm.reads, hasLength(1));
    vm.reads[0].completeError(StateError('synthetic unavailable store'));
    await t.pumpAndSettle();
    expect(find.byType(LoadFailureView), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('synthetic unavailable store'), findsNothing);
    await t.tap(find.text('Retry'));
    await t.pump();
    expect(vm.reads, hasLength(2));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byType(LoadFailureView),
      findsNothing,
      reason: 'A replacement pending Future must not retain the old failure',
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
    await t.pumpWidget(const SizedBox.shrink());
  });
}
