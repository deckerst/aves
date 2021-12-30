import 'package:aves/model/metadata/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class DateModifier {
  static const writableDateFields = [
    MetadataField.exifDate,
    MetadataField.exifDateOriginal,
    MetadataField.exifDateDigitized,
    MetadataField.exifGpsDate,
  ];

  final DateEditAction action;
  final Set<MetadataField> fields;
  final DateTime? setDateTime;
  final DateFieldSource? copyFieldSource;
  final int? shiftMinutes;

  const DateModifier._private(
    this.action,
    this.fields, {
    this.setDateTime,
    this.copyFieldSource,
    this.shiftMinutes,
  });

  factory DateModifier.setCustom(Set<MetadataField> fields, DateTime dateTime) {
    return DateModifier._private(DateEditAction.setCustom, fields, setDateTime: dateTime);
  }

  factory DateModifier.copyField(Set<MetadataField> fields, DateFieldSource copyFieldSource) {
    return DateModifier._private(DateEditAction.copyField, fields, copyFieldSource: copyFieldSource);
  }

  factory DateModifier.extractFromTitle(Set<MetadataField> fields) {
    return DateModifier._private(DateEditAction.extractFromTitle, fields);
  }

  factory DateModifier.shift(Set<MetadataField> fields, int shiftMinutes) {
    return DateModifier._private(DateEditAction.shift, fields, shiftMinutes: shiftMinutes);
  }

  factory DateModifier.clear(Set<MetadataField> fields) {
    return DateModifier._private(DateEditAction.clear, fields);
  }
}
