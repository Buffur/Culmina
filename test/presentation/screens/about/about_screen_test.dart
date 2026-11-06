// TASK 8.2: the About page credits the catalog (OpenNGC, CC BY-SA 4.0) with
// its full bundled notice, and the other data sources. TASK 16.3 (the
// roadmap's attribution test): every third-party credit, the app's licence
// with its source, and the privacy summary with the policy link.

import '../../../support/phase2_state_capture.dart';
import '../../../support/wave1_capture.dart';

import 'dart:io';
import 'dart:async';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/presentation/screens/about/about_screen.dart';
import 'package:astroplan/presentation/screens/settings/settings_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

late String _phase2Theme;

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    group('Phase2 $theme', () {
      setUp(() => _phase2Theme = theme);
      Future<void> pumpAbout(WidgetTester tester) async {
        final notice = File(AboutScreen.noticeAsset).readAsStringSync();
        tester.view.physicalSize = const Size(800, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: phase2Theme(_phase2Theme),
            builder: (_, child) =>
                phase2Frame(child: child!, theme: _phase2Theme),
            home: AboutScreen(loadNotice: () async => notice),
          ),
        );
        await tester.pumpAndSettle();
      }

      testWidgets('a failing notice load attaches only when expanded', (
        tester,
      ) async {
        var loads = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: phase2Theme(_phase2Theme),
            builder: (_, child) =>
                phase2Frame(child: child!, theme: _phase2Theme),
            home: AboutScreen(
              loadNotice: () async {
                loads++;
                throw StateError('synthetic missing notice asset');
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(loads, 0);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byKey(const Key('about.notice')));
        await tester.tap(find.text('OpenNGC notice'));
        await tester.pumpAndSettle();
        expect(loads, 1);
        expect(
          find.text(
            'Target catalog: adapted from OpenNGC by Mattia Verga, CC BY-SA 4.0.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('OpenNGC notice'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OpenNGC notice'));
        await tester.pumpAndSettle();
        expect(
          loads,
          1,
          reason: 'cached notice result survives disclosure toggles',
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'pending and failed notice keep its source and readable state',
        (tester) async {
          tester.view.physicalSize = const Size(375, 812);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final notice = Completer<String>();
          await tester.pumpWidget(
            MaterialApp(
              theme: phase2Theme(_phase2Theme),
              builder: (_, child) =>
                  phase2Frame(child: child!, theme: _phase2Theme),
              home: AboutScreen(loadNotice: () => notice.future),
            ),
          );
          await tester.pumpAndSettle();
          final disclosure = find.byKey(const Key('about.notice'));
          await tester.ensureVisible(disclosure);
          await tester.tap(find.text('OpenNGC notice'));
          await tester.pumpAndSettle();
          expect(find.text('Loading OpenNGC notice…'), findsOneWidget);
          await tester.ensureVisible(find.byKey(const Key('about.noticeText')));
          await tester.pumpAndSettle();
          await capturePhase2State(
            tester,
            package: 'package4-startup',
            state: 'about-notice-pending',
            theme: _phase2Theme,
          );
          notice.completeError(StateError('synthetic missing asset'));
          await tester.pumpAndSettle();
          expect(find.text('Loading OpenNGC notice…'), findsNothing);
          expect(
            find.text(
              'Target catalog: adapted from OpenNGC by Mattia Verga, CC BY-SA 4.0.',
            ),
            findsOneWidget,
          );
          await capturePhase2State(
            tester,
            package: 'package4-startup',
            state: 'about-notice-failed-attribution-fallback',
            theme: _phase2Theme,
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Open-source licences opens the real local LicensePage and Back returns',
        (tester) async {
          await pumpAbout(tester);
          tester.view.physicalSize = const Size(375, 812);
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Open-source licences').hitTestable(),
            400,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(
            find.text('Open-source licences').hitTestable(),
            findsOneWidget,
          );
          await tester.tap(find.text('Open-source licences').hitTestable());
          await tester.pumpAndSettle();
          expect(find.byType(LicensePage), findsOneWidget);
          final page = tester.widget<LicensePage>(find.byType(LicensePage));
          expect(page.applicationName, AppIdentity.appName);
          expect(page.applicationVersion, AppIdentity.version);
          await capturePhase2State(
            tester,
            package: 'package4-startup',
            state: 'about-open-source-license-destination',
            theme: _phase2Theme,
          );
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(find.byType(LicensePage), findsNothing);
          expect(find.text('About'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('shows the OpenNGC notice and the other credits', (
        tester,
      ) async {
        await pumpAbout(tester);
        // S9.5: the notice, and the catalog's credit with its link.
        expect(find.textContaining('Mattia Verga'), findsWidgets);
        expect(find.textContaining('CC BY-SA 4.0'), findsWidgets);
        expect(
          find.textContaining('OpenStreetMap contributors'),
          findsOneWidget,
        );
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
    });
  }
}
