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
import 'package:aves/widgets/viewer/info/metadata/geotiff.dart';
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
    super.key,
    required this.entry,
    required this.title,
    required this.dir,
    this.expandedDirectoryNotifier,
    this.initiallyExpanded = false,
    this.showThumbnails = true,
  });

  @override
  Widget build(BuildContext context) {
    var tags = dir.tags;
    if (tags.isEmpty) return const SizedBox();

    final dirName = dir.name;
    if (dirName == MetadataDirectory.xmpDirectory) {
      return XmpDirTile(
        entry: entry,
        title: title,
        allTags: dir.allTags,
        tags: tags,
        expandedNotifier: expandedDirectoryNotifier,
        initiallyExpanded: initiallyExpanded,
      );
    } else {
      Map<String, InfoValueSpanBuilder>? linkHandlers;
      switch (dirName) {
        case SvgMetadataService.metadataDirectory:
          linkHandlers = getSvgLinkHandlers(tags);
          break;
        case MetadataDirectory.coverDirectory:
          linkHandlers = getVideoCoverLinkHandlers(tags);
          break;
        case MetadataDirectory.geoTiffDirectory:
          tags = SplayTreeMap.from(tags.map((name, value) {
            final tag = GeoTiffDirectory.tagForName(name);
            return MapEntry(name, GeoTiffDirectory.formatValue(tag, value));
          }));
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
              spanBuilders: linkHandlers,
            ),
          ),
        ],
      );
    }
  }

  static Map<String, InfoValueSpanBuilder> getSvgLinkHandlers(SplayTreeMap<String, String> tags) {
    return {
      'Metadata': InfoRowGroup.linkSpanBuilder(
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

  static Map<String, InfoValueSpanBuilder> getVideoCoverLinkHandlers(SplayTreeMap<String, String> tags) {
    return {
      'Image': InfoRowGroup.linkSpanBuilder(
        linkText: (context) => context.l10n.viewerInfoOpenLinkText,
        onTap: (context) => OpenEmbeddedDataNotification.videoCover().dispatch(context),
      ),
    };
  }
}
