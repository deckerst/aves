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
import 'package:material_ui/material_ui.dart';

class CountryChipSetActionDelegate extends ChipSetActionDelegate<LocationFilter> {
  final Iterable<FilterGridItem<LocationFilter>> _items;

  new(Iterable<FilterGridItem<LocationFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<LocationFilter>> get allItems => _items;

  @override
  String get settingsRouteKey => CountryListPage.routeName;

  @override
  SortFactor get sortFactor => settings.countrySortFactor;

  @override
  set sortFactor(SortFactor factor) => settings.countrySortFactor = factor;

  @override
  bool get sortReverse => settings.countrySortReverse;

  @override
  set sortReverse(bool value) => settings.countrySortReverse = value;

  @override
  bool isVisible(
    ChipSetAction action, {
    required AppMode appMode,
    required bool isSelecting,
    required int itemCount,
    required Set<LocationFilter> selectedFilters,
  }) {
    switch (action) {
      case .showCountryStates:
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
      case .showCountryStates:
        return selectedFilters.any((v) => GeoStates.stateCodesByCountryCode.containsKey(v.code));
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
      case .showCountryStates:
        _showStates(context);
        browse(context);
      default:
        break;
    }
    super.onActionSelected(context, action);
  }

  void _showStates(BuildContext context) {
    final filters = getSelectedFilters(context);
    final countryCodes = filters.map((v) => v.code).where(GeoStates.stateCodesByCountryCode.containsKey).nonNulls.toSet();
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: StateListPage.routeName),
        builder: (_) => StateListPage(countryCodes: countryCodes),
      ),
    );
  }
}
