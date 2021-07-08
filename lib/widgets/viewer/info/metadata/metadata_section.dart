import 'dart:async';
import 'dart:collection';

import 'package:aves/model/entry.dart';
import 'package:aves/model/video/keys.dart';
import 'package:aves/model/video/metadata.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/services.dart';
import 'package:aves/services/svg_metadata_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MetadataSectionSliver extends StatefulWidget {
  final AvesEntry entry;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;

  const MetadataSectionSliver({
    Key? key,
    required this.entry,
    required this.metadataNotifier,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MetadataSectionSliverState();
}

class _MetadataSectionSliverState extends State<MetadataSectionSliver> {
  final ValueNotifier<String?> _expandedDirectoryNotifier = ValueNotifier(null);

  AvesEntry get entry => widget.entry;

  ValueNotifier<Map<String, MetadataDirectory>> get metadataNotifier => widget.metadataNotifier;

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
    widget.entry.metadataChangeNotifier.addListener(_onMetadataChanged);
  }

  void _unregisterWidget(MetadataSectionSliver widget) {
    widget.entry.metadataChangeNotifier.removeListener(_onMetadataChanged);
  }

  @override
  Widget build(BuildContext context) {
    // use a `Column` inside a `SliverToBoxAdapter`, instead of a `SliverList`,
    // so that we can have the metadata-dependent `AnimationLimiter` inside the metadata section
    // warning: placing the `AnimationLimiter` as a parent to the `ScrollView`
    // triggers dispose & reinitialization of other sections, including heavy widgets like maps
    return SliverToBoxAdapter(
      child: NotificationListener<ScrollNotification>(
        // cancel notification bubbling so that the info page
        // does not misinterpret content scrolling for page scrolling
        onNotification: (notification) => true,
        child: ValueListenableBuilder<Map<String, MetadataDirectory>>(
            valueListenable: metadataNotifier,
            builder: (context, metadata, child) {
              Widget content;
              if (metadata.isEmpty) {
                content = const SizedBox.shrink();
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
                      const SectionRow(icon: AIcons.info),
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
                key: ValueKey(metadata.length),
                child: content,
              );
            }),
      ),
    );
  }

  void _onMetadataChanged() {
    metadataNotifier.value = {};
    _getMetadata();
  }

  Future<void> _getMetadata() async {
    final rawMetadata = await (entry.isSvg ? SvgMetadataService.getAllMetadata(entry) : metadataService.getAllMetadata(entry));
    final directories = rawMetadata.entries.map((dirKV) {
      var directoryName = dirKV.key as String;

      String? parent;
      final parts = directoryName.split(parentChildSeparator);
      if (parts.length > 1) {
        parent = parts[0];
        directoryName = parts[1];
      }

      final rawTags = dirKV.value as Map;
      return MetadataDirectory(directoryName, parent, _toSortedTags(rawTags));
    }).toList();

    if (entry.isVideo || (entry.mimeType == MimeTypes.heif && entry.isMultiPage)) {
      directories.addAll(await _getStreamDirectories());
    }

    final titledDirectories = directories.map((dir) {
      var title = dir.name;
      if (directories.where((dir) => dir.name == title).length > 1 && dir.parent?.isNotEmpty == true) {
        title = '${dir.parent}/$title';
      }
      return MapEntry(title, dir);
    }).toList()
      ..sort((a, b) => compareAsciiUpperCase(a.key, b.key));
    metadataNotifier.value = Map.fromEntries(titledDirectories);
    _expandedDirectoryNotifier.value = null;
  }

  Future<List<MetadataDirectory>> _getStreamDirectories() async {
    final directories = <MetadataDirectory>[];
    final mediaInfo = await VideoMetadataFormatter.getVideoMetadata(entry);

    final formattedMediaTags = VideoMetadataFormatter.formatInfo(mediaInfo);
    if (formattedMediaTags.isNotEmpty) {
      // overwrite generic directory found from the platform side
      directories.add(MetadataDirectory(MetadataDirectory.mediaDirectory, null, _toSortedTags(formattedMediaTags)));
    }

    if (mediaInfo.containsKey(Keys.streams)) {
      String getTypeText(Map stream) {
        final type = stream[Keys.streamType] ?? StreamTypes.unknown;
        switch (type) {
          case StreamTypes.attachment:
            return 'Attachment';
          case StreamTypes.audio:
            return 'Audio';
          case StreamTypes.metadata:
            return 'Metadata';
          case StreamTypes.subtitle:
          case StreamTypes.timedText:
            return 'Text';
          case StreamTypes.video:
            return stream.containsKey(Keys.fpsDen) ? 'Video' : 'Image';
          case StreamTypes.unknown:
          default:
            return 'Unknown';
        }
      }

      final allStreams = (mediaInfo[Keys.streams] as List).cast<Map>();
      final attachmentStreams = allStreams.where((stream) => stream[Keys.streamType] == StreamTypes.attachment).toList();
      final knownStreams = allStreams.whereNot(attachmentStreams.contains);

      // display known streams as separate directories (e.g. video, audio, subs)
      if (knownStreams.isNotEmpty) {
        final indexDigits = knownStreams.length.toString().length;

        for (final stream in knownStreams) {
          final index = (stream[Keys.index] ?? 0) + 1;
          final typeText = getTypeText(stream);
          final dirName = 'Stream ${index.toString().padLeft(indexDigits, '0')} • $typeText';
          final formattedStreamTags = VideoMetadataFormatter.formatInfo(stream);
          if (formattedStreamTags.isNotEmpty) {
            final color = stringToColor(typeText);
            directories.add(MetadataDirectory(dirName, null, _toSortedTags(formattedStreamTags), color: color));
          }
        }
      }

      // group attachments by format (e.g. TTF fonts)
      if (attachmentStreams.isNotEmpty) {
        final formatCount = <String, List<String?>>{};
        for (final stream in attachmentStreams) {
          final codec = (stream[Keys.codecName] as String? ?? 'unknown').toUpperCase();
          if (!formatCount.containsKey(codec)) {
            formatCount[codec] = [];
          }
          formatCount[codec]!.add(stream[Keys.filename]);
        }
        if (formatCount.isNotEmpty) {
          final rawTags = formatCount.map((key, value) {
            final count = value.length;
            // remove duplicate names, so number of displayed names may not match displayed count
            final names = value.whereNotNull().toSet().toList()..sort(compareAsciiUpperCase);
            return MapEntry(key, '$count items: ${names.join(', ')}');
          });
          directories.add(MetadataDirectory('Attachments', null, _toSortedTags(rawTags)));
        }
      }
    }
    return directories;
  }

  SplayTreeMap<String, String> _toSortedTags(Map rawTags) {
    final tags = SplayTreeMap.of(Map.fromEntries(rawTags.entries.map((tagKV) {
      var value = (tagKV.value as String? ?? '').trim();
      if (value.isEmpty) return null;
      final tagName = tagKV.key as String;
      return MapEntry(tagName, value);
    }).whereNotNull()));
    return tags;
  }
}

class MetadataDirectory {
  final String name;
  final Color? color;
  final String? parent;
  final SplayTreeMap<String, String> allTags;
  final SplayTreeMap<String, String> tags;

  // special directory names
  static const exifThumbnailDirectory = 'Exif Thumbnail'; // from metadata-extractor
  static const xmpDirectory = 'XMP'; // from metadata-extractor
  static const mediaDirectory = 'Media'; // custom
  static const coverDirectory = 'Cover'; // custom

  const MetadataDirectory(
    this.name,
    this.parent,
    this.allTags, {
    SplayTreeMap<String, String>? tags,
    this.color,
  }) : tags = tags ?? allTags;

  MetadataDirectory filterKeys(bool Function(String key) testKey) {
    final filteredTags = SplayTreeMap.of(Map.fromEntries(allTags.entries.where((kv) => testKey(kv.key))));
    return MetadataDirectory(name, parent, tags, tags: filteredTags, color: color);
  }
}
