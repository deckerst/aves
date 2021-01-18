import 'dart:ui';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/behaviour/double_back_pop.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/gesture_area_protector.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:aves/widgets/common/grid/sliver.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:aves/widgets/common/providers/highlight_info_provider.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/scaling.dart';
import 'package:aves/widgets/common/tile_extent_manager.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:aves/widgets/filter_grids/common/decorated_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves/widgets/filter_grids/common/section_layout.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class FilterGridPage<T extends CollectionFilter> extends StatelessWidget {
  final CollectionSource source;
  final Widget appBar;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final bool showHeaders;
  final ValueNotifier<String> queryNotifier;
  final Widget Function() emptyBuilder;
  final String settingsRouteKey;
  final Iterable<FilterGridItem<T>> Function(Iterable<FilterGridItem<T>> filters, String query) applyQuery;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<double> _tileExtentNotifier = ValueNotifier(0);
  final GlobalKey _scrollableKey = GlobalKey();

  static const columnCountDefault = 2;
  static const extentMin = 60.0;
  static const spacing = 8.0;

  FilterGridPage({
    Key key,
    @required this.source,
    @required this.appBar,
    @required this.filterSections,
    this.showHeaders = false,
    @required this.queryNotifier,
    this.applyQuery,
    @required this.emptyBuilder,
    this.settingsRouteKey,
    double appBarHeight = kToolbarHeight,
    @required this.onTap,
    this.onLongPress,
  }) : super(key: key) {
    _appBarHeightNotifier.value = appBarHeight;
  }

  static const Color detailColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: DoubleBackPopScope(
          child: HighlightInfoProvider(
            child: GestureAreaProtectorStack(
              child: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportSize = constraints.biggest;
                    assert(viewportSize.isFinite, 'Cannot layout collection with unbounded constraints.');
                    if (viewportSize.isEmpty) return SizedBox.shrink();

                    final tileExtentManager = TileExtentManager(
                      settingsRouteKey: settingsRouteKey ?? context.currentRouteName,
                      extentNotifier: _tileExtentNotifier,
                      columnCountDefault: columnCountDefault,
                      extentMin: extentMin,
                      spacing: spacing,
                    )..applyTileExtent(viewportSize: viewportSize);

                    final pinnedFilters = settings.pinnedFilters;
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

                        final scrollView = AnimationLimiter(
                          child: _buildDraggableScrollView(_buildScrollView(context, visibleFilterSections.isEmpty)),
                        );

                        final scaler = GridScaleGestureDetector<FilterGridItem<T>>(
                          tileExtentManager: tileExtentManager,
                          scrollableKey: _scrollableKey,
                          appBarHeightNotifier: _appBarHeightNotifier,
                          viewportSize: viewportSize,
                          gridBuilder: (center, extent, child) => CustomPaint(
                            painter: GridPainter(
                              center: center,
                              extent: extent,
                              spacing: tileExtentManager.spacing,
                              color: Colors.grey.shade700,
                            ),
                            child: child,
                          ),
                          scaledBuilder: (item, extent) {
                            final filter = item.filter;
                            return DecoratedFilterChip(
                              source: source,
                              filter: filter,
                              entry: item.entry,
                              extent: extent,
                              pinned: pinnedFilters.contains(filter),
                              highlightable: false,
                            );
                          },
                          getScaledItemTileRect: (context, item) {
                            final sectionedListLayout = context.read<SectionedListLayout<FilterGridItem<T>>>();
                            return sectionedListLayout.getTileRect(item) ?? Rect.zero;
                          },
                          onScaled: (item) => Provider.of<HighlightInfo>(context, listen: false).add(item.filter),
                          child: scrollView,
                        );

                        final sectionedListLayoutProvider = ValueListenableBuilder<double>(
                          valueListenable: _tileExtentNotifier,
                          builder: (context, tileExtent, child) => SectionedFilterListLayoutProvider<T>(
                            sections: visibleFilterSections,
                            showHeaders: showHeaders,
                            scrollableWidth: viewportSize.width,
                            tileExtent: tileExtent,
                            columnCount: tileExtentManager.getEffectiveColumnCountForExtent(viewportSize, tileExtent),
                            spacing: spacing,
                            tileBuilder: (gridItem) {
                              final filter = gridItem.filter;
                              final entry = gridItem.entry;
                              return MetaData(
                                metaData: ScalerMetadata(FilterGridItem<T>(filter, entry)),
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
                            },
                            child: scaler,
                          ),
                        );
                        return sectionedListLayoutProvider;
                      },
                    );
                  },
                ),
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

  ScrollView _buildScrollView(BuildContext context, bool empty) {
    Widget content;
    if (empty) {
      content = SliverFillRemaining(
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
      );
    } else {
      content = SectionedListSliver<FilterGridItem<T>>();
    }

    final padding = SliverToBoxAdapter(
      child: Selector<MediaQueryData, double>(
        selector: (context, mq) => mq.viewInsets.bottom,
        builder: (context, mqViewInsetsBottom, child) {
          return SizedBox(height: mqViewInsetsBottom);
        },
      ),
    );

    return CustomScrollView(
      key: _scrollableKey,
      controller: PrimaryScrollController.of(context),
      slivers: [
        appBar,
        content,
        padding,
      ],
    );
  }
}
