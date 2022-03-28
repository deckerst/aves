import 'dart:collection';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/brand_colors.dart';
import 'package:aves/services/metadata/svg_metadata_service.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_thumbnail.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_tile.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MetadataDirTile extends StatelessWidget {
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
    if (dirName == MetadataDirectory.xmpDirectory) {
      return XmpDirTile(
        entry: entry,
        title: title,
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

      final colors = context.watch<AvesColorsData>();
      return AvesExpansionTile(
        title: title,
        highlightColor: dir.color ?? colors.fromBrandColor(BrandColors.get(dirName)) ?? colors.fromString(dirName),
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
}
