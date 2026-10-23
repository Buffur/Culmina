// Owner, 2026-10-23: the next launch's splash follows the app's appearance
// and field mode (Android 13+); field mode wins; a failure is never thrown.

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/services/splash_theme_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(SplashThemeChannel.name);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('field mode wins; otherwise the chosen appearance', () {
    for (final a in [...Appearance.values, null]) {
      expect(SplashTheme.of(fieldMode: true, appearance: a), SplashTheme.field);
    }
    expect(
      SplashTheme.of(fieldMode: false, appearance: Appearance.light),
      SplashTheme.light,
    );
    expect(
      SplashTheme.of(fieldMode: false, appearance: Appearance.dark),
      SplashTheme.dark,
    );
    expect(
      SplashTheme.of(fieldMode: false, appearance: Appearance.system),
      SplashTheme.system,
    );
    expect(
      SplashTheme.of(fieldMode: false, appearance: null),
      SplashTheme.system,
    );
  });

  test('sends a change once, by name', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    final splash = SplashThemeChannel();
    await splash.apply(SplashTheme.field);
    await splash.apply(SplashTheme.field);
    await splash.apply(SplashTheme.system);
    expect(calls.map((c) => '${c.method}:${c.arguments}'), [
      'setTheme:field',
      'setTheme:system',
    ]);
  });

  test('a failure is logged, not thrown, and retried next time', () async {
    var fail = true;
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.arguments as String);
      if (fail) throw PlatformException(code: 'x');
      return null;
    });
    final splash = SplashThemeChannel();
    await splash.apply(SplashTheme.dark);
    fail = false;
    await splash.apply(SplashTheme.dark);
    expect(calls, ['dark', 'dark']);
  });
}
