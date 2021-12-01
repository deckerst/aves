import 'dart:convert';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/iptc.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';

extension ExtraAvesEntryXmpIptc on AvesEntry {
  static const dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const rdfNamespace = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
  static const xNamespace = 'adobe:ns:meta/';
  static const xmpNamespace = 'http://ns.adobe.com/xap/1.0/';
  static const xmpNoteNamespace = 'http://ns.adobe.com/xmp/note/';

  static const xmlnsPrefix = 'xmlns';

  static final nsDefaultPrefixes = {
    dcNamespace: 'dc',
    rdfNamespace: 'rdf',
    xNamespace: 'x',
    xmpNamespace: 'xmp',
    xmpNoteNamespace: 'xmpNote',
  };

  // elements
  static const xXmpmeta = 'xmpmeta';
  static const rdfRoot = 'RDF';
  static const rdfDescription = 'Description';
  static const dcSubject = 'subject';

  // attributes
  static const xXmptk = 'xmptk';
  static const rdfAbout = 'about';
  static const xmpMetadataDate = 'MetadataDate';
  static const xmpModifyDate = 'ModifyDate';
  static const xmpNoteHasExtendedXMP = 'HasExtendedXMP';

  static String prefixOf(String ns) => nsDefaultPrefixes[ns] ?? '';

  Future<Set<EntryDataType>> editTags(Set<String> tags) async {
    final xmp = await metadataFetchService.getXmp(this);
    final extendedXmpString = xmp?.extendedXmpString;

    XmlDocument? xmpDoc;
    if (xmp != null) {
      final xmpString = xmp.xmpString;
      if (xmpString != null) {
        xmpDoc = XmlDocument.parse(xmpString);
      }
    }
    if (xmpDoc == null) {
      final toolkit = 'Aves v${(await PackageInfo.fromPlatform()).version}';
      final builder = XmlBuilder();
      builder.namespace(xNamespace, prefixOf(xNamespace));
      builder.element(xXmpmeta, namespace: xNamespace, namespaces: {
        xNamespace: prefixOf(xNamespace),
      }, attributes: {
        '${prefixOf(xNamespace)}:$xXmptk': toolkit,
      });
      xmpDoc = builder.buildDocument();
    }

    final root = xmpDoc.rootElement;
    XmlNode? rdf = root.getElement(rdfRoot, namespace: rdfNamespace);
    if (rdf == null) {
      final builder = XmlBuilder();
      builder.namespace(rdfNamespace, prefixOf(rdfNamespace));
      builder.element(rdfRoot, namespace: rdfNamespace, namespaces: {
        rdfNamespace: prefixOf(rdfNamespace),
      });
      // get element because doc fragment cannot be used to edit
      root.children.add(builder.buildFragment());
      rdf = root.getElement(rdfRoot, namespace: rdfNamespace)!;
    }

    XmlNode? description = rdf.getElement(rdfDescription, namespace: rdfNamespace);
    if (description == null) {
      final builder = XmlBuilder();
      builder.namespace(rdfNamespace, prefixOf(rdfNamespace));
      builder.element(rdfDescription, namespace: rdfNamespace, attributes: {
        '${prefixOf(rdfNamespace)}:$rdfAbout': '',
      });
      rdf.children.add(builder.buildFragment());
      // get element because doc fragment cannot be used to edit
      description = rdf.getElement(rdfDescription, namespace: rdfNamespace)!;
    }
    _setNamespaces(description, {
      dcNamespace: prefixOf(dcNamespace),
      xmpNamespace: prefixOf(xmpNamespace),
    });

    _setStringBag(description, dcSubject, tags, namespace: dcNamespace);

    if (_isMeaningfulXmp(rdf)) {
      final modifyDate = DateTime.now();
      description.setAttribute('${prefixOf(xmpNamespace)}:$xmpMetadataDate', _toXmpDate(modifyDate));
      description.setAttribute('${prefixOf(xmpNamespace)}:$xmpModifyDate', _toXmpDate(modifyDate));
    } else {
      // clear XMP if there are no attributes or elements worth preserving
      xmpDoc = null;
    }

    final editedXmp = AvesXmp(
      xmpString: xmpDoc?.toXmlString(),
      extendedXmpString: extendedXmpString,
    );

    if (canEditIptc) {
      final iptc = await metadataFetchService.getIptc(this);
      if (iptc != null) {
        await _setIptcKeywords(iptc, tags);
      }
    }

    final newFields = await metadataEditService.setXmp(this, editedXmp);
    return newFields.isEmpty ? {} : {EntryDataType.catalog};
  }

  Future<void> _setIptcKeywords(List<Map<String, dynamic>> iptc, Set<String> tags) async {
    iptc.removeWhere((v) => v['record'] == IPTC.applicationRecord && v['tag'] == IPTC.keywordsTag);
    iptc.add({
      'record': IPTC.applicationRecord,
      'tag': IPTC.keywordsTag,
      'values': tags.map((v) => utf8.encode(v)).toList(),
    });
    await metadataEditService.setIptc(this, iptc, postEditScan: false);
  }

  int _meaningfulChildrenCount(XmlNode node) => node.children.where((v) => v.nodeType != XmlNodeType.TEXT || v.text.trim().isNotEmpty).length;

  bool _isMeaningfulXmp(XmlNode rdf) {
    if (_meaningfulChildrenCount(rdf) > 1) return true;

    final description = rdf.getElement(rdfDescription, namespace: rdfNamespace);
    if (description == null) return true;

    if (_meaningfulChildrenCount(description) > 0) return true;

    final hasMeaningfulAttributes = description.attributes.any((v) {
      switch (v.name.local) {
        case rdfAbout:
          return v.value.isNotEmpty;
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
  String _xmpTimeZoneDesignator(DateTime date) {
    final offsetMinutes = date.timeZoneOffset.inMinutes;
    final abs = offsetMinutes.abs();
    final h = abs ~/ Duration.minutesPerHour;
    final m = abs % Duration.minutesPerHour;
    return '${offsetMinutes.isNegative ? '-' : '+'}${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _toXmpDate(DateTime date) => '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(date)}${_xmpTimeZoneDesignator(date)}';

  void _setNamespaces(XmlNode node, Map<String, String> namespaces) => namespaces.forEach((uri, prefix) => node.setAttribute('$xmlnsPrefix:$prefix', uri));

  void _setStringBag(XmlNode node, String name, Set<String> values, {required String namespace}) {
    // remove existing
    node.findElements(name, namespace: namespace).toSet().forEach(node.children.remove);

    if (values.isNotEmpty) {
      // add new bag
      final rootBuilder = XmlBuilder();
      rootBuilder.namespace(namespace, prefixOf(namespace));
      rootBuilder.element(name, namespace: namespace);
      node.children.add(rootBuilder.buildFragment());

      final bagBuilder = XmlBuilder();
      bagBuilder.namespace(rdfNamespace, prefixOf(rdfNamespace));
      bagBuilder.element('Bag', namespace: rdfNamespace, nest: () {
        values.forEach((v) {
          bagBuilder.element('li', namespace: rdfNamespace, nest: v);
        });
      });
      node.children.last.children.add(bagBuilder.buildFragment());
    }
  }
}

@immutable
class AvesXmp extends Equatable {
  final String? xmpString;
  final String? extendedXmpString;

  @override
  List<Object?> get props => [xmpString, extendedXmpString];

  const AvesXmp({
    required this.xmpString,
    this.extendedXmpString,
  });

  static AvesXmp? fromList(List<String> xmpStrings) {
    switch (xmpStrings.length) {
      case 0:
        return null;
      case 1:
        return AvesXmp(xmpString: xmpStrings.single);
      default:
        final byExtending = groupBy<String, bool>(xmpStrings, (v) => v.contains(':HasExtendedXMP='));
        final extending = byExtending[true] ?? [];
        final extension = byExtending[false] ?? [];
        if (extending.length == 1 && extension.length == 1) {
          return AvesXmp(
            xmpString: extending.single,
            extendedXmpString: extension.single,
          );
        }

        // take the first XMP and ignore the rest when the file is weirdly constructed
        debugPrint('warning: entry has ${xmpStrings.length} XMP directories, xmpStrings=$xmpStrings');
        return AvesXmp(xmpString: xmpStrings.firstOrNull);
    }
  }
}
