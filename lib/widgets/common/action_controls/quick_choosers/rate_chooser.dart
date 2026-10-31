import 'dart:async';

import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/quick_chooser.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:material_ui/material_ui.dart';

class const RateQuickChooser({
  super.key,
  required final bool blurred,
  required final ValueNotifier<Set<int>> valuesNotifier,
  required final Stream<Offset> pointerGlobalPosition,
}) extends StatefulWidget {
  @override
  State<RateQuickChooser> createState() => _RateQuickChooserState();
}

class _RateQuickChooserState extends State<RateQuickChooser> {
  final Set<StreamSubscription> _subscriptions = {};

  ValueNotifier<Set<int>> get valuesNotifier => widget.valuesNotifier;

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
        child: ValueListenableBuilder<Set<int>>(
          valueListenable: valuesNotifier,
          builder: (context, selectedValues, child) {
            final _rating = selectedValues.isNotEmpty ? selectedValues.first : 0;
            return Row(
              mainAxisSize: .min,
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
    final rating = (5 * (context.isRtl ? 1 - t : t)).ceil().clamp(0, 5);
    valuesNotifier.value = {rating};
  }
}
