import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/modules/common_layout.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves_model/aves_model.dart';

mixin CollectionSettings on SettingsAccess, CommonLayoutSettings {
  List<String> get collectionBurstPatterns => getStringList(SettingKeys.collectionBurstPatternsKey) ?? [];

  set collectionBurstPatterns(List<String> newValue) => set(SettingKeys.collectionBurstPatternsKey, newValue);

  SortFactor get collectionSortFactor => getEnumOrDefault(SettingKeys.collectionSortFactorKey, SettingsDefaults.collectionSortFactor, SortFactor.values);

  set collectionSortFactor(SortFactor newValue) => set(SettingKeys.collectionSortFactorKey, newValue.name);

  bool get collectionSortReverse => getBool(SettingKeys.collectionSortReverseKey) ?? false;

  set collectionSortReverse(bool newValue) => set(SettingKeys.collectionSortReverseKey, newValue);

  EntrySectionFactor get collectionSectionFactor => getEnumOrDefault(SettingKeys.collectionSectionFactorKey, SettingsDefaults.collectionSectionFactor, EntrySectionFactor.values);

  set collectionSectionFactor(EntrySectionFactor newValue) => set(SettingKeys.collectionSectionFactorKey, newValue.name);

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

  // composite

  TileLayout get effectiveCollectionTileLayout => getTileLayout(CollectionPage.routeName);

  SortFactor get effectiveCollectionSortFactor {
    switch (effectiveCollectionTileLayout) {
      case .mosaic:
      case .grid:
      case .list:
        return collectionSortFactor;
      case .calendar:
        return .date;
    }
  }

  bool get effectiveCollectionSortReverse => collectionSortReverse;

  EntrySectionFactor get effectiveCollectionSectionFactor {
    switch (effectiveCollectionTileLayout) {
      case .mosaic:
      case .grid:
      case .list:
        switch (effectiveCollectionSortFactor) {
          case .date:
            return collectionSectionFactor;
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
