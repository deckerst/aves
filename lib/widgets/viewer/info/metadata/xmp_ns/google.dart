import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:tuple/tuple.dart';

abstract class XmpGoogleNamespace extends XmpNamespace {
  XmpGoogleNamespace(String ns) : super(ns);

  List<Tuple2<String, String>> get dataProps;

  @override
  Map<String, InfoLinkHandler> linkifyValues(List<XmpProp> props) {
    return Map.fromEntries(dataProps.map((t) {
      final dataPropPath = t.item1;
      final mimePropPath = t.item2;
      final dataProp = props.firstWhere((prop) => prop.path == dataPropPath, orElse: () => null);
      final mimeProp = props.firstWhere((prop) => prop.path == mimePropPath, orElse: () => null);
      return (dataProp != null && mimeProp != null)
          ? MapEntry(
              dataProp.displayKey,
              InfoLinkHandler(
                linkText: (context) => context.l10n.viewerInfoOpenLinkText,
                onTap: (context) => OpenEmbeddedDataNotification.xmp(
                  propPath: dataProp.path,
                  mimeType: mimeProp.value,
                ).dispatch(context),
              ))
          : null;
    }).where((e) => e != null));
  }
}

class XmpGAudioNamespace extends XmpGoogleNamespace {
  static const ns = 'GAudio';

  XmpGAudioNamespace() : super(ns);

  @override
  List<Tuple2<String, String>> get dataProps => [Tuple2('$ns:Data', '$ns:Mime')];

  @override
  String get displayTitle => 'Google Audio';
}

class XmpGDepthNamespace extends XmpGoogleNamespace {
  static const ns = 'GDepth';

  XmpGDepthNamespace() : super(ns);

  @override
  List<Tuple2<String, String>> get dataProps => [
        Tuple2('$ns:Data', '$ns:Mime'),
        Tuple2('$ns:Confidence', '$ns:ConfidenceMime'),
      ];

  @override
  String get displayTitle => 'Google Depth';
}

class XmpGImageNamespace extends XmpGoogleNamespace {
  static const ns = 'GImage';

  XmpGImageNamespace() : super(ns);

  @override
  List<Tuple2<String, String>> get dataProps => [Tuple2('$ns:Data', '$ns:Mime')];

  @override
  String get displayTitle => 'Google Image';
}
