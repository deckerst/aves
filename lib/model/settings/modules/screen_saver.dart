import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin ScreenSaverSettings on SettingsAccess {
  bool get screenSaverFillScreen => getBool(SettingKeys.screenSaverFillScreenKey) ?? SettingsDefaults.slideshowFillScreen;

  set screenSaverFillScreen(bool newValue) => set(SettingKeys.screenSaverFillScreenKey, newValue);

  bool get screenSaverAnimatedZoomEffect => getBool(SettingKeys.screenSaverAnimatedZoomEffectKey) ?? SettingsDefaults.slideshowAnimatedZoomEffect;

  set screenSaverAnimatedZoomEffect(bool newValue) => set(SettingKeys.screenSaverAnimatedZoomEffectKey, newValue);

  ViewerTransition get screenSaverTransition => getEnumOrDefault(SettingKeys.screenSaverTransitionKey, SettingsDefaults.slideshowTransition, ViewerTransition.values);

  set screenSaverTransition(ViewerTransition newValue) => set(SettingKeys.screenSaverTransitionKey, newValue.toString());

  SlideshowVideoPlayback get screenSaverVideoPlayback => getEnumOrDefault(SettingKeys.screenSaverVideoPlaybackKey, SettingsDefaults.slideshowVideoPlayback, SlideshowVideoPlayback.values);

  set screenSaverVideoPlayback(SlideshowVideoPlayback newValue) => set(SettingKeys.screenSaverVideoPlaybackKey, newValue.toString());

  int get screenSaverInterval => getInt(SettingKeys.screenSaverIntervalKey) ?? SettingsDefaults.slideshowInterval;

  set screenSaverInterval(int newValue) => set(SettingKeys.screenSaverIntervalKey, newValue);

  Set<CollectionFilter> get screenSaverCollectionFilters => (getStringList(SettingKeys.screenSaverCollectionFiltersKey) ?? []).map(CollectionFilter.fromJson).nonNulls.toSet();

  set screenSaverCollectionFilters(Set<CollectionFilter> newValue) => set(SettingKeys.screenSaverCollectionFiltersKey, newValue.map((filter) => filter.toJson()).toList());
}
