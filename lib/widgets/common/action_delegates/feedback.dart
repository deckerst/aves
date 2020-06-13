import 'package:aves/utils/durations.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

mixin FeedbackMixin {
  Flushbar _flushbar;

  Future<void> dismissFeedback() => _flushbar?.dismiss();

  void showFeedback(BuildContext context, String message) {
    _flushbar = Flushbar(
      message: message,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      borderColor: Colors.white30,
      borderWidth: 0.5,
      duration: Durations.opToastDisplay * timeDilation,
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Durations.opToastAnimation,
    )..show(context);
  }
}
