import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

// cf www.metadataworkinggroup.org/pdf/mwg_guidance.pdf (down, as of 2021/02/15)
class XmpMgwRegionsNamespace extends XmpNamespace {
  static const ns = 'mwg-rs';

  static final dimensionsPattern = RegExp(ns + r':Regions/mwg-rs:AppliedToDimensions/(.*)');
  static final regionListPattern = RegExp(ns + r':Regions/mwg-rs:RegionList\[(\d+)\]/(.*)');

  final dimensions = <String, String>{};
  final regionList = <int, Map<String, String>>{};

  XmpMgwRegionsNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) {
    final hasStructs = extractStruct(prop, dimensionsPattern, dimensions);
    final hasIndexedStructs = extractIndexedStruct(prop, regionListPattern, regionList);
    return hasStructs || hasIndexedStructs;
  }

  @override
  List<Widget> buildFromExtractedData() => [
        if (dimensions.isNotEmpty)
          XmpStructCard(
            title: 'Applied To Dimensions',
            struct: dimensions,
          ),
        if (regionList.isNotEmpty)
          XmpStructArrayCard(
            title: 'Region',
            structByIndex: regionList,
          ),
      ];
}
