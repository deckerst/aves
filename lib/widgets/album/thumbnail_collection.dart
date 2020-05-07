import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/widgets/album/app_bar.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/album/grid/list_section_layout.dart';
import 'package:aves/widgets/album/grid/list_sliver.dart';
import 'package:aves/widgets/album/grid/scaling.dart';
import 'package:aves/widgets/album/grid/tile_extent_manager.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/scroll_thumb.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ThumbnailCollection extends StatelessWidget {
  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<double> _tileExtentNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Selector<MediaQueryData, Tuple2<Size, double>>(
        selector: (context, mq) => Tuple2(mq.size, mq.padding.horizontal),
        builder: (context, mq, child) {
          final mqSize = mq.item1;
          final mqHorizontalPadding = mq.item2;
          TileExtentManager.applyTileExtent(mqSize, mqHorizontalPadding, _tileExtentNotifier);

          // do not replace by Provider.of<CollectionLens>
          // so that view updates on collection filter changes
          return Consumer<CollectionLens>(
            builder: (context, collection, child) {
              final appBar = CollectionAppBar(
                appBarHeightNotifier: _appBarHeightNotifier,
                collection: collection,
              );

              final sectionedListLayoutProvider = ValueListenableBuilder<double>(
                valueListenable: _tileExtentNotifier,
                builder: (context, tileExtent, child) => SectionedListLayoutProvider(
                  collection: collection,
                  scrollableWidth: mqSize.width - mqHorizontalPadding,
                  tileExtent: tileExtent,
                  child: _ScalableThumbnailCollection(
                    appBarHeightNotifier: _appBarHeightNotifier,
                    tileExtentNotifier: _tileExtentNotifier,
                    collection: collection,
                    mqSize: mqSize,
                    mqHorizontalPadding: mqHorizontalPadding,
                    appBar: appBar,
                  ),
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

class _ScalableThumbnailCollection extends StatelessWidget {
  final CollectionLens collection;
  final ValueNotifier<double> appBarHeightNotifier;
  final ValueNotifier<double> tileExtentNotifier;
  final Size mqSize;
  final double mqHorizontalPadding;
  final Widget appBar;

  final GlobalKey _scrollableKey = GlobalKey();

  _ScalableThumbnailCollection({
    @required this.appBarHeightNotifier,
    @required this.tileExtentNotifier,
    @required this.collection,
    @required this.mqSize,
    @required this.mqHorizontalPadding,
    @required this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final scrollView = _buildScrollView(appBar, collection);
    final draggable = _buildDraggableScrollView(scrollView);
    return GridScaleGestureDetector(
      scrollableKey: _scrollableKey,
      extentNotifier: tileExtentNotifier,
      mqSize: mqSize,
      mqHorizontalPadding: mqHorizontalPadding,
      onScaled: (entry) => _scrollToEntry(context, entry),
      child: draggable,
    );
  }

  ScrollView _buildScrollView(Widget appBar, CollectionLens collection) {
    return CustomScrollView(
      key: _scrollableKey,
      primary: true,
      // workaround to prevent scrolling the app bar away
      // when there is no content and we use `SliverFillRemaining`
      physics: collection.isEmpty ? const NeverScrollableScrollPhysics() : null,
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
      valueListenable: appBarHeightNotifier,
      builder: (context, appBarHeight, child) => Selector<MediaQueryData, double>(
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
    return collection.filters.any((filter) => filter is FavouriteFilter)
        ? const EmptyContent(
            icon: AIcons.favourite,
            text: 'No favourites!',
          )
        : collection.filters.any((filter) => filter is MimeFilter && filter.mime == MimeTypes.ANY_VIDEO)
            ? const EmptyContent(
                icon: AIcons.video,
              )
            : const EmptyContent();
  }

  // about scrolling & offset retrieval:
  // `Scrollable.ensureVisible` only works on already rendered objects
  // `RenderViewport.showOnScreen` can find any `RenderSliver`, but not always a `RenderMetadata`
  // `RenderViewport.scrollOffsetOf` is a good alternative
  void _scrollToEntry(BuildContext context, ImageEntry entry) {
    final scrollableContext = _scrollableKey.currentContext;
    final scrollableHeight = (scrollableContext.findRenderObject() as RenderBox).size.height;
    final sectionLayout = Provider.of<SectionedListLayout>(context, listen: false);
    final tileRect = sectionLayout.getTileRect(entry) ?? Rect.zero;
    // most of the time the app bar will be scrolled away after scaling,
    // so we compensate for it to center the focal point thumbnail
    final appBarHeight = appBarHeightNotifier.value;
    final scrollOffset = tileRect.top + (tileRect.height - scrollableHeight) / 2 + appBarHeight;

    PrimaryScrollController.of(context)?.jumpTo(max(.0, scrollOffset));
  }
}
