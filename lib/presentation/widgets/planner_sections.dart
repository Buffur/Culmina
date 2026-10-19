/// The planner's collapsible sections (S6.7; ADR-019 §7): technical depth
/// one tap away behind a factual summary. Each key names the remembered
/// state (`DisclosureViewModel`), so never rename one without a reason.
abstract final class PlannerSections {
  static const budgetDetails = 'planner.budgetDetails';
  static const gainHelp = 'planner.gainHelp';
  static const gainCurve = 'planner.gainCurve';
  static const assumptions = 'planner.assumptions';
  static const rigDetails = 'planner.rigDetails';
  static const sky = 'planner.sky';

  /// F18 A1: the current sky on another plan night; shown only then, so
  /// it is not in [all].
  static const currentSky = 'planner.currentSky';

  static const all = [
    budgetDetails,
    gainHelp,
    gainCurve,
    assumptions,
    rigDetails,
    sky,
  ];
}
