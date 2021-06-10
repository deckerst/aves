import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/panorama.dart';
import 'package:aves/services/service_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class MetadataService {
  // returns Map<Map<Key, Value>> (map of directories, each directory being a map of metadata label and value description)
  Future<Map> getAllMetadata(AvesEntry entry);

  Future<CatalogMetadata?> getCatalogMetadata(AvesEntry entry, {bool background = false});

  Future<OverlayMetadata?> getOverlayMetadata(AvesEntry entry);

  Future<MultiPageInfo?> getMultiPageInfo(AvesEntry entry);

  Future<PanoramaInfo?> getPanoramaInfo(AvesEntry entry);

  Future<String?> getContentResolverProp(AvesEntry entry, String prop);
}

class PlatformMetadataService implements MetadataService {
  static const platform = MethodChannel('deckers.thibault/aves/metadata');

  @override
  Future<Map> getAllMetadata(AvesEntry entry) async {
    if (entry.isSvg) return {};

    try {
      final result = await platform.invokeMethod('getAllMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getAllMetadata failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  @override
  Future<CatalogMetadata?> getCatalogMetadata(AvesEntry entry, {bool background = false}) async {
    if (entry.isSvg) return null;

    Future<CatalogMetadata?> call() async {
      try {
        // returns map with:
        // 'mimeType': MIME type as reported by metadata extractors, not Media Store (string)
        // 'dateMillis': date taken in milliseconds since Epoch (long)
        // 'isAnimated': animated gif/webp (bool)
        // 'isFlipped': flipped according to EXIF orientation (bool)
        // 'rotationDegrees': rotation degrees according to EXIF orientation or other metadata (int)
        // 'latitude': latitude (double)
        // 'longitude': longitude (double)
        // 'xmpSubjects': ';' separated XMP subjects (string)
        // 'xmpTitleDescription': XMP title or XMP description (string)
        final result = await platform.invokeMethod('getCatalogMetadata', <String, dynamic>{
          'mimeType': entry.mimeType,
          'uri': entry.uri,
          'path': entry.path,
          'sizeBytes': entry.sizeBytes,
        }) as Map;
        result['contentId'] = entry.contentId;
        return CatalogMetadata.fromMap(result);
      } on PlatformException catch (e) {
        debugPrint('getCatalogMetadata failed with code=${e.code}, exception=${e.message}, details=${e.details}');
      }
      return null;
    }

    return background
        ? servicePolicy.call(
            call,
            priority: ServiceCallPriority.getMetadata,
          )
        : call();
  }

  @override
  Future<OverlayMetadata?> getOverlayMetadata(AvesEntry entry) async {
    if (entry.isSvg) return null;

    try {
      // returns map with values for: 'aperture' (double), 'exposureTime' (description), 'focalLength' (double), 'iso' (int)
      final result = await platform.invokeMethod('getOverlayMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      }) as Map;
      return OverlayMetadata.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('getOverlayMetadata failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }

  @override
  Future<MultiPageInfo?> getMultiPageInfo(AvesEntry entry) async {
    try {
      final result = await platform.invokeMethod('getMultiPageInfo', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      final pageMaps = (result as List).cast<Map>();
      if (entry.isMotionPhoto && pageMaps.isNotEmpty) {
        final imagePage = pageMaps[0];
        imagePage['width'] = entry.width;
        imagePage['height'] = entry.height;
        imagePage['rotationDegrees'] = entry.rotationDegrees;
      }
      return MultiPageInfo.fromPageMaps(entry, pageMaps);
    } on PlatformException catch (e) {
      debugPrint('getMultiPageInfo failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }

  @override
  Future<PanoramaInfo?> getPanoramaInfo(AvesEntry entry) async {
    try {
      // returns map with values for:
      // 'croppedAreaLeft' (int), 'croppedAreaTop' (int), 'croppedAreaWidth' (int), 'croppedAreaHeight' (int),
      // 'fullPanoWidth' (int), 'fullPanoHeight' (int)
      final result = await platform.invokeMethod('getPanoramaInfo', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      }) as Map;
      return PanoramaInfo.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('PanoramaInfo failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }

  @override
  Future<String?> getContentResolverProp(AvesEntry entry, String prop) async {
    try {
      return await platform.invokeMethod('getContentResolverProp', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'prop': prop,
      });
    } on PlatformException catch (e) {
      debugPrint('getContentResolverProp failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }
}
