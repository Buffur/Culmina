import 'package:flutter/material.dart';

import 'night_moon_screen.dart';

/// Opens the shared conditions browser on Weather; viewing another night
/// reuses the SectionCard/FactRow weather body and its shared hourly axis
/// without modifying the active plan.
class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) => const NightMoonScreen(initialPage: 2);
}
