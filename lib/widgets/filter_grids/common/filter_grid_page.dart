import 'dart:ui';

import 'package:aves/app_mode.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/double_back_pop.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/grid/item_tracker.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:aves/widgets/common/grid/selector.dart';
import 'package:aves/widgets/common/grid/sliver.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/providers/tile_extent_controller_provider.dart';
import 'package:aves/widgets/common/scaling.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:aves/widgets/filter_grids/common/covered_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/draggable_thumb_label.dart';
import 'package:aves/widgets/filter_grids/common/filter_chip_grid_decorator.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves/widgets/filter_grids/common/section_layout.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

typedef QueryTest<T extends CollectionFilter> = Iterable<FilterGridItem<T>> Function(Iterable<FilterGridItem<T>> filters, String query);

class FilterGridPage<T extends CollectionFilter> extends StatelessWidget {
  final String? settingsRouteKey;
  final Widget appBar;
  final double appBarHeight;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> sections;
  final Set<T> newFilters;
  final ChipSortFactor sortFactor;
  final bool showHeaders, selectable;
  final ValueNotifier<String> queryNotifier;
  final QueryTest<T>? applyQuery;
  final Widget Function() emptyBuilder;
  final FilterCallback onTap;

  const FilterGridPage({
    Key? key,
    this.settingsRouteKey,
    required this.appBar,
    this.appBarHeight = kToolbarHeight,
    required this.sections,
    required this.newFilters,
    required this.sortFactor,
    required this.showHeaders,
    required this.selectable,
    required this.queryNotifier,
    this.applyQuery,
    required this.emptyBuilder,
    required this.onTap,
  }) : super(key: key);

  static const Color detailColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () {
            final selection = context.read<Selection<FilterGridItem<T>>>();
            if (selection.isSelecting) {
              selection.browse();
              return SynchronousFuture(false);
            }
            return SynchronousFuture(true);
          },
          child: DoubleBackPopScope(
            child: GestureAreaProtectorStack(
              child: SafeArea(
                bottom: false,
                child: AnimatedBuilder(
                  animation: covers,
                  builder: (context, child) => FilterGrid<T>(
                    // key is expected by test driver
                    key: const Key('filter-grid'),
                    settingsRouteKey: settingsRouteKey,
                    appBar: appBar,
                    appBarHeight: appBarHeight,
                    sections: sections,
                    newFilters: newFilters,
                    sortFactor: sortFactor,
                    showHeaders: showHeaders,
                    selectable: selectable,
                    queryNotifier: queryNotifier,
                    applyQuery: applyQuery,
                    emptyBuilder: emptyBuilder,
                    onTap: onTap,
                  ),
                ),
              ),
            ),
          ),
        ),
        drawer: const AppDrawer(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class FilterGrid<T extends CollectionFilter> extends StatefulWidget {
  final String? settingsRouteKey;
  final Widget appBar;
  final double appBarHeight;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> sections;
  final Set<T> newFilters;
  final ChipSortFactor sortFactor;
  final bool showHeaders, selectable;
  final ValueNotifier<String> queryNotifier;
  final QueryTest<T>? applyQuery;
  final Widget Function() emptyBuilder;
  final FilterCallback onTap;

  const FilterGrid({
    Key? key,
    required this.settingsRouteKey,
    required this.appBar,
    required this.appBarHeight,
    required this.sections,
    required this.newFilters,
    required this.sortFactor,
    required this.showHeaders,
    required this.selectable,
    required this.queryNotifier,
    required this.applyQuery,
    required this.emptyBuilder,
    required this.onTap,
  }) : super(key: key);

  @override
  _FilterGridState createState() => _FilterGridState<T>();
}

class _FilterGridState<T extends CollectionFilter> extends State<FilterGrid<T>> {
  TileExtentController? _tileExtentController;

  @override
  void dispose() {
    _tileExtentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tileExtentController ??= TileExtentController(
      settingsRouteKey: widget.settingsRouteKey ?? context.currentRouteName!,
      columnCountDefault: 2,
      extentMin: 60,
      spacing: 8,
    );
    return TileExtentControllerProvider(
      controller: _tileExtentController!,
      child: _FilterGridContent<T>(
        appBar: widget.appBar,
        appBarHeight: widget.appBarHeight,
        sections: widget.sections,
        newFilters: widget.newFilters,
        sortFactor: widget.sortFactor,
        showHeaders: widget.showHeaders,
        selectable: widget.selectable,
        queryNotifier: widget.queryNotifier,
        applyQuery: widget.applyQuery,
        emptyBuilder: widget.emptyBuilder,
        onTap: widget.onTap,
      ),
    );
  }
}

class _FilterGridContent<T extends CollectionFilter> extends StatelessWidget {
  final Widget appBar;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> sections;
  final Set<T> newFilters;
  final ChipSortFactor sortFactor;
  final bool showHeaders, selectable;
  final ValueNotifier<String> queryNotifier;
  final Widget Function() emptyBuilder;
  final QueryTest<T>? applyQuery;
  final FilterCallback onTap;

  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);

  _FilterGridContent({
    Key? key,
    required this.appBar,
    required double appBarHeight,
    required this.sections,
    required this.newFilters,
    required this.sortFactor,
    required this.showHeaders,
    required this.selectable,
    required this.queryNotifier,
    required this.applyQuery,
    required this.emptyBuilder,
    required this.onTap,
  }) : super(key: key) {
    _appBarHeightNotifier.value = appBarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: queryNotifier,
      builder: (context, query, child) {
        Map<ChipSectionKey, List<FilterGridItem<T>>> visibleSections;
        if (applyQuery == null) {
          visibleSections = sections;
        } else {
          visibleSections = {};
          sections.forEach((sectionKey, sectionFilters) {
            final visibleFilters = applyQuery!(sectionFilters, query);
            if (visibleFilters.isNotEmpty) {
              visibleSections[sectionKey] = visibleFilters.toList();
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
                final tileAnimationDelay = context.read<TileExtentController>().getTileAnimationDelay(Durations.staggeredAnimationPageTarget);
                return Selector<MediaQueryData, double>(
                  selector: (context, mq) => mq.textScaleFactor,
                  builder: (context, textScaleFactor, child) {
                    final tileHeight = CoveredFilterChip.tileHeight(extent: tileExtent, textScaleFactor: textScaleFactor);
                    return GridTheme(
                      extent: tileExtent,
                      child: SectionedFilterListLayoutProvider<T>(
                        sections: visibleSections,
                        showHeaders: showHeaders,
                        scrollableWidth: scrollableWidth,
                        columnCount: columnCount,
                        spacing: tileSpacing,
                        tileWidth: tileExtent,
                        tileHeight: tileHeight,
                        tileBuilder: (gridItem) {
                          final filter = gridItem.filter;
                          return MetaData(
                            metaData: ScalerMetadata(gridItem),
                            child: FilterChipGridDecorator<T, FilterGridItem<T>>(
                              gridItem: gridItem,
                              extent: tileExtent,
                              child: CoveredFilterChip(
                                key: Key(filter.key),
                                filter: filter,
                                extent: tileExtent,
                                pinned: pinnedFilters.contains(filter),
                                banner: newFilters.contains(filter) ? context.l10n.newFilterBanner : null,
                                onTap: onTap,
                              ),
                            ),
                          );
                        },
                        tileAnimationDelay: tileAnimationDelay,
                        child: child!,
                      ),
                    );
                  },
                  child: child,
                );
              },
              child: child,
            );
          },
          child: _FilterSectionedContent<T>(
            appBar: appBar,
            appBarHeightNotifier: _appBarHeightNotifier,
            visibleSections: visibleSections,
            sortFactor: sortFactor,
            selectable: selectable,
            emptyBuilder: emptyBuilder,
            scrollController: PrimaryScrollController.of(context)!,
          ),
        );
        return sectionedListLayoutProvider;
      },
    );
  }
}

class _FilterSectionedContent<T extends CollectionFilter> extends StatefulWidget {
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> visibleSections;
  final ChipSortFactor sortFactor;
  final bool selectable;
  final Widget Function() emptyBuilder;
  final ScrollController scrollController;

  const _FilterSectionedContent({
    required this.appBar,
    required this.appBarHeightNotifier,
    required this.visibleSections,
    required this.sortFactor,
    required this.selectable,
    required this.emptyBuilder,
    required this.scrollController,
  });

  @override
  _FilterSectionedContentState createState() => _FilterSectionedContentState<T>();
}

class _FilterSectionedContentState<T extends CollectionFilter> extends State<_FilterSectionedContent<T>> with WidgetsBindingObserver, GridItemTrackerMixin<FilterGridItem<T>, _FilterSectionedContent<T>> {
  Widget get appBar => widget.appBar;

  @override
  ValueNotifier<double> get appBarHeightNotifier => widget.appBarHeightNotifier;

  Map<ChipSectionKey, List<FilterGridItem<T>>> get visibleSections => widget.visibleSections;

  Widget Function() get emptyBuilder => widget.emptyBuilder;

  @override
  ScrollController get scrollController => widget.scrollController;

  @override
  final GlobalKey scrollableKey = GlobalKey(debugLabel: 'filter-grid-page-scrollable');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _checkInitHighlight());
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = AnimationLimiter(
      child: _FilterScrollView<T>(
        scrollableKey: scrollableKey,
        appBar: appBar,
        appBarHeightNotifier: appBarHeightNotifier,
        sortFactor: widget.sortFactor,
        emptyBuilder: emptyBuilder,
        scrollController: scrollController,
      ),
    );

    final scaler = _FilterScaler<T>(
      scrollableKey: scrollableKey,
      appBarHeightNotifier: appBarHeightNotifier,
      child: scrollView,
    );

    final isMainMode = context.select<ValueNotifier<AppMode>, bool>((vn) => vn.value == AppMode.main);
    final selector = GridSelectionGestureDetector<FilterGridItem<T>>(
      selectable: isMainMode && widget.selectable,
      items: visibleSections.values.expand((v) => v).toList(),
      scrollController: scrollController,
      appBarHeightNotifier: appBarHeightNotifier,
      child: scaler,
    );

    return selector;
  }

  Future<void> _checkInitHighlight() async {
    final highlightInfo = context.read<HighlightInfo>();
    final filter = highlightInfo.clear();
    if (filter is T) {
      final gridItem = visibleSections.values.expand((list) => list).firstWhereOrNull((gridItem) => gridItem.filter == filter);
      if (gridItem != null) {
        await Future.delayed(Durations.highlightScrollInitDelay);
        highlightInfo.trackItem(gridItem, highlightItem: filter);
      }
    }
  }
}

class _FilterScaler<T extends CollectionFilter> extends StatelessWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final Widget child;

  const _FilterScaler({
    required this.scrollableKey,
    required this.appBarHeightNotifier,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final pinnedFilters = settings.pinnedFilters;
    final tileSpacing = context.select<TileExtentController, double>((controller) => controller.spacing);
    final textScaleFactor = context.select<MediaQueryData, double>((mq) => mq.textScaleFactor);
    return GridScaleGestureDetector<FilterGridItem<T>>(
      scrollableKey: scrollableKey,
      heightForWidth: (width) => CoveredFilterChip.tileHeight(extent: width, textScaleFactor: textScaleFactor),
      gridBuilder: (center, tileSize, child) => CustomPaint(
        painter: GridPainter(
          center: center,
          tileSize: tileSize,
          spacing: tileSpacing,
          borderWidth: AvesFilterChip.outlineWidth,
          borderRadius: CoveredFilterChip.radius(tileSize.width),
          color: Colors.grey.shade700,
        ),
        child: child,
      ),
      scaledBuilder: (item, tileSize) {
        final filter = item.filter;
        return CoveredFilterChip(
          filter: filter,
          extent: tileSize.width,
          thumbnailExtent: context.read<TileExtentController>().effectiveExtentMax,
          pinned: pinnedFilters.contains(filter),
        );
      },
      highlightItem: (item) => item.filter,
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
    required this.scrollableKey,
    required this.appBar,
    required this.appBarHeightNotifier,
    required this.sortFactor,
    required this.emptyBuilder,
    required this.scrollController,
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
        const BottomPaddingSliver(),
      ],
    );
  }
}
