import '../../core/theme/app_text_theme.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/diagnostics/app_log.dart';
import '../../core/theme/app_theme.dart';
import '../../core/units/display_units.dart';
import 'culmina_mark_geometry.dart';
import 'startup_mark.dart';

/// The look the launch starts in: the app's stored field mode and
/// appearance, read before the first frame so the launch screen matches the
/// splash (which follows the same choice on Android 13+).
@immutable
class LaunchLook {
  const LaunchLook({this.fieldMode = false, this.appearance});

  final bool fieldMode;
  final Appearance? appearance;

  ThemeData theme(Brightness platform) {
    if (fieldMode) return AppTheme.fieldTheme;
    return switch (appearance) {
      Appearance.light => AppTheme.light,
      Appearance.dark => AppTheme.dark,
      Appearance.system ||
      null => platform == Brightness.dark ? AppTheme.dark : AppTheme.light,
    };
  }

  CulminaMarkColors colours(Brightness platform) =>
      theme(platform).extension<CulminaMarkColors>()!;
}

/// The whole launch, in one place (owner, 2026-10-23): the full gesture is
/// shown before the app opens, and data readiness never cuts it short.
///
/// The first frame is the still mark exactly where the Android splash drew
/// it. The gesture ([CulminaLaunchTimeline]) starts when this mark is the
/// one on screen ([splashGone], or the first frame where Android has no
/// splash of its own) while [initialize] runs alongside. The app is
/// revealed when both are done: the gesture has ended and the app is ready.
/// Then the mark fades on the still opaque launch background and the
/// background fades to the app, once. Until then the app is neither visible
/// nor reachable by touch or by assistive technology.
///
/// Reduced motion shows the still mark and reveals the app as soon as it is
/// ready, without waiting out the gesture's length. A gesture paused by the
/// app going to the background continues where it was. A failed start is
/// shown with Retry, never hidden behind the mark.
class LaunchGate extends StatelessWidget {
  const LaunchGate({
    super.key,
    required this.look,
    required this.initialize,
    this.splashGone,
    this.onShown,
    this.animate = true,
    this.handOverLimit = const Duration(milliseconds: 600),
    this.waitHint = const Duration(milliseconds: 1500),
  });

  final LaunchLook look;

  /// The critical start (storage, settings, the first route); completes
  /// with the app's root widget.
  final Future<Widget> Function() initialize;

  /// Completes when the Android 12+ splash has gone (`LaunchChannel`).
  final Future<void>? splashGone;

  /// Called once, when the app is shown.
  final VoidCallback? onShown;

  /// False when the app restarts itself (restore, reset): no gesture.
  final bool animate;

  /// How long the gesture waits for [splashGone] after the first frame
  /// before it starts anyway (a safety net, not a pause).
  final Duration handOverLimit;

  /// How long the still mark waits after the gesture before a quiet
  /// "still loading" line appears.
  final Duration waitHint;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.fromView(
      view: View.of(context),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: look.theme(
            View.of(context).platformDispatcher.platformBrightness,
          ),
          child: _LaunchStage(gate: this),
        ),
      ),
    );
  }
}

class _LaunchStage extends StatefulWidget {
  const _LaunchStage({required this.gate});

  final LaunchGate gate;

  @override
  State<_LaunchStage> createState() => _LaunchStageState();
}

class _LaunchStageState extends State<_LaunchStage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _gesture = AnimationController(
    vsync: this,
    duration: CulminaLaunchTimeline.gesture,
  )..addStatusListener(_onGesture);

  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: CulminaLaunchTimeline.markOut + CulminaLaunchTimeline.fieldOut,
  )..addStatusListener(_onExit);

  final _appKey = GlobalKey(debugLabel: 'launched app');

  Widget? _app;
  Object? _error;
  bool _gestureDone = false;
  bool _exiting = false;
  bool _shown = false;
  bool _waiting = false;
  bool _reduced = false;
  bool _paused = false;
  bool _initializing = false;
  Timer? _waitTimer;
  Timer? _handOverTimer;

  LaunchGate get _gate => widget.gate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => _awaitHandOver());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced && !_gestureDone && _gesture.isAnimating) {
      // Less motion asked for mid-gesture: the still mark, no wait.
      _gesture.value = 1;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _waitTimer?.cancel();
    _handOverTimer?.cancel();
    _gesture.dispose();
    _exit.dispose();
    super.dispose();
  }

  /// Starts the gesture when the Flutter mark is the one on screen.
  void _awaitHandOver() {
    if (!mounted) return;
    if (!_gate.animate || _reduced) {
      _finishGesture();
      return;
    }
    final gone = _gate.splashGone;
    if (gone == null) {
      _startGesture();
      return;
    }
    _handOverTimer = Timer(_gate.handOverLimit, _startGesture);
    gone.then((_) {
      _handOverTimer?.cancel();
      _startGesture();
    });
  }

  void _startGesture() {
    if (!mounted || _gesture.status != AnimationStatus.dismissed) return;
    if (_gesture.isAnimating || _gestureDone) return;
    if (_reduced) {
      _finishGesture();
    } else if (_paused) {
      // Started in the background: it plays when the app is back.
    } else {
      _gesture.forward();
    }
  }

  void _onGesture(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finishGesture();
  }

  void _finishGesture() {
    if (_gestureDone || !mounted) return;
    setState(() => _gestureDone = true);
    _waitTimer = Timer(_gate.waitHint, () {
      if (mounted && _app == null && _error == null) {
        setState(() => _waiting = true);
      }
    });
    _maybeReveal();
  }

  Future<void> _initialize() async {
    if (_initializing) return;
    _initializing = true;
    try {
      final app = await _gate.initialize();
      if (!mounted) return;
      setState(() => _app = app);
      _maybeReveal();
    } catch (e, s) {
      AppLog.error(
        'launch',
        'The app could not start',
        error: e,
        stackTrace: s,
      );
      if (mounted) setState(() => _error = e);
    } finally {
      _initializing = false;
    }
  }

  void _retry() {
    if (_initializing) return;
    setState(() {
      _error = null;
      _waiting = false;
    });
    _initialize();
  }

  /// One reveal, when the gesture is done and the app is ready.
  void _maybeReveal() {
    if (_app == null || !_gestureDone || _exiting) return;
    _waitTimer?.cancel();
    setState(() => _exiting = true);
    // The app is built under the opaque launch background first; the fade
    // starts on the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_reduced) {
        _exit.value = 1;
      } else if (!_paused) {
        _exit.forward();
      }
    });
  }

  void _onExit(AnimationStatus status) {
    if (status != AnimationStatus.completed || _shown) return;
    setState(() => _shown = true);
    _gate.onShown?.call();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_paused) return;
      _paused = false;
      // Continue where it was; time in the background is not counted.
      if (!_gestureDone && _gesture.value > 0 && !_gesture.isAnimating) {
        _gesture.forward();
      } else if (!_gestureDone && _gesture.isDismissed) {
        _startGesture();
      } else if (_exiting && !_shown && !_exit.isAnimating) {
        _exit.forward();
      }
    } else {
      // Inactive already: on Android the window is leaving (HyperOS sends
      // `hidden`/`paused` only after its ~0.75 s minimise animation, during
      // which the gesture would otherwise play out unseen). A shade pulled
      // over the launch pauses it too, until the app is back.
      _paused = true;
      if (_gesture.isAnimating) _gesture.stop();
      if (_exit.isAnimating) _exit.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = _gate.look.colours(
      MediaQuery.platformBrightnessOf(context),
    );
    final app = _app;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (app != null && _exiting)
          ExcludeSemantics(
            excluding: !_shown,
            child: IgnorePointer(
              ignoring: !_shown,
              child: KeyedSubtree(key: _appKey, child: app),
            ),
          ),
        if (!_shown)
          AnimatedBuilder(
            animation: Listenable.merge([_gesture, _exit]),
            builder: (context, _) => _launchScreen(colours),
          ),
      ],
    );
  }

  static const _markShare = 0.5; // markOut of markOut + fieldOut

  Widget _launchScreen(CulminaMarkColors colours) {
    final exit = _exit.value;
    final markOpacity = 1 - const Interval(0, _markShare).transform(exit);
    final fieldOpacity = 1 - const Interval(_markShare, 1).transform(exit);
    final frame = _gestureDone
        ? LaunchGestureFrame.still
        : LaunchGestureFrame.at(_gesture.value);
    final error = _error != null && _gestureDone;
    return Opacity(
      opacity: fieldOpacity,
      child: ColoredBox(
        color: colours.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Opacity(
                opacity: markOpacity,
                child: Semantics(
                  label: error ? null : 'Culmina is starting',
                  liveRegion: true,
                  child: SizedBox.square(
                    key: const Key('launch.mark'),
                    dimension: CulminaLaunchTimeline.canvas,
                    child: CustomPaint(
                      painter: CulminaMarkPainter(colours, frame: frame),
                    ),
                  ),
                ),
              ),
            ),
            if (error)
              _Failure(colours: colours, onRetry: _retry)
            else if (_waiting && !_exiting)
              _Waiting(colours: colours),
          ],
        ),
      ),
    );
  }
}

/// A quiet sign that the start takes longer, under the mark: no progress
/// value, nothing that repeats the brand gesture.
class _Waiting extends StatelessWidget {
  const _Waiting({required this.colours});

  final CulminaMarkColors colours;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.42),
      child: SizedBox(
        width: 72,
        child: LinearProgressIndicator(
          key: const Key('launch.waiting'),
          minHeight: 2,
          color: colours.inner,
          backgroundColor: colours.inner.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

/// A failed start, with the one action that can help.
class _Failure extends StatelessWidget {
  const _Failure({required this.colours, required this.onRetry});

  final CulminaMarkColors colours;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = AppTextTheme.of(context)
        .resolve(
          AppTextTheme.of(context).inherited,
          AppTextGeometry.launchFailure,
        )
        .copyWith(color: colours.orbit);
    return Align(
      alignment: const Alignment(0, 0.55),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Culmina couldn't start.",
              key: const Key('launch.error'),
              style: text,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Semantics(
              key: const Key('launch.retrySemantics'),
              button: true,
              enabled: true,
              onTap: onRetry,
              label: 'Try again',
              child: ExcludeSemantics(
                child: GestureDetector(
                  key: const Key('launch.retry'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onRetry,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: colours.inner),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Try again', style: text),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
