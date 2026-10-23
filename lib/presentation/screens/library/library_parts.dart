import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/hybrid_parts.dart';

/// The pieces of Hybrid's Library pages (library.js, library.css), shared
/// by the rig, target and site lists and their records.

/// "Editing here never selects a record in the Plan or rewrites a saved
/// plan or Logbook snapshot." (library.js `SNAPSHOT_NOTE`).
const librarySnapshotNote =
    'Editing here never selects a record in the Plan or rewrites a saved '
    'plan or Logbook snapshot.';

/// The search field (`.library-search-field`): the italic hint, the
/// magnifier marking the field at its end; a clear button once typed.
class LibrarySearchField extends StatelessWidget {
  const LibrarySearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.label = 'Search',
  });

  final TextEditingController controller;
  final String hint;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final scale = MediaQuery.textScalerOf(context);
    return HybridPlanInputs(
      child: Semantics(
        label: label,
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          style: AppTypography.caption.copyWith(color: p.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.caption.copyWith(
              color: p.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            contentPadding: const EdgeInsets.fromLTRB(12, 14, 0, 14),
            suffixIcon: controller.text.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(left: 8, right: 12),
                    child: ExcludeSemantics(
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: HybridIcon(
                          HybridIcons.search,
                          size: scale.scale(20),
                          strokeWidth: 1.7,
                          color: p.textSecondary,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: HybridIcon(
                      HybridIcons.close,
                      size: scale.scale(20),
                      strokeWidth: 1.7,
                      color: p.textSecondary,
                    ),
                  ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// The page's main action (`.primary-button` with its icon): full width,
/// 48 tall.
class LibraryPrimaryAction extends StatelessWidget {
  const LibraryPrimaryAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final HybridIconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(HybridTokens.minTarget),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.sm,
      children: [
        HybridIcon(
          icon,
          size: MediaQuery.textScalerOf(context).scale(18),
          strokeWidth: 2,
        ),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );
}

/// Delete, last on a record (`.library-destructive`): outlined, the error
/// colour, the bin.
class LibraryDeleteAction extends StatelessWidget {
  const LibraryDeleteAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final error =
        (Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light)
            .errorText;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(HybridTokens.minTarget),
        foregroundColor: error,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.sm,
        children: [
          HybridIcon(
            HybridIcons.trash,
            size: MediaQuery.textScalerOf(context).scale(20),
            strokeWidth: 1.7,
            color: error,
          ),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}

/// A list row (`.library-row`): the 16/500 title, the 14 px caption and an
/// optional 13 px note; padding 12 0 and a rule below.
class LibraryRow extends StatelessWidget {
  const LibraryRow({
    super.key,
    required this.title,
    required this.caption,
    required this.onTap,
    this.note,
    this.titleKey,
  });

  final String title;
  final String caption;
  final String? note;
  final VoidCallback onTap;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    title,
                    key: titleKey,
                    style: AppTypography.rowTitle.copyWith(
                      color: p.textPrimary,
                    ),
                  ),
                  Text(
                    caption,
                    style: AppTypography.body.copyWith(
                      height: 1.6,
                      color: p.textSecondary,
                    ),
                  ),
                  if (note case final n?)
                    Text(
                      n,
                      style: AppTypography.caption.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A record's header (library.js `library-detail`): its caption and the
/// snapshot note, then the main action.
class LibraryRecordHeader extends StatelessWidget {
  const LibraryRecordHeader({
    super.key,
    required this.caption,
    required this.action,
    this.title,
  });

  /// A visible heading (a target's "Your target"); rigs and sites show
  /// their name in the app bar only.
  final String? title;
  final String caption;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title case final t?)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Semantics(
              header: true,
              child: Text(
                t,
                style: AppTypography.sectionSubject.copyWith(
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
            ),
          ),
        Text(
          caption,
          style: AppTypography.body.copyWith(
            height: 1.5,
            color: p.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          librarySnapshotNote,
          style: AppTypography.body.copyWith(
            height: 1.6,
            color: p.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.itemGap),
        action,
      ],
    );
  }
}

/// A form field (`.block-input`): the 15 px secondary label, 4 above the
/// 48 px input, then its hint.
class LibraryField extends StatelessWidget {
  const LibraryField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.top = AppSpacing.itemGap,
  });

  final String label;
  final Widget child;
  final String? hint;
  final double top;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTypography.value.copyWith(
              height: 1.5,
              color: p.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
          if (hint case final h? when h.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                h,
                style: AppTypography.caption.copyWith(
                  height: 1.55,
                  color: p.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The input text of a Library form (`.library-form input`): 15 px.
TextStyle libraryInputStyle(BuildContext context) => AppTypography.value
    .copyWith(height: 1.5, color: AppPalette.of(context).textPrimary);

/// A Library editor's actions (`.library-form-actions`): Cancel and the
/// save, side by side, 8 0 4 at the bottom of the page.
class LibrarySaveBar extends StatelessWidget {
  const LibrarySaveBar({
    super.key,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
    this.saveKey,
    this.cancelKey,
  });

  final String saveLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final Key? saveKey;
  final Key? cancelKey;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.sm,
          AppSpacing.gutter,
          AppSpacing.xs,
        ),
        child: Row(
          spacing: AppSpacing.itemGap,
          children: [
            Expanded(
              child: OutlinedButton(
                key: cancelKey,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(HybridTokens.minTarget),
                ),
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ),
            Expanded(
              child: FilledButton(
                key: saveKey,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(HybridTokens.minTarget),
                ),
                onPressed: onSave,
                child: Text(saveLabel, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The camera-type choices (library.css `.library-class-options`): two
/// columns 8 apart, the last odd one across both; each an outlined choice
/// with its 24 px radio 12 before the 14 px label (600 and the selection
/// wash when chosen). One column at large text.
class LibraryChoiceGrid<T> extends StatelessWidget {
  const LibraryChoiceGrid({
    super.key,
    required this.legend,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
  });

  final String legend;

  /// Each option: its value, its label and its key's suffix.
  final List<(T, String, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final h = Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    final columns = MediaQuery.textScalerOf(context).scale(1) >= 1.5 ? 1 : 2;
    Widget choice((T, String, String) o) {
      final selected = o.$1 == value;
      return MergeSemantics(
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          checked: selected,
          child: Material(
            key: Key('$keyPrefix.${o.$3}'),
            color: selected ? h.selection : HybridTokens.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: p.controlBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => onChanged(o.$1),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: HybridTokens.minTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      HybridRadio(checked: selected, size: 24),
                      const SizedBox(width: AppSpacing.itemGap),
                      Expanded(
                        child: Text(
                          o.$2,
                          style: AppTypography.body.copyWith(
                            height: 1.5,
                            fontWeight: selected ? FontWeight.w600 : null,
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final rows = <List<(T, String, String)>>[
      for (var i = 0; i < options.length; i += columns)
        options.sublist(i, (i + columns).clamp(0, options.length)),
    ];
    return Semantics(
      container: true,
      label: legend,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          for (final row in rows)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.sm,
                children: [for (final o in row) Expanded(child: choice(o))],
              ),
            ),
        ],
      ),
    );
  }
}
