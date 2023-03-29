import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraThumbnailOverlayTagIconView on ThumbnailOverlayTagIcon {
  String getName(BuildContext context) {
    switch (this) {
      case ThumbnailOverlayTagIcon.tagged:
        return context.l10n.filterTaggedLabel;
      case ThumbnailOverlayTagIcon.untagged:
        return context.l10n.filterNoTagLabel;
      case ThumbnailOverlayTagIcon.none:
        return context.l10n.settingsDisabled;
    }
  }

  IconData getIcon(BuildContext context) {
    switch (this) {
      case ThumbnailOverlayTagIcon.tagged:
        return AIcons.tag;
      case ThumbnailOverlayTagIcon.untagged:
        return AIcons.tagUntagged;
      case ThumbnailOverlayTagIcon.none:
        return AIcons.tag;
    }
  }
}
