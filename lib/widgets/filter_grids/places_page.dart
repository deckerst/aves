import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location/place.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/place_set.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class PlaceListPage extends StatelessWidget {
  static const routeName = '/places';

  const PlaceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return Selector<Settings, Tuple3<ChipSortFactor, bool, Set<CollectionFilter>>>(
      selector: (context, s) => Tuple3(s.placeSortFactor, s.placeSortReverse, s.pinnedFilters),
      shouldRebuild: (t1, t2) {
        // `Selector` by default uses `DeepCollectionEquality`, which does not go deep in collections within `TupleN`
        const eq = DeepCollectionEquality();
        return !(eq.equals(t1.item1, t2.item1) && eq.equals(t1.item2, t2.item2) && eq.equals(t1.item3, t2.item3));
      },
      builder: (context, s, child) {
        return StreamBuilder(
          stream: source.eventBus.on<PlacesChangedEvent>(),
          builder: (context, snapshot) {
            final gridItems = _getGridItems(source);
            return FilterNavigationPage<LocationFilter, PlaceChipSetActionDelegate>(
              source: source,
              title: context.l10n.placePageTitle,
              sortFactor: settings.placeSortFactor,
              actionDelegate: PlaceChipSetActionDelegate(gridItems),
              filterSections: _groupToSections(gridItems),
              applyQuery: applyQuery,
              emptyBuilder: () => EmptyContent(
                icon: AIcons.place,
                text: context.l10n.placeEmpty,
              ),
            );
          },
        );
      },
    );
  }

  List<FilterGridItem<LocationFilter>> applyQuery(BuildContext context, List<FilterGridItem<LocationFilter>> filters, String query) {
    return filters.where((item) => item.filter.getLabel(context).toUpperCase().contains(query)).toList();
  }

  List<FilterGridItem<LocationFilter>> _getGridItems(CollectionSource source) {
    final filters = source.sortedPlaces.map((location) => LocationFilter(LocationLevel.place, location)).toSet();

    return FilterNavigationPage.sort(settings.placeSortFactor, settings.placeSortReverse, source, filters);
  }

  static Map<ChipSectionKey, List<FilterGridItem<LocationFilter>>> _groupToSections(Iterable<FilterGridItem<LocationFilter>> sortedMapEntries) {
    final pinned = settings.pinnedFilters.whereType<LocationFilter>();
    final byPin = groupBy<FilterGridItem<LocationFilter>, bool>(sortedMapEntries, (e) => pinned.contains(e.filter));
    final pinnedMapEntries = (byPin[true] ?? []);
    final unpinnedMapEntries = (byPin[false] ?? []);

    return {
      if (pinnedMapEntries.isNotEmpty || unpinnedMapEntries.isNotEmpty)
        const ChipSectionKey(): [
          ...pinnedMapEntries,
          ...unpinnedMapEntries,
        ],
    };
  }
}
