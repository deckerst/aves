import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';

abstract class XmpGoogleNamespace extends XmpNamespace {
  XmpGoogleNamespace({
    required super.nsUri,
    required super.schemaRegistryPrefixes,
    required super.rawProps,
  });

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
  XmpGAudioNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.gAudio);

  @override
  List<Tuple2<String, String>> get dataProps => [
        Tuple2('${nsPrefix}Data', '${nsPrefix}Mime'),
      ];
}

class XmpGCameraNamespace extends XmpGoogleNamespace {
  XmpGCameraNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.gCamera);

  @override
  List<Tuple2<String, String>> get dataProps => [
        Tuple2('${nsPrefix}RelitInputImageData', '${nsPrefix}RelitInputImageMime'),
      ];
}

class XmpGContainer extends XmpNamespace {
  XmpGContainer({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.gContainer);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'Directory\[(\d+)\]/' + nsPrefix + r'Item/(.*)'), title: 'Directory Item'),
  ];
}

class XmpGDepthNamespace extends XmpGoogleNamespace {
  XmpGDepthNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.gDepth);

  @override
  List<Tuple2<String, String>> get dataProps => [
        Tuple2('${nsPrefix}Data', '${nsPrefix}Mime'),
        Tuple2('${nsPrefix}Confidence', '${nsPrefix}ConfidenceMime'),
      ];
}

class XmpGDeviceNamespace extends XmpNamespace {
  late final String _cameraNsPrefix;
  late final String _containerNsPrefix;
  late final String _itemNsPrefix;

  XmpGDeviceNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.gDevice) {
    _cameraNsPrefix = XmpNamespace.prefixForUri(schemaRegistryPrefixes, Namespaces.gDeviceCamera);
    _containerNsPrefix = XmpNamespace.prefixForUri(schemaRegistryPrefixes, Namespaces.gDeviceContainer);
    _itemNsPrefix = XmpNamespace.prefixForUri(schemaRegistryPrefixes, Namespaces.gDeviceItem);

    final mimePattern = RegExp(nsPrefix + r'Container/' + _containerNsPrefix + r'Directory\[(\d+)\]/' + _itemNsPrefix + r'Mime');
    final originalProps = rawProps.entries.toList();
    originalProps.forEach((kv) {
      final path = kv.key;
      final match = mimePattern.firstMatch(path);
      if (match != null) {
        final indexString = match.group(1);
        if (indexString != null) {
          final index = int.tryParse(indexString);
          if (index != null) {
            final dataPath = '${nsPrefix}Container/${_containerNsPrefix}Directory[$index]/${_itemNsPrefix}Data';
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
        XmpCardData(RegExp(_cameraNsPrefix + r'DepthMap/(.*)')),
        XmpCardData(RegExp(_cameraNsPrefix + r'Image/(.*)')),
        XmpCardData(RegExp(_cameraNsPrefix + r'ImagingModel/(.*)')),
      ],
    ),
    XmpCardData(
      RegExp(nsPrefix + r'Container/' + _containerNsPrefix + r'Directory\[(\d+)\]/(.*)'),
      spanBuilders: (index, struct) {
        if (struct.containsKey('${_itemNsPrefix}Data') && struct.containsKey('${_itemNsPrefix}DataURI')) {
          final dataUriProp = struct['${_itemNsPrefix}DataURI'];
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
  XmpGImageNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.gImage);

  @override
  List<Tuple2<String, String>> get dataProps => [
        Tuple2('${nsPrefix}Data', '${nsPrefix}Mime'),
      ];
}
