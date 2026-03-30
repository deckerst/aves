import 'dart:ui' as ui;

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/decoding.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/text.dart';
import 'package:flutter/services.dart';

abstract class EmbeddedDataService {
  Future<List<ui.ImageDescriptor?>> getExifThumbnails(AvesEntry entry);

  Future<Map> extractGoogleDeviceItem(AvesEntry entry, String dataUri);

  Future<Map> extractMotionPhotoImage(AvesEntry entry);

  Future<Map> extractMotionPhotoVideo(AvesEntry entry);

  Future<Map> extractJpegMpfItem(AvesEntry entry, int index);

  Future<Map> extractVideoEmbeddedPicture(AvesEntry entry);

  Future<Map> extractXmpDataProp(AvesEntry entry, List<Object?>? props, String? propMimeType);
}

class PlatformEmbeddedDataService implements EmbeddedDataService {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/embedded');

  @override
  Future<List<ui.ImageDescriptor?>> getExifThumbnails(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('getExifThumbnails', <String, Object?>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
      });
      if (result != null) {
        final descriptors = <ui.ImageDescriptor?>[];
        await Future.forEach((result as List).cast<Uint8List>(), (bytes) async {
          descriptors.add(await InteropDecoding.rawBytesToDescriptor(bytes));
        });
        return descriptors;
      }
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }

  @override
  Future<Map> extractGoogleDeviceItem(AvesEntry entry, String dataUri) async {
    try {
      final result = await _platform.invokeMethod('extractGoogleDeviceItem', <String, Object?>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'displayName': ['${entry.bestTitle}', dataUri].join(AText.separator),
        'dataUri': dataUri,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Map> extractMotionPhotoImage(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('extractMotionPhotoImage', <String, Object?>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'displayName': ['${entry.bestTitle}', 'Image'].join(AText.separator),
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Map> extractMotionPhotoVideo(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('extractMotionPhotoVideo', <String, Object?>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'displayName': ['${entry.bestTitle}', 'Video'].join(AText.separator),
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Map> extractJpegMpfItem(AvesEntry entry, int id) async {
    try {
      final result = await _platform.invokeMethod('extractJpegMpfItem', <String, Object?>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'displayName': ['${entry.bestTitle}', 'MPF #$id'].join(AText.separator),
        'id': id,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Map> extractVideoEmbeddedPicture(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('extractVideoEmbeddedPicture', <String, Object?>{
        'uri': entry.uri,
        'displayName': ['${entry.bestTitle}', 'Cover'].join(AText.separator),
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Map> extractXmpDataProp(AvesEntry entry, List<Object?>? props, String? propMimeType) async {
    try {
      final result = await _platform.invokeMethod('extractXmpDataProp', <String, Object?>{
        'mimeType': entry.mimeType,
        'uri': entry.uri,
        'sizeBytes': entry.sizeBytes,
        'displayName': ['${entry.bestTitle}', '$props'].join(AText.separator),
        'propPath': props,
        'propMimeType': propMimeType,
      });
      if (result != null) return result as Map;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }
}
