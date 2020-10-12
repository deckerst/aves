import 'dart:async';
import 'dart:math';

import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';

class EntryCache {
  static Future<void> evict(String uri, String mimeType, int oldRotationDegrees) async {
    // evict fullscreen image
    await UriImage(
      uri: uri,
      mimeType: mimeType,
      rotationDegrees: oldRotationDegrees,
    ).evict();

    // evict low quality thumbnail (without specified extents)
    await ThumbnailProvider(
      uri: uri,
      mimeType: mimeType,
      rotationDegrees: oldRotationDegrees,
    ).evict();

    // evict higher quality thumbnails (with powers of 2 from 32 to 1024 as specified extents)
    final extents = List.generate(6, (index) => pow(2, index + 5).toDouble());
    await Future.forEach<double>(
        extents,
        (extent) => ThumbnailProvider(
              uri: uri,
              mimeType: mimeType,
              rotationDegrees: oldRotationDegrees,
              extent: extent,
            ).evict());
  }
}
