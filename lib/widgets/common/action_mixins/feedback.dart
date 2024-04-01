import 'dart:async';
import 'dart:math';

import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/accessibility_timeout.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_mixins/overlay_snack_bar.dart';
import 'package:aves/widgets/common/basic/circle.dart';
import 'package:aves/widgets/common/basic/text/change_highlight.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

enum FeedbackType { info, warn }

mixin FeedbackMixin {
  static final ValueNotifier<EdgeInsets?> snackBarMarginOverrideNotifier = ValueNotifier(null);

  static EdgeInsets snackBarMarginDefault(BuildContext context) {
    final mq = context.read<MediaQueryData>();
    return EdgeInsets.only(bottom: max(mq.effectiveBottomPadding, mq.systemGestureInsets.bottom));
  }

  void dismissFeedback(BuildContext context) => ScaffoldMessenger.of(context).hideCurrentSnackBar();

  void showFeedback(BuildContext context, FeedbackType type, String message, [SnackBarAction? action]) {
    ScaffoldMessengerState? scaffoldMessenger;
    try {
      scaffoldMessenger = ScaffoldMessenger.of(context);
    } catch (error) {
      // minor issue: the page triggering this feedback likely
      // allows the user to navigate away and they did so
      debugPrint('failed to find ScaffoldMessenger in context');
    }
    if (scaffoldMessenger != null) {
      showFeedbackWithMessenger(context, scaffoldMessenger, type, message, action);
    }
  }

  // provide the messenger if feedback happens as the widget is disposed
  void showFeedbackWithMessenger(BuildContext context, ScaffoldMessengerState messenger, FeedbackType type, String message, [SnackBarAction? action]) {
    settings.timeToTakeAction.getSnackBarDuration(action != null).then((duration) {
      final start = DateTime.now();
      final theme = Theme.of(context);
      final snackBarTheme = theme.snackBarTheme;

      final snackBarContent = _FeedbackMessage(
        type: type,
        message: message,
        progressColor: theme.colorScheme.primary,
        start: start,
        stop: action != null ? start.add(duration) : null,
      );

      if (snackBarMarginOverrideNotifier.value != null) {
        // as of Flutter v2.10.4, `SnackBar` can only be positioned at the bottom,
        // and space under the snack bar `margin` does not receive gestures
        // (because it is used by the `Dismissible` wrapping the snack bar)
        // so we use `showOverlayNotification` instead
        OverlaySupportEntry? notificationOverlayEntry;
        notificationOverlayEntry = showOverlayNotification(
          (context) => SafeArea(
            bottom: false,
            child: ValueListenableBuilder<EdgeInsets?>(
              valueListenable: snackBarMarginOverrideNotifier,
              builder: (context, margin, child) {
                return AnimatedPadding(
                  padding: margin ?? snackBarMarginDefault(context),
                  duration: ADurations.pageTransitionAnimation,
                  child: child,
                );
              },
              child: OverlaySnackBar(
                content: snackBarContent,
                action: action != null
                    ? TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(snackBarTheme.actionTextColor),
                        ),
                        onPressed: () {
                          notificationOverlayEntry?.dismiss();
                          action.onPressed();
                        },
                        child: Text(action.label),
                      )
                    : null,
                animation: kAlwaysCompleteAnimation,
                dismissDirection: DismissDirection.horizontal,
                onDismiss: () => notificationOverlayEntry?.dismiss(),
              ),
            ),
          ),
          duration: duration,
          // reuse the same key to dismiss previous snack bar when a new one is shown
          key: const Key('snack'),
          position: NotificationPosition.bottom,
          context: context,
        );
      } else {
        messenger.showSnackBar(SnackBar(
          content: snackBarContent,
          padding: action != null ? EdgeInsetsDirectional.only(start: snackBarHorizontalPadding(snackBarTheme)) : null,
          action: action,
          duration: duration,
          dismissDirection: DismissDirection.horizontal,
        ));
      }
    });
  }

  static double snackBarHorizontalPadding(SnackBarThemeData snackBarTheme) {
    final isFloatingSnackBar = (snackBarTheme.behavior ?? SnackBarBehavior.fixed) == SnackBarBehavior.floating;
    final horizontalPadding = isFloatingSnackBar ? 16.0 : 24.0;
    return horizontalPadding;
  }

  // report overlay for multiple operations

  Future<void> showOpReport<T>({
    required BuildContext context,
    required Stream<T> opStream,
    int? itemCount,
    VoidCallback? onCancel,
    Future<void> Function(Set<T> processed)? onDone,
  }) async {
    final completer = Completer();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReportOverlay<T>(
        opStream: opStream,
        itemCount: itemCount,
        onCancel: onCancel,
        onDone: (processed) async {
          Navigator.maybeOf(context)?.pop();
          await onDone?.call(processed);
          completer.complete();
        },
      ),
      routeSettings: const RouteSettings(name: ReportOverlay.routeName),
    );
    return completer.future;
  }
}

class ReportOverlay<T> extends StatefulWidget {
  static const routeName = '/dialog/report_overlay';

  final Stream<T> opStream;
  final int? itemCount;
  final VoidCallback? onCancel;
  final void Function(Set<T> processed) onDone;

  const ReportOverlay({
    super.key,
    required this.opStream,
    required this.itemCount,
    required this.onCancel,
    required this.onDone,
  });

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
      duration: ADurations.collectionOpOverlayAnimation,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressColor = colorScheme.primary;
    final animate = context.select<Settings, bool>((v) => v.accessibilityAnimations.animate);
    return PopScope(
      canPop: false,
      child: StreamBuilder<T>(
        stream: opStream,
        builder: (context, snapshot) {
          final processedCount = processed.length.toDouble();
          final total = widget.itemCount;
          final percent = total == null || total == 0 ? 0.0 : min(1.0, processedCount / total);
          final percentFormat = NumberFormat.percentPattern();
          return FadeTransition(
            opacity: _animation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: diameter + 2,
                  height: diameter + 2,
                  decoration: BoxDecoration(
                    color: theme.isDark ? const Color(0xBB000000) : const Color(0xEEFFFFFF),
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
                  backgroundColor: colorScheme.onSurface.withOpacity(.2),
                  progressColor: progressColor,
                  animation: animate,
                  center: total != null
                      ? Text(
                          percentFormat.format(percent),
                          style: const TextStyle(fontSize: fontSize),
                        )
                      : null,
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
  final FeedbackType type;
  final String message;
  final DateTime? start, stop;
  final Color progressColor;

  const _FeedbackMessage({
    required this.type,
    required this.message,
    required this.progressColor,
    this.start,
    this.stop,
  });

  @override
  State<_FeedbackMessage> createState() => _FeedbackMessageState();
}

class _FeedbackMessageState extends State<_FeedbackMessage> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<int>? _remainingDurationMillis;
  int? _totalDurationMillis;

  @override
  void initState() {
    super.initState();
    final start = widget.start;
    final stop = widget.stop;
    if (start != null && stop != null) {
      _totalDurationMillis = stop.difference(start).inMilliseconds;
      final remainingDuration = stop.difference(DateTime.now());
      final effectiveDuration = remainingDuration > Duration.zero ? remainingDuration : const Duration(milliseconds: 1);
      _animationController = AnimationController(
        duration: effectiveDuration,
        vsync: this,
      );
      _remainingDurationMillis = IntTween(
        begin: effectiveDuration.inMilliseconds,
        end: 0,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ));
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final contentTextStyle = theme.snackBarTheme.contentTextStyle ??
        theme.textTheme.bodyMedium!.copyWith(
          color: colorScheme.onInverseSurface,
        );
    final contentTextFontSize = contentTextStyle.fontSize ?? theme.textTheme.bodyMedium!.fontSize!;
    final timerChangeShadowColor = colorScheme.primary;

    final remainingDurationAnimation = _remainingDurationMillis;
    return Row(
      children: [
        if (widget.type == FeedbackType.warn) ...[
          CustomPaint(
            painter: const _WarnIndicator(AColors.warning),
            size: Size(4, textScaler.scale(contentTextFontSize)),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(widget.message)),
        if (remainingDurationAnimation != null) ...[
          const SizedBox(width: 16),
          AnimatedBuilder(
            animation: remainingDurationAnimation,
            builder: (context, child) {
              final remainingDurationMillis = remainingDurationAnimation.value;
              final totalDurationMillis = _totalDurationMillis;
              return CircularIndicator(
                radius: 16,
                lineWidth: 2,
                percent: totalDurationMillis != null && totalDurationMillis > 0 ? remainingDurationMillis / totalDurationMillis : 0,
                background: Colors.grey,
                // progress color is provided by the caller,
                // because we cannot use the app context theme here
                foreground: widget.progressColor,
                center: ChangeHighlightText(
                  '${(remainingDurationMillis / 1000).ceil()}',
                  style: contentTextStyle.copyWith(
                    shadows: [
                      Shadow(
                        color: timerChangeShadowColor.withOpacity(0),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  changedStyle: contentTextStyle.copyWith(
                    shadows: [
                      Shadow(
                        color: timerChangeShadowColor,
                        blurRadius: 5,
                      )
                    ],
                  ),
                  duration: context.read<DurationsData>().formTextStyleTransition,
                ),
              );
            },
          ),
        ]
      ],
    );
  }
}

class _WarnIndicator extends CustomPainter {
  final Color color;

  const _WarnIndicator(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(size.shortestSide / 2)),
      Paint()
        ..style = PaintingStyle.fill
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_WarnIndicator oldDelegate) => false;
}

class ActionFeedback extends StatefulWidget {
  final Widget? child;

  const ActionFeedback({
    super.key,
    required this.child,
  });

  @override
  State<ActionFeedback> createState() => _ActionFeedbackState();
}

class _ActionFeedbackState extends State<ActionFeedback> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ADurations.viewerActionFeedbackAnimation,
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
