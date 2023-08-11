import 'package:aves/ref/metadata/xmp.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

class XmpBasicNamespace extends XmpNamespace {
  XmpBasicNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: XmpNamespaces.xmp);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(
      RegExp(nsPrefix + r'Thumbnails\[(\d+)\]/(.*)'),
      spanBuilders: (index, struct) {
        return {
          if (struct.containsKey('xmpGImg:image'))
            'Image': InfoRowGroup.linkSpanBuilder(
              linkText: (context) => context.l10n.viewerInfoOpenLinkText,
              onTap: (context) => OpenEmbeddedDataNotification.xmp(
                props: [
                  const [XmpNamespaces.xmp, 'Thumbnails'],
                  index,
                  const [XmpNamespaces.xmpGImg, 'image'],
                ],
                mimeType: MimeTypes.jpeg,
              ).dispatch(context),
            ),
        };
      },
    ),
  ];
}
