import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraEntryMapStyle on EntryMapStyle {
  String getName(BuildContext context) {
    switch (this) {
      case EntryMapStyle.googleNormal:
        return context.l10n.mapStyleGoogleNormal;
      case EntryMapStyle.googleHybrid:
        return context.l10n.mapStyleGoogleHybrid;
      case EntryMapStyle.googleTerrain:
        return context.l10n.mapStyleGoogleTerrain;
      case EntryMapStyle.osmHot:
        return context.l10n.mapStyleOsmHot;
      case EntryMapStyle.stamenToner:
        return context.l10n.mapStyleStamenToner;
      case EntryMapStyle.stamenWatercolor:
        return context.l10n.mapStyleStamenWatercolor;
      default:
        return toString();
    }
  }

  bool get isGoogleMaps {
    switch (this) {
      case EntryMapStyle.googleNormal:
      case EntryMapStyle.googleHybrid:
      case EntryMapStyle.googleTerrain:
        return true;
      default:
        return false;
    }
  }
}
