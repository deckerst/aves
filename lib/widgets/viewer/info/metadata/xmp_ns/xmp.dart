import 'package:aves/ref/mime_types.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:flutter/material.dart';

class XmpBasicNamespace extends XmpNamespace {
  static const ns = 'xmp';

  static final thumbnailsPattern = RegExp(r'xmp:Thumbnails\[(\d+)\]/(.*)');
  static const thumbnailDataDisplayKey = 'Image';

  final thumbnails = <int, Map<String, String>>{};

  XmpBasicNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  String get displayTitle => 'Basic';

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
                  thumbnailDataDisplayKey: InfoLinkHandler(
                    linkText: (context) => context.l10n.viewerInfoOpenLinkText,
                    onTap: (context) => OpenEmbeddedDataNotification.xmp(
                      propPath: 'xmp:Thumbnails[$index]/xmpGImg:image',
                      mimeType: MimeTypes.jpeg,
                    ).dispatch(context),
                  ),
              };
            },
          )
      ];
}

class XmpMMNamespace extends XmpNamespace {
  static const ns = 'xmpMM';

  static const didPrefix = 'xmp.did:';
  static const iidPrefix = 'xmp.iid:';

  static final derivedFromPattern = RegExp(r'xmpMM:DerivedFrom/(.*)');
  static final historyPattern = RegExp(r'xmpMM:History\[(\d+)\]/(.*)');
  static final ingredientsPattern = RegExp(r'xmpMM:Ingredients\[(\d+)\]/(.*)');
  static final pantryPattern = RegExp(r'xmpMM:Pantry\[(\d+)\]/(.*)');

  final derivedFrom = <String, String>{};
  final history = <int, Map<String, String>>{};
  final ingredients = <int, Map<String, String>>{};
  final pantry = <int, Map<String, String>>{};

  XmpMMNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  String get displayTitle => 'Media Management';

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

  @override
  String formatValue(XmpProp prop) {
    final value = prop.value;
    if (value.startsWith(didPrefix)) return value.replaceFirst(didPrefix, '');
    if (value.startsWith(iidPrefix)) return value.replaceFirst(iidPrefix, '');
    return value;
  }
}

class XmpNoteNamespace extends XmpNamespace {
  static const ns = 'xmpNote';

  // `xmpNote:HasExtendedXMP` is structural and should not be displayed to users
  static const hasExtendedXmp = '$ns:HasExtendedXMP';

  XmpNoteNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) {
    return prop.path == hasExtendedXmp;
  }
}
