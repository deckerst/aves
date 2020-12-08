import 'package:aves/widgets/fullscreen/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/fullscreen/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpBasicNamespace extends XmpNamespace {
  static const ns = 'xmp';

  static final thumbnailsPattern = RegExp(r'xmp:Thumbnails\[(\d+)\]/(.*)');

  final thumbnails = <int, Map<String, String>>{};

  XmpBasicNamespace() : super(ns);

  @override
  bool extractData(XmpProp prop) => extractIndexedStruct(prop, thumbnailsPattern, thumbnails);

  @override
  List<Widget> buildFromExtractedData() => [
        if (thumbnails.isNotEmpty)
          XmpStructArrayCard(
            title: 'Thumbnail',
            structByIndex: thumbnails,
          )
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
  bool extractData(XmpProp prop) => extractStruct(prop, derivedFromPattern, derivedFrom) || extractIndexedStruct(prop, historyPattern, history);

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

  XmpNoteNamespace() : super(ns);

  @override
  bool extractData(XmpProp prop) {
    return prop.path == hasExtendedXmp;
  }
}
