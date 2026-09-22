import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraThumbnailOverlayLocationIconView on ThumbnailOverlayLocationIcon {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .located => l10n.filterLocatedLabel,
      .unlocated => l10n.filterNoLocationLabel,
      .none => l10n.settingsDisabled,
    };
  }

  IconData getIcon(BuildContext context) {
    return switch (this) {
      .unlocated => AIcons.locationUnlocated,
      .located || .none => AIcons.location,
    };
  }
}
