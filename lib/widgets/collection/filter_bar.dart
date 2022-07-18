import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets rowPadding = EdgeInsets.symmetric(horizontal: 4);
  static const double verticalPadding = 16;
  static const double preferredHeight = AvesFilterChip.minChipHeight + verticalPadding;

  final List<CollectionFilter> filters;
  final bool removable;
  final FilterCallback? onTap;

  FilterBar({
    super.key,
    required Set<CollectionFilter> filters,
    this.removable = false,
    this.onTap,
  }) : filters = List<CollectionFilter>.from(filters)..sort();

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey(debugLabel: 'filter-bar-animated-list');
  CollectionFilter? _userTappedFilter;

  List<CollectionFilter> get filters => widget.filters;

  FilterCallback? get onTap => widget.onTap;

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
      final animate = _userTappedFilter == filter;
      listState!.removeItem(
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
      listState!.insertItem(
        index,
        duration: Duration.zero,
      );
    });
    _userTappedFilter = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // specify transparent as a workaround to prevent
      // chip border clipping when the floating app bar is fading
      color: Colors.transparent,
      height: FilterBar.preferredHeight,
      child: NotificationListener<ScrollNotification>(
        // cancel notification bubbling so that the draggable scroll bar
        // does not misinterpret filter bar scrolling for collection scrolling
        onNotification: (notification) => true,
        child: AnimatedList(
          key: _animatedListKey,
          initialItemCount: filters.length,
          scrollDirection: Axis.horizontal,
          padding: FilterBar.rowPadding,
          itemBuilder: (context, index, animation) {
            if (index >= filters.length) return const SizedBox();
            return _buildChip(filters.toList()[index]);
          },
        ),
      ),
    );
  }

  Widget _buildChip(CollectionFilter filter) {
    return _Chip(
      filter: filter,
      removable: widget.removable,
      single: filters.length == 1,
      onTap: onTap != null
          ? (filter) {
              _userTappedFilter = filter;
              onTap!(filter);
            }
          : null,
    );
  }
}

class _Chip extends StatelessWidget {
  final CollectionFilter filter;
  final bool removable, single;
  final FilterCallback? onTap;

  const _Chip({
    required this.filter,
    required this.removable,
    required this.single,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FilterBar.chipPadding,
      child: Center(
        child: AvesFilterChip(
          key: ValueKey(filter),
          filter: filter,
          removable: removable,
          maxWidth: single
              ? AvesFilterChip.computeMaxWidth(
                  context,
                  minChipPerRow: 1,
                  chipPadding: FilterBar.chipPadding.horizontal,
                  rowPadding: FilterBar.rowPadding.horizontal + AvesFloatingBar.margin.horizontal,
                )
              : null,
          heroType: HeroType.always,
          onTap: onTap,
        ),
      ),
    );
  }
}
