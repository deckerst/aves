// cf photoshop:ColorMode
// cf https://github.com/adobe/xmp-docs/blob/master/XMPNamespaces/photoshop.md
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

class XmpPhotoshopNamespace extends XmpNamespace {
  static const ns = 'photoshop';

  static final textLayersPattern = RegExp(ns + r':TextLayers\[(\d+)\]/(.*)');

  final textLayers = <int, Map<String, String>>{};

  XmpPhotoshopNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) {
    return extractIndexedStruct(prop, textLayersPattern, textLayers);
  }

  @override
  List<Widget> buildFromExtractedData() => [
        if (textLayers.isNotEmpty)
          XmpStructArrayCard(
            title: 'Text Layers',
            structByIndex: textLayers,
          ),
      ];

  @override
  String formatValue(XmpProp prop) {
    final value = prop.value;
    switch (prop.path) {
      case 'photoshop:ColorMode':
        return getColorModeDescription(value);
    }
    return value;
  }

  static String getColorModeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Bitmap';
      case 1:
        return 'Gray scale';
      case 2:
        return 'Indexed colour';
      case 3:
        return 'RGB colour';
      case 4:
        return 'CMYK colour';
      case 7:
        return 'Multi-channel';
      case 8:
        return 'Duotone';
      case 9:
        return 'LAB colour';
      default:
        return 'Unknown ($value)';
    }
  }
}
