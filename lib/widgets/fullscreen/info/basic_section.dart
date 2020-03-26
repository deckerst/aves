import 'package:aves/model/collection_filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicSection extends StatelessWidget {
  final ImageEntry entry;
  final FilterCallback onFilter;

  const BasicSection({
    Key key,
    @required this.entry,
    @required this.onFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = entry.bestDate;
    final dateText = date != null ? '${DateFormat.yMMMd().format(date)} • ${DateFormat.Hm().format(date)}' : '?';
    final showMegaPixels = !entry.isVideo && !entry.isGif && entry.megaPixels != null && entry.megaPixels > 0;
    final resolutionText = '${entry.width ?? '?'} × ${entry.height ?? '?'}${showMegaPixels ? ' (${entry.megaPixels} MP)' : ''}';

    final filter = entry.directory != null ? AlbumFilter(entry.directory) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRowGroup({
          'Title': entry.title ?? '?',
          'Date': dateText,
          if (entry.isVideo) ..._buildVideoRows(),
          if (!entry.isSvg) 'Resolution': resolutionText,
          'Size': entry.sizeBytes != null ? formatFilesize(entry.sizeBytes) : '?',
          'URI': entry.uri ?? '?',
          if (entry.path != null) 'Path': entry.path,
        }),
        if (filter != null) ...[
          const SizedBox(height: 8),
          AvesFilterChip.fromFilter(
            filter,
            onPressed: onFilter,
          ),
        ]
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
