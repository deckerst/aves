import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/modules/search.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';

mixin PrivacySettings on SettingsAccess, SearchSettings {
  Set<CollectionFilter> get hiddenFilters => (getStringList(SettingKeys.hiddenFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set hiddenFilters(Set<CollectionFilter> newValue) => set(SettingKeys.hiddenFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  void changeFilterVisibility(Set<CollectionFilter> filters, bool visible) {
    final _hiddenFilters = hiddenFilters;
    if (visible) {
      _hiddenFilters.removeAll(filters);
    } else {
      _hiddenFilters.addAll(filters);
      searchHistory = searchHistory..removeWhere(filters.contains);

      final _deactivatedHiddenFilters = deactivatedHiddenFilters;
      _deactivatedHiddenFilters.removeAll(filters);
      deactivatedHiddenFilters = _deactivatedHiddenFilters;
    }
    hiddenFilters = _hiddenFilters;
  }

  Set<CollectionFilter> get deactivatedHiddenFilters => (getStringList(SettingKeys.deactivatedHiddenFiltersKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set deactivatedHiddenFilters(Set<CollectionFilter> newValue) => set(SettingKeys.deactivatedHiddenFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  void activateHiddenFilter(CollectionFilter filter, bool active) {
    final _deactivatedHiddenFilters = deactivatedHiddenFilters;
    if (active) {
      _deactivatedHiddenFilters.remove(filter);
    } else {
      _deactivatedHiddenFilters.add(filter);
    }
    deactivatedHiddenFilters = _deactivatedHiddenFilters;

    final visible = !active;
    changeFilterVisibility({filter}, visible);
  }
}
