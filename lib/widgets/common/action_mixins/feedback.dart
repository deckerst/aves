import 'dart:async';
import 'dart:math';

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
    final duration = action != null ? Durations.opToastActionDisplay : Durations.opToastDisplay;
    messenger.showSnackBar(SnackBar(
      content: _FeedbackMessage(
        message: message,
        duration: action != null ? duration : null,
      ),
      action: action,
      duration: duration,
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
    Key? key,
    required this.opStream,
    required this.itemCount,
    required this.onDone,
  }) : super(key: key);

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
            final processedCount = processed.length.toDouble();
            final total = widget.itemCount;
            assert(processedCount <= total);
            final percent = min(1.0, processedCount / total);
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

class _FeedbackMessage extends StatefulWidget {
  final String message;
  final Duration? duration;

  const _FeedbackMessage({
    Key? key,
    required this.message,
    this.duration,
  }) : super(key: key);

  @override
  _FeedbackMessageState createState() => _FeedbackMessageState();
}

class _FeedbackMessageState extends State<_FeedbackMessage> {
  late int _totalSecs, _elapsedSecs = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration;
    if (duration != null) {
      _totalSecs = duration.inSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsedSecs++);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(widget.message);
    final duration = widget.duration;
    return duration == null
        ? text
        : Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 16),
              CircularPercentIndicator(
                percent: (_elapsedSecs.toDouble() / (_totalSecs - 1)).clamp(0.0, 1.0),
                lineWidth: 2,
                radius: 32,
                backgroundColor: Theme.of(context).accentColor,
                progressColor: Colors.grey,
                animation: true,
                animationDuration: 1000,
                center: Text('${_totalSecs - _elapsedSecs}'),
                animateFromLastPercent: true,
                reverse: true,
              ),
            ],
          );
  }
}
