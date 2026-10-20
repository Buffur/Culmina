import '../../core/utils/quantity_text.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/spec_confidence.dart';
import '../../domain/models/spec_provenance.dart';
import '../../domain/services/storage_estimate.dart';
import 'block_text.dart';

/// What a storage figure rests on, or why there is none (ADR-021 C8–C12,
/// F07): the source and its assumption, always visible next to the figure.
abstract final class StorageText {
  /// One frame's basis in a sentence.
  static String basis(FrameStorage f, {EquipmentProfile? rig}) {
    final size = f.bytes == null ? null : QuantityText.storage(f.bytes!);
    final skipped = _skipped(f);
    final text = switch (f.basis) {
      StorageBasis.planEstimate =>
        'Plan estimate: $size a frame (user entered).',
      StorageBasis.blockFile || StorageBasis.rigFile when !f.read =>
        'From the size of ${f.label}: $size a frame (mode not read; '
            'compressed sizes vary with content).',
      StorageBasis.blockFile ||
      StorageBasis.rigFile => 'Measured from ${f.label}: $size a frame.',
      StorageBasis.rigSize =>
        "The rig's RAW size: $size a frame (which file it came from was "
            'not recorded).'
            '${_estimated(rig) ? " It is itself an estimate, from one file." : ''}',
      StorageBasis.theoretical when f.pixelDataOnly =>
        'Theoretical: ${f.width} × ${f.height} px × ${f.bitsPerSample} bits '
            '= $size of pixel data a frame; the file adds a small header that '
            "depends on the camera's software.",
      StorageBasis.theoretical =>
        'Theoretical FITS: ${f.width} × ${f.height} px × '
            '${f.bitsPerSample} bits in 2,880-byte records'
            '${f.headerCounted ? ' with one header record' : ''} = $size a '
            'frame${f.headerCounted ? '' : '; the header is not counted'}.',
      StorageBasis.unknown => switch (f.gap) {
        StorageGap.noRig =>
          'Unknown: no rig chosen, so the frame size is not known.',
        StorageGap.compressed =>
          'Unknown: this format is compressed, so its size varies with '
              'content. Choose one file to measure it, or enter a size.',
        _ =>
          'Unknown: no file measured and no capture format declared for '
              'this rig. Choose one file, or enter a size or the format in '
              "the rig's editor.",
      },
    };
    return skipped == null ? text : '$text $skipped';
  }

  static bool _estimated(EquipmentProfile? rig) =>
      rig?.provenanceOf(EquipmentSpec.rawFileSize)?.confidence ==
      SpecConfidence.estimated;

  /// "Not used: the rig's file (another binning)." (C8: shown).
  static String? _skipped(FrameStorage f) {
    if (f.skipped.isEmpty) return null;
    final parts = [
      for (final MapEntry(:key, :value) in f.skipped.entries)
        '${key == StorageBasis.blockFile ? "the block's file" : "the rig's file"}'
            ' (${value.map(conflict).join(', ')})',
    ];
    return 'Not used: ${parts.join('; ')}.';
  }

  static String conflict(StorageConflict c) => switch (c) {
    StorageConflict.binning => 'another binning',
    StorageConflict.dimensions => 'another pixel count',
    StorageConflict.format => 'another capture format',
  };

  /// The note under the plan's storage: one basis when every counted block
  /// shares it, else one line per block.
  static String plan(
    List<CaptureBlock> blocks,
    List<FrameStorage> frames,
    List<bool> counted, {
    EquipmentProfile? rig,
  }) {
    final used = [
      for (var i = 0; i < blocks.length; i++)
        if (counted[i]) (blocks[i], frames[i]),
    ];
    if (used.isEmpty) return 'No frames to store.';
    if (used.every((u) => u.$2 == used.first.$2)) {
      return basis(used.first.$2, rig: rig);
    }
    return [
      for (final (b, f) in used)
        '${BlockText.identity(b)}: ${basis(f, rig: rig)}',
    ].join('\n');
  }
}
