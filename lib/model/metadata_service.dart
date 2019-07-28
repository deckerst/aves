import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MetadataService {
  static const platform = const MethodChannel('deckers.thibault/aves/metadata');

  // return map with: 'aperture' 'exposureTime' 'focalLength' 'iso'
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

  // return Map<Map<Key, Value>>
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
}
