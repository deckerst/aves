import 'package:aves/model/collection_filters.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/fullscreen/info/navigation_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CollectionFilter> filters;

  final ScrollController _scrollController = ScrollController();

  static const double maxChipWidth = 160;
  static const EdgeInsets padding = EdgeInsets.only(left: 8, right: 8, bottom: 8);

  @override
  final Size preferredSize = Size.fromHeight(kMinInteractiveDimension + padding.vertical);

  FilterBar(Set<CollectionFilter> filters)
      : this.filters = filters.toList()
          ..sort((a, b) {
            return compareAsciiUpperCase(a.label, b.label);
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
          padding: EdgeInsets.all(NavigationButton.buttonBorderWidth / 2),
          itemBuilder: (context, index) {
            if (index >= filters.length) return null;
            final filter = filters[index];
            final icon = filter.icon;
            final label = filter.label;
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxChipWidth),
              child: Tooltip(
                message: label,
                child: OutlineButton(
                  onPressed: () {},
                  borderSide: BorderSide(
                    color: stringToColor(label),
                    width: NavigationButton.buttonBorderWidth,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(42),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemCount: filters.length,
        ),
      ),
    );
  }
}
