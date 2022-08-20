import 'package:aves/ref/mime_types.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpBasicNamespace extends XmpNamespace {
  late final thumbnailsPattern = RegExp(nsPrefix + r'Thumbnails\[(\d+)\]/(.*)');
  static const thumbnailDataDisplayKey = 'Image';

  final thumbnails = <int, Map<String, String>>{};

  XmpBasicNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.xmp, nsPrefix, rawProps);

  @override
  bool extractData(XmpProp prop) => extractIndexedStruct(prop, thumbnailsPattern, thumbnails);

  @override
  List<Widget> buildFromExtractedData() => [
        if (thumbnails.isNotEmpty)
          XmpStructArrayCard(
            title: 'Thumbnail',
            structByIndex: thumbnails,
            linkifier: (index) {
              final struct = thumbnails[index]!;
              return {
                if (struct.containsKey(thumbnailDataDisplayKey))
                  thumbnailDataDisplayKey: InfoRowGroup.linkSpanBuilder(
                    linkText: (context) => context.l10n.viewerInfoOpenLinkText,
                    onTap: (context) => OpenEmbeddedDataNotification.xmp(
                      props: [
                        const [Namespaces.xmp, 'Thumbnails'],
                        index,
                        const [Namespaces.xmpGImg, 'image'],
                      ],
                      mimeType: MimeTypes.jpeg,
                    ).dispatch(context),
                  ),
              };
            },
          )
      ];
}

class XmpMMNamespace extends XmpNamespace {
  late final derivedFromPattern = RegExp(nsPrefix + r'DerivedFrom/(.*)');
  late final historyPattern = RegExp(nsPrefix + r'History\[(\d+)\]/(.*)');
  late final ingredientsPattern = RegExp(nsPrefix + r'Ingredients\[(\d+)\]/(.*)');
  late final pantryPattern = RegExp(nsPrefix + r'Pantry\[(\d+)\]/(.*)');

  final derivedFrom = <String, String>{};
  final history = <int, Map<String, String>>{};
  final ingredients = <int, Map<String, String>>{};
  final pantry = <int, Map<String, String>>{};

  XmpMMNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.xmpMM, nsPrefix, rawProps);

  @override
  bool extractData(XmpProp prop) {
    final hasStructs = extractStruct(prop, derivedFromPattern, derivedFrom);
    var hasIndexedStructs = extractIndexedStruct(prop, historyPattern, history);
    hasIndexedStructs |= extractIndexedStruct(prop, ingredientsPattern, ingredients);
    hasIndexedStructs |= extractIndexedStruct(prop, pantryPattern, pantry);
    return hasStructs || hasIndexedStructs;
  }

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
        if (ingredients.isNotEmpty)
          XmpStructArrayCard(
            title: 'Ingredients',
            structByIndex: ingredients,
          ),
        if (pantry.isNotEmpty)
          XmpStructArrayCard(
            title: 'Pantry',
            structByIndex: pantry,
          ),
      ];
}

class XmpNoteNamespace extends XmpNamespace {
  // `xmpNote:HasExtendedXMP` is structural and should not be displayed to users
  late final hasExtendedXmp = '${nsPrefix}HasExtendedXMP';

  XmpNoteNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.xmpNote, nsPrefix, rawProps);

  @override
  bool extractData(XmpProp prop) {
    return prop.path == hasExtendedXmp;
  }
}
