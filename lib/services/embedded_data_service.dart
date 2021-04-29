import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class EmbeddedDataService {
  Future<List<Uint8List>> getExifThumbnails(AvesEntry entry);

  Future<Map> extractMotionPhotoVideo(AvesEntry entry);

  Future<Map> extractVideoEmbeddedPicture(AvesEntry entry);

  Future<Map> extractXmpDataProp(AvesEntry entry, String propPath, String propMimeType);
}

class PlatformEmbeddedDataService implements EmbeddedDataService {
  static const platform = MethodChannel('deckers.thibault/aves/embedded');

  @override
  Future<List<Uint8List>> getExifThumbnails(AvesEntry entry) async {
    try {
      final result = await platform.invokeMethod('getExifThumbnails', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      return (result as List).cast<Uint8List>();
    } on PlatformException catch (e) {
      debugPrint('getExifThumbnail failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return [];
  }

  @override
  Future<Map> extractMotionPhotoVideo(AvesEntry entry) async {
    try {
      final result = await platform.invokeMethod('extractMotionPhotoVideo', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'displayName': '${entry.bestTitle} • Video',
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('extractMotionPhotoVideo failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }

  @override
  Future<Map> extractVideoEmbeddedPicture(AvesEntry entry) async {
    try {
      final result = await platform.invokeMethod('extractVideoEmbeddedPicture', <String, dynamic>{
        'uri': entry.uri,
        'displayName': '${entry.bestTitle} • Cover',
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('extractVideoEmbeddedPicture failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }

  @override
  Future<Map> extractXmpDataProp(AvesEntry entry, String propPath, String propMimeType) async {
    try {
      final result = await platform.invokeMethod('extractXmpDataProp', <String, dynamic>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'displayName': '${entry.bestTitle} • $propPath',
        'propPath': propPath,
        'propMimeType': propMimeType,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('extractXmpDataProp failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }
}
