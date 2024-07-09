import 'package:aves_map/aves_map.dart';

extension ExtraEntryMapStyle on EntryMapStyle {
  static bool isHeavy(EntryMapStyle? style) {
    switch (style) {
      case EntryMapStyle.googleNormal:
      case EntryMapStyle.googleHybrid:
      case EntryMapStyle.googleTerrain:
        return true;
      default:
        return false;
    }
  }

  bool get needMobileService {
    switch (this) {
      case EntryMapStyle.osmHot:
      case EntryMapStyle.stamenWatercolor:
        return false;
      default:
        return true;
    }
  }
}
