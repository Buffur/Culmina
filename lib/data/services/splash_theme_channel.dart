import 'package:flutter/services.dart';

import '../../core/diagnostics/app_log.dart';
import '../../core/units/display_units.dart';

/// Which splash the next launch shows (owner, 2026-10-23). The system draws
/// the splash before any Dart runs, so it cannot know the app's own
/// appearance or field mode; on Android 13+ the app stores the matching
/// splash theme whenever they change (`MainActivity.setSplashTheme`), and
/// field mode never starts with a bright splash. Earlier Android versions
/// follow the system's dark mode only.
enum SplashTheme {
  /// Follow the system: light or dark with the system's dark mode.
  system,
  light,
  dark,

  /// Black, with the mark in field mode's dim reds.
  field;

  static SplashTheme of({
    required bool fieldMode,
    required Appearance? appearance,
  }) {
    if (fieldMode) return field;
    return switch (appearance) {
      Appearance.light => light,
      Appearance.dark => dark,
      Appearance.system || null => system,
    };
  }
}

/// Sends [SplashTheme] to Android. A failure only costs the next splash its
/// colours, so it is logged and never thrown.
class SplashThemeChannel {
  SplashThemeChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(name);

  static const name = 'io.github.buffur.culmina/splash_theme';

  final MethodChannel _channel;
  SplashTheme? _sent;

  Future<void> apply(SplashTheme theme) async {
    if (theme == _sent) return;
    _sent = theme;
    try {
      await _channel.invokeMethod<void>('setTheme', theme.name);
    } catch (e) {
      _sent = null;
      AppLog.warning('splash', 'Splash theme not stored', error: e);
    }
  }
}
