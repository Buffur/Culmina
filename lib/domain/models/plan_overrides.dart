/// Explicit assumptions for one plan. Null fields inherit global settings
/// (or measured/declared storage evidence); zero is an intentional override.
class PlanOverrides {
  PlanOverrides({
    this.interframeSeconds,
    this.outsideSetupSeconds,
    this.fixedMarginSeconds,
    this.bytesPerFrame,
  }) {
    for (final entry in toJson().entries) {
      final value = entry.value;
      if (value != null &&
          (!value.isFinite ||
              value < 0 ||
              (entry.key == 'bytesPerFrame' && value == 0))) {
        throw ArgumentError.value(value, entry.key, 'invalid plan assumption');
      }
    }
  }

  final double? interframeSeconds;
  final double? outsideSetupSeconds;
  final double? fixedMarginSeconds;
  final double? bytesPerFrame;

  bool get isEmpty => toJson().values.every((value) => value == null);

  Map<String, double?> toJson() => {
    'interframeSeconds': interframeSeconds,
    'outsideSetupSeconds': outsideSetupSeconds,
    'fixedMarginSeconds': fixedMarginSeconds,
    'bytesPerFrame': bytesPerFrame,
  };

  /// Missing in older plans/backups means no overrides. Invalid present data
  /// is refused instead of silently changing the calculation.
  static PlanOverrides? fromJson(Object? json) {
    if (json == null) return null;
    if (json is! Map) throw const FormatException('Invalid plan overrides');
    double? value(String key) {
      final v = json[key];
      if (v == null) return null;
      if (v is! num) throw FormatException('Invalid plan override: $key');
      return v.toDouble();
    }

    final result = PlanOverrides(
      interframeSeconds: value('interframeSeconds'),
      outsideSetupSeconds: value('outsideSetupSeconds'),
      fixedMarginSeconds: value('fixedMarginSeconds'),
      bytesPerFrame: value('bytesPerFrame'),
    );
    return result.isEmpty ? null : result;
  }
}
