import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';

class ExpandableFilterRow extends StatelessWidget {
  final String title;
  final Iterable<CollectionFilter> filters;
  final ValueNotifier<String> expandedNotifier;
  final HeroType Function(CollectionFilter filter) heroTypeBuilder;
  final FilterCallback onTap;

  const ExpandableFilterRow({
    this.title,
    @required this.filters,
    @required this.expandedNotifier,
    this.heroTypeBuilder,
    @required this.onTap,
  });

  static const double horizontalPadding = 8;
  static const double verticalPadding = 8;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return SizedBox.shrink();

    final hasTitle = title != null && title.isNotEmpty;

    final isExpanded = hasTitle && expandedNotifier.value == title;

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
              tooltip: isExpanded ? MaterialLocalizations.of(context).expandedIconTapHint : MaterialLocalizations.of(context).collapsedIconTapHint,
            ),
          ],
        ),
      );
    }

    final filterList = filters.toList();
    final wrap = Container(
      key: ValueKey('wrap$title'),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      // specify transparent as a workaround to prevent
      // chip border clipping when the floating app bar is fading
      color: Colors.transparent,
      child: Wrap(
        spacing: horizontalPadding,
        runSpacing: verticalPadding,
        children: filterList.map(_buildFilterChip).toList(),
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
          return index < filterList.length ? _buildFilterChip(filterList[index]) : null;
        },
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemCount: filterList.length,
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
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                child: filterChips,
              ),
            ],
          )
        : filterChips;
  }

  Widget _buildFilterChip(CollectionFilter filter) {
    return AvesFilterChip(
      // key `album-{path}` is expected by test driver
      key: Key(filter.key),
      filter: filter,
      heroType: heroTypeBuilder?.call(filter) ?? HeroType.onTap,
      onTap: onTap,
    );
  }
}
