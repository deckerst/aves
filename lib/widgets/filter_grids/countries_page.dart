import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location/country.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/country_set.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CountryListPage extends StatelessWidget {
  static const routeName = '/countries';

  const CountryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return Selector<Settings, (ChipSortFactor, bool, Set<CollectionFilter>)>(
      selector: (context, s) => (s.countrySortFactor, s.countrySortReverse, s.pinnedFilters),
      shouldRebuild: (t1, t2) {
        // `Selector` by default uses `DeepCollectionEquality`, which does not go deep in collections within records
        const eq = DeepCollectionEquality();
        return !(eq.equals(t1.$1, t2.$1) && eq.equals(t1.$2, t2.$2) && eq.equals(t1.$3, t2.$3));
      },
      builder: (context, s, child) {
        return StreamBuilder(
          stream: source.eventBus.on<CountriesChangedEvent>(),
          builder: (context, snapshot) {
            final gridItems = _getGridItems(source);
            return FilterNavigationPage<LocationFilter, CountryChipSetActionDelegate>(
              source: source,
              title: context.l10n.countryPageTitle,
              sortFactor: settings.countrySortFactor,
              actionDelegate: CountryChipSetActionDelegate(gridItems),
              filterSections: _groupToSections(gridItems),
              emptyBuilder: () => EmptyContent(
                icon: AIcons.country,
                text: context.l10n.countryEmpty,
              ),
            );
          },
        );
      },
    );
  }

  List<FilterGridItem<LocationFilter>> _getGridItems(CollectionSource source) {
    final filters = source.sortedCountries.map((location) => LocationFilter(LocationLevel.country, location)).toSet();

    return FilterNavigationPage.sort(settings.countrySortFactor, settings.countrySortReverse, source, filters);
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
