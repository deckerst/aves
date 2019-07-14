import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageFetcher {
  static const platform = const MethodChannel('deckers.thibault.aves/mediastore');

  static Future<List> getImageEntries() async {
    try {
      final result = await platform.invokeMethod('getImageEntries');
      return result as List;
    } on PlatformException catch (e) {
      debugPrint('failed with exception=${e.message}');
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
      debugPrint('failed with exception=${e.message}');
    }
    return Uint8List(0);
  }

  static cancelGetImageBytes(String uri) async {
    try {
      await platform.invokeMethod('cancelGetImageBytes', <String, dynamic>{
        'uri': uri,
      });
    } on PlatformException catch (e) {
      debugPrint('failed with exception=${e.message}');
    }
  }
}
