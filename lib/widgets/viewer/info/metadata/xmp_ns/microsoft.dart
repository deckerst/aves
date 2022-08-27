import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

class XmpMPNamespace extends XmpNamespace {
  late final regionListPattern = RegExp(nsPrefix + r'RegionInfo/MPRI:Regions\[(\d+)\]/(.*)');

  final regionList = <int, Map<String, String>>{};

  XmpMPNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.mp, nsPrefix, rawProps);

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
