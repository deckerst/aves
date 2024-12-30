import 'dart:ui';

import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
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

  Color get subtitleTextColor => ExtraColor.fromJson(getString(SettingKeys.subtitleTextColorKey)) ?? SettingsDefaults.subtitleTextColor;

  set subtitleTextColor(Color newValue) => set(SettingKeys.subtitleTextColorKey, newValue.toJson());

  Color get subtitleBackgroundColor => ExtraColor.fromJson(getString(SettingKeys.subtitleBackgroundColorKey)) ?? SettingsDefaults.subtitleBackgroundColor;

  set subtitleBackgroundColor(Color newValue) => set(SettingKeys.subtitleBackgroundColorKey, newValue.toJson());
}
