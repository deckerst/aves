import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageFileService {
  static const platform = MethodChannel('deckers.thibault/aves/image');

  static Future<void> getImageEntries() async {
    try {
      await platform.invokeMethod('getImageEntries');
    } on PlatformException catch (e) {
      debugPrint('getImageEntries failed with exception=${e.message}');
    }
  }

  static Future<ImageEntry> getImageEntry(String uri, String mimeType) async {
    debugPrint('getImageEntry for uri=$uri, mimeType=$mimeType');
    try {
      final result = await platform.invokeMethod('getImageEntry', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      }) as Map;
      return ImageEntry.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('getImageEntry failed with exception=${e.message}');
    }
    return null;
  }

  static Future<Uint8List> getImage(String uri, String mimeType) async {
    try {
      final result = await platform.invokeMethod('getImage', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      });
      return result as Uint8List;
    } on PlatformException catch (e) {
      debugPrint('getImage failed with exception=${e.message}');
    }
    return Uint8List(0);
  }

  static Future<Uint8List> getThumbnail(ImageEntry entry, int width, int height) async {
    if (width > 0 && height > 0) {
//      debugPrint('getThumbnail width=$width path=${entry.path}');
      try {
        final result = await platform.invokeMethod('getThumbnail', <String, dynamic>{
          'entry': entry.toMap(),
          'width': width,
          'height': height,
        });
        return result as Uint8List;
      } on PlatformException catch (e) {
        debugPrint('getThumbnail failed with exception=${e.message}');
      }
    }
    return Uint8List(0);
  }

  static Future<void> cancelGetThumbnail(String uri) async {
    try {
      await platform.invokeMethod('cancelGetThumbnail', <String, dynamic>{
        'uri': uri,
      });
    } on PlatformException catch (e) {
      debugPrint('cancelGetThumbnail failed with exception=${e.message}');
    }
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
    return {};
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
    return {};
  }
}
