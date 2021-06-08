import 'package:aves/theme/durations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

mixin FeedbackMixin {
  void dismissFeedback(BuildContext context) => ScaffoldMessenger.of(context).hideCurrentSnackBar();

  void showFeedback(BuildContext context, String message, [SnackBarAction? action]) {
    showFeedbackWithMessenger(ScaffoldMessenger.of(context), message, action);
  }

  // provide the messenger if feedback happens as the widget is disposed
  void showFeedbackWithMessenger(ScaffoldMessengerState messenger, String message, [SnackBarAction? action]) {
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      action: action,
      duration: action != null ? Durations.opToastActionDisplay : Durations.opToastDisplay,
    ));
  }

  // report overlay for multiple operations

  void showOpReport<T>({
    required BuildContext context,
    required Stream<T> opStream,
    required int itemCount,
    void Function(Set<T> processed)? onDone,
  }) {
    late OverlayEntry _opReportOverlayEntry;
    _opReportOverlayEntry = OverlayEntry(
      builder: (context) => ReportOverlay<T>(
        opStream: opStream,
        itemCount: itemCount,
        onDone: (processed) {
          _opReportOverlayEntry.remove();
          onDone?.call(processed);
        },
      ),
    );
    Overlay.of(context)!.insert(_opReportOverlayEntry);
  }
}

class ReportOverlay<T> extends StatefulWidget {
  final Stream<T> opStream;
  final int itemCount;
  final void Function(Set<T> processed) onDone;

  const ReportOverlay({
    required this.opStream,
    required this.itemCount,
    required this.onDone,
  });

  @override
  _ReportOverlayState createState() => _ReportOverlayState<T>();
}

class _ReportOverlayState<T> extends State<ReportOverlay<T>> with SingleTickerProviderStateMixin {
  final processed = <T>{};
  late AnimationController _animationController;
  late Animation<double> _animation;

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
      onError: (error) => debugPrint('_showOpReport error=$error'),
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
                decoration: const BoxDecoration(
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
