import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registers the bundled typefaces and icon geometry for the application's licence page.
/// Call once after binding initialization; the text loads when requested.
abstract final class AppFontLicenses {
  static bool _registered = false;

  static void register() {
    if (_registered) return;
    _registered = true;
    LicenseRegistry.addLicense(() async* {
      final text = await rootBundle.loadString('assets/fonts/OFL-Geist.txt');
      yield LicenseEntryWithLineBreaks(const ['Geist'], text);
    });
    LicenseRegistry.addLicense(() async* {
      final text = await rootBundle.loadString(
        'assets/fonts/OFL-SourceSerif4.txt',
      );
      yield LicenseEntryWithLineBreaks(const ['Source Serif 4'], text);
    });
    // The Weather rows' data icons (HybridIcons) are Lucide geometry.
    LicenseRegistry.addLicense(() async* {
      final text = await rootBundle.loadString(
        'assets/fonts/LICENSE-Lucide.txt',
      );
      yield LicenseEntryWithLineBreaks(const ['Lucide icons'], text);
    });
  }
}
