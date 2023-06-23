import 'package:aves/model/device.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin DisplaySettings on SettingsAccess {
  DisplayRefreshRateMode get displayRefreshRateMode => getEnumOrDefault(SettingKeys.displayRefreshRateModeKey, SettingsDefaults.displayRefreshRateMode, DisplayRefreshRateMode.values);

  set displayRefreshRateMode(DisplayRefreshRateMode newValue) => set(SettingKeys.displayRefreshRateModeKey, newValue.toString());

  AvesThemeBrightness get themeBrightness => getEnumOrDefault(SettingKeys.themeBrightnessKey, SettingsDefaults.themeBrightness, AvesThemeBrightness.values);

  set themeBrightness(AvesThemeBrightness newValue) => set(SettingKeys.themeBrightnessKey, newValue.toString());

  AvesThemeColorMode get themeColorMode => getEnumOrDefault(SettingKeys.themeColorModeKey, SettingsDefaults.themeColorMode, AvesThemeColorMode.values);

  set themeColorMode(AvesThemeColorMode newValue) => set(SettingKeys.themeColorModeKey, newValue.toString());

  bool get enableDynamicColor => getBool(SettingKeys.enableDynamicColorKey) ?? SettingsDefaults.enableDynamicColor;

  set enableDynamicColor(bool newValue) => set(SettingKeys.enableDynamicColorKey, newValue);

  bool get enableBlurEffect => getBool(SettingKeys.enableBlurEffectKey) ?? SettingsDefaults.enableBlurEffect;

  set enableBlurEffect(bool newValue) => set(SettingKeys.enableBlurEffectKey, newValue);

  MaxBrightness get maxBrightness => getEnumOrDefault(SettingKeys.maxBrightnessKey, SettingsDefaults.maxBrightness, MaxBrightness.values);

  set maxBrightness(MaxBrightness newValue) => set(SettingKeys.maxBrightnessKey, newValue.toString());

  bool get forceTvLayout => getBool(SettingKeys.forceTvLayoutKey) ?? SettingsDefaults.forceTvLayout;

  set forceTvLayout(bool newValue) => set(SettingKeys.forceTvLayoutKey, newValue);

  bool get useTvLayout => device.isTelevision || forceTvLayout;

  bool get isReadOnly => useTvLayout;
}
