import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageFetcher {
  static const platform = const MethodChannel('deckers.thibault.aves/mediastore');

  static Future<List<Map>> getImageEntries() async {
    try {
      final result = await platform.invokeMethod('getImageEntries');
      return (result as List).cast<Map>();
    } on PlatformException catch (e) {
      debugPrint('getImageEntries failed with exception=${e.message}');
    }
    return [];
  }

  static Future<Uint8List> getImageBytes(Map entry, int width, int height) async {
    try {
      final result = await platform.invokeMethod('getImageBytes', <String, dynamic>{
        'entry': entry,
        'width': width,
        'height': height,
      });
      return result as Uint8List;
    } on PlatformException catch (e) {
      debugPrint('getImageBytes failed with exception=${e.message}');
    }
    return Uint8List(0);
  }

  static cancelGetImageBytes(String uri) async {
    try {
      await platform.invokeMethod('cancelGetImageBytes', <String, dynamic>{
        'uri': uri,
      });
    } on PlatformException catch (e) {
      debugPrint('cancelGetImageBytes failed with exception=${e.message}');
    }
  }

  // return map with: 'aperture' 'exposureTime' 'focalLength' 'iso'
  static Future<Map> getOverlayMetadata (String path) async {
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