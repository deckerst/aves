import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/panorama.dart';
import 'package:aves/services/service_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MetadataService {
  static const platform = MethodChannel('deckers.thibault/aves/metadata');

  // return Map<Map<Key, Value>> (map of directories, each directory being a map of metadata label and value description)
  static Future<Map> getAllMetadata(AvesEntry entry) async {
    if (entry.isSvg) return null;

    try {
      final result = await platform.invokeMethod('getAllMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getAllMetadata failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  static Future<CatalogMetadata> getCatalogMetadata(AvesEntry entry, {bool background = false}) async {
    if (entry.isSvg) return null;

    Future<CatalogMetadata> call() async {
      try {
        // return map with:
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

  static Future<OverlayMetadata> getOverlayMetadata(AvesEntry entry) async {
    if (entry.isSvg) return null;

    try {
      // return map with values for: 'aperture' (double), 'exposureTime' (description), 'focalLength' (double), 'iso' (int)
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

  static Future<MultiPageInfo> getMultiPageInfo(AvesEntry entry) async {
    try {
      final result = await platform.invokeMethod('getMultiPageInfo', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
      }) as Map;
      return MultiPageInfo.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('getMultiPageInfo failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }

  static Future<PanoramaInfo> getPanoramaInfo(AvesEntry entry) async {
    try {
      // return map with values for:
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

  static Future<List<Uint8List>> getEmbeddedPictures(String uri) async {
    try {
      final result = await platform.invokeMethod('getEmbeddedPictures', <String, dynamic>{
        'uri': uri,
      });
      return (result as List).cast<Uint8List>();
    } on PlatformException catch (e) {
      debugPrint('getEmbeddedPictures failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return [];
  }

  static Future<List<Uint8List>> getExifThumbnails(AvesEntry entry) async {
    try {
      final result = await platform.invokeMethod('getExifThumbnails', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      return (result as List).cast<Uint8List>();
    } on PlatformException catch (e) {
      debugPrint('getExifThumbnail failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return [];
  }

  static Future<Map> extractXmpDataProp(AvesEntry entry, String propPath, String propMimeType) async {
    try {
      final result = await platform.invokeMethod('extractXmpDataProp', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'propPath': propPath,
        'propMimeType': propMimeType,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('extractXmpDataProp failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }
}
