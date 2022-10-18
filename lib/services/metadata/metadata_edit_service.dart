import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/model/metadata/fields.dart';
import 'package:aves/services/common/services.dart';
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
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
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
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
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
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> editMetadata(
    AvesEntry entry,
    Map<MetadataType, dynamic> metadata, {
    bool autoCorrectTrailerOffset = true,
  }) async {
    try {
      final result = await _platform.invokeMethod('editMetadata', <String, dynamic>{
        'entry': entry.toPlatformEntryMap(),
        'metadata': metadata.map((type, value) => MapEntry(type.toPlatform, value)),
        'autoCorrectTrailerOffset': autoCorrectTrailerOffset,
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
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
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
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
      if (!entry.isMissingAtPath) {
        await reportService.recordError(e, stack);
      }
    }
    return {};
  }
}
