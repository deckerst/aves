import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

final DoubleBackPopHandler doubleBackPopHandler = DoubleBackPopHandler._private();

class DoubleBackPopHandler extends PopHandler {
  bool _backOnce = false;
  Timer? _backTimer;

  DoubleBackPopHandler._private();

  @override
  bool canPop(BuildContext context) {
    if (context.select<Settings, bool>((s) => !s.mustBackTwiceToExit)) return true;
    if (Navigator.canPop(context)) return true;
    return false;
  }

  @override
  void onPopBlocked(BuildContext context) {
    if (_backOnce) {
      if (Navigator.canPop(context)) {
        Navigator.maybeOf(context)?.pop();
      } else {
        // exit
        reportService.log('Exit by pop');
        PopExitNotification().dispatch(context);
        SystemNavigator.pop();
      }
    } else {
      _backOnce = true;
      _backTimer?.cancel();
      _backTimer = Timer(ADurations.doubleBackTimerDelay, () => _backOnce = false);
      toast(
        context.l10n.doubleBackExitMessage,
        duration: ADurations.doubleBackTimerDelay,
      );
    }
  }
}
