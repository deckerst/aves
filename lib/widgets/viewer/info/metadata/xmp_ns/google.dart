import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

abstract class XmpGoogleNamespace extends XmpNamespace {
  const XmpGoogleNamespace(String ns, Map<String, String> rawProps) : super(ns, rawProps);

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

  const XmpGAudioNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => const [Tuple2('$ns:Data', '$ns:Mime')];
}

class XmpGDepthNamespace extends XmpGoogleNamespace {
  static const ns = 'GDepth';

  const XmpGDepthNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => const [
        Tuple2('$ns:Data', '$ns:Mime'),
        Tuple2('$ns:Confidence', '$ns:ConfidenceMime'),
      ];
}

class XmpGImageNamespace extends XmpGoogleNamespace {
  static const ns = 'GImage';

  const XmpGImageNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => const [Tuple2('$ns:Data', '$ns:Mime')];
}

class XmpContainer extends XmpNamespace {
  static const ns = 'Container';

  static final directoryPattern = RegExp('$ns:Directory\\[(\\d+)\\]/$ns:Item/(.*)');

  final directories = <int, Map<String, String>>{};

  XmpContainer(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) => extractIndexedStruct(prop, directoryPattern, directories);

  @override
  List<Widget> buildFromExtractedData() => [
        if (directories.isNotEmpty)
          XmpStructArrayCard(
            title: 'Directory Item',
            structByIndex: directories,
          ),
      ];
}
