import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/query.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar/notifications.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar/scrollbar.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/double_back.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/grid/item_tracker.dart';
import 'package:aves/widgets/common/grid/scaling.dart';
import 'package:aves/widgets/common/grid/sections/fixed/scale_grid.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/selector.dart';
import 'package:aves/widgets/common/grid/sliver.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:aves/widgets/common/providers/tile_extent_controller_provider.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves/widgets/filter_grids/common/covered_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/draggable_thumb_label.dart';
import 'package:aves/widgets/filter_grids/common/filter_tile.dart';
import 'package:aves/widgets/filter_grids/common/list_details_theme.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves/widgets/filter_grids/common/section_layout.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves/widgets/navigation/nav_bar/nav_bar.dart';
import 'package:aves/widgets/navigation/tv_rail.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

typedef QueryTest<T extends CollectionFilter> = List<FilterGridItem<T>> Function(BuildContext context, List<FilterGridItem<T>> filters, String query);

class FilterGridPage<T extends CollectionFilter> extends StatelessWidget {
  final String? settingsRouteKey;
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> sections;
  final Set<T> newFilters;
  final ChipSortFactor sortFactor;
  final bool showHeaders, selectable;
  final QueryTest<T> applyQuery;
  final Widget Function() emptyBuilder;
  final HeroType heroType;
  final StreamController<DraggableScrollbarEvent> _draggableScrollBarEventStreamController = StreamController.broadcast();

  FilterGridPage({
    super.key,
    this.settingsRouteKey,
    required this.appBar,
    required this.appBarHeightNotifier,
    required this.sections,
    required this.newFilters,
    required this.sortFactor,
    required this.showHeaders,
    required this.selectable,
    required this.applyQuery,
    required this.emptyBuilder,
    required this.heroType,
  });

  @override
  Widget build(BuildContext context) {
    final useTvLayout = settings.useTvLayout;
    final body = GestureAreaProtectorStack(
      child: DirectionalSafeArea(
        start: !useTvLayout,
        top: false,
        bottom: false,
        child: Selector<MediaQueryData, double>(
          selector: (context, mq) => mq.padding.top,
          builder: (context, mqPaddingTop, child) {
            return ValueListenableBuilder<double>(
              valueListenable: appBarHeightNotifier,
              builder: (context, appBarHeight, child) {
                return _FilterGrid<T>(
                  // key is expected by test driver
                  key: const Key('filter-grid'),
                  settingsRouteKey: settingsRouteKey,
                  appBar: appBar,
                  appBarHeight: mqPaddingTop + appBarHeight,
                  sections: sections,
                  newFilters: newFilters,
                  sortFactor: sortFactor,
                  showHeaders: showHeaders,
                  selectable: selectable,
                  applyQuery: applyQuery,
                  emptyBuilder: emptyBuilder,
                  heroType: heroType,
                );
              },
            );
          },
        ),
      ),
    );

    if (useTvLayout) {
      final canNavigate = context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canNavigate);
      return AvesScaffold(
        body: canNavigate
            ? Row(
                children: [
                  TvRail(
                    controller: context.read<TvRailController>(),
                  ),
                  Expanded(child: body),
                ],
              )
            : DirectionalSafeArea(
                top: false,
                end: false,
                bottom: false,
                child: body,
              ),
        resizeToAvoidBottomInset: false,
        extendBody: true,
      );
    } else {
      return Selector<Settings, bool>(
        selector: (context, s) => s.enableBottomNavigationBar,
        builder: (context, enableBottomNavigationBar, child) {
          final canNavigate = context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canNavigate);
          final showBottomNavigationBar = canNavigate && enableBottomNavigationBar;

          return NotificationListener<DraggableScrollbarNotification>(
            onNotification: (notification) {
              _draggableScrollBarEventStreamController.add(notification.event);
              return false;
            },
            child: AvesScaffold(
              body: body,
              drawer: canNavigate ? const AppDrawer() : null,
              bottomNavigationBar: showBottomNavigationBar
                  ? AppBottomNavBar(
                      events: _draggableScrollBarEventStreamController.stream,
                    )
                  : null,
              resizeToAvoidBottomInset: false,
              extendBody: true,
            ),
          );
        },
      );
    }
  }
}

class _FilterGrid<T extends CollectionFilter> extends StatefulWidget {
  final String? settingsRouteKey;
  final Widget appBar;
  final double appBarHeight;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> sections;
  final Set<T> newFilters;
  final ChipSortFactor sortFactor;
  final bool showHeaders, selectable;
  final QueryTest<T> applyQuery;
  final Widget Function() emptyBuilder;
  final HeroType heroType;

  const _FilterGrid({
    super.key,
    required this.settingsRouteKey,
    required this.appBar,
    required this.appBarHeight,
    required this.sections,
    required this.newFilters,
    required this.sortFactor,
    required this.showHeaders,
    required this.selectable,
    required this.applyQuery,
    required this.emptyBuilder,
    required this.heroType,
  });

  @override
  State<_FilterGrid<T>> createState() => _FilterGridState<T>();
}

class _FilterGridState<T extends CollectionFilter> extends State<_FilterGrid<T>> {
  TileExtentController? _tileExtentController;
  final DoubleBackPopHandler _doubleBackPopHandler = DoubleBackPopHandler();

  @override
  void dispose() {
    _tileExtentController?.dispose();
    _doubleBackPopHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tileExtentController ??= TileExtentController(
      settingsRouteKey: widget.settingsRouteKey ?? context.currentRouteName!,
      columnCountDefault: settings.useTvLayout ? 4 : 3,
      extentMin: 60,
      extentMax: 300,
      spacing: 8,
      horizontalPadding: 2,
    );
    return AvesPopScope(
      handlers: [
        (context) {
          final selection = context.read<Selection<FilterGridItem<T>>>();
          if (selection.isSelecting) {
            selection.browse();
            return false;
          }
          return true;
        },
        TvNavigationPopHandler.pop,
        _doubleBackPopHandler.pop,
      ],
      child: TileExtentControllerProvider(
        controller: _tileExtentController!,
        child: _FilterGridContent<T>(
          appBar: widget.appBar,
          appBarHeight: widget.appBarHeight,
          sections: widget.sections,
          newFilters: widget.newFilters,
          sortFactor: widget.sortFactor,
          showHeaders: widget.showHeaders,
          selectable: widget.selectable,
          applyQuery: widget.applyQuery,
          emptyBuilder: widget.emptyBuilder,
          heroType: widget.heroType,
        ),
      ),
    );
  }
}

class _FilterGridContent<T extends CollectionFilter> extends StatefulWidget {
  final Widget appBar;
  final double appBarHeight;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> sections;
  final Set<T> newFilters;
  final ChipSortFactor sortFactor;
  final bool showHeaders, selectable;
  final Widget Function() emptyBuilder;
  final QueryTest<T> applyQuery;
  final HeroType heroType;

  const _FilterGridContent({
    super.key,
    required this.appBar,
    required this.appBarHeight,
    required this.sections,
    required this.newFilters,
    required this.sortFactor,
    required this.showHeaders,
    required this.selectable,
    required this.applyQuery,
    required this.emptyBuilder,
    required this.heroType,
  });

  @override
  State<_FilterGridContent<T>> createState() => _FilterGridContentState<T>();
}

class _FilterGridContentState<T extends CollectionFilter> extends State<_FilterGridContent<T>> {
  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<FilterGridItem<T>?> _focusedItemNotifier = ValueNotifier(null);

  @override
  void didUpdateWidget(covariant _FilterGridContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _appBarHeightNotifier.value = widget.appBarHeight;
  }

  @override
  void dispose() {
    _appBarHeightNotifier.dispose();
    _focusedItemNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    final settingsRouteKey = context.read<TileExtentController>().settingsRouteKey;
    final tileLayout = context.select<Settings, TileLayout>((s) => s.getTileLayout(settingsRouteKey));
    return Selector<Query, bool>(
      selector: (context, query) => query.enabled,
      builder: (context, queryEnabled, child) {
        return ValueListenableBuilder<String>(
          valueListenable: context.select<Query, ValueNotifier<String>>((query) => query.queryNotifier),
          builder: (context, query, child) {
            Map<ChipSectionKey, List<FilterGridItem<T>>> visibleSections;
            if (queryEnabled && query.isNotEmpty) {
              visibleSections = {};
              widget.sections.forEach((sectionKey, sectionFilters) {
                final visibleFilters = widget.applyQuery(context, sectionFilters, query.toUpperCase());
                if (visibleFilters.isNotEmpty) {
                  visibleSections[sectionKey] = visibleFilters;
                }
              });
            } else {
              visibleSections = widget.sections;
            }

            final sectionedListLayoutProvider = ValueListenableBuilder<double>(
              valueListenable: context.select<TileExtentController, ValueNotifier<double>>((controller) => controller.extentNotifier),
              builder: (context, thumbnailExtent, child) {
                return Selector<TileExtentController, Tuple4<double, int, double, double>>(
                  selector: (context, c) => Tuple4(c.viewportSize.width, c.columnCount, c.spacing, c.horizontalPadding),
                  builder: (context, c, child) {
                    final scrollableWidth = c.item1;
                    final columnCount = c.item2;
                    final tileSpacing = c.item3;
                    final horizontalPadding = c.item4;
                    // do not listen for animation delay change
                    final target = context.read<DurationsData>().staggeredAnimationPageTarget;
                    final tileAnimationDelay = context.read<TileExtentController>().getTileAnimationDelay(target);
                    return Selector<MediaQueryData, double>(
                      selector: (context, mq) => mq.textScaleFactor,
                      builder: (context, textScaleFactor, child) {
                        final tileHeight = CoveredFilterChip.tileHeight(
                          extent: thumbnailExtent,
                          textScaleFactor: textScaleFactor,
                          showText: tileLayout != TileLayout.list,
                        );
                        return GridTheme(
                          extent: thumbnailExtent,
                          child: FilterListDetailsTheme(
                            extent: thumbnailExtent,
                            child: AnimatedBuilder(
                              animation: vaults,
                              builder: (context, child) {
                                return SectionedFilterListLayoutProvider<T>(
                                  sections: visibleSections,
                                  showHeaders: widget.showHeaders,
                                  selectable: widget.selectable,
                                  tileLayout: tileLayout,
                                  scrollableWidth: scrollableWidth,
                                  columnCount: columnCount,
                                  spacing: tileSpacing,
                                  horizontalPadding: horizontalPadding,
                                  tileWidth: thumbnailExtent,
                                  tileHeight: tileHeight,
                                  tileBuilder: (gridItem, tileSize) {
                                    final extent = tileSize.shortestSide;
                                    final tile = InteractiveFilterTile(
                                      gridItem: gridItem,
                                      chipExtent: extent,
                                      thumbnailExtent: extent,
                                      tileLayout: tileLayout,
                                      banner: _getFilterBanner(context, gridItem.filter),
                                      heroType: widget.heroType,
                                    );
                                    if (!settings.useTvLayout) return tile;

                                    return Focus(
                                      onFocusChange: (focused) {
                                        if (focused) {
                                          _focusedItemNotifier.value = gridItem;
                                        } else if (_focusedItemNotifier.value == gridItem) {
                                          _focusedItemNotifier.value = null;
                                        }
                                      },
                                      child: ValueListenableBuilder<FilterGridItem<T>?>(
                                        valueListenable: _focusedItemNotifier,
                                        builder: (context, focusedItem, child) {
                                          return AnimatedScale(
                                            scale: focusedItem == gridItem ? 1 : .9,
                                            curve: Curves.fastOutSlowIn,
                                            duration: context.select<DurationsData, Duration>((v) => v.tvImageFocusAnimation),
                                            child: child!,
                                          );
                                        },
                                        child: tile,
                                      ),
                                    );
                                  },
                                  tileAnimationDelay: tileAnimationDelay,
                                  coverRatioResolver: (item) {
                                    final coverEntry = source.coverEntry(item.filter) ?? item.entry;
                                    return coverEntry?.displayAspectRatio ?? 1;
                                  },
                                  child: child!,
                                );
                              },
                              child: child,
                            ),
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
                appBar: widget.appBar,
                appBarHeightNotifier: _appBarHeightNotifier,
                visibleSections: visibleSections,
                sortFactor: widget.sortFactor,
                selectable: widget.selectable,
                emptyBuilder: widget.emptyBuilder,
                bannerBuilder: _getFilterBanner,
                scrollController: PrimaryScrollController.of(context),
                tileLayout: tileLayout,
              ),
            );
            return sectionedListLayoutProvider;
          },
        );
      },
    );
  }

  String? _getFilterBanner(BuildContext context, T filter) {
    final isNew = widget.newFilters.contains(filter);
    return isNew ? context.l10n.newFilterBanner : null;
  }
}

class _FilterSectionedContent<T extends CollectionFilter> extends StatefulWidget {
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> visibleSections;
  final ChipSortFactor sortFactor;
  final bool selectable;
  final Widget Function() emptyBuilder;
  final String? Function(BuildContext context, T filter) bannerBuilder;
  final ScrollController scrollController;
  final TileLayout tileLayout;

  const _FilterSectionedContent({
    required this.appBar,
    required this.appBarHeightNotifier,
    required this.visibleSections,
    required this.sortFactor,
    required this.selectable,
    required this.emptyBuilder,
    required this.bannerBuilder,
    required this.scrollController,
    required this.tileLayout,
  });

  @override
  State<_FilterSectionedContent<T>> createState() => _FilterSectionedContentState<T>();
}

class _FilterSectionedContentState<T extends CollectionFilter> extends State<_FilterSectionedContent<T>> {
  Widget get appBar => widget.appBar;

  ValueNotifier<double> get appBarHeightNotifier => widget.appBarHeightNotifier;

  TileLayout get tileLayout => widget.tileLayout;

  Map<ChipSectionKey, List<FilterGridItem<T>>> get visibleSections => widget.visibleSections;

  Widget Function() get emptyBuilder => widget.emptyBuilder;

  ScrollController get scrollController => widget.scrollController;

  final GlobalKey scrollableKey = GlobalKey(debugLabel: 'filter-grid-page-scrollable');

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInitHighlight());
  }

  @override
  void didUpdateWidget(covariant _FilterSectionedContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(_FilterSectionedContent<T> widget) {
    widget.appBarHeightNotifier.addListener(_onAppBarHeightChanged);
  }

  void _unregisterWidget(_FilterSectionedContent<T> widget) {
    widget.appBarHeightNotifier.removeListener(_onAppBarHeightChanged);
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
      tileLayout: tileLayout,
      bannerBuilder: widget.bannerBuilder,
      child: scrollView,
    );

    final selector = GridSelectionGestureDetector<FilterGridItem<T>>(
      scrollableKey: scrollableKey,
      selectable: context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canSelectFilter) && widget.selectable,
      items: visibleSections.values.expand((v) => v).toList(),
      scrollController: scrollController,
      appBarHeightNotifier: appBarHeightNotifier,
      child: scaler,
    );

    return GridItemTracker<FilterGridItem<T>>(
      scrollableKey: scrollableKey,
      tileLayout: tileLayout,
      appBarHeightNotifier: appBarHeightNotifier,
      scrollController: scrollController,
      child: selector,
    );
  }

  void _onAppBarHeightChanged() => setState(() {});

  Future<void> _checkInitHighlight() async {
    final highlightInfo = context.read<HighlightInfo>();
    final filter = highlightInfo.clear();
    if (filter is! T) return;

    final item = visibleSections.values.expand((list) => list).firstWhereOrNull((gridItem) => gridItem.filter == filter);
    if (item == null) return;

    await Future.delayed(Durations.highlightScrollInitDelay);

    final animate = context.read<Settings>().accessibilityAnimations.animate;
    highlightInfo.trackItem(item, animate: animate, highlightItem: filter);
  }
}

class _FilterScaler<T extends CollectionFilter> extends StatelessWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final TileLayout tileLayout;
  final String? Function(BuildContext context, T filter) bannerBuilder;
  final Widget child;

  const _FilterScaler({
    required this.scrollableKey,
    required this.appBarHeightNotifier,
    required this.tileLayout,
    required this.bannerBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = context.select<MediaQueryData, double>((mq) => mq.textScaleFactor);
    final metrics = context.select<TileExtentController, Tuple2<double, double>>((v) => Tuple2(v.spacing, v.horizontalPadding));
    final tileSpacing = metrics.item1;
    final horizontalPadding = metrics.item2;
    final brightness = Theme.of(context).brightness;
    return GridScaleGestureDetector<FilterGridItem<T>>(
      scrollableKey: scrollableKey,
      tileLayout: tileLayout,
      heightForWidth: (width) => CoveredFilterChip.tileHeight(extent: width, textScaleFactor: textScaleFactor, showText: true),
      gridBuilder: (center, tileSize, child) => CustomPaint(
        painter: FixedExtentGridPainter(
          tileLayout: tileLayout,
          tileCenter: center,
          tileSize: tileSize,
          spacing: tileSpacing,
          horizontalPadding: horizontalPadding,
          borderWidth: AvesFilterChip.outlineWidth,
          borderRadius: CoveredFilterChip.radius(tileSize.shortestSide),
          color: Colors.grey.shade700,
          textDirection: Directionality.of(context),
        ),
        child: child,
      ),
      scaledItemBuilder: (item, tileSize) => FilterListDetailsTheme(
        extent: tileSize.height,
        child: FilterTile(
          gridItem: item,
          chipExtent: tileLayout == TileLayout.grid ? tileSize.width : tileSize.height,
          thumbnailExtent: context.read<TileExtentController>().effectiveExtentMax,
          tileLayout: tileLayout,
          banner: bannerBuilder(context, item.filter),
        ),
      ),
      mosaicItemBuilder: (index, targetExtent) => DecoratedBox(
        decoration: BoxDecoration(
          color: ThumbnailImage.computeLoadingBackgroundColor(index * 10, brightness).withOpacity(.9),
          border: Border.all(
            color: context.read<AvesColorsData>().neutral,
            width: AvesFilterChip.outlineWidth,
          ),
          borderRadius: BorderRadius.all(CoveredFilterChip.radius(targetExtent)),
        ),
      ),
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
    return settings.useTvLayout ? scrollView : _buildDraggableScrollView(scrollView);
  }

  Widget _buildDraggableScrollView(Widget scrollView) {
    return ValueListenableBuilder<double>(
      valueListenable: appBarHeightNotifier,
      builder: (context, appBarHeight, child) {
        return Selector<MediaQueryData, double>(
          selector: (context, mq) => mq.effectiveBottomPadding,
          builder: (context, mqPaddingBottom, child) {
            return Selector<Settings, bool>(
              selector: (context, s) => s.enableBottomNavigationBar,
              builder: (context, enableBottomNavigationBar, child) {
                final canNavigate = context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canNavigate);
                final showBottomNavigationBar = canNavigate && enableBottomNavigationBar;
                final navBarHeight = showBottomNavigationBar ? AppBottomNavBar.height : 0;
                return DraggableScrollbar(
                  backgroundColor: Colors.white,
                  scrollThumbSize: Size(avesScrollThumbWidth, avesScrollThumbHeight),
                  scrollThumbBuilder: avesScrollThumbBuilder(
                    height: avesScrollThumbHeight,
                    backgroundColor: Colors.white,
                  ),
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    // padding to keep scroll thumb between app bar above and nav bar below
                    top: appBarHeight,
                    bottom: navBarHeight + mqPaddingBottom,
                  ),
                  labelTextBuilder: (offsetY) => FilterDraggableThumbLabel<T>(
                    sortFactor: sortFactor,
                    offsetY: offsetY,
                  ),
                  crumbTextBuilder: (offsetY) => const SizedBox(),
                  child: scrollView,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildScrollView(BuildContext context) {
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
                      child: emptyBuilder(),
                    )
                  : SectionedListSliver<FilterGridItem<T>>();
            }),
        const NavBarPaddingSliver(),
        const BottomPaddingSliver(),
        const TvTileGridBottomPaddingSliver(),
      ],
    );
  }
}
