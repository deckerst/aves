import 'package:aves/ref/locales.dart';
import 'package:aves/ref/metadata/xmp.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class XMP {
  static const xmlnsPrefix = 'xmlns';
  static const propNamespaceSeparator = ':';
  static const structFieldSeparator = '/';

  static final _defaultPrefixes = {
    XmpNamespaces.gContainer: 'Container',
    XmpNamespaces.dc: 'dc',
    XmpNamespaces.gCamera: 'GCamera',
    XmpNamespaces.microsoftPhoto: 'MicrosoftPhoto',
    XmpNamespaces.rdf: 'rdf',
    XmpNamespaces.x: 'x',
    XmpNamespaces.xmp: 'xmp',
    XmpNamespaces.xmpGImg: 'xmpGImg',
    XmpNamespaces.xmpNote: 'xmpNote',
  };

  static String prefixOf(String ns) => _defaultPrefixes[ns] ?? '';

  static const nsRdf = XmpNamespaces.rdf;
  static const nsX = XmpNamespaces.x;
  static const nsXmp = XmpNamespaces.xmp;

  // for `rdf:Description` node only
  static bool _hasMeaningfulChildren(XmlNode node) => node.children.any((v) => v.nodeType != XmlNodeType.TEXT || v.innerText.trim().isNotEmpty);

  // for `rdf:Description` node only
  static bool _hasMeaningfulAttributes(XmlNode description) {
    final hasMeaningfulAttributes = description.attributes.any((v) {
      switch (v.name.local) {
        case XmpAttributes.rdfAbout:
        case XmpAttributes.xmpMetadataDate:
        case XmpAttributes.xmpModifyDate:
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

  // returns time zone designator, formatted as `Z` or `+hh:mm` or `-hh:mm`
  // as of intl v0.17.0, formatting time zone offset is not implemented
  static String _xmpTimeZoneDesignator(DateTime date) {
    final offsetMinutes = date.timeZoneOffset.inMinutes;
    final abs = offsetMinutes.abs();
    final h = abs ~/ Duration.minutesPerHour;
    final m = abs % Duration.minutesPerHour;
    return '${offsetMinutes.isNegative ? '-' : '+'}${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static String toXmpDate(DateTime date) => '${DateFormat('yyyy-MM-ddTHH:mm:ss', asciiLocale).format(date)}${_xmpTimeZoneDesignator(date)}';

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
      bagBuilder.namespace(nsRdf, prefixOf(nsRdf));
      bagBuilder.element('Bag', namespace: nsRdf, nest: () {
        values.forEach((v) {
          bagBuilder.element('li', namespace: nsRdf, nest: v);
        });
      });
      node.children.last.children.add(bagBuilder.buildFragment());
      modified = true;
    }

    return modified;
  }

  static Future<String?> edit(
    String? xmpString,
    String toolkit,
    bool Function(List<XmlNode> descriptions) apply, {
    DateTime? modifyDate,
  }) async {
    XmlDocument? xmpDoc;
    if (xmpString != null) {
      xmpDoc = XmlDocument.parse(xmpString);
    }
    if (xmpDoc == null) {
      final builder = XmlBuilder();
      builder.namespace(nsX, prefixOf(nsX));
      builder.element(XmpElements.xXmpmeta, namespace: nsX, namespaces: {
        nsX: prefixOf(nsX),
      }, attributes: {
        '${prefixOf(nsX)}$propNamespaceSeparator${XmpAttributes.xXmptk}': toolkit,
      });
      xmpDoc = builder.buildDocument();
    }

    final root = xmpDoc.rootElement;
    XmlNode? rdf = root.getElement(XmpElements.rdfRoot, namespace: nsRdf);
    if (rdf == null) {
      final builder = XmlBuilder();
      builder.namespace(nsRdf, prefixOf(nsRdf));
      builder.element(XmpElements.rdfRoot, namespace: nsRdf, namespaces: {
        nsRdf: prefixOf(nsRdf),
      });
      // get element because doc fragment cannot be used to edit
      root.children.add(builder.buildFragment());
      rdf = root.getElement(XmpElements.rdfRoot, namespace: nsRdf)!;
    }

    // content can be split in multiple `rdf:Description` elements
    List<XmlNode> descriptions = rdf.children.where((node) {
      return node is XmlElement && node.name.local == XmpElements.rdfDescription && node.name.namespaceUri == nsRdf;
    }).toList();

    if (descriptions.isEmpty) {
      final builder = XmlBuilder();
      builder.namespace(nsRdf, prefixOf(nsRdf));
      builder.element(XmpElements.rdfDescription, namespace: nsRdf, attributes: {
        '${prefixOf(nsRdf)}$propNamespaceSeparator${XmpAttributes.rdfAbout}': '',
      });
      rdf.children.add(builder.buildFragment());
      // get element because doc fragment cannot be used to edit
      descriptions.add(rdf.getElement(XmpElements.rdfDescription, namespace: nsRdf)!);
    }
    final modified = apply(descriptions);

    // clean description nodes with no children
    descriptions.where((v) => !_hasMeaningfulChildren(v)).forEach((v) => v.children.clear());

    // remove superfluous description nodes
    rdf.children.removeWhere((v) => !_hasMeaningfulChildren(v) && !_hasMeaningfulAttributes(v));

    if (rdf.children.isNotEmpty) {
      if (modified) {
        _addNamespaces(descriptions.first, {nsXmp: prefixOf(nsXmp)});
        final xmpDate = toXmpDate(modifyDate ?? DateTime.now());
        setAttribute(descriptions, XmpAttributes.xmpMetadataDate, xmpDate, namespace: nsXmp, strat: XmpEditStrategy.always);
        setAttribute(descriptions, XmpAttributes.xmpModifyDate, xmpDate, namespace: nsXmp, strat: XmpEditStrategy.always);
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
