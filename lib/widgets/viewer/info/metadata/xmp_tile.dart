import 'dart:collection';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/ref/xmp.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/exif.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/google.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/iptc.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/mwg.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/photoshop.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/tiff.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_ns/xmp.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

class XmpDirTile extends StatefulWidget {
  final AvesEntry entry;
  final SplayTreeMap<String, String> tags;
  final ValueNotifier<String> expandedNotifier;
  final bool initiallyExpanded;

  const XmpDirTile({
    @required this.entry,
    @required this.tags,
    @required this.expandedNotifier,
    @required this.initiallyExpanded,
  });

  @override
  _XmpDirTileState createState() => _XmpDirTileState();
}

class _XmpDirTileState extends State<XmpDirTile> with FeedbackMixin {
  AvesEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final sections = SplayTreeMap<XmpNamespace, List<MapEntry<String, String>>>.of(
      groupBy(widget.tags.entries, (kv) {
        final fullKey = kv.key;
        final i = fullKey.indexOf(XMP.propNamespaceSeparator);
        final namespace = i == -1 ? '' : fullKey.substring(0, i);
        switch (namespace) {
          case XmpBasicNamespace.ns:
            return XmpBasicNamespace();
          case XmpExifNamespace.ns:
            return XmpExifNamespace();
          case XmpGAudioNamespace.ns:
            return XmpGAudioNamespace();
          case XmpGDepthNamespace.ns:
            return XmpGDepthNamespace();
          case XmpGImageNamespace.ns:
            return XmpGImageNamespace();
          case XmpIptcCoreNamespace.ns:
            return XmpIptcCoreNamespace();
          case XmpMgwRegionsNamespace.ns:
            return XmpMgwRegionsNamespace();
          case XmpMMNamespace.ns:
            return XmpMMNamespace();
          case XmpNoteNamespace.ns:
            return XmpNoteNamespace();
          case XmpPhotoshopNamespace.ns:
            return XmpPhotoshopNamespace();
          case XmpTiffNamespace.ns:
            return XmpTiffNamespace();
          default:
            return XmpNamespace(namespace);
        }
      }),
      (a, b) => compareAsciiUpperCase(a.displayTitle, b.displayTitle),
    );
    return AvesExpansionTile(
      title: 'XMP',
      expandedNotifier: widget.expandedNotifier,
      initiallyExpanded: widget.initiallyExpanded,
      children: [
        NotificationListener<OpenEmbeddedDataNotification>(
          onNotification: (notification) {
            _openEmbeddedData(notification.propPath, notification.mimeType);
            return true;
          },
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sections.entries
                  .expand((kv) => kv.key.buildNamespaceSection(
                        rawProps: kv.value,
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openEmbeddedData(String propPath, String propMimeType) async {
    final fields = await MetadataService.extractXmpDataProp(entry, propPath, propMimeType);
    if (fields == null || !fields.containsKey('mimeType') || !fields.containsKey('uri')) {
      showFeedback(context, 'Failed');
      return;
    }

    final mimeType = fields['mimeType'];
    final uri = fields['uri'];
    if (!MimeTypes.isImage(mimeType) && !MimeTypes.isVideo(mimeType)) {
      // open with another app
      unawaited(AndroidAppService.open(uri, mimeType).then((success) {
        if (!success) {
          // fallback to sharing, so that the file can be saved somewhere
          AndroidAppService.shareSingle(uri, mimeType).then((success) {
            if (!success) showNoMatchingAppDialog(context);
          });
        }
      }));
      return;
    }

    OpenTempEntryNotification(entry: AvesEntry.fromMap(fields)).dispatch(context);
  }
}
