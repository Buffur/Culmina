import '../../domain/models/capture_block.dart';

/// The recorded camera settings in words (ADR-021 C1, C3, C4; F06): white
/// balance, focus mode and where each field came from. Descriptive only;
/// nothing here is a calculation input.
abstract final class CaptureSettingsText {
  static String preset(WhiteBalancePreset p) => switch (p) {
    WhiteBalancePreset.daylight => 'Daylight',
    WhiteBalancePreset.cloudy => 'Cloudy',
    WhiteBalancePreset.shade => 'Shade',
    WhiteBalancePreset.tungsten => 'Tungsten',
    WhiteBalancePreset.fluorescent => 'Fluorescent',
    WhiteBalancePreset.flash => 'Flash',
  };

  static String mode(WhiteBalanceMode m) => switch (m) {
    WhiteBalanceMode.auto => 'Auto',
    WhiteBalanceMode.preset => 'Preset',
    WhiteBalanceMode.kelvin => 'Kelvin',
    WhiteBalanceMode.custom => 'Custom',
  };

  /// "Auto", "Daylight", "5600 K", "Custom", with a tint when recorded.
  static String whiteBalance(WhiteBalance wb) {
    final base = switch (wb.mode) {
      WhiteBalanceMode.auto => 'Auto',
      WhiteBalanceMode.preset => preset(wb.preset!),
      WhiteBalanceMode.kelvin => '${wb.kelvinK} K',
      WhiteBalanceMode.custom => 'Custom',
    };
    final tint = wb.tint;
    if (tint == null) return base;
    final t = tint == tint.roundToDouble() ? tint.toInt().toString() : '$tint';
    return '$base, tint ${tint > 0 ? '+' : ''}$t';
  }

  static String focus(FocusMode f) => switch (f) {
    FocusMode.af => 'AF',
    FocusMode.mf => 'MF',
  };

  /// "WB Daylight · MF", or null when neither is recorded.
  static String? of(CaptureBlock b) {
    final parts = [
      if (b.whiteBalance case final wb?) 'WB ${whiteBalance(wb)}',
      if (b.focusMode case final f?) focus(f),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// " · WB Daylight · MF" to append to a block's label, or "".
  static String suffix(CaptureBlock b) => switch (of(b)) {
    final s? => ' · $s',
    null => '',
  };

  static String field(CaptureField f) => switch (f) {
    CaptureField.frameType => 'Frame type',
    CaptureField.filter => 'Filter',
    CaptureField.exposure => 'Exposure',
    CaptureField.count => 'Frame count',
    CaptureField.sensitivity => 'ISO or gain',
    CaptureField.binning => 'Binning',
    CaptureField.wb => 'White balance',
    CaptureField.focusMode => 'Focus',
    CaptureField.fileSize => 'File size',
  };

  /// Where a value came from, as fixed when it was accepted.
  static String origin(FieldOrigin o) => switch (o.kind) {
    OriginKind.entered => 'Entered',
    OriginKind.copied ||
    OriginKind.inherited ||
    OriginKind.file ||
    OriginKind.declared => _capital(o.descriptor),
  };

  static String _capital(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// The descriptor of a value taken from block [row] ("from L · 60 s × 40").
  static String fromBlock(String row) => 'from $row';
}
