import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'hybrid_icon.dart';

/// A compact geo group heading, sharing the form's content edge.
class GeoHeading extends StatelessWidget {
  const GeoHeading(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      label,
      style: AppTypography.body.copyWith(
        fontWeight: FontWeight.w600,
        color: AppPalette.of(context).textPrimary,
      ),
    ),
  );
}

/// Secondary geo commands are flat rows, not competing primary buttons.
class GeoActionRow extends StatelessWidget {
  const GeoActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.divider = true,
  });
  final HybridIconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
          foregroundDecoration: !divider
              ? null
              : BoxDecoration(
                  border: Border(bottom: BorderSide(color: p.border)),
                ),
          child: Row(
            children: [
              HybridIcon(icon, size: 20, color: p.textPrimary),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(color: p.textPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.itemGap),
              HybridIcon(
                HybridIcons.rowChevron,
                size: 18,
                color: p.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visible GPS/map commands; stack at large text rather than shrinking it.
class GeoPositionActions extends StatelessWidget {
  const GeoPositionActions({
    super.key,
    required this.locating,
    required this.onLocate,
    required this.onMap,
  });
  final bool locating;
  final VoidCallback onLocate;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    Widget action(
      Key key,
      HybridIconData icon,
      String label,
      VoidCallback? press,
    ) => OutlinedButton(
      key: key,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onPressed: press,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HybridIcon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
    final commands = [
      action(
        const Key('siteEditor.useCurrentPosition'),
        HybridIcons.locate,
        locating ? 'Getting position…' : 'Current position',
        locating ? null : onLocate,
      ),
      action(const Key('siteEditor.pickOnMap'), HybridIcons.map, 'Map', onMap),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        if (MediaQuery.textScalerOf(context).scale(1) >= 1.5 ||
            box.maxWidth < 280) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: commands,
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.itemGap,
            children: [for (final c in commands) Expanded(child: c)],
          ),
        );
      },
    );
  }
}
