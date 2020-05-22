import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/app_drawer.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterGridPage extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final bool showFilterIcon;

  const FilterGridPage({
    @required this.source,
    @required this.title,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.showFilterIcon,
  });

  List<String> get filterKeys => filterEntries.keys.toList();

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(title),
                floating: true,
              ),
              SliverPadding(
                padding: EdgeInsets.all(AvesFilterChip.buttonBorderWidth),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final key = filterKeys[i];
                      final entry = filterEntries[key];
                      Decoration decoration;
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
                      return AvesFilterChip(
                        filter: filterBuilder(key),
                        showLeading: showFilterIcon,
                        decoration: decoration,
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
}
