import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/action_row.dart';
import '../../shared/search_filter_bar.dart';
import '../../shared/catalog_scaffold.dart';

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
    return SearchFilterBar(
      controller: controller,
      labelText: label,
      hintText: hint,
      onChanged: onChanged,
      onClear: controller.text.isEmpty
          ? null
          : () {
              controller.clear();
              onChanged('');
            },
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
  Widget build(BuildContext context) => TextButton(
    style: TextButton.styleFrom(
      minimumSize: const Size.fromHeight(HybridTokens.minTarget),
    ),
    onPressed: onPressed,
    child: Text(label, textAlign: TextAlign.center),
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
    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(HybridTokens.minTarget),
        foregroundColor: error,
        backgroundColor:
            (Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light)
                .errorWash,
      ),
      onPressed: onPressed,
      child: Text(label),
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
    this.divider = true,
  });

  final String title;
  final String caption;
  final String? note;
  final VoidCallback onTap;
  final Key? titleKey;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      button: true,
      label: [title, caption, ?note].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        excludeFromSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActionRow(
                title: title,
                titleKey: titleKey,
                description: caption,
                trailing: HybridIcon(
                  HybridIcons.rowChevron,
                  size: 16,
                  color: p.textSecondary,
                ),
              ),
              if (note case final n?)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    n,
                    style: AppTextTheme.of(context).caption
                        .copyWith(color: p.textSecondary),
                  ),
                ),
            ],
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
    this.snapshotAsCaption = false,
  });

  /// A visible heading (a target's "Your target"); rigs and sites show
  /// their name in the app bar only.
  final String? title;
  final String caption;
  final Widget action;
  final bool snapshotAsCaption;

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
                style: AppTextTheme.of(context).sectionHeading.copyWith(
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
            ),
          ),
        Text(
          caption,
          style: AppTextTheme.of(context).body.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          librarySnapshotNote,
          style:
              (snapshotAsCaption
                      ? AppTextTheme.of(context).caption
                      : AppTextTheme.of(context).body)
                  .copyWith(color: p.textSecondary),
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
            style: AppTextTheme.of(context)
                .resolve(
                  AppTextTheme.of(context).value,
                  AppTextGeometry.standard,
                )
                .copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
          if (hint case final h? when h.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                h,
                style: AppTextTheme.of(context).caption
                    .copyWith(color: p.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

/// The input text of a Library form (`.library-form input`): 15 px.
TextStyle libraryInputStyle(BuildContext context) =>
    AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).value, AppTextGeometry.standard)
        .copyWith(color: AppPalette.of(context).textPrimary);

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
    child: StickyBottomAction(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.itemGap,
          children: [
            Expanded(
              child: OutlinedButton(
                key: cancelKey,
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ),
            Expanded(
              child: FilledButton(
                key: saveKey,
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
    return Semantics(
      container: true,
      label: legend,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in options)
            ActionRow(
              key: Key('$keyPrefix.${option.$3}'),
              title: option.$2,
              variant: ActionRowVariant.radio,
              selected: option.$1 == value,
              onTap: () => onChanged(option.$1),
            ),
        ],
      ),
    );
  }
}
