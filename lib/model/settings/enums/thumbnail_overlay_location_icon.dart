import 'package:aves/theme/icons.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraThumbnailOverlayLocationIcon on ThumbnailOverlayLocationIcon {
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
