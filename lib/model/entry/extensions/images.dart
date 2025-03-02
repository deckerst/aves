import 'dart:math';

import 'package:aves/image_providers/region_provider.dart';
import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/model/entry/cache.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';

extension ExtraAvesEntryImages on AvesEntry {
  bool isThumbnailReady({double extent = 0}) => _isReady(_getThumbnailProviderKey(extent));

  ThumbnailProvider getThumbnail({double extent = 0}) {
    return ThumbnailProvider(_getThumbnailProviderKey(extent));
  }

  ThumbnailProviderKey _getThumbnailProviderKey(double extent) {
    final requestExtent = extent.roundToDouble();
    EntryCache.markThumbnailExtent(requestExtent);
    return ThumbnailProviderKey(
      uri: uri,
      mimeType: mimeType,
      pageId: pageId,
      rotationDegrees: rotationDegrees,
      isFlipped: isFlipped,
      dateModifiedMillis: dateModifiedMillis ?? -1,
      extent: requestExtent,
    );
  }

  RegionProvider getRegion({int sampleSize = 1, double scale = 1, required Rectangle<num> region}) {
    return RegionProvider(RegionProviderKey(
      uri: uri,
      mimeType: mimeType,
      pageId: pageId,
      sizeBytes: sizeBytes,
      rotationDegrees: rotationDegrees,
      isFlipped: isFlipped,
      sampleSize: sampleSize,
      region: Rectangle(
        (region.left * scale).round(),
        (region.top * scale).round(),
        (region.width * scale).round(),
        (region.height * scale).round(),
      ),
      imageSize: Size((width * scale).toDouble(), (height * scale).toDouble()),
    ));
  }

  UriImage get uriImage => UriImage(
        uri: uri,
        mimeType: mimeType,
        pageId: pageId,
        rotationDegrees: rotationDegrees,
        isFlipped: isFlipped,
        isAnimated: isAnimated,
        sizeBytes: sizeBytes,
      );

  bool _isReady(Object providerKey) => imageCache.statusForKey(providerKey).keepAlive;

  List<ThumbnailProvider> get cachedThumbnails => EntryCache.thumbnailRequestExtents.map(_getThumbnailProviderKey).where(_isReady).map(ThumbnailProvider.new).toList();

  ThumbnailProvider get bestCachedThumbnail {
    final sizedThumbnailKey = EntryCache.thumbnailRequestExtents.map(_getThumbnailProviderKey).firstWhereOrNull(_isReady);
    return sizedThumbnailKey != null ? ThumbnailProvider(sizedThumbnailKey) : getThumbnail();
  }

  static int sampleSizeForScale({
    required double magnifierScale,
    required double devicePixelRatio,
  }) {
    var sample = 0;
    if (0 < magnifierScale && magnifierScale < 1) {
      sample = highestPowerOf2(1 / (magnifierScale * devicePixelRatio));
    }
    return max<int>(1, sample);
  }
}
