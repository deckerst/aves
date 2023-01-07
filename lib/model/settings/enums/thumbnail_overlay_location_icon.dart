import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'enums.dart';

extension ExtraThumbnailOverlayLocationIcon on ThumbnailOverlayLocationIcon {
  String getName(BuildContext context) {
    switch (this) {
      case ThumbnailOverlayLocationIcon.located:
        return context.l10n.filterLocatedLabel;
      case ThumbnailOverlayLocationIcon.unlocated:
        return context.l10n.filterNoLocationLabel;
      case ThumbnailOverlayLocationIcon.none:
        return context.l10n.settingsDisabled;
    }
  }

  IconData getIcon(BuildContext context) {
    switch (this) {
      case ThumbnailOverlayLocationIcon.located:
        return AIcons.location;
      case ThumbnailOverlayLocationIcon.unlocated:
        return AIcons.locationUnlocated;
      case ThumbnailOverlayLocationIcon.none:
        return AIcons.location;
    }
  }
}
