import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin SlideshowSettings on SettingsAccess {
  bool get slideshowRepeat => getBool(SettingKeys.slideshowRepeatKey) ?? SettingsDefaults.slideshowRepeat;

  set slideshowRepeat(bool newValue) => set(SettingKeys.slideshowRepeatKey, newValue);

  bool get slideshowShuffle => getBool(SettingKeys.slideshowShuffleKey) ?? SettingsDefaults.slideshowShuffle;

  set slideshowShuffle(bool newValue) => set(SettingKeys.slideshowShuffleKey, newValue);

  bool get slideshowFillScreen => getBool(SettingKeys.slideshowFillScreenKey) ?? SettingsDefaults.slideshowFillScreen;

  set slideshowFillScreen(bool newValue) => set(SettingKeys.slideshowFillScreenKey, newValue);

  bool get slideshowAnimatedZoomEffect => getBool(SettingKeys.slideshowAnimatedZoomEffectKey) ?? SettingsDefaults.slideshowAnimatedZoomEffect;

  set slideshowAnimatedZoomEffect(bool newValue) => set(SettingKeys.slideshowAnimatedZoomEffectKey, newValue);

  ViewerTransition get slideshowTransition => getEnumOrDefault(SettingKeys.slideshowTransitionKey, SettingsDefaults.slideshowTransition, ViewerTransition.values);

  set slideshowTransition(ViewerTransition newValue) => set(SettingKeys.slideshowTransitionKey, newValue.toString());

  SlideshowVideoPlayback get slideshowVideoPlayback => getEnumOrDefault(SettingKeys.slideshowVideoPlaybackKey, SettingsDefaults.slideshowVideoPlayback, SlideshowVideoPlayback.values);

  set slideshowVideoPlayback(SlideshowVideoPlayback newValue) => set(SettingKeys.slideshowVideoPlaybackKey, newValue.toString());

  int get slideshowInterval => getInt(SettingKeys.slideshowIntervalKey) ?? SettingsDefaults.slideshowInterval;

  set slideshowInterval(int newValue) => set(SettingKeys.slideshowIntervalKey, newValue);
}
