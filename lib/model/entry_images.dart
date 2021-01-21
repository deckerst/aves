import 'dart:math';
import 'dart:ui';

import 'package:aves/image_providers/region_provider.dart';
import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

extension ExtraAvesEntry on AvesEntry {
  ThumbnailProvider getThumbnail({double extent = 0}) => ThumbnailProvider(_getThumbnailProviderKey(extent));

  ThumbnailProviderKey _getThumbnailProviderKey(double extent) {
    // we standardize the thumbnail loading dimension by taking the nearest larger power of 2
    // so that there are less variants of the thumbnails to load and cache
    // it increases the chance of cache hit when loading similarly sized columns (e.g. on orientation change)
    final requestExtent = extent == 0 ? .0 : pow(2, (log(extent) / log(2)).ceil()).toDouble();

    return ThumbnailProviderKey(
      uri: uri,
      mimeType: mimeType,
      page: page,
      rotationDegrees: rotationDegrees,
      isFlipped: isFlipped,
      dateModifiedSecs: dateModifiedSecs ?? -1,
      extent: requestExtent,
    );
  }

  RegionProvider getRegion({@required int sampleSize, Rectangle<int> region}) => RegionProvider(getRegionProviderKey(sampleSize, region));

  RegionProviderKey getRegionProviderKey(int sampleSize, Rectangle<int> region) {
    return RegionProviderKey(
      uri: uri,
      mimeType: mimeType,
      page: page,
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
        page: page,
        rotationDegrees: rotationDegrees,
        isFlipped: isFlipped,
        expectedContentLength: sizeBytes,
      );

  bool _isReady(Object providerKey) => imageCache.statusForKey(providerKey).keepAlive;

  ImageProvider getBestThumbnail(double extent) {
    final sizedThumbnailKey = _getThumbnailProviderKey(extent);
    if (_isReady(sizedThumbnailKey)) return ThumbnailProvider(sizedThumbnailKey);

    return getThumbnail();
  }
}
