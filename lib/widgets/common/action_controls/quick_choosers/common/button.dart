import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/route_layout.dart';
import 'package:aves/widgets/common/basic/gestures/gesture_detector.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

abstract class const ChooserQuickButton<T>({
  super.key,
  required final bool blurred,
  final ValueSetter<Set<T>>? onChooserValues,
  final bool allowMultipleSelection = false,
  final FocusNode? focusNode,
  required final VoidCallback? onPressed,
}) extends StatefulWidget;

enum SelectionMode { single, multiple }

abstract class ChooserQuickButtonState<T extends ChooserQuickButton<U>, U> extends State<T> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  CurvedAnimation? _animation;
  OverlayEntry? _chooserOverlayEntry;
  final ValueNotifier<SelectionMode> _selectionModeNotifier = ValueNotifier(.single);
  final ValueNotifier<Set<U>> _chooserValuesNotifier = ValueNotifier({});
  final StreamController<LongPressMoveUpdateDetails> _moveUpdateStreamController = StreamController.broadcast();

  Widget get icon;

  String get tooltip;

  Duration get animationDuration => context.read<DurationsData>().quickChooserAnimation;

  Curve get animationCurve => Curves.easeOutQuad;

  bool get hasChooser => widget.onChooserValues != null;

  Widget buildChooser(Animation<double> animation, PopupMenuPosition chooserPosition);

  ValueNotifier<SelectionMode> get selectionModeNotifier => _selectionModeNotifier;

  ValueNotifier<Set<U>> get chooserValuesNotifier => _chooserValuesNotifier;

  Stream<Offset> get pointerGlobalPosition => _moveUpdateStreamController.stream.map((event) => event.globalPosition);

  @override
  void dispose() {
    _animation?.dispose();
    _animationController?.dispose();
    _clearChooserOverlayEntry();
    _selectionModeNotifier.dispose();
    _chooserValuesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _hasChooser = hasChooser;

    Widget child = IconButton(
      icon: icon,
      onPressed: widget.onPressed,
      focusNode: widget.focusNode,
      tooltip: _hasChooser ? null : tooltip,
    );
    if (_hasChooser) {
      child = Semantics(
        tooltip: tooltip,
        child: child,
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Theme(
      data: theme.copyWith(
        colorScheme: colorScheme.copyWith(
          onSurfaceVariant: colorScheme.onSurface,
        ),
      ),
      child: AGestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: _hasChooser ? _showChooser : null,
        onLongPressMoveUpdate: _hasChooser ? _moveUpdateStreamController.add : null,
        onLongPressEnd: _hasChooser
            ? (details) {
                if (widget.allowMultipleSelection) {
                  final triggerBox = context.findRenderObject() as RenderBox;
                  final result = BoxHitTestResult();
                  if (triggerBox.hitTest(result, position: details.localPosition)) {
                    _selectionModeNotifier.value = .multiple;
                    return;
                  }
                }
                _submitSelectedValues();
              }
            : null,
        onLongPressCancel: _clearChooserOverlayEntry,
        longPressTimeout: settings.longPressTimeout,
        child: child,
      ),
    );
  }

  void _clearChooserOverlayEntry() {
    _chooserOverlayEntry
      ?..remove()
      ..dispose();
    _chooserOverlayEntry = null;
  }

  void _submitSelectedValues() {
    _clearChooserOverlayEntry();

    final selectedValues = _chooserValuesNotifier.value;
    if (selectedValues.isNotEmpty) {
      widget.onChooserValues?.call(selectedValues);
    }
  }

  void _showChooser(LongPressStartDetails details) {
    final overlay = Overlay.of(context);
    final triggerBox = context.findRenderObject() as RenderBox;
    final overlayBox = overlay.context.findRenderObject() as RenderBox;
    final triggerRect = RelativeRect.fromRect(
      triggerBox.localToGlobal(Offset.zero, ancestor: overlayBox) & triggerBox.size,
      Offset.zero & overlayBox.size,
    );

    _selectionModeNotifier.value = .single;
    _chooserOverlayEntry = OverlayEntry(
      builder: (context) {
        final mq = MediaQuery.of(context);
        final chooserPosition = (details.globalPosition.dy > mq.size.height / 2) ? PopupMenuPosition.over : PopupMenuPosition.under;
        return Stack(
          children: [
            const Positioned.fill(
              child: AbsorbPointer(),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: _submitSelectedValues,
              ),
            ),
            CustomSingleChildLayout(
              delegate: QuickChooserRouteLayout(
                triggerRect,
                chooserPosition,
                mq.padding,
                DisplayFeatureSubScreen.avoidBounds(mq).toSet(),
              ),
              child: buildChooser(_animation!, chooserPosition),
            ),
          ],
        );
      },
    );
    if (_animationController == null) {
      _animationController = AnimationController(
        duration: animationDuration,
        vsync: this,
      );
      _animation = CurvedAnimation(
        parent: _animationController!,
        curve: animationCurve,
      );
    }
    _animationController!.reset();
    overlay.insert(_chooserOverlayEntry!);
    _animationController!.forward();
  }
}
