import 'dart:io';
import 'dart:ui';

import 'package:aves/model/app/support.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/trash.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/ref/unicode.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:intl/intl.dart';

extension ExtraAvesEntryProps on AvesEntry {
  bool get isValid => !isMissingAtPath && sizeBytes != 0 && width > 0 && height > 0;

  // type

  String get mimeTypeAnySubtype => mimeType.replaceAll(RegExp('/.*'), '/*');

  bool get canHaveAlpha => MimeTypes.canHaveAlpha(mimeType);

  bool get isSvg => mimeType == MimeTypes.svg;

  bool get isRaw => MimeTypes.isRaw(mimeType);

  bool get isImage => MimeTypes.isImage(mimeType);

  bool get isVideo => MimeTypes.isVideo(mimeType) || (mimeType == MimeTypes.avif && isAnimated);

  bool get isPureVideo => isVideo && !isAnimated;

  // size

  bool get useTiles => !isAnimated;

  bool get isSized => width > 0 && height > 0;

  Size videoDisplaySize(double? sar) {
    final size = displaySize;
    if (sar != null && sar != 1) {
      final dar = displayAspectRatio * sar;
      final w = size.width;
      final h = size.height;
      if (w >= h) return Size(w, w / dar);
      if (h > w) return Size(h * dar, h);
    }
    return size;
  }

  // text

  String getResolutionText(String locale) {
    final dimensionFormatter = NumberFormat('0', locale);
    final ws = dimensionFormatter.format(width);
    final hs = dimensionFormatter.format(height);
    return isRotated ? '$hs${AText.resolutionSeparator}$ws' : '$ws${AText.resolutionSeparator}$hs';
  }

  String get aspectRatioText {
    const separator = UniChars.ratio;
    if (width > 0 && height > 0) {
      final gcd = width.gcd(height);
      final w = width ~/ gcd;
      final h = height ~/ gcd;
      return isRotated ? '$h$separator$w' : '$w$separator$h';
    } else {
      return '?$separator?';
    }
  }

  // catalog

  bool get isGeotiff => catalogMetadata?.isGeotiff ?? false;

  bool get is360 => catalogMetadata?.is360 ?? false;

  // trash

  bool get isExpiredTrash {
    final dateMillis = trashDetails?.dateMillis;
    if (dateMillis == null) return false;
    return DateTime.fromMillisecondsSinceEpoch(dateMillis).add(TrashMixin.binKeepDuration).isBefore(DateTime.now());
  }

  int? get trashDaysLeft {
    final dateMillis = trashDetails?.dateMillis;
    if (dateMillis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(dateMillis).add(TrashMixin.binKeepDuration).difference(DateTime.now()).inHumanDays;
  }

  // storage

  String? get storageDirectory => trashed ? pContext.dirname(trashDetails!.path) : directory;

  bool get isMissingAtPath {
    final _storagePath = trashed ? trashDetails?.path : path;
    return _storagePath != null && !File(_storagePath).existsSync();
  }

  // providers

  bool get _isVaultContent => path?.startsWith(androidFileUtils.vaultRoot) ?? false;

  bool get _isMediaStoreContent => uri.startsWith(AndroidFileUtils.mediaStoreUriRoot);

  bool get isMediaStoreMediaContent => _isMediaStoreContent && AndroidFileUtils.mediaUriPathRoots.any(uri.contains);

  // edition

  bool get canEdit => !settings.isReadOnly && path != null && !trashed && (_isMediaStoreContent || _isVaultContent);

  bool get canEditDate => canEdit && (isExifEditionSupported || isXmpEditionSupported);

  bool get canEditLocation => canEdit && (isExifEditionSupported || mimeType == MimeTypes.mp4);

  bool get canEditTitleDescription => canEdit && isXmpEditionSupported;

  bool get canEditRating => canEdit && isXmpEditionSupported;

  bool get canEditTags => canEdit && isXmpEditionSupported;

  bool get canRotate => canEdit && (isExifEditionSupported || mimeType == MimeTypes.mp4);

  bool get canFlip => canEdit && isExifEditionSupported;

  // app support

  bool get isDecodingSupported => AppSupport.canDecode(mimeType);

  bool get isExifEditionSupported => AppSupport.canEditExif(mimeType);

  bool get isIptcEditionSupported => AppSupport.canEditIptc(mimeType);

  bool get isXmpEditionSupported => AppSupport.canEditXmp(mimeType);

  bool get isMetadataRemovalSupported => AppSupport.canRemoveMetadata(mimeType);
}
