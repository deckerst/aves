import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpPlusNamespace extends XmpNamespace {
  static const ns = 'plus';

  static final licensorPattern = RegExp(ns + r':Licensor\[(\d+)\]/(.*)');

  final licensor = <int, Map<String, String>>{};

  XmpPlusNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) => extractIndexedStruct(prop, licensorPattern, licensor);

  @override
  List<Widget> buildFromExtractedData() => [
        if (licensor.isNotEmpty)
          XmpStructArrayCard(
            title: 'Licensor',
            structByIndex: licensor,
          ),
      ];
}
