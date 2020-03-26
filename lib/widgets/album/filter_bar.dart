import 'package:aves/model/collection_filters.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CollectionFilter> filters;

  final ScrollController _scrollController = ScrollController();

  static const EdgeInsets padding = EdgeInsets.only(left: 8, right: 8, bottom: 8);

  @override
  final Size preferredSize = Size.fromHeight(kMinInteractiveDimension + padding.vertical);

  FilterBar(Set<CollectionFilter> filters)
      : this.filters = filters.toList()
          ..sort((a, b) {
            final c = a.displayPriority.compareTo(b.displayPriority);
            return c != 0 ? c : compareAsciiUpperCase(a.label, b.label);
          });

  @override
  Widget build(BuildContext context) {
    return Container(
      // specify transparent as a workaround to prevent
      // chip border clipping when the floating app bar is fading
      color: Colors.transparent,
      padding: padding,
      height: preferredSize.height,
      child: NotificationListener<ScrollNotification>(
        // cancel notification bubbling so that the draggable scrollbar
        // does not misinterpret filter bar scrolling for collection scrolling
        onNotification: (notification) => true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          primary: false,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AvesFilterChip.buttonBorderWidth / 2),
          itemBuilder: (context, index) {
            if (index >= filters.length) return null;
            final filter = filters[index];
            return AvesFilterChip(
              filter,
              onPressed: (filter) {},
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemCount: filters.length,
        ),
      ),
    );
  }
}
