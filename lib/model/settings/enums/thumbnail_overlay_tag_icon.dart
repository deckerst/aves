import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/widgets.dart';

extension ExtraThumbnailOverlayTagIcon on ThumbnailOverlayTagIcon {
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
