import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/collection_drawer.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagsPage extends StatelessWidget {
  final CollectionSource source;
  final Map<String, ImageEntry> tagEntries;

  TagsPage({
    @required this.source,
  }) : tagEntries = source.getTagEntries();

  List<String> get tags => source.sortedTags;

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                title: Text('Tags'),
                floating: true,
              ),
              SliverPadding(
                padding: EdgeInsets.all(AvesFilterChip.buttonBorderWidth),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final tag = tags[i];
                      final entry = tagEntries[tag];
                      Decoration decoration;
                      if (entry != null && !entry.isSvg) {
                        decoration = BoxDecoration(
                          image: DecorationImage(
                            image: ThumbnailProvider(
                              entry: entry,
                              extent: Constants.thumbnailCacheExtent,
                            ),
                            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.dstATop),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: AvesFilterChip.borderRadius,
                        );
                      }
                      return AvesFilterChip(
                        filter: TagFilter(tag),
                        showLeading: false,
                        decoration: decoration,
                        onPressed: (filter) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollectionPage(CollectionLens(
                              source: source,
                              filters: [filter],
                              groupFactor: settings.collectionGroupFactor,
                              sortFactor: settings.collectionSortFactor,
                            )),
                          ),
                        ),
                      );
                    },
                    childCount: tags.length,
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
        drawer: CollectionDrawer(
          source: source,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
