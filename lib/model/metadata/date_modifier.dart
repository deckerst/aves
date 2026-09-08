import 'package:aves_model/aves_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class DateModifier extends Equatable {
  static const writableFields = [
    MetadataField.exifDate,
    MetadataField.exifDateOriginal,
    MetadataField.exifDateDigitized,
    MetadataField.exifGpsDatestamp,
    MetadataField.xmpXmpCreateDate,
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
    return DateModifier._private(DateEditAction.setCustom, fields: fields, setDateTime: dateTime);
  }

  factory copyField(DateFieldSource copyFieldSource) {
    return DateModifier._private(DateEditAction.copyField, copyFieldSource: copyFieldSource);
  }

  factory extractFromTitle() {
    return const DateModifier._private(DateEditAction.extractFromTitle);
  }

  factory shift(Set<MetadataField> fields, int shiftSeconds) {
    return DateModifier._private(DateEditAction.shift, fields: fields, shiftSeconds: shiftSeconds);
  }

  factory remove(Set<MetadataField> fields) {
    return DateModifier._private(DateEditAction.remove, fields: fields);
  }
}
