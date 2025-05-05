import 'package:aves/app_mode.dart';
import 'package:aves/geo/states.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/states_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class CountryChipSetActionDelegate extends ChipSetActionDelegate<LocationFilter> {
  final Iterable<FilterGridItem<LocationFilter>> _items;

  CountryChipSetActionDelegate(Iterable<FilterGridItem<LocationFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<LocationFilter>> get allItems => _items;

  @override
  ChipSortFactor get sortFactor => settings.countrySortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.countrySortFactor = factor;

  @override
  bool get sortReverse => settings.countrySortReverse;

  @override
  set sortReverse(bool value) => settings.countrySortReverse = value;

  @override
  TileLayout get tileLayout => settings.getTileLayout(CountryListPage.routeName);

  @override
  set tileLayout(TileLayout tileLayout) => settings.setTileLayout(CountryListPage.routeName, tileLayout);

  @override
  bool isVisible(
    ChipSetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required Set<LocationFilter> selectedFilters,
  }) {
    switch (action) {
      case ChipSetAction.showCountryStates:
        return isSelecting;
      default:
        return super.isVisible(
          action,
          appMode: appMode,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );
    }
  }

  @override
  bool canApply(
    ChipSetAction action, {
    required bool isSelecting,
    required int itemCount,
    required Set<LocationFilter> selectedFilters,
  }) {
    switch (action) {
      case ChipSetAction.showCountryStates:
        return selectedFilters.any((v) => GeoStates.stateCountryCodes.contains(v.code));
      default:
        return super.canApply(
          action,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );
    }
  }

  @override
  void onActionSelected(BuildContext context, ChipSetAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      // single/multiple filters
      case ChipSetAction.showCountryStates:
        _showStates(context);
        browse(context);
      default:
        break;
    }
    super.onActionSelected(context, action);
  }

  void _showStates(BuildContext context) {
    final filters = getSelectedFilters(context);
    final countryCodes = filters.map((v) => v.code).where(GeoStates.stateCountryCodes.contains).nonNulls.toSet();
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: StateListPage.routeName),
        builder: (_) => StateListPage(countryCodes: countryCodes),
      ),
    );
  }
}
