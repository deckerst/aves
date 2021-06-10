import 'dart:async';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_image_provider.dart';

class EntryCache {
  // ordered descending
  static final thumbnailRequestExtents = <double>[];

  static void markThumbnailExtent(double extent) {
    if (!thumbnailRequestExtents.contains(extent)) {
      thumbnailRequestExtents
        ..add(extent)
        ..sort((a, b) => b.compareTo(a));
    }
  }

  static Future<void> evict(
    String uri,
    String mimeType,
    int? dateModifiedSecs,
    int oldRotationDegrees,
    bool oldIsFlipped,
  ) async {
    // TODO TLAD provide pageId parameter for multi page items, if someday image editing features are added for them
    int? pageId;

    // evict fullscreen image
    await UriImage(
      uri: uri,
      mimeType: mimeType,
      pageId: pageId,
      rotationDegrees: oldRotationDegrees,
      isFlipped: oldIsFlipped,
    ).evict();

    // evict low quality thumbnail (without specified extents)
    await ThumbnailProvider(ThumbnailProviderKey(
      uri: uri,
      mimeType: mimeType,
      pageId: pageId,
      dateModifiedSecs: dateModifiedSecs ?? 0,
      rotationDegrees: oldRotationDegrees,
      isFlipped: oldIsFlipped,
    )).evict();

    await Future.forEach<double>(
        thumbnailRequestExtents,
        (extent) => ThumbnailProvider(ThumbnailProviderKey(
              uri: uri,
              mimeType: mimeType,
              pageId: pageId,
              dateModifiedSecs: dateModifiedSecs ?? 0,
              rotationDegrees: oldRotationDegrees,
              isFlipped: oldIsFlipped,
              extent: extent,
            )).evict());
  }
}
