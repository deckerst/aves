enum DateEditAction {
  setCustom,
  copyField,
  copyItem,
  extractFromTitle,
  shift,
  remove,
}

enum DateFieldSource {
  fileModifiedDate,
  exifDate,
  exifDateOriginal,
  exifDateDigitized,
  exifGpsDate,
}

enum LengthUnit { px, percent }

enum LocationEditAction {
  chooseOnMap,
  copyItem,
  setCustom,
  remove,
}

enum MetadataType {
  // JPEG COM marker or GIF comment
  comment,
  // Exif: https://en.wikipedia.org/wiki/Exif
  exif,
  // ICC profile: https://en.wikipedia.org/wiki/ICC_profile
  iccProfile,
  // IPTC: https://en.wikipedia.org/wiki/IPTC_Information_Interchange_Model
  iptc,
  // JPEG APP0 / JFIF: https://en.wikipedia.org/wiki/JPEG_File_Interchange_Format
  jfif,
  // JPEG APP14 / Adobe: https://www.exiftool.org/TagNames/JPEG.html#Adobe
  jpegAdobe,
  // JPEG APP12 / Ducky: https://www.exiftool.org/TagNames/APP12.html#Ducky
  jpegDucky,
  // ISO User Data box content, etc.
  mp4,
  // Photoshop IRB: https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/
  photoshopIrb,
  // XMP: https://en.wikipedia.org/wiki/Extensible_Metadata_Platform
  xmp,
}

class MetadataTypes {
  static const main = {
    MetadataType.exif,
    MetadataType.xmp,
  };

  static const common = {
    MetadataType.exif,
    MetadataType.xmp,
    MetadataType.comment,
    MetadataType.iccProfile,
    MetadataType.iptc,
    MetadataType.photoshopIrb,
  };

  static const jpeg = {
    MetadataType.jfif,
    MetadataType.jpegAdobe,
    MetadataType.jpegDucky,
  };
}
