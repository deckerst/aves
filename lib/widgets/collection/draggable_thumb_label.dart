import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/draggable_thumb_label.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
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
          case .date:
            final locale = settings.intl4xLocale();
            final calendar = settings.calendar;
            final date = entry.bestDate;
            switch (collection.sectionFactor) {
              case .album:
                return [
                  DraggableThumbLabel.formatMonthThumbLabel(context, locale, calendar, date),
                  if (_showAlbumName(context, entry)) _getAlbumName(context, entry),
                ];
              case .month:
              case .none:
                return [
                  DraggableThumbLabel.formatMonthThumbLabel(context, locale, calendar, date),
                ];
              case .day:
                return [
                  DraggableThumbLabel.formatDayThumbLabel(context, locale, date),
                ];
            }
          case .name:
            return [
              if (_showAlbumName(context, entry)) _getAlbumName(context, entry),
              ?entry.bestTitle,
            ];
          case .rating:
            final locale = settings.intl4xLocale();
            final calendar = settings.calendar;
            final date = entry.bestDate;
            return [
              RatingFilter.formatRating(context, entry.rating),
              DraggableThumbLabel.formatMonthThumbLabel(context, locale, calendar, date),
            ];
          case .size:
            final sizeBytes = entry.sizeBytes;
            return [
              if (sizeBytes != null) formatFileSize(context.localeName, sizeBytes, round: 0),
            ];
          case .duration:
            return [
              if (entry.durationMillis != null) entry.durationText,
            ];
          case .path:
            final entryFilename = entry.filenameWithoutExtension;
            return [
              if (_showAlbumName(context, entry)) _getAlbumName(context, entry),
              ?entryFilename,
            ];
        }
      },
    );
  }

  bool _hasMultipleSections(BuildContext context) => context.read<SectionedListLayout<AvesEntry>>().sections.length > 1;

  bool _showAlbumName(BuildContext context, AvesEntry entry) => _hasMultipleSections(context) && entry.directory != null;

  String _getAlbumName(BuildContext context, AvesEntry entry) => context.read<CollectionSource>().getStoredAlbumDisplayName(context, entry.directory!);
}
