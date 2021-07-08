import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';

abstract class XmpGoogleNamespace extends XmpNamespace {
  XmpGoogleNamespace(String ns, Map<String, String> rawProps) : super(ns, rawProps);

  List<Tuple2<String, String>> get dataProps;

  @override
  Map<String, InfoLinkHandler> linkifyValues(List<XmpProp> props) {
    return Map.fromEntries(dataProps.map((t) {
      final dataPropPath = t.item1;
      final mimePropPath = t.item2;
      final dataProp = props.firstWhereOrNull((prop) => prop.path == dataPropPath);
      final mimeProp = props.firstWhereOrNull((prop) => prop.path == mimePropPath);
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
    }).whereNotNull());
  }
}

class XmpGAudioNamespace extends XmpGoogleNamespace {
  static const ns = 'GAudio';

  XmpGAudioNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => const [Tuple2('$ns:Data', '$ns:Mime')];

  @override
  String get displayTitle => 'Google Audio';
}

class XmpGDepthNamespace extends XmpGoogleNamespace {
  static const ns = 'GDepth';

  XmpGDepthNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => const [
        Tuple2('$ns:Data', '$ns:Mime'),
        Tuple2('$ns:Confidence', '$ns:ConfidenceMime'),
      ];

  @override
  String get displayTitle => 'Google Depth';
}

class XmpGImageNamespace extends XmpGoogleNamespace {
  static const ns = 'GImage';

  XmpGImageNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => const [Tuple2('$ns:Data', '$ns:Mime')];

  @override
  String get displayTitle => 'Google Image';
}

class XmpGCameraNamespace extends XmpNamespace {
  static const ns = 'GCamera';
  static const videoOffsetKey = 'GCamera:MicroVideoOffset';
  static const videoDataKey = 'Data';

  late bool _isMotionPhoto;

  XmpGCameraNamespace(Map<String, String> rawProps) : super(ns, rawProps) {
    _isMotionPhoto = rawProps.keys.any((key) => key == videoOffsetKey);
  }

  @override
  Map<String, String> get buildProps {
    return _isMotionPhoto
        ? Map.fromEntries({
            const MapEntry(videoDataKey, '[skipped]'),
            ...rawProps.entries,
          })
        : rawProps;
  }

  @override
  Map<String, InfoLinkHandler> linkifyValues(List<XmpProp> props) {
    return {
      videoDataKey: InfoLinkHandler(
        linkText: (context) => context.l10n.viewerInfoOpenLinkText,
        onTap: (context) => OpenEmbeddedDataNotification.motionPhotoVideo().dispatch(context),
      ),
    };
  }
}
