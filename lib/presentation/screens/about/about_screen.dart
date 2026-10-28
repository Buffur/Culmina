import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:flutter/services.dart' show rootBundle;

import '../../../core/config/app_identity.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../shared/collapsible_section.dart';
import '../settings/settings_parts.dart';

/// About: the author, the data sources and their attribution, privacy and
/// the licence (TASK 8.2, TASK 16.3; S9.5, 08 §23, D9-4). The author comes
/// first and apart from third-party credit; every source is a link, worded
/// as its terms ask (`docs/COMPLIANCE.md`). The target catalog is an adapted
/// subset of OpenNGC (CC BY-SA 4.0), whose notice is shown in full. The
/// source-code, project and policy links stay as they are until RD-01.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.loadNotice});

  static const String noticeAsset = 'assets/catalog/OPENNGC_NOTICE.txt';

  /// The author's public handle and profiles (the owner's, 08 §23).
  static const String author = 'Buffur';
  static const String authorReddit = 'https://www.reddit.com/user/Buffur/';
  static const String authorGitHub = 'https://github.com/Buffur';

  /// Loads the OpenNGC notice; defaults to the bundled asset.
  final Future<String> Function()? loadNotice;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final small = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).caption, AppTextGeometry.reading)
        .copyWith(color: p.textSecondary);
    final quiet = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).body, AppTextGeometry.reading)
        .copyWith(color: p.textSecondary);
    // settings.js `aboutView`: the app and its author, the data sources,
    // then the licence; the privacy summary stays here too (TASK 16.3).
    return Scaffold(
      appBar: hybridAppBar(context, title: const Text('About')),
      body: ListView(
        padding: settingsPagePadding,
        children: [
          DocumentSection(
            key: const Key('about.identityGroup'),
            children: [
              // S9.5 (08 §23): the author, prominent and first.
              Column(
                key: const Key('about.author'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SettingsHeading(AppIdentity.appName, top: 0),
                  Text(
                    'Version ${AppIdentity.version} · Made by $author',
                    key: const Key('about.version'),
                    style: quiet,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const SettingsLink(
                    key: Key('about.reddit'),
                    label: 'Reddit: u/$author',
                    url: authorReddit,
                  ),
                  const SettingsLink(
                    key: Key('about.github'),
                    label: 'GitHub: $author',
                    url: authorGitHub,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const DocumentSection(
            joinNext: true,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            children: [SettingsHeading('Data sources in the app', top: 0)],
          ),
          const DocumentSection(
            joinPrevious: true,
            joinNext: true,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _Source(
                key: Key('about.openngc'),
                text:
                    'Target catalog: adapted from OpenNGC, by Mattia Verga, '
                    'CC BY-SA 4.0.',
                label: 'OpenNGC on GitHub',
                url: 'https://github.com/mattiaverga/OpenNGC',
              ),
            ],
          ),
          // The catalog notice in full, as its licence asks (COMPLIANCE).
          // The catalog notice in full, as its licence asks (COMPLIANCE).
          DocumentSection(
            joinPrevious: true,
            joinNext: true,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _Notice(
                load: loadNotice ?? () => rootBundle.loadString(noticeAsset),
                style: small,
              ),
            ],
          ),
          const DocumentSection(
            joinPrevious: true,
            joinNext: true,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _Source(
                key: Key('about.osm'),
                text:
                    'Map tiles and place names: © OpenStreetMap contributors, via '
                    'the OpenStreetMap tile servers and Nominatim.',
                label: 'openstreetmap.org/copyright',
                url: 'https://www.openstreetmap.org/copyright',
              ),
            ],
          ),
          const DocumentSection(
            joinPrevious: true,
            joinNext: true,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _Source(
                key: Key('about.openMeteo'),
                text:
                    'Weather data by Open-Meteo.com (CC BY 4.0). The model used is '
                    'shown with each forecast.',
                label: 'open-meteo.com',
                url: 'https://open-meteo.com/',
              ),
            ],
          ),
          const DocumentSection(
            joinPrevious: true,
            joinNext: false,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            children: [
              _Source(
                key: Key('about.lightPollution'),
                text:
                    'Light-pollution map: lightpollutionmap.app, opened in your '
                    'browser; nothing is fetched by the app.',
                label: 'lightpollutionmap.app',
                url: 'https://lightpollutionmap.app/',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocumentSection(
            key: const Key('about.privacyGroup'),
            children: [
              const SettingsHeading('Privacy', top: 0),
              const SettingsCopy(
                'No account, no ads, no analytics and no tracking. Your sites, '
                'rigs, targets, plans and results stay on this device. The app '
                'sends a position only to fetch the weather (Open-Meteo), to '
                'show map tiles (OpenStreetMap) and — if you switch it on in '
                'Settings, or when the site editor offers it — to look up a '
                'place name (Nominatim). Location '
                'permission is asked only when you tap "Use current position".',
                key: Key('about.privacy'),
              ),
              const SettingsLink(
                key: Key('about.privacyPolicy'),
                label: 'Privacy policy',
                url: AppIdentity.privacyPolicyUrl,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocumentSection(
            key: const Key('about.licenceGroup'),
            children: [
              const SettingsHeading('Licence', top: 0),
              const SettingsCopy(
                '${AppIdentity.appName} ${AppIdentity.version} is free software '
                'under the GNU General Public License v3.0 (GPL-3.0). You may '
                'use, study, share and change it under that licence.',
                key: Key('about.licence'),
              ),
              // F23 A2 (S12.4 = (a)): the owner's accepted exception for the
              // Google Play services location libraries in the Android build;
              // the same words as README.md and COMPLIANCE.md.
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'The Android build includes Google Play services location, '
                  'used only when you tap "Use current position". '
                  '$playServicesPermission',
                  key: const Key('about.playServices'),
                  style: small,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const SettingsLink(
                key: Key('about.source'),
                label: 'Source code',
                url: AppIdentity.sourceUrl,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(HybridTokens.minTarget),
                ),
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: AppIdentity.appName,
                  applicationVersion: AppIdentity.version,
                ),
                child: const Text('Open-source licences'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The additional permission under GPL-3.0 section 7 (S12.4 = (a)).
const playServicesPermission =
    'Additional permission under GNU GPL version 3 section 7: if you modify '
    'this program, or any covered work, by linking or combining it with the '
    'Google Play services libraries (or a modified version of those '
    'libraries), containing parts covered by the terms of the Android '
    'Software Development Kit License, the licensors of this program grant '
    'you additional permission to convey the resulting work.';

/// One data source (`.settings-sources li`): a bullet, its credit, then
/// its link (S9.5).
class _Source extends StatelessWidget {
  const _Source({
    super.key,
    required this.text,
    required this.label,
    required this.url,
  });

  final String text;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final style = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).body, AppTextGeometry.standard)
        .copyWith(color: AppPalette.of(context).textPrimary);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The list's disc: 5 px, centred on the first line.
          SizedBox(
            width: AppSpacing.gutter,
            height: 21,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: style.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: style),
                SettingsLink(label: label, url: url),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The bundled OpenNGC notice, one tap away under the catalog's credit.
class _Notice extends StatefulWidget {
  const _Notice({required this.load, required this.style});

  final Future<String> Function() load;
  final TextStyle style;

  @override
  State<_Notice> createState() => _NoticeState();
}

class _NoticeState extends State<_Notice> {
  late final Future<String> _text = widget.load();
  bool _open = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.gutter),
    child: CollapsibleSection(
      key: const Key('about.notice'),
      sectionKey: 'about.openngcNotice',
      title: 'OpenNGC notice',
      titleStyle: settingsLegendStyle(context)
          .copyWith(fontWeight: FontWeight.w600),
      open: _open,
      onToggle: () => setState(() => _open = !_open),
      child: FutureBuilder<String>(
        future: _text,
        // TASK 15.3: selectable text is a long-press target (48 px).
        builder: (context, snapshot) => ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: SelectableText(
            snapshot.data ??
                (snapshot.hasError
                    ? 'Target catalog: adapted from OpenNGC by Mattia '
                          'Verga, CC BY-SA 4.0.'
                    : ''),
            key: const Key('about.noticeText'),
            style: widget.style,
          ),
        ),
      ),
    ),
  );
}
