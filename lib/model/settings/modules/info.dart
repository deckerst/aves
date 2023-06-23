import 'package:aves/model/settings/defaults.dart';
import 'package:aves_model/aves_model.dart';

mixin InfoSettings on SettingsAccess {
  double get infoMapZoom => getDouble(SettingKeys.infoMapZoomKey) ?? SettingsDefaults.infoMapZoom;

  set infoMapZoom(double newValue) => set(SettingKeys.infoMapZoomKey, newValue);

  CoordinateFormat get coordinateFormat => getEnumOrDefault(SettingKeys.coordinateFormatKey, SettingsDefaults.coordinateFormat, CoordinateFormat.values);

  set coordinateFormat(CoordinateFormat newValue) => set(SettingKeys.coordinateFormatKey, newValue.toString());

  UnitSystem get unitSystem => getEnumOrDefault(SettingKeys.unitSystemKey, SettingsDefaults.unitSystem, UnitSystem.values);

  set unitSystem(UnitSystem newValue) => set(SettingKeys.unitSystemKey, newValue.toString());
}
