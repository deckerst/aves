import 'dart:ui';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/behaviour/double_back_pop.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:aves/widgets/common/providers/highlight_info_provider.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/scaling.dart';
import 'package:aves/widgets/common/tile_extent_manager.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:aves/widgets/filter_grids/common/decorated_filter_chip.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class FilterGridPage<T extends CollectionFilter> extends StatelessWidget {
  final CollectionSource source;
  final Widget appBar;
  final Map<T, ImageEntry> filterEntries;
  final ValueNotifier<String> queryNotifier;
  final Widget Function() emptyBuilder;
  final String settingsRouteKey;
  final Iterable<T> Function(Iterable<T> filters, String query) applyQuery;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<double> _tileExtentNotifier = ValueNotifier(0);
  final GlobalKey _scrollableKey = GlobalKey();

  static const spacing = 8.0;

  FilterGridPage({
    @required this.source,
    @required this.appBar,
    @required this.filterEntries,
    @required this.queryNotifier,
    this.applyQuery,
    @required this.emptyBuilder,
    this.settingsRouteKey,
    double appBarHeight = kToolbarHeight,
    @required this.onTap,
    this.onLongPress,
  }) {
    _appBarHeightNotifier.value = appBarHeight;
  }

  static const Color detailColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: DoubleBackPopScope(
          child: HighlightInfoProvider(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportSize = constraints.biggest;
                  assert(viewportSize.isFinite, 'Cannot layout collection with unbounded constraints.');
                  if (viewportSize.isEmpty) return SizedBox.shrink();

                  final tileExtentManager = TileExtentManager(
                    settingsRouteKey: settingsRouteKey ?? context.currentRouteName,
                    columnCountMin: 2,
                    columnCountDefault: 2,
                    extentMin: 60,
                    extentNotifier: _tileExtentNotifier,
                    spacing: spacing,
                  )..applyTileExtent(viewportSize: viewportSize);

                  return ValueListenableBuilder<double>(
                    valueListenable: _tileExtentNotifier,
                    builder: (context, tileExtent, child) {
                      final columnCount = tileExtentManager.getEffectiveColumnCountForExtent(viewportSize, tileExtent);

                      return ValueListenableBuilder<String>(
                        valueListenable: queryNotifier,
                        builder: (context, query, child) {
                          final allFilters = filterEntries.keys;
                          final visibleFilters = (applyQuery != null ? applyQuery(allFilters, query) : allFilters).toList();

                          final scrollView = AnimationLimiter(
                            child: _buildDraggableScrollView(_buildScrollView(context, columnCount, visibleFilters)),
                          );

                          return GridScaleGestureDetector<FilterGridItem>(
                            tileExtentManager: tileExtentManager,
                            scrollableKey: _scrollableKey,
                            appBarHeightNotifier: _appBarHeightNotifier,
                            viewportSize: viewportSize,
                            showScaledGrid: true,
                            scaledBuilder: (item, extent) {
                              final filter = item.filter;
                              return SizedBox(
                                width: extent,
                                height: extent,
                                child: DecoratedFilterChip(
                                  source: source,
                                  filter: filter,
                                  entry: item.entry,
                                  extent: extent,
                                  pinned: settings.pinnedFilters.contains(filter),
                                  highlightable: false,
                                ),
                              );
                            },
                            getScaledItemTileRect: (context, item) {
                              final index = visibleFilters.indexOf(item.filter);
                              final column = index % columnCount;
                              final row = (index / columnCount).floor();
                              final left = tileExtent * column + spacing * (column - 1);
                              final top = tileExtent * row + spacing * (row - 1);
                              return Rect.fromLTWH(left, top, tileExtent, tileExtent);
                            },
                            onScaled: (item) => Provider.of<HighlightInfo>(context, listen: false).add(item.filter),
                            child: scrollView,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        drawer: AppDrawer(
          source: source,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget _buildDraggableScrollView(ScrollView scrollView) {
    return Selector<MediaQueryData, double>(
      selector: (context, mq) => mq.viewInsets.bottom,
      builder: (context, mqViewInsetsBottom, child) => DraggableScrollbar(
        heightScrollThumb: avesScrollThumbHeight,
        backgroundColor: Colors.white,
        scrollThumbBuilder: avesScrollThumbBuilder(
          height: avesScrollThumbHeight,
          backgroundColor: Colors.white,
        ),
        controller: PrimaryScrollController.of(context),
        padding: EdgeInsets.only(
          // padding to keep scroll thumb between app bar above and nav bar below
          top: _appBarHeightNotifier.value,
          bottom: mqViewInsetsBottom,
        ),
        child: scrollView,
      ),
    );
  }

  ScrollView _buildScrollView(BuildContext context, int columnCount, List<T> visibleFilters) {
    final pinnedFilters = settings.pinnedFilters;
    return CustomScrollView(
      key: _scrollableKey,
      controller: PrimaryScrollController.of(context),
      slivers: [
        appBar,
        visibleFilters.isEmpty
            ? SliverFillRemaining(
                child: Selector<MediaQueryData, double>(
                  selector: (context, mq) => mq.viewInsets.bottom,
                  builder: (context, mqViewInsetsBottom, child) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: mqViewInsetsBottom),
                      child: emptyBuilder(),
                    );
                  },
                ),
                hasScrollBody: false,
              )
            : SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final filter = visibleFilters[i];
                    final entry = filterEntries[filter];
                    final child = MetaData(
                      metaData: ScalerMetadata(FilterGridItem(filter, entry)),
                      child: DecoratedFilterChip(
                        key: Key(filter.key),
                        source: source,
                        filter: filter,
                        entry: entry,
                        extent: _tileExtentNotifier.value,
                        pinned: pinnedFilters.contains(filter),
                        onTap: onTap,
                        onLongPress: onLongPress,
                      ),
                    );
                    return AnimationConfiguration.staggeredGrid(
                      position: i,
                      columnCount: columnCount,
                      duration: Durations.staggeredAnimation,
                      delay: Durations.staggeredAnimationDelay,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: child,
                        ),
                      ),
                    );
                  },
                  childCount: visibleFilters.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                ),
              ),
        SliverToBoxAdapter(
          child: Selector<MediaQueryData, double>(
            selector: (context, mq) => mq.viewInsets.bottom,
            builder: (context, mqViewInsetsBottom, child) {
              return SizedBox(height: mqViewInsetsBottom);
            },
          ),
        ),
      ],
    );
  }
}

class FilterGridItem<T extends CollectionFilter> {
  final T filter;
  final ImageEntry entry;

  const FilterGridItem(this.filter, this.entry);
}
