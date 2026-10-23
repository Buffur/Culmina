import 'dart:async';

import 'package:flutter/services.dart';

import '../../core/diagnostics/app_log.dart';

/// The launch hand-over with Android (`MainActivity`; owner, 2026-10-23).
/// Android 12+ removes its splash, which shows the still mark, when Flutter
/// has drawn the same mark, and says so here: from then on the Flutter mark
/// is the one on screen and the launch gesture can start. When the app is
/// shown, Android is told so and gives the window a plain background.
class LaunchChannel {
  LaunchChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(name) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'splashGone' && !_splashGone.isCompleted) {
        _splashGone.complete();
      }
    });
  }

  static const name = 'io.github.buffur.culmina/launch';

  final MethodChannel _channel;
  final _splashGone = Completer<void>();

  /// Completes when Android 12+ has removed its splash. Never completes on
  /// older versions, which have no splash of their own to remove.
  Future<void> get splashGone => _splashGone.future;

  Future<void> appShown() async {
    try {
      await _channel.invokeMethod<void>('appShown');
    } catch (e) {
      AppLog.warning('launch', 'Launch window not reset', error: e);
    }
  }
}
