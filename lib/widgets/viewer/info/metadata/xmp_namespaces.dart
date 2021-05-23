import 'package:aves/ref/brand_colors.dart';
import 'package:aves/ref/xmp.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/exif.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/google.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/iptc.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/mwg.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/photoshop.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/tiff.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/xmp.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XmpNamespace {
  final String namespace;
  final Map<String, String> rawProps;

  const XmpNamespace(this.namespace, this.rawProps);

  factory XmpNamespace.create(String namespace, Map<String, String> rawProps) {
    switch (namespace) {
      case XmpBasicNamespace.ns:
        return XmpBasicNamespace(rawProps);
      case XmpExifNamespace.ns:
        return XmpExifNamespace(rawProps);
      case XmpGAudioNamespace.ns:
        return XmpGAudioNamespace(rawProps);
      case XmpGCameraNamespace.ns:
        return XmpGCameraNamespace(rawProps);
      case XmpGDepthNamespace.ns:
        return XmpGDepthNamespace(rawProps);
      case XmpGImageNamespace.ns:
        return XmpGImageNamespace(rawProps);
      case XmpIptcCoreNamespace.ns:
        return XmpIptcCoreNamespace(rawProps);
      case XmpMgwRegionsNamespace.ns:
        return XmpMgwRegionsNamespace(rawProps);
      case XmpMMNamespace.ns:
        return XmpMMNamespace(rawProps);
      case XmpNoteNamespace.ns:
        return XmpNoteNamespace(rawProps);
      case XmpPhotoshopNamespace.ns:
        return XmpPhotoshopNamespace(rawProps);
      case XmpTiffNamespace.ns:
        return XmpTiffNamespace(rawProps);
      default:
        return XmpNamespace(namespace, rawProps);
    }
  }

  String get displayTitle => XMP.namespaces[namespace] ?? namespace;

  Map<String, String> get buildProps => rawProps;

  List<Widget> buildNamespaceSection() {
    final props = buildProps.entries
        .map((kv) {
          final prop = XmpProp(kv.key, kv.value);
          return extractData(prop) ? null : prop;
        })
        .where((v) => v != null)
        .cast<XmpProp>()
        .toList()
          ..sort((a, b) => compareAsciiUpperCaseNatural(a.displayKey, b.displayKey));

    final content = [
      if (props.isNotEmpty)
        InfoRowGroup(
          Map.fromEntries(props.map((prop) => MapEntry(prop.displayKey, formatValue(prop)))),
          maxValueLength: Constants.infoGroupMaxValueLength,
          linkHandlers: linkifyValues(props),
        ),
      ...buildFromExtractedData(),
    ];

    return content.isNotEmpty
        ? [
            if (displayTitle.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: HighlightTitle(
                  displayTitle,
                  color: BrandColors.get(displayTitle),
                  selectable: true,
                ),
              ),
            ...content
          ]
        : [];
  }

  bool extractStruct(XmpProp prop, RegExp pattern, Map<String, String> store) {
    final matches = pattern.allMatches(prop.path);
    if (matches.isEmpty) return false;

    final match = matches.first;
    final field = XmpProp.formatKey(match.group(1)!);
    store[field] = formatValue(prop);
    return true;
  }

  bool extractIndexedStruct(XmpProp prop, RegExp pattern, Map<int, Map<String, String>> store) {
    final matches = pattern.allMatches(prop.path);
    if (matches.isEmpty) return false;

    final match = matches.first;
    final index = int.parse(match.group(1)!);
    final field = XmpProp.formatKey(match.group(2)!);
    final fields = store.putIfAbsent(index, () => <String, String>{});
    fields[field] = formatValue(prop);
    return true;
  }

  bool extractData(XmpProp prop) => false;

  List<Widget> buildFromExtractedData() => [];

  String formatValue(XmpProp prop) => prop.value;

  Map<String, InfoLinkHandler> linkifyValues(List<XmpProp> props) => {};

  // identity

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is XmpNamespace && other.namespace == namespace;
  }

  @override
  int get hashCode => namespace.hashCode;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{namespace=$namespace}';
}

class XmpProp {
  final String path, value;
  final String displayKey;

  XmpProp(this.path, this.value) : displayKey = formatKey(path);

  static String formatKey(String propPath) {
    return propPath.splitMapJoin(XMP.structFieldSeparator,
        onMatch: (match) => ' ${match.group(0)} ',
        onNonMatch: (s) {
          // strip namespace & format
          return s.split(XMP.propNamespaceSeparator).last.toSentenceCase();
        });
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{path=$path, value=$value}';
}
