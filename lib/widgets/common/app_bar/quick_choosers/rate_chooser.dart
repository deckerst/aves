import 'dart:async';

import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class RateQuickChooser extends StatefulWidget {
  final ValueNotifier<int?> valueNotifier;
  final Stream<Offset> pointerGlobalPosition;

  const RateQuickChooser({
    super.key,
    required this.valueNotifier,
    required this.pointerGlobalPosition,
  });

  @override
  State<RateQuickChooser> createState() => _RateQuickChooserState();
}

class _RateQuickChooserState extends State<RateQuickChooser> {
  final List<StreamSubscription> _subscriptions = [];

  ValueNotifier<int?> get valueNotifier => widget.valueNotifier;

  static const margin = EdgeInsets.all(8);
  static const padding = EdgeInsets.all(8);

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
    return Padding(
      padding: margin,
      child: Material(
        shape: AvesDialog.shape(context),
        child: Padding(
          padding: padding,
          child: ValueListenableBuilder<int?>(
            valueListenable: valueNotifier,
            builder: (context, selectedValue, child) {
              final _rating = selectedValue ?? 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final thisRating = i + 1;
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _rating < thisRating ? AIcons.rating : AIcons.ratingFull,
                      color: _rating < thisRating ? Colors.grey : Colors.amber,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onPointerMove(Offset globalPosition) {
    final chooserBox = context.findRenderObject() as RenderBox;
    final chooserSize = chooserBox.size;
    final contentWidth = chooserSize.width - (margin.horizontal + padding.horizontal);

    final local = chooserBox.globalToLocal(globalPosition);
    final dx = local.dx - (margin.horizontal + padding.horizontal) / 2;

    valueNotifier.value = (5 * dx / contentWidth).ceil().clamp(0, 5);
  }
}
