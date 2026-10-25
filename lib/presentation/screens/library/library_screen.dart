import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../shared/hybrid_icon.dart';
import '../settings/settings_parts.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/field_mode_button.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/startup_viewmodel.dart';

/// The Library tab (ADR-015): rigs, targets and sites, managed here (S9.1,
/// RD-07, D9-1): nothing here changes the plan, so the tiles describe the
/// Library, not the plan. Progress by target lives in the Logbook (S8.5).
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<List<int>> _counts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gear = context.watch<GearViewModel>();
    final targets = context.watch<TargetsViewModel>();
    _counts = _readCounts(gear, targets);
  }

  Future<List<int>> _readCounts(
    GearViewModel gear,
    TargetsViewModel targets,
  ) async => Future.wait([
    gear.all().then((items) => items.length),
    targets.search('').then((items) => items.length),
  ]);

  void _retry() => setState(() {
    _counts = _readCounts(
      context.read<GearViewModel>(),
      context.read<TargetsViewModel>(),
    );
  });

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final startup = context.watch<StartupViewModel>();
    final p = AppPalette.of(context);
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: const Text(AppWords.library),
        actions: const [FieldModeButton()],
      ),
      body: FutureBuilder<List<int>>(
        future: _counts,
        builder: (context, snapshot) {
          // A refresh/error never presents the old count as a current fact.
          final counts =
              snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError
              ? snapshot.data
              : null;
          final sites = startup.isLoading || startup.hasBootstrapError
              ? 'Count unavailable'
              : '${siteVm.sites.length} saved';
          final caption = AppTypography.caption.copyWith(
            height: 1.55,
            color: p.textSecondary,
          );
          // library.js `rootView`.
          return ListView(
            padding: settingsPagePadding,
            children: [
              DocumentSection(
                key: const Key('library.collectionsGroup'),
                children: [
                  SettingsRow(
                    key: const Key('library.rigs'),
                    icon: HybridIcons.camera,
                    title: AppWords.rigs,
                    summary: counts == null
                        ? 'Your cameras with their lenses or telescopes'
                        : '${counts[0]} ${counts[0] == 1 ? 'rig' : 'rigs'} · your '
                              'cameras with their lenses or telescopes',
                    onTap: () => context.push(AppRouter.libraryRigs),
                  ),
                  SettingsRow(
                    key: const Key('library.targets'),
                    icon: HybridIcons.target,
                    title: AppWords.targets,
                    summary: counts == null
                        ? 'The catalogue and the targets you added'
                        : '${counts[1]} ${counts[1] == 1 ? 'target' : 'targets'}'
                              ' · the catalogue and the targets you added',
                    onTap: () => context.push(AppRouter.libraryTargets),
                  ),
                  SettingsRow(
                    key: const Key('library.sites'),
                    divider: false,
                    icon: HybridIcons.pin,
                    title: AppWords.sites,
                    summary: '$sites · choose the planning site in Plan',
                    onTap: () => context.push(AppRouter.librarySites),
                  ),
                ],
              ),
              if (snapshot.hasError) ...[
                const SizedBox(height: AppSpacing.itemGap),
                Text(
                  "Couldn't load library counts. Lists remain available.",
                  style: caption,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('library.retryCounts'),
                    onPressed: _retry,
                    child: const Text('Retry counts'),
                  ),
                ),
              ],
              if (startup.hasBootstrapError)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: startup.retryBootstrap,
                    child: const Text('Retry loading saved site'),
                  ),
                ),
              // Progress moved to the Logbook (S8.5; RD-07, ADR-019 §8).
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.itemGap),
                child: Text(
                  'Progress by target lives in the Logbook.',
                  style: caption,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
