import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

// cf https://github.com/adobe/xmp-docs/blob/master/XMPNamespaces/photoshop.md
class XmpPhotoshopNamespace extends XmpNamespace {
  XmpPhotoshopNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.photoshop, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(
      RegExp(nsPrefix + r'CameraProfiles\[(\d+)\]/(.*)'),
      cards: [
        XmpCardData(RegExp(r'crlcp:PerspectiveModel/(.*)')),
      ],
    ),
    XmpCardData(RegExp(nsPrefix + r'TextLayers\[(\d+)\]/(.*)')),
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
