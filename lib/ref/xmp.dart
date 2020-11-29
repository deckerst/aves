class XMP {
  static const namespaceSeparator = ':';
  static const structFieldSeparator = '/';

  // cf https://exiftool.org/TagNames/XMP.html
  static const Map<String, String> namespaces = {
    'aux': 'Exif Aux',
    'Camera': 'Camera',
    'crs': 'Camera Raw Settings',
    'dc': 'Dublin Core',
    'exif': 'Exif',
    'exifEX': 'Exif Ex',
    'GettyImagesGIFT': 'Getty Images',
    'GIMP': 'GIMP',
    'illustrator': 'Illustrator',
    'Iptc4xmpCore': 'IPTC Core',
    'lr': 'Lightroom',
    'MicrosoftPhoto': 'Microsoft Photo',
    'panorama': 'Panorama',
    'pdf': 'PDF',
    'pdfx': 'PDF/X',
    'photomechanic': 'Photo Mechanic',
    'photoshop': 'Photoshop',
    'plus': 'PLUS',
    'tiff': 'TIFF',
    'xmp': 'Basic',
    'xmpBJ': 'Basic Job Ticket',
    'xmpDM': 'Dynamic Media',
    'xmpMM': 'Media Management',
    'xmpRights': 'Rights Management',
    'xmpTPg': 'Paged-Text',
  };
}
