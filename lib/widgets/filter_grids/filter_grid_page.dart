import 'dart:ui';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/collection/search/search_delegate.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/double_back_pop.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:aves/widgets/filter_grids/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/chip_actions.dart';
import 'package:aves/widgets/filter_grids/decorated_filter_chip.dart';
import 'package:aves/widgets/filter_grids/search_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class FilterNavigationPage extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final ChipActionDelegate actionDelegate;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final Widget Function() emptyBuilder;
  final OffsetFilterCallback onLongPress;

  const FilterNavigationPage({
    @required this.source,
    @required this.title,
    @required this.actionDelegate,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.emptyBuilder,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return FilterGridPage(
      source: source,
      appBar: SliverAppBar(
        title: TappableAppBarTitle(
          onTap: () => _goToSearch(context),
          child: SourceStateAwareAppBarTitle(
            title: Text(title),
            source: source,
          ),
        ),
        actions: _buildActions(context),
        titleSpacing: 0,
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
      onTap: (filter) => Navigator.pushAndRemoveUntil(
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
      onLongPress: onLongPress,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      SearchButton(source),
      PopupMenuButton<ChipAction>(
        key: Key('appbar-menu-button'),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              key: Key('menu-sort'),
              value: ChipAction.sort,
              child: MenuRow(text: 'Sort...', icon: AIcons.sort),
            ),
          ];
        },
        onSelected: (action) => actionDelegate.onChipActionSelected(context, action),
      ),
    ];
  }

  void _goToSearch(BuildContext context) {
    Navigator.push(
        context,
        SearchPageRoute(
          delegate: ImageSearchDelegate(
            source: source,
          ),
        ));
  }

  static int compareChipByDate(MapEntry<String, ImageEntry> a, MapEntry<String, ImageEntry> b) {
    final c = b.value.bestDate?.compareTo(a.value.bestDate) ?? -1;
    return c != 0 ? c : compareAsciiUpperCase(a.key, b.key);
  }
}

class FilterGridPage extends StatelessWidget {
  final CollectionSource source;
  final Widget appBar;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final Widget Function() emptyBuilder;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  const FilterGridPage({
    @required this.source,
    @required this.appBar,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.emptyBuilder,
    @required this.onTap,
    this.onLongPress,
  });

  List<String> get filterKeys => filterEntries.keys.toList();

  static const Color detailColor = Color(0xFFE0E0E0);
  static const double maxCrossAxisExtent = 180;

  @override
  Widget build(BuildContext context) {
    final pinnedFilters = settings.pinnedFilters;
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
                                    final filter = filterBuilder(key);
                                    final child = DecoratedFilterChip(
                                      key: Key(key),
                                      source: source,
                                      filter: filter,
                                      entry: filterEntries[key],
                                      pinned: pinnedFilters.contains(filter),
                                      onTap: onTap,
                                      onLongPress: onLongPress,
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
