import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/feature_scope.dart';
import '../../../domain/models/camera_class.dart';
import '../../shared/rig_input_text.dart';
import '../../shared/site_label.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../equipment/add_rig_panel.dart';
import '../../shared/equipment_draft.dart';
import '../equipment/equipment_editor.dart';
import '../metadata/metadata_import_screen.dart';
import '../../navigation/app_router.dart';
import '../../shared/example_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/location_feedback.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/tonight_viewmodel.dart';
import '../../../core/config/app_identity.dart';

/// The first-run setup (TASK 12.5; F16, S16.1, RA-B01–06): one page, the
/// app's first route on a first run (A1). Two optional steps — the
/// observing site, and a rig whose camera class comes first (F05) — and
/// Start planning, which (like back) closes it for good. No target step,
/// no Skip: both steps may simply be left. Location permission is asked
/// only on "Use current position"; a denial leaves choosing or typing a
/// site. A rig made here becomes the plan's rig (D8) and the page shows it
/// (UXA-C2).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static Future<void> _close(BuildContext context) async {
    // TASK 15.4: if it cannot be stored the page is offered again at the
    // next start; say so, and still close it now.
    await runWithFeedback(
      context,
      'save your setup',
      context.read<TonightViewModel>().finishFirstRun,
    );
    if (context.mounted) context.go(AppRouter.tonight);
  }

  /// D8: the rig just saved becomes the plan's, and the page says so.
  static Future<void> _choose(BuildContext context, int? id) async {
    if (id == null || !context.mounted) return;
    final rig = (await context.read<GearViewModel>().all())
        .where((r) => r.id == id)
        .firstOrNull;
    if (rig == null || !context.mounted) return;
    await context.read<SessionPlanViewModel>().setEquipment(rig);
    if (context.mounted) showDone(context, RigInputText.savedAndChosen);
  }

  static Future<void> _byHand(BuildContext context, CameraClass c) async {
    final id = await showEquipmentEditor(
      context,
      draft: EquipmentDraft.fromProfile(null).withCameraClass(c),
    );
    if (context.mounted) await _choose(context, id);
  }

  static Future<void> _fromPhoto(BuildContext context, CameraClass c) async {
    final id = await context.push<int>(
      AppRouter.metadata,
      extra: NewRigArgs(cameraClass: c, returnsNewRig: true),
    );
    if (context.mounted) await _choose(context, id);
  }

  static const intro =
      '${AppIdentity.appName} plans astrophotography: how long your frames '
      'take, how much they store, and whether they fit the night. Two '
      'optional steps help; you can leave both and set them later.';

  static const permission =
      'Night times, the Moon and target altitudes are computed for your '
      'site. ${AppIdentity.appName} asks for location permission only if you '
      'tap "Use current position", and uses your position on this device to '
      'compute the night. You can choose or enter a site instead.';

  @override
  Widget build(BuildContext context) {
    final siteVm = context.watch<SiteViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    final theme = Theme.of(context);
    final rig = planVm.selectedEquipment;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(context);
      },
      child: Scaffold(
        appBar: hybridAppBar(
          context,
          title: const Text('Welcome to ${AppIdentity.appName}'),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(intro, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            _Step(
              key: const Key('welcome.site'),
              number: 1,
              title: 'Your observing site (optional)',
              status: SiteLabel.of(siteVm) ?? 'Not set',
              explanation: permission,
              actions: [
                FilledButton.icon(
                  key: const Key('welcome.useCurrentPosition'),
                  onPressed: () =>
                      useCurrentPositionWithFeedback(context, siteVm),
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use current position'),
                ),
                OutlinedButton.icon(
                  key: const Key('welcome.chooseSite'),
                  onPressed: () => context.push(AppRouter.selectSite),
                  icon: const Icon(Icons.place_outlined),
                  label: const Text('Choose or add a site'),
                ),
              ],
            ),
            _Step(
              key: const Key('welcome.rig'),
              number: 2,
              title: 'Your rig (optional)',
              status: rig == null ? 'Not chosen' : ExampleText.rigName(rig),
              explanation:
                  'Telescope or lens and camera: they set the field of view, '
                  'the pixel scale, the exposure guidance and the storage '
                  'estimate.',
              actions: [
                AddRigPanel(
                  onByHand: (c) => _byHand(context, c),
                  onFromPhoto: FeatureScope.metadataImport
                      ? (c) => _fromPhoto(context, c)
                      : null,
                ),
                TextButton.icon(
                  key: const Key('welcome.chooseRig'),
                  onPressed: () => context.push(AppRouter.selectRigForPlan),
                  icon: const Icon(Icons.list_outlined),
                  label: const Text('Or choose a saved rig'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('welcome.start'),
              onPressed: () => _close(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Start planning'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    super.key,
    required this.number,
    required this.title,
    required this.status,
    required this.explanation,
    required this.actions,
  });

  final int number;
  final String title;
  final String status;
  final String explanation;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('$number. $title', style: theme.textTheme.titleMedium),
            Text(status, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(explanation, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ),
      ),
    );
  }
}
