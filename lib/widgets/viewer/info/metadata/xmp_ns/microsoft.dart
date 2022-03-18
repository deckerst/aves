import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

class XmpMPNamespace extends XmpNamespace {
  static const ns = 'MP';

  static final regionListPattern = RegExp(ns + r':RegionInfo/MPRI:Regions\[(\d+)\]/(.*)');

  final regionList = <int, Map<String, String>>{};

  XmpMPNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) => extractIndexedStruct(prop, regionListPattern, regionList);

  @override
  List<Widget> buildFromExtractedData() => [
        if (regionList.isNotEmpty)
          XmpStructArrayCard(
            title: 'Regions',
            structByIndex: regionList,
          ),
      ];
}
