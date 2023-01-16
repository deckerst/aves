import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

class XmpCrsNamespace extends XmpNamespace {
  XmpCrsNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.crs);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'CircularGradientBasedCorrections\[(\d+)\]/(.*)')),
    XmpCardData(
      RegExp(nsPrefix + r'GradientBasedCorrections\[(\d+)\]/(.*)'),
      cards: [
        XmpCardData(RegExp(nsPrefix + r'CorrectionMasks\[(\d+)\]/(.*)')),
        XmpCardData(RegExp(nsPrefix + r'CorrectionRangeMask/(.*)')),
      ],
    ),
    XmpCardData(
      RegExp(nsPrefix + r'Look/(.*)'),
      cards: [
        XmpCardData(RegExp(nsPrefix + r'Parameters/(.*)')),
      ],
    ),
    XmpCardData(
      RegExp(nsPrefix + r'MaskGroupBasedCorrections\[(\d+)\]/(.*)'),
      cards: [
        XmpCardData(
          RegExp(nsPrefix + r'CorrectionMasks\[(\d+)\]/(.*)'),
          cards: [
            XmpCardData(RegExp(nsPrefix + r'CorrectionRangeMask/(.*)')),
            XmpCardData(RegExp(nsPrefix + r'Masks\[(\d+)\]/(.*)')),
          ],
        ),
      ],
    ),
    XmpCardData(
      RegExp(nsPrefix + r'PaintBasedCorrections\[(\d+)\]/(.*)'),
      cards: [
        XmpCardData(RegExp(nsPrefix + r'CorrectionMasks\[(\d+)\]/(.*)')),
        XmpCardData(RegExp(nsPrefix + r'CorrectionRangeMask/(.*)')),
      ],
    ),
    XmpCardData(
      RegExp(nsPrefix + r'RetouchAreas\[(\d+)\]/(.*)'),
      cards: [
        XmpCardData(RegExp(nsPrefix + r'Masks\[(\d+)\]/(.*)')),
      ],
    ),
    XmpCardData(RegExp(nsPrefix + r'RangeMaskMapInfo/' + nsPrefix + r'RangeMaskMapInfo/(.*)')),
  ];
}
