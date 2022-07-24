import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/intent_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/double_back_pop.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_fab.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves/widgets/navigation/nav_bar/nav_bar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionPage extends StatefulWidget {
  static const routeName = '/collection';

  final CollectionSource source;
  final Set<CollectionFilter?>? filters;
  final bool Function(AvesEntry element)? highlightTest;

  const CollectionPage({
    super.key,
    required this.source,
    required this.filters,
    this.highlightTest,
  });

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final List<StreamSubscription> _subscriptions = [];
  late CollectionLens _collection;
  final StreamController<DraggableScrollBarEvent> _draggableScrollBarEventStreamController = StreamController.broadcast();

  @override
  void initState() {
    // do not seed this widget with the collection, but control its lifecycle here instead,
    // as the collection properties may change and they should not be reset by a widget update (e.g. with theme change)
    _collection = CollectionLens(
      source: widget.source,
      filters: widget.filters,
    );
    super.initState();
    _subscriptions.add(settings.updateStream.where((event) => event.key == Settings.enableBinKey).listen((_) {
      if (!settings.enableBin) {
        _collection.removeFilter(TrashFilter.instance);
      }
    }));
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInitHighlight());
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _collection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveFilter = _collection.filters.firstWhereOrNull((v) => v is QueryFilter && v.live) as QueryFilter?;
    return MediaQueryDataProvider(
      child: SelectionProvider<AvesEntry>(
        child: Selector<Selection<AvesEntry>, bool>(
          selector: (context, selection) => selection.selectedItems.isNotEmpty,
          builder: (context, hasSelection, child) {
            return Selector<Settings, bool>(
              selector: (context, s) => s.enableBottomNavigationBar,
              builder: (context, enableBottomNavigationBar, child) {
                final canNavigate = context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canNavigate);
                final showBottomNavigationBar = canNavigate && enableBottomNavigationBar;
                return NotificationListener<DraggableScrollBarNotification>(
                  onNotification: (notification) {
                    _draggableScrollBarEventStreamController.add(notification.event);
                    return false;
                  },
                  child: Scaffold(
                    body: QueryProvider(
                      initialQuery: liveFilter?.query,
                      child: Builder(
                        builder: (context) => WillPopScope(
                          onWillPop: () {
                            final selection = context.read<Selection<AvesEntry>>();
                            if (selection.isSelecting) {
                              selection.browse();
                              return SynchronousFuture(false);
                            }
                            return SynchronousFuture(true);
                          },
                          child: DoubleBackPopScope(
                            child: GestureAreaProtectorStack(
                              child: SafeArea(
                                top: false,
                                bottom: false,
                                child: ChangeNotifierProvider<CollectionLens>.value(
                                  value: _collection,
                                  child: const CollectionGrid(
                                    // key is expected by test driver
                                    key: Key('collection-grid'),
                                    settingsRouteKey: CollectionPage.routeName,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    floatingActionButton: _buildFab(context, hasSelection),
                    drawer: AppDrawer(currentCollection: _collection),
                    bottomNavigationBar: showBottomNavigationBar
                        ? AppBottomNavBar(
                            events: _draggableScrollBarEventStreamController.stream,
                            currentCollection: _collection,
                          )
                        : null,
                    resizeToAvoidBottomInset: false,
                    extendBody: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget? _buildFab(BuildContext context, bool hasSelection) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    switch (appMode) {
      case AppMode.pickMultipleMediaExternal:
        return hasSelection
            ? AvesFab(
                tooltip: context.l10n.collectionPickPageTitle,
                onPressed: () {
                  final items = context.read<Selection<AvesEntry>>().selectedItems;
                  final uris = items.map((entry) => entry.uri).toList();
                  IntentService.submitPickedItems(uris);
                },
              )
            : null;
      case AppMode.pickCollectionFiltersExternal:
        return AvesFab(
          tooltip: context.l10n.collectionPickPageTitle,
          onPressed: () {
            final filters = _collection.filters;
            IntentService.submitPickedCollectionFilters(filters);
          },
        );
      case AppMode.main:
      case AppMode.pickSingleMediaExternal:
      case AppMode.pickMediaInternal:
      case AppMode.pickFilterInternal:
      case AppMode.screenSaver:
      case AppMode.setWallpaper:
      case AppMode.slideshow:
      case AppMode.view:
        return null;
    }
  }

  Future<void> _checkInitHighlight() async {
    final highlightTest = widget.highlightTest;
    if (highlightTest == null) return;

    final delayDuration = context.read<DurationsData>().staggeredAnimationPageTarget;
    await Future.delayed(delayDuration + Durations.highlightScrollInitDelay);
    final targetEntry = _collection.sortedEntries.firstWhereOrNull(highlightTest);
    if (targetEntry != null) {
      context.read<HighlightInfo>().trackItem(targetEntry, highlightItem: targetEntry);
    }
  }
}
