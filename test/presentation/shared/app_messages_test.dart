// S9.8 (TD-081): every message goes through `AppMessages.showMessage`, so
// messages stop sliding when the platform asks for less motion, and keep
// their normal slide otherwise.

import 'dart:io';

import 'package:astroplan/presentation/shared/failure_feedback.dart';
import 'package:astroplan/presentation/shared/app_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long actionable warning at 200% keeps a 48 dp close target', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late BuildContext host;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              host = context;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    ScaffoldMessenger.of(host).showMessage(
      SnackBar(
        content: const Text(
          'This position is already saved. Use the existing site or change the coordinates. Nothing was saved.',
        ),
        persist: true,
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
    await tester.pumpAndSettle();
    final close = tester.getSize(find.byKey(const Key('appMessage.dismiss')));
    expect(close.width, greaterThanOrEqualTo(48));
    expect(close.height, greaterThanOrEqualTo(48));
    expect(find.text('Undo'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('appMessage.dismiss')));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
  });

  testWidgets(
    'timeout animates out; replacement cannot dismiss the next message',
    (tester) async {
      late BuildContext host;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                host = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      final messenger = ScaffoldMessenger.of(host);
      final first = messenger.showMessage(
        const SnackBar(
          content: Text('QA first'),
          duration: Duration(seconds: 1),
        ),
      );
      await tester.pumpAndSettle();
      final animation = tester
          .widget<MaterialBanner>(find.byType(MaterialBanner))
          .animation!;
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 20));
      expect(await first.closed, SnackBarClosedReason.timeout);
      expect(animation.value, greaterThan(0));
      expect(animation.value, lessThan(1));
      final next = messenger.showMessage(
        const SnackBar(content: Text('QA next'), persist: true),
      );
      await tester.pumpAndSettle();
      expect(find.text('QA first'), findsNothing);
      expect(find.text('QA next'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('QA next'), findsOneWidget);
      await tester.tap(find.byKey(const Key('appMessage.dismiss')));
      await tester.pumpAndSettle();
      expect(await next.closed, SnackBarClosedReason.dismiss);
    },
  );

  testWidgets(
    'action and close remain independent and report only one outcome',
    (tester) async {
      late BuildContext host;
      var actions = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                host = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      final message = ScaffoldMessenger.of(host).showMessage(
        SnackBar(
          content: const Text('QA deleted'),
          persist: true,
          action: SnackBarAction(label: 'Undo', onPressed: () => actions++),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Dismiss'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(actions, 1);
      expect(await message.closed, SnackBarClosedReason.action);
    },
  );
  testWidgets(
    'feedback reserves layout space and Dismiss closes its outcome at 200%',
    (tester) async {
      late BuildContext host;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  host = context;
                  return const SizedBox.expand(key: Key('message.body'));
                },
              ),
            ),
          ),
        ),
      );
      final message = ScaffoldMessenger.of(host)
          .showMessage(const SnackBar(content: Text('Plan saved')));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const Key('message.body'))).top,
        greaterThanOrEqualTo(
          tester.getRect(find.byType(MaterialBanner)).bottom,
        ),
      );
      await tester.tap(find.byKey(const Key('appMessage.dismiss')));
      await tester.pumpAndSettle();
      expect(await message.closed, SnackBarClosedReason.dismiss);
      expect(find.text('Plan saved'), findsNothing);
    },
  );

  test('lib/presentation calls showSnackBar only through AppMessages', () {
    final offenders = [
      for (final f
          in Directory('lib/presentation')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart')))
        if (!f.path
                .replaceAll(r'\', '/')
                .endsWith('shared/app_messages.dart') &&
            f.readAsStringSync().contains('.showSnackBar('))
          f.path,
    ];
    expect(offenders, isEmpty);
  });

  Future<Animation<double>?> show(
    WidgetTester tester, {
    required bool reduceMotion,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDone(context, 'Rig saved'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump(); // the message is added
    await tester.pump(const Duration(milliseconds: 50));
    return tester.widget<MaterialBanner>(find.byType(MaterialBanner)).animation;
  }

  testWidgets('TD-081: under reduced motion a message is in place at once', (
    tester,
  ) async {
    final animation = await show(tester, reduceMotion: true);
    expect(animation!.value, 1.0);
    expect(find.text('Rig saved'), findsOneWidget);
  });

  testWidgets('otherwise the layout row animates in', (tester) async {
    final animation = await show(tester, reduceMotion: false);
    expect(animation!.value, lessThan(1.0));
    await tester.pumpAndSettle();
    expect(find.text('Rig saved'), findsOneWidget);
  });
}
