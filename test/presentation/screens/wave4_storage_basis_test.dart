import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:astroplan/presentation/shared/storage_text.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_budget_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/hybrid_transfer_shots.dart';
import '../../support/wave1_capture.dart';
import '../../support/wave2_fixture.dart';

final _longName =
    'M31_Luminance_${List.filled(16, 'sequence_').join()}2026-10-19.CR3';
final wave4StorageMetrics = <Map<String, Object?>>[];

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    for (final width in [320.0, 375.0, 412.0]) {
      for (final variant in ['unknown', 'long', 'multi']) {
        testWidgets(
          'UIA-0011 $theme/$width/$variant: full provenance, numeric facts and readback',
          (t) async {
            final f = await mountWave2(t, theme);
            if (wave1IsNative) {
              await t.binding.setSurfaceSize(Size(width, 812));
            } else {
              t.view.physicalSize = Size(width, 812);
            }
            if (variant != 'unknown') {
              await t.runAsync(() async {
                final first = f.vm.plan.captureBlocks.first;
                await f.vm.plan.updateCaptureBlock(
                  0,
                  first.copyWith(
                    fileEvidence: () => FileEvidence(
                      bytes: 31457280,
                      format: 'recognized:cr3',
                      read: false,
                      label: _longName,
                    ),
                  ),
                );
                if (variant == 'multi') {
                  await f.vm.plan.addCaptureBlock(
                    CaptureBlock(
                      frameType: FrameType.light,
                      filterName: 'Ha',
                      exposureTimeSeconds: 180,
                      frameCount: 50,
                    ),
                  );
                }
                await f.vm.plan.idle;
              });
            }
            await t.tap(find.byKey(const Key('tonight.openPlanner')));
            await hybridSettle(t);
            final disclosure = find.byKey(
              const Key('section.planner.budgetDetails'),
            );
            await revealWave2(t, disclosure);
            await t.tap(disclosure);
            await hybridSettle(t);
            final total = find.byKey(const Key('budget.totalTime'));
            await revealWave2(t, total);
            final note = find.byKey(const Key('capturePlan.storageNote'));
            final texts = find.descendant(
              of: note,
              matching: find.byType(Text),
            );
            final heading = texts.first;
            final prose = texts.last;
            final budget = f.vm.analysis.captureBudget;
            final blocks = f.vm.plan.captureBlocks.toList();
            final frames = f.vm.analysis.frameStorage.toList();
            final expected = StorageText.plan(blocks, frames, [
              for (final b in budget.blocks)
                b.placement != BudgetPlacement.library,
            ], rig: f.vm.plan.selectedEquipment);
            expect(t.widget<Text>(heading).data, 'File size basis');
            expect(t.widget<Text>(prose).data, expected);
            if (variant == 'unknown') {
              expect(expected, contains('Unknown:'));
              expect(expected, contains('Choose one file'));
              expect(expected, contains('enter a size'));
            } else {
              expect(expected, contains(_longName));
              expect(
                expected,
                contains('mode not read; compressed sizes vary with content'),
              );
              if (variant == 'multi') {
                expect(expected, contains('\n'));
                expect(expected, contains('Unknown:'));
              }
            }
            final id = f.vm.plan.activeSessionId!;
            final before = await t.runAsync(() => f.seed.sessions.get(id));
            await captureWave1(
              t,
              'wave4-storage-$theme-${width.toInt()}-$variant',
            );
            final groupRect = t.getRect(note);
            final headingRect = t.getRect(heading);
            final proseRect = t.getRect(prose);
            expect(proseRect.top, greaterThanOrEqualTo(headingRect.bottom));
            expect(proseRect.left, closeTo(groupRect.left, .01));
            expect(proseRect.width, closeTo(groupRect.width, .01));
            expect(t.widget<Text>(prose).textAlign, TextAlign.start);
            expect(t.widget<Text>(prose).maxLines, isNull);
            expect(
              t.widget<Text>(prose).overflow,
              isNot(TextOverflow.ellipsis),
            );
            expect(
              t.widget<HybridFact>(total).value,
              formatBudgetDuration(budget.sessionBudgetMs),
            );
            final numeric = find
                .descendant(of: total, matching: find.byType(Text))
                .last;
            // HybridFact uses a shared leading edge for the value column,
            // including when narrow layouts stack the label above it.
            expect(
              t.widget<Text>(numeric).textAlign ?? TextAlign.start,
              TextAlign.start,
            );
            expect(f.vm.plan.captureBlocks, blocks);
            expect(f.vm.analysis.frameStorage, frames);
            await t.runAsync(() async {
              final after = (await f.seed.sessions.get(id))!;
              expect(after.planSnapshot!.json, before!.planSnapshot!.json);
              expect(after.updatedAtUtc, before.updatedAtUtc);
            });
            expect(t.takeException(), isNull);
            wave4StorageMetrics.add({
              'case': '$theme/$width/$variant',
              'width': groupRect.width,
              'proseWidth': proseRect.width,
              'proseHeight': proseRect.height,
              'prose': expected,
              'blocks': blocks.length,
              'numericFactRetained': true,
              'snapshotUpdatedAtUnchanged': true,
            });
          },
        );
      }
    }
  }
}
