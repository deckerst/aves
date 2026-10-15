import 'package:aves_model/aves_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const DateModifier._private(
  final DateEditAction action, {
  final Set<MetadataField> fields = const {},
  final DateTime? setDateTime,
  final int? timeZoneOffsetMinutes,
  final DateFieldSource? copyFieldSource,
  final int? shiftSeconds,
}) extends Equatable {
  static const writableFields = <MetadataField>[
    .exifDate,
    .exifDateOriginal,
    .exifDateDigitized,
    .exifGpsDatestamp,
    .xmpXmpCreateDate,
  ];

  @override
  List<Object?> get props => [action, fields, setDateTime, copyFieldSource, shiftSeconds];

  factory setCustom({
    required Set<MetadataField> fields,
    required DateTime date,
    required int? timeZoneOffsetMinutes,
  }) {
    return DateModifier._private(.setCustom, fields: fields, setDateTime: date, timeZoneOffsetMinutes: timeZoneOffsetMinutes);
  }

  factory copyField(DateFieldSource copyFieldSource) {
    return DateModifier._private(.copyField, copyFieldSource: copyFieldSource);
  }

  factory extractFromFileName() {
    return const DateModifier._private(.extractFromFileName);
  }

  factory shift(Set<MetadataField> fields, int shiftSeconds) {
    return DateModifier._private(.shift, fields: fields, shiftSeconds: shiftSeconds);
  }

  factory remove(Set<MetadataField> fields) {
    return DateModifier._private(.remove, fields: fields);
  }
}
