import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraSlideshowVideoPlayback on SlideshowVideoPlayback {
  String getName(BuildContext context) {
    switch (this) {
      case SlideshowVideoPlayback.skip:
        return context.l10n.videoPlaybackSkip;
      case SlideshowVideoPlayback.playMuted:
        return context.l10n.videoPlaybackMuted;
      case SlideshowVideoPlayback.playWithSound:
        return context.l10n.videoPlaybackWithSound;
    }
  }
}
