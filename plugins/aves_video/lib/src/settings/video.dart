import 'package:aves_model/aves_model.dart';
import 'package:aves_video/src/settings/defaults.dart';

mixin VideoSettings on SettingsAccess {
  bool get enableVideoHardwareAcceleration => getBool(SettingKeys.enableVideoHardwareAccelerationKey) ?? SettingsDefaults.enableVideoHardwareAcceleration;

  set enableVideoHardwareAcceleration(bool newValue) => set(SettingKeys.enableVideoHardwareAccelerationKey, newValue);

  VideoAutoPlayMode get videoAutoPlayMode => getEnumOrDefault(SettingKeys.videoAutoPlayModeKey, SettingsDefaults.videoAutoPlayMode, VideoAutoPlayMode.values);

  set videoAutoPlayMode(VideoAutoPlayMode newValue) => set(SettingKeys.videoAutoPlayModeKey, newValue.toString());

  VideoBackgroundMode get videoBackgroundMode => getEnumOrDefault(SettingKeys.videoBackgroundModeKey, SettingsDefaults.videoBackgroundMode, VideoBackgroundMode.values);

  set videoBackgroundMode(VideoBackgroundMode newValue) => set(SettingKeys.videoBackgroundModeKey, newValue.toString());

  VideoLoopMode get videoLoopMode => getEnumOrDefault(SettingKeys.videoLoopModeKey, SettingsDefaults.videoLoopMode, VideoLoopMode.values);

  set videoLoopMode(VideoLoopMode newValue) => set(SettingKeys.videoLoopModeKey, newValue.toString());

  VideoResumptionMode get videoResumptionMode => getEnumOrDefault(SettingKeys.videoResumptionModeKey, SettingsDefaults.videoResumptionMode, VideoResumptionMode.values);

  set videoResumptionMode(VideoResumptionMode newValue) => set(SettingKeys.videoResumptionModeKey, newValue.toString());

  List<EntryAction> get videoControlActions => getEnumListOrDefault(SettingKeys.videoControlActionsKey, SettingsDefaults.videoControlActions, EntryAction.values);

  set videoControlActions(List<EntryAction> newValue) => set(SettingKeys.videoControlActionsKey, newValue.map((v) => v.toString()).toList());

  bool get videoGestureDoubleTapTogglePlay => getBool(SettingKeys.videoGestureDoubleTapTogglePlayKey) ?? SettingsDefaults.videoGestureDoubleTapTogglePlay;

  set videoGestureDoubleTapTogglePlay(bool newValue) => set(SettingKeys.videoGestureDoubleTapTogglePlayKey, newValue);

  bool get videoGestureSideDoubleTapSeek => getBool(SettingKeys.videoGestureSideDoubleTapSeekKey) ?? SettingsDefaults.videoGestureSideDoubleTapSeek;

  set videoGestureSideDoubleTapSeek(bool newValue) => set(SettingKeys.videoGestureSideDoubleTapSeekKey, newValue);

  bool get videoGestureVerticalDragBrightnessVolume => getBool(SettingKeys.videoGestureVerticalDragBrightnessVolumeKey) ?? SettingsDefaults.videoGestureVerticalDragBrightnessVolume;

  set videoGestureVerticalDragBrightnessVolume(bool newValue) => set(SettingKeys.videoGestureVerticalDragBrightnessVolumeKey, newValue);
}
