import 'package:aves_model/aves_model.dart';

extension ExtraDateFieldSourceConvert on DateFieldSource {
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
