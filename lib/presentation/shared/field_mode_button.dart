import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/feature_scope.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'failure_feedback.dart';
import 'hybrid_icon.dart';

/// Red field mode, one tap from Tonight and the planner (ADR-015 §4,
/// TASK 12.4). Reads the gate itself, so call sites never gate it again.
class FieldModeButton extends StatelessWidget {
  const FieldModeButton({super.key, this.home = false});

  /// Tonight's square 48 button with the 20 px Home moon (styles.css
  /// `.icon-button`); otherwise the app bar's round 48 button with the
  /// 24 px moon at stroke 1.8 (plan.css `.android-icon-button`). The moon
  /// stays the same in both states; the pressed state is announced.
  final bool home;

  @override
  Widget build(BuildContext context) {
    if (!FeatureScope.fieldMode) return const SizedBox.shrink();
    final on = context.watch<ThemeViewModel>().isFieldMode;
    final scale = MediaQuery.textScalerOf(context);
    return Semantics(
      toggled: on,
      child: IconButton(
        key: const Key('fieldMode.toggle'),
        icon: home
            ? HybridIcon(HybridIcons.homeMoon, size: scale.scale(20))
            : HybridIcon(
                HybridIcons.moon,
                size: scale.scale(24),
                strokeWidth: 1.8,
              ),
        style: home
            ? IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              )
            : null,
        tooltip: on ? 'Turn off field mode' : 'Turn on field mode',
        onPressed: () => _toggle(context),
      ),
    );
  }
}

/// The same switch as a Settings row.
class FieldModeTile extends StatelessWidget {
  const FieldModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    if (!FeatureScope.fieldMode) return const SizedBox.shrink();
    return SwitchListTile(
      key: const Key('fieldMode.tile'),
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.nightlight_round),
      title: const Text('Red field mode'),
      subtitle: const Text(
        'Red on black only, to keep your night vision. Stays on after a '
        'restart.',
      ),
      value: context.watch<ThemeViewModel>().isFieldMode,
      onChanged: (_) => _toggle(context),
    );
  }
}

/// Switches field mode; it switches even when it cannot be stored, and
/// then says it will not survive a restart (TASK 15.4).
Future<void> _toggle(BuildContext context) => runWithFeedback(
  context,
  'save the field mode setting',
  context.read<ThemeViewModel>().toggleFieldMode,
);
