import '../metadata/capture_metadata.dart';
import '../metadata/metadata_format.dart';
import '../models/capture_block.dart';
import '../models/capture_evidence.dart';
import '../models/equipment_profile.dart';

/// What one frame's size rests on (ADR-021 C8), in its order of use.
enum StorageBasis {
  /// The block's own compatible measured file (C6).
  blockFile,

  /// The rig's compatible measured file (C7).
  rigFile,

  /// The rig's RAW size without a recorded file: an older rig, or a size
  /// the user entered (association unrecorded).
  rigSize,

  /// The pixel payload of an evidenced uncompressed format (C10).
  theoretical,

  /// None of these: the plan says why and offers a file or a size.
  unknown,
}

/// Why a measured file does not fit a block (C8, C9): shown, never
/// rescaled.
enum StorageConflict { binning, dimensions, format }

/// Why no size could be given.
enum StorageGap {
  /// No rig chosen: no pixel count.
  noRig,

  /// A compressed or lossy format, whose size varies with content (C10).
  compressed,

  /// Nothing measured or declared.
  noEvidence,
}

/// One frame's size for a block, and what it rests on (C8–C12). Pure
/// value; [bytes] per frame (10⁶ bytes = 1 MB).
class FrameStorage {
  const FrameStorage({
    required this.basis,
    this.bytes,
    this.label,
    this.read = true,
    this.pixelDataOnly = false,
    this.headerCounted = true,
    this.gap,
    this.skipped = const {},
    this.width,
    this.height,
    this.bitsPerSample,
  });

  final StorageBasis basis;

  /// Bytes per frame; null when [basis] is [StorageBasis.unknown].
  final double? bytes;

  /// The measured file's basename, or null.
  final String? label;

  /// False for a recognized file that was not read (C12, D3 A): its size
  /// varies with content and its mode is not known.
  final bool read;

  /// A theoretical DNG size: pixel data only; the file adds a small,
  /// writer-specific header (C10).
  final bool pixelDataOnly;

  /// False for a theoretical FITS size whose header count was not read.
  final bool headerCounted;

  final StorageGap? gap;

  /// Measured files that were not used, and why (C8: shown).
  final Map<StorageBasis, Set<StorageConflict>> skipped;

  /// The theoretical output geometry (C11), when [basis] is theoretical.
  final int? width;
  final int? height;
  final int? bitsPerSample;

  double? get megabytes => bytes == null ? null : bytes! / 1e6;

  bool get known => bytes != null;

  @override
  bool operator ==(Object other) =>
      other is FrameStorage &&
      basis == other.basis &&
      bytes == other.bytes &&
      label == other.label &&
      read == other.read &&
      pixelDataOnly == other.pixelDataOnly &&
      headerCounted == other.headerCounted &&
      gap == other.gap;

  @override
  int get hashCode =>
      Object.hash(basis, bytes, label, read, pixelDataOnly, headerCounted, gap);
}

/// ADR-021 C8–C12 (D3–D5 = A, PD-06): the size of one frame of a block,
/// from the first compatible evidence. Camera class never selects a branch;
/// a measured file is never rescaled by binning; compressed formats have no
/// theoretical value.
abstract final class StorageEstimate {
  /// The FITS record size (C10).
  static const fitsRecordBytes = 2880;

  /// [of] for every block of a plan, in order.
  static List<FrameStorage> ofPlan(
    List<CaptureBlock> blocks,
    EquipmentProfile? rig,
  ) => [for (final b in blocks) of(b, rig)];

  static FrameStorage of(CaptureBlock block, EquipmentProfile? rig) {
    final skipped = <StorageBasis, Set<StorageConflict>>{};
    // (1) The block's own measured file.
    if (block.fileEvidence case final file?) {
      final c = conflicts(file, block, rig);
      if (c.isEmpty) return _measured(StorageBasis.blockFile, file);
      skipped[StorageBasis.blockFile] = c;
    }
    // (2) The rig's measured file, or its size without one.
    if (rig?.averageRawFileSizeMB case final mb? when rig != null) {
      final file = rig.rawFileSizeEvidence;
      if (file == null) {
        return FrameStorage(
          basis: StorageBasis.rigSize,
          bytes: mb * 1e6,
          skipped: skipped,
        );
      }
      final c = conflicts(file, block, rig);
      if (c.isEmpty) {
        // The rig's size came from this file: its exact length is used.
        return FrameStorage(
          basis: StorageBasis.rigFile,
          bytes: file.bytes.toDouble(),
          label: file.label,
          read: file.read,
          skipped: skipped,
        );
      }
      skipped[StorageBasis.rigFile] = c;
    }
    if (rig == null) {
      return FrameStorage(
        basis: StorageBasis.unknown,
        gap: StorageGap.noRig,
        skipped: skipped,
      );
    }
    // (3) The theoretical payload of an evidenced uncompressed format.
    if (theoretical(block, rig) case final t?) {
      return FrameStorage(
        basis: StorageBasis.theoretical,
        bytes: t.bytes.toDouble(),
        pixelDataOnly: t.pixelDataOnly,
        headerCounted: t.headerCounted,
        width: t.width,
        height: t.height,
        bitsPerSample: t.bitsPerSample,
        skipped: skipped,
      );
    }
    // (4) Unknown, with the reason.
    return FrameStorage(
      basis: StorageBasis.unknown,
      gap: _compressed(block, rig)
          ? StorageGap.compressed
          : StorageGap.noEvidence,
      skipped: skipped,
    );
  }

  static FrameStorage _measured(StorageBasis basis, FileEvidence file) =>
      FrameStorage(
        basis: basis,
        bytes: file.bytes.toDouble(),
        label: file.label,
        read: file.read,
      );

  /// Why [file] does not fit [block] (C8, C9); empty when it fits. What is
  /// unknown on either side is not a conflict.
  static Set<StorageConflict> conflicts(
    FileEvidence file,
    CaptureBlock block,
    EquipmentProfile? rig,
  ) {
    final out = <StorageConflict>{};
    if (file.binning case final b? when b != block.binning) {
      out.add(StorageConflict.binning);
    }
    if ((file.width, file.height, rig) case (final w?, final h?, final r?)) {
      final ow = r.resolutionWidthPx ~/ block.binning;
      final oh = r.resolutionHeightPx ~/ block.binning;
      final same = (w == ow && h == oh) || (w == oh && h == ow);
      if (!same) out.add(StorageConflict.dimensions);
    }
    if (rig?.captureFormat case final f? when !_formatFits(f, file)) {
      out.add(StorageConflict.format);
    }
    return out;
  }

  static bool _formatFits(CaptureFormat f, FileEvidence file) => switch (f) {
    CaptureFormat.dngUncompressed16 =>
      file.format == 'dng' &&
          (file.compression == null ||
              file.compression == FileCompression.none),
    CaptureFormat.fits16 || CaptureFormat.fits32float =>
      file.format == 'fits' || file.format == 'recognized:fits',
    CaptureFormat.compressedRaw =>
      file.format.startsWith('recognized:') || file.format == 'dng',
    CaptureFormat.jpegHeic => file.format == 'jpeg' || file.format == 'heic',
  };

  /// C10's theoretical payload, or null when no uncompressed format is
  /// evidenced: the rig's declared or file-sourced format, else a read,
  /// uncompressed DNG among the block's and the rig's files.
  static ({
    int bytes,
    int width,
    int height,
    int bitsPerSample,
    bool pixelDataOnly,
    bool headerCounted,
  })?
  theoretical(CaptureBlock block, EquipmentProfile rig) {
    final w = rig.resolutionWidthPx ~/ block.binning;
    final h = rig.resolutionHeightPx ~/ block.binning;
    if (w <= 0 || h <= 0) return null;
    final declared = rig.captureFormatSource == 'declared';
    int fits(int bits, {required bool header}) {
      final data = w * h * bits ~/ 8;
      final records = (data + fitsRecordBytes - 1) ~/ fitsRecordBytes;
      return records * fitsRecordBytes + (header ? fitsRecordBytes : 0);
    }

    switch (rig.captureFormat) {
      case CaptureFormat.dngUncompressed16:
        return (
          bytes: w * h * 2,
          width: w,
          height: h,
          bitsPerSample: 16,
          pixelDataOnly: true,
          headerCounted: false,
        );
      case CaptureFormat.fits16:
        return (
          bytes: fits(16, header: declared),
          width: w,
          height: h,
          bitsPerSample: 16,
          pixelDataOnly: false,
          headerCounted: declared,
        );
      case CaptureFormat.fits32float:
        return (
          bytes: fits(32, header: declared),
          width: w,
          height: h,
          bitsPerSample: 32,
          pixelDataOnly: false,
          headerCounted: declared,
        );
      case CaptureFormat.compressedRaw || CaptureFormat.jpegHeic:
        return null;
      case null:
        break;
    }
    for (final file in [block.fileEvidence, rig.rawFileSizeEvidence]) {
      if (file case FileEvidence(
        format: 'dng',
        read: true,
        compression: FileCompression.none,
        bitsPerSample: final bits?,
      )) {
        return (
          bytes: w * h * bits ~/ 8,
          width: w,
          height: h,
          bitsPerSample: bits,
          pixelDataOnly: true,
          headerCounted: false,
        );
      }
    }
    return null;
  }

  /// Whether what is known says the format is compressed (no theoretical
  /// value can exist, C10).
  static bool _compressed(CaptureBlock block, EquipmentProfile rig) {
    if (rig.captureFormat
        case CaptureFormat.compressedRaw || CaptureFormat.jpegHeic) {
      return true;
    }
    for (final file in [block.fileEvidence, rig.rawFileSizeEvidence]) {
      if (file == null) continue;
      if (!file.read) return true;
      if (file.compression
          case FileCompression.lossless ||
              FileCompression.lossy ||
              FileCompression.unknown) {
        return true;
      }
    }
    return false;
  }

  /// One picked file as storage evidence (C6, C12): a read DNG, JPEG or
  /// HEIC with what it says about its pixels; a recognized file without a
  /// reader by its length only (`read: false`). Null for an unrecognized
  /// or unreadable file, or one without a length.
  static FileEvidence? evidenceOf(
    String? name,
    MetadataReading reading,
    int? lengthBytes,
  ) {
    if (lengthBytes == null || lengthBytes <= 0) return null;
    final label = (name == null || name.trim().isEmpty) ? 'file' : name;
    switch (reading) {
      case MetadataRead(:final format, :final metadata):
        final format0 = switch (format) {
          MetadataFormat.dng => 'dng',
          MetadataFormat.jpeg => 'jpeg',
          MetadataFormat.heif => 'heic',
          MetadataFormat.fits => 'fits',
          _ => null,
        };
        if (format0 == null) return null;
        if (format0 == 'fits') return _fits(label, metadata, lengthBytes);
        final dims = metadata.imageDimensions.valueOrNull;
        final compression = format0 == 'dng'
            ? switch (metadata.compression.valueOrNull?.kind) {
                PixelCompressionKind.none => FileCompression.none,
                PixelCompressionKind.lossless => FileCompression.lossless,
                PixelCompressionKind.lossy => FileCompression.lossy,
                PixelCompressionKind.unknown => FileCompression.unknown,
                null => null,
              }
            : FileCompression.lossy;
        return FileEvidence(
          bytes: lengthBytes,
          format: format0,
          read: true,
          width: dims?.widthPx,
          height: dims?.heightPx,
          bitsPerSample: format0 == 'dng'
              ? metadata.bitsPerSample.valueOrNull
              : null,
          compression: compression,
          label: label,
        );
      case MetadataUnsupported(:final format)
          when format != MetadataFormat.unknown:
        return FileEvidence(
          bytes: lengthBytes,
          format: 'recognized:${_extension(format)}',
          read: false,
          label: label,
        );
      case MetadataUnsupported() || MetadataUnreadable():
        return null;
    }
  }

  /// A read FITS file (F10, C6/C11): its written (output) geometry, sample
  /// size and binning; a supported image layout is uncompressed.
  static FileEvidence _fits(String label, CaptureMetadata m, int bytes) {
    final layout = m.sampleLayout.valueOrNull;
    final dims = m.imageDimensions.valueOrNull;
    final bin = m.binning.valueOrNull;
    return FileEvidence(
      bytes: bytes,
      format: 'fits',
      read: true,
      width: dims?.widthPx,
      height: dims?.heightPx,
      bitsPerSample: m.bitsPerSample.valueOrNull,
      compression: layout == null
          ? null
          : layout.isSupported
          ? FileCompression.none
          : FileCompression.unknown,
      binning: bin != null && bin.isSymmetric ? bin.x : null,
      label: label,
    );
  }

  static String _extension(MetadataFormat f) => switch (f) {
    MetadataFormat.heif || MetadataFormat.heifSequence => 'heif',
    _ => f.name,
  };
}
