import '../../core/utils/quantity_text.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/services/capture_budget_calculator.dart';

/// How a capture block reads in the plan (S6.9; UX-09, 08 §14): what will
/// be captured first — "Ha · 60 s × 100 · 1 h 40 min". The duration is the
/// block's exposure from the budget (`BlockBudget`), never computed here.
/// Camera-specific values (ISO or gain, binning) stay in the block's editor.
abstract final class BlockText {
  /// The block's identity: a light's filter ("Ha"), or "Light" without one;
  /// a calibration frame's type, with its filter if it has one ("Flat
  /// (Ha)").
  static String identity(CaptureBlock b) {
    final name = b.filterName?.trim();
    final filter = name == null || name.isEmpty ? null : name;
    final type = BlockText.type(b.frameType);
    if (b.frameType == FrameType.light) return filter ?? type;
    return filter == null ? type : '$type ($filter)';
  }

  /// A frame type's name: "Light", "Dark flat" (also the block editor's
  /// choices).
  static String type(FrameType t) => switch (t) {
    FrameType.light => 'Light',
    FrameType.dark => 'Dark',
    FrameType.flat => 'Flat',
    FrameType.bias => 'Bias',
    FrameType.darkFlat => 'Dark flat',
  };

  /// Hybrid block title (plan.js `blockRow`): "Light · L", "Light · no
  /// filter", "Dark", "Flat · no filter".
  static String title(CaptureBlock b) {
    final name = b.filterName?.trim();
    final filter = name == null || name.isEmpty
        ? (b.frameType == FrameType.light || b.frameType == FrameType.flat
              ? 'no filter'
              : null)
        : name;
    return filter == null
        ? type(b.frameType)
        : '${type(b.frameType)} · $filter';
  }

  /// "120 × 60 s = 2 h integration"; calibration says it is not
  /// integration (plan.js `block-math`).
  static String math(CaptureBlock b) {
    final total = Duration(
      milliseconds: (b.exposureTimeSeconds * 1000 * b.frameCount).round(),
    );
    return '${b.frameCount} × ${QuantityText.exposure(b.exposureTimeSeconds)} = '
        '${QuantityText.duration(total)} '
        '${b.frameType == FrameType.light ? 'integration' : 'planned calibration, not integration'}';
  }

  /// The row: identity · exposure × count · the block's exposure time, or
  /// "from your library" for library calibration (no time, ADR-009 §3).
  static String row(CaptureBlock b, BlockBudget? budget) => [
    identity(b),
    '${QuantityText.exposure(b.exposureTimeSeconds)} × ${b.frameCount}',
    if (budget != null)
      budget.placement == BudgetPlacement.library
          ? 'from your library'
          : QuantityText.duration(Duration(milliseconds: budget.exposureMs)),
  ].join(' · ');

  /// What fits of this light block tonight (S6.10; P6.9; plan.js
  /// `fitLine`), only from the fit's own outputs: [unplaced] from
  /// `FitResult.unplacedFramesByBlock` and [upTo] from
  /// `FitAnalyzer.maxFramesForBlock`, with every other block as planned,
  /// which [others] says when other blocks share the window (F12, TD-074).
  /// Worded for tonight; `PlanNightPhrase.apply` names another night.
  static String whatFits(
    CaptureBlock b, {
    required int unplaced,
    int? upTo,
    bool others = false,
  }) {
    if (upTo == null) return 'Window capacity unknown for this plan';
    final rest = others ? ' (other blocks as planned)' : '';
    return unplaced == 0
        ? "Fits: room for up to $upTo frames like this in tonight's "
              'window$rest'
        : "Only $upTo of ${b.frameCount} frames fit tonight's window";
  }

  /// Where a calibration block's time goes; null for lights and library
  /// blocks (the row already says so).
  static String? placement(CaptureBlock b, BlockBudget? budget) {
    if (b.frameType == FrameType.light || budget == null) return null;
    return switch (budget.placement) {
      BudgetPlacement.window => 'During the imaging window',
      BudgetPlacement.outsideWindow => 'Outside the imaging window',
      BudgetPlacement.library => null,
    };
  }
}
