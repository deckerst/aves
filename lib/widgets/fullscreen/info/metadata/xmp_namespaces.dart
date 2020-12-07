import 'package:aves/ref/brand_colors.dart';
import 'package:aves/ref/xmp.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:aves/widgets/fullscreen/info/metadata/xmp_structs.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XmpNamespace {
  final String namespace;

  const XmpNamespace(this.namespace);

  String get displayTitle => XMP.namespaces[namespace] ?? namespace;

  List<Widget> buildNamespaceSection({
    @required List<MapEntry<String, String>> props,
    @required void Function(String propPath) openEmbeddedData,
  }) {
    final linkHandlers = <String, InfoLinkHandler>{};

    final entries = props
        .map((prop) {
          final propPath = prop.key;
          final value = formatValue(prop.value);
          if (extractData(propPath, value)) return null;

          final displayKey = _formatKey(propPath);
          if (XMP.dataProps.contains(propPath)) {
            linkHandlers.putIfAbsent(
              displayKey,
              () => InfoLinkHandler(linkText: 'Open', onTap: () => openEmbeddedData(propPath)),
            );
          }
          return MapEntry(displayKey, value);
        })
        .where((e) => e != null)
        .toList()
          ..sort((a, b) => compareAsciiUpperCaseNatural(a.key, b.key));

    final content = [
      if (entries.isNotEmpty)
        InfoRowGroup(
          Map.fromEntries(entries),
          maxValueLength: Constants.infoGroupMaxValueLength,
          linkHandlers: linkHandlers,
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

  String _formatKey(String propPath) {
    return propPath.splitMapJoin(XMP.structFieldSeparator, onNonMatch: (s) {
      // strip namespace
      final key = s.split(XMP.propNamespaceSeparator).last;
      // uppercase first letter
      return key.replaceFirstMapped(RegExp('.'), (m) => m.group(0).toUpperCase());
    });
  }

  bool _extractStruct(String propPath, String value, RegExp pattern, Map<String, String> store) {
    final matches = pattern.allMatches(propPath);
    if (matches.isEmpty) return false;

    final match = matches.first;
    final field = _formatKey(match.group(1));
    store[field] = value;
    return true;
  }

  bool _extractIndexedStruct(String propPath, String value, RegExp pattern, Map<int, Map<String, String>> store) {
    final matches = pattern.allMatches(propPath);
    if (matches.isEmpty) return false;

    final match = matches.first;
    final index = int.parse(match.group(1));
    final field = _formatKey(match.group(2));
    final fields = store.putIfAbsent(index, () => <String, String>{});
    fields[field] = value;
    return true;
  }

  bool extractData(String propPath, String value) => false;

  List<Widget> buildFromExtractedData() => [];

  String formatValue(String value) => value;

  // identity

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is XmpNamespace && other.namespace == namespace;
  }

  @override
  int get hashCode => namespace.hashCode;

  @override
  String toString() {
    return '$runtimeType#${shortHash(this)}{namespace=$namespace}';
  }
}

class XmpBasicNamespace extends XmpNamespace {
  static const ns = 'xmp';

  static final thumbnailsPattern = RegExp(r'xmp:Thumbnails\[(\d+)\]/(.*)');

  final thumbnails = <int, Map<String, String>>{};

  XmpBasicNamespace() : super(ns);

  @override
  bool extractData(String propPath, String value) => _extractIndexedStruct(propPath, value, thumbnailsPattern, thumbnails);

  @override
  List<Widget> buildFromExtractedData() => [
        if (thumbnails.isNotEmpty)
          XmpStructArrayCard(
            title: 'Thumbnail',
            structByIndex: thumbnails,
          )
      ];
}

class XmpIptcCoreNamespace extends XmpNamespace {
  static const ns = 'Iptc4xmpCore';

  static final creatorContactInfoPattern = RegExp(r'Iptc4xmpCore:CreatorContactInfo/(.*)');

  final creatorContactInfo = <String, String>{};

  XmpIptcCoreNamespace() : super(ns);

  @override
  bool extractData(String propPath, String value) => _extractStruct(propPath, value, creatorContactInfoPattern, creatorContactInfo);

  @override
  List<Widget> buildFromExtractedData() => [
        if (creatorContactInfo.isNotEmpty)
          XmpStructCard(
            title: 'Creator Contact Info',
            struct: creatorContactInfo,
          ),
      ];
}

class XmpMMNamespace extends XmpNamespace {
  static const ns = 'xmpMM';

  static const didPrefix = 'xmp.did:';
  static const iidPrefix = 'xmp.iid:';

  static final derivedFromPattern = RegExp(r'xmpMM:DerivedFrom/(.*)');
  static final historyPattern = RegExp(r'xmpMM:History\[(\d+)\]/(.*)');

  final derivedFrom = <String, String>{};
  final history = <int, Map<String, String>>{};

  XmpMMNamespace() : super(ns);

  @override
  bool extractData(String propPath, String value) => _extractStruct(propPath, value, derivedFromPattern, derivedFrom) || _extractIndexedStruct(propPath, value, historyPattern, history);

  @override
  List<Widget> buildFromExtractedData() => [
        if (derivedFrom.isNotEmpty)
          XmpStructCard(
            title: 'Derived From',
            struct: derivedFrom,
          ),
        if (history.isNotEmpty)
          XmpStructArrayCard(
            title: 'History',
            structByIndex: history,
          ),
      ];

  @override
  String formatValue(String value) {
    if (value.startsWith(didPrefix)) return value.replaceFirst(didPrefix, '');
    if (value.startsWith(iidPrefix)) return value.replaceFirst(iidPrefix, '');
    return value;
  }
}

class XmpNoteNamespace extends XmpNamespace {
  static const ns = 'xmpNote';

  // `xmpNote:HasExtendedXMP` is structural and should not be displayed to users
  static const hasExtendedXmp = '$ns:HasExtendedXMP';

  XmpNoteNamespace() : super(ns);

  @override
  bool extractData(String propPath, String value) {
    return propPath == hasExtendedXmp;
  }
}
