import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves_model/aves_model.dart';

mixin HistorySettings on SettingsAccess {
  static const int recentFilterHistoryMax = 20;

  void initHistorySettings() {
    vaults.lockStateChangeNotifier.addListener(_onVaultsChanged);
  }

  bool get saveSearchHistory => getBool(SettingKeys.saveSearchHistoryKey) ?? SettingsDefaults.saveSearchHistory;

  set saveSearchHistory(bool newValue) => set(SettingKeys.saveSearchHistoryKey, newValue);

  List<CollectionFilter> get searchHistory => (getStringList(SettingKeys.searchHistoryKey) ?? []).map(CollectionFilter.fromJson).nonNulls.toList();

  set searchHistory(List<CollectionFilter> newValue) => set(SettingKeys.searchHistoryKey, newValue.map((filter) => filter.toJsonString()).toList());

  List<String> get recentSettingKeys => getStringList(SettingKeys.recentSettingKeysKey) ?? [];

  set recentSettingKeys(List<String> newValue) => set(SettingKeys.recentSettingKeysKey, newValue);

  List<String> get recentDestinationAlbums => getStringList(SettingKeys.recentDestinationAlbumsKey) ?? [];

  set recentDestinationAlbums(List<String> newValue) => set(SettingKeys.recentDestinationAlbumsKey, newValue.take(recentFilterHistoryMax).toList());

  // recent tags

  List<CollectionFilter> get _recentTags => (getStringList(SettingKeys.recentTagsKey) ?? []).map(CollectionFilter.fromJson).nonNulls.toList();

  set _recentTags(List<CollectionFilter> newValue) => set(SettingKeys.recentTagsKey, newValue.take(recentFilterHistoryMax).map((filter) => filter.toJsonString()).toList());

  // when vaults are unlocked, recent tags are transient and not persisted
  List<CollectionFilter>? _protectedRecentTags;

  List<CollectionFilter> get recentTags => vaults.needProtection ? _protectedRecentTags ?? List.of(_recentTags) : _recentTags;

  set recentTags(List<CollectionFilter> newValue) {
    if (vaults.needProtection) {
      _protectedRecentTags = newValue;
    } else {
      _recentTags = newValue;
    }
  }

  void _onVaultsChanged() => _protectedRecentTags = null;

  void removeObsoleteRecentTags(CollectionSource? source) {
    if (source != null) {
      recentTags = recentTags.where((v) => v is! TagFilter || source.sortedTags.contains(v.tag)).toList();
    }
  }
}
