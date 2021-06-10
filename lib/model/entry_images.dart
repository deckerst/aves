import 'dart:math';
import 'dart:ui';

import 'package:aves/image_providers/region_provider.dart';
import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_cache.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

extension ExtraAvesEntry on AvesEntry {
  ThumbnailProvider getThumbnail({double extent = 0}) {
    return ThumbnailProvider(_getThumbnailProviderKey(extent));
  }

  ThumbnailProviderKey _getThumbnailProviderKey(double extent) {
    EntryCache.markThumbnailExtent(extent);
    return ThumbnailProviderKey(
      uri: uri,
      mimeType: mimeType,
      pageId: pageId,
      rotationDegrees: rotationDegrees,
      isFlipped: isFlipped,
      dateModifiedSecs: dateModifiedSecs ?? -1,
      extent: extent,
    );
  }

  RegionProvider getRegion({required int sampleSize, Rectangle<int>? region}) {
    return RegionProvider(_getRegionProviderKey(sampleSize, region));
  }

  RegionProviderKey _getRegionProviderKey(int sampleSize, Rectangle<int>? region) {
    return RegionProviderKey(
      uri: uri,
      mimeType: mimeType,
      pageId: pageId,
      rotationDegrees: rotationDegrees,
      isFlipped: isFlipped,
      sampleSize: sampleSize,
      region: region ?? Rectangle<int>(0, 0, width, height),
      imageSize: Size(width.toDouble(), height.toDouble()),
    );
  }

  UriImage get uriImage => UriImage(
        uri: uri,
        mimeType: mimeType,
        pageId: pageId,
        rotationDegrees: rotationDegrees,
        isFlipped: isFlipped,
        expectedContentLength: sizeBytes,
      );

  bool _isReady(Object providerKey) => imageCache!.statusForKey(providerKey).keepAlive;

  List<ThumbnailProvider> get cachedThumbnails => EntryCache.thumbnailRequestExtents.map(_getThumbnailProviderKey).where(_isReady).map((key) => ThumbnailProvider(key)).toList();

  ThumbnailProvider get bestCachedThumbnail {
    final sizedThumbnailKey = EntryCache.thumbnailRequestExtents.map(_getThumbnailProviderKey).firstWhereOrNull(_isReady);
    return sizedThumbnailKey != null ? ThumbnailProvider(sizedThumbnailKey) : getThumbnail();
  }
}
