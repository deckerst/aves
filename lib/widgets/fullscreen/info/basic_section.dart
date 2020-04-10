import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicSection extends StatelessWidget {
  final ImageEntry entry;
  final CollectionLens collection;
  final FilterCallback onFilter;

  const BasicSection({
    Key key,
    @required this.entry,
    this.collection,
    @required this.onFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = entry.bestDate;
    final dateText = date != null ? '${DateFormat.yMMMd().format(date)} • ${DateFormat.Hm().format(date)}' : '?';
    final showMegaPixels = !entry.isVideo && !entry.isGif && entry.megaPixels != null && entry.megaPixels > 0;
    final resolutionText = '${entry.width ?? '?'} × ${entry.height ?? '?'}${showMegaPixels ? ' (${entry.megaPixels} MP)' : ''}';

    final tags = entry.xmpSubjects..sort(compareAsciiUpperCase);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRowGroup({
          'Title': entry.bestTitle ?? '?',
          'Date': dateText,
          if (entry.isVideo) ..._buildVideoRows(),
          if (!entry.isSvg) 'Resolution': resolutionText,
          'Size': entry.sizeBytes != null ? formatFilesize(entry.sizeBytes) : '?',
          'URI': entry.uri ?? '?',
          if (entry.path != null) 'Path': entry.path,
        }),
        ValueListenableBuilder<bool>(
          valueListenable: entry.isFavouriteNotifier,
          builder: (context, isFavourite, child) {
            final album = entry.directory;
            final filters = [
              if (entry.isVideo) MimeFilter(MimeTypes.ANY_VIDEO),
              if (entry.isGif) MimeFilter(MimeTypes.GIF),
              if (isFavourite) FavouriteFilter(),
              if (album != null) AlbumFilter(album, collection?.source?.getUniqueAlbumName(album)),
              ...tags.map((tag) => TagFilter(tag)),
            ]..sort();
            if (filters.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.buttonBorderWidth / 2) + const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                children: filters
                    .map((filter) => AvesFilterChip(
                          filter: filter,
                          onPressed: onFilter,
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Map<String, String> _buildVideoRows() {
    final rotation = entry.catalogMetadata?.videoRotation;
    return {
      'Duration': entry.durationText,
      if (rotation != null) 'Rotation': '$rotation°',
    };
  }
}
