import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class DoubleBackPopHandler {
  bool _backOnce = false;
  Timer? _backTimer;

  DoubleBackPopHandler() {
    if (kFlutterMemoryAllocationsEnabled) {
      MemoryAllocations.instance.dispatchObjectCreated(
        library: 'aves',
        className: '$DoubleBackPopHandler',
        object: this,
      );
    }
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      MemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _stopBackTimer();
  }

  bool pop(BuildContext context) {
    if (!Navigator.canPop(context) && settings.mustBackTwiceToExit && !_backOnce) {
      _backOnce = true;
      _stopBackTimer();
      _backTimer = Timer(ADurations.doubleBackTimerDelay, () => _backOnce = false);
      toast(
        context.l10n.doubleBackExitMessage,
        duration: ADurations.doubleBackTimerDelay,
      );
      return false;
    }
    return true;
  }

  void _stopBackTimer() {
    _backTimer?.cancel();
  }
}
