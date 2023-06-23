import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin CollectionSettings on SettingsAccess {
  List<String> get collectionBurstPatterns => getStringList(SettingKeys.collectionBurstPatternsKey) ?? [];

  set collectionBurstPatterns(List<String> newValue) => set(SettingKeys.collectionBurstPatternsKey, newValue);

  EntryGroupFactor get collectionSectionFactor => getEnumOrDefault(SettingKeys.collectionGroupFactorKey, SettingsDefaults.collectionSectionFactor, EntryGroupFactor.values);

  set collectionSectionFactor(EntryGroupFactor newValue) => set(SettingKeys.collectionGroupFactorKey, newValue.toString());

  EntrySortFactor get collectionSortFactor => getEnumOrDefault(SettingKeys.collectionSortFactorKey, SettingsDefaults.collectionSortFactor, EntrySortFactor.values);

  set collectionSortFactor(EntrySortFactor newValue) => set(SettingKeys.collectionSortFactorKey, newValue.toString());

  bool get collectionSortReverse => getBool(SettingKeys.collectionSortReverseKey) ?? false;

  set collectionSortReverse(bool newValue) => set(SettingKeys.collectionSortReverseKey, newValue);

  List<EntrySetAction> get collectionBrowsingQuickActions => getEnumListOrDefault(SettingKeys.collectionBrowsingQuickActionsKey, SettingsDefaults.collectionBrowsingQuickActions, EntrySetAction.values);

  set collectionBrowsingQuickActions(List<EntrySetAction> newValue) => set(SettingKeys.collectionBrowsingQuickActionsKey, newValue.map((v) => v.toString()).toList());

  List<EntrySetAction> get collectionSelectionQuickActions => getEnumListOrDefault(SettingKeys.collectionSelectionQuickActionsKey, SettingsDefaults.collectionSelectionQuickActions, EntrySetAction.values);

  set collectionSelectionQuickActions(List<EntrySetAction> newValue) => set(SettingKeys.collectionSelectionQuickActionsKey, newValue.map((v) => v.toString()).toList());

  bool get showThumbnailFavourite => getBool(SettingKeys.showThumbnailFavouriteKey) ?? SettingsDefaults.showThumbnailFavourite;

  set showThumbnailFavourite(bool newValue) => set(SettingKeys.showThumbnailFavouriteKey, newValue);

  ThumbnailOverlayLocationIcon get thumbnailLocationIcon => getEnumOrDefault(SettingKeys.thumbnailLocationIconKey, SettingsDefaults.thumbnailLocationIcon, ThumbnailOverlayLocationIcon.values);

  set thumbnailLocationIcon(ThumbnailOverlayLocationIcon newValue) => set(SettingKeys.thumbnailLocationIconKey, newValue.toString());

  ThumbnailOverlayTagIcon get thumbnailTagIcon => getEnumOrDefault(SettingKeys.thumbnailTagIconKey, SettingsDefaults.thumbnailTagIcon, ThumbnailOverlayTagIcon.values);

  set thumbnailTagIcon(ThumbnailOverlayTagIcon newValue) => set(SettingKeys.thumbnailTagIconKey, newValue.toString());

  bool get showThumbnailMotionPhoto => getBool(SettingKeys.showThumbnailMotionPhotoKey) ?? SettingsDefaults.showThumbnailMotionPhoto;

  set showThumbnailMotionPhoto(bool newValue) => set(SettingKeys.showThumbnailMotionPhotoKey, newValue);

  bool get showThumbnailRating => getBool(SettingKeys.showThumbnailRatingKey) ?? SettingsDefaults.showThumbnailRating;

  set showThumbnailRating(bool newValue) => set(SettingKeys.showThumbnailRatingKey, newValue);

  bool get showThumbnailRaw => getBool(SettingKeys.showThumbnailRawKey) ?? SettingsDefaults.showThumbnailRaw;

  set showThumbnailRaw(bool newValue) => set(SettingKeys.showThumbnailRawKey, newValue);

  bool get showThumbnailVideoDuration => getBool(SettingKeys.showThumbnailVideoDurationKey) ?? SettingsDefaults.showThumbnailVideoDuration;

  set showThumbnailVideoDuration(bool newValue) => set(SettingKeys.showThumbnailVideoDurationKey, newValue);
}
