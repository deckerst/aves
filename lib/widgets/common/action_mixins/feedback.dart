import 'dart:async';
import 'dart:math';

import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

mixin FeedbackMixin {
  void dismissFeedback(BuildContext context) => ScaffoldMessenger.of(context).hideCurrentSnackBar();

  void showFeedback(BuildContext context, String message, [SnackBarAction? action]) {
    ScaffoldMessengerState? scaffoldMessenger;
    try {
      scaffoldMessenger = ScaffoldMessenger.of(context);
    } catch (e) {
      // minor issue: the page triggering this feedback likely
      // allows the user to navigate away and they did so
      debugPrint('failed to find ScaffoldMessenger in context');
    }
    if (scaffoldMessenger != null) {
      showFeedbackWithMessenger(context, scaffoldMessenger, message, action);
    }
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

  Future<void> showOpReport<T>({
    required BuildContext context,
    required Stream<T> opStream,
    required int itemCount,
    VoidCallback? onCancel,
    void Function(Set<T> processed)? onDone,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReportOverlay<T>(
        opStream: opStream,
        itemCount: itemCount,
        onCancel: onCancel,
        onDone: (processed) {
          Navigator.pop(context);
          onDone?.call(processed);
        },
      ),
    );
  }
}

class ReportOverlay<T> extends StatefulWidget {
  final Stream<T> opStream;
  final int itemCount;
  final VoidCallback? onCancel;
  final void Function(Set<T> processed) onDone;

  const ReportOverlay({
    Key? key,
    required this.opStream,
    required this.itemCount,
    required this.onCancel,
    required this.onDone,
  }) : super(key: key);

  @override
  State<ReportOverlay<T>> createState() => _ReportOverlayState<T>();
}

class _ReportOverlayState<T> extends State<ReportOverlay<T>> with SingleTickerProviderStateMixin {
  final processed = <T>{};
  late AnimationController _animationController;
  late Animation<double> _animation;

  Stream<T> get opStream => widget.opStream;

  static const fontSize = 18.0;
  static const diameter = 160.0;
  static const strokeWidth = 8.0;

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
    final animate = context.select<Settings, bool>((v) => v.accessibilityAnimations.animate);
    return WillPopScope(
      onWillPop: () => SynchronousFuture(false),
      child: StreamBuilder<T>(
        stream: opStream,
        builder: (context, snapshot) {
          final processedCount = processed.length.toDouble();
          final total = widget.itemCount;
          final percent = min(1.0, processedCount / total);
          return FadeTransition(
            opacity: _animation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: diameter + 2,
                  height: diameter + 2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xBB000000) : const Color(0xEEFFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
                if (animate)
                  Container(
                    width: diameter,
                    height: diameter,
                    padding: const EdgeInsets.all(strokeWidth / 2),
                    child: CircularProgressIndicator(
                      color: progressColor.withOpacity(.1),
                      strokeWidth: strokeWidth,
                    ),
                  ),
                CircularPercentIndicator(
                  percent: percent,
                  lineWidth: strokeWidth,
                  radius: diameter / 2,
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
                  progressColor: progressColor,
                  animation: animate,
                  center: Text(
                    NumberFormat.percentPattern().format(percent),
                    style: const TextStyle(fontSize: fontSize),
                  ),
                  animateFromLastPercent: true,
                ),
                if (widget.onCancel != null)
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      width: diameter,
                      height: diameter,
                      margin: const EdgeInsets.only(top: fontSize),
                      alignment: const FractionalOffset(0.5, 0.75),
                      child: Tooltip(
                        message: context.l10n.cancelTooltip,
                        preferBelow: false,
                        child: IconButton(
                          icon: const Icon(AIcons.cancel),
                          onPressed: widget.onCancel,
                        ),
                      ),
                    ),
                  ),
              ],
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
  State<_FeedbackMessage> createState() => _FeedbackMessageState();
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
    final theme = Theme.of(context);
    final contentTextStyle = theme.snackBarTheme.contentTextStyle ?? ThemeData(brightness: theme.brightness).textTheme.subtitle1;
    return duration == null
        ? text
        : Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 16),
              CircularPercentIndicator(
                percent: _percent,
                lineWidth: 2,
                radius: 16,
                // progress color is provided by the caller,
                // because we cannot use the app context theme here
                backgroundColor: widget.progressColor,
                progressColor: Colors.grey,
                animation: true,
                animationDuration: duration.inMilliseconds,
                center: Text(
                  '$_remainingSecs',
                  style: contentTextStyle,
                ),
                animateFromLastPercent: true,
                reverse: true,
              ),
            ],
          );
  }
}

class ActionFeedback extends StatefulWidget {
  final Widget? child;

  const ActionFeedback({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ActionFeedback> createState() => _ActionFeedbackState();
}

class _ActionFeedbackState extends State<ActionFeedback> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Durations.viewerActionFeedbackAnimation,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant ActionFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.child != widget.child) {
      _animationController.reset();
      if (widget.child != null) {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final t = _animationController.value;
            final opacity = Curves.easeOutQuad.transform(t > .5 ? (1 - t) * 2 : t * 2);
            final scale = Curves.slowMiddle.transform(t) * 2;
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
