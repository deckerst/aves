import 'package:aves_model/aves_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class DateModifier extends Equatable {
  static const writableFields = <MetadataField>[
    .exifDate,
    .exifDateOriginal,
    .exifDateDigitized,
    .exifGpsDatestamp,
    .xmpXmpCreateDate,
  ];

  final DateEditAction action;
  final Set<MetadataField> fields;
  final DateTime? setDateTime;
  final DateFieldSource? copyFieldSource;
  final int? shiftSeconds;

  @override
  List<Object?> get props => [action, fields, setDateTime, copyFieldSource, shiftSeconds];

  const new _private(
    this.action, {
    this.fields = const {},
    this.setDateTime,
    this.copyFieldSource,
    this.shiftSeconds,
  });

  factory setCustom(Set<MetadataField> fields, DateTime dateTime) {
    return DateModifier._private(.setCustom, fields: fields, setDateTime: dateTime);
  }

  factory copyField(DateFieldSource copyFieldSource) {
    return DateModifier._private(.copyField, copyFieldSource: copyFieldSource);
  }

  factory extractFromTitle() {
    return const DateModifier._private(.extractFromTitle);
  }

  factory shift(Set<MetadataField> fields, int shiftSeconds) {
    return DateModifier._private(.shift, fields: fields, shiftSeconds: shiftSeconds);
  }

  factory remove(Set<MetadataField> fields) {
    return DateModifier._private(.remove, fields: fields);
  }
}
