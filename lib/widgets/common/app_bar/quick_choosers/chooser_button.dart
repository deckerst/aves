import 'dart:async';

import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/route_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class ChooserQuickButton<T> extends StatefulWidget {
  final bool blurred;
  final ValueSetter<T>? onChooserValue;
  final VoidCallback? onPressed;

  const ChooserQuickButton({
    super.key,
    required this.blurred,
    this.onChooserValue,
    required this.onPressed,
  });
}

abstract class ChooserQuickButtonState<T extends ChooserQuickButton<U>, U> extends State<T> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  OverlayEntry? _chooserOverlayEntry;
  final ValueNotifier<U?> _chooserValueNotifier = ValueNotifier(null);
  final StreamController<LongPressMoveUpdateDetails> _moveUpdateStreamController = StreamController.broadcast();

  Widget get icon;

  String get tooltip;

  U? get defaultValue => null;

  Duration get animationDuration => context.read<DurationsData>().quickChooserAnimation;

  Curve get animationCurve => Curves.easeOutQuad;

  Widget buildChooser(Animation<double> animation, PopupMenuPosition chooserPosition);

  ValueNotifier<U?> get chooserValueNotifier => _chooserValueNotifier;

  Stream<Offset> get pointerGlobalPosition => _moveUpdateStreamController.stream.map((event) => event.globalPosition);

  @override
  void dispose() {
    _animationController?.dispose();
    _clearChooserOverlayEntry();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onChooserValue = widget.onChooserValue;
    final isChooserEnabled = onChooserValue != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: isChooserEnabled ? _showChooser : null,
      onLongPressMoveUpdate: isChooserEnabled ? _moveUpdateStreamController.add : null,
      onLongPressEnd: isChooserEnabled
          ? (details) {
              _clearChooserOverlayEntry();
              final selectedValue = _chooserValueNotifier.value;
              if (selectedValue != null) {
                onChooserValue(selectedValue);
              }
            }
          : null,
      onLongPressCancel: _clearChooserOverlayEntry,
      child: IconButton(
        icon: icon,
        onPressed: widget.onPressed,
        tooltip: isChooserEnabled ? null : tooltip,
      ),
    );
  }

  void _clearChooserOverlayEntry() {
    if (_chooserOverlayEntry != null) {
      _chooserOverlayEntry!.remove();
      _chooserOverlayEntry = null;
    }
  }

  void _showChooser(LongPressStartDetails details) {
    final overlay = Overlay.of(context)!;
    final triggerBox = context.findRenderObject() as RenderBox;
    final overlayBox = overlay.context.findRenderObject() as RenderBox;
    final triggerRect = RelativeRect.fromRect(
      triggerBox.localToGlobal(Offset.zero, ancestor: overlayBox) & triggerBox.size,
      Offset.zero & overlayBox.size,
    );

    _chooserValueNotifier.value = defaultValue;
    _chooserOverlayEntry = OverlayEntry(
      builder: (context) {
        final mq = MediaQuery.of(context);
        final chooserPosition = (details.globalPosition.dy > mq.size.height / 2) ? PopupMenuPosition.over : PopupMenuPosition.under;
        return CustomSingleChildLayout(
          delegate: QuickChooserRouteLayout(
            triggerRect,
            chooserPosition,
            mq.padding,
            DisplayFeatureSubScreen.avoidBounds(mq).toSet(),
          ),
          child: buildChooser(_animation!, chooserPosition),
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
