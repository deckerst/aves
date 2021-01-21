import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicSection extends StatelessWidget {
  final AvesEntry entry;
  final CollectionLens collection;
  final FilterCallback onFilter;

  const BasicSection({
    Key key,
    @required this.entry,
    this.collection,
    @required this.onFilter,
  }) : super(key: key);

  int get megaPixels => entry.megaPixels;

  bool get showMegaPixels => entry.isPhoto && megaPixels != null && megaPixels > 0;

  String get rasterResolutionText => '${entry.resolutionText}${showMegaPixels ? ' ($megaPixels MP)' : ''}';

  @override
  Widget build(BuildContext context) {
    final date = entry.bestDate;
    final dateText = date != null ? '${DateFormat.yMMMd().format(date)} • ${DateFormat.Hm().format(date)}' : Constants.infoUnknown;

    // TODO TLAD line break on all characters for the following fields when this is fixed: https://github.com/flutter/flutter/issues/61081
    // inserting ZWSP (\u200B) between characters does help, but it messes with width and height computation (another Flutter issue)
    final title = entry.bestTitle ?? Constants.infoUnknown;
    final uri = entry.uri ?? Constants.infoUnknown;
    final path = entry.path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRowGroup({
          'Title': title,
          'Date': dateText,
          if (entry.isVideo) ..._buildVideoRows(),
          if (!entry.isSvg) 'Resolution': rasterResolutionText,
          'Size': entry.sizeBytes != null ? formatFilesize(entry.sizeBytes) : Constants.infoUnknown,
          'URI': uri,
          if (path != null) 'Path': path,
        }),
        _buildChips(),
      ],
    );
  }

  Widget _buildChips() {
    final tags = entry.xmpSubjects..sort(compareAsciiUpperCase);
    final album = entry.directory;
    final filters = [
      if (entry.isAnimated) MimeFilter(MimeFilter.animated),
      if (entry.isImage && entry.is360) MimeFilter(MimeFilter.panorama),
      if (entry.isVideo) MimeFilter(entry.is360 ? MimeFilter.sphericalVideo : MimeTypes.anyVideo),
      if (entry.isGeotiff) MimeFilter(MimeFilter.geotiff),
      if (album != null) AlbumFilter(album, collection?.source?.getUniqueAlbumName(album)),
      ...tags.map((tag) => TagFilter(tag)),
    ];
    return AnimatedBuilder(
      animation: favourites.changeNotifier,
      builder: (context, child) {
        final effectiveFilters = [
          ...filters,
          if (entry.isFavourite) FavouriteFilter(),
        ]..sort();
        if (effectiveFilters.isEmpty) return SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AvesFilterChip.outlineWidth / 2) + EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: effectiveFilters
                .map((filter) => AvesFilterChip(
                      filter: filter,
                      onTap: onFilter,
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Map<String, String> _buildVideoRows() {
    return {
      'Duration': entry.durationText,
    };
  }
}
