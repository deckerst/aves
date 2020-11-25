import 'dart:async';

import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/app_bar.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/collection/grid/list_section_layout.dart';
import 'package:aves/widgets/collection/grid/list_sliver.dart';
import 'package:aves/widgets/collection/grid/scaling.dart';
import 'package:aves/widgets/collection/grid/tile_extent_manager.dart';
import 'package:aves/widgets/collection/thumbnail/decorated.dart';
import 'package:aves/widgets/common/behaviour/sloppy_scroll_physics.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ThumbnailCollection extends StatelessWidget {
  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<double> _tileExtentNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isScrollingNotifier = ValueNotifier(false);
  final GlobalKey _scrollableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = constraints.biggest;
          assert(viewportSize.isFinite, 'Cannot layout collection with unbounded constraints.');
          if (viewportSize.isEmpty) return SizedBox.shrink();

          TileExtentManager.applyTileExtent(viewportSize, _tileExtentNotifier);
          final cacheExtent = TileExtentManager.extentMaxForSize(viewportSize) * 2;

          // do not replace by Provider.of<CollectionLens>
          // so that view updates on collection filter changes
          return Consumer<CollectionLens>(
            builder: (context, collection, child) {
              final scrollView = CollectionScrollView(
                scrollableKey: _scrollableKey,
                collection: collection,
                appBar: CollectionAppBar(
                  appBarHeightNotifier: _appBarHeightNotifier,
                  collection: collection,
                ),
                appBarHeightNotifier: _appBarHeightNotifier,
                isScrollingNotifier: _isScrollingNotifier,
                scrollController: PrimaryScrollController.of(context),
                cacheExtent: cacheExtent,
              );

              final scaler = GridScaleGestureDetector<ImageEntry>(
                scrollableKey: _scrollableKey,
                appBarHeightNotifier: _appBarHeightNotifier,
                extentNotifier: _tileExtentNotifier,
                viewportSize: viewportSize,
                scaledBuilder: (entry, extent) => DecoratedThumbnail(
                  entry: entry,
                  extent: extent,
                  showOverlay: false,
                ),
                getScaledItemTileRect: (entry) {
                  final sectionedListLayout = Provider.of<SectionedListLayout>(context, listen: false);
                  return sectionedListLayout.getTileRect(entry) ?? Rect.zero;
                },
                onScaled: collection.highlight,
                child: scrollView,
              );

              final sectionedListLayoutProvider = ValueListenableBuilder<double>(
                valueListenable: _tileExtentNotifier,
                builder: (context, tileExtent, child) => SectionedListLayoutProvider(
                  collection: collection,
                  scrollableWidth: viewportSize.width,
                  tileExtent: tileExtent,
                  thumbnailBuilder: (entry) => GridThumbnail(
                    key: ValueKey(entry.contentId),
                    collection: collection,
                    entry: entry,
                    tileExtent: tileExtent,
                    isScrollingNotifier: _isScrollingNotifier,
                  ),
                  child: scaler,
                ),
              );
              return sectionedListLayoutProvider;
            },
          );
        },
      ),
    );
  }
}

class CollectionScrollView extends StatefulWidget {
  final GlobalKey scrollableKey;
  final CollectionLens collection;
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final ValueNotifier<bool> isScrollingNotifier;
  final ScrollController scrollController;
  final double cacheExtent;

  const CollectionScrollView({
    @required this.scrollableKey,
    @required this.collection,
    @required this.appBar,
    @required this.appBarHeightNotifier,
    @required this.isScrollingNotifier,
    @required this.scrollController,
    @required this.cacheExtent,
  });

  @override
  _CollectionScrollViewState createState() => _CollectionScrollViewState();
}

class _CollectionScrollViewState extends State<CollectionScrollView> {
  Timer _scrollMonitoringTimer;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(CollectionScrollView oldWidget) {
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

  void _registerWidget(CollectionScrollView widget) {
    widget.scrollController.addListener(_onScrollChange);
  }

  void _unregisterWidget(CollectionScrollView widget) {
    widget.scrollController.removeListener(_onScrollChange);
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = _buildScrollView(widget.appBar, widget.collection);
    return _buildDraggableScrollView(scrollView);
  }

  ScrollView _buildScrollView(Widget appBar, CollectionLens collection) {
    return CustomScrollView(
      key: widget.scrollableKey,
      primary: true,
      // workaround to prevent scrolling the app bar away
      // when there is no content and we use `SliverFillRemaining`
      physics: collection.isEmpty ? NeverScrollableScrollPhysics() : SloppyScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      cacheExtent: widget.cacheExtent,
      slivers: [
        appBar,
        collection.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyCollectionPlaceholder(collection),
                hasScrollBody: false,
              )
            : CollectionListSliver(),
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

  Widget _buildDraggableScrollView(ScrollView scrollView) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.appBarHeightNotifier,
      builder: (context, appBarHeight, child) => Selector<MediaQueryData, double>(
        selector: (context, mq) => mq.viewInsets.bottom,
        builder: (context, mqViewInsetsBottom, child) => DraggableScrollbar(
          heightScrollThumb: avesScrollThumbHeight,
          backgroundColor: Colors.white,
          scrollThumbBuilder: avesScrollThumbBuilder(
            height: avesScrollThumbHeight,
            backgroundColor: Colors.white,
          ),
          controller: widget.scrollController,
          padding: EdgeInsets.only(
            // padding to keep scroll thumb between app bar above and nav bar below
            top: appBarHeight,
            bottom: mqViewInsetsBottom,
          ),
          child: scrollView,
        ),
        child: child,
      ),
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
            text: 'No favourites',
          );
        }
        if (collection.filters.any((filter) => filter is MimeFilter && filter.mime == MimeTypes.anyVideo)) {
          return EmptyContent(
            icon: AIcons.video,
            text: 'No videos',
          );
        }
        return EmptyContent(
          icon: AIcons.image,
          text: 'No images',
        );
      },
    );
  }

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
