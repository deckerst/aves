import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/material.dart';

class XmpPlusNamespace extends XmpNamespace {
  late final licensorPattern = RegExp(nsPrefix + r'Licensor\[(\d+)\]/(.*)');

  final licensor = <int, Map<String, String>>{};

  XmpPlusNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.plus, nsPrefix, rawProps);

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
