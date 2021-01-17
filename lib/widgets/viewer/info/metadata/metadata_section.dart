import 'dart:collection';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/services/svg_metadata_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MetadataSectionSliver extends StatefulWidget {
  final ImageEntry entry;
  final ValueNotifier<bool> visibleNotifier;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;

  const MetadataSectionSliver({
    @required this.entry,
    @required this.visibleNotifier,
    @required this.metadataNotifier,
  });

  @override
  State<StatefulWidget> createState() => _MetadataSectionSliverState();
}

class _MetadataSectionSliverState extends State<MetadataSectionSliver> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<String> _loadedMetadataUri = ValueNotifier(null);
  final ValueNotifier<String> _expandedDirectoryNotifier = ValueNotifier(null);

  ImageEntry get entry => widget.entry;

  bool get isVisible => widget.visibleNotifier.value;

  ValueNotifier<Map<String, MetadataDirectory>> get metadataNotifier => widget.metadataNotifier;

  Map<String, MetadataDirectory> get metadata => metadataNotifier.value;

  // directory names may contain the name of their parent directory
  // if so, they are separated by this character
  static const parentChildSeparator = '/';

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    metadataNotifier.value = {};
    _getMetadata();
  }

  @override
  void didUpdateWidget(covariant MetadataSectionSliver oldWidget) {
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
      child: NotificationListener<ScrollNotification>(
        // cancel notification bubbling so that the info page
        // does not misinterpret content scrolling for page scrolling
        onNotification: (notification) => true,
        child: ValueListenableBuilder<String>(
          valueListenable: _loadedMetadataUri,
          builder: (context, uri, child) {
            Widget content;
            if (metadata.isEmpty) {
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
                    ...metadata.entries.map((kv) => MetadataDirTile(
                          entry: entry,
                          title: kv.key,
                          dir: kv.value,
                          expandedDirectoryNotifier: _expandedDirectoryNotifier,
                        )),
                  ],
                ),
              );
            }
            return AnimationLimiter(
              // we update the limiter key after fetching the metadata of a new entry,
              // in order to restart the staggered animation of the metadata section
              key: Key(uri),
              child: content,
            );
          },
        ),
      ),
    );
  }

  void _onMetadataChanged() {
    _loadedMetadataUri.value = null;
    metadataNotifier.value = {};
    _getMetadata();
  }

  Future<void> _getMetadata() async {
    if (entry == null) return;
    if (_loadedMetadataUri.value == entry.uri) return;
    if (isVisible) {
      final rawMetadata = await (entry.isSvg ? SvgMetadataService.getAllMetadata(entry) : MetadataService.getAllMetadata(entry)) ?? {};
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
        return MetadataDirectory(directoryName, parent, tags);
      }).toList();

      final titledDirectories = directories.map((dir) {
        var title = dir.name;
        if (directories.where((dir) => dir.name == title).length > 1 && dir.parent?.isNotEmpty == true) {
          title = '${dir.parent}/$title';
        }
        return MapEntry(title, dir);
      }).toList()
        ..sort((a, b) => compareAsciiUpperCase(a.key, b.key));
      metadataNotifier.value = Map.fromEntries(titledDirectories);
      _loadedMetadataUri.value = entry.uri;
    } else {
      metadataNotifier.value = {};
      _loadedMetadataUri.value = null;
    }
    _expandedDirectoryNotifier.value = null;
  }

  @override
  bool get wantKeepAlive => true;
}

class MetadataDirectory {
  final String name;
  final String parent;
  final SplayTreeMap<String, String> allTags;
  final SplayTreeMap<String, String> tags;

  // special directory names
  static const exifThumbnailDirectory = 'Exif Thumbnail'; // from metadata-extractor
  static const xmpDirectory = 'XMP'; // from metadata-extractor
  static const mediaDirectory = 'Media'; // additional media (video/audio/images) directory

  const MetadataDirectory(this.name, this.parent, SplayTreeMap<String, String> allTags, {SplayTreeMap<String, String> tags})
      : allTags = allTags,
        tags = tags ?? allTags;

  MetadataDirectory filterKeys(bool Function(String key) testKey) {
    final filteredTags = SplayTreeMap.of(Map.fromEntries(allTags.entries.where((kv) => testKey(kv.key))));
    return MetadataDirectory(name, parent, tags, tags: filteredTags);
  }
}
