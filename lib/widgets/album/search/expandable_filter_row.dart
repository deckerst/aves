import 'package:aves/model/filters/filters.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/search/search_delegate.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    final hasTitle = title != null && title.isNotEmpty;

    final isExpanded = hasTitle && expandedNotifier?.value == title;

    Widget titleRow;
    if (hasTitle) {
      titleRow = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              title,
              style: Constants.titleTextStyle,
            ),
            const Spacer(),
            IconButton(
              icon: Icon(isExpanded ? OMIcons.expandLess : OMIcons.expandMore),
              onPressed: () => expandedNotifier.value = isExpanded ? null : title,
            ),
          ],
        ),
      );
    }

    final filtersList = filters.toList();
    final filterChips = isExpanded
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.buttonBorderWidth / 2 + 6),
            child: Wrap(
              spacing: 8,
              children: filtersList
                  .map((filter) => AvesFilterChip(
                        filter: filter,
                        onPressed: onPressed,
                      ))
                  .toList(),
            ),
          )
        : Container(
            height: kMinInteractiveDimension,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AvesFilterChip.buttonBorderWidth / 2) + const EdgeInsets.symmetric(horizontal: 6),
              itemBuilder: (context, index) {
                if (index >= filtersList.length) return null;
                final filter = filtersList[index];
                return Center(
                  child: AvesFilterChip(
                    filter: filter,
                    onPressed: onPressed,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: filtersList.length,
            ),
          );
    return titleRow != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              filterChips,
            ],
          )
        : filterChips;
  }
}
