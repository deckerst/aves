import 'dart:async';
import 'dart:math';

import 'package:aves/model/settings/accessibility_animations.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

mixin FeedbackMixin {
  void dismissFeedback(BuildContext context) => ScaffoldMessenger.of(context).hideCurrentSnackBar();

  void showFeedback(BuildContext context, String message, [SnackBarAction? action]) {
    showFeedbackWithMessenger(context, ScaffoldMessenger.of(context), message, action);
  }

  // provide the messenger if feedback happens as the widget is disposed
  void showFeedbackWithMessenger(BuildContext context, ScaffoldMessengerState messenger, String message, [SnackBarAction? action]) {
    _getSnackBarDuration(action != null).then((duration) {
      final progressColor = Theme.of(context).colorScheme.secondary;
      messenger.showSnackBar(SnackBar(
        content: _FeedbackMessage(
          message: message,
          progressColor: progressColor,
          duration: action != null ? duration : null,
        ),
        action: action,
        duration: duration,
      ));
    });
  }

  Future<Duration> _getSnackBarDuration(bool hasAction) async {
    final appDefaultDuration = hasAction ? Durations.opToastActionDisplay : Durations.opToastTextDisplay;
    switch (settings.timeToTakeAction) {
      case AccessibilityTimeout.system:
        final original = appDefaultDuration.inMilliseconds;
        final millis = await (hasAction ? AccessibilityService.getRecommendedTimeToTakeAction(original) : AccessibilityService.getRecommendedTimeToRead(original));
        return Duration(milliseconds: millis);
      case AccessibilityTimeout.appDefault:
        return appDefaultDuration;
      case AccessibilityTimeout.s10:
        return const Duration(seconds: 10);
      case AccessibilityTimeout.s30:
        return const Duration(seconds: 30);
      case AccessibilityTimeout.s60:
        return const Duration(minutes: 1);
      case AccessibilityTimeout.s120:
        return const Duration(minutes: 2);
    }
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

  static const radius = 160.0;
  static const strokeWidth = 16.0;

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
    final progressColor = Theme.of(context).colorScheme.secondary;
    return AbsorbPointer(
      child: StreamBuilder<T>(
        stream: opStream,
        builder: (context, snapshot) {
          final processedCount = processed.length.toDouble();
          final total = widget.itemCount;
          assert(processedCount <= total);
          final percent = min(1.0, processedCount / total);
          final animate = context.select<Settings, bool>((v) => v.accessibilityAnimations.animate);
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
                child: Stack(
                  children: [
                    if (animate)
                      Container(
                        width: radius,
                        height: radius,
                        padding: const EdgeInsets.all(strokeWidth / 2),
                        child: CircularProgressIndicator(
                          color: progressColor.withOpacity(.1),
                          strokeWidth: strokeWidth,
                        ),
                      ),
                    CircularPercentIndicator(
                      percent: percent,
                      lineWidth: strokeWidth,
                      radius: radius,
                      backgroundColor: Colors.white24,
                      progressColor: progressColor,
                      animation: animate,
                      center: Text(NumberFormat.percentPattern().format(percent)),
                      animateFromLastPercent: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeedbackMessage extends StatefulWidget {
  final String message;
  final Duration? duration;
  final Color progressColor;

  const _FeedbackMessage({
    Key? key,
    required this.message,
    required this.progressColor,
    this.duration,
  }) : super(key: key);

  @override
  _FeedbackMessageState createState() => _FeedbackMessageState();
}

class _FeedbackMessageState extends State<_FeedbackMessage> {
  double _percent = 0;
  late int _remainingSecs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration;
    if (duration != null) {
      _remainingSecs = duration.inSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _remainingSecs--);
      });
      WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() => _percent = 1.0));
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
                percent: _percent,
                lineWidth: 2,
                radius: 32,
                // progress color is provided by the caller,
                // because we cannot use the app context theme here
                backgroundColor: widget.progressColor,
                progressColor: Colors.grey,
                animation: true,
                animationDuration: duration.inMilliseconds,
                center: Text('$_remainingSecs'),
                animateFromLastPercent: true,
                reverse: true,
              ),
            ],
          );
  }
}
