import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CountryListPage extends StatelessWidget {
  static const routeName = '/countries';

  const CountryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return Selector<Settings, Tuple2<ChipSortFactor, Set<CollectionFilter>>>(
      selector: (context, s) => Tuple2(s.countrySortFactor, s.pinnedFilters),
      shouldRebuild: (t1, t2) {
        // `Selector` by default uses `DeepCollectionEquality`, which does not go deep in collections within `TupleN`
        const eq = DeepCollectionEquality();
        return !(eq.equals(t1.item1, t2.item1) && eq.equals(t1.item2, t2.item2));
      },
      builder: (context, s, child) {
        return StreamBuilder(
          stream: source.eventBus.on<CountriesChangedEvent>(),
          builder: (context, snapshot) => FilterNavigationPage<LocationFilter>(
            source: source,
            title: context.l10n.countryPageTitle,
            sortFactor: settings.countrySortFactor,
            chipSetActionDelegate: CountryChipSetActionDelegate(),
            chipActionDelegate: ChipActionDelegate(),
            chipActionsBuilder: (filter) => [
              settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
              ChipAction.setCover,
              ChipAction.hide,
            ],
            filterSections: _getCountryEntries(source),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.location,
              text: context.l10n.countryEmpty,
            ),
          ),
        );
      },
    );
  }

  Map<ChipSectionKey, List<FilterGridItem<LocationFilter>>> _getCountryEntries(CollectionSource source) {
    final filters = source.sortedCountries.map((location) => LocationFilter(LocationLevel.country, location)).toSet();

    final sorted = FilterNavigationPage.sort(settings.countrySortFactor, source, filters);
    return _group(sorted);
  }

  static Map<ChipSectionKey, List<FilterGridItem<LocationFilter>>> _group(Iterable<FilterGridItem<LocationFilter>> sortedMapEntries) {
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
