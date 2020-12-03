import 'dart:collection';

import 'package:aves/model/image_entry.dart';
import 'package:aves/ref/brand_colors.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/ref/xmp.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/fullscreen/fullscreen_page.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:aves/widgets/fullscreen/info/metadata/metadata_thumbnail.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

class XmpDirTile extends StatefulWidget {
  final ImageEntry entry;
  final SplayTreeMap<String, String> tags;
  final ValueNotifier<String> expandedNotifier;

  const XmpDirTile({
    @required this.entry,
    @required this.tags,
    @required this.expandedNotifier,
  });

  @override
  _XmpDirTileState createState() => _XmpDirTileState();
}

class _XmpDirTileState extends State<XmpDirTile> with FeedbackMixin {
  ImageEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final thumbnail = MetadataThumbnails(source: MetadataThumbnailSource.xmp, entry: entry);
    final sections = SplayTreeMap<_XmpNamespace, List<MapEntry<String, String>>>.of(
      groupBy(widget.tags.entries, (kv) {
        final fullKey = kv.key;
        final i = fullKey.indexOf(XMP.propNamespaceSeparator);
        if (i == -1) return _XmpNamespace('');
        final namespace = fullKey.substring(0, i);
        return _XmpNamespace(namespace);
      }),
      (a, b) => compareAsciiUpperCase(a.displayTitle, b.displayTitle),
    );
    return AvesExpansionTile(
      title: 'XMP',
      expandedNotifier: widget.expandedNotifier,
      children: [
        if (thumbnail != null) thumbnail,
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.entries.expand((namespaceProps) {
              final namespace = namespaceProps.key;
              final displayNamespace = namespace.displayTitle;
              final linkHandlers = <String, InfoLinkHandler>{};

              final entries = namespaceProps.value.map((prop) {
                final propPath = prop.key;

                final displayKey = propPath.splitMapJoin(XMP.structFieldSeparator, onNonMatch: (s) {
                  // strip namespace
                  final key = s.split(XMP.propNamespaceSeparator).last;
                  // uppercase first letter
                  return key.replaceFirstMapped(RegExp('.'), (m) => m.group(0).toUpperCase());
                });

                var value = prop.value;
                if (XMP.dataProps.contains(propPath)) {
                  linkHandlers.putIfAbsent(
                    displayKey,
                    () => InfoLinkHandler(linkText: 'Open', onTap: () => _openEmbeddedData(propPath)),
                  );
                }
                return MapEntry(displayKey, value);
              }).toList()
                ..sort((a, b) => compareAsciiUpperCaseNatural(a.key, b.key));
              return [
                if (displayNamespace.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: HighlightTitle(
                      displayNamespace,
                      color: BrandColors.get(displayNamespace),
                      selectable: true,
                    ),
                  ),
                InfoRowGroup(
                  Map.fromEntries(entries),
                  maxValueLength: Constants.infoGroupMaxValueLength,
                  linkHandlers: linkHandlers,
                ),
              ];
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _openEmbeddedData(String propPath) async {
    final fields = await MetadataService.extractXmpDataProp(entry, propPath);
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

    final embedEntry = ImageEntry.fromMap(fields);
    unawaited(Navigator.push(
      context,
      TransparentMaterialPageRoute(
        settings: RouteSettings(name: SingleFullscreenPage.routeName),
        pageBuilder: (c, a, sa) => SingleFullscreenPage(entry: embedEntry),
      ),
    ));
  }
}

class _XmpNamespace {
  final String namespace;

  const _XmpNamespace(this.namespace);

  String get displayTitle => XMP.namespaces[namespace] ?? namespace;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _XmpNamespace && other.namespace == namespace;
  }

  @override
  int get hashCode => namespace.hashCode;

  @override
  String toString() {
    return '$runtimeType#${shortHash(this)}{namespace=$namespace}';
  }
}
