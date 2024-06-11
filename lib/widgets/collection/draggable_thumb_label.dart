import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/draggable_thumb_label.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionDraggableThumbLabel extends StatelessWidget {
  final CollectionLens collection;
  final double offsetY;

  const CollectionDraggableThumbLabel({
    super.key,
    required this.collection,
    required this.offsetY,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableThumbLabel<AvesEntry>(
      offsetY: offsetY,
      lineBuilder: (context, entry) {
        switch (collection.sortFactor) {
          case EntrySortFactor.date:
            switch (collection.sectionFactor) {
              case EntryGroupFactor.album:
                return [
                  DraggableThumbLabel.formatMonthThumbLabel(context, entry.bestDate),
                  if (_showAlbumName(context, entry)) _getAlbumName(context, entry),
                ];
              case EntryGroupFactor.month:
              case EntryGroupFactor.none:
                return [
                  DraggableThumbLabel.formatMonthThumbLabel(context, entry.bestDate),
                ];
              case EntryGroupFactor.day:
                return [
                  DraggableThumbLabel.formatDayThumbLabel(context, entry.bestDate),
                ];
            }
          case EntrySortFactor.name:
            return [
              if (_showAlbumName(context, entry)) _getAlbumName(context, entry),
              if (entry.bestTitle != null) entry.bestTitle!,
            ];
          case EntrySortFactor.rating:
            return [
              RatingFilter.formatRating(context, entry.rating),
              DraggableThumbLabel.formatMonthThumbLabel(context, entry.bestDate),
            ];
          case EntrySortFactor.size:
            return [
              if (entry.sizeBytes != null) formatFileSize(context.locale, entry.sizeBytes!, round: 0),
            ];
        }
      },
    );
  }

  bool _hasMultipleSections(BuildContext context) => context.read<SectionedListLayout<AvesEntry>>().sections.length > 1;

  bool _showAlbumName(BuildContext context, AvesEntry entry) => _hasMultipleSections(context) && entry.directory != null;

  String _getAlbumName(BuildContext context, AvesEntry entry) => context.read<CollectionSource>().getAlbumDisplayName(context, entry.directory!);
}
