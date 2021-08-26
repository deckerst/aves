import 'package:aves/model/metadata/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class DateModifier {
  static const allDateFields = [
    MetadataField.exifDate,
    MetadataField.exifDateOriginal,
    MetadataField.exifDateDigitized,
    MetadataField.exifGpsDate,
  ];

  final DateEditAction action;
  final Set<MetadataField> fields;
  final DateTime? dateTime;
  final int? shiftMinutes;

  const DateModifier(this.action, this.fields, {this.dateTime, this.shiftMinutes});
}
