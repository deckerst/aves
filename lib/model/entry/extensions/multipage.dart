import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';

extension ExtraAvesEntryMultipage on AvesEntry {
  static final _burstFilenamePattern = RegExp(r'^(\d{8}_\d{6})_(\d+)$');

  bool get isMultiPage => (catalogMetadata?.isMultiPage ?? false) || isBurst;

  bool get isBurst => burstEntries?.isNotEmpty == true;

  // for backward compatibility
  bool get _isMotionPhotoLegacy => isMultiPage && !isBurst && mimeType == MimeTypes.jpeg;

  bool get isMotionPhoto => (catalogMetadata?.isMotionPhoto ?? false) || _isMotionPhotoLegacy;

  String? get burstKey {
    if (filenameWithoutExtension != null) {
      final match = _burstFilenamePattern.firstMatch(filenameWithoutExtension!);
      if (match != null) {
        return '$directory/${match.group(1)}';
      }
    }
    return null;
  }

  Future<MultiPageInfo?> getMultiPageInfo() async {
    if (isBurst) {
      return MultiPageInfo(
        mainEntry: this,
        pages: burstEntries!
            .mapIndexed((index, entry) => SinglePageInfo(
                  index: index,
                  pageId: entry.id,
                  isDefault: index == 0,
                  uri: entry.uri,
                  mimeType: entry.mimeType,
                  width: entry.width,
                  height: entry.height,
                  rotationDegrees: entry.rotationDegrees,
                  durationMillis: entry.durationMillis,
                ))
            .toList(),
      );
    } else {
      return await metadataFetchService.getMultiPageInfo(this);
    }
  }
}
