import 'dart:async';

import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Write {
  _Write(this.kind, this.profile);
  final String kind;
  final EquipmentProfile profile;
  final done = Completer<int>();
}

class _Gear extends ChangeNotifier implements GearViewModel {
  final writes = <_Write>[];
  @override
  Future<int> add(EquipmentProfile profile) {
    final write = _Write('add', profile);
    writes.add(write);
    return write.done.future;
  }

  @override
  Future<void> update(EquipmentProfile profile) async {
    final write = _Write('update', profile);
    writes.add(write);
    await write.done.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Pops extends NavigatorObserver {
  int count = 0;
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    count++;
    super.didPop(route, previousRoute);
  }
}

const _rig = EquipmentProfile(
  id: 7,
  name: 'Synthetic audit rig',
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  pixelPitchUm: 3.76,
  sensorWidthMm: 22.56,
  sensorHeightMm: 15.04,
  focalLengthMm: 400,
  focalRatio: 5,
);
const _newDraft = EquipmentDraft(
  initial: EquipmentFormTexts(
    name: 'Synthetic audit rig',
    resolutionWidth: '6000',
    resolutionHeight: '4000',
    pixelPitch: '3.76',
    sensorWidth: '22.56',
    sensorHeight: '15.04',
    focalLength: '400',
    focalRatio: '5',
  ),
);

void main() {
  for (final editing in [false, true]) {
    testWidgets(
      '${editing ? 'update' : 'add'} owns one write, guards exit, retries failure',
      (t) async {
        final gear = _Gear();
        addTearDown(gear.dispose);
        final pops = _Pops();
        int? result;
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          ChangeNotifierProvider<GearViewModel>.value(
            value: gear,
            child: MaterialApp(
              navigatorObservers: [pops],
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      result = await showEquipmentEditor(
                        context,
                        existing: editing ? _rig : null,
                        draft: editing ? null : _newDraft,
                      );
                    },
                    child: const Text('Open editor'),
                  ),
                ),
              ),
            ),
          ),
        );
        await t.tap(find.text('Open editor'));
        await t.pumpAndSettle();
        final save = find.byKey(const Key('rigEditor.save'));
        final cancel = find.byKey(const Key('rigEditor.cancel'));
        await t.tap(save);
        await t.pump();
        expect(gear.writes, hasLength(1));
        expect(gear.writes.single.kind, editing ? 'update' : 'add');
        expect(t.widget<FilledButton>(save).onPressed, isNull);
        expect(t.widget<OutlinedButton>(cancel).onPressed, isNull);
        await t.sendKeyEvent(LogicalKeyboardKey.tab);
        await t.pump();
        for (final field in find.byType(EditableText).evaluate()) {
          expect((field.widget as EditableText).focusNode.hasFocus, isFalse);
        }
        // A second physical tap and system Back must not start another write
        // or dismiss a still-pending editor, including an unchanged edit.
        await t.tap(save);
        await t.binding.handlePopRoute();
        await t.pump();
        expect(gear.writes, hasLength(1));
        expect(save, findsOneWidget);
        expect(pops.count, 0);

        gear.writes[0].done.completeError(
          StateError('synthetic unavailable store'),
        );
        await t.pumpAndSettle();
        expect(save, findsOneWidget);
        expect(t.widget<FilledButton>(save).onPressed, isNotNull);
        expect(t.widget<OutlinedButton>(cancel).onPressed, isNotNull);
        expect(find.text('Synthetic audit rig'), findsOneWidget);
        expect(find.textContaining("Couldn't save the rig"), findsOneWidget);
        await t.pump(const Duration(seconds: 5));
        await t.pumpAndSettle();
        await t.tap(save);
        await t.pump();
        expect(gear.writes, hasLength(2));
        expect(gear.writes[1].profile.name, 'Synthetic audit rig');
        gear.writes[1].done.complete(42);
        await t.pumpAndSettle();
        expect(save, findsNothing);
        expect(pops.count, 1);
        expect(result, editing ? 7 : 42);
        await t.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
