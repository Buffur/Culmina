import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

final _messages = Expando<AppMessageController>();

/// A message's outcome keeps the existing scoped Undo/commit contract.
class AppMessageController {
  AppMessageController(this._finish);
  final void Function(SnackBarClosedReason) _finish;
  final _closed = Completer<SnackBarClosedReason>();
  Future<SnackBarClosedReason> get closed => _closed.future;
  void close() => _finish(SnackBarClosedReason.hide);
}

/// Hybrid feedback takes a Scaffold layout row, so it cannot cover actions.
/// Existing content, Undo callbacks, expiry and close outcomes are preserved.
extension AppMessages on ScaffoldMessengerState {
  void hideCurrentMessage() => _messages[this]?.close();

  AppMessageController showMessage(SnackBar bar) {
    hideCurrentMessage();
    late AppMessageController result;
    void finish(SnackBarClosedReason reason) {
      if (result._closed.isCompleted) return;
      if (mounted && identical(_messages[this], result)) {
        hideCurrentMaterialBanner();
        _messages[this] = null;
      }
      result._closed.complete(reason);
    }

    result = AppMessageController(finish);
    _messages[this] = result;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final theme = Theme.of(context);
    final action = bar.action;
    final accessible = MediaQuery.maybeAccessibleNavigationOf(context) ?? false;
    final expires =
        bar.persist == false ||
        (bar.persist != true && (action == null || !accessible));
    final banner = showMaterialBanner(
      _InlineMessageBanner(
        key: bar.key,
        reduced: reduced,
        content: _MessageLifetime(
          duration: expires ? bar.duration : null,
          onExpired: () => finish(SnackBarClosedReason.timeout),
          child: Semantics(liveRegion: true, child: bar.content),
        ),
        contentTextStyle: theme.textTheme.bodySmall,
        backgroundColor: theme.colorScheme.surface,
        dividerColor: theme.dividerColor,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        actions: [
          if (action != null)
            TextButton(
              onPressed: () {
                if (result._closed.isCompleted) return;
                action.onPressed();
                finish(SnackBarClosedReason.action);
              },
              child: Text(action.label),
            ),
          IconButton(
            key: const Key('appMessage.dismiss'),
            tooltip: 'Dismiss',
            onPressed: () => finish(SnackBarClosedReason.dismiss),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
    unawaited(banner.closed.then((_) => finish(SnackBarClosedReason.hide)));
    return result;
  }
}

class _MessageLifetime extends StatefulWidget {
  const _MessageLifetime({
    required this.duration,
    required this.onExpired,
    required this.child,
  });
  final Duration? duration;
  final VoidCallback onExpired;
  final Widget child;

  @override
  State<_MessageLifetime> createState() => _MessageLifetimeState();
}

class _MessageLifetimeState extends State<_MessageLifetime> {
  Timer? expiry;
  @override
  void initState() {
    super.initState();
    final duration = widget.duration;
    if (duration != null) expiry = Timer(duration, widget.onExpired);
  }

  @override
  void dispose() {
    expiry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _InlineMessageBanner extends MaterialBanner {
  const _InlineMessageBanner({
    super.key,
    required this.reduced,
    required super.content,
    required super.actions,
    super.contentTextStyle,
    super.backgroundColor,
    super.dividerColor,
    super.padding,
  });
  final bool reduced;

  @override
  MaterialBanner withAnimation(
    Animation<double> newAnimation, {
    Key? fallbackKey,
  }) => MaterialBanner(
    key: key ?? fallbackKey,
    content: content,
    actions: actions,
    contentTextStyle: contentTextStyle,
    backgroundColor: backgroundColor,
    dividerColor: dividerColor,
    padding: padding,
    animation: reduced
        ? const AlwaysStoppedAnimation(1)
        : newAnimation.drive(CurveTween(curve: AppMotion.curve)),
  );
}
