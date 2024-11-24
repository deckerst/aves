import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin FilterGridsSettings on SettingsAccess {
  AlbumChipGroupFactor get albumGroupFactor => getEnumOrDefault(SettingKeys.albumGroupFactorKey, SettingsDefaults.albumGroupFactor, AlbumChipGroupFactor.values);

  set albumGroupFactor(AlbumChipGroupFactor newValue) => set(SettingKeys.albumGroupFactorKey, newValue.toString());

  ChipSortFactor get albumSortFactor => getEnumOrDefault(SettingKeys.albumSortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set albumSortFactor(ChipSortFactor newValue) => set(SettingKeys.albumSortFactorKey, newValue.toString());

  ChipSortFactor get countrySortFactor => getEnumOrDefault(SettingKeys.countrySortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set countrySortFactor(ChipSortFactor newValue) => set(SettingKeys.countrySortFactorKey, newValue.toString());

  ChipSortFactor get stateSortFactor => getEnumOrDefault(SettingKeys.stateSortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set stateSortFactor(ChipSortFactor newValue) => set(SettingKeys.stateSortFactorKey, newValue.toString());

  ChipSortFactor get placeSortFactor => getEnumOrDefault(SettingKeys.placeSortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set placeSortFactor(ChipSortFactor newValue) => set(SettingKeys.placeSortFactorKey, newValue.toString());

  ChipSortFactor get tagSortFactor => getEnumOrDefault(SettingKeys.tagSortFactorKey, SettingsDefaults.chipListSortFactor, ChipSortFactor.values);

  set tagSortFactor(ChipSortFactor newValue) => set(SettingKeys.tagSortFactorKey, newValue.toString());

  bool get albumSortReverse => getBool(SettingKeys.albumSortReverseKey) ?? false;

  set albumSortReverse(bool newValue) => set(SettingKeys.albumSortReverseKey, newValue);

  bool get countrySortReverse => getBool(SettingKeys.countrySortReverseKey) ?? false;

  set countrySortReverse(bool newValue) => set(SettingKeys.countrySortReverseKey, newValue);

  bool get stateSortReverse => getBool(SettingKeys.stateSortReverseKey) ?? false;

  set stateSortReverse(bool newValue) => set(SettingKeys.stateSortReverseKey, newValue);

  bool get placeSortReverse => getBool(SettingKeys.placeSortReverseKey) ?? false;

  set placeSortReverse(bool newValue) => set(SettingKeys.placeSortReverseKey, newValue);

  bool get tagSortReverse => getBool(SettingKeys.tagSortReverseKey) ?? false;

  set tagSortReverse(bool newValue) => set(SettingKeys.tagSortReverseKey, newValue);

  Set<CollectionFilter> get pinnedFilters => (getStringList(SettingKeys.pinnedFiltersKey) ?? []).map(CollectionFilter.fromJson).nonNulls.toSet();

  set pinnedFilters(Set<CollectionFilter> newValue) => set(SettingKeys.pinnedFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  bool getShowTitleQuery(String routeName) => getBool(SettingKeys.showTitleQueryPrefixKey + routeName) ?? false;

  void setShowTitleQuery(String routeName, bool newValue) => set(SettingKeys.showTitleQueryPrefixKey + routeName, newValue);
}
