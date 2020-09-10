import 'package:aves/model/filters/location.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/filter_grid_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CountryListPage extends StatelessWidget {
  static const routeName = '/countries';

  final CollectionSource source;

  const CountryListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, ChipSortFactor>(
      selector: (context, s) => s.countrySortFactor,
      builder: (context, sortFactor, child) {
        return StreamBuilder(
          stream: source.eventBus.on<LocationsChangedEvent>(),
          builder: (context, snapshot) => FilterNavigationPage(
            source: source,
            title: 'Countries',
            onChipActionSelected: _onChipActionSelected,
            filterEntries: _getCountryEntries(),
            filterBuilder: (s) => LocationFilter(LocationLevel.country, s),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.location,
              text: 'No countries',
            ),
          ),
        );
      },
    );
  }

  void _onChipActionSelected(BuildContext context, ChipAction action) async {
    switch (action) {
      case ChipAction.sort:
        final factor = await showDialog<ChipSortFactor>(
          context: context,
          builder: (context) => AvesSelectionDialog<ChipSortFactor>(
            initialValue: settings.countrySortFactor,
            options: {
              ChipSortFactor.date: 'By date',
              ChipSortFactor.name: 'By name',
            },
            title: 'Sort',
          ),
        );
        if (factor != null) {
          settings.countrySortFactor = factor;
        }
        break;
    }
  }

  Map<String, ImageEntry> _getCountryEntries() {
    final entriesByDate = source.sortedEntriesForFilterList;
    final locatedEntries = entriesByDate.where((entry) => entry.isLocated);
    final countries = source.sortedCountries.map((countryNameAndCode) {
      final split = countryNameAndCode.split(LocationFilter.locationSeparator);
      ImageEntry entry;
      if (split.length > 1) {
        final countryCode = split[1];
        entry = locatedEntries.firstWhere((entry) => entry.addressDetails.countryCode == countryCode, orElse: () => null);
      }
      return MapEntry(countryNameAndCode, entry);
    }).toList();

    switch (settings.countrySortFactor) {
      case ChipSortFactor.date:
        countries.sort(FilterNavigationPage.compareChipByDate);
        break;
      case ChipSortFactor.name:
    }
    return Map.fromEntries(countries);
  }
}
