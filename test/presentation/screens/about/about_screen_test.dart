// TASK 8.2: the About page credits the catalog (OpenNGC, CC BY-SA 4.0) with
// its full bundled notice, and the other data sources. TASK 16.3 (the
// roadmap's attribution test): every third-party credit, the app's licence
// with its source, and the privacy summary with the policy link.

import 'dart:io';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/presentation/screens/about/about_screen.dart';
import 'package:astroplan/presentation/screens/settings/settings_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAbout(WidgetTester tester) async {
    final notice = File(AboutScreen.noticeAsset).readAsStringSync();
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: AboutScreen(loadNotice: () async => notice)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the OpenNGC notice and the other credits', (tester) async {
    await pumpAbout(tester);
    // S9.5: the notice, and the catalog's credit with its link.
    expect(find.textContaining('Mattia Verga'), findsWidgets);
    expect(find.textContaining('CC BY-SA 4.0'), findsWidgets);
    expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
    expect(
      find.textContaining('Weather data by Open-Meteo.com'),
      findsOneWidget,
    );
    expect(find.textContaining('CC BY 4.0'), findsOneWidget);
    expect(find.textContaining('lightpollutionmap.app'), findsWidgets);
    expect(find.text('Open-source licences'), findsOneWidget);
    // The full notice, one tap away.
    expect(find.byKey(const Key('about.noticeText')), findsNothing);
    await tester.tap(find.text('OpenNGC notice'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SelectableText>(find.byKey(const Key('about.noticeText')))
          .data,
      File(AboutScreen.noticeAsset).readAsStringSync(),
    );
  });

  // S9.5 (08 §23, D9-4): the author first, apart from third-party credit,
  // with Reddit prominent; every source a link.
  testWidgets('the author block comes first, with Reddit and GitHub', (
    tester,
  ) async {
    await pumpAbout(tester);
    final author = find.byKey(const Key('about.author'));
    expect(
      find.descendant(
        of: author,
        matching: find.textContaining('Made by Buffur'),
      ),
      findsOneWidget,
    );
    // settings.js aboutView: Reddit, then GitHub, as links.
    expect(
      tester.getTopLeft(find.byKey(const Key('about.reddit'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('about.github'))).dy),
    );
    expect(find.byKey(const Key('about.reddit')), findsOneWidget);
    expect(find.byKey(const Key('about.github')), findsOneWidget);
    expect(AboutScreen.authorReddit, 'https://www.reddit.com/user/Buffur/');
    expect(AboutScreen.authorGitHub, 'https://github.com/Buffur');
    expect(
      tester.getTopLeft(author).dy,
      lessThan(tester.getTopLeft(find.text('Data sources in the app')).dy),
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('about.version'))).data,
      'Version ${AppIdentity.version} · Made by Buffur',
    );
  });

  testWidgets('every data source has its link', (tester) async {
    await pumpAbout(tester);
    for (final key in [
      'about.openngc',
      'about.osm',
      'about.openMeteo',
      'about.lightPollution',
    ]) {
      expect(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(SettingsLink),
        ),
        findsOneWidget,
        reason: key,
      );
    }
    expect(find.text('openstreetmap.org/copyright'), findsOneWidget);
  });

  testWidgets('states the GPL-3.0 licence with a link to the source', (
    tester,
  ) async {
    await pumpAbout(tester);
    final licence = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('about.licence')),
        matching: find.byType(Text),
      ),
    );
    expect(licence.data, contains('GPL-3.0'));
    expect(licence.data, contains(AppIdentity.appName));
    expect(licence.data, contains(AppIdentity.version));
    expect(find.byKey(const Key('about.source')), findsOneWidget);
    expect(AppIdentity.sourceUrl, startsWith('https://'));
  });

  testWidgets('F23 A2: the accepted Play services permission is shown, as '
      'the README grants it', (tester) async {
    await pumpAbout(tester);
    final shown = tester
        .widget<Text>(find.byKey(const Key('about.playServices')))
        .data!;
    final readme = File('README.md').readAsStringSync();
    final quote = RegExp(
      r'^> (Additional permission under GNU GPL[\s\S]*?resulting work\.)',
      multiLine: true,
    ).firstMatch(readme)!;
    String words(String s) =>
        s.replaceAll(RegExp(r'\n> ?'), ' ').replaceAll(RegExp(r'\s+'), ' ');
    expect(shown, contains(words(quote[1]!)));
    expect(shown, contains('Google Play services location'));
  });

  testWidgets('summarises privacy and links the policy', (tester) async {
    await pumpAbout(tester);
    final privacy = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('about.privacy')),
        matching: find.byType(Text),
      ),
    );
    for (final phrase in [
      'No account, no ads, no analytics',
      'stay on this device',
      'Open-Meteo',
      'OpenStreetMap',
      'Nominatim',
      'if you switch it on in Settings, or when the site editor offers it',
    ]) {
      expect(privacy.data, contains(phrase));
    }
    expect(find.byKey(const Key('about.privacyPolicy')), findsOneWidget);
    expect(AppIdentity.privacyPolicyUrl, startsWith('https://'));
    expect(AppIdentity.privacyPolicyUrl, endsWith('/privacy/'));
  });
}
