import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/services.dart';
import 'package:flutter/services.dart';

class AndroidDebugService {
  static const platform = MethodChannel('deckers.thibault/aves/debug');

  static Future<void> crash() async {
    try {
      await platform.invokeMethod('crash');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<void> exception() async {
    try {
      await platform.invokeMethod('exception');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<void> safeException() async {
    try {
      await platform.invokeMethod('safeException');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<void> exceptionInCoroutine() async {
    try {
      await platform.invokeMethod('exceptionInCoroutine');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<void> safeExceptionInCoroutine() async {
    try {
      await platform.invokeMethod('safeExceptionInCoroutine');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<Map> getContextDirs() async {
    try {
      final result = await platform.invokeMethod('getContextDirs');
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<Map> getEnv() async {
    try {
      final result = await platform.invokeMethod('getEnv');
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<Map> getBitmapFactoryInfo(AvesEntry entry) async {
    try {
      // returns map with all data available when decoding image bounds with `BitmapFactory`
      final result = await platform.invokeMethod('getBitmapFactoryInfo', <String, dynamic>{
        'uri': entry.uri,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<Map> getContentResolverMetadata(AvesEntry entry) async {
    try {
      // returns map with all data available from the content resolver
      final result = await platform.invokeMethod('getContentResolverMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<Map> getExifInterfaceMetadata(AvesEntry entry) async {
    try {
      // returns map with all data available from the `ExifInterface` library
      final result = await platform.invokeMethod('getExifInterfaceMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<Map> getMediaMetadataRetrieverMetadata(AvesEntry entry) async {
    try {
      // returns map with all data available from `MediaMetadataRetriever`
      final result = await platform.invokeMethod('getMediaMetadataRetrieverMetadata', <String, dynamic>{
        'uri': entry.uri,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<Map> getMetadataExtractorSummary(AvesEntry entry) async {
    try {
      // returns map with the mime type and tag count for each directory found by `metadata-extractor`
      final result = await platform.invokeMethod('getMetadataExtractorSummary', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<Map> getTiffStructure(AvesEntry entry) async {
    if (entry.mimeType != MimeTypes.tiff) return {};

    try {
      final result = await platform.invokeMethod('getTiffStructure', <String, dynamic>{
        'uri': entry.uri,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }
}
