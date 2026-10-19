import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/units/display_units.dart';
import '../viewmodels/display_settings_viewmodel.dart';

/// The units to show (F21), watched: the user's choice, or the metric
/// defaults where no display settings are provided.
DisplayUnits unitsOf(BuildContext context) =>
    context.watch<DisplaySettingsViewModel?>()?.units ?? DisplayUnits.metric;
