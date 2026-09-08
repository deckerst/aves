import 'package:aves/image_providers/full_image_provider.dart';
import 'package:aves/image_providers/region_provider.dart';
import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';

class EntryCache {
  static final _requestKeysByUri = <String, Set<Object>>{};

  static void registerKey(Object key) {
    Set<Object> ifAbsent() => {};
    switch (key) {
      case ThumbnailProviderKey _:
        _requestKeysByUri.putIfAbsent(key.uri, ifAbsent).add(key);
      case FullImage _:
        _requestKeysByUri.putIfAbsent(key.uri, ifAbsent).add(key);
      case RegionProviderKey _:
        _requestKeysByUri.putIfAbsent(key.uri, ifAbsent).add(key);
      default:
        debugPrint('failed to register image cache key because of unknown type for key=$key');
    }
  }

  static void evict(String uri) {
    final keys = _requestKeysByUri.remove(uri) ?? {};
    debugPrint('Evict cached images for uri=$uri: ${keys.length} imageCache keys');
    keys.forEach(imageCache.evict);
  }

  // return keys sorted by descending extent
  static List<ThumbnailProviderKey> getThumbnailProviderKeys(String uri) {
    return (_requestKeysByUri[uri] ?? {}).whereType<ThumbnailProviderKey>().sortedByCompare((key) => key.extent, (a, b) => b.compareTo(a));
  }
}
