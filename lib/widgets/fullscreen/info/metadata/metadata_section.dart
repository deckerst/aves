import 'dart:collection';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/ref/brand_colors.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:aves/widgets/fullscreen/info/metadata/metadata_thumbnail.dart';
import 'package:aves/widgets/fullscreen/info/metadata/xmp_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MetadataSectionSliver extends StatefulWidget {
  final ImageEntry entry;
  final ValueNotifier<bool> visibleNotifier;

  const MetadataSectionSliver({
    @required this.entry,
    @required this.visibleNotifier,
  });

  @override
  State<StatefulWidget> createState() => _MetadataSectionSliverState();
}

class _MetadataSectionSliverState extends State<MetadataSectionSliver> with AutomaticKeepAliveClientMixin {
  Map<String, _MetadataDirectory> _metadata = {};
  final ValueNotifier<String> _loadedMetadataUri = ValueNotifier(null);
  final ValueNotifier<String> _expandedDirectoryNotifier = ValueNotifier(null);

  ImageEntry get entry => widget.entry;

  bool get isVisible => widget.visibleNotifier.value;

  // special directory names
  static const exifThumbnailDirectory = 'Exif Thumbnail'; // from metadata-extractor
  static const xmpDirectory = 'XMP'; // from metadata-extractor
  static const mediaDirectory = 'Media'; // additional media (video/audio/images) directory

  // directory names may contain the name of their parent directory
  // if so, they are separated by this character
  static const parentChildSeparator = '/';

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    _getMetadata();
  }

  @override
  void didUpdateWidget(MetadataSectionSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
    _getMetadata();
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(MetadataSectionSliver widget) {
    widget.visibleNotifier.addListener(_getMetadata);
    widget.entry.metadataChangeNotifier.addListener(_onMetadataChanged);
  }

  void _unregisterWidget(MetadataSectionSliver widget) {
    widget.visibleNotifier.removeListener(_getMetadata);
    widget.entry.metadataChangeNotifier.removeListener(_onMetadataChanged);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // use a `Column` inside a `SliverToBoxAdapter`, instead of a `SliverList`,
    // so that we can have the metadata-dependent `AnimationLimiter` inside the metadata section
    // warning: placing the `AnimationLimiter` as a parent to the `ScrollView`
    // triggers dispose & reinitialization of other sections, including heavy widgets like maps
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _loadedMetadataUri,
        builder: (context, child) {
          Widget content;
          if (_metadata.isEmpty) {
            content = SizedBox.shrink();
          } else {
            content = Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: Durations.staggeredAnimation,
                delay: Durations.staggeredAnimationDelay,
                childAnimationBuilder: (child) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: child,
                  ),
                ),
                children: [
                  SectionRow(AIcons.info),
                  ..._metadata.entries.map((kv) => _buildDirTile(kv.key, kv.value)),
                ],
              ),
            );
          }
          return AnimationLimiter(
            // we update the limiter key after fetching the metadata of a new entry,
            // in order to restart the staggered animation of the metadata section
            key: Key(_loadedMetadataUri.value),
            child: content,
          );
        },
      ),
    );
  }

  Widget _buildDirTile(String title, _MetadataDirectory dir) {
    final dirName = dir.name;
    if (dirName == xmpDirectory) {
      return XmpDirTile(
        entry: entry,
        tags: dir.tags,
        expandedNotifier: _expandedDirectoryNotifier,
      );
    }
    Widget thumbnail;
    final prefixChildren = <Widget>[];
    switch (dirName) {
      case exifThumbnailDirectory:
        thumbnail = MetadataThumbnails(source: MetadataThumbnailSource.exif, entry: entry);
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
      title: title,
      color: BrandColors.get(dirName) ?? stringToColor(dirName),
      expandedNotifier: _expandedDirectoryNotifier,
      children: [
        if (prefixChildren.isNotEmpty) Wrap(children: prefixChildren),
        if (thumbnail != null) thumbnail,
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup(dir.tags, maxValueLength: Constants.infoGroupMaxValueLength),
        ),
      ],
    );
  }

  void _onMetadataChanged() {
    _loadedMetadataUri.value = null;
    _metadata = {};
    _getMetadata();
  }

  Future<void> _getMetadata() async {
    if (entry == null) return;
    if (_loadedMetadataUri.value == entry.uri) return;
    if (isVisible) {
      final rawMetadata = await MetadataService.getAllMetadata(entry) ?? {};
      final directories = rawMetadata.entries.map((dirKV) {
        var directoryName = dirKV.key as String ?? '';

        String parent;
        final parts = directoryName.split(parentChildSeparator);
        if (parts.length > 1) {
          parent = parts[0];
          directoryName = parts[1];
        }

        final rawTags = dirKV.value as Map ?? {};
        final tags = SplayTreeMap.of(Map.fromEntries(rawTags.entries.map((tagKV) {
          final value = (tagKV.value as String ?? '').trim();
          if (value.isEmpty) return null;
          final tagName = tagKV.key as String ?? '';
          return MapEntry(tagName, value);
        }).where((kv) => kv != null)));
        return _MetadataDirectory(directoryName, parent, tags);
      }).toList();

      final titledDirectories = directories.map((dir) {
        var title = dir.name;
        if (directories.where((dir) => dir.name == title).length > 1 && dir.parent?.isNotEmpty == true) {
          title = '${dir.parent}/$title';
        }
        return MapEntry(title, dir);
      }).toList()
        ..sort((a, b) => compareAsciiUpperCase(a.key, b.key));
      _metadata = Map.fromEntries(titledDirectories);
      _loadedMetadataUri.value = entry.uri;
    } else {
      _metadata = {};
      _loadedMetadataUri.value = null;
    }
    _expandedDirectoryNotifier.value = null;
  }

  @override
  bool get wantKeepAlive => true;
}

class _MetadataDirectory {
  final String name;
  final String parent;
  final SplayTreeMap<String, String> tags;

  const _MetadataDirectory(this.name, this.parent, this.tags);
}
