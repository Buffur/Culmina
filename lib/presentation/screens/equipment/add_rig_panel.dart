import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/camera_class.dart';
import '../../shared/rig_input_text.dart';

/// How a new rig starts (F05; S14.2, CA-02): the camera class first, with
/// "Not sure" as an explicit Unknown, then two equally visible choices.
/// From a photo comes first for a phone or camera, Enter by hand first for
/// an astro camera (FITS is not read yet, F10). The panel only reports the
/// choice; the caller opens the editor or the import.
class AddRigPanel extends StatefulWidget {
  const AddRigPanel({super.key, required this.onByHand, this.onFromPhoto});

  final void Function(CameraClass cameraClass) onByHand;

  /// Null where reading capture files is not available.
  final void Function(CameraClass cameraClass)? onFromPhoto;

  /// The order the classes are offered in; "Not sure" last.
  static const classes = [
    CameraClass.phone,
    CameraClass.dslrMirrorless,
    CameraClass.astroColour,
    CameraClass.astroMono,
    CameraClass.unknown,
  ];

  @override
  State<AddRigPanel> createState() => _AddRigPanelState();
}

class _AddRigPanelState extends State<AddRigPanel> {
  CameraClass? _class;

  bool get _astro =>
      _class == CameraClass.astroColour || _class == CameraClass.astroMono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chosen = _class;
    final byHand = FilledButton.tonalIcon(
      key: const Key('addRig.byHand'),
      onPressed: chosen == null ? null : () => widget.onByHand(chosen),
      icon: const Icon(Icons.edit_outlined),
      label: const Text(RigInputText.byHand),
    );
    final photo = widget.onFromPhoto;
    final fromPhoto = photo == null
        ? null
        : FilledButton.tonalIcon(
            key: const Key('addRig.fromPhoto'),
            onPressed: chosen == null ? null : () => photo(chosen),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text(RigInputText.fromPhoto),
          );
    final choices = [
      if (fromPhoto != null && !_astro) fromPhoto,
      byHand,
      if (fromPhoto != null && _astro) fromPhoto,
    ];
    return Column(
      key: const Key('addRig.panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(RigInputText.classQuestion, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final c in AddRigPanel.classes)
              ChoiceChip(
                key: Key('addRig.class.${c.name}'),
                label: Text(RigInputText.classLabel(c)),
                selected: _class == c,
                onSelected: (_) => setState(() => _class = c),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          switch (chosen) {
            null => RigInputText.chooseClassFirst,
            CameraClass.unknown => RigInputText.notSure,
            final CameraClass c => RigInputText.readableFormats(c),
          },
          key: const Key('addRig.note'),
          style: theme.textTheme.bodySmall,
        ),
        if (chosen == CameraClass.unknown && fromPhoto != null)
          Text(
            RigInputText.readableFormats(CameraClass.unknown),
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: AppSpacing.md),
        for (final (i, button) in choices.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          button,
        ],
      ],
    );
  }
}
