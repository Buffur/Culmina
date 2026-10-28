import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../navigation/app_router.dart';
import '../../shared/context_line.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/hybrid_icon.dart';
import '../../viewmodels/session_plan_viewmodel.dart';

/// Tonight goes straight to the shared site chooser and management list.
Future<void> showHomeSiteSheet(BuildContext context) =>
    context.push<void>(AppRouter.selectSite);

/// Confirming the calendar updates the working plan through its existing
/// autosave path. Cancelling leaves the night and other plan edits intact.
Future<void> showHomeNightSheet(BuildContext context) async {
  final plan = context.read<SessionPlanViewModel>();
  final night = await pickNight(
    context,
    initial: plan.eveningDate ?? plan.tonightKey,
    builder: (context, child) {
      final theme = Theme.of(context);
      return Theme(
        data: theme.copyWith(
          // The seven-column grid needs the compact data role at large
          // text sizes. Keep the user's scaler and the theme's colours.
          datePickerTheme: theme.datePickerTheme.copyWith(
            dayStyle: AppTextTheme.of(context).body,
          ),
        ),
        child: child!,
      );
    },
  );
  if (night == null || !context.mounted || night == plan.eveningDate) return;
  await runWithFeedback(
    context,
    'change the night',
    () => plan.setEveningDate(night),
  );
}

/// The phone detail sheet's header (styles.css `.dialog-header` in
/// `#detail.phone-detail`): the app's name in 12 px tertiary, [actions],
/// then Close, over a subtle rule.
class HomeSheetHeader extends StatelessWidget {
  const HomeSheetHeader({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Culmina',
                style: AppTextTheme.of(context).dense
                    .copyWith(color: p.textTertiary),
              ),
            ),
            ...actions,
            IconButton(
              key: const Key('homeSheet.close'),
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: HybridIcon(
                HybridIcons.close,
                size: MediaQuery.textScalerOf(context).scale(20),
                color: p.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
