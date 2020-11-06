import 'dart:collection';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/aves_expansion_tile.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:aves/widgets/fullscreen/info/metadata_thumbnail.dart';
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
  List<_MetadataDirectory> _metadata = [];
  final ValueNotifier<String> _loadedMetadataUri = ValueNotifier(null);
  final ValueNotifier<String> _expandedDirectoryNotifier = ValueNotifier(null);

  ImageEntry get entry => widget.entry;

  bool get isVisible => widget.visibleNotifier.value;

  // special directory names
  static const exifThumbnailDirectory = 'Exif Thumbnail'; // from metadata-extractor
  static const xmpDirectory = 'XMP'; // from metadata-extractor
  static const mediaDirectory = 'Media'; // additional media (video/audio/images) directory

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
            final directoriesWithoutTitle = _metadata.where((dir) => dir.name.isEmpty).toList();
            final directoriesWithTitle = _metadata.where((dir) => dir.name.isNotEmpty).toList();
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
                  ...directoriesWithoutTitle.map(_buildDirTileWithoutTitle),
                  ...directoriesWithTitle.map(_buildDirTileWithTitle),
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

  Widget _buildDirTileWithoutTitle(_MetadataDirectory dir) {
    return InfoRowGroup(dir.tags, maxValueLength: Constants.infoGroupMaxValueLength);
  }

  Widget _buildDirTileWithTitle(_MetadataDirectory dir) {
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
          Wrap(children: prefixChildren),
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
    _metadata = [];
    _getMetadata();
  }

  Future<void> _getMetadata() async {
    if (entry == null) return;
    if (_loadedMetadataUri.value == entry.uri) return;
    if (isVisible) {
      final rawMetadata = await MetadataService.getAllMetadata(entry) ?? {};
      _metadata = rawMetadata.entries.map((dirKV) {
        final directoryName = dirKV.key as String ?? '';
        final rawTags = dirKV.value as Map ?? {};
        final tags = SplayTreeMap.of(Map.fromEntries(rawTags.entries.map((tagKV) {
          final value = tagKV.value as String ?? '';
          if (value.isEmpty) return null;
          final tagName = tagKV.key as String ?? '';
          return MapEntry(tagName, value);
        }).where((kv) => kv != null)));
        return _MetadataDirectory(directoryName, tags);
      }).toList()
        ..sort((a, b) => compareAsciiUpperCase(a.name, b.name));
      _loadedMetadataUri.value = entry.uri;
    } else {
      _metadata = [];
      _loadedMetadataUri.value = null;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _MetadataDirectory {
  final String name;
  final SplayTreeMap<String, String> tags;

  const _MetadataDirectory(this.name, this.tags);
}
