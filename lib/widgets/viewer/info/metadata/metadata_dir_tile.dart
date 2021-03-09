import 'dart:collection';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/brand_colors.dart';
import 'package:aves/services/svg_metadata_service.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_thumbnail.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_tile.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MetadataDirTile extends StatelessWidget {
  final AvesEntry entry;
  final String title;
  final MetadataDirectory dir;
  final ValueNotifier<String> expandedDirectoryNotifier;
  final bool initiallyExpanded, showPrefixChildren;

  const MetadataDirTile({
    @required this.entry,
    @required this.title,
    @required this.dir,
    this.expandedDirectoryNotifier,
    this.initiallyExpanded = false,
    this.showPrefixChildren = true,
  });

  @override
  Widget build(BuildContext context) {
    final tags = dir.tags;
    if (tags.isEmpty) return SizedBox.shrink();

    final dirName = dir.name;
    if (dirName == MetadataDirectory.xmpDirectory) {
      return XmpDirTile(
        entry: entry,
        tags: tags,
        expandedNotifier: expandedDirectoryNotifier,
        initiallyExpanded: initiallyExpanded,
      );
    }

    Widget thumbnail;
    final prefixChildren = <Widget>[];
    if (showPrefixChildren) {
      switch (dirName) {
        case MetadataDirectory.exifThumbnailDirectory:
          thumbnail = MetadataThumbnails(source: MetadataThumbnailSource.exif, entry: entry);
          break;
        case MetadataDirectory.mediaDirectory:
          thumbnail = MetadataThumbnails(source: MetadataThumbnailSource.embedded, entry: entry);
          Widget builder(IconData data) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Icon(data),
              );
          if (tags['Has Video'] == 'yes') prefixChildren.add(builder(AIcons.video));
          if (tags['Has Audio'] == 'yes') prefixChildren.add(builder(AIcons.audio));
          if (tags['Has Image'] == 'yes') prefixChildren.add(builder(AIcons.image));
          break;
      }
    }

    return AvesExpansionTile(
      title: title,
      color: BrandColors.get(dirName) ?? stringToColor(dirName),
      expandedNotifier: expandedDirectoryNotifier,
      initiallyExpanded: initiallyExpanded,
      children: [
        if (prefixChildren.isNotEmpty) Wrap(children: prefixChildren),
        if (thumbnail != null) thumbnail,
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup(
            tags,
            maxValueLength: Constants.infoGroupMaxValueLength,
            linkHandlers: dirName == SvgMetadataService.metadataDirectory ? getSvgLinkHandlers(tags) : null,
          ),
        ),
      ],
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
              settings: RouteSettings(name: SourceViewerPage.routeName),
              builder: (context) => SourceViewerPage(
                loader: () => SynchronousFuture(tags['Metadata']),
              ),
            ),
          );
        },
      ),
    };
  }
}
