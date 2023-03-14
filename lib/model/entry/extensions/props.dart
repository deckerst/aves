import 'dart:ui';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/utils/android_file_utils.dart';

extension ExtraAvesEntryProps on AvesEntry {
  String get mimeTypeAnySubtype => mimeType.replaceAll(RegExp('/.*'), '/*');

  bool get isSvg => mimeType == MimeTypes.svg;

  // guess whether this is a photo, according to file type (used as a hint to e.g. display megapixels)
  bool get isPhoto => [MimeTypes.heic, MimeTypes.heif, MimeTypes.jpeg, MimeTypes.tiff].contains(mimeType) || isRaw;

  // Android's `BitmapRegionDecoder` documentation states that "only the JPEG and PNG formats are supported"
  // but in practice (tested on API 25, 27, 29), it successfully decodes the formats listed below,
  // and it actually fails to decode GIF, DNG and animated WEBP. Other formats were not tested.
  bool get _supportedByBitmapRegionDecoder =>
      [
        MimeTypes.heic,
        MimeTypes.heif,
        MimeTypes.jpeg,
        MimeTypes.png,
        MimeTypes.webp,
        MimeTypes.arw,
        MimeTypes.cr2,
        MimeTypes.nef,
        MimeTypes.nrw,
        MimeTypes.orf,
        MimeTypes.pef,
        MimeTypes.raf,
        MimeTypes.rw2,
        MimeTypes.srw,
      ].contains(mimeType) &&
      !isAnimated;

  bool get supportTiling => _supportedByBitmapRegionDecoder || mimeType == MimeTypes.tiff;

  bool get useTiles => supportTiling && (width > 4096 || height > 4096);

  bool get isRaw => MimeTypes.rawImages.contains(mimeType);

  bool get isImage => MimeTypes.isImage(mimeType);

  bool get isVideo => MimeTypes.isVideo(mimeType);

  bool get isAnimated => catalogMetadata?.isAnimated ?? false;

  bool get isGeotiff => catalogMetadata?.isGeotiff ?? false;

  bool get is360 => catalogMetadata?.is360 ?? false;

  bool get isMediaStoreContent => uri.startsWith('content://media/');

  bool get isMediaStoreMediaContent => isMediaStoreContent && {'/external/images/', '/external/video/'}.any(uri.contains);

  bool get isVaultContent => path?.startsWith(androidFileUtils.vaultRoot) ?? false;

  bool get canEdit => !settings.isReadOnly && path != null && !trashed && (isMediaStoreContent || isVaultContent);

  bool get canEditDate => canEdit && (canEditExif || canEditXmp);

  bool get canEditLocation => canEdit && (canEditExif || mimeType == MimeTypes.mp4);

  bool get canEditTitleDescription => canEdit && canEditXmp;

  bool get canEditRating => canEdit && canEditXmp;

  bool get canEditTags => canEdit && canEditXmp;

  bool get canRotate => canEdit && (canEditExif || mimeType == MimeTypes.mp4);

  bool get canFlip => canEdit && canEditExif;

  bool get canEditExif => MimeTypes.canEditExif(mimeType);

  bool get canEditIptc => MimeTypes.canEditIptc(mimeType);

  bool get canEditXmp => MimeTypes.canEditXmp(mimeType);

  bool get canRemoveMetadata => MimeTypes.canRemoveMetadata(mimeType);

  static const ratioSeparator = '\u2236';
  static const resolutionSeparator = ' \u00D7 ';

  bool get isSized => width > 0 && height > 0;

  String get resolutionText {
    final ws = width;
    final hs = height;
    return isRotated ? '$hs$resolutionSeparator$ws' : '$ws$resolutionSeparator$hs';
  }

  String get aspectRatioText {
    if (width > 0 && height > 0) {
      final gcd = width.gcd(height);
      final w = width ~/ gcd;
      final h = height ~/ gcd;
      return isRotated ? '$h$ratioSeparator$w' : '$w$ratioSeparator$h';
    } else {
      return '?$ratioSeparator?';
    }
  }

  Size videoDisplaySize(double sar) {
    final size = displaySize;
    if (sar != 1) {
      final dar = displayAspectRatio * sar;
      final w = size.width;
      final h = size.height;
      if (w >= h) return Size(w, w / dar);
      if (h > w) return Size(h * dar, h);
    }
    return size;
  }

  int get megaPixels => (width * height / 1000000).round();
}
