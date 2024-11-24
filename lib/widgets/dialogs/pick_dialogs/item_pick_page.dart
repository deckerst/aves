import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemPickPage extends StatefulWidget {
  static const routeName = '/item_pick';

  final CollectionLens collection;
  final bool canRemoveFilters;

  const ItemPickPage({
    super.key,
    required this.collection,
    required this.canRemoveFilters,
  });

  @override
  State<ItemPickPage> createState() => _ItemPickPageState();
}

class _ItemPickPageState extends State<ItemPickPage> {
  final ValueNotifier<AppMode> _appModeNotifier = ValueNotifier(AppMode.initialization);

  CollectionLens get collection => widget.collection;

  @override
  void dispose() {
    collection.dispose();
    _appModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveFilter = collection.filters.firstWhereOrNull((v) => v is QueryFilter && v.live) as QueryFilter?;
    _appModeNotifier.value = widget.canRemoveFilters ? AppMode.pickUnfilteredMediaInternal : AppMode.pickFilteredMediaInternal;
    return ListenableProvider<ValueNotifier<AppMode>>.value(
      value: _appModeNotifier,
      child: AvesScaffold(
        body: SelectionProvider<AvesEntry>(
          child: QueryProvider(
            startEnabled: settings.getShowTitleQuery(context.currentRouteName!),
            initialQuery: liveFilter?.query,
            child: GestureAreaProtectorStack(
              child: SafeArea(
                top: false,
                bottom: false,
                child: ChangeNotifierProvider<CollectionLens>.value(
                  value: collection,
                  child: const CollectionGrid(
                    settingsRouteKey: CollectionPage.routeName,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
