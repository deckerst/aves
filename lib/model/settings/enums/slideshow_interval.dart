import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraSlideshowInterval on SlideshowInterval {
  String getName(BuildContext context) {
    switch (this) {
      case SlideshowInterval.s3:
        return context.l10n.timeSeconds(3);
      case SlideshowInterval.s5:
        return context.l10n.timeSeconds(5);
      case SlideshowInterval.s10:
        return context.l10n.timeSeconds(10);
      case SlideshowInterval.s30:
        return context.l10n.timeSeconds(30);
      case SlideshowInterval.s60:
        return context.l10n.timeMinutes(1);
    }
  }

  Duration getDuration() {
    switch (this) {
      case SlideshowInterval.s3:
        return const Duration(seconds: 3);
      case SlideshowInterval.s5:
        return const Duration(seconds: 5);
      case SlideshowInterval.s10:
        return const Duration(seconds: 10);
      case SlideshowInterval.s30:
        return const Duration(seconds: 30);
      case SlideshowInterval.s60:
        return const Duration(minutes: 1);
    }
  }
}
