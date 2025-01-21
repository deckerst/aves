import 'package:aves_model/aves_model.dart';

mixin DebugSettings on SettingsAccess {
  bool get debugShowViewerTiles => getBool(SettingKeys.debugShowViewerTilesKey) ?? false;

  set debugShowViewerTiles(bool newValue) => set(SettingKeys.debugShowViewerTilesKey, newValue);
}
