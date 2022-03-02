import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraVideoControls on VideoControls {
  String getName(BuildContext context) {
    switch (this) {
      case VideoControls.none:
        return context.l10n.videoControlsNone;
      case VideoControls.play:
        return context.l10n.videoControlsPlay;
      case VideoControls.playSeek:
        return context.l10n.videoControlsPlaySeek;
      case VideoControls.playOutside:
        return context.l10n.videoControlsPlayOutside;
    }
  }
}
