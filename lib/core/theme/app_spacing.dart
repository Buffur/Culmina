/// AFTER-DARK-1.2 spacing scale, in logical pixels (documented in S5.1; see
/// `docs/DESIGN_SYSTEM.md`). Component padding and page gutters are distinct:
/// [md] is the usual card's inner padding, not a universal page gutter.
/// Current page callers generally use [gutter], with documented local exceptions.
/// [lg] separates sections; [sm] separates rows within a section;
/// [xs] separates a label from its value.
class AppSpacing {
  /// Centers a 36 dp peer-tab visual inside its 48 dp target.
  static const double peerTabInset = 6.0;

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Hybrid reference steps (notion-hybrid.css / conditions.css, CSS px as
  // logical px) used where the transferred screens follow the reference.
  /// A caption tucked under its line.
  static const double hair = 2.0;

  /// A secondary line under a value.
  static const double nudge = 3.0;

  /// A dense table cell's vertical padding.
  static const double cellY = 8.0;

  /// A note under a chart or list.
  static const double notes = 12.0;

  /// Between related items in a group.
  static const double itemGap = 8.0;

  /// A list row's vertical padding.
  static const double rowY = 14.0;

  /// A Hybrid page's side padding.
  static const double gutter = 24.0;

  /// Between sections of a Hybrid page.
  static const double section = 32.0;
}
