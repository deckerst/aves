import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraThumbnailOverlayLocationIconView on ThumbnailOverlayLocationIcon {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ThumbnailOverlayLocationIcon.located => l10n.filterLocatedLabel,
      ThumbnailOverlayLocationIcon.unlocated => l10n.filterNoLocationLabel,
      ThumbnailOverlayLocationIcon.none => l10n.settingsDisabled,
    };
  }

  IconData getIcon(BuildContext context) {
    return switch (this) {
      ThumbnailOverlayLocationIcon.unlocated => AIcons.locationUnlocated,
      ThumbnailOverlayLocationIcon.located || ThumbnailOverlayLocationIcon.none => AIcons.location,
    };
  }
}
