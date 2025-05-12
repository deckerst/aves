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
            final date = entry.bestDate;
            switch (collection.sectionFactor) {
              case EntrySectionFactor.album:
                return [
                  DraggableThumbLabel.formatMonthThumbLabel(context, date),
                  if (_showAlbumName(context, entry)) _getAlbumName(context, entry),
                ];
              case EntrySectionFactor.month:
              case EntrySectionFactor.none:
                return [
                  DraggableThumbLabel.formatMonthThumbLabel(context, date),
                ];
              case EntrySectionFactor.day:
                return [
                  DraggableThumbLabel.formatDayThumbLabel(context, date),
                ];
            }
          case EntrySortFactor.name:
            final entryTitle = entry.bestTitle;
            return [
              if (_showAlbumName(context, entry)) _getAlbumName(context, entry),
              if (entryTitle != null) entryTitle,
            ];
          case EntrySortFactor.rating:
            return [
              RatingFilter.formatRating(context, entry.rating),
              DraggableThumbLabel.formatMonthThumbLabel(context, entry.bestDate),
            ];
          case EntrySortFactor.size:
            final sizeBytes = entry.sizeBytes;
            return [
              if (sizeBytes != null) formatFileSize(context.locale, sizeBytes, round: 0),
            ];
          case EntrySortFactor.duration:
            return [
              if (entry.durationMillis != null) entry.durationText,
            ];
          case EntrySortFactor.path:
            final entryFilename = entry.filenameWithoutExtension;
            return [
              if (_showAlbumName(context, entry)) _getAlbumName(context, entry),
              if (entryFilename != null) entryFilename,
            ];
        }
      },
    );
  }

  bool _hasMultipleSections(BuildContext context) => context.read<SectionedListLayout<AvesEntry>>().sections.length > 1;

  bool _showAlbumName(BuildContext context, AvesEntry entry) => _hasMultipleSections(context) && entry.directory != null;

  String _getAlbumName(BuildContext context, AvesEntry entry) => context.read<CollectionSource>().getStoredAlbumDisplayName(context, entry.directory!);
}
