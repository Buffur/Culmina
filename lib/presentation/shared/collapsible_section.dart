import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'hybrid_icon.dart';
import 'hybrid_quiet_ink.dart';
import '../viewmodels/disclosure_viewmodel.dart';

/// Detail one tap away (S5.5; ADR-019 §7, RD-06, RG-06): a header with the
/// section's title and a factual summary, and the content below it when
/// open. The open or closed state is remembered per [sectionKey]
/// ([DisclosureViewModel]).
///
/// The [summary] states facts ("3 lines · 2 h 35 min total"), never a
/// verdict ("good", "fine"); the verdict belongs to the status block. The
/// summary stays visible when the section is open.
class CollapsibleSection extends StatelessWidget {
  const CollapsibleSection({
    super.key,
    required this.sectionKey,
    required this.title,
    required this.child,
    this.summary,
    this.initiallyOpen = false,
    this.open,
    this.onToggle,
    this.topRule = true,
    this.titleStyle,
    this.icon,
    this.iconColor,
    this.readableFeedback = false,
  });

  /// A data icon before the title (conditions.css `.condition-data-heading`:
  /// 20 px, 10 before the words), e.g. the Moon or the Sun.
  final HybridIconData? icon;
  final Color? iconColor;

  /// Local opt-in for confirmed quiet-label interaction states.
  final bool readableFeedback;

  /// The Hybrid disclosure's thin rule above it (`.plan-disclosure`).
  final bool topRule;

  /// A nested disclosure's smaller title (Library 15/600); defaults to the
  /// section heading role 20/600.
  final TextStyle? titleStyle;

  /// Stable and unique, e.g. `planner.budgetDetails`; it names the stored
  /// preference, so never rename one without a reason.
  final String sectionKey;
  final String title;
  final String? summary;
  final Widget child;

  /// The state before the user has opened or closed it.
  final bool initiallyOpen;

  /// Controlled use (S7.6): the caller holds the state, e.g. a dialog whose
  /// section need not be remembered. With both set, the section reads no
  /// [DisclosureViewModel] and [initiallyOpen] is unused.
  final bool? open;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final controlled = this.open != null && onToggle != null;
    final vm = controlled ? null : context.watch<DisclosureViewModel>();
    final open =
        this.open ?? vm!.isOpen(sectionKey, initiallyOpen: initiallyOpen);
    final p = AppPalette.of(context);
    void toggle() => controlled ? onToggle!() : vm!.setOpen(sectionKey, !open);
    final resize = AppMotion.duration(context, AppMotion.medium);
    final Widget body = open
        ? Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: child,
          )
        : const SizedBox(width: double.infinity);

    // The Hybrid disclosure (hybrid-refinement.css `.plan-disclosure`):
    // grid title | chevron, gap 16, min 48, padding 6 0; title 20/600 at
    // 1.4; caption 13 at 1.4, 2 below; an 18 px chevron (m9 5 7 7-7 7,
    // stroke 1.7) turned down when closed and up when open (120 ms).
    final header = Semantics(
      key: Key('section.$sectionKey'),
      button: true,
      enabled: true,
      expanded: open,
      onTap: toggle,
      hint: open ? 'Collapse' : 'Expand',
      excludeSemantics: true,
      label: [title, ?summary].join(', '),
      child: InkWell(
        overlayColor: readableFeedback ? HybridQuietInk.overlay(context) : null,
        onTap: toggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (icon case final i?) ...[
                            HybridIcon(
                              i,
                              size: 20,
                              strokeWidth: 1.7,
                              color: iconColor ?? p.textPrimary,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Text(
                              title,
                              style:
                                  (titleStyle ??
                                          AppTypography.sectionHeading.copyWith(
                                            height: 1.4,
                                            letterSpacing: 0,
                                          ))
                                      .copyWith(color: p.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      if (summary != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            summary!,
                            style: AppTypography.caption.copyWith(
                              height: 1.4,
                              color: p.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AnimatedRotation(
                  turns: open ? -0.25 : 0.25,
                  duration: AppMotion.duration(context, AppMotion.short),
                  curve: AppMotion.curve,
                  child: HybridIcon(
                    HybridIcons.chevron,
                    size: 18,
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topRule)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: p.border)),
            ),
            child: header,
          )
        else
          header,
        // Reduced motion: no AnimatedSize at all (with a zero duration it
        // throws a layout assertion).
        if (resize == Duration.zero)
          body
        else
          ClipRect(
            child: AnimatedSize(
              duration: resize,
              curve: AppMotion.curve,
              alignment: Alignment.topCenter,
              child: body,
            ),
          ),
      ],
    );
  }
}
