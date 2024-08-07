import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/modules/search.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';

mixin PrivacySettings on SettingsAccess, SearchSettings {
  Set<CollectionFilter> get hiddenFilters => (getStringList(SettingKeys.hiddenFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set hiddenFilters(Set<CollectionFilter> newValue) => set(SettingKeys.hiddenFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  void changeFilterVisibility(Set<CollectionFilter> filters, bool visible) {
    final _deactivatedHiddenFilters = deactivatedHiddenFilters;
    final _hiddenFilters = hiddenFilters;

    _deactivatedHiddenFilters.removeAll(filters);
    if (visible) {
      _hiddenFilters.removeAll(filters);
    } else {
      _hiddenFilters.addAll(filters);
      searchHistory = searchHistory..removeWhere(filters.contains);
    }

    deactivatedHiddenFilters = _deactivatedHiddenFilters;
    hiddenFilters = _hiddenFilters;
  }

  Set<CollectionFilter> get deactivatedHiddenFilters => (getStringList(SettingKeys.deactivatedHiddenFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set deactivatedHiddenFilters(Set<CollectionFilter> newValue) => set(SettingKeys.deactivatedHiddenFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  void activateHiddenFilter(CollectionFilter filter, bool active) {
    final _deactivatedHiddenFilters = deactivatedHiddenFilters;
    final _hiddenFilters = hiddenFilters;

    if (active) {
      _deactivatedHiddenFilters.remove(filter);
      _hiddenFilters.add(filter);
      searchHistory = searchHistory..remove(filter);
    } else {
      _deactivatedHiddenFilters.add(filter);
      _hiddenFilters.remove(filter);
    }

    deactivatedHiddenFilters = _deactivatedHiddenFilters;
    hiddenFilters = _hiddenFilters;
  }
}
