import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MetadataService {
  static const platform = const MethodChannel('deckers.thibault/aves/metadata');

  // return Map<Map<Key, Value>> (map of directories, each directory being a map of metadata label and value description)
  static Future<Map> getAllMetadata(String path) async {
    try {
      final result = await platform.invokeMethod('getAllMetadata', <String, dynamic>{
        'path': path,
      });
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getAllMetadata failed with exception=${e.message}');
    }
    return Map();
  }

  // return map with:
  // 'dateMillis': date taken in milliseconds since Epoch (long)
  // 'latitude': latitude (double)
  // 'longitude': longitude (double)
  // 'keywords': space separated XMP subjects (string)
  static Future<Map> getCatalogMetadata(String path) async {
    try {
      final result = await platform.invokeMethod('getCatalogMetadata', <String, dynamic>{
        'path': path,
      });
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getCatalogMetadata failed with exception=${e.message}');
    }
    return Map();
  }

  // return map with string descriptions for: 'aperture' 'exposureTime' 'focalLength' 'iso'
  static Future<Map> getOverlayMetadata(String path) async {
    try {
      final result = await platform.invokeMethod('getOverlayMetadata', <String, dynamic>{
        'path': path,
      });
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getOverlayMetadata failed with exception=${e.message}');
    }
    return Map();
  }
}
