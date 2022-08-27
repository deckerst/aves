import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

class XmpCrsNamespace extends XmpNamespace {
  late final cgbcPattern = RegExp(nsPrefix + r'CircularGradientBasedCorrections\[(\d+)\]/(.*)');
  late final gbcPattern = RegExp(nsPrefix + r'GradientBasedCorrections\[(\d+)\]/(.*)');
  late final mgbcPattern = RegExp(nsPrefix + r'MaskGroupBasedCorrections\[(\d+)\]/(.*)');
  late final pbcPattern = RegExp(nsPrefix + r'PaintBasedCorrections\[(\d+)\]/(.*)');
  late final retouchAreasPattern = RegExp(nsPrefix + r'RetouchAreas\[(\d+)\]/(.*)');
  late final lookPattern = RegExp(nsPrefix + r'Look/(.*)');
  late final rmmiPattern = RegExp(nsPrefix + r'RangeMaskMapInfo/' + nsPrefix + r'RangeMaskMapInfo/(.*)');

  final cgbc = <int, Map<String, String>>{};
  final gbc = <int, Map<String, String>>{};
  final mgbc = <int, Map<String, String>>{};
  final pbc = <int, Map<String, String>>{};
  final retouchAreas = <int, Map<String, String>>{};
  final look = <String, String>{};
  final rmmi = <String, String>{};

  XmpCrsNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.crs, nsPrefix, rawProps);

  @override
  bool extractData(XmpProp prop) {
    var hasStructs = extractStruct(prop, lookPattern, look);
    hasStructs |= extractStruct(prop, rmmiPattern, rmmi);
    var hasIndexedStructs = extractIndexedStruct(prop, cgbcPattern, cgbc);
    hasIndexedStructs |= extractIndexedStruct(prop, gbcPattern, gbc);
    hasIndexedStructs |= extractIndexedStruct(prop, mgbcPattern, mgbc);
    hasIndexedStructs |= extractIndexedStruct(prop, pbcPattern, pbc);
    hasIndexedStructs |= extractIndexedStruct(prop, retouchAreasPattern, retouchAreas);
    return hasStructs || hasIndexedStructs;
  }

  @override
  List<Widget> buildFromExtractedData() => [
        if (cgbc.isNotEmpty)
          XmpStructArrayCard(
            title: 'Circular Gradient Based Corrections',
            structByIndex: cgbc,
          ),
        if (gbc.isNotEmpty)
          XmpStructArrayCard(
            title: 'Gradient Based Corrections',
            structByIndex: gbc,
          ),
        if (look.isNotEmpty)
          XmpStructCard(
            title: 'Look',
            struct: look,
          ),
        if (mgbc.isNotEmpty)
          XmpStructArrayCard(
            title: 'Mask Group Based Corrections',
            structByIndex: mgbc,
          ),
        if (pbc.isNotEmpty)
          XmpStructArrayCard(
            title: 'Paint Based Corrections',
            structByIndex: pbc,
          ),
        if (rmmi.isNotEmpty)
          XmpStructCard(
            title: 'Range Mask Map Info',
            struct: rmmi,
          ),
        if (retouchAreas.isNotEmpty)
          XmpStructArrayCard(
            title: 'Retouch Areas',
            structByIndex: retouchAreas,
          ),
      ];
}
