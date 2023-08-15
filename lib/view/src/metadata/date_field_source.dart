import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraDateFieldSourceView on DateFieldSource {
  String getText(BuildContext context) {
    return switch (this) {
      DateFieldSource.fileModifiedDate => context.l10n.editEntryDateDialogSourceFileModifiedDate,
      DateFieldSource.exifDate => 'Exif date',
      DateFieldSource.exifDateOriginal => 'Exif original date',
      DateFieldSource.exifDateDigitized => 'Exif digitized date',
      DateFieldSource.exifGpsDate => 'Exif GPS date',
    };
  }
}
