import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/action_delegates/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class DoubleBackPopScope extends StatefulWidget {
  final Widget child;

  const DoubleBackPopScope({
    @required this.child,
  });

  @override
  _DoubleBackPopScopeState createState() => _DoubleBackPopScopeState();
}

class _DoubleBackPopScopeState extends State<DoubleBackPopScope> with FeedbackMixin {
  bool _backOnce = false;
  Timer _backTimer;

  @override
  void dispose() {
    _stopBackTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!Navigator.of(context).canPop() && settings.mustBackTwiceToExit && !_backOnce) {
          _backOnce = true;
          _stopBackTimer();
          _backTimer = Timer(Durations.doubleBackTimerDelay, () => _backOnce = false);
          toast(
            'Tap “back” again to exit.',
            duration: Durations.doubleBackTimerDelay,
          );
          return SynchronousFuture(false);
        }
        return SynchronousFuture(true);
      },
      child: widget.child,
    );
  }

  void _stopBackTimer() {
    _backTimer?.cancel();
  }
}
