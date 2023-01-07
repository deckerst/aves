import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'enums.dart';

extension ExtraThumbnailOverlayTagIcon on ThumbnailOverlayTagIcon {
  String getName(BuildContext context) {
    switch (this) {
      case ThumbnailOverlayTagIcon.tagged:
        return context.l10n.thumbnailOverlayTaggedIcon;
      case ThumbnailOverlayTagIcon.untagged:
        return context.l10n.thumbnailOverlayUntaggedIcon;
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
