import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class Namespaces {
  static const acdsee = 'http://ns.acdsee.com/iptc/1.0/';
  static const adsmlat = 'http://adsml.org/xmlns/';
  static const avm = 'http://www.communicatingastronomy.org/avm/1.0/';
  static const camera = 'http://pix4d.com/camera/1.0/';
  static const cc = 'http://creativecommons.org/ns#';
  static const container = 'http://ns.google.com/photos/1.0/container/';
  static const creatorAtom = 'http://ns.adobe.com/creatorAtom/1.0/';
  static const crd = 'http://ns.adobe.com/camera-raw-defaults/1.0/';
  static const crlcp = 'http://ns.adobe.com/camera-raw-embedded-lens-profile/1.0/';
  static const crs = 'http://ns.adobe.com/camera-raw-settings/1.0/';
  static const crss = 'http://ns.adobe.com/camera-raw-saved-settings/1.0/';
  static const darktable = 'http://darktable.sf.net/';
  static const dc = 'http://purl.org/dc/elements/1.1/';
  static const dcterms = 'http://purl.org/dc/terms/';
  static const dicom = 'http://ns.adobe.com/DICOM/';
  static const digiKam = 'http://www.digikam.org/ns/1.0/';
  static const droneDji = 'http://www.dji.com/drone-dji/1.0/';
  static const dwc = 'http://rs.tdwg.org/dwc/index.htm';
  static const dwciri = 'http://rs.tdwg.org/dwc/iri/';
  static const exif = 'http://ns.adobe.com/exif/1.0/';
  static const exifAux = 'http://ns.adobe.com/exif/1.0/aux/';
  static const exifEx = 'http://cipa.jp/exif/1.0/';
  static const gAudio = 'http://ns.google.com/photos/1.0/audio/';
  static const gCamera = 'http://ns.google.com/photos/1.0/camera/';
  static const gCreations = 'http://ns.google.com/photos/1.0/creations/';
  static const gDepth = 'http://ns.google.com/photos/1.0/depthmap/';
  static const gDevice = 'http://ns.google.com/photos/dd/1.0/device/';
  static const gFocus = 'http://ns.google.com/photos/1.0/focus/';
  static const gImage = 'http://ns.google.com/photos/1.0/image/';
  static const gPano = 'http://ns.google.com/photos/1.0/panorama/';
  static const gSpherical = 'http://ns.google.com/videos/1.0/spherical/';
  static const gettyImagesGift = 'http://xmp.gettyimages.com/gift/1.0/';
  static const gimp210 = 'http://www.gimp.org/ns/2.10/';
  static const gimpXmp = 'http://www.gimp.org/xmp/';
  static const illustrator = 'http://ns.adobe.com/illustrator/1.0/';
  static const iptc4xmpCore = 'http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/';
  static const iptc4xmpExt = 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/';
  static const lr = 'http://ns.adobe.com/lightroom/1.0/';
  static const mediapro = 'http://ns.iview-multimedia.com/mediapro/1.0/';

  // also seen in the wild for prefix `MicrosoftPhoto`: 'http://ns.microsoft.com/photo/1.0'
  static const microsoftPhoto = 'http://ns.microsoft.com/photo/1.0/';
  static const mp1 = 'http://ns.microsoft.com/photo/1.1';
  static const mp = 'http://ns.microsoft.com/photo/1.2/';
  static const mpri = 'http://ns.microsoft.com/photo/1.2/t/RegionInfo#';
  static const mpreg = 'http://ns.microsoft.com/photo/1.2/t/Region#';
  static const mwgrs = 'http://www.metadataworkinggroup.com/schemas/regions/';
  static const nga = 'https://standards.nga.gov/metadata/media/image/artobject/1.0';
  static const opMedia = 'http://ns.oneplus.com/media/1.0/';
  static const panorama = 'http://ns.adobe.com/photoshop/1.0/panorama-profile';
  static const panoStudio = 'http://www.tshsoft.com/xmlns';
  static const pdf = 'http://ns.adobe.com/pdf/1.3/';
  static const pdfX = 'http://ns.adobe.com/pdfx/1.3/';
  static const photoMechanic = 'http://ns.camerabits.com/photomechanic/1.0/';
  static const photoshop = 'http://ns.adobe.com/photoshop/1.0/';
  static const plus = 'http://ns.useplus.org/ldf/xmp/1.0/';
  static const pmtm = 'http://www.hdrsoft.com/photomatix_settings01';
  static const rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
  static const stCamera = 'http://ns.adobe.com/photoshop/1.0/camera-profile';
  static const stEvt = 'http://ns.adobe.com/xap/1.0/sType/ResourceEvent#';
  static const stRef = 'http://ns.adobe.com/xap/1.0/sType/ResourceRef#';
  static const tiff = 'http://ns.adobe.com/tiff/1.0/';
  static const x = 'adobe:ns:meta/';
  static const xmp = 'http://ns.adobe.com/xap/1.0/';
  static const xmpBJ = 'http://ns.adobe.com/xap/1.0/bj/';
  static const xmpDM = 'http://ns.adobe.com/xmp/1.0/DynamicMedia/';
  static const xmpGImg = 'http://ns.adobe.com/xap/1.0/g/img/';
  static const xmpMM = 'http://ns.adobe.com/xap/1.0/mm/';
  static const xmpNote = 'http://ns.adobe.com/xmp/note/';
  static const xmpRights = 'http://ns.adobe.com/xap/1.0/rights/';
  static const xmpTPg = 'http://ns.adobe.com/xap/1.0/t/pg/';

  // cf https://exiftool.org/TagNames/XMP.html
  static const Map<String, String> nsTitles = {
    acdsee: 'ACDSee',
    adsmlat: 'AdsML',
    exifAux: 'Exif Aux',
    avm: 'Astronomy Visualization',
    camera: 'Pix4D Camera',
    cc: 'Creative Commons',
    container: 'Container',
    crd: 'Camera Raw Defaults',
    creatorAtom: 'After Effects',
    crs: 'Camera Raw Settings',
    crss: 'Camera Raw Saved Settings',
    darktable: 'darktable',
    dc: 'Dublin Core',
    digiKam: 'digiKam',
    droneDji: 'DJI Drone',
    dwc: 'Darwin Core',
    exif: 'Exif',
    exifEx: 'Exif Ex',
    gAudio: 'Google Audio',
    gCamera: 'Google Camera',
    gCreations: 'Google Creations',
    gDepth: 'Google Depth',
    gDevice: 'Google Device',
    gFocus: 'Google Focus',
    gImage: 'Google Image',
    gPano: 'Google Panorama',
    gSpherical: 'Google Spherical',
    gettyImagesGift: 'Getty Images',
    gimp210: 'GIMP 2.10',
    gimpXmp: 'GIMP',
    illustrator: 'Illustrator',
    iptc4xmpCore: 'IPTC Core',
    iptc4xmpExt: 'IPTC Extension',
    lr: 'Lightroom',
    mediapro: 'MediaPro',
    microsoftPhoto: 'Microsoft Photo 1.0',
    mp1: 'Microsoft Photo 1.1',
    mp: 'Microsoft Photo 1.2',
    mwgrs: 'Regions',
    nga: 'National Gallery of Art',
    opMedia: 'OnePlus Media',
    panorama: 'Panorama',
    panoStudio: 'PanoramaStudio',
    pdf: 'PDF',
    pdfX: 'PDF/X',
    photoMechanic: 'Photo Mechanic',
    photoshop: 'Photoshop',
    plus: 'PLUS',
    pmtm: 'Photomatix',
    tiff: 'TIFF',
    xmp: 'Basic',
    xmpBJ: 'Basic Job Ticket',
    xmpDM: 'Dynamic Media',
    xmpMM: 'Media Management',
    xmpNote: 'Note',
    xmpRights: 'Rights Management',
    xmpTPg: 'Paged-Text',
  };

  static final defaultPrefixes = {
    container: 'Container',
    dc: 'dc',
    gCamera: 'GCamera',
    microsoftPhoto: 'MicrosoftPhoto',
    rdf: 'rdf',
    x: 'x',
    xmp: 'xmp',
    xmpGImg: 'xmpGImg',
    xmpNote: 'xmpNote',
  };
}

class XMP {
  static const xmlnsPrefix = 'xmlns';
  static const propNamespaceSeparator = ':';
  static const structFieldSeparator = '/';

  static String prefixOf(String ns) => Namespaces.defaultPrefixes[ns] ?? '';

  // elements
  static const xXmpmeta = 'xmpmeta';
  static const rdfRoot = 'RDF';
  static const rdfDescription = 'Description';
  static const containerDirectory = 'Directory';
  static const dcDescription = 'description';
  static const dcSubject = 'subject';
  static const dcTitle = 'title';
  static const msPhotoRating = 'Rating';
  static const xmpRating = 'Rating';

  // attributes
  static const xXmptk = 'xmptk';
  static const rdfAbout = 'about';
  static const gCameraMicroVideo = 'MicroVideo';
  static const gCameraMicroVideoVersion = 'MicroVideoVersion';
  static const gCameraMicroVideoOffset = 'MicroVideoOffset';
  static const gCameraMicroVideoPresentationTimestampUs = 'MicroVideoPresentationTimestampUs';
  static const gCameraMotionPhoto = 'MotionPhoto';
  static const gCameraMotionPhotoVersion = 'MotionPhotoVersion';
  static const gCameraMotionPhotoPresentationTimestampUs = 'MotionPhotoPresentationTimestampUs';
  static const xmpCreateDate = 'CreateDate';
  static const xmpMetadataDate = 'MetadataDate';
  static const xmpModifyDate = 'ModifyDate';
  static const xmpNoteHasExtendedXMP = 'HasExtendedXMP';

  // for `rdf:Description` node only
  static bool _hasMeaningfulChildren(XmlNode node) => node.children.any((v) => v.nodeType != XmlNodeType.TEXT || v.text.trim().isNotEmpty);

  // for `rdf:Description` node only
  static bool _hasMeaningfulAttributes(XmlNode description) {
    final hasMeaningfulAttributes = description.attributes.any((v) {
      switch (v.name.local) {
        case rdfAbout:
        case xmpMetadataDate:
        case xmpModifyDate:
          return false;
        default:
          switch (v.name.prefix) {
            case xmlnsPrefix:
              return false;
            default:
              // if the attribute got defined with the prefix as part of the name,
              // the prefix is not recognized as such, so we check the full name
              return !v.name.qualified.startsWith(xmlnsPrefix);
          }
      }
    });
    return hasMeaningfulAttributes;
  }

  // return time zone designator, formatted as `Z` or `+hh:mm` or `-hh:mm`
  // as of intl v0.17.0, formatting time zone offset is not implemented
  static String _xmpTimeZoneDesignator(DateTime date) {
    final offsetMinutes = date.timeZoneOffset.inMinutes;
    final abs = offsetMinutes.abs();
    final h = abs ~/ Duration.minutesPerHour;
    final m = abs % Duration.minutesPerHour;
    return '${offsetMinutes.isNegative ? '-' : '+'}${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static String toXmpDate(DateTime date) => '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(date)}${_xmpTimeZoneDesignator(date)}';

  static String? getString(
    List<XmlNode> nodes,
    String name, {
    required String namespace,
  }) {
    for (final node in nodes) {
      final attribute = node.getAttribute(name, namespace: namespace);
      if (attribute != null) return attribute;

      final element = node.getElement(name, namespace: namespace);
      if (element != null) return element.innerText;
    }
    return null;
  }

  static void _addNamespaces(XmlNode node, Map<String, String> namespaces) => namespaces.forEach((uri, prefix) => node.setAttribute('$xmlnsPrefix:$prefix', uri));

  // remove elements and attributes
  static bool removeElements(List<XmlNode> nodes, String name, String namespace) {
    var removed = false;
    nodes.forEach((node) {
      final elements = node.findElements(name, namespace: namespace).toSet();
      if (elements.isNotEmpty) {
        elements.forEach(node.children.remove);
        removed = true;
      }

      if (node.getAttributeNode(name, namespace: namespace) != null) {
        node.removeAttribute(name, namespace: namespace);
        removed = true;
      }
    });
    return removed;
  }

  // remove attribute/element from all nodes, and set attribute with new value, if any, in the first node
  static bool setAttribute(
    List<XmlNode> nodes,
    String name,
    String? value, {
    required String namespace,
    required XmpEditStrategy strat,
  }) {
    final removed = removeElements(nodes, name, namespace);

    if (value == null) return removed;

    bool modified = removed;
    if (strat == XmpEditStrategy.always || (strat == XmpEditStrategy.updateIfPresent && removed)) {
      final node = nodes.first;
      _addNamespaces(node, {namespace: prefixOf(namespace)});

      // use qualified name, otherwise the namespace prefix is not added
      final qualifiedName = '${prefixOf(namespace)}$propNamespaceSeparator$name';
      node.setAttribute(qualifiedName, value);
      modified = true;
    }

    return modified;
  }

  // remove attribute/element from all nodes, and create element with new value, if any, in the first node
  static void setElement(
    List<XmlNode> nodes,
    String name,
    String? value, {
    required String namespace,
    required XmpEditStrategy strat,
  }) {
    final removed = removeElements(nodes, name, namespace);

    if (value == null) return;

    if (strat == XmpEditStrategy.always || (strat == XmpEditStrategy.updateIfPresent && removed)) {
      final node = nodes.first;
      _addNamespaces(node, {namespace: prefixOf(namespace)});

      final builder = XmlBuilder();
      builder.namespace(namespace, prefixOf(namespace));
      builder.element(name, namespace: namespace, nest: () {
        builder.text(value);
      });
      node.children.add(builder.buildFragment());
    }
  }

  // remove bag from all nodes, and create bag with new values, if any, in the first node
  static bool setStringBag(
    List<XmlNode> nodes,
    String name,
    Set<String> values, {
    required String namespace,
    required XmpEditStrategy strat,
  }) {
    // remove existing
    final removed = removeElements(nodes, name, namespace);

    if (values.isEmpty) return removed;

    bool modified = removed;
    if (strat == XmpEditStrategy.always || (strat == XmpEditStrategy.updateIfPresent && removed)) {
      final node = nodes.first;
      _addNamespaces(node, {namespace: prefixOf(namespace)});

      // add new bag
      final rootBuilder = XmlBuilder();
      rootBuilder.namespace(namespace, prefixOf(namespace));
      rootBuilder.element(name, namespace: namespace);
      node.children.add(rootBuilder.buildFragment());

      final bagBuilder = XmlBuilder();
      bagBuilder.namespace(Namespaces.rdf, prefixOf(Namespaces.rdf));
      bagBuilder.element('Bag', namespace: Namespaces.rdf, nest: () {
        values.forEach((v) {
          bagBuilder.element('li', namespace: Namespaces.rdf, nest: v);
        });
      });
      node.children.last.children.add(bagBuilder.buildFragment());
      modified = true;
    }

    return modified;
  }

  static Future<String?> edit(
    String? xmpString,
    Future<String> Function() toolkit,
    bool Function(List<XmlNode> descriptions) apply, {
    DateTime? modifyDate,
  }) async {
    XmlDocument? xmpDoc;
    if (xmpString != null) {
      xmpDoc = XmlDocument.parse(xmpString);
    }
    if (xmpDoc == null) {
      final builder = XmlBuilder();
      builder.namespace(Namespaces.x, prefixOf(Namespaces.x));
      builder.element(xXmpmeta, namespace: Namespaces.x, namespaces: {
        Namespaces.x: prefixOf(Namespaces.x),
      }, attributes: {
        '${prefixOf(Namespaces.x)}$propNamespaceSeparator$xXmptk': await toolkit(),
      });
      xmpDoc = builder.buildDocument();
    }

    final root = xmpDoc.rootElement;
    XmlNode? rdf = root.getElement(rdfRoot, namespace: Namespaces.rdf);
    if (rdf == null) {
      final builder = XmlBuilder();
      builder.namespace(Namespaces.rdf, prefixOf(Namespaces.rdf));
      builder.element(rdfRoot, namespace: Namespaces.rdf, namespaces: {
        Namespaces.rdf: prefixOf(Namespaces.rdf),
      });
      // get element because doc fragment cannot be used to edit
      root.children.add(builder.buildFragment());
      rdf = root.getElement(rdfRoot, namespace: Namespaces.rdf)!;
    }

    // content can be split in multiple `rdf:Description` elements
    List<XmlNode> descriptions = rdf.children.where((node) {
      return node is XmlElement && node.name.local == rdfDescription && node.name.namespaceUri == Namespaces.rdf;
    }).toList();

    if (descriptions.isEmpty) {
      final builder = XmlBuilder();
      builder.namespace(Namespaces.rdf, prefixOf(Namespaces.rdf));
      builder.element(rdfDescription, namespace: Namespaces.rdf, attributes: {
        '${prefixOf(Namespaces.rdf)}$propNamespaceSeparator$rdfAbout': '',
      });
      rdf.children.add(builder.buildFragment());
      // get element because doc fragment cannot be used to edit
      descriptions.add(rdf.getElement(rdfDescription, namespace: Namespaces.rdf)!);
    }
    final modified = apply(descriptions);

    // clean description nodes with no children
    descriptions.where((v) => !_hasMeaningfulChildren(v)).forEach((v) => v.children.clear());

    // remove superfluous description nodes
    rdf.children.removeWhere((v) => !_hasMeaningfulChildren(v) && !_hasMeaningfulAttributes(v));

    if (rdf.children.isNotEmpty) {
      if (modified) {
        _addNamespaces(descriptions.first, {Namespaces.xmp: prefixOf(Namespaces.xmp)});
        final xmpDate = toXmpDate(modifyDate ?? DateTime.now());
        setAttribute(descriptions, xmpMetadataDate, xmpDate, namespace: Namespaces.xmp, strat: XmpEditStrategy.always);
        setAttribute(descriptions, xmpModifyDate, xmpDate, namespace: Namespaces.xmp, strat: XmpEditStrategy.always);
      }
    } else {
      // clear XMP if there are no attributes or elements worth preserving
      xmpDoc = null;
    }

    return xmpDoc?.toXmlString();
  }

  static String? toMsPhotoRating(int? rating) {
    if (rating == null) return null;
    switch (rating) {
      case 5:
        return '99';
      case 4:
        return '75';
      case 3:
        return '50';
      case 2:
        return '25';
      case 1:
        return '1';
      case 0:
        return null;
      case -1:
        return '-1';
    }
    return null;
  }
}

enum XmpEditStrategy { always, updateIfPresent }
