import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/widget_previews.dart';

import '../../core/units/display_units.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_theme.dart';
import 'launch_gate.dart';

// Widget previews of the launch (owner, 2026-10-23): the production
// [LaunchGate] and its timeline, with a stand-in app. Slow motion
// (`timeDilation`) and the chosen "ready" moment exist only here.

@Preview(name: 'Launch · dark', size: Size(390, 844))
Widget launchPreviewDark() =>
    const LaunchPreview(look: LaunchLook(appearance: Appearance.dark));

@Preview(name: 'Launch · light', size: Size(390, 844))
Widget launchPreviewLight() =>
    const LaunchPreview(look: LaunchLook(appearance: Appearance.light));

@Preview(name: 'Launch · field mode', size: Size(390, 844))
Widget launchPreviewField() =>
    const LaunchPreview(look: LaunchLook(fieldMode: true));

/// Replays [LaunchGate] with a stand-in app that is ready after a chosen
/// time, at normal speed or four times slower.
class LaunchPreview extends StatefulWidget {
  const LaunchPreview({super.key, required this.look});

  final LaunchLook look;

  @override
  State<LaunchPreview> createState() => _LaunchPreviewState();
}

class _LaunchPreviewState extends State<LaunchPreview> {
  static const _readyAfter = [
    Duration(milliseconds: 80),
    Duration(milliseconds: 700),
    Duration(milliseconds: 2600),
  ];

  int _run = 0;
  int _ready = 0;
  bool _slow = false;

  @override
  void dispose() {
    timeDilation = 1;
    super.dispose();
  }

  void _replay({int? ready, bool? slow}) => setState(() {
    _ready = ready ?? _ready;
    _slow = slow ?? _slow;
    timeDilation = _slow ? 4 : 1;
    _run++;
  });

  @override
  Widget build(BuildContext context) {
    final readyAfter = _readyAfter[_ready];
    return Stack(
      fit: StackFit.expand,
      children: [
        LaunchGate(
          key: ValueKey(_run),
          look: widget.look,
          initialize: () => Future.delayed(
            readyAfter * (_slow ? 4 : 1),
            () => const _StandInApp(),
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: Material(
            color: AppPalette.of(context).surfaceRaised,
            borderRadius: BorderRadius.circular(8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                for (var i = 0; i < _readyAfter.length; i++)
                  TextButton(
                    onPressed: () => _replay(ready: i),
                    child: Text(
                      'Ready ${_readyAfter[i].inMilliseconds} ms',
                      style: AppTextTheme.of(context).inherited.copyWith(
                        color: i == _ready
                            ? AppPalette.of(context).textPrimary
                            : AppPalette.of(context).textSecondary,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => _replay(slow: !_slow),
                  child: Text(
                    _slow ? 'Normal speed' : 'Slow ×4',
                    style: AppTextTheme.of(context).inherited
                        .copyWith(color: AppPalette.of(context).textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StandInApp extends StatelessWidget {
  const _StandInApp();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Center(
      child: Text(
        'The app',
        textDirection: TextDirection.ltr,
        style: AppTextTheme.of(context).sectionHeading
            .copyWith(color: AppPalette.of(context).textPrimary),
      ),
    ),
  );
}
