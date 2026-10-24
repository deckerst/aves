import 'package:aves/ref/brand_colors.dart';
import 'package:aves/ref/metadata/xmp.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/model/xmp_card_data.dart';
import 'package:aves/widgets/viewer/info/metadata/model/xmp_prop.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_card.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/crs.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/exif.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/google.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/misc.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/photoshop.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/tiff.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/xmp.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

@immutable
class XmpNamespace extends Equatable {
  final Map<String, String> schemaRegistryPrefixes;
  final String nsUri, nsPrefix;
  final Map<String, String> rawProps;

  @override
  List<Object?> get props => [nsUri, nsPrefix];

  new({
    required this.nsUri,
    required this.schemaRegistryPrefixes,
    required this.rawProps,
  }) : nsPrefix = prefixForUri(schemaRegistryPrefixes, nsUri);

  factory create(Map<String, String> schemaRegistryPrefixes, String nsPrefix, Map<String, String> rawProps) {
    final nsUri = schemaRegistryPrefixes[nsPrefix] ?? '';
    switch (nsUri) {
      case XmpNamespaces.creatorAtom:
        return XmpCreatorAtom(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.crs:
        return XmpCrsNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.darktable:
        return XmpDarktableNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.dwc:
        return XmpDwcNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.exif:
        return XmpExifNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.gAudio:
        return XmpGAudioNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.gCamera:
        return XmpGCameraNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.gContainer:
        return XmpGContainer(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.gDepth:
        return XmpGDepthNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.gDevice:
        return XmpGDeviceNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.gImage:
        return XmpGImageNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.iptc4xmpCore:
        return XmpIptcCoreNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.iptc4xmpExt:
        return XmpIptc4xmpExtNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.mwgrs:
        return XmpMgwRegionsNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.mp:
        return XmpMPNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.photoshop:
        return XmpPhotoshopNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.plus:
        return XmpPlusNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.tiff:
        return XmpTiffNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.xmp:
        return XmpBasicNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.xmpMM:
        return XmpMMNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      case XmpNamespaces.xperiaCamera:
        return XmpXperiaCameraNamespace(schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
      default:
        return XmpNamespace(nsUri: nsUri, schemaRegistryPrefixes: schemaRegistryPrefixes, rawProps: rawProps);
    }
  }

  String get displayTitle => XmpNamespaceView.nsTitles[nsUri] ?? (nsPrefix.isEmpty ? nsUri : '${nsPrefix.substring(0, nsPrefix.length - 1)} ($nsUri)');

  List<Widget> buildNamespaceSection(BuildContext context) {
    final props =
        rawProps.entries
            .map((kv) {
              final key = kv.key;
              if (skippedProps.any((pattern) => pattern.allMatches(key).isNotEmpty)) {
                return null;
              }
              final prop = XmpProp(key, kv.value);
              var extracted = false;
              cards.forEach((card) => extracted |= card.extract(prop));
              return extracted ? null : prop;
            })
            .nonNulls
            .toList()
          ..sort();

    final content = [
      if (props.isNotEmpty)
        InfoRowGroup(
          info: Map.fromEntries(props.map((v) => MapEntry(v.displayKey, formatValue(v)))),
          spanBuilders: linkifyValues(props),
        ),
      ...cards.where((v) => !v.isEmpty).map((card) {
        final spanBuilders = card.spanBuilders;
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: XmpCard(
            title: card.title,
            structByIndex: card.data,
            formatValue: formatValue,
            spanBuilders: spanBuilders != null ? (index) => spanBuilders(index, card.data[index]!.$1) : null,
          ),
        );
      }),
    ];

    return content.isNotEmpty
        ? [
            if (displayTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: HighlightTitle(
                  title: displayTitle,
                  locale: KnownLocale.english,
                  color: context.select<AvesColorsData, Color?>((v) => v.fromBrandColor(BrandColors.get(displayTitle))),
                ),
              ),
            ...content,
          ]
        : [];
  }

  Set<RegExp> get skippedProps => {};

  List<XmpCardData> get cards => [];

  String formatValue(XmpProp prop) => prop.value;

  Map<String, InfoValueSpanBuilder> linkifyValues(List<XmpProp> props) => {};

  static String prefixForUri(Map<String, String> schemaRegistryPrefixes, String nsUri) => schemaRegistryPrefixes.entries.firstWhereOrNull((kv) => kv.value == nsUri)?.key ?? '';
}
