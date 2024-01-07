import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';

mixin NavigationSettings on SettingsAccess {
  bool get mustBackTwiceToExit => getBool(SettingKeys.mustBackTwiceToExitKey) ?? SettingsDefaults.mustBackTwiceToExit;

  set mustBackTwiceToExit(bool newValue) => set(SettingKeys.mustBackTwiceToExitKey, newValue);

  KeepScreenOn get keepScreenOn => getEnumOrDefault(SettingKeys.keepScreenOnKey, SettingsDefaults.keepScreenOn, KeepScreenOn.values);

  set keepScreenOn(KeepScreenOn newValue) => set(SettingKeys.keepScreenOnKey, newValue.toString());

  HomePageSetting get homePage => getEnumOrDefault(SettingKeys.homePageKey, SettingsDefaults.homePage, HomePageSetting.values);

  set homePage(HomePageSetting newValue) => set(SettingKeys.homePageKey, newValue.toString());

  Set<CollectionFilter> get homeCustomCollection => (getStringList(SettingKeys.homeCustomCollectionKey) ?? []).map(CollectionFilter.fromJson).whereNotNull().toSet();

  set homeCustomCollection(Set<CollectionFilter> newValue) => set(SettingKeys.homeCustomCollectionKey, newValue.map((filter) => filter.toJson()).toList());

  bool get enableBottomNavigationBar => getBool(SettingKeys.enableBottomNavigationBarKey) ?? SettingsDefaults.enableBottomNavigationBar;

  set enableBottomNavigationBar(bool newValue) => set(SettingKeys.enableBottomNavigationBarKey, newValue);

  bool get confirmCreateVault => getBool(SettingKeys.confirmCreateVaultKey) ?? SettingsDefaults.confirm;

  set confirmCreateVault(bool newValue) => set(SettingKeys.confirmCreateVaultKey, newValue);

  bool get confirmDeleteForever => getBool(SettingKeys.confirmDeleteForeverKey) ?? SettingsDefaults.confirm;

  set confirmDeleteForever(bool newValue) => set(SettingKeys.confirmDeleteForeverKey, newValue);

  bool get confirmMoveToBin => getBool(SettingKeys.confirmMoveToBinKey) ?? SettingsDefaults.confirm;

  set confirmMoveToBin(bool newValue) => set(SettingKeys.confirmMoveToBinKey, newValue);

  bool get confirmMoveUndatedItems => getBool(SettingKeys.confirmMoveUndatedItemsKey) ?? SettingsDefaults.confirm;

  set confirmMoveUndatedItems(bool newValue) => set(SettingKeys.confirmMoveUndatedItemsKey, newValue);

  bool get confirmAfterMoveToBin => getBool(SettingKeys.confirmAfterMoveToBinKey) ?? SettingsDefaults.confirm;

  set confirmAfterMoveToBin(bool newValue) => set(SettingKeys.confirmAfterMoveToBinKey, newValue);

  bool get setMetadataDateBeforeFileOp => getBool(SettingKeys.setMetadataDateBeforeFileOpKey) ?? SettingsDefaults.setMetadataDateBeforeFileOp;

  set setMetadataDateBeforeFileOp(bool newValue) => set(SettingKeys.setMetadataDateBeforeFileOpKey, newValue);

  List<CollectionFilter?> get drawerTypeBookmarks =>
      (getStringList(SettingKeys.drawerTypeBookmarksKey))?.map((v) {
        if (v.isEmpty) return null;
        return CollectionFilter.fromJson(v);
      }).toList() ??
      SettingsDefaults.drawerTypeBookmarks;

  set drawerTypeBookmarks(List<CollectionFilter?> newValue) => set(SettingKeys.drawerTypeBookmarksKey, newValue.map((filter) => filter?.toJson() ?? '').toList());

  List<String>? get drawerAlbumBookmarks => getStringList(SettingKeys.drawerAlbumBookmarksKey);

  set drawerAlbumBookmarks(List<String>? newValue) => set(SettingKeys.drawerAlbumBookmarksKey, newValue);

  List<String> get drawerPageBookmarks => getStringList(SettingKeys.drawerPageBookmarksKey) ?? SettingsDefaults.drawerPageBookmarks;

  set drawerPageBookmarks(List<String> newValue) => set(SettingKeys.drawerPageBookmarksKey, newValue);
}
