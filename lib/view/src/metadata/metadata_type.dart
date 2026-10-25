import 'package:aves_model/aves_model.dart';

extension ExtraMetadataTypeView on MetadataType {
  // match `metadata-extractor` directory names
  String getText() {
    return switch (this) {
      .comment => 'Comment',
      .exif => 'Exif',
      .iccProfile => 'ICC Profile',
      .iptc => 'IPTC',
      .jfif => 'JFIF',
      .jpegAdobe => 'Adobe JPEG',
      .jpegDucky => 'Ducky',
      .mp4 => 'MP4',
      .photoshopIrb => 'Photoshop',
      .xmp => 'XMP',
      .file => 'File',
    };
  }
}
