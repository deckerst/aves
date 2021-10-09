import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

class XmpCrsNamespace extends XmpNamespace {
  static const ns = 'crs';

  static final cgbcPattern = RegExp(ns + r':CircularGradientBasedCorrections\[(\d+)\]/(.*)');
  static final lookPattern = RegExp(ns + r':Look/(.*)');

  final cgbc = <int, Map<String, String>>{};
  final look = <String, String>{};

  XmpCrsNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) {
    final hasStructs = extractStruct(prop, lookPattern, look);
    final hasIndexedStructs = extractIndexedStruct(prop, cgbcPattern, cgbc);
    return hasStructs || hasIndexedStructs;
  }

  @override
  List<Widget> buildFromExtractedData() => [
        if (look.isNotEmpty)
          XmpStructCard(
            title: 'Look',
            struct: look,
          ),
        if (cgbc.isNotEmpty)
          XmpStructArrayCard(
            title: 'Circular Gradient Based Corrections',
            structByIndex: cgbc,
          ),
      ];
}
