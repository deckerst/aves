import 'dart:async';

import 'package:aves/image_providers/full_image_provider.dart';
import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:flutter/foundation.dart';

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
    int? dateModifiedMillis,
    int rotationDegrees,
    bool isFlipped,
    bool isAnimated,
  ) async {
    debugPrint('Evict cached images for uri=$uri, mimeType=$mimeType, dateModifiedMillis=$dateModifiedMillis, rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, isAnimated=$isAnimated');

    // TODO TLAD provide pageId parameter for multi page items, if someday image editing features are added for them
    int? pageId;

    // evict fullscreen image
    await FullImage(
      uri: uri,
      mimeType: mimeType,
      pageId: pageId,
      rotationDegrees: rotationDegrees,
      isFlipped: isFlipped,
      isAnimated: isAnimated,
    ).evict();

    // evict low quality thumbnail (without specified extents)
    await ThumbnailProvider(ThumbnailProviderKey(
      uri: uri,
      mimeType: mimeType,
      pageId: pageId,
      dateModifiedMillis: dateModifiedMillis ?? 0,
      rotationDegrees: rotationDegrees,
      isFlipped: isFlipped,
    )).evict();

    await Future.forEach<double>(
        thumbnailRequestExtents,
        (extent) => ThumbnailProvider(ThumbnailProviderKey(
              uri: uri,
              mimeType: mimeType,
              pageId: pageId,
              dateModifiedMillis: dateModifiedMillis ?? 0,
              rotationDegrees: rotationDegrees,
              isFlipped: isFlipped,
              extent: extent,
            )).evict());
  }
}
