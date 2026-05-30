import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';

class AndroidDebugService {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/debug');

  static Future<void> crash() async {
    try {
      await _platform.invokeMethod('crash');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<void> exception() async {
    try {
      await _platform.invokeMethod('exception');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<void> safeException() async {
    try {
      await _platform.invokeMethod('safeException');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<void> exceptionInCoroutine() async {
    try {
      await _platform.invokeMethod('exceptionInCoroutine');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<void> safeExceptionInCoroutine() async {
    try {
      await _platform.invokeMethod('safeExceptionInCoroutine');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  static Future<Map> getContextDirs() async {
    try {
      final result = await _platform.invokeMethod('getContextDirs');
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<List<Map>> getCodecs() async {
    try {
      final result = await _platform.invokeMethod('getCodecs');
      if (result != null) return (result as List).cast<Map>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }

  static Future<Map> getEnv() async {
    try {
      final result = await _platform.invokeMethod('getEnv');
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  static Future<Map> getBitmapFactoryInfo(AvesEntry entry) async {
    try {
      // returns map with all data available when decoding image bounds with `BitmapFactory`
      final result = await _platform.invokeMethod('getBitmapFactoryInfo', <String, Object?>{
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
      final result = await _platform.invokeMethod('getContentResolverMetadata', <String, Object?>{
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
      final result = await _platform.invokeMethod('getExifInterfaceMetadata', <String, Object?>{
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
      final result = await _platform.invokeMethod('getMediaMetadataRetrieverMetadata', <String, Object?>{
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
      // returns map with the MIME type and tag count for each directory found by `metadata-extractor`
      final result = await _platform.invokeMethod('getMetadataExtractorSummary', <String, Object?>{
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

  static Future<String?> getMp4ParserDump(AvesEntry entry) async {
    try {
      return await _platform.invokeMethod('getMp4ParserDump', <String, Object?>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  static Future<Map> getPixyMetadata(AvesEntry entry) async {
    try {
      // returns map with all data available from the `PixyMeta` library
      final result = await _platform.invokeMethod('getPixyMetadata', <String, Object?>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
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
      final result = await _platform.invokeMethod('getTiffStructure', <String, Object?>{
        'uri': entry.uri,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  // bytes are expected to be in a basic format decodable by Flutter
  static Future<Uint8List?> getThumbnail(ThumbnailProviderKey request, ThumbnailMethod method) async {
    try {
      final result = await _platform.invokeMethod('getThumbnail', <String, Object?>{
        'uri': request.uri,
        'pageId': request.pageId,
        'mimeType': request.mimeType,
        'dateModifiedMillis': request.dateModifiedMillis,
        'rotationDegrees': request.rotationDegrees,
        'isFlipped': request.isFlipped,
        'widthDip': request.extent,
        'heightDip': request.extent,
        'method': method.name,
      });
      if (result != null) return result as Uint8List;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }
}

enum ThumbnailMethod { resolver, mediaStore, glide }
