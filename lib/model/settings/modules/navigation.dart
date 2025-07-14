import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/explorer/explorer_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/navigation/nav_item.dart';
import 'package:aves_model/aves_model.dart';
import 'package:synchronized/synchronized.dart';

mixin NavigationSettings on SettingsAccess {
  bool get mustBackTwiceToExit => getBool(SettingKeys.mustBackTwiceToExitKey) ?? SettingsDefaults.mustBackTwiceToExit;

  set mustBackTwiceToExit(bool newValue) => set(SettingKeys.mustBackTwiceToExitKey, newValue);

  KeepScreenOn get keepScreenOn => getEnumOrDefault(SettingKeys.keepScreenOnKey, SettingsDefaults.keepScreenOn, KeepScreenOn.values);

  set keepScreenOn(KeepScreenOn newValue) => set(SettingKeys.keepScreenOnKey, newValue.toString());

  HomePageSetting get homePage => getEnumOrDefault(SettingKeys.homePageKey, SettingsDefaults.homePage, HomePageSetting.values);

  Set<CollectionFilter> get homeCustomCollection => (getStringList(SettingKeys.homeCustomCollectionKey) ?? []).map(CollectionFilter.fromJson).nonNulls.toSet();

  String? get homeCustomExplorerPath => getString(SettingKeys.homeCustomExplorerPathKey);

  AvesNavItem get homeNavItem {
    switch (homePage) {
      case HomePageSetting.collection:
        return AvesNavItem(route: CollectionPage.routeName, filters: homeCustomCollection);
      case HomePageSetting.albums:
        return const AvesNavItem(route: AlbumListPage.routeName);
      case HomePageSetting.tags:
        return const AvesNavItem(route: TagListPage.routeName);
      case HomePageSetting.explorer:
        return AvesNavItem(route: ExplorerPage.routeName, path: homeCustomExplorerPath);
    }
  }

  void setHome(
    HomePageSetting homePage, {
    Set<CollectionFilter> customCollection = const {},
    String? customExplorerPath,
  }) {
    set(SettingKeys.homePageKey, homePage.toString());
    set(SettingKeys.homeCustomCollectionKey, customCollection.map((filter) => filter.toJson()).toList());
    set(SettingKeys.homeCustomExplorerPathKey, customExplorerPath);
  }

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
      getStringList(SettingKeys.drawerTypeBookmarksKey)?.map((v) {
        if (v.isEmpty) return null;
        return CollectionFilter.fromJson(v);
      }).toList() ??
      SettingsDefaults.drawerTypeBookmarks;

  set drawerTypeBookmarks(List<CollectionFilter?> newValue) => set(SettingKeys.drawerTypeBookmarksKey, newValue.map((filter) => filter?.toJson() ?? '').toList());

  List<AlbumBaseFilter>? get drawerAlbumBookmarks => getStringList(SettingKeys.drawerAlbumBookmarksKey)?.map(CollectionFilter.fromJson).whereType<AlbumBaseFilter>().toList();

  set drawerAlbumBookmarks(List<AlbumBaseFilter>? newValue) => set(SettingKeys.drawerAlbumBookmarksKey, newValue?.map((filter) => filter.toJson()).toList());

  List<String> get drawerPageBookmarks => getStringList(SettingKeys.drawerPageBookmarksKey) ?? SettingsDefaults.drawerPageBookmarks;

  set drawerPageBookmarks(List<String> newValue) => set(SettingKeys.drawerPageBookmarksKey, newValue);

  List<AvesNavItem> get bottomNavigationActions => getStringList(SettingKeys.bottomNavigationActionsKey)?.map(AvesNavItem.fromJson).nonNulls.toList() ?? SettingsDefaults.bottomNavigationActions;

  set bottomNavigationActions(List<AvesNavItem>? newValue) => set(SettingKeys.bottomNavigationActionsKey, newValue?.map((v) => v.toJson()).toList());

  bool get enableBottomNavigationBar => bottomNavigationActions.length >= 2;

  // listening

  final _lockForBookmarks = Lock();

  Future<void> updateBookmarkedDynamicAlbums(Map<DynamicAlbumFilter, DynamicAlbumFilter?> changes) async {
    await _lockForBookmarks.synchronized(() async {
      final _bookmarks = drawerAlbumBookmarks;
      bool changed = false;
      if (_bookmarks != null) {
        changes.forEach((oldFilter, newFilter) {
          if (newFilter != null) {
            changed |= _bookmarks.replace(oldFilter, newFilter);
          } else {
            changed |= _bookmarks.remove(oldFilter);
          }
        });
      }
      if (changed) {
        drawerAlbumBookmarks = _bookmarks;
      }
    });
  }

  Future<void> updateBookmarkedGroup(Uri oldGroupUri, Uri newGroupUri) async {
    await _lockForBookmarks.synchronized(() async {
      final _bookmarks = drawerAlbumBookmarks;
      bool changed = false;
      if (_bookmarks != null) {
        final grouping = FilterGrouping.forUri(oldGroupUri);
        if (grouping != null) {
          final oldFilter = grouping.uriToFilter(oldGroupUri);
          final newFilter = grouping.uriToFilter(newGroupUri);
          if (oldFilter is AlbumBaseFilter && newFilter is AlbumBaseFilter) {
            changed |= _bookmarks.replace(oldFilter, newFilter);
          }
        }
      }
      if (changed) {
        drawerAlbumBookmarks = _bookmarks;
      }
    });
  }
}
