class XMP {
  static const namespaceSeparator = ':';
  static const structFieldSeparator = '/';

  // cf https://exiftool.org/TagNames/XMP.html
  static const Map<String, String> namespaces = {
    'aux': 'Auxiliary Exif',
    'Camera': 'Camera',
    'crs': 'Camera Raw Settings',
    'dc': 'Dublin Core',
    'exif': 'Exif',
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
    'tiff': 'TIFF',
    'xmp': 'Basic',
    'xmpBJ': 'Basic Job Ticket',
    'xmpDM': 'Dynamic Media',
    'xmpMM': 'Media Management',
    'xmpRights': 'Rights Management',
    'xmpTPg': 'Paged-Text',
  };
}
