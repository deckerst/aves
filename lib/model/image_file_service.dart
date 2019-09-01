import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageFileService {
  static const platform = const MethodChannel('deckers.thibault/aves/image');

  static getImageEntries() async {
    try {
      await platform.invokeMethod('getImageEntries');
    } on PlatformException catch (e) {
      debugPrint('getImageEntries failed with exception=${e.message}');
    }
  }

  static Future<Uint8List> getImageBytes(ImageEntry entry, int width, int height) async {
    if (width > 0 && height > 0) {
      try {
        final result = await platform.invokeMethod('getImageBytes', <String, dynamic>{
          'entry': entry.toMap(),
          'width': width,
          'height': height,
        });
        return result as Uint8List;
      } on PlatformException catch (e) {
        debugPrint('getImageBytes failed with exception=${e.message}');
      }
    }
    return Uint8List(0);
  }

  static Future<bool> delete(ImageEntry entry) async {
    try {
      await platform.invokeMethod('delete', <String, dynamic>{
        'entry': entry.toMap(),
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint('delete failed with exception=${e.message}');
    }
    return false;
  }

  static Future<Map> rename(ImageEntry entry, String newName) async {
    try {
      // return map with: 'contentId' 'path' 'title' 'uri' (all optional)
      final result = await platform.invokeMethod('rename', <String, dynamic>{
        'entry': entry.toMap(),
        'newName': newName,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('rename failed with exception=${e.message}');
    }
    return Map();
  }

  static Future<Map> rotate(ImageEntry entry, {@required bool clockwise}) async {
    try {
      // return map with: 'width' 'height' 'orientationDegrees' (all optional)
      final result = await platform.invokeMethod('rotate', <String, dynamic>{
        'entry': entry.toMap(),
        'clockwise': clockwise,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('rotate failed with exception=${e.message}');
    }
    return Map();
  }
}
