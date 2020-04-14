import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/widgets/album/app_bar.dart';
import 'package:aves/widgets/album/collection_page.dart';
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
  final ValueNotifier<PageState> stateNotifier;

  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<double> _tileExtentNotifier = ValueNotifier(0);
  final GlobalKey _scrollableKey = GlobalKey();

  ThumbnailCollection({
    Key key,
    @required this.stateNotifier,
  }) : super(key: key);

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
              final scrollView = _buildScrollView(collection);
              final draggable = _buildDraggableScrollView(scrollView);
              final scaler = GridScaleGestureDetector(
                scrollableKey: _scrollableKey,
                extentNotifier: _tileExtentNotifier,
                mqSize: mqSize,
                mqHorizontalPadding: mqHorizontalPadding,
                child: draggable,
              );
              final sectionedListLayoutProvider = ValueListenableBuilder<double>(
                valueListenable: _tileExtentNotifier,
                builder: (context, tileExtent, child) => SectionedListLayoutProvider(
                  collection: collection,
                  scrollableWidth: mqSize.width - mqHorizontalPadding,
                  tileExtent: tileExtent,
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

  ScrollView _buildScrollView(CollectionLens collection) {
    return CustomScrollView(
      key: _scrollableKey,
      primary: true,
      // workaround to prevent scrolling the app bar away
      // when there is no content and we use `SliverFillRemaining`
      physics: collection.isEmpty ? const NeverScrollableScrollPhysics() : null,
      slivers: [
        CollectionAppBar(
          stateNotifier: stateNotifier,
          appBarHeightNotifier: _appBarHeightNotifier,
          collection: collection,
        ),
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
      valueListenable: _appBarHeightNotifier,
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
}
