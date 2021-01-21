import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget implements PreferredSizeWidget {
  static const double verticalPadding = 16;
  static const double preferredHeight = AvesFilterChip.minChipHeight + verticalPadding;

  final List<CollectionFilter> filters;
  final FilterCallback onPressed;

  FilterBar({
    Key key,
    @required Set<CollectionFilter> filters,
    @required this.onPressed,
  })  : filters = List.from(filters)..sort(),
        super(key: key);

  @override
  final Size preferredSize = Size.fromHeight(preferredHeight);

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey(debugLabel: 'filter-bar-animated-list');
  CollectionFilter _userRemovedFilter;

  @override
  void didUpdateWidget(covariant FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widget.filters;
    final existing = oldWidget.filters;
    final removed = existing.where((filter) => !current.contains(filter)).toList();
    final added = current.where((filter) => !existing.contains(filter)).toList();
    final listState = _animatedListKey.currentState;
    removed.forEach((filter) {
      final index = existing.indexOf(filter);
      existing.removeAt(index);
      // only animate item removal when triggered by a user interaction with the chip,
      // not from automatic chip replacement following chip selection
      final animate = _userRemovedFilter == filter;
      listState.removeItem(
        index,
        animate
            ? (context, animation) {
                animation = animation.drive(CurveTween(curve: Curves.easeInOutBack));
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    axis: Axis.horizontal,
                    sizeFactor: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: _buildChip(filter),
                    ),
                  ),
                );
              }
            : (context, animation) => _buildChip(filter),
        duration: animate ? Durations.filterBarRemovalAnimation : Duration.zero,
      );
    });
    added.forEach((filter) {
      final index = current.indexOf(filter);
      listState.insertItem(
        index,
        duration: Duration.zero,
      );
    });
    _userRemovedFilter = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // specify transparent as a workaround to prevent
      // chip border clipping when the floating app bar is fading
      color: Colors.transparent,
      height: FilterBar.preferredHeight,
      child: NotificationListener<ScrollNotification>(
        // cancel notification bubbling so that the draggable scrollbar
        // does not misinterpret filter bar scrolling for collection scrolling
        onNotification: (notification) => true,
        child: AnimatedList(
          key: _animatedListKey,
          initialItemCount: widget.filters.length,
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 8),
          itemBuilder: (context, index, animation) {
            if (index >= widget.filters.length) return null;
            return _buildChip(widget.filters.toList()[index]);
          },
        ),
      ),
    );
  }

  Padding _buildChip(CollectionFilter filter) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Center(
        child: AvesFilterChip(
          key: ValueKey(filter),
          filter: filter,
          removable: true,
          heroType: HeroType.always,
          onTap: (filter) {
            _userRemovedFilter = filter;
            widget.onPressed(filter);
          },
        ),
      ),
    );
  }
}
