import 'package:aves_model/aves_model.dart';

extension ExtraDateFieldSourceConvert on DateFieldSource {
  MetadataField? toMetadataField() {
    switch (this) {
      case .fileModifiedDate:
        return null;
      case .exifDate:
        return MetadataField.exifDate;
      case .exifDateOriginal:
        return MetadataField.exifDateOriginal;
      case .exifDateDigitized:
        return MetadataField.exifDateDigitized;
      case .exifGpsDate:
        return MetadataField.exifGpsDatestamp;
    }
  }
}
