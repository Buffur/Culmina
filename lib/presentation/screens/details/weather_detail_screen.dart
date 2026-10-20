import 'package:flutter/material.dart';

import 'night_moon_screen.dart';

/// Opens the shared conditions browser on Weather; viewing another night
/// reuses the existing weather service without modifying the active plan.
class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) => const NightMoonScreen(initialPage: 2);
}
