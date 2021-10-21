import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

class XmpCrsNamespace extends XmpNamespace {
  static const ns = 'crs';

  static final cgbcPattern = RegExp(ns + r':CircularGradientBasedCorrections\[(\d+)\]/(.*)');
  static final gbcPattern = RegExp(ns + r':GradientBasedCorrections\[(\d+)\]/(.*)');
  static final pbcPattern = RegExp(ns + r':PaintBasedCorrections\[(\d+)\]/(.*)');
  static final lookPattern = RegExp(ns + r':Look/(.*)');

  final cgbc = <int, Map<String, String>>{};
  final gbc = <int, Map<String, String>>{};
  final pbc = <int, Map<String, String>>{};
  final look = <String, String>{};

  XmpCrsNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) {
    final hasStructs = extractStruct(prop, lookPattern, look);
    var hasIndexedStructs = extractIndexedStruct(prop, cgbcPattern, cgbc);
    hasIndexedStructs |= extractIndexedStruct(prop, gbcPattern, gbc);
    hasIndexedStructs |= extractIndexedStruct(prop, pbcPattern, pbc);
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
        if (pbc.isNotEmpty)
          XmpStructArrayCard(
            title: 'Paint Based Corrections',
            structByIndex: pbc,
          ),
      ];
}
