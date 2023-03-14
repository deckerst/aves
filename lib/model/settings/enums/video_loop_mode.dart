import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraVideoLoopMode on VideoLoopMode {
  String getName(BuildContext context) {
    switch (this) {
      case VideoLoopMode.never:
        return context.l10n.videoLoopModeNever;
      case VideoLoopMode.shortOnly:
        return context.l10n.videoLoopModeShortOnly;
      case VideoLoopMode.always:
        return context.l10n.videoLoopModeAlways;
    }
  }

  static const shortVideoThreshold = Duration(seconds: 30);

  bool shouldLoop(int? durationMillis) {
    switch (this) {
      case VideoLoopMode.never:
        return false;
      case VideoLoopMode.shortOnly:
        return durationMillis != null ? durationMillis < shortVideoThreshold.inMilliseconds : false;
      case VideoLoopMode.always:
        return true;
    }
  }
}
