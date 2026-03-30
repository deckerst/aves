import 'dart:async';

import 'package:aves/convert/convert.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/custom_exception.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class MetadataEditService {
  Future<Map<String, Object?>> rotate(AvesEntry entry, {required bool clockwise});

  Future<Map<String, Object?>> flip(AvesEntry entry);

  Future<Map<String, Object?>> editExifDate(AvesEntry entry, DateModifier modifier);

  Future<Map<String, Object?>> editMetadata(AvesEntry entry, Map<MetadataType, dynamic> modifier, {bool autoCorrectTrailerOffset = true});

  Future<Map<String, Object?>> removeTrailerVideo(AvesEntry entry);

  Future<Map<String, Object?>> removeTypes(AvesEntry entry, Set<MetadataType> types);
}

class PlatformMetadataEditService implements MetadataEditService {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/metadata_edit');

  @override
  Future<Map<String, Object?>> rotate(AvesEntry entry, {required bool clockwise}) async {
    try {
      // returns map with: 'rotationDegrees' 'isFlipped'
      final result = await _platform.invokeMethod('rotate', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'clockwise': clockwise,
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, Object?>> flip(AvesEntry entry) async {
    try {
      // returns map with: 'rotationDegrees' 'isFlipped'
      final result = await _platform.invokeMethod('flip', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, Object?>> editExifDate(AvesEntry entry, DateModifier modifier) async {
    try {
      final result = await _platform.invokeMethod('editDate', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'dateMillis': modifier.setDateTime?.millisecondsSinceEpoch,
        'shiftSeconds': modifier.shiftSeconds,
        'fields': modifier.fields.where((v) => v.type == MetadataType.exif).map((v) => v.toPlatform).nonNulls.toList(),
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, Object?>> editMetadata(
    AvesEntry entry,
    Map<MetadataType, dynamic> metadata, {
    bool autoCorrectTrailerOffset = true,
  }) async {
    try {
      final result = await _platform.invokeMethod('editMetadata', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'metadata': metadata.map((type, value) => MapEntry(type.toPlatform, value)),
        'autoCorrectTrailerOffset': autoCorrectTrailerOffset,
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, Object?>> removeTrailerVideo(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('removeTrailerVideo', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, Object?>> removeTypes(AvesEntry entry, Set<MetadataType> types) async {
    try {
      final result = await _platform.invokeMethod('removeTypes', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'types': types.map((v) => v.toPlatform).toList(),
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  Future<void> _processPlatformException(AvesEntry entry, PlatformException e, StackTrace stack) async {
    if (entry.isValid) {
      final code = e.code;
      final customException = CustomPlatformException.fromStandard(e);
      if (code.endsWith('mp4fragmented')) {
        await mp4Fragmented(customException);
      } else if (code.endsWith('mp4zerosizebox')) {
        await mp4ZeroSizeBox(customException);
      } else if (code.endsWith('mp4largemoov')) {
        await mp4LargeMoov(customException);
      } else if (code.endsWith('mp4largeother')) {
        await mp4LargeOther(customException);
      } else if (code.endsWith('filenotfound')) {
        await fileNotFound(customException);
      } else {
        await reportService.recordError(e, stack);
      }
    }
  }

  // distinct exceptions to convince Crashlytics to split reports into distinct issues
  // The distinct debug statement is there to make the body unique, so that the methods are not merged at compile time.

  Future<void> mp4Fragmented(CustomPlatformException e) {
    debugPrint('mp4Fragmented $e');
    return reportService.recordError(e);
  }

  Future<void> mp4ZeroSizeBox(CustomPlatformException e) {
    debugPrint('mp4ZeroSizeBox $e');
    return reportService.recordError(e);
  }

  Future<void> mp4LargeMoov(CustomPlatformException e) {
    debugPrint('mp4LargeMoov $e');
    return reportService.recordError(e);
  }

  Future<void> mp4LargeOther(CustomPlatformException e) {
    debugPrint('mp4LargeOther $e');
    return reportService.recordError(e);
  }

  Future<void> fileNotFound(CustomPlatformException e) {
    debugPrint('fileNotFound $e');
    return reportService.recordError(e);
  }
}
