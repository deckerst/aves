import 'package:aves/model/metadata/enums.dart';
import 'package:aves/model/metadata/fields.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class DateModifier extends Equatable {
  static const writableDateFields = [
    MetadataField.exifDate,
    MetadataField.exifDateOriginal,
    MetadataField.exifDateDigitized,
    MetadataField.exifGpsDatestamp,
    MetadataField.xmpCreateDate,
  ];

  final DateEditAction action;
  final Set<MetadataField> fields;
  final DateTime? setDateTime;
  final DateFieldSource? copyFieldSource;
  final int? shiftMinutes;

  @override
  List<Object?> get props => [action, fields, setDateTime, copyFieldSource, shiftMinutes];

  const DateModifier._private(
    this.action, {
    this.fields = const {},
    this.setDateTime,
    this.copyFieldSource,
    this.shiftMinutes,
  });

  factory DateModifier.setCustom(Set<MetadataField> fields, DateTime dateTime) {
    return DateModifier._private(DateEditAction.setCustom, fields: fields, setDateTime: dateTime);
  }

  factory DateModifier.copyField(DateFieldSource copyFieldSource) {
    return DateModifier._private(DateEditAction.copyField, copyFieldSource: copyFieldSource);
  }

  factory DateModifier.extractFromTitle() {
    return const DateModifier._private(DateEditAction.extractFromTitle);
  }

  factory DateModifier.shift(Set<MetadataField> fields, int shiftMinutes) {
    return DateModifier._private(DateEditAction.shift, fields: fields, shiftMinutes: shiftMinutes);
  }

  factory DateModifier.remove(Set<MetadataField> fields) {
    return DateModifier._private(DateEditAction.remove, fields: fields);
  }
}
