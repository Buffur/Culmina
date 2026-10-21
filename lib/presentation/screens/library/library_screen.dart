import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
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
    final site = siteVm.activeSite?.name;
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
          final siteCount = startup.isLoading || startup.hasBootstrapError
              ? 'Count unavailable'
              : '${siteVm.sites.length} saved';
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              ListTile(
                subtitleTextStyle: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text(AppWords.rigs),
                subtitle: Text(
                  counts == null
                      ? 'Your cameras with their lenses or telescopes'
                      : '${counts[0]} ${counts[0] == 1 ? 'rig' : 'rigs'} · '
                            'cameras with lenses or telescopes',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.libraryRigs),
              ),
              const Divider(height: 1),
              ListTile(
                subtitleTextStyle: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                leading: const Icon(Icons.auto_awesome_outlined),
                title: const Text(AppWords.targets),
                subtitle: Text(
                  counts == null
                      ? 'The catalog and the targets you added'
                      : '${counts[1]} ${counts[1] == 1 ? 'target' : 'targets'}'
                            ' · catalog and your additions',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.libraryTargets),
              ),
              const Divider(height: 1),
              ListTile(
                subtitleTextStyle: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                leading: const Icon(Icons.place_outlined),
                title: const Text(AppWords.sites),
                subtitle: Text(
                  site == null
                      ? '$siteCount · no active site'
                      : '$siteCount · active: $site',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.librarySites),
              ),
              const Divider(height: 1),
              if (snapshot.hasError)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Couldn't load library counts. Lists remain available.",
                    ),
                    TextButton(
                      key: const Key('library.retryCounts'),
                      onPressed: _retry,
                      child: const Text('Retry counts'),
                    ),
                  ],
                ),
              if (startup.hasBootstrapError)
                TextButton(
                  onPressed: startup.retryBootstrap,
                  child: const Text('Retry loading saved site'),
                ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Text(
                  'Progress by target lives in the Logbook.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              // Progress moved to the Logbook (S8.5; RD-07, ADR-019 §8).
            ],
          );
        },
      ),
    );
  }
}
