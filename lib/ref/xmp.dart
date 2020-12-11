class XMP {
  static const propNamespaceSeparator = ':';
  static const structFieldSeparator = '/';

  // cf https://exiftool.org/TagNames/XMP.html
  static const Map<String, String> namespaces = {
    'adsml-at': 'AdsML',
    'aux': 'Exif Aux',
    'Camera': 'Camera',
    'creatorAtom': 'After Effects',
    'crs': 'Camera Raw Settings',
    'dc': 'Dublin Core',
    'drone-dji': 'DJI Drone',
    'exifEX': 'Exif Ex',
    'GettyImagesGIFT': 'Getty Images',
    'GIMP': 'GIMP',
    'GFocus': 'Google Focus',
    'GPano': 'Google Panorama',
    'illustrator': 'Illustrator',
    'lr': 'Lightroom',
    'MicrosoftPhoto': 'Microsoft Photo',
    'panorama': 'Panorama',
    'pdf': 'PDF',
    'pdfx': 'PDF/X',
    'PanoStudioXMP': 'PanoramaStudio',
    'photomechanic': 'Photo Mechanic',
    'plus': 'PLUS',
    'pmtm': 'Photomatix',
    'xmpBJ': 'Basic Job Ticket',
    'xmpDM': 'Dynamic Media',
    'xmpRights': 'Rights Management',
    'xmpTPg': 'Paged-Text',
  };
}
