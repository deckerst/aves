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
  Future<Map<String, Object?>> rotate(AvesEntry entry, List<String> c2paActions, {required bool clockwise});

  Future<Map<String, Object?>> flip(AvesEntry entry, List<String> c2paActions);

  Future<Map<String, Object?>> editExifDate(AvesEntry entry, List<String> c2paActions, DateModifier modifier);

  Future<Map<String, Object?>> editMetadata(AvesEntry entry, List<String> c2paActions, Map<MetadataType, dynamic> modifier, {bool autoCorrectTrailerOffset = true});

  Future<Map<String, Object?>> removeTrailerVideo(AvesEntry entry, List<String> c2paActions);

  Future<Map<String, Object?>> removeTypes(AvesEntry entry, List<String> c2paActions, Set<MetadataType> types);
}

class PlatformMetadataEditService implements MetadataEditService {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/metadata_edit');

  @override
  Future<Map<String, Object?>> rotate(AvesEntry entry, List<String> c2paActions, {required bool clockwise}) async {
    try {
      // returns map with: 'rotationDegrees' 'isFlipped'
      final result = await _platform.invokeMethod('rotate', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'c2paActions': c2paActions,
        'clockwise': clockwise,
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, Object?>> flip(AvesEntry entry, List<String> c2paActions) async {
    try {
      // returns map with: 'rotationDegrees' 'isFlipped'
      final result = await _platform.invokeMethod('flip', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'c2paActions': c2paActions,
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, Object?>> editExifDate(AvesEntry entry, List<String> c2paActions, DateModifier modifier) async {
    try {
      final result = await _platform.invokeMethod('editExifDate', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'c2paActions': c2paActions,
        'dateMillis': modifier.setDateTime?.millisecondsSinceEpoch,
        'timeZoneOffsetMinutes': modifier.timeZoneOffsetMinutes,
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
    List<String> c2paActions,
    Map<MetadataType, dynamic> metadata, {
    bool autoCorrectTrailerOffset = true,
  }) async {
    try {
      final result = await _platform.invokeMethod('editMetadata', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'c2paActions': c2paActions,
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
  Future<Map<String, Object?>> removeTrailerVideo(AvesEntry entry, List<String> c2paActions) async {
    try {
      final result = await _platform.invokeMethod('removeTrailerVideo', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'c2paActions': c2paActions,
      });
      if (result is Map) return result.cast<String, Object?>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, Object?>> removeTypes(AvesEntry entry, List<String> c2paActions, Set<MetadataType> types) async {
    try {
      final result = await _platform.invokeMethod('removeTypes', <String, Object?>{
        'entry': entry.toPlatformEntryMap(),
        'c2paActions': c2paActions,
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
      if (code.endsWith('exifinterface')) {
        await exifInterface(customException);
      } else if (code.endsWith('mp4fragmented')) {
        await mp4Fragmented(customException);
      } else if (code.endsWith('mp4zerosizebox')) {
        await mp4ZeroSizeBox(customException);
      } else if (code.endsWith('mp4largemoov')) {
        await mp4LargeMoov(customException);
      } else if (code.endsWith('mp4largeother')) {
        await mp4LargeOther(customException);
      } else if (code.endsWith('outputstream')) {
        await outputStream(customException);
      } else if (code.endsWith('partialtransfer')) {
        await partialTransfer(customException);
      } else if (code.endsWith('filenotfound')) {
        debugPrint('Unreported `fileNotFound` error with exception=$e');
      } else if (code.endsWith('readonly')) {
        debugPrint('Unreported `readOnly` error with exception=$e');
      } else {
        await reportService.recordError(e, stack);
      }
    }
  }

  // distinct exceptions to convince Crashlytics to split reports into distinct issues
  // The distinct debug statement is there to make the body unique, so that the methods are not merged at compile time.

  Future<void> exifInterface(CustomPlatformException e) {
    debugPrint('exifInterface $e');
    return reportService.recordError(e);
  }

  Future<void> mp4Fragmented(CustomPlatformException e) {
    debugPrint('mp4Fragmented $e');
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

  Future<void> mp4ZeroSizeBox(CustomPlatformException e) {
    debugPrint('mp4ZeroSizeBox $e');
    return reportService.recordError(e);
  }

  Future<void> outputStream(CustomPlatformException e) {
    debugPrint('outputStream $e');
    return reportService.recordError(e);
  }

  Future<void> partialTransfer(CustomPlatformException e) {
    debugPrint('partialTransfer $e');
    return reportService.recordError(e);
  }
}
