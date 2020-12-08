import 'package:aves/widgets/fullscreen/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/fullscreen/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpIptcCoreNamespace extends XmpNamespace {
  static const ns = 'Iptc4xmpCore';

  static final creatorContactInfoPattern = RegExp(r'Iptc4xmpCore:CreatorContactInfo/(.*)');

  final creatorContactInfo = <String, String>{};

  XmpIptcCoreNamespace() : super(ns);

  @override
  String get displayTitle => 'IPTC Core';

  @override
  bool extractData(XmpProp prop) => extractStruct(prop, creatorContactInfoPattern, creatorContactInfo);

  @override
  List<Widget> buildFromExtractedData() => [
        if (creatorContactInfo.isNotEmpty)
          XmpStructCard(
            title: 'Creator Contact Info',
            struct: creatorContactInfo,
          ),
      ];
}
