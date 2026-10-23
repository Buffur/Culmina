// TASK 16.1: the app's name and id live in one place (AppIdentity) and the
// Android project agrees with it; the icon and splash resources are wired.
// "Build and install" itself needs an Android toolchain (TEST_PLAN).

import 'dart:io';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/data/services/launch_channel.dart';
import 'package:astroplan/data/services/splash_theme_channel.dart';
import 'package:astroplan/presentation/shared/culmina_mark_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('the owner-decided name and id (RA.D ID-1 to ID-4; S13.2)', () {
    expect(AppIdentity.appName, 'Culmina');
    expect(AppIdentity.packageName, 'io.github.buffur.culmina');
    expect(
      AppIdentity.userAgent,
      'Culmina/${AppIdentity.version} '
      '(+https://buffur.github.io/Culmina/; '
      'io.github.buffur.culmina)',
    );
  });

  test('Gradle, the manifest and MainActivity use the same id and name', () {
    final gradle = _read('android/app/build.gradle.kts');
    expect(gradle, contains('applicationId = "${AppIdentity.packageName}"'));
    expect(gradle, contains('namespace = "${AppIdentity.packageName}"'));
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    expect(manifest, contains('android:label="${AppIdentity.appName}"'));
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    final activity = File(
      'android/app/src/main/kotlin/'
      '${AppIdentity.packageName.replaceAll('.', '/')}/MainActivity.kt',
    );
    expect(activity.existsSync(), isTrue);
    expect(
      activity.readAsStringSync(),
      startsWith('package ${AppIdentity.packageName}'),
    );
    final everything = [
      for (final f in Directory('android/app/src').listSync(recursive: true))
        if (f is File && RegExp(r'\.(kt|xml|kts)$').hasMatch(f.path))
          f.readAsStringSync(),
      gradle,
    ].join('\n');
    expect(everything, isNot(contains('com.astroplan')));
  });

  test('the adaptive icon, legacy icons and splash are wired', () {
    final adaptive = _read('$_res/mipmap-anydpi-v26/ic_launcher.xml');
    // Owner, 2026-10-23: the refreshed dark field is a gradient drawable.
    expect(adaptive, contains('@drawable/ic_launcher_background'));
    expect(adaptive, contains('@drawable/ic_launcher_foreground'));
    // S13.3: the themed icon is its own one-colour layer.
    expect(adaptive, contains('<monochrome'));
    expect(adaptive, contains('@drawable/ic_launcher_monochrome'));
    for (final f in [
      'ic_launcher_background',
      'ic_launcher_foreground',
      'ic_launcher_monochrome',
      'launch_background',
      for (final s in ['light', 'dark', 'field']) ...[
        'splash_mark_$s',
        'launch_mark_$s',
        'launch_background_$s',
      ],
    ]) {
      expect(File('$_res/drawable/$f.xml').existsSync(), isTrue, reason: f);
    }
    for (final gone in [
      'drawable/splash_icon_animated.xml',
      'drawable/launch_mark.xml',
      'drawable-v21/launch_background.xml',
    ]) {
      expect(File('$_res/$gone').existsSync(), isFalse, reason: gone);
    }
    // The splash shows the mark on the first screen's own background.
    expect(_read('$_res/values/colors.xml'), contains('#FFFFFF'));
    expect(_read('$_res/values-night/colors.xml'), contains('#191919'));
    for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      expect(File('$_res/mipmap-$d/ic_launcher.png').existsSync(), isTrue);
    }
    for (final (d, mark) in [
      ('values-v31', 'splash_mark_light'),
      ('values-night-v31', 'splash_mark_dark'),
    ]) {
      final styles = _read('$_res/$d/styles.xml');
      expect(
        styles,
        contains('windowSplashScreenBackground">@color/splash_background<'),
      );
      expect(styles, contains('@drawable/$mark'));
      // The splash shows the still mark; Flutter plays the gesture.
      expect(styles, isNot(contains('windowSplashScreenAnimationDuration')));
      // The mark itself, not an enlarged icon tile.
      expect(styles, isNot(contains('windowSplashScreenIconBackgroundColor')));
    }
    // The window behind Flutter carries the launch mark (no frame without
    // it between the splash and Flutter's first frame).
    for (final d in [
      'values',
      'values-night',
      'values-v31',
      'values-night-v31',
    ]) {
      expect(
        _read('$_res/$d/styles.xml'),
        contains('windowBackground">@drawable/launch_background<'),
        reason: d,
      );
    }
    // Android 13+: the stored splash themes for the app's own appearance.
    final v31 = _read('$_res/values-v31/styles.xml');
    for (final t in ['Light', 'Dark', 'Field']) {
      expect(v31, contains('name="CulminaSplash.$t"'));
    }
    for (final (d, s) in [('drawable', 'light'), ('drawable-night', 'dark')]) {
      final launch = _read('$_res/$d/launch_background.xml');
      // F02 (S13V-01, TD-109): no <bitmap> of the adaptive mipmap, which
      // cannot be drawn on API 26-30; the mark vector, centred.
      expect(launch, isNot(contains('<bitmap')));
      expect(launch, isNot(contains('@mipmap/')));
      expect(
        RegExp(
          '<item\\s+android:drawable="@drawable/launch_mark_$s"'
          r'\s+android:gravity="center"\s*/>',
        ).hasMatch(launch),
        isTrue,
        reason: '$d: the centred mark on the first-screen background',
      );
    }
    expect(File('assets/branding/icon_512.png').lengthSync(), greaterThan(0));
  });

  // Owner, 2026-10-23 (second brief): every copy of the mark has the
  // generated geometry; the native splash shows it still, at the launch
  // size Flutter uses, and the gesture is Flutter's (LaunchGate).
  test('one mark everywhere; the native launch is still', () {
    final icon = _read('$_res/drawable/ic_launcher_foreground.xml');
    final iconPaths = [
      for (final m in RegExp(r'android:pathData="([^"]+)"').allMatches(icon))
        m[1]!,
    ];
    expect(iconPaths, hasLength(3));
    for (final s in ['light', 'dark', 'field']) {
      for (final f in ['splash_mark_$s', 'launch_mark_$s']) {
        final vector = _read('$_res/drawable/$f.xml');
        for (final p in iconPaths) {
          expect(vector, contains(p), reason: '$f draws the icon mark');
        }
        expect(vector, isNot(contains('<animated-vector')), reason: f);
        expect(vector, isNot(contains('objectAnimator')), reason: f);
      }
      expect(
        _read('$_res/drawable/launch_mark_$s.xml'),
        contains('android:width="${CulminaLaunchTimeline.canvas.toInt()}dp"'),
        reason: 'the launch window draws the mark at the Flutter size',
      );
    }
    // Flutter's launch mark draws the same star as the vectors.
    expect(iconPaths.last, CulminaMarkGeometry.starPathData);
    final activity = _read(
      'android/app/src/main/kotlin/io/github/buffur/culmina/MainActivity.kt',
    );
    // The splash leaves at Flutter's first frame and says so; nothing in
    // Android holds it or plays a gesture of its own.
    expect(activity, contains('setOnExitAnimationListener'));
    expect(activity, contains('"splashGone"'));
    expect(activity, contains('"${LaunchChannel.name}"'));
    expect(activity, isNot(contains('iconAnimationDuration')));
    expect(activity, isNot(contains('postDelayed')));
  });

  test('the splash theme channel has one name on both sides', () {
    expect(
      _read(
        'android/app/src/main/kotlin/io/github/buffur/culmina/MainActivity.kt',
      ),
      contains('"${SplashThemeChannel.name}"'),
    );
  });

  // S13.2 (RA_D_IDENTITY_TRANSITION.md §3, criterion 2): no trace of the
  // earlier id in code, platform files, tests or tools. The needles are
  // split so this file does not match itself.
  test('the earlier id is gone everywhere', () {
    const oldOwner =
        'chacha'
        '12';
    const oldPackage =
        'astro'
        'planner';
    final skip = RegExp(r'[\\/](build|\.gradle|\.dart_tool)[\\/]');
    final hits = <String>[];
    for (final dir in ['lib', 'android', 'test', 'integration_test', 'tool']) {
      for (final f in Directory(dir).listSync(recursive: true)) {
        if (f is! File || skip.hasMatch(f.path)) continue;
        if (!RegExp(r'\.(dart|kt|kts|xml|py|gradle|properties)$')
            .hasMatch(f.path)) {
          continue;
        }
        final text = f.readAsStringSync().toLowerCase();
        if (text.contains(oldOwner) || text.contains(oldPackage)) {
          hits.add(f.path);
        }
      }
    }
    expect(hits, isEmpty);
  });

  test('the metadata channel has one name on both sides (S13.2)', () {
    const channel = 'io.github.buffur.culmina/metadata_document';
    expect(
      _read('lib/data/metadata/android_capture_file_access.dart'),
      contains("'$channel'"),
    );
    expect(
      _read(
        'android/app/src/main/kotlin/io/github/buffur/culmina/'
        'MetadataDocumentChannel.kt',
      ),
      contains('"$channel"'),
    );
  });
}
