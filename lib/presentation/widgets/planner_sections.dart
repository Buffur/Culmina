/// The planner's collapsible sections (S6.7; ADR-019 §7): technical depth
/// one tap away behind a factual summary. Each key names the remembered
/// state (`DisclosureViewModel`), so never rename one without a reason.
abstract final class PlannerSections {
  /// Hybrid "Budget and assumptions" (the facts, then the assumptions).
  static const budgetDetails = 'planner.budgetDetails';

  /// Hybrid "Stacking gain details" (the table, the curves and the help).
  static const gainHelp = 'planner.gainHelp';

  /// Earlier separate sections, folded into the two above by the Hybrid
  /// transfer (2026-10-22); kept so a stored state keeps its name.
  static const gainCurve = 'planner.gainCurve';
  static const assumptions = 'planner.assumptions';
  static const rigDetails = 'planner.rigDetails';
  static const sky = 'planner.sky';

  /// F18 A1: the current sky on another plan night; shown only then, so
  /// it is not in [all].
  static const currentSky = 'planner.currentSky';

  static const all = [budgetDetails, gainHelp, rigDetails, sky];
}
