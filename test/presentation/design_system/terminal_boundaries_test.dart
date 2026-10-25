import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/presentation/screens/equipment/rig_detail_screen.dart';
import 'package:astroplan/presentation/screens/library/library_parts.dart';
import 'package:astroplan/presentation/screens/logbook/logbook_screen.dart';
import 'package:astroplan/presentation/screens/logbook/progress_screen.dart';
import 'package:astroplan/presentation/screens/logbook/session_detail_screen.dart';
import 'package:astroplan/presentation/screens/target/target_selection_screen.dart';
import 'package:astroplan/presentation/shared/collapsible_section.dart';
import 'package:astroplan/presentation/shared/list_mode.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';

class _Targets extends ChangeNotifier implements TargetsViewModel {
  _Targets(this.records);
  final List<AstroTarget> records;
  @override
  Future<List<AstroTarget>> search(String query) async => records
      .where(
        (t) => '${t.catalogId} ${t.commonName}'.toLowerCase().contains(
          query.toLowerCase(),
        ),
      )
      .toList();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<HybridTransferFixture> setup(WidgetTester t) async {
    t.view.physicalSize = const Size(412, 1800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    late HybridTransferFixture fixture;
    await t.runAsync(() async {
      fixture = await HybridTransferFixture.create(
        AppDatabase(NativeDatabase.memory()),
      );
      await fixture.seedLogbook();
    });
    addTearDown(() async {
      await t.pumpWidget(const SizedBox.shrink());
      fixture.vm.dispose();
      await t.runAsync(fixture.db.close);
    });
    return fixture;
  }

  Future<void> show(
    WidgetTester t,
    HybridTransferFixture fixture,
    Widget screen,
  ) async {
    await t.pumpWidget(
      MultiProvider(
        providers: fixture.vm.providers,
        child: MaterialApp(home: screen),
      ),
    );
    await hybridSettle(t);
  }

  Future<void> reveal(WidgetTester t, String key, String scrollKey) async {
    final target = find.byKey(Key(key));
    final scroll = find
        .descendant(
          of: find.byKey(Key(scrollKey)),
          matching: find.byType(Scrollable),
        )
        .first;
    if (target.evaluate().isEmpty) {
      await t.scrollUntilVisible(target, 400, scrollable: scroll);
    } else {
      await t.ensureVisible(target);
    }
    await hybridSettle(t);
  }

  bool bottomRule(WidgetTester t, Finder root) => t
      .widgetList<DecoratedBox>(
        find.descendant(of: root, matching: find.byType(DecoratedBox)),
      )
      .any(
        (w) =>
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).border is Border &&
            ((w.decoration as BoxDecoration).border! as Border).bottom.style !=
                BorderStyle.none,
      );

  test('shared row/disclosure defaults remain ruled', () {
    expect(
      LibraryRow(title: 'row', caption: 'caption', onTap: () {}).divider,
      isTrue,
    );
    expect(
      CollapsibleSection(
        sectionKey: 'default',
        title: 'Default',
        open: false,
        onToggle: () {},
        child: const SizedBox(),
      ).topRule,
      isTrue,
    );
  });

  testWidgets('rig logical last row follows filters and help is standalone', (
    t,
  ) async {
    final fixture = await setup(t);
    await show(
      t,
      fixture,
      const EquipmentSelectionScreen(mode: ListMode.manage),
    );
    final initialRows = t
        .widgetList<LibraryRow>(find.byType(LibraryRow))
        .toList();
    expect(initialRows.length, greaterThan(1));
    expect(
      initialRows.take(initialRows.length - 1).every((r) => r.divider),
      isTrue,
    );
    expect(initialRows.last.divider, isFalse);
    expect(
      t
          .widget<CollapsibleSection>(
            find.byKey(const Key('rigs.fromPhotoHelp')),
          )
          .topRule,
      isFalse,
    );
    final search = find.descendant(
      of: find.byKey(const Key('rigs.search')),
      matching: find.byType(TextField),
    );
    await t.enterText(search, 'Phone');
    await t.pumpAndSettle();
    expect(find.byType(LibraryRow), findsOneWidget);
    expect(t.widget<LibraryRow>(find.byType(LibraryRow)).divider, isFalse);
    await t.enterText(search, 'No matching synthetic rig');
    await t.pumpAndSettle();
    expect(find.byType(LibraryRow), findsNothing);
    expect(find.byKey(const Key('rigs.clearSearch')), findsOneWidget);
  });

  testWidgets(
    'target own/catalogue terminal rules follow each filtered group',
    (t) async {
      final fixture = await setup(t);
      late List<AstroTarget> catalogue;
      await t.runAsync(() async {
        catalogue = (await DriftTargetRepository(fixture.db).searchTargets(''))
            .take(2)
            .toList();
      });
      final own = [
        for (var i = 0; i < 2; i++)
          AstroTarget(
            id: -100 - i,
            catalogId: 'QA$i',
            commonName: 'Own $i',
            rightAscension: 10.0 + i,
            declination: 20,
            type: 'Galaxy',
            source: 'user',
          ),
      ];
      final targets = _Targets([...own, ...catalogue]);
      addTearDown(targets.dispose);
      await t.pumpWidget(
        MultiProvider(
          providers: [
            ...fixture.vm.providers,
            ChangeNotifierProvider<TargetsViewModel>.value(value: targets),
          ],
          child: const MaterialApp(
            home: TargetSelectionScreen(mode: ListMode.manage),
          ),
        ),
      );
      await t.pumpAndSettle();
      for (final group in [own, catalogue]) {
        expect(
          t
              .widget<LibraryRow>(
                find.byKey(Key('targets.row.${group.first.id}')),
              )
              .divider,
          isTrue,
        );
        expect(
          t
              .widget<LibraryRow>(
                find.byKey(Key('targets.row.${group.last.id}')),
              )
              .divider,
          isFalse,
        );
      }
      final search = find.descendant(
        of: find.byKey(const Key('targets.search')),
        matching: find.byType(TextField),
      );
      await t.enterText(search, 'QA0');
      await t.pumpAndSettle();
      expect(find.byType(LibraryRow), findsOneWidget);
      expect(t.widget<LibraryRow>(find.byType(LibraryRow)).divider, isFalse);
    },
  );

  testWidgets('rig full record is standalone', (t) async {
    final fixture = await setup(t);
    final rigs = await t.runAsync(
      () => DriftEquipmentRepository(fixture.db).getAllEquipment(),
    );
    await show(t, fixture, RigDetailScreen(rig: rigs!.first));
    expect(
      t
          .widget<CollapsibleSection>(find.byKey(const Key('rigDetail.full')))
          .topRule,
      isFalse,
    );
  });

  testWidgets('Logbook Progress is standalone while entry boundaries remain', (
    t,
  ) async {
    final fixture = await setup(t);
    await show(t, fixture, const LogbookScreen());
    expect(bottomRule(t, find.byKey(const Key('logbook.progress'))), isFalse);
    final entry = find
        .byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('logbook.entry.'),
        )
        .first;
    // The DecoratedBox is the entry InkWell's parent; check the enclosing
    // SwipeToDelete via its key rather than assuming the rule is a child.
    final row = find
        .ancestor(of: entry, matching: find.byType(DecoratedBox))
        .first;
    final decoration = t.widget<DecoratedBox>(row).decoration as BoxDecoration;
    expect((decoration.border! as Border).bottom.style, BorderStyle.solid);
  });

  testWidgets('entry root disclosures omit first rules; gain boundary stays', (
    t,
  ) async {
    final fixture = await setup(t);
    await show(
      t,
      fixture,
      SessionDetailScreen(sessionId: fixture.logbookIds['M31 2026-10-12']!),
    );
    for (final (key, ruled) in [
      ('detail.gain', true),
      ('detail.snapshot', false),
      ('detail.exportSection', false),
    ]) {
      await reveal(t, key, 'detail.scroll');
      final disclosure = find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(CollapsibleSection),
      );
      expect(
        t.widget<CollapsibleSection>(disclosure).topRule,
        ruled,
        reason: key,
      );
    }
  });

  testWidgets('Progress guide is standalone', (t) async {
    final fixture = await setup(t);
    await show(t, fixture, const ProgressScreen());
    if (find.byKey(const Key('progress.guide')).evaluate().isEmpty) {
      await t.scrollUntilVisible(
        find.byKey(const Key('progress.guide')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
    }
    expect(
      t
          .widget<CollapsibleSection>(find.byKey(const Key('progress.guide')))
          .topRule,
      isFalse,
    );
  });
}
