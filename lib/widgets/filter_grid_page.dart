import 'dart:ui';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/album/thumbnail/raster.dart';
import 'package:aves/widgets/album/thumbnail/vector.dart';
import 'package:aves/widgets/app_drawer.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class AlbumListPage extends StatelessWidget {
  final CollectionSource source;

  const AlbumListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: androidFileUtils.appNameChangeNotifier,
      builder: (context, child) => StreamBuilder(
        stream: source.eventBus.on<AlbumsChangedEvent>(),
        builder: (context, snapshot) => FilterNavigationPage(
          source: source,
          title: 'Albums',
          filterEntries: source.getAlbumEntries(),
          filterBuilder: (s) => AlbumFilter(s, source.getUniqueAlbumName(s)),
          emptyBuilder: () => EmptyContent(
            icon: AIcons.album,
            text: 'No albums',
          ),
        ),
      ),
    );
  }
}

class CountryListPage extends StatelessWidget {
  final CollectionSource source;

  const CountryListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: source.eventBus.on<LocationsChangedEvent>(),
      builder: (context, snapshot) => FilterNavigationPage(
        source: source,
        title: 'Countries',
        filterEntries: source.getCountryEntries(),
        filterBuilder: (s) => LocationFilter(LocationLevel.country, s),
        emptyBuilder: () => EmptyContent(
          icon: AIcons.location,
          text: 'No countries',
        ),
      ),
    );
  }
}

class TagListPage extends StatelessWidget {
  final CollectionSource source;

  const TagListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: source.eventBus.on<TagsChangedEvent>(),
      builder: (context, snapshot) => FilterNavigationPage(
        source: source,
        title: 'Tags',
        filterEntries: source.getTagEntries(),
        filterBuilder: (s) => TagFilter(s),
        emptyBuilder: () => EmptyContent(
          icon: AIcons.tag,
          text: 'No tags',
        ),
      ),
    );
  }
}

class FilterNavigationPage extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final Widget Function() emptyBuilder;

  const FilterNavigationPage({
    @required this.source,
    @required this.title,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FilterGridPage(
      source: source,
      appBar: SliverAppBar(
        title: SourceStateAwareAppBarTitle(
          title: Text(title),
          source: source,
        ),
        floating: true,
      ),
      filterEntries: filterEntries,
      filterBuilder: filterBuilder,
      emptyBuilder: () => ValueListenableBuilder<SourceState>(
        valueListenable: source.stateNotifier,
        builder: (context, sourceState, child) {
          return sourceState != SourceState.loading && emptyBuilder != null ? emptyBuilder() : SizedBox.shrink();
        },
      ),
      onPressed: (filter) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => CollectionPage(CollectionLens(
            source: source,
            filters: [filter],
            groupFactor: settings.collectionGroupFactor,
            sortFactor: settings.collectionSortFactor,
          )),
        ),
        (route) => false,
      ),
    );
  }
}

class FilterGridPage extends StatelessWidget {
  final CollectionSource source;
  final Widget appBar;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final Widget Function() emptyBuilder;
  final FilterCallback onPressed;

  const FilterGridPage({
    @required this.source,
    @required this.appBar,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.emptyBuilder,
    @required this.onPressed,
  });

  List<String> get filterKeys => filterEntries.keys.toList();

  static const Color detailColor = Color(0xFFE0E0E0);
  static const double maxCrossAxisExtent = 180;

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: SafeArea(
          child: Selector<MediaQueryData, double>(
            selector: (c, mq) => mq.size.width,
            builder: (c, mqWidth, child) {
              final columnCount = (mqWidth / maxCrossAxisExtent).ceil();
              return AnimationLimiter(
                child: CustomScrollView(
                  slivers: [
                    appBar,
                    filterKeys.isEmpty
                        ? SliverFillRemaining(
                            child: emptyBuilder(),
                            hasScrollBody: false,
                          )
                        : SliverPadding(
                            padding: EdgeInsets.all(AvesFilterChip.outlineWidth),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) {
                                  final key = filterKeys[i];
                                  final child = DecoratedFilterChip(
                                    source: source,
                                    filter: filterBuilder(key),
                                    entry: filterEntries[key],
                                    onPressed: onPressed,
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
                                childCount: filterKeys.length,
                              ),
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: maxCrossAxisExtent,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
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
                ),
              );
            },
          ),
        ),
        drawer: AppDrawer(
          source: source,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class DecoratedFilterChip extends StatelessWidget {
  final CollectionSource source;
  final CollectionFilter filter;
  final ImageEntry entry;
  final FilterCallback onPressed;

  const DecoratedFilterChip({
    @required this.source,
    @required this.filter,
    @required this.entry,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget backgroundImage;
    if (entry != null) {
      backgroundImage = entry.isSvg
          ? ThumbnailVectorImage(
              entry: entry,
              extent: FilterGridPage.maxCrossAxisExtent,
            )
          : ThumbnailRasterImage(
              entry: entry,
              extent: FilterGridPage.maxCrossAxisExtent,
            );
    }
    return AvesFilterChip(
      filter: filter,
      showGenericIcon: false,
      background: backgroundImage,
      details: _buildDetails(filter),
      onPressed: onPressed,
    );
  }

  Widget _buildDetails(CollectionFilter filter) {
    final count = Text(
      '${source.count(filter)}',
      style: TextStyle(color: FilterGridPage.detailColor),
    );
    return filter is AlbumFilter && androidFileUtils.isOnRemovableStorage(filter.album)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AIcons.removableStorage,
                size: 16,
                color: FilterGridPage.detailColor,
              ),
              SizedBox(width: 8),
              count,
            ],
          )
        : count;
  }
}
