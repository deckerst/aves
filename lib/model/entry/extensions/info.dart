import 'dart:async';
import 'dart:collection';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/media/video/metadata.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/metadata/svg_metadata_service.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension ExtraAvesEntryInfo on AvesEntry {
  // directory names may contain the name of their parent directory (as prefix + '/')
  // directory names may contain an index (as suffix in '[]')
  static final directoryNamePattern = RegExp(r'^((?<parent>.*?)/)?(?<name>.*?)(\[(?<index>\d+)\])?$');

  Future<List<MapEntry<String, MetadataDirectory>>> getMetadataDirectories(BuildContext context) async {
    final rawMetadata = await (isSvg ? SvgMetadataService.getAllMetadata(this) : metadataFetchService.getAllMetadata(this));
    final directories = rawMetadata.entries.map((dirKV) {
      var directoryName = dirKV.key as String;

      String? parent;
      int? index;
      final match = directoryNamePattern.firstMatch(directoryName);
      if (match != null) {
        parent = match.namedGroup('parent');
        final nameMatch = match.namedGroup('name');
        if (nameMatch != null) {
          directoryName = nameMatch;
        }
        final indexMatch = match.namedGroup('index');
        if (indexMatch != null) {
          index = int.tryParse(indexMatch);
        }
      }

      final rawTags = dirKV.value as Map;
      return MetadataDirectory(
        directoryName,
        _toSortedTags(rawTags),
        parent: parent,
        index: index,
      );
    }).toList();

    if (isVideo || (mimeType == MimeTypes.heif && isMultiPage)) {
      directories.addAll(await _getStreamDirectories(context));
    }

    final titledDirectories = directories.map((dir) {
      var title = dir.name;
      if (directories.where((dir) => dir.name == title).length > 1 && dir.parent?.isNotEmpty == true) {
        title = '${dir.parent}/$title';
      }
      if (dir.index != null) {
        title += ' ${dir.index}';
      }
      return MapEntry(title, dir);
    }).toList()
      ..sort((a, b) => compareAsciiUpperCase(a.key, b.key));

    return titledDirectories;
  }

  Future<List<MetadataDirectory>> _getStreamDirectories(BuildContext context) async {
    final directories = <MetadataDirectory>[];
    final mediaInfo = await videoMetadataFetcher.getMetadata(this);
    if (!context.mounted) {
      return directories;
    }

    final formattedMediaTags = VideoMetadataFormatter.formatInfo(mediaInfo);
    if (formattedMediaTags.isNotEmpty) {
      // overwrite generic directory found from the platform side
      directories.add(MetadataDirectory(MetadataDirectory.mediaDirectory, _toSortedTags(formattedMediaTags)));
    }

    if (mediaInfo.containsKey(Keys.streams)) {
      String getTypeText(Map stream) {
        final type = stream[Keys.streamType] ?? MediaStreamTypes.unknown;
        switch (type) {
          case MediaStreamTypes.attachment:
            return 'Attachment';
          case MediaStreamTypes.audio:
            return 'Audio';
          case MediaStreamTypes.metadata:
            return 'Metadata';
          case MediaStreamTypes.subtitle:
          case MediaStreamTypes.timedText:
            return 'Text';
          case MediaStreamTypes.video:
            return stream.containsKey(Keys.fpsDen) ? 'Video' : 'Image';
          case MediaStreamTypes.unknown:
          default:
            return 'Unknown';
        }
      }

      final allStreams = (mediaInfo[Keys.streams] as List).cast<Map>();
      final attachmentStreams = allStreams.where((stream) => stream[Keys.streamType] == MediaStreamTypes.attachment).toList();
      final knownStreams = allStreams.whereNot(attachmentStreams.contains);

      // display known streams as separate directories (e.g. video, audio, subs)
      if (knownStreams.isNotEmpty) {
        final indexDigits = knownStreams.length.toString().length;

        final colors = context.read<AvesColorsData>();
        for (final stream in knownStreams) {
          final index = (stream[Keys.index] ?? 0) + 1;
          final typeText = getTypeText(stream);
          final dirName = [
            'Stream ${index.toString().padLeft(indexDigits, '0')}',
            typeText,
          ].join(AText.separator);
          final formattedStreamTags = VideoMetadataFormatter.formatInfo(stream);
          if (formattedStreamTags.isNotEmpty) {
            final color = colors.fromString(typeText);
            directories.add(MetadataDirectory(dirName, _toSortedTags(formattedStreamTags), color: color));
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
            final names = value.nonNulls.toSet().toList()..sort(compareAsciiUpperCase);
            return MapEntry(key, '$count items: ${names.join(', ')}');
          });
          directories.add(MetadataDirectory('Attachments', _toSortedTags(rawTags)));
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
    }).nonNulls));
    return tags;
  }
}
