import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpIptc4xmpExtNamespace extends XmpNamespace {
  static const ns = 'Iptc4xmpExt';

  static final aooPattern = RegExp(ns + r':ArtworkOrObject\[(\d+)\]/(.*)');

  final aoo = <int, Map<String, String>>{};

  XmpIptc4xmpExtNamespace(Map<String, String> rawProps) : super(ns, rawProps);

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
