import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraDateFieldSourceView on DateFieldSource {
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
}
