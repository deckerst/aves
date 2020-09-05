import 'dart:ui';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/double_back_pop.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:aves/widgets/filter_grids/decorated_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class FilterNavigationPage extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final List<Widget> actions;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final Widget Function() emptyBuilder;

  const FilterNavigationPage({
    @required this.source,
    @required this.title,
    this.actions,
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
        actions: actions,
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
          settings: RouteSettings(name: CollectionPage.routeName),
          builder: (context) => CollectionPage(CollectionLens(
            source: source,
            filters: [filter],
            groupFactor: settings.collectionGroupFactor,
            sortFactor: settings.collectionSortFactor,
          )),
        ),
        settings.navRemoveRoutePredicate(CollectionPage.routeName),
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
        body: DoubleBackPopScope(
          child: SafeArea(
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
        ),
        drawer: AppDrawer(
          source: source,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

enum ChipAction {
  sort,
}
