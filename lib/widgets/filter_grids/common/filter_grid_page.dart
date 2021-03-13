import 'dart:ui';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/settings.dart';
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
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves/widgets/filter_grids/common/section_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

typedef QueryTest<T extends CollectionFilter> = Iterable<FilterGridItem<T>> Function(Iterable<FilterGridItem<T>> filters, String query);

class FilterGridPage<T extends CollectionFilter> extends StatelessWidget {
  final Widget appBar;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final bool showHeaders;
  final ValueNotifier<String> queryNotifier;
  final Widget Function() emptyBuilder;
  final String settingsRouteKey;
  final double appBarHeight;
  final QueryTest<T> applyQuery;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  const FilterGridPage({
    Key key,
    @required this.appBar,
    @required this.filterSections,
    this.showHeaders = false,
    @required this.queryNotifier,
    this.applyQuery,
    @required this.emptyBuilder,
    this.settingsRouteKey,
    this.appBarHeight = kToolbarHeight,
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
              child: TileExtentControllerProvider(
                controller: TileExtentController(
                  settingsRouteKey: settingsRouteKey ?? context.currentRouteName,
                  columnCountDefault: 2,
                  extentMin: 60,
                  spacing: 8,
                ),
                child: _FilterGridPageContent<T>(
                  appBar: appBar,
                  filterSections: filterSections,
                  showHeaders: showHeaders,
                  queryNotifier: queryNotifier,
                  applyQuery: applyQuery,
                  emptyBuilder: emptyBuilder,
                  appBarHeight: appBarHeight,
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

class _FilterGridPageContent<T extends CollectionFilter> extends StatelessWidget {
  final Widget appBar;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> filterSections;
  final bool showHeaders;
  final ValueNotifier<String> queryNotifier;
  final Widget Function() emptyBuilder;
  final QueryTest<T> applyQuery;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);

  _FilterGridPageContent({
    Key key,
    @required this.appBar,
    @required this.filterSections,
    @required this.showHeaders,
    @required this.queryNotifier,
    @required this.applyQuery,
    @required this.emptyBuilder,
    @required double appBarHeight,
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
            final columnCount = context.select<TileExtentController, int>((controller) => controller.getEffectiveColumnCountForExtent(tileExtent));
            final tileSpacing = context.select<TileExtentController, double>((controller) => controller.spacing);
            return SectionedFilterListLayoutProvider<T>(
              sections: visibleFilterSections,
              showHeaders: showHeaders,
              scrollableWidth: context.select<TileExtentController, double>((controller) => controller.viewportSize.width),
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
              child: _SectionedContent<T>(
                appBar: appBar,
                appBarHeightNotifier: _appBarHeightNotifier,
                visibleFilterSections: visibleFilterSections,
                emptyBuilder: emptyBuilder,
                scrollController: PrimaryScrollController.of(context),
              ),
            );
          },
        );
        return sectionedListLayoutProvider;
      },
    );
  }
}

class _SectionedContent<T extends CollectionFilter> extends StatefulWidget {
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final Map<ChipSectionKey, List<FilterGridItem<T>>> visibleFilterSections;
  final Widget Function() emptyBuilder;
  final ScrollController scrollController;

  const _SectionedContent({
    @required this.appBar,
    @required this.appBarHeightNotifier,
    @required this.visibleFilterSections,
    @required this.emptyBuilder,
    @required this.scrollController,
  });

  @override
  _SectionedContentState createState() => _SectionedContentState<T>();
}

class _SectionedContentState<T extends CollectionFilter> extends State<_SectionedContent<T>> {
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

  @override
  Widget build(BuildContext context) {
    final pinnedFilters = settings.pinnedFilters;
    final tileSpacing = context.select<TileExtentController, double>((controller) => controller.spacing);
    return GridScaleGestureDetector<FilterGridItem<T>>(
      scrollableKey: _scrollableKey,
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
      child: AnimationLimiter(
        child: _buildDraggableScrollView(_buildScrollView(context, visibleFilterSections.isEmpty)),
      ),
    );
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
        child: scrollView,
      ),
    );
  }

  ScrollView _buildScrollView(BuildContext context, bool empty) {
    Widget content;
    if (empty) {
      content = SliverFillRemaining(
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
      );
    } else {
      content = SectionedListSliver<FilterGridItem<T>>();
    }

    return CustomScrollView(
      key: _scrollableKey,
      controller: scrollController,
      slivers: [
        appBar,
        content,
        BottomPaddingSliver(),
      ],
    );
  }
}
