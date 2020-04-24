import 'dart:async';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/album/filter_bar.dart';
import 'package:aves/widgets/album/search/search_delegate.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/stats/stats.dart';
import 'package:collection/collection.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:pedantic/pedantic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CollectionAppBar extends StatefulWidget {
  final ValueNotifier<double> appBarHeightNotifier;
  final CollectionLens collection;

  const CollectionAppBar({
    Key key,
    @required this.appBarHeightNotifier,
    @required this.collection,
  }) : super(key: key);

  @override
  _CollectionAppBarState createState() => _CollectionAppBarState();
}

class _CollectionAppBarState extends State<CollectionAppBar> with SingleTickerProviderStateMixin {
  final TextEditingController _searchFieldController = TextEditingController();

  AnimationController _browseToSelectAnimation;

  CollectionLens get collection => widget.collection;

  bool get hasFilters => collection.filters.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _browseToSelectAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  @override
  void didUpdateWidget(CollectionAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _browseToSelectAnimation.dispose();
    super.dispose();
  }

  void _registerWidget(CollectionAppBar widget) {
    widget.collection.activityNotifier.addListener(_onActivityChange);
    widget.collection.filterChangeNotifier.addListener(_updateHeight);
  }

  void _unregisterWidget(CollectionAppBar widget) {
    widget.collection.activityNotifier.removeListener(_onActivityChange);
    widget.collection.filterChangeNotifier.removeListener(_updateHeight);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Activity>(
      valueListenable: collection.activityNotifier,
      builder: (context, activity, child) {
        return AnimatedBuilder(
          animation: collection.filterChangeNotifier,
          builder: (context, child) => SliverAppBar(
            titleSpacing: 0,
            leading: _buildAppBarLeading(),
            title: _buildAppBarTitle(),
            actions: _buildActions(),
            bottom: hasFilters ? FilterBar() : null,
            floating: true,
          ),
        );
      },
    );
  }

  Widget _buildAppBarLeading() {
    VoidCallback onPressed;
    String tooltip;
    if (collection.isBrowsing) {
      onPressed = Scaffold.of(context).openDrawer;
      tooltip = MaterialLocalizations.of(context).openAppDrawerTooltip;
    } else if (collection.isSelecting) {
      onPressed = () {
        collection.clearSelection();
        collection.browse();
      };
      tooltip = MaterialLocalizations.of(context).backButtonTooltip;
    }
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: _browseToSelectAnimation,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildAppBarTitle() {
    if (collection.isBrowsing) {
      return GestureDetector(
        onTap: _goToSearch,
        // use a `Container` with a dummy color to make it expand
        // so that we can also detect taps around the title `Text`
        child: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.symmetric(horizontal: NavigationToolbar.kMiddleSpacing),
          color: Colors.transparent,
          height: kToolbarHeight,
          child: const Text('Aves'),
        ),
      );
    } else if (collection.isSelecting) {
      return AnimatedBuilder(
        animation: collection.selectionChangeNotifier,
        builder: (context, child) {
          final count = collection.selection.length;
          return Text(Intl.plural(count, zero: 'Select items', one: '${count} item', other: '${count} items'));
        },
      );
    }
    return null;
  }

  List<Widget> _buildActions() {
    return [
      if (collection.isBrowsing)
        IconButton(
          icon: const Icon(OMIcons.search),
          onPressed: _goToSearch,
        ),
      if (collection.isSelecting)
        ...EntryActions.selection.map((action) => AnimatedBuilder(
              animation: collection.selectionChangeNotifier,
              builder: (context, child) {
                return IconButton(
                  icon: Icon(action.getIcon()),
                  onPressed: collection.selection.isEmpty ? null : () => _onSelectionActionSelected(action),
                  tooltip: action.getText(),
                );
              },
            )),
      Builder(
        builder: (context) => PopupMenuButton<CollectionAction>(
          itemBuilder: (context) => [
            ..._buildSortMenuItems(),
            ..._buildGroupMenuItems(),
            if (collection.isBrowsing) ...[
              const PopupMenuItem(
                value: CollectionAction.select,
                child: MenuRow(text: 'Select', icon: OMIcons.selectAll),
              ),
              const PopupMenuItem(
                value: CollectionAction.stats,
                child: MenuRow(text: 'Stats', icon: OMIcons.pieChart),
              ),
            ],
          ],
          onSelected: _onCollectionActionSelected,
        ),
      ),
    ];
  }

  List<PopupMenuEntry<CollectionAction>> _buildSortMenuItems() {
    return [
      PopupMenuItem(
        value: CollectionAction.sortByDate,
        child: MenuRow(text: 'Sort by date', checked: collection.sortFactor == SortFactor.date),
      ),
      PopupMenuItem(
        value: CollectionAction.sortBySize,
        child: MenuRow(text: 'Sort by size', checked: collection.sortFactor == SortFactor.size),
      ),
      PopupMenuItem(
        value: CollectionAction.sortByName,
        child: MenuRow(text: 'Sort by name', checked: collection.sortFactor == SortFactor.name),
      ),
      const PopupMenuDivider(),
    ];
  }

  List<PopupMenuEntry<CollectionAction>> _buildGroupMenuItems() {
    return collection.sortFactor == SortFactor.date
        ? [
            PopupMenuItem(
              value: CollectionAction.groupByAlbum,
              child: MenuRow(text: 'Group by album', checked: collection.groupFactor == GroupFactor.album),
            ),
            PopupMenuItem(
              value: CollectionAction.groupByMonth,
              child: MenuRow(text: 'Group by month', checked: collection.groupFactor == GroupFactor.month),
            ),
            PopupMenuItem(
              value: CollectionAction.groupByDay,
              child: MenuRow(text: 'Group by day', checked: collection.groupFactor == GroupFactor.day),
            ),
            const PopupMenuDivider(),
          ]
        : [];
  }

  void _onActivityChange() {
    if (collection.isSelecting) {
      _browseToSelectAnimation.forward();
    } else {
      _browseToSelectAnimation.reverse();
      _searchFieldController.clear();
    }
  }

  void _updateHeight() {
    widget.appBarHeightNotifier.value = kToolbarHeight + (hasFilters ? FilterBar.preferredHeight : 0);
  }

  void _onCollectionActionSelected(CollectionAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(Constants.popupMenuTransitionDuration);
    switch (action) {
      case CollectionAction.select:
        collection.select();
        break;
      case CollectionAction.stats:
        unawaited(_goToStats());
        break;
      case CollectionAction.groupByAlbum:
        settings.collectionGroupFactor = GroupFactor.album;
        collection.group(GroupFactor.album);
        break;
      case CollectionAction.groupByMonth:
        settings.collectionGroupFactor = GroupFactor.month;
        collection.group(GroupFactor.month);
        break;
      case CollectionAction.groupByDay:
        settings.collectionGroupFactor = GroupFactor.day;
        collection.group(GroupFactor.day);
        break;
      case CollectionAction.sortByDate:
        settings.collectionSortFactor = SortFactor.date;
        collection.sort(SortFactor.date);
        break;
      case CollectionAction.sortBySize:
        settings.collectionSortFactor = SortFactor.size;
        collection.sort(SortFactor.size);
        break;
      case CollectionAction.sortByName:
        settings.collectionSortFactor = SortFactor.name;
        collection.sort(SortFactor.name);
        break;
    }
  }

  Future<void> _goToSearch() async {
    final filter = await showSearch(
      context: context,
      delegate: ImageSearchDelegate(collection),
    );
    collection.addFilter(filter);
  }

  Future<void> _goToStats() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsPage(
          collection: collection,
        ),
      ),
    );
  }

  void _onSelectionActionSelected(EntryAction action) {
    switch (action) {
      case EntryAction.share:
        _shareSelection();
        break;
      case EntryAction.delete:
        _deleteSelection();
        break;
      default:
        break;
    }
  }

  void _shareSelection() {
    final urisByMimeType = groupBy<ImageEntry, String>(collection.selection, (e) => e.mimeType).map((k, v) => MapEntry(k, v.map((e) => e.uri).toList()));
    AndroidAppService.share(urisByMimeType);
  }

  void _deleteSelection() {
    final selection = collection.selection.toList();
    _showOpReport(
      selection: selection,
      opStream: ImageFileService.delete(selection),
      onDone: (processed) {
        final deletedUris = processed.where((e) => e.success).map((e) => e.uri);
        final deletedCount = deletedUris.length;
        final selectionCount = selection.length;
        if (deletedCount < selectionCount) {
          _showFeedback(context, 'Failed to delete ${selectionCount - deletedCount} items');
        }
        if (deletedCount > 0) {
          collection.source.removeEntries(selection.where((e) => deletedUris.contains(e.uri)));
        }
        collection.browse();
      },
    );
  }

  // selection action report overlay

  OverlayEntry _opReportOverlayEntry;

  static const _overlayAnimationDuration = Duration(milliseconds: 300);

  void _showOpReport({
    @required List<ImageEntry> selection,
    @required Stream<ImageOpEvent> opStream,
    @required void Function(Set<ImageOpEvent> processed) onDone,
  }) {
    final processed = <ImageOpEvent>{};
    _opReportOverlayEntry = OverlayEntry(
      builder: (context) {
        return StreamBuilder<ImageOpEvent>(
            stream: opStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                processed.add(snapshot.data);
              }

              Widget child = const SizedBox.shrink();
              if (snapshot.hasError || snapshot.connectionState == ConnectionState.done) {
                _hideOpReportOverlay().then((_) => onDone(processed));
              } else if (snapshot.connectionState == ConnectionState.active) {
                final percent = processed.length.toDouble() / selection.length;
                child = CircularPercentIndicator(
                  percent: percent,
                  lineWidth: 16,
                  radius: 160,
                  backgroundColor: Colors.white24,
                  progressColor: Theme.of(context).accentColor,
                  animation: true,
                  center: Text(NumberFormat.percentPattern().format(percent)),
                  animateFromLastPercent: true,
                );
              }
              return AnimatedSwitcher(
                duration: _overlayAnimationDuration,
                child: child,
              );
            });
      },
    );
    Overlay.of(context).insert(_opReportOverlayEntry);
  }

  Future<void> _hideOpReportOverlay() async {
    await Future.delayed(_overlayAnimationDuration);
    _opReportOverlayEntry.remove();
    _opReportOverlayEntry = null;
  }

  void _showFeedback(BuildContext context, String message) {
    Flushbar(
      message: message,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      borderColor: Colors.white30,
      borderWidth: 0.5,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 600),
    ).show(context);
  }
}

enum CollectionAction { select, stats, groupByAlbum, groupByMonth, groupByDay, sortByDate, sortBySize, sortByName }
