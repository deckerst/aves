import 'dart:async';

import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/quick_chooser.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class RateQuickChooser extends StatefulWidget {
  final bool blurred;
  final ValueNotifier<int?> valueNotifier;
  final Stream<Offset> pointerGlobalPosition;

  const RateQuickChooser({
    super.key,
    required this.blurred,
    required this.valueNotifier,
    required this.pointerGlobalPosition,
  });

  @override
  State<RateQuickChooser> createState() => _RateQuickChooserState();
}

class _RateQuickChooserState extends State<RateQuickChooser> {
  final Set<StreamSubscription> _subscriptions = {};

  ValueNotifier<int?> get valueNotifier => widget.valueNotifier;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant RateQuickChooser oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(RateQuickChooser widget) {
    _subscriptions.add(widget.pointerGlobalPosition.listen(_onPointerMove));
  }

  void _unregisterWidget(RateQuickChooser widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return QuickChooser(
      blurred: widget.blurred,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ValueListenableBuilder<int?>(
          valueListenable: valueNotifier,
          builder: (context, selectedValue, child) {
            final _rating = selectedValue ?? 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final disabled = _rating < i + 1;
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    AIcons.rating,
                    fill: disabled ? 0 : 1,
                    color: disabled ? AColors.starDisabled : AColors.starEnabled,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _onPointerMove(Offset globalPosition) {
    final padding = QuickChooser.margin.horizontal + QuickChooser.padding.horizontal;

    final chooserBox = context.findRenderObject() as RenderBox;
    final chooserSize = chooserBox.size;
    final contentWidth = chooserSize.width - padding;

    final local = chooserBox.globalToLocal(globalPosition);
    final t = (local.dx - padding / 2) / contentWidth;
    valueNotifier.value = (5 * (context.isRtl ? 1 - t : t)).ceil().clamp(0, 5);
  }
}
