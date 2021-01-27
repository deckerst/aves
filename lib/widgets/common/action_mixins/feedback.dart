import 'package:aves/model/entry.dart';
import 'package:aves/services/image_op_events.dart';
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
    @required Set<AvesEntry> selection,
    @required Stream<T> opStream,
    @required void Function(Set<T> processed) onDone,
  }) {
    _opReportOverlayEntry = OverlayEntry(
      builder: (context) => ReportOverlay<T>(
        opStream: opStream,
        itemCount: selection.length,
        onDone: (processed) {
          _opReportOverlayEntry?.remove();
          _opReportOverlayEntry = null;
          onDone(processed);
        },
      ),
    );
    Overlay.of(context).insert(_opReportOverlayEntry);
  }
}

class ReportOverlay<T> extends StatefulWidget {
  final Stream<T> opStream;
  final int itemCount;
  final void Function(Set<T> processed) onDone;

  const ReportOverlay({
    @required this.opStream,
    @required this.itemCount,
    @required this.onDone,
  });

  @override
  _ReportOverlayState createState() => _ReportOverlayState<T>();
}

class _ReportOverlayState<T> extends State<ReportOverlay<T>> with SingleTickerProviderStateMixin {
  final processed = <T>{};
  AnimationController _animationController;
  Animation<double> _animation;

  Stream<T> get opStream => widget.opStream;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Durations.collectionOpOverlayAnimation,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    );
    _animationController.forward();

    // do not handle completion inside `StreamBuilder`
    // as it could be called multiple times
    Future<void> onComplete() => _animationController.reverse().then((_) => widget.onDone(processed));
    opStream.listen(
      processed.add,
      onError: (error) {
        debugPrint('_showOpReport error=$error');
        onComplete();
      },
      onDone: onComplete,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: StreamBuilder<T>(
          stream: opStream,
          builder: (context, snapshot) {
            final percent = processed.length.toDouble() / widget.itemCount;
            return FadeTransition(
              opacity: _animation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.black,
                      Colors.black54,
                    ],
                  ),
                ),
                child: Center(
                  child: CircularPercentIndicator(
                    percent: percent,
                    lineWidth: 16,
                    radius: 160,
                    backgroundColor: Colors.white24,
                    progressColor: Theme.of(context).accentColor,
                    animation: true,
                    center: Text(NumberFormat.percentPattern().format(percent)),
                    animateFromLastPercent: true,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
