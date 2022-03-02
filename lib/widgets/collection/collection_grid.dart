import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/app_bar.dart';
import 'package:aves/widgets/collection/draggable_thumb_label.dart';
import 'package:aves/widgets/collection/grid/list_details_theme.dart';
import 'package:aves/widgets/collection/grid/section_layout.dart';
import 'package:aves/widgets/collection/grid/tile.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/sloppy_scroll_physics.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/grid/item_tracker.dart';
import 'package:aves/widgets/common/grid/scaling.dart';
import 'package:aves/widgets/common/grid/selector.dart';
import 'package:aves/widgets/common/grid/sliver.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:aves/widgets/common/providers/tile_extent_controller_provider.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CollectionGrid extends StatefulWidget {
  final String settingsRouteKey;

  static const int columnCountDefault = 4;
  static const double extentMin = 46;
  static const double extentMax = 300;
  static const double spacing = 2;

  const CollectionGrid({
    Key? key,
    required this.settingsRouteKey,
  }) : super(key: key);

  @override
  State<CollectionGrid> createState() => _CollectionGridState();
}

class _CollectionGridState extends State<CollectionGrid> {
  TileExtentController? _tileExtentController;

  @override
  void dispose() {
    _tileExtentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tileExtentController ??= TileExtentController(
      settingsRouteKey: widget.settingsRouteKey,
      columnCountDefault: CollectionGrid.columnCountDefault,
      extentMin: CollectionGrid.extentMin,
      extentMax: CollectionGrid.extentMax,
      spacing: CollectionGrid.spacing,
    );
    return TileExtentControllerProvider(
      controller: _tileExtentController!,
      child: _CollectionGridContent(),
    );
  }
}

class _CollectionGridContent extends StatelessWidget {
  final ValueNotifier<bool> _isScrollingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final settingsRouteKey = context.read<TileExtentController>().settingsRouteKey;
    final tileLayout = context.select<Settings, TileLayout>((s) => s.getTileLayout(settingsRouteKey));
    return Consumer<CollectionLens>(
      builder: (context, collection, child) {
        final sectionedListLayoutProvider = ValueListenableBuilder<double>(
          valueListenable: context.select<TileExtentController, ValueNotifier<double>>((controller) => controller.extentNotifier),
          builder: (context, thumbnailExtent, child) {
            return Selector<TileExtentController, Tuple3<double, int, double>>(
              selector: (context, c) => Tuple3(c.viewportSize.width, c.columnCount, c.spacing),
              builder: (context, c, child) {
                final scrollableWidth = c.item1;
                final columnCount = c.item2;
                final tileSpacing = c.item3;
                return GridTheme(
                  extent: thumbnailExtent,
                  child: EntryListDetailsTheme(
                    extent: thumbnailExtent,
                    child: ValueListenableBuilder<SourceState>(
                      valueListenable: collection.source.stateNotifier,
                      builder: (context, sourceState, child) {
                        late final Duration tileAnimationDelay;
                        if (sourceState == SourceState.ready) {
                          // do not listen for animation delay change
                          final target = context.read<DurationsData>().staggeredAnimationPageTarget;
                          tileAnimationDelay = context.read<TileExtentController>().getTileAnimationDelay(target);
                        } else {
                          tileAnimationDelay = Duration.zero;
                        }
                        return SectionedEntryListLayoutProvider(
                          collection: collection,
                          scrollableWidth: scrollableWidth,
                          tileLayout: tileLayout,
                          columnCount: columnCount,
                          spacing: tileSpacing,
                          tileExtent: thumbnailExtent,
                          tileBuilder: (entry) => AnimatedBuilder(
                            animation: favourites,
                            builder: (context, child) {
                              return InteractiveTile(
                                key: ValueKey(entry.id),
                                collection: collection,
                                entry: entry,
                                thumbnailExtent: thumbnailExtent,
                                tileLayout: tileLayout,
                                isScrollingNotifier: _isScrollingNotifier,
                              );
                            },
                          ),
                          tileAnimationDelay: tileAnimationDelay,
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
          child: _CollectionSectionedContent(
            collection: collection,
            isScrollingNotifier: _isScrollingNotifier,
            scrollController: PrimaryScrollController.of(context)!,
            tileLayout: tileLayout,
          ),
        );
        return sectionedListLayoutProvider;
      },
    );
  }
}

class _CollectionSectionedContent extends StatefulWidget {
  final CollectionLens collection;
  final ValueNotifier<bool> isScrollingNotifier;
  final ScrollController scrollController;
  final TileLayout tileLayout;

  const _CollectionSectionedContent({
    required this.collection,
    required this.isScrollingNotifier,
    required this.scrollController,
    required this.tileLayout,
  });

  @override
  State<_CollectionSectionedContent> createState() => _CollectionSectionedContentState();
}

class _CollectionSectionedContentState extends State<_CollectionSectionedContent> {
  CollectionLens get collection => widget.collection;

  TileLayout get tileLayout => widget.tileLayout;

  ScrollController get scrollController => widget.scrollController;

  final ValueNotifier<double> appBarHeightNotifier = ValueNotifier(0);

  final GlobalKey scrollableKey = GlobalKey(debugLabel: 'thumbnail-collection-scrollable');

  @override
  Widget build(BuildContext context) {
    final scrollView = AnimationLimiter(
      child: _CollectionScrollView(
        scrollableKey: scrollableKey,
        collection: collection,
        appBar: CollectionAppBar(
          appBarHeightNotifier: appBarHeightNotifier,
          collection: collection,
        ),
        appBarHeightNotifier: appBarHeightNotifier,
        isScrollingNotifier: widget.isScrollingNotifier,
        scrollController: scrollController,
      ),
    );

    final scaler = _CollectionScaler(
      scrollableKey: scrollableKey,
      appBarHeightNotifier: appBarHeightNotifier,
      tileLayout: tileLayout,
      child: scrollView,
    );

    final isMainMode = context.select<ValueNotifier<AppMode>, bool>((vn) => vn.value == AppMode.main);
    final selector = GridSelectionGestureDetector(
      scrollableKey: scrollableKey,
      selectable: isMainMode,
      items: collection.sortedEntries,
      scrollController: scrollController,
      appBarHeightNotifier: appBarHeightNotifier,
      child: scaler,
    );

    return GridItemTracker<AvesEntry>(
      scrollableKey: scrollableKey,
      tileLayout: tileLayout,
      appBarHeightNotifier: appBarHeightNotifier,
      scrollController: scrollController,
      child: selector,
    );
  }
}

class _CollectionScaler extends StatelessWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final TileLayout tileLayout;
  final Widget child;

  const _CollectionScaler({
    required this.scrollableKey,
    required this.appBarHeightNotifier,
    required this.tileLayout,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tileSpacing = context.select<TileExtentController, double>((controller) => controller.spacing);
    return GridScaleGestureDetector<AvesEntry>(
      scrollableKey: scrollableKey,
      tileLayout: tileLayout,
      heightForWidth: (width) => width,
      gridBuilder: (center, tileSize, child) => CustomPaint(
        painter: GridPainter(
          tileLayout: tileLayout,
          tileCenter: center,
          tileSize: tileSize,
          spacing: tileSpacing,
          borderWidth: DecoratedThumbnail.borderWidth,
          borderRadius: Radius.zero,
          color: DecoratedThumbnail.borderColor,
          textDirection: Directionality.of(context),
        ),
        child: child,
      ),
      scaledBuilder: (entry, tileSize) => EntryListDetailsTheme(
        extent: tileSize.height,
        child: Tile(
          entry: entry,
          thumbnailExtent: context.read<TileExtentController>().effectiveExtentMax,
          tileLayout: tileLayout,
        ),
      ),
      child: child,
    );
  }
}

class _CollectionScrollView extends StatefulWidget {
  final GlobalKey scrollableKey;
  final CollectionLens collection;
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final ValueNotifier<bool> isScrollingNotifier;
  final ScrollController scrollController;

  const _CollectionScrollView({
    required this.scrollableKey,
    required this.collection,
    required this.appBar,
    required this.appBarHeightNotifier,
    required this.isScrollingNotifier,
    required this.scrollController,
  });

  @override
  State<_CollectionScrollView> createState() => _CollectionScrollViewState();
}

class _CollectionScrollViewState extends State<_CollectionScrollView> {
  Timer? _scrollMonitoringTimer;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant _CollectionScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _stopScrollMonitoringTimer();
    super.dispose();
  }

  void _registerWidget(_CollectionScrollView widget) {
    widget.collection.filterChangeNotifier.addListener(_scrollToTop);
    widget.collection.sortSectionChangeNotifier.addListener(_scrollToTop);
    widget.scrollController.addListener(_onScrollChange);
  }

  void _unregisterWidget(_CollectionScrollView widget) {
    widget.collection.filterChangeNotifier.removeListener(_scrollToTop);
    widget.collection.sortSectionChangeNotifier.removeListener(_scrollToTop);
    widget.scrollController.removeListener(_onScrollChange);
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = _buildScrollView(widget.appBar, widget.collection);
    return _buildDraggableScrollView(scrollView, widget.collection);
  }

  Widget _buildDraggableScrollView(ScrollView scrollView, CollectionLens collection) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.appBarHeightNotifier,
      builder: (context, appBarHeight, child) => Selector<MediaQueryData, double>(
        selector: (context, mq) => mq.effectiveBottomPadding,
        builder: (context, mqPaddingBottom, child) => DraggableScrollbar(
          backgroundColor: Colors.white,
          scrollThumbHeight: avesScrollThumbHeight,
          scrollThumbBuilder: avesScrollThumbBuilder(
            height: avesScrollThumbHeight,
            backgroundColor: Colors.white,
          ),
          controller: widget.scrollController,
          padding: EdgeInsets.only(
            // padding to keep scroll thumb between app bar above and nav bar below
            top: appBarHeight,
            bottom: mqPaddingBottom,
          ),
          labelTextBuilder: (offsetY) => CollectionDraggableThumbLabel(
            collection: collection,
            offsetY: offsetY,
          ),
          child: scrollView,
        ),
        child: child,
      ),
    );
  }

  ScrollView _buildScrollView(Widget appBar, CollectionLens collection) {
    return CustomScrollView(
      key: widget.scrollableKey,
      primary: true,
      // workaround to prevent scrolling the app bar away
      // when there is no content and we use `SliverFillRemaining`
      physics: collection.isEmpty ? const NeverScrollableScrollPhysics() : const SloppyScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      cacheExtent: context.select<TileExtentController, double>((controller) => controller.effectiveExtentMax),
      slivers: [
        appBar,
        collection.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyCollectionPlaceholder(collection),
              )
            : const SectionedListSliver<AvesEntry>(),
        const BottomPaddingSliver(),
      ],
    );
  }

  Widget _buildEmptyCollectionPlaceholder(CollectionLens collection) {
    return ValueListenableBuilder<SourceState>(
      valueListenable: collection.source.stateNotifier,
      builder: (context, sourceState, child) {
        if (sourceState == SourceState.loading) {
          return const SizedBox.shrink();
        }
        if (collection.filters.any((filter) => filter is FavouriteFilter)) {
          return EmptyContent(
            icon: AIcons.favourite,
            text: context.l10n.collectionEmptyFavourites,
          );
        }
        if (collection.filters.any((filter) => filter is MimeFilter && filter.mime == MimeTypes.anyVideo)) {
          return EmptyContent(
            icon: AIcons.video,
            text: context.l10n.collectionEmptyVideos,
          );
        }
        return EmptyContent(
          icon: AIcons.image,
          text: context.l10n.collectionEmptyImages,
        );
      },
    );
  }

  void _scrollToTop() => widget.scrollController.jumpTo(0);

  void _onScrollChange() {
    widget.isScrollingNotifier.value = true;
    _stopScrollMonitoringTimer();
    _scrollMonitoringTimer = Timer(Durations.collectionScrollMonitoringTimerDelay, () {
      widget.isScrollingNotifier.value = false;
    });
  }

  void _stopScrollMonitoringTimer() {
    _scrollMonitoringTimer?.cancel();
  }
}
