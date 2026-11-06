import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_theme.dart';

/// Source-owned wording and actions shared by empty and unavailable content.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.action,
    this.titleKey,
  });
  final String title;
  final String? message;
  final Widget? action;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final t = AppTextTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            key: titleKey,
            style: t.rowTitle.copyWith(color: p.textPrimary),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(message!, style: t.body.copyWith(color: p.textSecondary)),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: EmptyState(
      title: message,
      action: const Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: EmptyState(
      title: title,
      message: message,
      action: onRetry == null
          ? null
          : OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
    ),
  );
}

/// Common asynchronous presentation; callers retain state and error wording.
class AsyncStateView extends StatelessWidget {
  const AsyncStateView.loading({super.key, String message = 'Loading…'})
    : _kind = 0,
      title = message,
      message = null,
      action = null,
      onRetry = null,
      retryLabel = 'Retry',
      titleKey = null;
  const AsyncStateView.empty({
    super.key,
    required this.title,
    this.message,
    this.action,
    this.titleKey,
  }) : _kind = 1,
       onRetry = null,
       retryLabel = 'Retry';
  const AsyncStateView.error({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.titleKey,
  }) : _kind = 2,
       action = null;
  final int _kind;
  final String title;
  final String? message;
  final Widget? action;
  final VoidCallback? onRetry;
  final String retryLabel;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: _kind != 1,
    child: EmptyState(
      title: title,
      titleKey: titleKey,
      message: message,
      action: _kind == 0
          ? const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(),
              ),
            )
          : _kind == 2 && onRetry != null
          ? OutlinedButton(onPressed: onRetry, child: Text(retryLabel))
          : action,
    ),
  );
}
