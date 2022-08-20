import 'package:aves/ref/brand_colors.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/crs.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/darktable.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/dwc.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/exif.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/google.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/iptc.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/iptc4xmpext.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/microsoft.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/mwg.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/photoshop.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/plus.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/tiff.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/xmp.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@immutable
class XmpNamespace extends Equatable {
  final String nsUri, nsPrefix;
  final Map<String, String> rawProps;

  @override
  List<Object?> get props => [nsUri, nsPrefix];

  const XmpNamespace(this.nsUri, this.nsPrefix, this.rawProps);

  factory XmpNamespace.create(String nsUri, String nsPrefix, Map<String, String> rawProps) {
    switch (nsUri) {
      case Namespaces.container:
        return XmpContainer(nsPrefix, rawProps);
      case Namespaces.crs:
        return XmpCrsNamespace(nsPrefix, rawProps);
      case Namespaces.darktable:
        return XmpDarktableNamespace(nsPrefix, rawProps);
      case Namespaces.dwc:
        return XmpDwcNamespace(nsPrefix, rawProps);
      case Namespaces.exif:
        return XmpExifNamespace(nsPrefix, rawProps);
      case Namespaces.gAudio:
        return XmpGAudioNamespace(nsPrefix, rawProps);
      case Namespaces.gDepth:
        return XmpGDepthNamespace(nsPrefix, rawProps);
      case Namespaces.gImage:
        return XmpGImageNamespace(nsPrefix, rawProps);
      case Namespaces.iptc4xmpCore:
        return XmpIptcCoreNamespace(nsPrefix, rawProps);
      case Namespaces.iptc4xmpExt:
        return XmpIptc4xmpExtNamespace(nsPrefix, rawProps);
      case Namespaces.mwgrs:
        return XmpMgwRegionsNamespace(nsPrefix, rawProps);
      case Namespaces.mp:
        return XmpMPNamespace(nsPrefix, rawProps);
      case Namespaces.photoshop:
        return XmpPhotoshopNamespace(nsPrefix, rawProps);
      case Namespaces.plus:
        return XmpPlusNamespace(nsPrefix, rawProps);
      case Namespaces.tiff:
        return XmpTiffNamespace(nsPrefix, rawProps);
      case Namespaces.xmp:
        return XmpBasicNamespace(nsPrefix, rawProps);
      case Namespaces.xmpMM:
        return XmpMMNamespace(nsPrefix, rawProps);
      case Namespaces.xmpNote:
        return XmpNoteNamespace(nsPrefix, rawProps);
      default:
        return XmpNamespace(nsUri, nsPrefix, rawProps);
    }
  }

  String get displayTitle => Namespaces.nsTitles[nsUri] ?? '${nsPrefix.substring(0, nsPrefix.length - 1)} ($nsUri)';

  Map<String, String> get buildProps => rawProps;

  List<Widget> buildNamespaceSection(BuildContext context) {
    final props = buildProps.entries
        .map((kv) {
          final prop = XmpProp(kv.key, kv.value);
          return extractData(prop) ? null : prop;
        })
        .whereNotNull()
        .toList()
      ..sort((a, b) => compareAsciiUpperCaseNatural(a.displayKey, b.displayKey));

    final content = [
      if (props.isNotEmpty)
        InfoRowGroup(
          info: Map.fromEntries(props.map((prop) => MapEntry(prop.displayKey, formatValue(prop)))),
          maxValueLength: Constants.infoGroupMaxValueLength,
          spanBuilders: linkifyValues(props),
        ),
      ...buildFromExtractedData(),
    ];

    return content.isNotEmpty
        ? [
            if (displayTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: HighlightTitle(
                  title: displayTitle,
                  color: context.select<AvesColorsData, Color?>((v) => v.fromBrandColor(BrandColors.get(displayTitle))),
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

  Map<String, InfoValueSpanBuilder> linkifyValues(List<XmpProp> props) => {};
}

class XmpProp {
  final String path, value;
  final String displayKey;

  XmpProp(this.path, this.value) : displayKey = formatKey(path);

  static String formatKey(String propPath) {
    return propPath.splitMapJoin(XMP.structFieldSeparator,
        onMatch: (match) => ' ${match.group(0)} ',
        onNonMatch: (s) {
          // strip namespace
          final key = s.split(XMP.propNamespaceSeparator).last;
          // format
          return key.replaceAll('_', ' ').toSentenceCase();
        });
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{path=$path, value=$value}';
}
