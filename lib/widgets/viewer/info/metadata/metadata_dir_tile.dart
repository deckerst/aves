import 'dart:collection';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/brand_colors.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/services.dart';
import 'package:aves/services/svg_metadata_service.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/pedantic.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_thumbnail.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_tile.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MetadataDirTile extends StatelessWidget with FeedbackMixin {
  final AvesEntry entry;
  final String title;
  final MetadataDirectory dir;
  final ValueNotifier<String?>? expandedDirectoryNotifier;
  final bool initiallyExpanded, showThumbnails;

  const MetadataDirTile({
    Key? key,
    required this.entry,
    required this.title,
    required this.dir,
    this.expandedDirectoryNotifier,
    this.initiallyExpanded = false,
    this.showThumbnails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tags = dir.tags;
    if (tags.isEmpty) return const SizedBox.shrink();

    final dirName = dir.name;
    Widget tile;
    if (dirName == MetadataDirectory.xmpDirectory) {
      tile = XmpDirTile(
        entry: entry,
        tags: tags,
        expandedNotifier: expandedDirectoryNotifier,
        initiallyExpanded: initiallyExpanded,
      );
    } else {
      Map<String, InfoLinkHandler>? linkHandlers;
      switch (dirName) {
        case SvgMetadataService.metadataDirectory:
          linkHandlers = getSvgLinkHandlers(tags);
          break;
        case MetadataDirectory.coverDirectory:
          linkHandlers = getVideoCoverLinkHandlers(tags);
          break;
      }

      tile = AvesExpansionTile(
        title: title,
        color: dir.color ?? BrandColors.get(dirName) ?? stringToColor(dirName),
        expandedNotifier: expandedDirectoryNotifier,
        initiallyExpanded: initiallyExpanded,
        children: [
          if (showThumbnails && dirName == MetadataDirectory.exifThumbnailDirectory) MetadataThumbnails(entry: entry),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: InfoRowGroup(
              info: tags,
              maxValueLength: Constants.infoGroupMaxValueLength,
              linkHandlers: linkHandlers,
            ),
          ),
        ],
      );
    }
    return NotificationListener<OpenEmbeddedDataNotification>(
      onNotification: (notification) {
        _openEmbeddedData(context, notification);
        return true;
      },
      child: tile,
    );
  }

  static Map<String, InfoLinkHandler> getSvgLinkHandlers(SplayTreeMap<String, String> tags) {
    return {
      'Metadata': InfoLinkHandler(
        linkText: (context) => context.l10n.viewerInfoViewXmlLinkText,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: SourceViewerPage.routeName),
              builder: (context) => SourceViewerPage(
                loader: () => SynchronousFuture(tags['Metadata'] ?? ''),
              ),
            ),
          );
        },
      ),
    };
  }

  static Map<String, InfoLinkHandler> getVideoCoverLinkHandlers(SplayTreeMap<String, String> tags) {
    return {
      'Image': InfoLinkHandler(
        linkText: (context) => context.l10n.viewerInfoOpenLinkText,
        onTap: (context) => OpenEmbeddedDataNotification.videoCover().dispatch(context),
      ),
    };
  }

  Future<void> _openEmbeddedData(BuildContext context, OpenEmbeddedDataNotification notification) async {
    late Map fields;
    switch (notification.source) {
      case EmbeddedDataSource.motionPhotoVideo:
        fields = await embeddedDataService.extractMotionPhotoVideo(entry);
        break;
      case EmbeddedDataSource.videoCover:
        fields = await embeddedDataService.extractVideoEmbeddedPicture(entry);
        break;
      case EmbeddedDataSource.xmp:
        fields = await embeddedDataService.extractXmpDataProp(entry, notification.propPath, notification.mimeType);
        break;
    }
    if (!fields.containsKey('mimeType') || !fields.containsKey('uri')) {
      showFeedback(context, context.l10n.viewerInfoOpenEmbeddedFailureFeedback);
      return;
    }

    final mimeType = fields['mimeType']!;
    final uri = fields['uri']!;
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
