import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:flutter/material.dart';
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
//    debugPrint('getImageBytes with path=${entry.path} contentId=${entry.contentId}');
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

  static cancelGetImageBytes(String uri) async {
    try {
      await platform.invokeMethod('cancelGetImageBytes', <String, dynamic>{
        'uri': uri,
      });
    } on PlatformException catch (e) {
      debugPrint('cancelGetImageBytes failed with exception=${e.message}');
    }
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
}
