import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraDateFieldSourceView on DateFieldSource {
  String getText(BuildContext context) {
    return switch (this) {
      .fileModifiedDate => context.l10n.editEntryDateDialogSourceFileModifiedDate,
      .exifDate => 'Exif date',
      .exifDateOriginal => 'Exif original date',
      .exifDateDigitized => 'Exif digitized date',
      .exifGpsDate => 'Exif GPS date',
    };
  }
}
