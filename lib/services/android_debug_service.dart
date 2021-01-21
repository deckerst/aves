import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidDebugService {
  static const platform = MethodChannel('deckers.thibault/aves/debug');

  static Future<Map> getContextDirs() async {
    try {
      final result = await platform.invokeMethod('getContextDirs');
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getContextDirs failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  static Future<Map> getEnv() async {
    try {
      final result = await platform.invokeMethod('getEnv');
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getEnv failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  static Future<Map> getBitmapFactoryInfo(AvesEntry entry) async {
    try {
      // return map with all data available when decoding image bounds with `BitmapFactory`
      final result = await platform.invokeMethod('getBitmapFactoryInfo', <String, dynamic>{
        'uri': entry.uri,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('getBitmapFactoryInfo failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  static Future<Map> getContentResolverMetadata(AvesEntry entry) async {
    try {
      // return map with all data available from the content resolver
      final result = await platform.invokeMethod('getContentResolverMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('getContentResolverMetadata failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  static Future<Map> getExifInterfaceMetadata(AvesEntry entry) async {
    try {
      // return map with all data available from the `ExifInterface` library
      final result = await platform.invokeMethod('getExifInterfaceMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('getExifInterfaceMetadata failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  static Future<Map> getMediaMetadataRetrieverMetadata(AvesEntry entry) async {
    try {
      // return map with all data available from `MediaMetadataRetriever`
      final result = await platform.invokeMethod('getMediaMetadataRetrieverMetadata', <String, dynamic>{
        'uri': entry.uri,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('getMediaMetadataRetrieverMetadata failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  static Future<Map> getMetadataExtractorSummary(AvesEntry entry) async {
    try {
      // return map with the mime type and tag count for each directory found by `metadata-extractor`
      final result = await platform.invokeMethod('getMetadataExtractorSummary', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('getMetadataExtractorSummary failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  static Future<Map> getTiffStructure(AvesEntry entry) async {
    if (entry.mimeType != MimeTypes.tiff) return {};

    try {
      final result = await platform.invokeMethod('getTiffStructure', <String, dynamic>{
        'uri': entry.uri,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('getTiffStructure failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }
}
