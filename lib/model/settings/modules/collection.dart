import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/modules/common_layout.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves_model/aves_model.dart';

mixin CollectionSettings on SettingsAccess, CommonLayoutSettings {
  List<String> get collectionBurstPatterns => getStringList(SettingKeys.collectionBurstPatternsKey) ?? [];

  set collectionBurstPatterns(List<String> newValue) => set(SettingKeys.collectionBurstPatternsKey, newValue);

  bool get showCollectionLayoutBar => getBool(SettingKeys.showCollectionLayoutBarKey) ?? false;

  set showCollectionLayoutBar(bool newValue) => set(SettingKeys.showCollectionLayoutBarKey, newValue);

  List<EntrySetAction> get collectionBrowsingQuickActions => getEnumListOrDefault(SettingKeys.collectionBrowsingQuickActionsKey, SettingsDefaults.collectionBrowsingQuickActions, EntrySetAction.values);

  set collectionBrowsingQuickActions(List<EntrySetAction> newValue) => set(SettingKeys.collectionBrowsingQuickActionsKey, newValue.map((v) => v.name).toList());

  List<EntrySetAction> get collectionSelectionQuickActions => getEnumListOrDefault(SettingKeys.collectionSelectionQuickActionsKey, SettingsDefaults.collectionSelectionQuickActions, EntrySetAction.values);

  set collectionSelectionQuickActions(List<EntrySetAction> newValue) => set(SettingKeys.collectionSelectionQuickActionsKey, newValue.map((v) => v.name).toList());

  bool get showThumbnailFavourite => getBool(SettingKeys.showThumbnailFavouriteKey) ?? SettingsDefaults.showThumbnailFavourite;

  set showThumbnailFavourite(bool newValue) => set(SettingKeys.showThumbnailFavouriteKey, newValue);

  bool get showThumbnailHdr => getBool(SettingKeys.showThumbnailHdrKey) ?? SettingsDefaults.showThumbnailHdr;

  set showThumbnailHdr(bool newValue) => set(SettingKeys.showThumbnailHdrKey, newValue);

  ThumbnailOverlayLocationIcon get thumbnailLocationIcon => getEnumOrDefault(SettingKeys.thumbnailLocationIconKey, SettingsDefaults.thumbnailLocationIcon, ThumbnailOverlayLocationIcon.values);

  set thumbnailLocationIcon(ThumbnailOverlayLocationIcon newValue) => set(SettingKeys.thumbnailLocationIconKey, newValue.name);

  ThumbnailOverlayTagIcon get thumbnailTagIcon => getEnumOrDefault(SettingKeys.thumbnailTagIconKey, SettingsDefaults.thumbnailTagIcon, ThumbnailOverlayTagIcon.values);

  set thumbnailTagIcon(ThumbnailOverlayTagIcon newValue) => set(SettingKeys.thumbnailTagIconKey, newValue.name);

  bool get showThumbnailMotionPhoto => getBool(SettingKeys.showThumbnailMotionPhotoKey) ?? SettingsDefaults.showThumbnailMotionPhoto;

  set showThumbnailMotionPhoto(bool newValue) => set(SettingKeys.showThumbnailMotionPhotoKey, newValue);

  bool get showThumbnailRating => getBool(SettingKeys.showThumbnailRatingKey) ?? SettingsDefaults.showThumbnailRating;

  set showThumbnailRating(bool newValue) => set(SettingKeys.showThumbnailRatingKey, newValue);

  bool get showThumbnailRaw => getBool(SettingKeys.showThumbnailRawKey) ?? SettingsDefaults.showThumbnailRaw;

  set showThumbnailRaw(bool newValue) => set(SettingKeys.showThumbnailRawKey, newValue);

  bool get showThumbnailSlowMotionVideo => getBool(SettingKeys.showThumbnailSlowMotionVideoKey) ?? SettingsDefaults.showThumbnailRaw;

  set showThumbnailSlowMotionVideo(bool newValue) => set(SettingKeys.showThumbnailSlowMotionVideoKey, newValue);

  bool get showThumbnailVideoDuration => getBool(SettingKeys.showThumbnailVideoDurationKey) ?? SettingsDefaults.showThumbnailVideoDuration;

  set showThumbnailVideoDuration(bool newValue) => set(SettingKeys.showThumbnailVideoDurationKey, newValue);

  // direct

  SortFactor get _collectionSortFactor => getEnumOrDefault(SettingKeys.collectionSortFactorKey, SettingsDefaults.collectionSortFactor, SortFactor.values);

  set _collectionSortFactor(SortFactor newValue) => set(SettingKeys.collectionSortFactorKey, newValue.name);

  bool get _collectionSortReverse => getBool(SettingKeys.collectionSortReverseKey) ?? false;

  set _collectionSortReverse(bool newValue) => set(SettingKeys.collectionSortReverseKey, newValue);

  EntrySectionFactor get _collectionSectionFactor => getEnumOrDefault(SettingKeys.collectionSectionFactorKey, SettingsDefaults.collectionSectionFactor, EntrySectionFactor.values);

  set _collectionSectionFactor(EntrySectionFactor newValue) => set(SettingKeys.collectionSectionFactorKey, newValue.name);

  // composite (stored)

  void setStoredCollectionTileLayout(Set<CollectionFilter> filters, TileLayout newValue) {
    // TODO TLAD [layout per album]
    setTileLayout(CollectionPage.routeName, newValue);
  }

  void setStoredCollectionSortFactor(Set<CollectionFilter> filters, SortFactor newValue) {
    // TODO TLAD [layout per album]
    _collectionSortFactor = newValue;
  }

  void setStoredCollectionSortReverse(Set<CollectionFilter> filters, bool newValue) {
    // TODO TLAD [layout per album]
    _collectionSortReverse = newValue;
  }

  void setStoredCollectionSectionFactor(Set<CollectionFilter> filters, EntrySectionFactor newValue) {
    // TODO TLAD [layout per album]
    _collectionSectionFactor = newValue;
  }

  TileLayout getStoredCollectionTileLayout(Set<CollectionFilter> filters) {
    // TODO TLAD [layout per album]
    return getTileLayout(CollectionPage.routeName);
  }

  SortFactor getStoredCollectionSortFactor(Set<CollectionFilter> filters) {
    // TODO TLAD [layout per album]
    return _collectionSortFactor;
  }

  bool getStoredCollectionSortReverse(Set<CollectionFilter> filters) {
    // TODO TLAD [layout per album]
    return _collectionSortReverse;
  }

  EntrySectionFactor getStoredCollectionSectionFactor(Set<CollectionFilter> filters) {
    // TODO TLAD [layout per album]
    return _collectionSectionFactor;
  }

  // composite (effective)

  TileLayout getEffectiveCollectionTileLayout(Set<CollectionFilter> filters) {
    return getStoredCollectionTileLayout(filters);
  }

  SortFactor getEffectiveCollectionSortFactor(Set<CollectionFilter> filters) {
    switch (getEffectiveCollectionTileLayout(filters)) {
      case .mosaic:
      case .grid:
      case .list:
        return getStoredCollectionSortFactor(filters);
      case .calendar:
        return .date;
    }
  }

  bool getEffectiveCollectionSortReverse(Set<CollectionFilter> filters) {
    return getStoredCollectionSortReverse(filters);
  }

  EntrySectionFactor getEffectiveCollectionSectionFactor(Set<CollectionFilter> filters) {
    switch (getEffectiveCollectionTileLayout(filters)) {
      case .mosaic:
      case .grid:
      case .list:
        switch (getEffectiveCollectionSortFactor(filters)) {
          case .date:
            return getStoredCollectionSectionFactor(filters);
          case .albumItemName:
          case .path:
            return .name;
          case .size:
          case .duration:
            return .none;
          case .rating:
            return .rating;
          case .chipName:
          case .count:
            throw UnimplementedError();
        }
      case .calendar:
        return .month;
    }
  }
}
