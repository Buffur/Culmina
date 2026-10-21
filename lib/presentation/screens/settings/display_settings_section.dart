import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/display_units.dart';
import '../../shared/failure_feedback.dart';
import '../../viewmodels/display_settings_viewmodel.dart';

/// Appearance and units (F21, S16.6, PD-20; D1 = A): System, Light or Dark
/// (System by default), and the units shown for temperature, wind and
/// elevation. Display only: stored values and calculations keep their
/// canonical units. A choice that cannot be stored stays applied and says
/// so, with Retry (A5).
class DisplaySettingsSection extends StatelessWidget {
  const DisplaySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DisplaySettingsViewModel?>();
    if (vm == null) return const SizedBox.shrink();
    final units = vm.units;
    void change(Future<void> Function() write) =>
        runWithFeedback(context, 'save the display setting', write);
    Widget choice<T>(
      String key,
      String title,
      List<(T, String)> options,
      T selected,
      void Function(T) onSelected,
    ) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<T>(
            key: Key(key),
            direction: MediaQuery.textScalerOf(context).scale(14) > 21
                ? Axis.vertical
                : Axis.horizontal,
            segments: [
              for (final (v, label) in options)
                ButtonSegment(value: v, label: Text(label)),
            ],
            selected: {selected},
            onSelectionChanged: (s) => onSelected(s.first),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        choice<Appearance>(
          'settings.appearance',
          'Appearance',
          [for (final a in Appearance.values) (a, a.label)],
          vm.appearance,
          (a) => change(() => vm.setAppearance(a)),
        ),
        choice<TemperatureUnit>(
          'settings.units.temperature',
          'Temperature',
          [for (final u in TemperatureUnit.values) (u, u.symbol)],
          units.temperature,
          (u) => change(() => vm.setUnits(units.copyWith(temperature: u))),
        ),
        choice<WindUnit>(
          'settings.units.wind',
          'Wind',
          [for (final u in WindUnit.values) (u, u.symbol)],
          units.wind,
          (u) => change(() => vm.setUnits(units.copyWith(wind: u))),
        ),
        choice<ElevationUnit>(
          'settings.units.elevation',
          'Elevation',
          [for (final u in ElevationUnit.values) (u, u.symbol)],
          units.elevation,
          (u) => change(() => vm.setUnits(units.copyWith(elevation: u))),
        ),
        if (vm.unsaved) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Shown now, but not saved: after a restart the saved choice '
            'returns.',
            key: const Key('settings.display.unsaved'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('settings.display.retry'),
              onPressed: () => change(vm.retry),
              child: const Text('Retry'),
            ),
          ),
        ],
      ],
    );
  }
}
