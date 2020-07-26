import 'package:aves/model/filters/filters.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';

class ExpandableFilterRow extends StatelessWidget {
  final String title;
  final Iterable<CollectionFilter> filters;
  final ValueNotifier<String> expandedNotifier;
  final FilterCallback onPressed;

  const ExpandableFilterRow({
    this.title,
    @required this.filters,
    this.expandedNotifier,
    @required this.onPressed,
  });

  static const double horizontalPadding = 8;
  static const double verticalPadding = 8;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return SizedBox.shrink();

    final hasTitle = title != null && title.isNotEmpty;

    final isExpanded = hasTitle && expandedNotifier?.value == title;

    Widget titleRow;
    if (hasTitle) {
      titleRow = Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              title,
              style: Constants.titleTextStyle,
            ),
            const Spacer(),
            IconButton(
              icon: Icon(isExpanded ? AIcons.collapse : AIcons.expand),
              onPressed: () => expandedNotifier.value = isExpanded ? null : title,
            ),
          ],
        ),
      );
    }

    final filtersList = filters.toList();
    final wrap = Container(
      key: ValueKey('wrap$title'),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      // specify transparent as a workaround to prevent
      // chip border clipping when the floating app bar is fading
      color: Colors.transparent,
      child: Wrap(
        spacing: horizontalPadding,
        runSpacing: verticalPadding,
        children: filtersList
            .map((filter) => AvesFilterChip(
                  filter: filter,
                  onPressed: onPressed,
                ))
            .toList(),
      ),
    );
    final list = Container(
      key: ValueKey('list$title'),
      // specify transparent as a workaround to prevent
      // chip border clipping when the floating app bar is fading
      color: Colors.transparent,
      height: AvesFilterChip.minChipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemBuilder: (context, index) {
          if (index >= filtersList.length) return null;
          final filter = filtersList[index];
          return AvesFilterChip(
            filter: filter,
            onPressed: onPressed,
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemCount: filtersList.length,
      ),
    );
    final filterChips = isExpanded ? wrap : list;
    return titleRow != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              AnimatedSwitcher(
                duration: Durations.filterRowExpandAnimation,
                child: filterChips,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
              ),
            ],
          )
        : filterChips;
  }
}
