import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpIptcCoreNamespace extends XmpNamespace {
  late final creatorContactInfoPattern = RegExp(nsPrefix + r'CreatorContactInfo/(.*)');

  final creatorContactInfo = <String, String>{};

  XmpIptcCoreNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.iptc4xmpCore, nsPrefix, rawProps);

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
