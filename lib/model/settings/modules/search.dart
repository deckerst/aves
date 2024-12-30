import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin SearchSettings on SettingsAccess {
  bool get saveSearchHistory => getBool(SettingKeys.saveSearchHistoryKey) ?? SettingsDefaults.saveSearchHistory;

  set saveSearchHistory(bool newValue) => set(SettingKeys.saveSearchHistoryKey, newValue);

  List<CollectionFilter> get searchHistory => (getStringList(SettingKeys.searchHistoryKey) ?? []).map(CollectionFilter.fromJson).nonNulls.toList();

  set searchHistory(List<CollectionFilter> newValue) => set(SettingKeys.searchHistoryKey, newValue.map((filter) => filter.toJson()).toList());
}
