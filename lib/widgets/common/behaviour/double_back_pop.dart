import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class DoubleBackPopScope extends StatefulWidget {
  final Widget child;

  const DoubleBackPopScope({
    super.key,
    required this.child,
  });

  @override
  State<DoubleBackPopScope> createState() => _DoubleBackPopScopeState();
}

class _DoubleBackPopScopeState extends State<DoubleBackPopScope> with FeedbackMixin {
  bool _backOnce = false;
  Timer? _backTimer;

  @override
  void dispose() {
    _stopBackTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!Navigator.canPop(context) && settings.mustBackTwiceToExit && !_backOnce) {
          _backOnce = true;
          _stopBackTimer();
          _backTimer = Timer(Durations.doubleBackTimerDelay, () => _backOnce = false);
          toast(
            context.l10n.doubleBackExitMessage,
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
