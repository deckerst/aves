import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/grid/draggable_thumb_label.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionDraggableThumbLabel extends StatelessWidget {
  final CollectionLens collection;
  final double offsetY;

  const CollectionDraggableThumbLabel({
    @required this.collection,
    @required this.offsetY,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableThumbLabel<AvesEntry>(
      offsetY: offsetY,
      lineBuilder: (context, entry) {
        switch (collection.sortFactor) {
          case EntrySortFactor.date:
            switch (collection.groupFactor) {
              case EntryGroupFactor.album:
                return [
                  DraggableThumbLabel.formatMonthThumbLabel(context, entry.bestDate),
                  if (_hasMultipleSections(context)) context.read<CollectionSource>().getAlbumDisplayName(context, entry.directory),
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
            break;
          case EntrySortFactor.name:
            return [
              if (_hasMultipleSections(context)) context.read<CollectionSource>().getAlbumDisplayName(context, entry.directory),
              entry.bestTitle,
            ];
          case EntrySortFactor.size:
            return [
              formatFilesize(entry.sizeBytes, round: 0),
            ];
        }
        return [];
      },
    );
  }

  bool _hasMultipleSections(BuildContext context) => context.read<SectionedListLayout<AvesEntry>>().sections.length > 1;
}
