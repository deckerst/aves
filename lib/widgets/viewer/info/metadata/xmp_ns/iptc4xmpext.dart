import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpIptc4xmpExtNamespace extends XmpNamespace {
  late final aooPattern = RegExp(nsPrefix + r'ArtworkOrObject\[(\d+)\]/(.*)');

  final aoo = <int, Map<String, String>>{};

  XmpIptc4xmpExtNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.iptc4xmpExt, nsPrefix, rawProps);

  @override
  bool extractData(XmpProp prop) => extractIndexedStruct(prop, aooPattern, aoo);

  @override
  List<Widget> buildFromExtractedData() => [
        if (aoo.isNotEmpty)
          XmpStructArrayCard(
            title: 'Artwork or Object',
            structByIndex: aoo,
          ),
      ];
}
