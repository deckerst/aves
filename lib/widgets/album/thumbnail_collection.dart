import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/video.dart';
import 'package:aves/widgets/album/collection_app_bar.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/album/collection_scaling.dart';
import 'package:aves/widgets/album/collection_section.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/common/scroll_thumb.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class ThumbnailCollection extends StatelessWidget {
  final ValueNotifier<PageState> stateNotifier;

  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<int> _columnCountNotifier = ValueNotifier(4);
  final GlobalKey _scrollableKey = GlobalKey();

  ThumbnailCollection({
    Key key,
    @required this.stateNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('$runtimeType build');
    final collection = Provider.of<CollectionLens>(context);
    final sections = collection.sections;
    final sectionKeys = sections.keys.toList();
    final showHeaders = collection.showHeaders;

    return SafeArea(
      child: Selector<MediaQueryData, double>(
        selector: (c, mq) => mq.viewInsets.bottom,
        builder: (c, mqViewInsetsBottom, child) {
          return GridScaleGestureDetector(
            scrollableKey: _scrollableKey,
            columnCountNotifier: _columnCountNotifier,
            child: ValueListenableBuilder<int>(
              valueListenable: _columnCountNotifier,
              builder: (context, columnCount, child) {
                debugPrint('$runtimeType builder columnCount=$columnCount entries=${collection.entryCount}');
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
                    if (collection.isEmpty)
                      SliverFillRemaining(
                        child: _buildEmptyCollectionPlaceholder(collection),
                        hasScrollBody: false,
                      ),
                    ...sectionKeys.map((sectionKey) => SectionSliver(
                          collection: collection,
                          sectionKey: sectionKey,
                          columnCount: columnCount,
                          showHeader: showHeaders,
                        )),
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
                      scrollThumbBuilder: avesScrollThumbBuilder(),
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
      ),
    );
  }

  Widget _buildEmptyCollectionPlaceholder(CollectionLens collection) {
    return collection.filters.any((filter) => filter is FavouriteFilter)
        ? const EmptyContent(
            icon: OMIcons.favoriteBorder,
            text: 'No favourites!',
          )
        : collection.filters.any((filter) => filter is VideoFilter)
            ? const EmptyContent(
                icon: OMIcons.movie,
              )
            : const EmptyContent();
  }
}
