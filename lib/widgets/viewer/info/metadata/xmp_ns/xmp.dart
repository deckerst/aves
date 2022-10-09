import 'package:aves/ref/mime_types.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

class XmpBasicNamespace extends XmpNamespace {
  XmpBasicNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.xmp, nsPrefix, rawProps);

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
                  const [Namespaces.xmp, 'Thumbnails'],
                  index,
                  const [Namespaces.xmpGImg, 'image'],
                ],
                mimeType: MimeTypes.jpeg,
              ).dispatch(context),
            ),
        };
      },
    ),
  ];
}
