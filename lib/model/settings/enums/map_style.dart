import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntryMapStyle on EntryMapStyle {
  String getName(BuildContext context) {
    switch (this) {
      case EntryMapStyle.googleNormal:
        return context.l10n.mapStyleGoogleNormal;
      case EntryMapStyle.googleHybrid:
        return context.l10n.mapStyleGoogleHybrid;
      case EntryMapStyle.googleTerrain:
        return context.l10n.mapStyleGoogleTerrain;
      case EntryMapStyle.hmsNormal:
        return context.l10n.mapStyleHuaweiNormal;
      case EntryMapStyle.hmsTerrain:
        return context.l10n.mapStyleHuaweiTerrain;
      case EntryMapStyle.osmHot:
        return context.l10n.mapStyleOsmHot;
      case EntryMapStyle.stamenToner:
        return context.l10n.mapStyleStamenToner;
      case EntryMapStyle.stamenWatercolor:
        return context.l10n.mapStyleStamenWatercolor;
    }
  }

  bool get isHeavy {
    switch (this) {
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
