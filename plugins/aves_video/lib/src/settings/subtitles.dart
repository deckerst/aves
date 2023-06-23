import 'dart:ui';

import 'package:aves_model/aves_model.dart';
import 'package:aves_video/src/settings/defaults.dart';

mixin SubtitlesSettings on SettingsAccess {
  double get subtitleFontSize => getDouble(SettingKeys.subtitleFontSizeKey) ?? SettingsDefaults.subtitleFontSize;

  set subtitleFontSize(double newValue) => set(SettingKeys.subtitleFontSizeKey, newValue);

  TextAlign get subtitleTextAlignment => getEnumOrDefault(SettingKeys.subtitleTextAlignmentKey, SettingsDefaults.subtitleTextAlignment, TextAlign.values);

  set subtitleTextAlignment(TextAlign newValue) => set(SettingKeys.subtitleTextAlignmentKey, newValue.toString());

  SubtitlePosition get subtitleTextPosition => getEnumOrDefault(SettingKeys.subtitleTextPositionKey, SettingsDefaults.subtitleTextPosition, SubtitlePosition.values);

  set subtitleTextPosition(SubtitlePosition newValue) => set(SettingKeys.subtitleTextPositionKey, newValue.toString());

  bool get subtitleShowOutline => getBool(SettingKeys.subtitleShowOutlineKey) ?? SettingsDefaults.subtitleShowOutline;

  set subtitleShowOutline(bool newValue) => set(SettingKeys.subtitleShowOutlineKey, newValue);

  Color get subtitleTextColor => Color(getInt(SettingKeys.subtitleTextColorKey) ?? SettingsDefaults.subtitleTextColor.value);

  set subtitleTextColor(Color newValue) => set(SettingKeys.subtitleTextColorKey, newValue.value);

  Color get subtitleBackgroundColor => Color(getInt(SettingKeys.subtitleBackgroundColorKey) ?? SettingsDefaults.subtitleBackgroundColor.value);

  set subtitleBackgroundColor(Color newValue) => set(SettingKeys.subtitleBackgroundColorKey, newValue.value);
}
