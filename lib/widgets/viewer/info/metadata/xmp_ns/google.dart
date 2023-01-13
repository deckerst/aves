import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';

abstract class XmpGoogleNamespace extends XmpNamespace {
  const XmpGoogleNamespace(String nsUri, String nsPrefix, Map<String, String> rawProps) : super(nsUri, nsPrefix, rawProps);

  List<Tuple2<String, String>> get dataProps;

  @override
  Map<String, InfoValueSpanBuilder> linkifyValues(List<XmpProp> props) {
    return Map.fromEntries(dataProps.map((t) {
      final dataPropPath = t.item1;
      final mimePropPath = t.item2;
      final dataProp = props.firstWhereOrNull((prop) => prop.path == dataPropPath);
      final mimeProp = props.firstWhereOrNull((prop) => prop.path == mimePropPath);
      return (dataProp != null && mimeProp != null)
          ? MapEntry(
              dataProp.displayKey,
              InfoRowGroup.linkSpanBuilder(
                linkText: (context) => context.l10n.viewerInfoOpenLinkText,
                onTap: (context) {
                  final pattern = RegExp(r'(.+):(.+)([(\d)])?');
                  final props = dataProp.path.split('/').expand((part) {
                    var match = pattern.firstMatch(part);
                    if (match == null) return [];

                    // ignore namespace prefix
                    final propName = match.group(2);
                    final prop = [nsUri, propName];

                    final indexString = match.groupCount >= 4 ? match.group(4) : null;
                    final index = indexString != null ? int.tryParse(indexString) : null;
                    if (index != null) {
                      return [prop, index];
                    } else {
                      return [prop];
                    }
                  }).toList();
                  return OpenEmbeddedDataNotification.xmp(
                    props: props,
                    mimeType: mimeProp.value,
                  ).dispatch(context);
                },
              ))
          : null;
    }).whereNotNull());
  }
}

class XmpGAudioNamespace extends XmpGoogleNamespace {
  const XmpGAudioNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.gAudio, nsPrefix, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => [Tuple2('${nsPrefix}Data', '${nsPrefix}Mime')];
}

class XmpGDepthNamespace extends XmpGoogleNamespace {
  const XmpGDepthNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.gDepth, nsPrefix, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => [
        Tuple2('${nsPrefix}Data', '${nsPrefix}Mime'),
        Tuple2('${nsPrefix}Confidence', '${nsPrefix}ConfidenceMime'),
      ];
}

class XmpGDeviceNamespace extends XmpNamespace {
  XmpGDeviceNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.gDevice, nsPrefix, rawProps) {
    final mimePattern = RegExp(nsPrefix + r'Container/Container:Directory\[(\d+)\]/Item:Mime');
    final originalProps = rawProps.entries.toList();
    originalProps.forEach((kv) {
      final path = kv.key;
      final match = mimePattern.firstMatch(path);
      if (match != null) {
        final indexString = match.group(1);
        if (indexString != null) {
          final index = int.tryParse(indexString);
          if (index != null) {
            final dataPath = '${nsPrefix}Container/Container:Directory[$index]/Item:Data';
            rawProps[dataPath] = '[skipped]';
          }
        }
      }
    });
  }

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(
      RegExp(nsPrefix + r'Cameras\[(\d+)\]/(.*)'),
      cards: [
        XmpCardData(RegExp(r'Camera:DepthMap/(.*)')),
        XmpCardData(RegExp(r'Camera:Image/(.*)')),
        XmpCardData(RegExp(r'Camera:ImagingModel/(.*)')),
      ],
    ),
    XmpCardData(
      RegExp(nsPrefix + r'Container/Container:Directory\[(\d+)\]/(.*)'),
      spanBuilders: (index, struct) {
        if (struct.containsKey('Item:Data') && struct.containsKey('Item:DataURI')) {
          final dataUriProp = struct['Item:DataURI'];
          if (dataUriProp != null) {
            return {
              'Data': InfoRowGroup.linkSpanBuilder(
                linkText: (context) => context.l10n.viewerInfoOpenLinkText,
                onTap: (context) => OpenEmbeddedDataNotification.googleDevice(dataUri: dataUriProp.value).dispatch(context),
              ),
            };
          }
        }
        return {};
      },
    ),
    XmpCardData(RegExp(nsPrefix + r'Profiles\[(\d+)\]/(.*)')),
  ];
}

class XmpGImageNamespace extends XmpGoogleNamespace {
  const XmpGImageNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.gImage, nsPrefix, rawProps);

  @override
  List<Tuple2<String, String>> get dataProps => [Tuple2('${nsPrefix}Data', '${nsPrefix}Mime')];
}

class XmpContainer extends XmpNamespace {
  XmpContainer(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.container, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp('${nsPrefix}Directory\\[(\\d+)\\]/${nsPrefix}Item/(.*)'), title: 'Directory Item'),
  ];
}
