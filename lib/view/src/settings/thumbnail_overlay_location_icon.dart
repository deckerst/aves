import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraThumbnailOverlayLocationIconView on ThumbnailOverlayLocationIcon {
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
      case ThumbnailOverlayLocationIcon.unlocated:
        return AIcons.locationUnlocated;
      case ThumbnailOverlayLocationIcon.located:
      case ThumbnailOverlayLocationIcon.none:
        return AIcons.location;
    }
  }
}
