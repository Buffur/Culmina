import 'dart:async';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/presentation/screens/target/target_editor_screen.dart';
import 'package:astroplan/presentation/shared/confirmation_patterns.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/wave1_capture.dart';

class _HeldTargets extends DriftTargetRepository {
  _HeldTargets(super.db);
  Completer<void>? gate;
  final submitted = <AstroTarget>[];

  @override
  Future<void> updateTarget(AstroTarget target) async {
    submitted.add(target);
    await gate?.future;
    await super.updateTarget(target);
  }

  @override
  Future<int> insertTarget(AstroTarget target) async {
    if (gate != null) {
      submitted.add(target);
      await gate!.future;
    }
    return super.insertTarget(target);
  }
}

void main() {
  setUpAll(loadWave1Font);
  for (final (creating, theme) in [
    for (final theme in ['light', 'dark', 'field'])
      for (final creating in [false, true]) (creating, theme),
  ]) {
    testWidgets(
      'UIA-0003: $theme held ${creating ? 'add' : 'update'} owns input and Back',
      (t) async {
        if (!wave1IsNative) {
          t.view.physicalSize = const Size(375, 812);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
        }
        final db = AppDatabase(NativeDatabase.memory());
        final repo = _HeldTargets(db);
        final vm = TargetsViewModel(repo);
        addTearDown(() => t.runAsync(db.close));
        addTearDown(vm.dispose);
        late AstroTarget original;
        await t.runAsync(() async {
          final id = await repo.insertTarget(
            const AstroTarget(
              id: 0,
              catalogId: 'QA-exact',
              commonName: 'Original',
              type: 'Galaxy',
              rightAscension: 83.820833333,
              declination: -5.391111111,
              source: 'user',
              magnitude: 3.44,
              angularSizeArcmin: 42.17,
            ),
          );
          original = (await repo.getTargetById(id))!;
        });
        final nav = GlobalKey<NavigatorState>();
        AstroTarget? result;
        await t.pumpWidget(
          ChangeNotifierProvider.value(
            value: vm,
            child: wave1App(
              theme,
              navigatorKey: nav,
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async => result = await showTargetEditor(
                      context,
                      existing: creating ? null : original,
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await t.tap(find.text('Open'));
        await t.pumpAndSettle();
        await t.enterText(
          find.byKey(const Key('targetEditor.name')),
          'Submitted',
        );
        if (creating) {
          await t.enterText(
            find.byKey(const Key('targetEditor.ra')),
            '5.588 h',
          );
          await t.enterText(find.byKey(const Key('targetEditor.dec')), '-5.39');
        }
        repo.gate = Completer<void>();
        await t.tap(find.byKey(const Key('targetEditor.save')));
        await t.pump();
        expect(repo.submitted, hasLength(1));
        for (final field in t.widgetList<TextFormField>(
          find.byType(TextFormField),
        )) {
          expect(field.enabled, isFalse);
        }
        expect(
          t
              .widget<DropdownButtonFormField<String>>(
                find.byKey(const Key('targetEditor.type')),
              )
              .onChanged,
          isNull,
        );
        await t.tap(
          find.byKey(const Key('targetEditor.name')),
          warnIfMissed: false,
        );
        await t.pump();
        if (!wave1IsNative) expect(t.testTextInput.hasAnyClients, isFalse);
        await captureWave1(
          t,
          'target-$theme-${creating ? 'add' : 'update'}-pending',
        );
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(find.text('Unsaved changes'), findsNothing);
        expect(find.byType(TargetEditorScreen), findsOneWidget);

        // An unrelated typed modal must never receive the target result.
        final modal = showDialog<UnsavedChoice>(
          context: nav.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Independent modal'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, UnsavedChoice.cancel),
                child: const Text('Close modal'),
              ),
            ],
          ),
        );
        await t.pumpAndSettle();
        await t.runAsync(() async {
          repo.gate!.complete();
          await Future<void>.delayed(const Duration(milliseconds: 80));
        });
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.text('Independent modal'), findsOneWidget);
        await t.tap(find.text('Close modal'));
        await t.pumpAndSettle();
        expect(await modal, UnsavedChoice.cancel);
        expect(result?.commonName, 'Submitted');
        expect(repo.submitted, hasLength(1));
        await t.runAsync(() async {
          final stored = (await repo.getTargetById(result!.id))!;
          expect(stored.commonName, 'Submitted');
          expect(stored.rightAscension, repo.submitted.single.rightAscension);
          expect(stored.declination, repo.submitted.single.declination);
          if (!creating) {
            expect(stored.catalogId, original.catalogId);
            expect(stored.source, original.source);
            expect(stored.rightAscension, original.rightAscension);
            expect(stored.declination, original.declination);
          }
        });
      },
    );
  }

  testWidgets(
    'UIA-0003: failure keeps draft, retry writes only visible input',
    (t) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = _HeldTargets(db);
      final vm = TargetsViewModel(repo);
      addTearDown(() => t.runAsync(db.close));
      addTearDown(vm.dispose);
      late AstroTarget original;
      await t.runAsync(() async {
        final id = await repo.insertTarget(
          const AstroTarget(
            id: 0,
            catalogId: 'QA',
            commonName: 'Original',
            type: 'Galaxy',
            rightAscension: 1.123456789,
            declination: 2.987654321,
            source: 'user',
          ),
        );
        original = (await repo.getTargetById(id))!;
      });
      await t.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () =>
                      showTargetEditor(context, existing: original),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Open'));
      await t.pumpAndSettle();
      final name = find.byKey(const Key('targetEditor.name'));
      await t.enterText(name, 'First attempt');
      repo.gate = Completer<void>();
      await t.tap(find.byKey(const Key('targetEditor.save')));
      await t.pump();
      await t.runAsync(() async {
        repo.gate!.completeError(StateError('synthetic failed write'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect((await repo.getTargetById(original.id))!.commonName, 'Original');
      });
      await t.pumpAndSettle();
      expect(t.widget<TextFormField>(name).enabled, isTrue);
      expect(t.widget<TextFormField>(name).controller!.text, 'First attempt');
      await t.enterText(name, 'Retry visible draft');
      repo.gate = null;
      await t.tap(find.byKey(const Key('targetEditor.save')));
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 80)),
      );
      await t.pumpAndSettle();
      expect(find.byType(TargetEditorScreen), findsNothing);
      expect(repo.submitted.map((e) => e.commonName), [
        'First attempt',
        'Retry visible draft',
      ]);
      await t.runAsync(
        () async => expect(
          (await repo.getTargetById(original.id))!.commonName,
          'Retry visible draft',
        ),
      );
      await t.tap(find.text('Open'));
      await t.pumpAndSettle();
      await t.enterText(name, 'Discard me');
      await t.tap(find.byKey(const Key('targetEditor.cancel')));
      await t.pumpAndSettle();
      await t.tap(find.text('Cancel').last);
      await t.pumpAndSettle();
      expect(t.widget<TextFormField>(name).controller!.text, 'Discard me');
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      await t.tap(find.text('Discard'));
      await t.pumpAndSettle();
      expect(find.byType(TargetEditorScreen), findsNothing);
      expect(repo.submitted, hasLength(2));
    },
  );
}
