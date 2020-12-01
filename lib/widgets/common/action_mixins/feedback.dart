import 'package:aves/model/image_entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

mixin FeedbackMixin {
  Flushbar _flushbar;

  Future<void> dismissFeedback() => _flushbar?.dismiss();

  void showFeedback(BuildContext context, String message) {
    _flushbar = Flushbar(
      message: message,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      borderColor: Colors.white30,
      borderWidth: 0.5,
      duration: Durations.opToastDisplay * timeDilation,
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Durations.opToastAnimation,
    )..show(context);
  }

  // report overlay for multiple operations

  OverlayEntry _opReportOverlayEntry;

  void showOpReport<T extends ImageOpEvent>({
    @required BuildContext context,
    @required Set<ImageEntry> selection,
    @required Stream<T> opStream,
    @required void Function(Set<T> processed) onDone,
  }) {
    final processed = <T>{};

    // do not handle completion inside `StreamBuilder`
    // as it could be called multiple times
    Future<void> onComplete() => _hideOpReportOverlay().then((_) => onDone(processed));
    opStream.listen(
      processed.add,
      onError: (error) {
        debugPrint('_showOpReport error=$error');
        onComplete();
      },
      onDone: onComplete,
    );

    _opReportOverlayEntry = OverlayEntry(
      builder: (context) {
        return AbsorbPointer(
          child: StreamBuilder<T>(
              stream: opStream,
              builder: (context, snapshot) {
                Widget child = SizedBox.shrink();
                if (!snapshot.hasError) {
                  final percent = processed.length.toDouble() / selection.length;
                  child = CircularPercentIndicator(
                    percent: percent,
                    lineWidth: 16,
                    radius: 160,
                    backgroundColor: Colors.white24,
                    progressColor: Theme.of(context).accentColor,
                    animation: true,
                    center: Text(NumberFormat.percentPattern().format(percent)),
                    animateFromLastPercent: true,
                  );
                }
                return AnimatedSwitcher(
                  duration: Durations.collectionOpOverlayAnimation,
                  child: child,
                );
              }),
        );
      },
    );
    Overlay.of(context).insert(_opReportOverlayEntry);
  }

  Future<void> _hideOpReportOverlay() async {
    await Future.delayed(Durations.collectionOpOverlayAnimation * timeDilation);
    _opReportOverlayEntry.remove();
    _opReportOverlayEntry = null;
  }
}
