import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/plan_overrides.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final preferences = PlanningPreferences(
    perFrameOverheadSeconds: 5,
    setupMinutes: 10,
  );
  final blocks = [
    CaptureBlock(
      frameType: FrameType.light,
      exposureTimeSeconds: 60,
      frameCount: 10,
    ),
  ];
  CaptureBudget budget([PlanOverrides? overrides]) =>
      CaptureBudgetCalculator.calculate(
        blocks: blocks,
        overheads: CaptureOverheads.fromPreferences(
          preferences,
          planOverrides: overrides,
        ),
        frameBytes: [overrides?.bytesPerFrame],
      );

  test('missing overrides preserve defaults and unknown storage', () {
    expect(PlanOverrides.fromJson(null), isNull);
    expect(PlanOverrides.fromJson({}), isNull);
    expect(budget().acquisitionMs, 650000);
    expect(budget().setupMs, 600000);
    expect(budget().storageMB, isNull);
  });

  test(
    'explicit zero and positive overrides alter only intended quantities',
    () {
      final result = budget(
        PlanOverrides(
          interframeSeconds: 7.5,
          outsideSetupSeconds: 900,
          bytesPerFrame: 30000000,
        ),
      );
      expect(result.integrationMs, 600000);
      expect(result.acquisitionMs, 675000);
      expect(result.setupMs, 900000);
      expect(result.windowLoad.inMilliseconds, 675000);
      expect(result.storageMB, 300);
      final zeros = budget(
        PlanOverrides(interframeSeconds: 0, outsideSetupSeconds: 0),
      );
      expect(zeros.acquisitionMs, 600000);
      expect(zeros.setupMs, 0);
      expect(preferences.perFrameOverheadSeconds, 5);
      expect(preferences.setupMinutes, 10);
    },
  );

  test('fixed margin changes fit verdict, never placement or integration', () {
    final windows = [
      VisibilityWindow(
        start: DateTime.utc(2026, 12, 15, 20),
        end: DateTime.utc(2026, 12, 15, 20, 20),
      ),
    ];
    final normal = FitAnalyzer.analyze(budget: budget(), windows: windows);
    final fixed = FitAnalyzer.analyze(
      budget: budget(),
      windows: windows,
      fixedMarginSeconds: 900,
    );
    expect(normal.state, FitState.fits);
    expect(fixed.state, FitState.tight);
    expect(fixed.placedMs, normal.placedMs);
    expect(fixed.endUtc, normal.endUtc);
    expect(fixed.reason, contains('15 min'));
    expect(
      FitAnalyzer.analyze(
        budget: budget(),
        windows: windows,
        fixedMarginSeconds: 0,
        marginFraction: .5,
      ).state,
      FitState.fits,
    );
  });

  test('invalid present values are refused, never treated as inheritance', () {
    for (final bad in [-1, double.nan, double.infinity]) {
      expect(
        () => PlanOverrides(interframeSeconds: bad.toDouble()),
        throwsArgumentError,
      );
    }
    expect(() => PlanOverrides(bytesPerFrame: 0), throwsArgumentError);
    expect(
      () => PlanOverrides.fromJson({'interframeSeconds': '5'}),
      throwsFormatException,
    );
    final value = PlanOverrides(
      interframeSeconds: 0,
      outsideSetupSeconds: 5,
      fixedMarginSeconds: 10,
      bytesPerFrame: 1,
    );
    expect(PlanOverrides.fromJson(value.toJson())!.toJson(), value.toJson());
  });
}
