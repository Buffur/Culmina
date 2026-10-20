import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/repositories/undoable_deletion.dart';
import 'package:astroplan/presentation/shared/app_messages.dart';
import 'package:astroplan/presentation/shared/delete_patterns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<BuildContext> host(WidgetTester tester) async {
    late BuildContext page;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              page = context;
              return const Text('Library');
            },
          ),
        ),
      ),
    );
    return page;
  }

  testWidgets('Undo survives closing the editor route and restores once', (
    tester,
  ) async {
    final home = await host(tester);
    late BuildContext editor;
    Navigator.of(home).push(
      MaterialPageRoute<void>(
        builder: (context) {
          editor = context;
          return const Scaffold(body: Text('Editor'));
        },
      ),
    );
    await tester.pumpAndSettle();
    var restored = 0;
    var refreshed = 0;
    final deleted = await deleteWithUndoFeedback(
      editor,
      action: 'delete the rig',
      message: 'Rig deleted',
      remove: () async => DeletionReceipt(
        resource: DeletedResource.rig,
        id: 7,
        restore: () async {
          restored++;
        },
      ),
      afterRestore: () async {
        refreshed++;
      },
    );
    expect(deleted, isTrue);
    Navigator.of(editor).pop();
    await tester.pumpAndSettle();
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(restored, 1);
    expect(refreshed, 1);
    expect(find.text('Deletion undone'), findsOneWidget);
  });

  testWidgets('failed restore remains retryable without false success', (
    tester,
  ) async {
    final context = await host(tester);
    var attempts = 0;
    await deleteWithUndoFeedback(
      context,
      action: 'delete the entry',
      message: 'Entry deleted',
      remove: () async => DeletionReceipt(
        resource: DeletedResource.session,
        id: 8,
        restore: () async {
          if (++attempts == 1) throw StateError('conflicting identity');
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Deletion undone'), findsNothing);
    expect(find.text('Retry Undo'), findsOneWidget);
    expect(find.textContaining("Couldn't undo the deletion"), findsOneWidget);
    await tester.tap(find.text('Retry Undo'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Deletion undone'), findsOneWidget);
  });

  for (final replacement in [false, true]) {
    testWidgets(
      '${replacement ? 'replacement' : 'Dismiss'} commits deletion without restore',
      (tester) async {
        final context = await host(tester);
        var restores = 0;
        await deleteWithUndoFeedback(
          context,
          action: 'delete the target',
          message: 'Target deleted',
          remove: () async => DeletionReceipt(
            resource: DeletedResource.target,
            id: 1,
            restore: () async {
              restores++;
            },
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 30));
        expect(
          find.text('Undo'),
          findsOneWidget,
          reason: 'Stored-record Undo does not inherit the block timeout.',
        );
        if (replacement) {
          ScaffoldMessenger.of(context)
              .showMessage(const SnackBar(content: Text('Another action')));
        } else {
          await tester.tap(find.byKey(const Key('appMessage.dismiss')));
        }
        await tester.pumpAndSettle();
        expect(restores, 0);
        expect(find.text('Undo'), findsNothing);
      },
    );
  }

  testWidgets('failed delete offers neither Undo nor deleted success', (
    tester,
  ) async {
    final context = await host(tester);
    final result = await deleteWithUndoFeedback(
      context,
      action: 'delete the site',
      message: 'Site deleted',
      remove: () async => throw StateError('write failed'),
    );
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.text('Site deleted'), findsNothing);
    expect(find.text('Undo'), findsNothing);
    expect(find.textContaining("Couldn't delete the site"), findsOneWidget);
  });

  testWidgets('a failed list refresh keeps the committed deletion undoable', (
    tester,
  ) async {
    final context = await host(tester);
    var restored = false;
    expect(
      await deleteWithUndoFeedback(
        context,
        action: 'delete the target',
        message: 'Target deleted',
        remove: () async => DeletionReceipt(
          resource: DeletedResource.target,
          id: 1,
          restore: () async {
            restored = true;
          },
        ),
        afterDelete: () async => throw StateError('list read failed'),
      ),
      isTrue,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be refreshed'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(restored, isTrue);
  });
}
