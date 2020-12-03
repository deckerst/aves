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
    'exif': 'Exif',
    'exifEX': 'Exif Ex',
    'GettyImagesGIFT': 'Getty Images',
    'GIMP': 'GIMP',
    'GAudio': 'Google Audio',
    'GDepth': 'Google Depth',
    'GFocus': 'Google Focus',
    'GImage': 'Google Image',
    'GPano': 'Google Panorama',
    'illustrator': 'Illustrator',
    'Iptc4xmpCore': 'IPTC Core',
    'lr': 'Lightroom',
    'MicrosoftPhoto': 'Microsoft Photo',
    'panorama': 'Panorama',
    'pdf': 'PDF',
    'pdfx': 'PDF/X',
    'PanoStudioXMP': 'PanoramaStudio',
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

  // TODO TLAD 'xmp:Thumbnails[\d]/Image'
  static const dataProps = [
    'GAudio:Data',
    'GDepth:Data',
    'GImage:Data',
  ];
}
