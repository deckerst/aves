import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class Namespaces {
  static const dc = 'http://purl.org/dc/elements/1.1/';
  static const microsoftPhoto = 'http://ns.microsoft.com/photo/1.0/';
  static const rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
  static const x = 'adobe:ns:meta/';
  static const xmp = 'http://ns.adobe.com/xap/1.0/';
  static const xmpNote = 'http://ns.adobe.com/xmp/note/';

  static final defaultPrefixes = {
    dc: 'dc',
    microsoftPhoto: 'MicrosoftPhoto',
    rdf: 'rdf',
    x: 'x',
    xmp: 'xmp',
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
  static const dcSubject = 'subject';
  static const msPhotoRating = 'Rating';
  static const xmpRating = 'Rating';

  // attributes
  static const xXmptk = 'xmptk';
  static const rdfAbout = 'about';
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
  static bool _removeElements(List<XmlNode> nodes, String name, String namespace) {
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
  static void setAttribute(
    List<XmlNode> nodes,
    String name,
    String? value, {
    required String namespace,
    required XmpEditStrategy strat,
  }) {
    final removed = _removeElements(nodes, name, namespace);

    if (value == null) return;

    if (strat == XmpEditStrategy.always || (strat == XmpEditStrategy.updateIfPresent && removed)) {
      final node = nodes.first;
      _addNamespaces(node, {namespace: prefixOf(namespace)});

      // use qualified name, otherwise the namespace prefix is not added
      final qualifiedName = '${prefixOf(namespace)}$propNamespaceSeparator$name';
      node.setAttribute(qualifiedName, value);
    }
  }

  // remove attribute/element from all nodes, and create element with new value, if any, in the first node
  static void setElement(
    List<XmlNode> nodes,
    String name,
    String? value, {
    required String namespace,
    required XmpEditStrategy strat,
  }) {
    final removed = _removeElements(nodes, name, namespace);

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
  static void setStringBag(
    List<XmlNode> nodes,
    String name,
    Set<String> values, {
    required String namespace,
    required XmpEditStrategy strat,
  }) {
    // remove existing
    final removed = _removeElements(nodes, name, namespace);

    if (values.isEmpty) return;

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
    }
  }

  static Future<String?> edit(
    String? xmpString,
    Future<String> Function() toolkit,
    void Function(List<XmlNode> descriptions) apply, {
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
    apply(descriptions);

    // clean description nodes with no children
    descriptions.where((v) => !_hasMeaningfulChildren(v)).forEach((v) => v.children.clear());

    // remove superfluous description nodes
    rdf.children.removeWhere((v) => !_hasMeaningfulChildren(v) && !_hasMeaningfulAttributes(v));

    if (rdf.children.isNotEmpty) {
      _addNamespaces(descriptions.first, {Namespaces.xmp: prefixOf(Namespaces.xmp)});
      final xmpDate = toXmpDate(modifyDate ?? DateTime.now());
      setAttribute(descriptions, xmpMetadataDate, xmpDate, namespace: Namespaces.xmp, strat: XmpEditStrategy.always);
      setAttribute(descriptions, xmpModifyDate, xmpDate, namespace: Namespaces.xmp, strat: XmpEditStrategy.always);
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
  }
}

enum XmpEditStrategy { always, updateIfPresent }
