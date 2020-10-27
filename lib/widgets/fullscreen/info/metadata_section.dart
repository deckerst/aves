import 'dart:collection';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/aves_expansion_tile.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:aves/widgets/fullscreen/info/metadata_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MetadataSectionSliver extends StatefulWidget {
  final ImageEntry entry;
  final List<MetadataDirectory> metadata;

  const MetadataSectionSliver({
    @required this.entry,
    @required this.metadata,
  });

  @override
  State<StatefulWidget> createState() => metadataSectionSliverState();
}

class metadataSectionSliverState extends State<MetadataSectionSliver> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<String> _expandedDirectoryNotifier = ValueNotifier(null);

  ImageEntry get entry => widget.entry;

  List<MetadataDirectory> get metadata => widget.metadata;

  // special directory names
  static const exifThumbnailDirectory = 'Exif Thumbnail'; // from metadata-extractor
  static const xmpDirectory = 'XMP'; // from metadata-extractor
  static const mediaDirectory = 'Media'; // additional media (video/audio/images) directory

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (metadata.isEmpty) return SliverToBoxAdapter(child: SizedBox.shrink());

    final directoriesWithoutTitle = metadata.where((dir) => dir.name.isEmpty).toList();
    final directoriesWithTitle = metadata.where((dir) => dir.name.isNotEmpty).toList();
    final untitledDirectoryCount = directoriesWithoutTitle.length;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          Widget child;
          if (index == 0) {
            child = SectionRow(AIcons.info);
          } else if (index < untitledDirectoryCount + 1) {
            child = _buildDirTileWithoutTitle(directoriesWithoutTitle[index - 1]);
          } else {
            child = _buildDirTileWithTitle(directoriesWithTitle[index - 1 - untitledDirectoryCount]);
          }
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Durations.staggeredAnimation,
            delay: Durations.staggeredAnimationDelay,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: child,
              ),
            ),
          );
        },
        childCount: 1 + metadata.length,
      ),
    );
  }

  Widget _buildDirTileWithoutTitle(MetadataDirectory dir) {
    return InfoRowGroup(dir.tags, maxValueLength: Constants.infoGroupMaxValueLength);
  }

  Widget _buildDirTileWithTitle(MetadataDirectory dir) {
    Widget thumbnail;
    final prefixChildren = <Widget>[];
    switch (dir.name) {
      case exifThumbnailDirectory:
        thumbnail = MetadataThumbnails(source: MetadataThumbnailSource.exif, entry: entry);
        break;
      case xmpDirectory:
        thumbnail = MetadataThumbnails(source: MetadataThumbnailSource.xmp, entry: entry);
        break;
      case mediaDirectory:
        thumbnail = MetadataThumbnails(source: MetadataThumbnailSource.embedded, entry: entry);
        Widget builder(IconData data) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Icon(data),
            );
        if (dir.tags['Has Video'] == 'yes') prefixChildren.add(builder(AIcons.video));
        if (dir.tags['Has Audio'] == 'yes') prefixChildren.add(builder(AIcons.audio));
        if (dir.tags['Has Image'] == 'yes') {
          int count;
          if (dir.tags.containsKey('Image Count')) {
            count = int.tryParse(dir.tags['Image Count']);
          }
          prefixChildren.addAll(List.generate(count ?? 1, (i) => builder(AIcons.image)));
        }
        break;
    }

    return AvesExpansionTile(
      title: dir.name,
      expandedNotifier: _expandedDirectoryNotifier,
      children: [
        if (prefixChildren.isNotEmpty)
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Wrap(children: prefixChildren),
          ),
        if (thumbnail != null) thumbnail,
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup(dir.tags, maxValueLength: Constants.infoGroupMaxValueLength),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MetadataDirectory {
  final String name;
  final SplayTreeMap<String, String> tags;

  const MetadataDirectory(this.name, this.tags);
}
