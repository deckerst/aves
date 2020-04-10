import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/widgets/album/collection_app_bar.dart';
import 'package:aves/widgets/album/collection_list_sliver.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/album/collection_scaling.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/album/tile_extent_manager.dart';
import 'package:aves/widgets/common/scroll_thumb.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
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
      child: Selector<MediaQueryData, Tuple3<Size, EdgeInsets, double>>(
        selector: (c, mq) => Tuple3(mq.size, mq.padding, mq.viewInsets.bottom),
        builder: (c, mq, child) {
          final mqSize = mq.item1;
          final mqPadding = mq.item2;
          final mqViewInsetsBottom = mq.item3;
          TileExtentManager.applyTileExtent(mqSize, mqPadding, _tileExtentNotifier);
          return Consumer<CollectionLens>(
            builder: (context, collection, child) {
//              debugPrint('$runtimeType collection builder entries=${collection.entryCount}');
              final sectionKeys = collection.sections.keys.toList();
              final showHeaders = collection.showHeaders;
              return GridScaleGestureDetector(
                scrollableKey: _scrollableKey,
                extentNotifier: _tileExtentNotifier,
                mqSize: mqSize,
                mqPadding: mqPadding,
                child: ValueListenableBuilder<double>(
                  valueListenable: _tileExtentNotifier,
                  builder: (context, tileExtent, child) {
                    debugPrint('$runtimeType tileExtent builder entries=${collection.entryCount} tileExtent=$tileExtent');
                    final scrollView = CustomScrollView(
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
                            : CollectionListSliver(
                                collection: collection,
                                showHeader: showHeaders,
                                columnCount: (mqSize.width / tileExtent).round(),
                                tileExtent: tileExtent,
                              ),
                        SliverToBoxAdapter(
                          child: Selector<MediaQueryData, double>(
                            selector: (c, mq) => mq.viewInsets.bottom,
                            builder: (c, mqViewInsetsBottom, child) {
                              return SizedBox(height: mqViewInsetsBottom);
                            },
                          ),
                        ),
                      ],
                    );

                    return ValueListenableBuilder<double>(
                      valueListenable: _appBarHeightNotifier,
                      builder: (context, appBarHeight, child) {
                        return DraggableScrollbar(
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
                          child: child,
                        );
                      },
                      child: scrollView,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyCollectionPlaceholder(CollectionLens collection) {
    return collection.filters.any((filter) => filter is FavouriteFilter)
        ? const EmptyContent(
            icon: OMIcons.favoriteBorder,
            text: 'No favourites!',
          )
        : collection.filters.any((filter) => filter is MimeFilter && filter.mime == MimeTypes.ANY_VIDEO)
            ? const EmptyContent(
                icon: OMIcons.movie,
              )
            : const EmptyContent();
  }
}
