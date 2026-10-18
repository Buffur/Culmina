import 'dart:convert';
import 'dart:typed_data';

/// A synthetic FITS file (FITS 4.0 §3–§4): [cards] as `KEYWORD = value`
/// pairs (a value is written as given; a String in quotes is a string),
/// then END unless [end] is false, padded to 2,880-byte records with
/// spaces, then [dataBytes] zero bytes. Nothing here is a real camera's.
Uint8List fitsFile(
  List<(String, Object)> cards, {
  bool end = true,
  int dataBytes = 0,
  int? records,
}) {
  String card(String keyword, Object value) {
    final v = switch (value) {
      final String s when s.startsWith("'") => s,
      final String s => "'${s.replaceAll("'", "''")}'",
      final bool b => (b ? 'T' : 'F').padLeft(20),
      final Object o => '$o'.padLeft(20),
    };
    return '${keyword.padRight(8)}= $v'.padRight(80).substring(0, 80);
  }

  final text = StringBuffer();
  for (final (k, v) in cards) {
    text.write(card(k, v));
  }
  if (end) text.write('END'.padRight(80));
  var header = text.toString();
  final wanted = records ?? ((header.length + 2879) ~/ 2880);
  header = header.padRight(wanted * 2880);
  return Uint8List.fromList([
    ...latin1.encode(header),
    ...List.filled(dataBytes, 0),
  ]);
}

/// A N.I.N.A.-style light sub-frame header (synthetic values).
List<(String, Object)> ninaLight({
  int bitpix = 16,
  int width = 3124,
  int height = 2088,
  int? binning = 2,
  double? pixelSize = 7.52,
}) => [
  ('SIMPLE', true),
  ('BITPIX', bitpix),
  ('NAXIS', 2),
  ('NAXIS1', width),
  ('NAXIS2', height),
  ('EXPTIME', 300.0),
  ('GAIN', 100),
  ('OFFSET', 50),
  if (binning != null) ('XBINNING', binning),
  if (binning != null) ('YBINNING', binning),
  if (pixelSize != null) ('XPIXSZ', pixelSize),
  if (pixelSize != null) ('YPIXSZ', pixelSize),
  ('CCD-TEMP', -9.8),
  ('SET-TEMP', -10.0),
  ('FILTER', 'Ha'),
  ('DATE-OBS', '2026-11-10T21:30:05.123'),
  ('INSTRUME', 'TestAstro 2600MM'),
  ('TELESCOP', 'Test 400 mm refractor'),
  ('FOCALLEN', 400.0),
];
