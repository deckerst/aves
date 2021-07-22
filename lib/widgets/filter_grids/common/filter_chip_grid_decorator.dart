import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/common/grid/overlay.dart';
import 'package:aves/widgets/filter_grids/common/covered_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/overlay.dart';
import 'package:flutter/widgets.dart';

class FilterChipGridDecorator<T extends CollectionFilter, U extends FilterGridItem<T>> extends StatelessWidget {
  final U gridItem;
  final double extent;
  final Widget child;

  const FilterChipGridDecorator({
    Key? key,
    required this.gridItem,
    required this.extent,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.all(CoveredFilterChip.radius(extent));
    return SizedBox(
      width: extent,
      height: extent,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          GridItemSelectionOverlay<FilterGridItem<T>>(
            item: gridItem,
            borderRadius: borderRadius,
            padding: EdgeInsets.all(extent / 24),
          ),
          ChipHighlightOverlay(
            filter: gridItem.filter,
            extent: extent,
            borderRadius: borderRadius,
          ),
        ],
      ),
    );
  }
}
