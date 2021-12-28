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
  final DateSetSource? setSource;
  final DateTime? setDateTime;
  final int? shiftMinutes;

  const DateModifier(
    this.action,
    this.fields, {
    this.setSource,
    this.setDateTime,
    this.shiftMinutes,
  });
}
