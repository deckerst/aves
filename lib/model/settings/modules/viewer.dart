import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin ViewerSettings on SettingsAccess {
  List<EntryAction> get viewerQuickActions => getEnumListOrDefault(SettingKeys.viewerQuickActionsKey, SettingsDefaults.viewerQuickActions, EntryAction.values);

  set viewerQuickActions(List<EntryAction> newValue) => set(SettingKeys.viewerQuickActionsKey, newValue.map((v) => v.toString()).toList());

  bool get showOverlayOnOpening => getBool(SettingKeys.showOverlayOnOpeningKey) ?? SettingsDefaults.showOverlayOnOpening;

  set showOverlayOnOpening(bool newValue) => set(SettingKeys.showOverlayOnOpeningKey, newValue);

  bool get showOverlayMinimap => getBool(SettingKeys.showOverlayMinimapKey) ?? SettingsDefaults.showOverlayMinimap;

  set showOverlayMinimap(bool newValue) => set(SettingKeys.showOverlayMinimapKey, newValue);

  OverlayHistogramStyle get overlayHistogramStyle => getEnumOrDefault(SettingKeys.overlayHistogramStyleKey, SettingsDefaults.overlayHistogramStyle, OverlayHistogramStyle.values);

  set overlayHistogramStyle(OverlayHistogramStyle newValue) => set(SettingKeys.overlayHistogramStyleKey, newValue.toString());

  bool get showOverlayInfo => getBool(SettingKeys.showOverlayInfoKey) ?? SettingsDefaults.showOverlayInfo;

  set showOverlayInfo(bool newValue) => set(SettingKeys.showOverlayInfoKey, newValue);

  bool get showOverlayDescription => getBool(SettingKeys.showOverlayDescriptionKey) ?? SettingsDefaults.showOverlayDescription;

  set showOverlayDescription(bool newValue) => set(SettingKeys.showOverlayDescriptionKey, newValue);

  bool get showOverlayRatingTags => getBool(SettingKeys.showOverlayRatingTagsKey) ?? SettingsDefaults.showOverlayRatingTags;

  set showOverlayRatingTags(bool newValue) => set(SettingKeys.showOverlayRatingTagsKey, newValue);

  bool get showOverlayShootingDetails => getBool(SettingKeys.showOverlayShootingDetailsKey) ?? SettingsDefaults.showOverlayShootingDetails;

  set showOverlayShootingDetails(bool newValue) => set(SettingKeys.showOverlayShootingDetailsKey, newValue);

  bool get showOverlayThumbnailPreview => getBool(SettingKeys.showOverlayThumbnailPreviewKey) ?? SettingsDefaults.showOverlayThumbnailPreview;

  set showOverlayThumbnailPreview(bool newValue) => set(SettingKeys.showOverlayThumbnailPreviewKey, newValue);

  bool get viewerGestureSideTapNext => getBool(SettingKeys.viewerGestureSideTapNextKey) ?? SettingsDefaults.viewerGestureSideTapNext;

  set viewerGestureSideTapNext(bool newValue) => set(SettingKeys.viewerGestureSideTapNextKey, newValue);

  bool get viewerUseCutout => getBool(SettingKeys.viewerUseCutoutKey) ?? SettingsDefaults.viewerUseCutout;

  set viewerUseCutout(bool newValue) => set(SettingKeys.viewerUseCutoutKey, newValue);

  bool get enableMotionPhotoAutoPlay => getBool(SettingKeys.enableMotionPhotoAutoPlayKey) ?? SettingsDefaults.enableMotionPhotoAutoPlay;

  set enableMotionPhotoAutoPlay(bool newValue) => set(SettingKeys.enableMotionPhotoAutoPlayKey, newValue);

  EntryBackground get imageBackground => getEnumOrDefault(SettingKeys.imageBackgroundKey, SettingsDefaults.imageBackground, EntryBackground.values);

  set imageBackground(EntryBackground newValue) => set(SettingKeys.imageBackgroundKey, newValue.toString());
}
