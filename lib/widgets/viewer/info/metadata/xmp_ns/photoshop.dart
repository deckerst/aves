// cf photoshop:ColorMode
// cf https://github.com/adobe/xmp-docs/blob/master/XMPNamespaces/photoshop.md
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

class XmpPhotoshopNamespace extends XmpNamespace {
  static const ns = 'photoshop';

  const XmpPhotoshopNamespace(Map<String, String> rawProps) : super(ns, rawProps);

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
