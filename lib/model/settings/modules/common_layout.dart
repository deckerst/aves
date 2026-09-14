import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin CommonLayoutSettings on SettingsAccess {
  double getTileExtent(String routeName) => getDouble(SettingKeys.tileExtentPrefixKey + routeName) ?? 0;

  void setTileExtent(String routeName, double newValue) => set(SettingKeys.tileExtentPrefixKey + routeName, newValue);

  TileLayout getTileLayout(String routeName) => getEnumOrDefault(SettingKeys.tileLayoutPrefixKey + routeName, SettingsDefaults.tileLayout, TileLayout.values);

  void setTileLayout(String routeName, TileLayout newValue) => set(SettingKeys.tileLayoutPrefixKey + routeName, newValue.name);
}
