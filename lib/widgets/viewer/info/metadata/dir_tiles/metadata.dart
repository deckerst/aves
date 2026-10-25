import 'dart:collection';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/ref/brand_colors.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/services/metadata/svg_metadata_service.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/metadata/dir_tiles/c2pa.dart';
import 'package:aves/widgets/viewer/info/metadata/dir_tiles/xmp.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_thumbnail.dart';
import 'package:aves/widgets/viewer/info/metadata/model/metadata_dir.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const MetadataDirTile({
  super.key,
  required final AvesEntry entry,
  required final String title,
  required final MetadataDirectory dir,
  final ValueNotifier<String?>? expandedDirectoryNotifier,
  final bool initiallyExpanded = false,
  final bool showThumbnails = true,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var tags = dir.tags;
    if (tags.isEmpty) return const SizedBox();

    return AvesExpansionTile(
      title: title,
      trailing: _buildTrailing(context, dir),
      locale: KnownLocale.english,
      highlightColor: getTitleColor(context, dir),
      expandedNotifier: expandedDirectoryNotifier,
      initiallyExpanded: initiallyExpanded,
      children: [
        MetadataDirTileBody(
          entry: entry,
          dir: dir,
          showThumbnails: showThumbnails,
        ),
      ],
    );
  }

  static Widget? _buildTrailing(BuildContext context, MetadataDirectory dir) {
    switch (dir.name) {
      case MetadataDirectory.c2paDirectory:
        final validityString = dir.tags['validity'];
        final validity = C2paValidity.values.safeByName(validityString, ignoreCase: true) ?? .unknown;
        return Icon(validity.getIconData());
      default:
        return null;
    }
  }

  static Color getTitleColor(BuildContext context, MetadataDirectory dir) {
    final dirName = dir.name;
    switch (dirName) {
      case MetadataDirectory.xmpDirectory:
        return context.select<AvesColorsData, Color>((v) => v.xmp);
      default:
        final colors = context.watch<AvesColorsData>();
        return dir.color ?? colors.fromBrandColor(BrandColors.get(dirName)) ?? colors.fromString(dirName);
    }
  }
}

class const MetadataDirTileBody({
  super.key,
  required final AvesEntry entry,
  required final MetadataDirectory dir,
  final bool showThumbnails = true,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var tags = dir.tags;

    late final List<Widget> children;
    final dirName = dir.name;
    switch (dirName) {
      case MetadataDirectory.c2paDirectory:
        children = [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: C2paDirTileBody(
              tags: tags,
            ),
          ),
        ];
      case MetadataDirectory.xmpDirectory:
        children = [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: XmpDirTileBody(
              allTags: dir.allTags,
              tags: tags,
            ),
          ),
        ];
      default:
        Map<String, InfoValueSpanBuilder>? linkHandlers;
        switch (dirName) {
          case SvgMetadataService.metadataDirectory:
            linkHandlers = getSvgLinkHandlers(tags);
          case MetadataDirectory.coverDirectory:
            linkHandlers = getVideoCoverLinkHandlers(tags);
        }

        children = [
          if (showThumbnails && dirName == MetadataDirectory.exifThumbnailDirectory) MetadataThumbnails(entry: entry),
          if (dirName.startsWith(MetadataDirectory.mpfImageDirectoryPrefix))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AvesOutlinedButton(
                label: context.l10n.viewerInfoOpenLinkText,
                onPressed: () {
                  final id = int.tryParse(dirName.substring(MetadataDirectory.mpfImageDirectoryPrefix.length));
                  if (id != null) {
                    OpenEmbeddedDataNotification.mpf(id).dispatch(context);
                  }
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: InfoRowGroup(
              info: tags,
              spanBuilders: linkHandlers,
            ),
          ),
        ];
    }

    return Column(
      crossAxisAlignment: .start,
      children: children,
    );
  }

  static Map<String, InfoValueSpanBuilder> getSvgLinkHandlers(SplayTreeMap<String, String> tags) {
    return {
      'Metadata': InfoRowGroup.linkSpanBuilder(
        linkText: (context) => context.l10n.viewerInfoViewXmlLinkText,
        onTap: (context) {
          Navigator.maybeOf(context)?.push(
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
