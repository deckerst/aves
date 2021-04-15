import 'package:aves/ref/brand_colors.dart';
import 'package:aves/ref/xmp.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XmpNamespace {
  final String namespace;

  const XmpNamespace(this.namespace);

  String get displayTitle => XMP.namespaces[namespace] ?? namespace;

  List<Widget> buildNamespaceSection({
    @required List<MapEntry<String, String>> rawProps,
  }) {
    final props = rawProps
        .map((kv) {
          final prop = XmpProp(kv.key, kv.value);
          return extractData(prop) ? null : prop;
        })
        .where((e) => e != null)
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
    final field = XmpProp.formatKey(match.group(1));
    store[field] = formatValue(prop);
    return true;
  }

  bool extractIndexedStruct(XmpProp prop, RegExp pattern, Map<int, Map<String, String>> store) {
    final matches = pattern.allMatches(prop.path);
    if (matches.isEmpty) return false;

    final match = matches.first;
    final index = int.parse(match.group(1));
    final field = XmpProp.formatKey(match.group(2));
    final fields = store.putIfAbsent(index, () => <String, String>{});
    fields[field] = formatValue(prop);
    return true;
  }

  bool extractData(XmpProp prop) => false;

  List<Widget> buildFromExtractedData() => [];

  String formatValue(XmpProp prop) => prop.value;

  Map<String, InfoLinkHandler> linkifyValues(List<XmpProp> props) => null;

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

enum EmbeddedDataSource { videoCover, xmp }

class OpenEmbeddedDataNotification extends Notification {
  final EmbeddedDataSource source;
  final String propPath;
  final String mimeType;

  const OpenEmbeddedDataNotification._private({
    @required this.source,
    this.propPath,
    this.mimeType,
  });

  factory OpenEmbeddedDataNotification.videoCover() => OpenEmbeddedDataNotification._private(
        source: EmbeddedDataSource.videoCover,
      );

  factory OpenEmbeddedDataNotification.xmp({
    @required String propPath,
    @required String mimeType,
  }) =>
      OpenEmbeddedDataNotification._private(
        source: EmbeddedDataSource.xmp,
        propPath: propPath,
        mimeType: mimeType,
      );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{source=$source, propPath=$propPath, mimeType=$mimeType}';
}
