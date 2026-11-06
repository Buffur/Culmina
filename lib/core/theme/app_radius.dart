/// Corner radii (S5.1), in logical pixels. One scale for the whole app;
/// see `docs/DESIGN_SYSTEM.md`.
abstract final class AppRadius {
  /// Cards, sections, text fields and buttons.
  static const double small = 8;

  /// Menus (plan.css `.plan-menu`).
  static const double menu = 12;

  /// Dialogs, bottom sheets and a swiped row's background.
  static const double large = 20;

  /// Search with an attached filter action.
  static const double searchFilter = 24;

  /// Pills and chips.
  static const double pill = 999;
}
