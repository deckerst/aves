import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/double_back_pop.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
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
    Key? key,
    required this.source,
    required this.filters,
    this.highlightTest,
  }) : super(key: key);

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final List<StreamSubscription> _subscriptions = [];
  late CollectionLens _collection;

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
    WidgetsBinding.instance!.addPostFrameCallback((_) => _checkInitHighlight());
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
      child: Scaffold(
        body: SelectionProvider<AvesEntry>(
          child: QueryProvider(
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
        ),
        drawer: AppDrawer(currentCollection: _collection),
        resizeToAvoidBottomInset: false,
      ),
    );
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
