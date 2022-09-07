import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums/enums.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/draggable_thumb_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterDraggableThumbLabel<T extends CollectionFilter> extends StatelessWidget {
  final ChipSortFactor sortFactor;
  final double offsetY;

  const FilterDraggableThumbLabel({
    super.key,
    required this.sortFactor,
    required this.offsetY,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableThumbLabel<FilterGridItem<T>>(
      offsetY: offsetY,
      lineBuilder: (context, filterGridItem) {
        switch (sortFactor) {
          case ChipSortFactor.date:
            return [
              DraggableThumbLabel.formatMonthThumbLabel(context, filterGridItem.entry?.bestDate),
            ];
          case ChipSortFactor.name:
            return [
              filterGridItem.filter.getLabel(context),
            ];
          case ChipSortFactor.count:
            return [
              context.l10n.itemCount(context.read<CollectionSource>().count(filterGridItem.filter)),
            ];
          case ChipSortFactor.size:
            final locale = context.l10n.localeName;
            return [
              formatFileSize(locale, context.read<CollectionSource>().size(filterGridItem.filter)),
            ];
        }
      },
    );
  }
}
