import 'dart:ui';

import 'package:aves/main.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar_title.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/double_back_pop.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/common/scroll_thumb.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/decorated_filter_chip.dart';
import 'package:aves/widgets/search/search_button.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:collection/collection.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class FilterNavigationPage extends StatelessWidget {
  final CollectionSource source;
  final String title;
  final ChipSetActionDelegate chipSetActionDelegate;
  final ChipActionDelegate chipActionDelegate;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final Widget Function() emptyBuilder;
  final List<ChipAction> Function(CollectionFilter filter) chipActionsBuilder;

  const FilterNavigationPage({
    @required this.source,
    @required this.title,
    @required this.chipSetActionDelegate,
    @required this.chipActionDelegate,
    @required this.chipActionsBuilder,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.emptyBuilder,
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
      onTap: (filter) => Navigator.push(
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
      ),
      onLongPress: AvesApp.mode == AppMode.main ? (filter, tapPosition) => _showMenu(context, filter, tapPosition) : null,
    );
  }

  Future<void> _showMenu(BuildContext context, CollectionFilter filter, Offset tapPosition) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final touchArea = Size(40, 40);
    final selectedAction = await showMenu<ChipAction>(
      context: context,
      position: RelativeRect.fromRect(tapPosition & touchArea, Offset.zero & overlay.size),
      items: chipActionsBuilder(filter)
          .map((action) => PopupMenuItem(
                value: action,
                child: MenuRow(text: action.getText(), icon: action.getIcon()),
              ))
          .toList(),
    );
    if (selectedAction != null) {
      // wait for the popup menu to hide before proceeding with the action
      Future.delayed(Durations.popupMenuAnimation * timeDilation, () => chipActionDelegate.onActionSelected(context, filter, selectedAction));
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      SearchButton(source),
      PopupMenuButton<ChipSetAction>(
        key: Key('appbar-menu-button'),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              key: Key('menu-sort'),
              value: ChipSetAction.sort,
              child: MenuRow(text: 'Sort…', icon: AIcons.sort),
            ),
            if (kDebugMode)
              PopupMenuItem(
                value: ChipSetAction.refresh,
                child: MenuRow(text: 'Refresh', icon: AIcons.refresh),
              ),
            PopupMenuItem(
              value: ChipSetAction.stats,
              child: MenuRow(text: 'Stats', icon: AIcons.stats),
            ),
          ];
        },
        onSelected: (action) {
          // wait for the popup menu to hide before proceeding with the action
          Future.delayed(Durations.popupMenuAnimation * timeDilation, () => chipSetActionDelegate.onActionSelected(context, action));
        },
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

  static int compareChipsByDate(MapEntry<String, ImageEntry> a, MapEntry<String, ImageEntry> b) {
    final c = b.value.bestDate?.compareTo(a.value.bestDate) ?? -1;
    return c != 0 ? c : compareAsciiUpperCase(a.key, b.key);
  }

  static int compareChipsByEntryCount(MapEntry<String, num> a, MapEntry<String, num> b) {
    final c = b.value.compareTo(a.value) ?? -1;
    return c != 0 ? c : compareAsciiUpperCase(a.key, b.key);
  }
}

class FilterGridPage extends StatelessWidget {
  final CollectionSource source;
  final Widget appBar;
  final Map<String, ImageEntry> filterEntries;
  final CollectionFilter Function(String key) filterBuilder;
  final Widget Function() emptyBuilder;
  final double appBarHeight;
  final FilterCallback onTap;
  final OffsetFilterCallback onLongPress;

  const FilterGridPage({
    @required this.source,
    @required this.appBar,
    @required this.filterEntries,
    @required this.filterBuilder,
    @required this.emptyBuilder,
    this.appBarHeight = kToolbarHeight,
    @required this.onTap,
    this.onLongPress,
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
                final scrollView = _buildScrollView(context, columnCount);
                return AnimationLimiter(
                  child: _buildDraggableScrollView(scrollView),
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

  Widget _buildDraggableScrollView(ScrollView scrollView) {
    return Selector<MediaQueryData, double>(
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
    );
  }

  ScrollView _buildScrollView(BuildContext context, int columnCount) {
    final pinnedFilters = settings.pinnedFilters;
    return CustomScrollView(
      controller: PrimaryScrollController.of(context),
      slivers: [
        appBar,
        filterKeys.isEmpty
            ? SliverFillRemaining(
                child: Selector<MediaQueryData, double>(
                  selector: (context, mq) => mq.viewInsets.bottom,
                  builder: (context, mqViewInsetsBottom, child) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: mqViewInsetsBottom),
                      child: emptyBuilder(),
                    );
                  },
                ),
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
    );
  }
}
