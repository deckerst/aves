import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/app_drawer.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterNavigationPage extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;

  const FilterNavigationPage({
    @required this.source,
    @required this.title,
    @required this.filterEntries,
    @required this.filterBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FilterGridPage(
      source: source,
      appBar: SliverAppBar(
        title: Text(title),
        floating: true,
      ),
      filterEntries: filterEntries,
      filterBuilder: filterBuilder,
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
  final FilterCallback onPressed;

  const FilterGridPage({
    @required this.source,
    @required this.appBar,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.onPressed,
  });

  List<String> get filterKeys => filterEntries.keys.toList();

  static const Color detailColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              appBar,
              SliverPadding(
                padding: const EdgeInsets.all(AvesFilterChip.buttonBorderWidth),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final key = filterKeys[i];
                      final entry = filterEntries[key];
                      Decoration decoration;
                      // TODO TLAD add decoration for SVG
                      if (entry != null && !entry.isSvg) {
                        decoration = BoxDecoration(
                          image: DecorationImage(
                            image: ThumbnailProvider(
                              entry: entry,
                              extent: Constants.thumbnailCacheExtent,
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: AvesFilterChip.borderRadius,
                        );
                      }
                      final filter = filterBuilder(key);
                      return AvesFilterChip(
                        filter: filter,
                        showGenericIcon: false,
                        decoration: decoration,
                        details: _buildDetails(filter),
                        onPressed: onPressed,
                      );
                    },
                    childCount: filterKeys.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
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
        ),
        drawer: AppDrawer(
          source: source,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget _buildDetails(CollectionFilter filter) {
    final count = Text(
      '${source.count(filter)}',
      style: const TextStyle(color: FilterGridPage.detailColor),
    );
    return filter is AlbumFilter && androidFileUtils.isOnRemovableStorage(filter.album)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AIcons.removableStorage,
                size: 16,
                color: FilterGridPage.detailColor,
              ),
              const SizedBox(width: 8),
              count,
            ],
          )
        : count;
  }
}
