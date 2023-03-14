import 'package:aves_map/aves_map.dart';

extension ExtraEntryMapStyle on EntryMapStyle {
  static bool isHeavy(EntryMapStyle? style) {
    switch (style) {
      case EntryMapStyle.googleNormal:
      case EntryMapStyle.googleHybrid:
      case EntryMapStyle.googleTerrain:
      case EntryMapStyle.hmsNormal:
      case EntryMapStyle.hmsTerrain:
        return true;
      default:
        return false;
    }
  }

  bool get needMobileService {
    switch (this) {
      case EntryMapStyle.osmHot:
      case EntryMapStyle.stamenToner:
      case EntryMapStyle.stamenWatercolor:
        return false;
      default:
        return true;
    }
  }
}
