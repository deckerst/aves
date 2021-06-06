import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/app_bar.dart';
import 'package:aves/widgets/collection/draggable_thumb_label.dart';
import 'package:aves/widgets/collection/grid/section_layout.dart';
import 'package:aves/widgets/collection/grid/selector.dart';
import 'package:aves/widgets/collection/grid/thumbnail.dart';
import 'package:aves/widgets/collection/thumbnail/decorated.dart';
import 'package:aves/widgets/collection/thumbnail/theme.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/sloppy_scroll_physics.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:aves/widgets/common/grid/sliver.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:aves/widgets/common/providers/tile_extent_controller_provider.dart';
import 'package:aves/widgets/common/scaling.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CollectionGrid extends StatefulWidget {
  final String? settingsRouteKey;

  const CollectionGrid({
    this.settingsRouteKey,
  });

  @override
  _CollectionGridState createState() => _CollectionGridState();
}

class _CollectionGridState extends State<CollectionGrid> {
  TileExtentController? _tileExtentController;

  @override
  Widget build(BuildContext context) {
    _tileExtentController ??= TileExtentController(
      settingsRouteKey: widget.settingsRouteKey ?? context.currentRouteName!,
      columnCountDefault: 4,
      extentMin: 46,
      spacing: 2,
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
    return Consumer<CollectionLens>(
      builder: (context, collection, child) {
        final sectionedListLayoutProvider = ValueListenableBuilder<double>(
          valueListenable: context.select<TileExtentController, ValueNotifier<double>>((controller) => controller.extentNotifier),
          builder: (context, tileExtent, child) {
            return ThumbnailTheme(
              extent: tileExtent,
              child: Selector<TileExtentController, Tuple3<double, int, double>>(
                selector: (context, c) => Tuple3(c.viewportSize.width, c.columnCount, c.spacing),
                builder: (context, c, child) {
                  final scrollableWidth = c.item1;
                  final columnCount = c.item2;
                  final tileSpacing = c.item3;
                  // do not listen for animation delay change
                  final controller = Provider.of<TileExtentController>(context, listen: false);
                  final tileAnimationDelay = controller.getTileAnimationDelay(Durations.staggeredAnimationPageTarget);
                  return SectionedEntryListLayoutProvider(
                    collection: collection,
                    scrollableWidth: scrollableWidth,
                    columnCount: columnCount,
                    spacing: tileSpacing,
                    tileExtent: tileExtent,
                    tileBuilder: (entry) => InteractiveThumbnail(
                      key: ValueKey(entry.contentId),
                      collection: collection,
                      entry: entry,
                      tileExtent: tileExtent,
                      isScrollingNotifier: _isScrollingNotifier,
                    ),
                    tileAnimationDelay: tileAnimationDelay,
                    child: _CollectionSectionedContent(
                      collection: collection,
                      isScrollingNotifier: _isScrollingNotifier,
                      scrollController: PrimaryScrollController.of(context)!,
                    ),
                  );
                },
              ),
            );
          },
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

  const _CollectionSectionedContent({
    required this.collection,
    required this.isScrollingNotifier,
    required this.scrollController,
  });

  @override
  _CollectionSectionedContentState createState() => _CollectionSectionedContentState();
}

class _CollectionSectionedContentState extends State<_CollectionSectionedContent> {
  CollectionLens get collection => widget.collection;

  ScrollController get scrollController => widget.scrollController;

  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final GlobalKey _scrollableKey = GlobalKey(debugLabel: 'thumbnail-collection-scrollable');

  @override
  Widget build(BuildContext context) {
    final scrollView = AnimationLimiter(
      child: _CollectionScrollView(
        scrollableKey: _scrollableKey,
        collection: collection,
        appBar: CollectionAppBar(
          appBarHeightNotifier: _appBarHeightNotifier,
          collection: collection,
        ),
        appBarHeightNotifier: _appBarHeightNotifier,
        isScrollingNotifier: widget.isScrollingNotifier,
        scrollController: scrollController,
      ),
    );

    final scaler = _CollectionScaler(
      scrollableKey: _scrollableKey,
      appBarHeightNotifier: _appBarHeightNotifier,
      child: scrollView,
    );

    final isMainMode = context.select<ValueNotifier<AppMode>, bool>((vn) => vn.value == AppMode.main);
    final selector = GridSelectionGestureDetector(
      selectable: isMainMode,
      collection: collection,
      scrollController: scrollController,
      appBarHeightNotifier: _appBarHeightNotifier,
      child: scaler,
    );

    return selector;
  }
}

class _CollectionScaler extends StatelessWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final Widget child;

  const _CollectionScaler({
    required this.scrollableKey,
    required this.appBarHeightNotifier,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tileSpacing = context.select<TileExtentController, double>((controller) => controller.spacing);
    return GridScaleGestureDetector<AvesEntry>(
      scrollableKey: scrollableKey,
      appBarHeightNotifier: appBarHeightNotifier,
      gridBuilder: (center, extent, child) => CustomPaint(
        painter: GridPainter(
          center: center,
          extent: extent,
          spacing: tileSpacing,
          borderWidth: DecoratedThumbnail.borderWidth,
          borderRadius: Radius.zero,
          color: DecoratedThumbnail.borderColor,
        ),
        child: child,
      ),
      scaledBuilder: (entry, extent) => ThumbnailTheme(
        extent: extent,
        child: DecoratedThumbnail(
          entry: entry,
          tileExtent: extent,
          selectable: false,
          highlightable: false,
        ),
      ),
      getScaledItemTileRect: (context, entry) {
        final sectionedListLayout = context.read<SectionedListLayout<AvesEntry>>();
        return sectionedListLayout.getTileRect(entry) ?? Rect.zero;
      },
      onScaled: (entry) => context.read<HighlightInfo>().set(entry),
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
  _CollectionScrollViewState createState() => _CollectionScrollViewState();
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
    widget.collection.sortGroupChangeNotifier.addListener(_scrollToTop);
    widget.scrollController.addListener(_onScrollChange);
  }

  void _unregisterWidget(_CollectionScrollView widget) {
    widget.collection.filterChangeNotifier.removeListener(_scrollToTop);
    widget.collection.sortGroupChangeNotifier.removeListener(_scrollToTop);
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
      physics: collection.isEmpty ? NeverScrollableScrollPhysics() : SloppyScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      cacheExtent: context.select<TileExtentController, double>((controller) => controller.effectiveExtentMax),
      slivers: [
        appBar,
        collection.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyCollectionPlaceholder(collection),
              )
            : SectionedListSliver<AvesEntry>(),
        BottomPaddingSliver(),
      ],
    );
  }

  Widget _buildEmptyCollectionPlaceholder(CollectionLens collection) {
    return ValueListenableBuilder<SourceState>(
      valueListenable: collection.source.stateNotifier,
      builder: (context, sourceState, child) {
        if (sourceState == SourceState.loading) {
          return SizedBox.shrink();
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
