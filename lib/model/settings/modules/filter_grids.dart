import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:synchronized/synchronized.dart';

mixin FilterGridsSettings on SettingsAccess {
  AlbumChipSectionFactor get albumSectionFactor => getEnumOrDefault(SettingKeys.albumSectionFactorKey, SettingsDefaults.albumGroupFactor, AlbumChipSectionFactor.values);

  set albumSectionFactor(AlbumChipSectionFactor newValue) => set(SettingKeys.albumSectionFactorKey, newValue.toString());

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

  Map<Uri, Set<Uri>> get albumGroups => FilterGrouping.fromJson(getString(SettingKeys.albumGroupsKey)) ?? {};

  set albumGroups(Map<Uri, Set<Uri>> groups) => set(SettingKeys.albumGroupsKey, FilterGrouping.toJson(groups));

  // listening

  final _lockForPins = Lock();

  Future<void> updatePinnedDynamicAlbums(Map<DynamicAlbumFilter, DynamicAlbumFilter?> changes) async {
    await _lockForPins.synchronized(() async {
      final _pinnedFilters = pinnedFilters;
      bool changed = false;
      changes.forEach((oldFilter, newFilter) {
        if (newFilter != null) {
          changed |= _pinnedFilters.replace(oldFilter, newFilter);
        } else {
          changed |= _pinnedFilters.remove(oldFilter);
        }
      });
      if (changed) {
        pinnedFilters = _pinnedFilters;
      }
    });
  }

  Future<void> updatePinnedGroup(Uri oldGroupUri, Uri newGroupUri) async {
    await _lockForPins.synchronized(() async {
      final _pinnedFilters = pinnedFilters;
      bool changed = false;
      final grouping = FilterGrouping.forUri(oldGroupUri);
      if (grouping != null) {
        final oldFilter = grouping.uriToFilter(oldGroupUri);
        final newFilter = grouping.uriToFilter(newGroupUri);
        if (oldFilter != null && newFilter != null) {
          changed |= _pinnedFilters.replace(oldFilter, newFilter);
        }
      }
      if (changed) {
        pinnedFilters = _pinnedFilters;
      }
    });
  }

  void saveAlbumGroups() => albumGroups = albumGrouping.allGroups;
}
