import 'dart:ui';

import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/double_back_pop.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:aves/widgets/common/grid/sliver.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/providers/tile_extent_controller_provider.dart';
import 'package:aves/widgets/common/scaling.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:aves/widgets/filter_grids/common/decorated_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/draggable_thumb_label.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves/widgets/filter_grids/common/section_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

typedef QueryTest<T extends CollectionFilter> = Iterable<FilterGridItem<T>> Function(Iterable<FilterGridItem<T>> filters, String query);

class FilterGridPage<T extends CollectionFilter> extends StatelessWidget {
  final String settingsRouteKey;
  final Widget appBar;
  final double appBarHeight;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final ChipSortFactor sortFactor;
  final bool showHeaders;
  final ValueNotifier<String> queryNotifier;
  final QueryTest<T> applyQuery;
  final Widget Function() emptyBuilder;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  const FilterGridPage({
    Key key,
    this.settingsRouteKey,
    @required this.appBar,
    this.appBarHeight = kToolbarHeight,
    @required this.filterSections,
    @required this.sortFactor,
    @required this.showHeaders,
    @required this.queryNotifier,
    this.applyQuery,
    @required this.emptyBuilder,
    @required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  static const Color detailColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: DoubleBackPopScope(
          child: GestureAreaProtectorStack(
            child: SafeArea(
              bottom: false,
              child: AnimatedBuilder(
                animation: covers,
                builder: (context, child) => FilterGrid<T>(
                  settingsRouteKey: settingsRouteKey,
                  appBar: appBar,
                  appBarHeight: appBarHeight,
                  filterSections: filterSections,
                  sortFactor: sortFactor,
                  showHeaders: showHeaders,
                  queryNotifier: queryNotifier,
                  applyQuery: applyQuery,
                  emptyBuilder: emptyBuilder,
                  onTap: onTap,
                  onLongPress: onLongPress,
                ),
              ),
            ),
          ),
        ),
        drawer: AppDrawer(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class FilterGrid<T extends CollectionFilter> extends StatefulWidget {
  final String settingsRouteKey;
  final Widget appBar;
  final double appBarHeight;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final ChipSortFactor sortFactor;
  final bool showHeaders;
  final ValueNotifier<String> queryNotifier;
  final QueryTest<T> applyQuery;
  final Widget Function() emptyBuilder;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  const FilterGrid({
    Key key,
    @required this.settingsRouteKey,
    @required this.appBar,
    @required this.appBarHeight,
    @required this.filterSections,
    @required this.sortFactor,
    @required this.showHeaders,
    @required this.queryNotifier,
    @required this.applyQuery,
    @required this.emptyBuilder,
    @required this.onTap,
    @required this.onLongPress,
  }) : super(key: key);

  @override
  _FilterGridState createState() => _FilterGridState<T>();
}

class _FilterGridState<T extends CollectionFilter> extends State<FilterGrid<T>> {
  TileExtentController _tileExtentController;

  @override
  Widget build(BuildContext context) {
    _tileExtentController ??= TileExtentController(
      settingsRouteKey: widget.settingsRouteKey ?? context.currentRouteName,
      columnCountDefault: 2,
      extentMin: 60,
      spacing: 8,
    );
    return TileExtentControllerProvider(
      controller: _tileExtentController,
      child: _FilterGridContent<T>(
        appBar: widget.appBar,
        appBarHeight: widget.appBarHeight,
        filterSections: widget.filterSections,
        sortFactor: widget.sortFactor,
        showHeaders: widget.showHeaders,
        queryNotifier: widget.queryNotifier,
        applyQuery: widget.applyQuery,
        emptyBuilder: widget.emptyBuilder,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      ),
    );
  }
}

class _FilterGridContent<T extends CollectionFilter> extends StatelessWidget {
  final Widget appBar;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final ChipSortFactor sortFactor;
  final bool showHeaders;
  final ValueNotifier<String> queryNotifier;
  final Widget Function() emptyBuilder;
  final QueryTest<T> applyQuery;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);

  _FilterGridContent({
    Key key,
    @required this.appBar,
    @required double appBarHeight,
    @required this.filterSections,
    @required this.sortFactor,
    @required this.showHeaders,
    @required this.queryNotifier,
    @required this.applyQuery,
    @required this.emptyBuilder,
    @required this.onTap,
    @required this.onLongPress,
  }) : super(key: key) {
    _appBarHeightNotifier.value = appBarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: queryNotifier,
      builder: (context, query, child) {
        Map<ChipSectionKey, List<FilterGridItem<T>>> visibleFilterSections;
        if (applyQuery == null) {
          visibleFilterSections = filterSections;
        } else {
          visibleFilterSections = {};
          filterSections.forEach((sectionKey, sectionFilters) {
            final visibleFilters = applyQuery(sectionFilters, query);
            if (visibleFilters.isNotEmpty) {
              visibleFilterSections[sectionKey] = visibleFilters.toList();
            }
          });
        }

        final pinnedFilters = settings.pinnedFilters;
        final sectionedListLayoutProvider = ValueListenableBuilder<double>(
          valueListenable: context.select<TileExtentController, ValueNotifier<double>>((controller) => controller.extentNotifier),
          builder: (context, tileExtent, child) {
            return Selector<TileExtentController, Tuple3<double, int, double>>(
                selector: (context, c) => Tuple3(c.viewportSize.width, c.columnCount, c.spacing),
                builder: (context, c, child) {
                  final scrollableWidth = c.item1;
                  final columnCount = c.item2;
                  final tileSpacing = c.item3;
                  // do not listen for animation delay change
                  final controller = Provider.of<TileExtentController>(context, listen: false);
                  final tileAnimationDelay = controller.getTileAnimationDelay(Durations.staggeredAnimationPageTarget);
                  return SectionedFilterListLayoutProvider<T>(
                    sections: visibleFilterSections,
                    showHeaders: showHeaders,
                    scrollableWidth: scrollableWidth,
                    tileExtent: tileExtent,
                    columnCount: columnCount,
                    spacing: tileSpacing,
                    tileBuilder: (gridItem) {
                      final filter = gridItem.filter;
                      final entry = gridItem.entry;
                      return MetaData(
                        metaData: ScalerMetadata(FilterGridItem<T>(filter, entry)),
                        child: DecoratedFilterChip(
                          key: Key(filter.key),
                          filter: filter,
                          extent: tileExtent,
                          pinned: pinnedFilters.contains(filter),
                          onTap: onTap,
                          onLongPress: onLongPress,
                        ),
                      );
                    },
                    tileAnimationDelay: tileAnimationDelay,
                    child: _FilterSectionedContent<T>(
                      appBar: appBar,
                      appBarHeightNotifier: _appBarHeightNotifier,
                      visibleFilterSections: visibleFilterSections,
                      sortFactor: sortFactor,
                      emptyBuilder: emptyBuilder,
                      scrollController: PrimaryScrollController.of(context),
                    ),
                  );
                });
          },
        );
        return sectionedListLayoutProvider;
      },
    );
  }
}

class _FilterSectionedContent<T extends CollectionFilter> extends StatefulWidget {
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> visibleFilterSections;
  final ChipSortFactor sortFactor;
  final Widget Function() emptyBuilder;
  final ScrollController scrollController;

  const _FilterSectionedContent({
    @required this.appBar,
    @required this.appBarHeightNotifier,
    @required this.visibleFilterSections,
    @required this.sortFactor,
    @required this.emptyBuilder,
    @required this.scrollController,
  });

  @override
  _FilterSectionedContentState createState() => _FilterSectionedContentState<T>();
}

class _FilterSectionedContentState<T extends CollectionFilter> extends State<_FilterSectionedContent<T>> {
  Widget get appBar => widget.appBar;

  ValueNotifier<double> get appBarHeightNotifier => widget.appBarHeightNotifier;

  Map<ChipSectionKey, List<FilterGridItem<T>>> get visibleFilterSections => widget.visibleFilterSections;

  Widget Function() get emptyBuilder => widget.emptyBuilder;

  ScrollController get scrollController => widget.scrollController;

  final GlobalKey _scrollableKey = GlobalKey(debugLabel: 'filter-grid-page-scrollable');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInitHighlight());
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = AnimationLimiter(
      child: _FilterScrollView<T>(
        scrollableKey: _scrollableKey,
        appBar: appBar,
        appBarHeightNotifier: appBarHeightNotifier,
        sortFactor: widget.sortFactor,
        emptyBuilder: emptyBuilder,
        scrollController: scrollController,
      ),
    );

    final scaler = _FilterScaler<T>(
      scrollableKey: _scrollableKey,
      appBarHeightNotifier: appBarHeightNotifier,
      child: scrollView,
    );

    return scaler;
  }

  Future<void> _checkInitHighlight() async {
    final highlightInfo = context.read<HighlightInfo>();
    final filter = highlightInfo.clear();
    if (filter is T) {
      final gridItem = visibleFilterSections.values.expand((list) => list).firstWhere((gridItem) => gridItem.filter == filter, orElse: () => null);
      if (gridItem != null) {
        await Future.delayed(Durations.highlightScrollInitDelay);
        final sectionedListLayout = context.read<SectionedListLayout<FilterGridItem<T>>>();
        final tileRect = sectionedListLayout.getTileRect(gridItem);
        await _scrollToItem(tileRect);
        highlightInfo.set(filter);
      }
    }
  }

  Future<void> _scrollToItem(Rect tileRect) async {
    final scrollableContext = _scrollableKey.currentContext;
    final scrollableHeight = (scrollableContext.findRenderObject() as RenderBox).size.height;

    // most of the time the app bar will be scrolled away after scaling,
    // so we compensate for it to center the focal point thumbnail
    final appBarHeight = appBarHeightNotifier.value;
    final scrollOffset = tileRect.top + (tileRect.height - scrollableHeight) / 2 + appBarHeight;

    if (scrollOffset > 0) {
      await scrollController.animateTo(
        scrollOffset,
        duration: Duration(milliseconds: (scrollOffset / 2).round().clamp(Durations.highlightScrollAnimationMinMillis, Durations.highlightScrollAnimationMaxMillis)),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}

class _FilterScaler<T extends CollectionFilter> extends StatelessWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final Widget child;

  const _FilterScaler({
    @required this.scrollableKey,
    @required this.appBarHeightNotifier,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final pinnedFilters = settings.pinnedFilters;
    final tileSpacing = context.select<TileExtentController, double>((controller) => controller.spacing);
    return GridScaleGestureDetector<FilterGridItem<T>>(
      scrollableKey: scrollableKey,
      appBarHeightNotifier: appBarHeightNotifier,
      gridBuilder: (center, extent, child) => CustomPaint(
        painter: GridPainter(
          center: center,
          extent: extent,
          spacing: tileSpacing,
          color: Colors.grey.shade700,
        ),
        child: child,
      ),
      scaledBuilder: (item, extent) {
        final filter = item.filter;
        return DecoratedFilterChip(
          filter: filter,
          extent: extent,
          pinned: pinnedFilters.contains(filter),
          highlightable: false,
        );
      },
      getScaledItemTileRect: (context, item) {
        final sectionedListLayout = context.read<SectionedListLayout<FilterGridItem<T>>>();
        return sectionedListLayout.getTileRect(item) ?? Rect.zero;
      },
      onScaled: (item) => context.read<HighlightInfo>().set(item.filter),
      child: child,
    );
  }
}

class _FilterScrollView<T extends CollectionFilter> extends StatelessWidget {
  final GlobalKey scrollableKey;
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final ChipSortFactor sortFactor;
  final Widget Function() emptyBuilder;
  final ScrollController scrollController;

  const _FilterScrollView({
    @required this.scrollableKey,
    @required this.appBar,
    @required this.appBarHeightNotifier,
    @required this.sortFactor,
    @required this.emptyBuilder,
    @required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final scrollView = _buildScrollView(context);
    return _buildDraggableScrollView(scrollView);
  }

  Widget _buildDraggableScrollView(ScrollView scrollView) {
    return Selector<MediaQueryData, double>(
      selector: (context, mq) => mq.effectiveBottomPadding,
      builder: (context, mqPaddingBottom, child) => DraggableScrollbar(
        backgroundColor: Colors.white,
        scrollThumbHeight: avesScrollThumbHeight,
        scrollThumbBuilder: avesScrollThumbBuilder(
          height: avesScrollThumbHeight,
          backgroundColor: Colors.white,
        ),
        controller: scrollController,
        padding: EdgeInsets.only(
          // padding to keep scroll thumb between app bar above and nav bar below
          top: appBarHeightNotifier.value,
          bottom: mqPaddingBottom,
        ),
        labelTextBuilder: (offsetY) => FilterDraggableThumbLabel<T>(
          sortFactor: sortFactor,
          offsetY: offsetY,
        ),
        child: scrollView,
      ),
    );
  }

  ScrollView _buildScrollView(BuildContext context) {
    return CustomScrollView(
      key: scrollableKey,
      controller: scrollController,
      slivers: [
        appBar,
        Selector<SectionedListLayout<FilterGridItem<T>>, bool>(
            selector: (context, layout) => layout.sections.isEmpty,
            builder: (context, empty, child) {
              return empty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Selector<MediaQueryData, double>(
                        selector: (context, mq) => mq.effectiveBottomPadding,
                        builder: (context, mqPaddingBottom, child) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: mqPaddingBottom),
                            child: emptyBuilder(),
                          );
                        },
                      ),
                    )
                  : SectionedListSliver<FilterGridItem<T>>();
            }),
        BottomPaddingSliver(),
      ],
    );
  }
}
