import 'package:aves_model/aves_model.dart';

mixin DebugSettings on SettingsAccess {
  int get debugCatalogConcurrentTaskMax => getInt(SettingKeys.debugCatalogConcurrentTaskMaxKey) ?? 1;

  set debugCatalogConcurrentTaskMax(int newValue) => set(SettingKeys.debugCatalogConcurrentTaskMaxKey, newValue);

  bool get debugShowViewerTiles => getBool(SettingKeys.debugShowViewerTilesKey) ?? false;

  set debugShowViewerTiles(bool newValue) => set(SettingKeys.debugShowViewerTilesKey, newValue);
}
