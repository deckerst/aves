import 'dart:async';

import 'package:aves/convert/convert.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

abstract class MetadataEditService {
  Future<Map<String, dynamic>> rotate(AvesEntry entry, {required bool clockwise});

  Future<Map<String, dynamic>> flip(AvesEntry entry);

  Future<Map<String, dynamic>> editExifDate(AvesEntry entry, DateModifier modifier);

  Future<Map<String, dynamic>> editMetadata(AvesEntry entry, Map<MetadataType, dynamic> modifier, {bool autoCorrectTrailerOffset = true});

  Future<Map<String, dynamic>> removeTrailerVideo(AvesEntry entry);

  Future<Map<String, dynamic>> removeTypes(AvesEntry entry, Set<MetadataType> types);
}

class PlatformMetadataEditService implements MetadataEditService {
  static const _platform = MethodChannel('deckers.thibault/aves/metadata_edit');

  @override
  Future<Map<String, dynamic>> rotate(AvesEntry entry, {required bool clockwise}) async {
    try {
      // returns map with: 'rotationDegrees' 'isFlipped'
      final result = await _platform.invokeMethod('rotate', <String, dynamic>{
        'entry': entry.toPlatformEntryMap(),
        'clockwise': clockwise,
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> flip(AvesEntry entry) async {
    try {
      // returns map with: 'rotationDegrees' 'isFlipped'
      final result = await _platform.invokeMethod('flip', <String, dynamic>{
        'entry': entry.toPlatformEntryMap(),
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> editExifDate(AvesEntry entry, DateModifier modifier) async {
    try {
      final result = await _platform.invokeMethod('editDate', <String, dynamic>{
        'entry': entry.toPlatformEntryMap(),
        'dateMillis': modifier.setDateTime?.millisecondsSinceEpoch,
        'shiftMinutes': modifier.shiftMinutes,
        'fields': modifier.fields.where((v) => v.type == MetadataType.exif).map((v) => v.toPlatform).whereNotNull().toList(),
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> editMetadata(
    AvesEntry entry,
    Map<MetadataType, dynamic> metadata, {
    bool autoCorrectTrailerOffset = true,
  }) async {
    // TODO TLAD remove log when OOMs are inspected
    if ((entry.sizeBytes ?? 0) > 20000000) {
      await reportService.log('edit metadata of large entry=$entry size=${entry.sizeBytes}');
    }

    try {
      final result = await _platform.invokeMethod('editMetadata', <String, dynamic>{
        'entry': entry.toPlatformEntryMap(),
        'metadata': metadata.map((type, value) => MapEntry(type.toPlatform, value)),
        'autoCorrectTrailerOffset': autoCorrectTrailerOffset,
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> removeTrailerVideo(AvesEntry entry) async {
    try {
      final result = await _platform.invokeMethod('removeTrailerVideo', <String, dynamic>{
        'entry': entry.toPlatformEntryMap(),
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> removeTypes(AvesEntry entry, Set<MetadataType> types) async {
    try {
      final result = await _platform.invokeMethod('removeTypes', <String, dynamic>{
        'entry': entry.toPlatformEntryMap(),
        'types': types.map((v) => v.toPlatform).toList(),
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await _processPlatformException(entry, e, stack);
    }
    return {};
  }

  Future<void> _processPlatformException(AvesEntry entry, PlatformException e, StackTrace stack) async {
    if (!entry.isMissingAtPath) {
      final code = e.code;
      if (code.endsWith('mp4largemoov')) {
        await reportService.recordError(_Mp4LargeMoovException(code: e.code, message: e.message, details: e.details, stacktrace: e.stacktrace), stack);
      } else if (code.endsWith('mp4largeother')) {
        await reportService.recordError(_Mp4LargeOtherException(code: e.code, message: e.message, details: e.details, stacktrace: e.stacktrace), stack);
      } else if (code.endsWith('filenotfound')) {
        await reportService.recordError(_FileNotFoundException(code: e.code, message: e.message, details: e.details, stacktrace: e.stacktrace), stack);
      } else {
        await reportService.recordError(e, stack);
      }
    }
  }
}

// distinct exceptions to convince Crashlytics to split reports into distinct issues

class _Mp4LargeMoovException extends PlatformException {
  _Mp4LargeMoovException({
    required super.code,
    required super.message,
    required super.details,
    required super.stacktrace,
  });
}

class _Mp4LargeOtherException extends PlatformException {
  _Mp4LargeOtherException({
    required super.code,
    required super.message,
    required super.details,
    required super.stacktrace,
  });
}

class _FileNotFoundException extends PlatformException {
  _FileNotFoundException({
    required super.code,
    required super.message,
    required super.details,
    required super.stacktrace,
  });
}
