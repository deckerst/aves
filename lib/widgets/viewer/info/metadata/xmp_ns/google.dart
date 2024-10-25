import 'package:aves/ref/metadata/xmp.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:collection/collection.dart';

abstract class XmpGoogleNamespace extends XmpNamespace {
  XmpGoogleNamespace({
    required super.nsUri,
    required super.schemaRegistryPrefixes,
    required super.rawProps,
  });

  List<(String, String)> get dataProps;

  @override
  Map<String, InfoValueSpanBuilder> linkifyValues(List<XmpProp> props) {
    return Map.fromEntries(dataProps.map((t) {
      final (dataPropPath, mimePropPath) = t;
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
    }).nonNulls);
  }
}

class XmpGAudioNamespace extends XmpGoogleNamespace {
  XmpGAudioNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: XmpNamespaces.gAudio);

  @override
  List<(String, String)> get dataProps => [
        ('${nsPrefix}Data', '${nsPrefix}Mime'),
      ];
}

class XmpGCameraNamespace extends XmpGoogleNamespace {
  XmpGCameraNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: XmpNamespaces.gCamera);

  @override
  List<(String, String)> get dataProps => [
        ('${nsPrefix}RelitInputImageData', '${nsPrefix}RelitInputImageMime'),
      ];
}

class XmpGContainer extends XmpNamespace {
  late final String _gContainerItemNsPrefix;
  late final String _rdfNsPrefix;

  XmpGContainer({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: XmpNamespaces.gContainer) {
    _gContainerItemNsPrefix = XmpNamespace.prefixForUri(schemaRegistryPrefixes, XmpNamespaces.gContainerItem);
    _rdfNsPrefix = XmpNamespace.prefixForUri(schemaRegistryPrefixes, XmpNamespaces.rdf);
  }

  @override
  late final Set<RegExp> skippedProps = {
    // variant of `Container:Item` with `<rdf:li>`
    RegExp(nsPrefix + r'Directory\[(\d+)\]/' + _rdfNsPrefix + r'type'),
  };

  @override
  late final List<XmpCardData> cards = [
    // variant of `Container:Item` with `<rdf:li rdf:parseType="Resource">`
    XmpCardData(RegExp(nsPrefix + r'Directory\[(\d+)\]/' + nsPrefix + r'Item/(.*)'), title: 'Directory Item'),
    // variant of `Container:Item` with `<rdf:li>`
    XmpCardData(RegExp(nsPrefix + r'Directory\[(\d+)\]/(' + _gContainerItemNsPrefix + r'.*)'), title: 'Directory Item'),
  ];
}

class XmpGDepthNamespace extends XmpGoogleNamespace {
  XmpGDepthNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: XmpNamespaces.gDepth);

  @override
  List<(String, String)> get dataProps => [
        ('${nsPrefix}Data', '${nsPrefix}Mime'),
        ('${nsPrefix}Confidence', '${nsPrefix}ConfidenceMime'),
      ];
}

class XmpGDeviceNamespace extends XmpNamespace {
  late final String _cameraNsPrefix;
  late final String _containerNsPrefix;
  late final String _itemNsPrefix;

  XmpGDeviceNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: XmpNamespaces.gDevice) {
    _cameraNsPrefix = XmpNamespace.prefixForUri(schemaRegistryPrefixes, XmpNamespaces.gDeviceCamera);
    _containerNsPrefix = XmpNamespace.prefixForUri(schemaRegistryPrefixes, XmpNamespaces.gDeviceContainer);
    _itemNsPrefix = XmpNamespace.prefixForUri(schemaRegistryPrefixes, XmpNamespaces.gDeviceItem);

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
  XmpGImageNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: XmpNamespaces.gImage);

  @override
  List<(String, String)> get dataProps => [
        ('${nsPrefix}Data', '${nsPrefix}Mime'),
      ];
}
