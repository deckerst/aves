import 'package:aves/model/metadata/fields.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraDateFieldSource on DateFieldSource {
  String getText(BuildContext context) {
    switch (this) {
      case DateFieldSource.fileModifiedDate:
        return context.l10n.editEntryDateDialogSourceFileModifiedDate;
      case DateFieldSource.exifDate:
        return 'Exif date';
      case DateFieldSource.exifDateOriginal:
        return 'Exif original date';
      case DateFieldSource.exifDateDigitized:
        return 'Exif digitized date';
      case DateFieldSource.exifGpsDate:
        return 'Exif GPS date';
    }
  }

  MetadataField? toMetadataField() {
    switch (this) {
      case DateFieldSource.fileModifiedDate:
        return null;
      case DateFieldSource.exifDate:
        return MetadataField.exifDate;
      case DateFieldSource.exifDateOriginal:
        return MetadataField.exifDateOriginal;
      case DateFieldSource.exifDateDigitized:
        return MetadataField.exifDateDigitized;
      case DateFieldSource.exifGpsDate:
        return MetadataField.exifGpsDatestamp;
    }
  }
}
