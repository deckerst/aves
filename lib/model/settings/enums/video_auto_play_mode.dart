import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraSlideshowVideoPlayback on VideoAutoPlayMode {
  String getName(BuildContext context) {
    switch (this) {
      case VideoAutoPlayMode.disabled:
        return context.l10n.settingsDisabled;
      case VideoAutoPlayMode.playMuted:
        return context.l10n.videoPlaybackMuted;
      case VideoAutoPlayMode.playWithSound:
        return context.l10n.videoPlaybackWithSound;
    }
  }
}
