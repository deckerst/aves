import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CountryListPage extends StatelessWidget {
  static const routeName = '/countries';

  final CollectionSource source;

  const CountryListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, Tuple2<ChipSortFactor, Set<CollectionFilter>>>(
      selector: (context, s) => Tuple2(s.countrySortFactor, s.pinnedFilters),
      builder: (context, s, child) {
        return StreamBuilder(
          stream: source.eventBus.on<LocationsChangedEvent>(),
          builder: (context, snapshot) => FilterNavigationPage(
            source: source,
            title: 'Countries',
            chipSetActionDelegate: CountryChipSetActionDelegate(source: source),
            chipActionDelegate: ChipActionDelegate(),
            chipActionsBuilder: (filter) => [
              settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
            ],
            filterEntries: _getCountryEntries(),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.location,
              text: 'No countries',
            ),
          ),
        );
      },
    );
  }

  Map<LocationFilter, ImageEntry> _getCountryEntries() {
    final pinned = settings.pinnedFilters.whereType<LocationFilter>();

    final entriesByDate = source.sortedEntriesForFilterList;
    // countries are initially sorted by name at the source level
    var sortedFilters = source.sortedCountries.map((location) => LocationFilter(LocationLevel.country, location));
    if (settings.countrySortFactor == ChipSortFactor.count) {
      final filtersWithCount = List.of(sortedFilters.map((filter) => MapEntry(filter, source.count(filter))));
      filtersWithCount.sort(FilterNavigationPage.compareChipsByEntryCount);
      sortedFilters = filtersWithCount.map((kv) => kv.key).toList();
    }

    final locatedEntries = entriesByDate.where((entry) => entry.isLocated);
    final allMapEntries = sortedFilters.map((filter) {
      final split = filter.countryNameAndCode.split(LocationFilter.locationSeparator);
      ImageEntry entry;
      if (split.length > 1) {
        final countryCode = split[1];
        entry = locatedEntries.firstWhere((entry) => entry.addressDetails.countryCode == countryCode, orElse: () => null);
      }
      return MapEntry(filter, entry);
    });
    final byPin = groupBy<MapEntry<LocationFilter, ImageEntry>, bool>(allMapEntries, (e) => pinned.contains(e.key));
    final pinnedMapEntries = (byPin[true] ?? []);
    final unpinnedMapEntries = (byPin[false] ?? []);

    if (settings.countrySortFactor == ChipSortFactor.date) {
      pinnedMapEntries.sort(FilterNavigationPage.compareChipsByDate);
      unpinnedMapEntries.sort(FilterNavigationPage.compareChipsByDate);
    }

    return Map.fromEntries([...pinnedMapEntries, ...unpinnedMapEntries]);
  }
}
