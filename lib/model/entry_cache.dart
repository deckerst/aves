import 'dart:async';
import 'dart:math';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_image_provider.dart';

class EntryCache {
  static Future<void> evict(
    String uri,
    String mimeType,
    int dateModifiedSecs,
    int oldRotationDegrees,
    bool oldIsFlipped,
  ) async {
    // TODO TLAD provide page parameter for multipage items, if someday image editing features are added for them

    // evict fullscreen image
    await UriImage(
      uri: uri,
      mimeType: mimeType,
      rotationDegrees: oldRotationDegrees,
      isFlipped: oldIsFlipped,
    ).evict();

    // evict low quality thumbnail (without specified extents)
    await ThumbnailProvider(ThumbnailProviderKey(
      uri: uri,
      mimeType: mimeType,
      dateModifiedSecs: dateModifiedSecs,
      rotationDegrees: oldRotationDegrees,
      isFlipped: oldIsFlipped,
    )).evict();

    // evict higher quality thumbnails (with powers of 2 from 32 to 1024 as specified extents)
    final extents = List.generate(6, (index) => pow(2, index + 5).toDouble());
    await Future.forEach<double>(
        extents,
        (extent) => ThumbnailProvider(ThumbnailProviderKey(
              uri: uri,
              mimeType: mimeType,
              dateModifiedSecs: dateModifiedSecs,
              rotationDegrees: oldRotationDegrees,
              isFlipped: oldIsFlipped,
              extent: extent,
            )).evict());
  }
}
